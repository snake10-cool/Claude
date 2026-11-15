/* JS-Laufzeit für den Kurs: führt Schüler-JavaScript echt aus – im Browser in einem eigenen Web Worker
 * (abgeschottet, mit Zeitlimit), beim Bauen in Node über vm. Gleiche Ausgabe-Formatierung und deutsche Fehler.
 *   JSRun.start(code, { onOut(text, kind), onDone({ error }), timeout })  -> { stop() }
 *   JSRun.run(code, { timeout })                                        -> Promise<{ output, parts, error }>
 */
(function (root) {
  'use strict';

  // ------------------------------------------------------------------ Läuft IM Sandbox-Kontext (Worker bzw. vm)
  function prelude() {
    const H = (typeof __host !== 'undefined' && __host) || globalThis;
    const emit = typeof __emit !== 'undefined' ? __emit : (k, p) => postMessage({ k, p });
    const realST = H.setTimeout.bind(H), realCT = H.clearTimeout.bind(H), realSI = H.setInterval.bind(H), realCI = H.clearInterval.bind(H);
    let pending = 0, lines = 0, cut = false, failed = false;
    const timers = new Set(), intervals = new Set();
    const isPlain = o => { const p = Object.getPrototypeOf(o); return p === Object.prototype || p === null; };
    function fmt(v, depth, seen, nested) {
      if (typeof v === 'string') return nested ? JSON.stringify(v) : v;
      if (typeof v === 'number') return Object.is(v, -0) ? '0' : String(v);
      if (typeof v === 'bigint') return v + 'n';
      if (v === undefined || v === null || typeof v === 'boolean' || typeof v === 'symbol') return String(v);
      if (typeof v === 'function') return /^class\b/.test(Function.prototype.toString.call(v)) ? `[Klasse ${v.name}]` : `[Funktion ${v.name || '(anonym)'}]`;
      if (seen.has(v)) return '[Kreis]';
      if (v instanceof Error) return `${v.name}: ${v.message}`;
      if (depth > 3) return Array.isArray(v) ? '[Array]' : '[Objekt]';
      seen.add(v);
      let s;
      if (Array.isArray(v)) {
        const items = v.slice(0, 100).map(x => fmt(x, depth + 1, seen, true));
        if (v.length > 100) items.push(`… ${v.length - 100} weitere`);
        s = `[${items.join(', ')}]`;
      } else if (v instanceof Map) s = `Map(${v.size}) {${v.size ? ' ' + [...v].map(([k, x]) => fmt(k, depth + 1, seen, true) + ' => ' + fmt(x, depth + 1, seen, true)).join(', ') + ' ' : ''}}`;
      else if (v instanceof Set) s = `Set(${v.size}) {${v.size ? ' ' + [...v].map(x => fmt(x, depth + 1, seen, true)).join(', ') + ' ' : ''}}`;
      else if (v instanceof Promise) s = 'Promise { … }';
      else if (v instanceof Date) s = v.toISOString();
      else {
        const keys = Object.keys(v);
        const body = keys.map(k => (/^[A-Za-z_$][\w$]*$/.test(k) ? k : JSON.stringify(k)) + ': ' + fmt(v[k], depth + 1, seen, true)).join(', ');
        const name = isPlain(v) ? '' : ((v.constructor && v.constructor.name) || 'Objekt') + ' ';
        s = name + (keys.length ? `{ ${body} }` : '{}');
      }
      seen.delete(v);
      return s;
    }
    const show = args => args.map(a => fmt(a, 0, new Set(), false)).join(' ');
    function out(kind, text) {
      if (cut) return;
      if (++lines > 2000) { cut = true; emit('out', { kind: 'meta', text: '… (Ausgabe nach 2000 Zeilen gekürzt)\n' }); return; }
      emit('out', { kind, text });
    }
    const errInfo = e => e && typeof e === 'object' ? { name: e.name || 'Error', message: String(e.message), stack: String(e.stack || '') } : { name: 'Error', message: 'Es wurde ' + fmt(e, 0, new Set(), true) + ' geworfen', stack: '' };
    function fail(e) { if (failed) return; failed = true; for (const t of timers) realCT(t); for (const t of intervals) realCI(t); emit('error', errInfo(e)); }
    const guard = fn => function () { try { return fn.apply(this, arguments); } catch (e) { fail(e); } };
    const con = {
      log: (...a) => out('out', show(a) + '\n'), info: (...a) => out('out', show(a) + '\n'), debug: (...a) => out('out', show(a) + '\n'),
      warn: (...a) => out('warn', show(a) + '\n'), error: (...a) => out('err', show(a) + '\n'),
      table: (d) => { if (d && typeof d === 'object') for (const k of Object.keys(d)) out('out', k + ' │ ' + fmt(d[k], 1, new Set(), true) + '\n'); else out('out', show([d]) + '\n'); },
      clear: () => {},
    };
    Object.defineProperty(globalThis, 'console', { value: con, writable: true, configurable: true });
    globalThis.setTimeout = (fn, ms, ...args) => { pending++; const id = realST(() => { timers.delete(id); pending--; guard(fn)(...args); }, ms); timers.add(id); return id; };
    globalThis.clearTimeout = id => { if (timers.delete(id)) { pending--; realCT(id); } };
    globalThis.setInterval = (fn, ms, ...args) => { pending++; const id = realSI(guard(() => fn(...args)), Math.max(ms || 0, 10)); intervals.add(id); return id; };
    globalThis.clearInterval = id => { if (intervals.delete(id)) { pending--; realCI(id); } };
    if (typeof self !== 'undefined' && self.addEventListener && typeof __emit === 'undefined') {
      self.onerror = (msg, src, line, col, e) => { fail(e || { name: 'Error', message: String(msg), stack: 'main.js:' + line + ':' + col }); return true; };
      self.addEventListener('unhandledrejection', ev => { ev.preventDefault(); fail(ev.reason); });
    }
    globalThis.__rejected = fail;
    globalThis.__finish = () => {
      const check = () => { if (failed) return; if (pending === 0) realST(() => { if (failed) return; if (pending === 0) emit('done', null); else realST(check, 20); }, 15); else realST(check, 20); };
      check();
    };
  }
  const PRELUDE = "'use strict';(" + prelude.toString() + ')();';
  const OFFSET = PRELUDE.split('\n').length;

  // ------------------------------------------------------------------ Deutsche Fehlermeldungen
  const MSG = [
    [/^(\S+) is not defined$/, m => [`${m[1]} ist nicht definiert`, 'Tippfehler im Namen? Oder fehlt let/const beim Anlegen? Groß- und Kleinschreibung zählt.']],
    [/^Cannot access '(.+)' before initialization$/, m => [`${m[1]} wird benutzt, bevor es angelegt wurde`, 'Schieb die Zeile mit let/const/class nach oben, vor die erste Benutzung.']],
    [/^Assignment to constant variable\.?$/, () => ['Einer const-Variable kann man keinen neuen Wert geben', 'Nimm let statt const, wenn sich der Wert ändern soll.']],
    [/^(.+) is not a function$/, m => [`${m[1]} ist keine Funktion`, 'Stimmt der Name? Klammern () gehören nur hinter Funktionen.']],
    [/^(.+) is not a constructor$/, m => [`${m[1]} kann man nicht mit new erzeugen`, 'new funktioniert nur mit Klassen.']],
    [/^Class constructor (\S+) cannot be invoked without 'new'$/, m => [`Die Klasse ${m[1]} braucht new`, `Schreib new ${m[1]}(…).`]],
    [/^Cannot read properties of (undefined|null) \(reading '(.+)'\)$/, m => [`.${m[2]} kann nicht gelesen werden – der Wert davor ist ${m[1]}`, 'Prüf, ob die Variable wirklich ein Objekt bzw. Array enthält – oder ob ein Index zu groß ist.']],
    [/^Cannot set properties of (undefined|null) \(setting '(.+)'\)$/, m => [`.${m[2]} kann nicht gesetzt werden – der Wert davor ist ${m[1]}`, 'Das Objekt existiert noch nicht. Hast du es angelegt?']],
    [/^(.+) is not iterable$/, m => [`${m[1]} kann man nicht durchlaufen`, 'for…of funktioniert mit Arrays, Strings, Maps und Sets – nicht mit normalen Objekten (dafür Object.keys).']],
    [/^Identifier '(.+)' has already been declared$/, m => [`${m[1]} wurde schon einmal angelegt`, 'Jeder Name darf pro Block nur einmal mit let/const angelegt werden. Zum Ändern einfach ohne let zuweisen.']],
    [/^Unexpected token '(.+)'$/, m => [`Unerwartetes Zeichen „${m[1]}“`, 'Oft fehlt davor eine Klammer, ein Komma oder ein Operator.']],
    [/^Unexpected identifier(?: '(.+)')?$/, m => [`Unerwarteter Name${m[1] ? ' „' + m[1] + '“' : ''}`, 'Fehlt davor ein Komma, ein Operator oder eine Klammer?']],
    [/^Unexpected end of input$/, () => ['Der Code hört mittendrin auf', 'Fehlt am Ende eine schließende } oder )?']],
    [/^missing \) after argument list$/, () => ['Es fehlt eine ) nach den Argumenten', 'Zähl die Klammern beim Funktionsaufruf – und prüf, ob zwischen den Argumenten Kommas stehen.']],
    [/^Invalid or unexpected token$/, () => ['Ungültiges Zeichen im Code', 'Ist ein Text nicht mit " oder \' geschlossen? Oder ein Sonderzeichen hineingerutscht?']],
    [/^Unexpected string$/, () => ['Unerwarteter Text', 'Fehlt zwischen den Teilen ein + oder ein Komma?']],
    [/^Unexpected number$/, () => ['Unerwartete Zahl', 'Fehlt davor ein Operator oder ein Komma?']],
    [/^Unexpected template string$/, () => ['Unerwarteter Template-String', 'Fehlt davor ein + oder ein Komma?']],
    [/^Unexpected strict mode reserved word$/, () => ['Reserviertes Wort an falscher Stelle', 'await geht nur in async-Funktionen.']],
    [/^await is only valid in async functions/, () => ['await geht nur in async-Funktionen', 'Schreib async vor die Funktion – oder benutze .then().']],
    [/^Maximum call stack size exceeded$/, () => ['Zu viele Funktionsaufrufe ineinander', 'Ruft sich eine Funktion endlos selbst auf? Dann fehlt eine Abbruch-Bedingung.']],
    [/^Invalid array length$/, () => ['Ungültige Array-Länge', 'Die Länge muss eine ganze Zahl ≥ 0 sein.']],
    [/^Missing initializer in const declaration$/, () => ['const braucht sofort einen Wert', 'Schreib const name = wert; – oder nimm let.']],
    [/^Unexpected reserved word$/, () => ['Reserviertes Wort an falscher Stelle', 'Wörter wie class, let, await darf man nicht als Namen benutzen – oder await steht außerhalb einer async-Funktion.']],
    [/^Illegal return statement$/, () => ['return steht außerhalb einer Funktion', 'return gibt es nur in Funktionen.']],
    [/^Invalid left-hand side in assignment$/, () => ['Hier kann man nichts zuweisen', 'Meintest du === (Vergleich) statt = (Zuweisung)?']],
  ];
  function lineOf(info) {
    if (info.line) return info.line;
    const m = /(?:main\.js|blob:[^\s)]+):(\d+):(\d+)/.exec(info.stack || '');
    return m ? Number(m[1]) - OFFSET : 0;
  }
  function describe(info) {
    const msg = String(info.message || '').replace(/^Uncaught (\w*Error: )?/, '');
    let text = msg, hint = '';
    for (const [re, f] of MSG) { const m = re.exec(msg); if (m) { [text, hint] = f(m); break; } }
    const line = lineOf(info);
    return { name: info.name || 'Error', message: text, original: msg, hint, line: line > 0 ? line : 0, syntax: info.name === 'SyntaxError' || /Unexpected|missing \)|Invalid or unexpected/.test(msg),
      text: `${line > 0 ? 'Zeile ' + line + ': ' : ''}${info.name || 'Error'} – ${text}` };
  }

  // ------------------------------------------------------------------ Browser: Web Worker
  function start(code, o) {
    o = o || {};
    const src = PRELUDE + '\n' + code + '\n;__finish();';
    let url, w, done = false;
    const finish = err => {
      if (done) return; done = true; clearTimeout(timer);
      try { w && w.terminate(); } catch (e) { /* egal */ }
      if (url) URL.revokeObjectURL(url);
      o.onDone && o.onDone({ error: err });
    };
    const timer = setTimeout(() => finish({ kind: 'timeout', text: `Zeitlimit von ${Math.round((o.timeout || 5000) / 1000)} s überschritten`, hint: 'Läuft eine Schleife endlos? Prüf die Bedingung und ob sich die Zählvariable ändert.' }), o.timeout || 5000);
    try {
      url = URL.createObjectURL(new Blob([src], { type: 'text/javascript' }));
      w = new Worker(url);
    } catch (e) { finish({ kind: 'runtime', text: 'JavaScript kann hier nicht gestartet werden: ' + e.message }); return { stop() {} }; }
    w.onmessage = e => {
      const { k, p } = e.data || {};
      if (k === 'out') o.onOut && o.onOut(p.text, p.kind);
      else if (k === 'error') { const d = describe(p); finish(Object.assign({ kind: d.syntax ? 'syntax' : 'runtime' }, d)); }
      else if (k === 'done') finish(null);
    };
    w.onerror = e => { e.preventDefault(); const d = describe({ name: /SyntaxError/.test(e.message) ? 'SyntaxError' : 'Error', message: e.message, line: e.lineno ? e.lineno - OFFSET : 0 }); finish(Object.assign({ kind: d.syntax ? 'syntax' : 'runtime' }, d)); };
    return { stop() { finish({ kind: 'stopped', text: 'Programm gestoppt' }); } };
  }
  function run(code, o) {
    return new Promise(res => {
      const parts = [];
      start(code, Object.assign({}, o, { onOut: (text, kind) => parts.push({ text, kind }), onDone: ({ error }) => res({ parts, output: parts.filter(p => p.kind !== 'meta').map(p => p.text).join(''), error }) }));
    });
  }

  const api = { PRELUDE, OFFSET, describe, start, run };
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  else root.JSRun = api;
})(typeof window !== 'undefined' ? window : globalThis);
