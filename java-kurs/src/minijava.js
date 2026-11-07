/* Mini-Java – ein kleiner Java-Interpreter für den Java-Kurs (Lernversion).
 *
 * Unterstützt: Klassen, Objekte, Vererbung, static, Methoden (mit Überladung), Rekursion,
 * int/long/short/byte/double/float/char/boolean/String, Arrays, ArrayList, HashMap, StringBuilder,
 * Scanner, Random, Math, Integer/Double/Character, if/else, switch, while, do-while, for, for-each,
 * break/continue, try/catch/finally/throw, printf/String.format.
 *
 * Läuft als Generator: Eingaben (Scanner), Pausen (Thread.sleep) und Zwischenstopps werden
 * vom Aufrufer bedient (siehe runSync / startRun unten). Fehlermeldungen sind auf Deutsch.
 */
(function (global) {
  'use strict';

  // ------------------------------------------------------------------ Fehler & Signale
  class JavaError extends Error {
    constructor(kind, message, line, extra) { super(message); this.kind = kind; this.line = line; this.extra = extra || {}; }
  }
  class JavaThrow { constructor(val, line) { this.val = val; this.line = line; } } // geworfene Java-Exception
  class BreakSig { constructor(label) { this.label = label; } }
  class ContinueSig { constructor(label) { this.label = label; } }
  class ReturnSig { constructor(val) { this.val = val; } }
  class ExitSig { constructor(code) { this.code = code; } }

  const cerr = (msg, line) => { throw new JavaError('compile', msg, line); };

  // ------------------------------------------------------------------ Lexer
  const KEYWORDS = new Set(['abstract', 'boolean', 'break', 'byte', 'case', 'catch', 'char', 'class', 'continue', 'default', 'do', 'double', 'else', 'enum', 'extends', 'final', 'finally', 'float', 'for', 'if', 'implements', 'import', 'instanceof', 'int', 'interface', 'long', 'new', 'package', 'private', 'protected', 'public', 'return', 'short', 'static', 'super', 'switch', 'this', 'throw', 'throws', 'try', 'void', 'while']);
  const PRIMS = new Set(['int', 'long', 'short', 'byte', 'double', 'float', 'char', 'boolean']);
  const OPS = ['>>>=', '<<=', '>>=', '>>>', '...', '->', '::', '++', '--', '&&', '||', '==', '!=', '<=', '>=', '+=', '-=', '*=', '/=', '%=', '&=', '|=', '^=', '<<', '>>', '(', ')', '{', '}', '[', ']', ';', ',', '.', '@', '=', '<', '>', '!', '~', '?', ':', '+', '-', '*', '/', '&', '|', '^', '%'];
  const ID_START = /[\p{L}_$]/u, ID_PART = /[\p{L}\p{N}_$]/u;

  function readEscape(src, i, line) { // src[i] === '\\'
    const c = src[i + 1];
    const map = { n: '\n', t: '\t', r: '\r', b: '\b', f: '\f', 0: '\0', s: ' ', '\\': '\\', "'": "'", '"': '"' };
    if (c === 'u') { let j = i + 1; while (src[j] === 'u') j++; const hex = src.substr(j, 4); if (!/^[0-9a-fA-F]{4}$/.test(hex)) cerr('Ungültige Unicode-Escape-Sequenz \\u' + hex, line); return [String.fromCharCode(parseInt(hex, 16)), j + 4 - i]; }
    if (c in map) return [map[c], 2];
    cerr(`Ungültige Escape-Sequenz '\\${c}' – erlaubt sind z. B. \\n, \\t, \\", \\\\`, line);
  }

  function lex(src) {
    const toks = []; let i = 0, line = 1, col = 1; const n = src.length;
    const push = (type, value, l, c, extra) => toks.push(Object.assign({ type, value, line: l, col: c }, extra || {}));
    while (i < n) {
      const ch = src[i];
      if (ch === '\n') { i++; line++; col = 1; continue; }
      if (ch === ' ' || ch === '\t' || ch === '\r' || ch === '\f' || ch === ' ') { i++; col++; continue; }
      if (ch === '/' && src[i + 1] === '/') { while (i < n && src[i] !== '\n') i++; continue; }
      if (ch === '/' && src[i + 1] === '*') {
        const l0 = line; i += 2;
        while (i < n && !(src[i] === '*' && src[i + 1] === '/')) { if (src[i] === '\n') { line++; col = 1; } i++; }
        if (i >= n) cerr('Ein Kommentar /* … wird nie mit */ geschlossen', l0);
        i += 2; continue;
      }
      const l = line, c = col;
      if (ID_START.test(ch)) {
        let j = i; while (j < n && ID_PART.test(src[j])) j++;
        const w = src.slice(i, j); col += j - i; i = j;
        if (w === 'true' || w === 'false') push('bool', w === 'true', l, c);
        else if (w === 'null') push('null', null, l, c);
        else push(KEYWORDS.has(w) ? 'kw' : 'id', w, l, c);
        continue;
      }
      if (/[0-9]/.test(ch) || (ch === '.' && /[0-9]/.test(src[i + 1] || ''))) {
        let j = i, isFloat = false, t = 'int', v;
        if (ch === '0' && /[xXbB]/.test(src[i + 1] || '')) {
          const hex = /[xX]/.test(src[i + 1]); j += 2;
          while (j < n && (hex ? /[0-9a-fA-F_]/ : /[01_]/).test(src[j])) j++;
          v = parseInt(src.slice(i + 2, j).replace(/_/g, ''), hex ? 16 : 2);
          if (/[lL]/.test(src[j] || '')) { j++; t = 'long'; } else if (v > 0xffffffff) cerr('Die Zahl ist zu groß für int', l); else v = v | 0;
        } else {
          while (j < n && /[0-9_]/.test(src[j])) j++;
          if (src[j] === '.' && /[0-9]/.test(src[j + 1] || '')) { isFloat = true; j++; while (j < n && /[0-9_]/.test(src[j])) j++; }
          else if (src[j] === '.' && !ID_START.test(src[j + 1] || '') && src[j + 1] !== '.') { isFloat = true; j++; }
          if (/[eE]/.test(src[j] || '')) { isFloat = true; j++; if (/[+-]/.test(src[j])) j++; while (j < n && /[0-9]/.test(src[j])) j++; }
          v = Number(src.slice(i, j).replace(/_/g, ''));
          t = isFloat ? 'double' : 'int';
          if (/[lL]/.test(src[j] || '')) { t = 'long'; j++; } else if (/[fF]/.test(src[j] || '')) { t = 'float'; j++; v = Math.fround(v); } else if (/[dD]/.test(src[j] || '')) { t = 'double'; j++; }
          if (t === 'int' && v > 2147483648) cerr(`Die Zahl ${src.slice(i, j)} ist zu groß für int (höchstens 2147483647). Für große Zahlen: long, z. B. ${src.slice(i, j)}L`, l);
        }
        push('num', v, l, c, { numType: t, raw: src.slice(i, j) }); col += j - i; i = j; continue;
      }
      if (ch === '"') {
        if (src.startsWith('"""', i)) cerr('Textblöcke (""") werden in dieser Lern-Version nicht unterstützt', l);
        let j = i + 1, s = '';
        while (j < n && src[j] !== '"') {
          if (src[j] === '\n') cerr('Der Text (String) wird nicht mit " geschlossen', l);
          if (src[j] === '\\') { const [e, len] = readEscape(src, j, l); s += e; j += len; } else s += src[j++];
        }
        if (j >= n) cerr('Der Text (String) wird nicht mit " geschlossen', l);
        push('str', s, l, c); col += j + 1 - i; i = j + 1; continue;
      }
      if (ch === "'") {
        let j = i + 1, s;
        if (src[j] === '\\') { const [e, len] = readEscape(src, j, l); s = e; j += len; } else { s = src[j]; j++; }
        if (src[j] !== "'" || s === undefined || s === "'" && src[i + 1] !== '\\') cerr("Ein char muss genau ein Zeichen in einfachen Anführungszeichen sein, z. B. 'a' – für Text nimm \"…\"", l);
        push('char', s.charCodeAt(0), l, c); col += j + 1 - i; i = j + 1; continue;
      }
      const op = OPS.find(o => src.startsWith(o, i));
      if (!op) cerr(`Unerwartetes Zeichen '${ch}'`, l);
      push('op', op, l, c); i += op.length; col += op.length;
    }
    toks.push({ type: 'eof', value: '<Ende>', line, col });
    return toks;
  }

  // ------------------------------------------------------------------ Parser
  const BIN_PREC = { '||': 1, '&&': 2, '|': 3, '^': 4, '&': 5, '==': 6, '!=': 6, '<': 7, '>': 7, '<=': 7, '>=': 7, 'instanceof': 7, '<<': 8, '>>': 8, '>>>': 8, '+': 9, '-': 9, '*': 10, '/': 10, '%': 10 };
  const ASSIGN_OPS = new Set(['=', '+=', '-=', '*=', '/=', '%=', '&=', '|=', '^=', '<<=', '>>=', '>>>=']);
  const MODS = ['public', 'private', 'protected', 'static', 'final', 'abstract'];

  class Parser {
    constructor(toks) { this.toks = toks; this.p = 0; }
    peek(k = 0) { return this.toks[Math.min(this.p + k, this.toks.length - 1)]; }
    is(v, k = 0) { const t = this.peek(k); return (t.type === 'op' || t.type === 'kw') && t.value === v; }
    isId(k = 0) { return this.peek(k).type === 'id'; }
    next() { return this.toks[Math.min(this.p++, this.toks.length - 1)]; }
    prevLine() { const t = this.toks[this.p - 1]; return t ? t.line : this.peek().line; }
    err(msg, tok) { tok = tok || this.peek(); throw new JavaError('compile', msg, tok.line, { col: tok.col }); }
    expect(v, msg) {
      if (this.is(v)) return this.next();
      if (v === ';' || v === ')') throw new JavaError('compile', msg || (v === ';' ? "';' erwartet – am Ende der Anweisung fehlt ein Strichpunkt" : "')' erwartet – eine Klammer wird nicht geschlossen"), this.prevLine());
      const t = this.peek();
      this.err(msg || `'${v}' erwartet, gefunden: '${t.value}'`);
    }
    save() { return { p: this.p, toks: this.toks.slice() }; }
    restore(s) { this.p = s.p; this.toks = s.toks; }

    parseUnit() {
      const imports = [];
      while (this.is('package') || this.is('import')) {
        const kw = this.next().value; let name = '';
        if (kw === 'import' && this.is('static')) { this.next(); name = 'static '; }
        while (!this.is(';') && this.peek().type !== 'eof') name += this.next().value;
        this.expect(';');
        if (kw === 'import') imports.push(name);
      }
      const classes = [];
      while (this.peek().type !== 'eof') {
        const mods = this.parseModifiers();
        if (this.is('class')) classes.push(this.parseClass(mods));
        else if (this.is('interface') || this.is('enum')) this.err(`'${this.peek().value}' wird in dieser Lern-Version noch nicht unterstützt`);
        else if (this.is('import')) this.err('import muss ganz oben stehen, vor der Klasse');
        else this.err("'class' erwartet – jedes Java-Programm steht in einer Klasse, z. B. public class Main { … }");
      }
      if (!classes.length) this.err('Keine Klasse gefunden – ein Java-Programm braucht z. B. public class Main { … }');
      return { imports, classes };
    }
    parseModifiers() {
      const m = new Set();
      while (true) {
        if (this.is('@')) { this.next(); this.next(); if (this.is('(')) { let d = 0; do { if (this.is('(')) d++; if (this.is(')')) d--; this.next(); } while (d > 0); } continue; }
        const t = this.peek();
        if (t.type === 'kw' && MODS.includes(t.value)) { m.add(t.value); this.next(); continue; }
        break;
      }
      return m;
    }
    parseClass(mods) {
      const kw = this.next(); const nameTok = this.next();
      if (nameTok.type !== 'id') this.err('Klassenname erwartet', nameTok);
      let sup = null;
      if (this.is('extends')) { this.next(); sup = this.parseType().name; }
      if (this.is('implements')) { this.next(); this.parseType(); while (this.is(',')) { this.next(); this.parseType(); } }
      this.expect('{', `'{' erwartet nach dem Klassennamen ${nameTok.value}`);
      const cls = { name: nameTok.value, sup, mods, fields: [], methods: [], ctors: [], inits: [], line: kw.line };
      while (!this.is('}')) {
        if (this.peek().type === 'eof') this.err(`'}' fehlt am Ende der Klasse ${cls.name}`);
        if (this.is(';')) { this.next(); continue; }
        const mm = this.parseModifiers();
        if (this.is('class') || this.is('interface') || this.is('enum')) this.err('Klassen in Klassen werden noch nicht unterstützt – schreib die Klasse außerhalb');
        if (this.is('{')) { const b = this.parseBlock(); cls.inits.push({ static: mm.has('static'), block: b }); continue; }
        if (this.is('<')) { let d = 0; do { if (this.is('<')) d++; if (this.peek().value[0] === '>') d -= this.peek().value.length; this.next(); } while (d > 0); }
        if (this.isId() && this.peek().value === cls.name && this.is('(', 1)) {
          const t = this.next(); const params = this.parseParams(); this.skipThrows();
          cls.ctors.push({ params, body: this.parseBlock(), line: t.line, mods: mm, cls: cls.name });
          continue;
        }
        if (this.isId() && this.is('(', 1)) this.err(`Rückgabetyp fehlt bei der Methode ${this.peek().value} – z. B. void, int oder String (oder ist der Name falsch geschrieben? Ein Konstruktor muss genau wie die Klasse heißen: ${cls.name})`);
        let type;
        if (this.is('void')) { this.next(); type = { name: 'void', dims: 0 }; } else type = this.parseType();
        const nameT = this.next();
        if (nameT.type !== 'id') this.err('Name erwartet', nameT);
        if (this.is('(')) {
          const params = this.parseParams(); this.skipThrows();
          let body = null;
          if (this.is(';')) { this.next(); if (!mm.has('abstract')) this.err('Methode ohne Rumpf { … }', nameT); } else body = this.parseBlock();
          cls.methods.push({ name: nameT.value, ret: type, params, body, static: mm.has('static'), mods: mm, line: nameT.line, cls: cls.name });
        } else {
          let nt = nameT;
          while (true) {
            let ty = type;
            while (this.is('[')) { this.next(); this.expect(']'); ty = Object.assign({}, ty, { dims: ty.dims + 1 }); }
            let init = null;
            if (this.is('=')) { this.next(); init = this.parseVarInit(ty); }
            cls.fields.push({ name: nt.value, type: ty, init, line: nt.line, static: mm.has('static'), final: mm.has('final'), mods: mm, cls: cls.name });
            if (this.is(',')) { this.next(); nt = this.next(); if (nt.type !== 'id') this.err('Variablenname erwartet', nt); continue; }
            break;
          }
          this.expect(';');
        }
      }
      this.next();
      return cls;
    }
    skipThrows() { if (this.is('throws')) { this.next(); this.parseType(); while (this.is(',')) { this.next(); this.parseType(); } } }
    parseType(noDims) {
      const t = this.next();
      if (!(t.type === 'id' || (t.type === 'kw' && PRIMS.has(t.value)))) this.err(`Datentyp erwartet, gefunden: '${t.value}'`, t);
      let name = t.value;
      while (this.is('.') && this.isId(1)) { this.next(); name += '.' + this.next().value; }
      const qualified = /^java\.(util|lang|io)\./.test(name);
      name = name.replace(/^java\.(util|lang|io)\./, '');
      let args = null;
      if (this.is('<')) {
        this.next(); args = [];
        if (!this.isGT()) { args.push(this.parseTypeArg()); while (this.is(',')) { this.next(); args.push(this.parseTypeArg()); } }
        this.expectGT();
      }
      let dims = 0;
      if (!noDims) while (this.is('[') && this.is(']', 1)) { this.next(); this.next(); dims++; }
      return { name, args, dims, line: t.line, qualified };
    }
    parseTypeArg() { if (this.is('?')) { this.next(); if (this.is('extends') || this.is('super')) { this.next(); return this.parseType(); } return { name: 'Object', dims: 0 }; } return this.parseType(); }
    isGT() { const t = this.peek(); return t.type === 'op' && t.value[0] === '>'; }
    expectGT() {
      const t = this.peek();
      if (t.type !== 'op' || t.value[0] !== '>') this.err("'>' erwartet");
      if (t.value === '>') this.next();
      else this.toks[this.p] = Object.assign({}, t, { value: t.value.slice(1), col: t.col + 1 });
    }
    parseParams() {
      this.expect('(');
      const ps = [];
      if (!this.is(')')) {
        while (true) {
          this.parseModifiers();
          let type = this.parseType(); let varargs = false;
          if (this.is('...')) { this.next(); varargs = true; type = Object.assign({}, type, { dims: type.dims + 1 }); }
          const nt = this.next();
          if (nt.type !== 'id') this.err('Parametername erwartet (z. B. int zahl)', nt);
          while (this.is('[')) { this.next(); this.expect(']'); type = Object.assign({}, type, { dims: type.dims + 1 }); }
          ps.push({ type, name: nt.value, varargs });
          if (this.is(',')) { this.next(); continue; }
          break;
        }
      }
      this.expect(')');
      return ps;
    }
    parseBlock() {
      const t = this.expect('{');
      const body = [];
      while (!this.is('}')) {
        if (this.peek().type === 'eof') throw new JavaError('compile', `'}' fehlt – zur '{' in Zeile ${t.line} gibt es keine schließende Klammer`, this.prevLine());
        body.push(this.parseStatement());
      }
      this.next();
      return { k: 'block', body, line: t.line };
    }
    tryLocalDecl() {
      const s = this.save();
      try {
        let fin = false;
        if (this.is('final')) { this.next(); fin = true; }
        const t = this.peek();
        if (t.type === 'id' && t.value === 'var' && this.isId(1)) { this.next(); return { type: { name: 'var', dims: 0 }, fin }; }
        if (!(t.type === 'id' || (t.type === 'kw' && PRIMS.has(t.value)))) { this.restore(s); return null; }
        const type = this.parseType();
        if (this.isId() && (this.is('=', 1) || this.is(';', 1) || this.is(',', 1) || this.is('[', 1) || this.is(':', 1) || this.is(')', 1))) return { type, fin };
        if (t.type === 'kw' && PRIMS.has(t.value) && !this.isId()) this.err(`Variablenname erwartet nach '${type.name}'`);
        this.restore(s); return null;
      } catch (e) {
        if (e instanceof JavaError && /Variablenname erwartet/.test(e.message)) throw e;
        this.restore(s); return null;
      }
    }
    parseDeclRest(type, fin, line) {
      const decls = [];
      while (true) {
        const nt = this.next();
        if (nt.type !== 'id') this.err('Variablenname erwartet', nt);
        let ty = type;
        while (this.is('[')) { this.next(); this.expect(']'); ty = Object.assign({}, ty, { dims: ty.dims + 1 }); }
        let init = null;
        if (this.is('=')) { this.next(); init = this.parseVarInit(ty); }
        decls.push({ name: nt.value, type: ty, init, line: nt.line });
        if (this.is(',')) { this.next(); continue; }
        break;
      }
      return { k: 'local', decls, fin, line };
    }
    parseVarInit(type) { return this.is('{') ? this.parseArrayInit(type) : this.parseExpr(); }
    parseArrayInit(type) {
      const t = this.expect('{'); const elems = [];
      const et = Object.assign({}, type, { dims: type.dims - 1 });
      while (!this.is('}')) {
        elems.push(this.is('{') ? this.parseArrayInit(et) : this.parseExpr());
        if (!this.is('}')) this.expect(',', "',' oder '}' erwartet in der Array-Liste");
      }
      this.next();
      return { k: 'arrinit', type, elems, line: t.line };
    }
    parseStatement() {
      const t = this.peek(), line = t.line;
      if (this.is('{')) return this.parseBlock();
      if (this.is(';')) { this.next(); return { k: 'empty', line }; }
      if (this.is('if')) {
        this.next(); this.expect('(', "'(' erwartet nach if – die Bedingung steht in Klammern: if (x > 5)");
        const cond = this.parseExpr(); this.expect(')');
        if (this.is(';')) { /* if (…); – gültig, aber fast immer ein Fehler */ }
        const then = this.parseStatement(); let els = null;
        if (this.is('else')) { this.next(); els = this.parseStatement(); }
        return { k: 'if', cond, then, els, line };
      }
      if (this.is('while')) { this.next(); this.expect('('); const cond = this.parseExpr(); this.expect(')'); return { k: 'while', cond, body: this.parseStatement(), line }; }
      if (this.is('do')) { this.next(); const body = this.parseStatement(); this.expect('while', "'while' erwartet nach dem do-Block"); this.expect('('); const cond = this.parseExpr(); this.expect(')'); this.expect(';'); return { k: 'do', body, cond, line }; }
      if (this.is('for')) {
        this.next(); this.expect('(');
        const s = this.save(); const d = this.tryLocalDecl();
        if (d && this.isId() && this.is(':', 1)) {
          const name = this.next().value; this.next();
          const iter = this.parseExpr(); this.expect(')');
          return { k: 'foreach', type: d.type, name, iter, body: this.parseStatement(), line };
        }
        this.restore(s);
        let init = [];
        if (!this.is(';')) {
          const d2 = this.tryLocalDecl();
          if (d2) init = [this.parseDeclRest(d2.type, d2.fin, line)];
          else { init.push({ k: 'expr', e: this.parseExpr(), line }); while (this.is(',')) { this.next(); init.push({ k: 'expr', e: this.parseExpr(), line }); } }
        }
        this.expect(';', "';' erwartet in der for-Klammer: for (start; bedingung; schritt)");
        const cond = this.is(';') ? null : this.parseExpr();
        this.expect(';', "';' erwartet in der for-Klammer: for (start; bedingung; schritt)");
        const upd = [];
        if (!this.is(')')) { upd.push(this.parseExpr()); while (this.is(',')) { this.next(); upd.push(this.parseExpr()); } }
        this.expect(')');
        return { k: 'for', init, cond, upd, body: this.parseStatement(), line };
      }
      if (this.is('return')) { this.next(); const e = this.is(';') ? null : this.parseExpr(); this.expect(';'); return { k: 'return', e, line }; }
      if (this.is('break')) { this.next(); let label = null; if (this.isId()) label = this.next().value; this.expect(';'); return { k: 'break', label, line }; }
      if (this.is('continue')) { this.next(); let label = null; if (this.isId()) label = this.next().value; this.expect(';'); return { k: 'continue', label, line }; }
      if (this.is('switch')) return this.parseSwitch();
      if (this.is('throw')) { this.next(); const e = this.parseExpr(); this.expect(';'); return { k: 'throw', e, line }; }
      if (this.is('try')) {
        this.next(); const resources = [];
        if (this.is('(')) {
          this.next();
          while (!this.is(')')) { const d = this.tryLocalDecl(); if (!d) this.err('Ressource erwartet'); resources.push(this.parseDeclRest(d.type, d.fin, line)); if (this.is(';')) this.next(); }
          this.next();
        }
        const block = this.parseBlock(); const catches = [];
        while (this.is('catch')) {
          this.next(); this.expect('('); this.parseModifiers();
          const types = [this.parseType().name]; while (this.is('|')) { this.next(); types.push(this.parseType().name); }
          const nt = this.next(); this.expect(')');
          catches.push({ types, name: nt.value, body: this.parseBlock() });
        }
        let fin = null;
        if (this.is('finally')) { this.next(); fin = this.parseBlock(); }
        if (!catches.length && !fin && !resources.length) this.err("'catch' oder 'finally' erwartet nach dem try-Block");
        return { k: 'try', resources, block, catches, fin, line };
      }
      if (this.is('else')) this.err("'else' ohne passendes 'if' – prüfe die Klammern { } und Strichpunkte davor");
      if (this.is('case') || this.is('default')) this.err(`'${t.value}' darf nur in einem switch stehen`);
      if (this.isId() && this.is(':', 1)) { const label = this.next().value; this.next(); const st = this.parseStatement(); st.label = label; return st; }
      const d = this.tryLocalDecl();
      if (d) { const st = this.parseDeclRest(d.type, d.fin, line); this.expect(';'); return st; }
      const e = this.parseExpr();
      if (!['assign', 'compound', 'call', 'postinc', 'preinc', 'new', 'ctorcall'].includes(e.k)) {
        throw new JavaError('compile', 'Das ist keine gültige Anweisung – fehlt ein = oder ein Methodenaufruf?', e.line || line);
      }
      this.expect(';');
      return { k: 'expr', e, line };
    }
    parseSwitch() {
      const t = this.next(); this.expect('(');
      const sel = this.parseExpr(); this.expect(')'); this.expect('{');
      const cases = [];
      while (!this.is('}')) {
        if (this.peek().type === 'eof') this.err("'}' fehlt am Ende des switch");
        let labels;
        if (this.is('default')) { this.next(); labels = null; }
        else { this.expect('case', "'case' oder 'default' erwartet"); labels = [this.parseTernary()]; while (this.is(',')) { this.next(); labels.push(this.parseTernary()); } }
        if (this.is('->')) {
          this.next(); let body;
          if (this.is('{')) body = [this.parseBlock()];
          else if (this.is('throw')) body = [this.parseStatement()];
          else { const l = this.peek().line; const e = this.parseExpr(); this.expect(';'); body = [{ k: 'expr', e, line: l, arrowValue: true }]; }
          cases.push({ labels, body, arrow: true });
        } else {
          this.expect(':', "':' erwartet nach dem case-Wert, z. B. case 1:");
          const body = [];
          while (!this.is('case') && !this.is('default') && !this.is('}')) body.push(this.parseStatement());
          cases.push({ labels, body, arrow: false });
        }
      }
      this.next();
      return { k: 'switch', sel, cases, line: t.line };
    }
    parseExpr() { return this.parseAssign(); }
    parseAssign() {
      const left = this.parseTernary();
      const t = this.peek();
      if (t.type === 'op' && ASSIGN_OPS.has(t.value)) {
        this.next();
        let tg = left; while (tg.k === 'paren') tg = tg.e;
        if (!['name', 'field', 'index'].includes(tg.k)) this.err('Links vom = muss eine Variable stehen', t);
        const right = this.parseAssign();
        return t.value === '=' ? { k: 'assign', target: tg, e: right, line: t.line } : { k: 'compound', op: t.value.slice(0, -1), target: tg, e: right, line: t.line };
      }
      return left;
    }
    parseTernary() {
      const c = this.parseBin(0);
      if (this.is('?')) { const t = this.next(); const a = this.parseTernary(); this.expect(':', "':' erwartet im Bedingungsoperator  bedingung ? a : b"); const b = this.parseTernary(); return { k: 'cond', c, a, b, line: t.line }; }
      return c;
    }
    parseBin(minPrec) {
      let left = this.parseUnary();
      while (true) {
        const t = this.peek();
        const op = (t.type === 'op' || (t.type === 'kw' && t.value === 'instanceof')) ? t.value : null;
        const prec = op != null ? BIN_PREC[op] : undefined;
        if (prec === undefined || prec <= minPrec) break;
        this.next();
        if (op === 'instanceof') { const type = this.parseType(); let bind = null; if (this.isId()) bind = this.next().value; left = { k: 'instanceof', e: left, type, bind, line: t.line }; continue; }
        const right = this.parseBin(prec);
        left = { k: 'bin', op, l: left, r: right, line: t.line };
      }
      return left;
    }
    parseUnary() {
      const t = this.peek();
      if (t.type === 'op') {
        if (t.value === '++' || t.value === '--') { this.next(); const e = this.parseUnary(); return { k: 'preinc', op: t.value, target: e, line: t.line }; }
        if (t.value === '-' || t.value === '+' || t.value === '!' || t.value === '~') {
          this.next();
          const nt = this.peek();
          if (t.value === '-' && nt.type === 'num') { this.next(); const lit = { k: 'lit', t: nt.numType, v: -nt.value, line: nt.line }; return this.parsePostfixOn(lit); }
          return { k: 'unary', op: t.value, e: this.parseUnary(), line: t.line };
        }
        if (t.value === '(') { const c = this.tryCast(); if (c) return c; }
      }
      return this.parsePostfix();
    }
    tryCast() {
      const t = this.peek(1);
      if (t.type === 'kw' && PRIMS.has(t.value)) { this.next(); const type = this.parseType(); this.expect(')'); return { k: 'cast', type, e: this.parseUnary(), line: t.line }; }
      if (t.type === 'id' && /^[A-Z]/.test(t.value)) {
        const s = this.save();
        try {
          this.next(); const type = this.parseType();
          if (this.is(')')) {
            const nt = this.peek(1);
            if (['id', 'num', 'str', 'char', 'bool'].includes(nt.type) || (nt.type === 'op' && nt.value === '(') || (nt.type === 'kw' && (nt.value === 'this' || nt.value === 'new'))) {
              this.next(); return { k: 'cast', type, e: this.parseUnary(), line: t.line };
            }
          }
        } catch (e) { /* kein Cast */ }
        this.restore(s);
      }
      return null;
    }
    parsePostfix() { return this.parsePostfixOn(this.parsePrimary()); }
    parsePostfixOn(e) {
      while (true) {
        const t = this.peek();
        if (this.is('.')) {
          this.next(); const nt = this.next();
          if (nt.type !== 'id' && !(nt.type === 'kw' && nt.value === 'class')) this.err('Name nach dem Punkt erwartet', nt);
          if (this.is('(')) e = { k: 'call', obj: e, name: nt.value, args: this.parseArgs(), line: nt.line };
          else e = { k: 'field', obj: e, name: nt.value, line: nt.line };
          continue;
        }
        if (this.is('[')) { this.next(); const idx = this.parseExpr(); this.expect(']'); e = { k: 'index', arr: e, idx, line: t.line }; continue; }
        if (this.is('++') || this.is('--')) { this.next(); e = { k: 'postinc', op: t.value, target: e, line: t.line }; continue; }
        if (this.is('::')) this.err('Methodenreferenzen (::) werden noch nicht unterstützt');
        break;
      }
      return e;
    }
    parseArgs() {
      this.expect('('); const args = [];
      if (!this.is(')')) { args.push(this.parseExpr()); while (this.is(',')) { this.next(); args.push(this.parseExpr()); } }
      this.expect(')');
      return args;
    }
    parsePrimary() {
      const t = this.next();
      switch (t.type) {
        case 'num': return { k: 'lit', t: t.numType, v: t.value, line: t.line };
        case 'str': return { k: 'lit', t: 'String', v: t.value, line: t.line };
        case 'char': return { k: 'lit', t: 'char', v: t.value, line: t.line };
        case 'bool': return { k: 'lit', t: 'boolean', v: t.value, line: t.line };
        case 'null': return { k: 'lit', t: 'null', v: null, line: t.line };
        case 'id':
          if (this.is('(')) return { k: 'call', obj: null, name: t.value, args: this.parseArgs(), line: t.line };
          if (this.is('->')) this.err('Lambdas (->) werden in dieser Lern-Version noch nicht unterstützt');
          return { k: 'name', name: t.value, line: t.line };
        case 'kw':
          if (t.value === 'this') { if (this.is('(')) return { k: 'ctorcall', which: 'this', args: this.parseArgs(), line: t.line }; return { k: 'this', line: t.line }; }
          if (t.value === 'super') {
            if (this.is('(')) return { k: 'ctorcall', which: 'super', args: this.parseArgs(), line: t.line };
            this.expect('.'); const nt = this.next();
            if (this.is('(')) return { k: 'call', obj: { k: 'super', line: t.line }, name: nt.value, args: this.parseArgs(), line: t.line };
            return { k: 'field', obj: { k: 'this', line: t.line }, name: nt.value, line: t.line };
          }
          if (t.value === 'new') return this.parseNew(t);
          if (t.value === 'switch') this.err('switch als Ausdruck wird noch nicht unterstützt – nimm die Anweisungs-Form', t);
          this.err(`Unerwartetes Schlüsselwort '${t.value}'`, t);
          break;
        case 'op':
          if (t.value === '(') { const e = this.parseExpr(); this.expect(')'); return { k: 'paren', e, line: t.line }; }
          this.err(`Unerwartetes Zeichen '${t.value}'`, t);
          break;
        case 'eof': this.err('Unerwartetes Ende des Programms – fehlt eine } oder ein ;?', t); break;
      }
      this.err(`Unerwartet: '${t.value}'`, t);
    }
    parseNew(t) {
      const type = this.parseType(true);
      if (this.is('[')) {
        const dimsExpr = []; let dims = 0;
        while (this.is('[')) {
          this.next();
          if (this.is(']')) { this.next(); dims++; continue; }
          if (dimsExpr.length < dims) this.err('Array-Größen müssen von links nach rechts angegeben werden');
          dimsExpr.push(this.parseExpr()); this.expect(']'); dims++;
        }
        const full = { name: type.name, args: type.args, dims };
        if (this.is('{')) { if (dimsExpr.length) this.err('Bei einer Werte-Liste { … } keine Größe in [ ] angeben'); return this.parseArrayInit(full); }
        if (!dimsExpr.length) this.err('Array-Größe fehlt, z. B. new int[5]');
        return { k: 'newarr', type: full, dimsExpr, line: t.line };
      }
      if (!this.is('(')) this.err(`'(' erwartet nach new ${type.name} – z. B. new ${type.name}()`);
      const args = this.parseArgs();
      if (this.is('{')) this.err('Anonyme Klassen werden in dieser Lern-Version nicht unterstützt');
      return { k: 'new', type, args, line: t.line };
    }
  }

  // ------------------------------------------------------------------ Werte & Hilfsfunktionen
  const NUM = new Set(['byte', 'short', 'int', 'long', 'float', 'double', 'char']);
  const INTEGRAL = new Set(['byte', 'short', 'int', 'long', 'char']);
  const WIDEN = { byte: ['short', 'int', 'long', 'float', 'double'], short: ['int', 'long', 'float', 'double'], char: ['int', 'long', 'float', 'double'], int: ['long', 'float', 'double'], long: ['float', 'double'], float: ['double'] };
  const BOX = { Integer: 'int', Double: 'double', Character: 'char', Boolean: 'boolean', Long: 'long', Float: 'float', Short: 'short', Byte: 'byte' };
  const UNBOX_NAME = { int: 'Integer', double: 'Double', char: 'Character', boolean: 'Boolean', long: 'Long', float: 'Float', short: 'Short', byte: 'Byte' };
  const UTIL = new Set(['Scanner', 'Random', 'ArrayList', 'List', 'LinkedList', 'HashMap', 'Map', 'Arrays', 'Collections', 'InputMismatchException', 'NoSuchElementException', 'Collection', 'Iterator', 'HashSet', 'Set']);
  const EX_PARENT = {
    Throwable: null, Exception: 'Throwable', Error: 'Throwable', RuntimeException: 'Exception', StackOverflowError: 'Error',
    ArithmeticException: 'RuntimeException', IndexOutOfBoundsException: 'RuntimeException', ArrayIndexOutOfBoundsException: 'IndexOutOfBoundsException',
    StringIndexOutOfBoundsException: 'IndexOutOfBoundsException', NullPointerException: 'RuntimeException', IllegalArgumentException: 'RuntimeException',
    NumberFormatException: 'IllegalArgumentException', IllegalStateException: 'RuntimeException', NoSuchElementException: 'RuntimeException',
    InputMismatchException: 'NoSuchElementException', ClassCastException: 'RuntimeException', NegativeArraySizeException: 'RuntimeException',
    UnsupportedOperationException: 'RuntimeException', IllegalFormatConversionException: 'IllegalArgumentException', MissingFormatArgumentException: 'IllegalArgumentException',
    UnknownFormatConversionException: 'IllegalArgumentException', InterruptedException: 'Exception', IOException: 'Exception',
  };
  const EX_PKG = { InputMismatchException: 'java.util', NoSuchElementException: 'java.util', IllegalFormatConversionException: 'java.util', MissingFormatArgumentException: 'java.util', UnknownFormatConversionException: 'java.util', IOException: 'java.io' };
  const fqn = n => (EX_PKG[n] || 'java.lang') + '.' + n;

  const mk = (t, v) => ({ t, v });
  const I = v => ({ t: 'int', v });
  const B = v => ({ t: 'boolean', v });
  const D = v => ({ t: 'double', v });
  const NULL = { t: 'null', v: null };
  let SID = 0, OID = 0;
  const INTERN = new Map();
  const S = v => ({ t: 'String', v, sid: ++SID });
  const internStr = v => { let s = INTERN.get(v); if (!s) { s = { t: 'String', v, sid: ++SID }; INTERN.set(v, s); } return s; };
  const typeStr = ty => ty.name + '[]'.repeat(ty.dims || 0);
  const isRef = t => !(PRIMS.has(t));
  const disp = t => t === 'null' ? 'null' : t;
  const toInt = v => v | 0;
  const hashOf = o => { if (o.oid == null) o.oid = ++OID; return ((o.oid * 2654435761) >>> 0).toString(16).slice(0, 8); };

  function lev(a, b) {
    const m = a.length, n = b.length; const d = Array.from({ length: m + 1 }, (_, i) => [i]);
    for (let j = 1; j <= n; j++) d[0][j] = j;
    for (let i = 1; i <= m; i++) for (let j = 1; j <= n; j++) d[i][j] = Math.min(d[i - 1][j] + 1, d[i][j - 1] + 1, d[i - 1][j - 1] + (a[i - 1] === b[j - 1] ? 0 : 1));
    return d[m][n];
  }
  function suggest(name, cands) {
    let best = null, bd = 99;
    for (const c of cands) { if (c === name) continue; const d = c.toLowerCase() === name.toLowerCase() ? 0 : lev(name, c); if (d < bd) { bd = d; best = c; } }
    return best && bd <= Math.max(1, Math.floor(name.length / 3)) ? best : null;
  }

  // Java-Darstellung von Zahlen
  function jDouble(v) {
    if (Number.isNaN(v)) return 'NaN';
    if (v === Infinity) return 'Infinity'; if (v === -Infinity) return '-Infinity';
    if (v === 0) return Object.is(v, -0) ? '-0.0' : '0.0';
    const a = Math.abs(v);
    if (a >= 1e-3 && a < 1e7) { let s = String(v); if (s.includes('e')) s = v.toFixed(20).replace(/0+$/, ''); if (!s.includes('.')) s += '.0'; return s; }
    let [m, e] = v.toExponential().split('e');
    if (!m.includes('.')) m += '.0';
    return m + 'E' + (e[0] === '+' ? e.slice(1) : e);
  }
  function jFloat(v) {
    v = Math.fround(v);
    if (!Number.isFinite(v) || v === 0) return jDouble(v);
    let shortest = v;
    for (let p = 1; p <= 9; p++) { const s = Number(v.toPrecision(p)); if (Math.fround(s) === v) { shortest = s; break; } }
    return jDouble(shortest);
  }
  function numStr(val) {
    switch (val.t) {
      case 'double': return jDouble(val.v);
      case 'float': return jFloat(val.v);
      case 'char': return String.fromCharCode(val.v);
      default: return String(val.v);
    }
  }
  // Dezimalrundung HALF_UP auf einer Ziffernfolge (wie java.util.Formatter)
  function fixedHalfUp(v, prec) {
    if (!Number.isFinite(v)) return Number.isNaN(v) ? 'NaN' : (v > 0 ? 'Infinity' : '-Infinity');
    const neg = v < 0 || Object.is(v, -0); let s = Math.abs(v).toPrecision(17);
    // kürzeste Darstellung bevorzugen (wie Double.toString)
    const sh = String(Math.abs(v)); if (Number(sh) === Math.abs(v)) s = sh;
    let [mant, exp] = s.split('e'); exp = exp ? Number(exp) : 0;
    let [ip, fp = ''] = mant.split('.');
    let digits = ip + fp, point = ip.length + exp;
    if (point < 0) { digits = '0'.repeat(-point) + digits; point = 0; }
    while (digits.length < point + prec + 1) digits += '0';
    const keep = point + prec;
    let arr = digits.slice(0, keep).split('').map(Number);
    if (Number(digits[keep] || 0) >= 5) {
      let i = arr.length - 1;
      while (i >= 0) { if (arr[i] === 9) { arr[i] = 0; i--; } else { arr[i]++; break; } }
      if (i < 0) { arr.unshift(1); point++; }
    }
    let intPart = arr.slice(0, point).join('').replace(/^0+(?=\d)/, '') || '0';
    const frac = arr.slice(point).join('');
    let out = prec > 0 ? intPart + '.' + frac : intPart;
    if (neg && /[1-9]/.test(out)) out = '-' + out;
    return out;
  }
  function groupThousands(s) { const [i, f] = s.split('.'); const neg = i[0] === '-'; const d = neg ? i.slice(1) : i; const g = d.replace(/\B(?=(\d{3})+(?!\d))/g, ','); return (neg ? '-' : '') + g + (f !== undefined ? '.' + f : ''); }
  function sciJava(v, prec, upper) {
    let s = Math.abs(v).toExponential(prec); let [m, e] = s.split('e'); const sign = e[0] === '-' ? '-' : '+'; let digits = e.replace(/^[+-]/, ''); if (digits.length < 2) digits = '0' + digits;
    return (v < 0 ? '-' : '') + m + (upper ? 'E' : 'e') + sign + digits;
  }

  // Java-Zufallsgenerator (exakt wie java.util.Random)
  class JRandom {
    constructor(seed) { if (seed == null) seed = Math.floor(Math.random() * 2 ** 48); this.seed = (BigInt(Math.trunc(seed)) ^ 0x5DEECE66Dn) & ((1n << 48n) - 1n); }
    next(bits) { this.seed = (this.seed * 0x5DEECE66Dn + 0xBn) & ((1n << 48n) - 1n); let r = Number(this.seed >> BigInt(48 - bits)); if (bits === 32 && r >= 2 ** 31) r -= 2 ** 32; return r; }
    nextInt(bound) {
      if (bound === undefined) return this.next(32);
      if ((bound & -bound) === bound) return Number((BigInt(bound) * BigInt(this.next(31))) >> 31n);
      let bits, val;
      do { bits = this.next(31); val = bits % bound; } while (((bits - val + (bound - 1)) | 0) < 0);
      return val;
    }
    nextDouble() { return (this.next(26) * 2 ** 27 + this.next(27)) * 2 ** -53; }
    nextBoolean() { return this.next(1) !== 0; }
  }

  // ------------------------------------------------------------------ Programm (geparst)
  function compile(src) {
    SID = 0; OID = 0; INTERN.clear();
    const unit = new Parser(lex(src)).parseUnit();
    const classes = new Map();
    for (const c of unit.classes) {
      if (classes.has(c.name)) cerr(`Die Klasse ${c.name} gibt es zweimal`, c.line);
      if (BOX[c.name] || ['String', 'Math', 'System', 'Object'].includes(c.name)) cerr(`Eine eigene Klasse darf nicht ${c.name} heißen – der Name ist in Java schon vergeben`, c.line);
      classes.set(c.name, c);
    }
    for (const c of classes.values()) {
      if (c.sup && !classes.has(c.sup) && !EX_PARENT.hasOwnProperty(c.sup) && c.sup !== 'Object') cerr(`Die Oberklasse ${c.sup} gibt es nicht`, c.line);
      const seen = new Set();
      for (const f of c.fields) { if (seen.has(f.name)) cerr(`Das Attribut ${f.name} gibt es in ${c.name} zweimal`, f.line); seen.add(f.name); }
      const sigs = new Set();
      for (const m of c.methods) { const sig = m.name + '(' + m.params.map(p => typeStr(p.type)).join(',') + ')'; if (sigs.has(sig)) cerr(`Die Methode ${sig} gibt es in ${c.name} zweimal`, m.line); sigs.add(sig); }
    }
    const imports = unit.imports;
    let mainCls = null;
    for (const c of unit.classes) { const m = c.methods.find(m => m.name === 'main'); if (m) { if (!mainCls || c.mods.has('public')) mainCls = c; } }
    if (!mainCls) throw new JavaError('compile', 'Keine main-Methode gefunden. Jedes Programm startet bei:  public static void main(String[] args) { … }', unit.classes[0].line);
    const main = mainCls.methods.find(m => m.name === 'main');
    if (!main.static) cerr('Die main-Methode muss static sein:  public static void main(String[] args)', main.line);
    if (main.params.length !== 1 || typeStr(main.params[0].type) !== 'String[]') cerr('Die main-Methode braucht genau den Parameter String[] args', main.line);
    if (main.ret.name !== 'void') cerr('Die main-Methode muss void zurückgeben', main.line);
    return { classes, imports, mainCls, main };
  }

  // ------------------------------------------------------------------ Laufzeit
  class Scope {
    constructor(parent) { this.parent = parent; this.vars = new Map(); }
    find(name) { let s = this; while (s) { const v = s.vars.get(name); if (v) return v; s = s.parent; } return null; }
    names() { const out = []; let s = this; while (s) { out.push(...s.vars.keys()); s = s.parent; } return out; }
  }

  class Runtime {
    constructor(prog, opts) {
      this.prog = prog; this.classes = prog.classes; this.opts = opts || {};
      this.steps = 0; this.depth = 0; this.statics = new Map(); this.out = ''; this.inBuf = ''; this.inputEOF = false;
      this.maxSteps = this.opts.maxSteps || 20000000;
      this.imports = prog.imports;
    }
    hasImport(name) {
      return this.imports.some(im => im === 'java.util.*' || im === 'java.util.' + name || im === 'java.io.*' && name === 'IOException' || im === 'java.io.' + name);
    }
    requireImport(name, line) {
      if (UTIL.has(name) && !this.classes.has(name) && !this.hasImport(name)) cerr(`Die Klasse ${name} wurde nicht gefunden – fehlt ganz oben  import java.util.${name};  ?`, line);
    }
    tick() { if (++this.steps > this.maxSteps) throw new JavaError('limit', 'Das Programm wurde abgebrochen: zu viele Schritte. Gibt es eine Endlosschleife?', this.curLine); }

    // ---- Typen
    isSubclass(a, b) {
      if (a === b) return true;
      let c = a;
      while (c) {
        if (c === b) return true;
        const uc = this.classes.get(c);
        if (uc) { c = uc.sup || (uc.name !== 'Object' ? 'Object' : null); continue; }
        if (EX_PARENT.hasOwnProperty(c)) { c = EX_PARENT[c] || 'Object'; continue; }
        return b === 'Object';
      }
      return false;
    }
    defaultVal(ty) {
      const t = typeStr(ty);
      if (t === 'boolean') return B(false);
      if (t === 'double' || t === 'float') return mk(t, 0);
      if (NUM.has(t)) return mk(t, 0);
      return NULL;
    }
    checkType(ty, line) {
      const n = ty.name;
      if (PRIMS.has(n) || n === 'void' || n === 'var' || n === 'String' || n === 'Object' || BOX[n] || this.classes.has(n) || EX_PARENT.hasOwnProperty(n)) return;
      if (UTIL.has(n) || n === 'StringBuilder' || n === 'Math' || n === 'System') { if (!ty.qualified) this.requireImport(n, line); return; }
      const s = suggest(n, ['String', 'int', 'double', 'boolean', 'char', 'long', 'Scanner', 'ArrayList', 'Integer', 'Double', 'Random', ...this.classes.keys()]);
      cerr(`Den Datentyp ${n} gibt es nicht` + (s ? ` – meintest du ${s}?` : ''), line);
    }
    coerce(val, ty, line, constInit) {
      const tn = typeof ty === 'string' ? ty : typeStr(ty);
      if (tn === 'var') { if (val.t === 'null') cerr('var braucht einen Startwert, der nicht null ist', line); return val; }
      const vt = val.t;
      if (vt === tn) return val;
      const target = BOX[tn] || tn;
      if (vt === 'null') { if (PRIMS.has(tn)) cerr(`inkompatible Typen: null kann nicht in ${tn} gespeichert werden`, line); return val; }
      if (NUM.has(target)) {
        if (NUM.has(vt)) {
          if (vt === target) return val.t === tn ? val : mk(target, val.v);
          if (WIDEN[vt] && WIDEN[vt].includes(target)) return mk(target, target === 'float' ? Math.fround(val.v) : val.v);
          if (constInit && vt === 'int' && ((target === 'char' && val.v >= 0 && val.v <= 65535) || (target === 'byte' && val.v >= -128 && val.v <= 127) || (target === 'short' && val.v >= -32768 && val.v <= 32767))) return mk(target, val.v);
          cerr(`inkompatible Typen: ${vt} kann nicht ohne Weiteres in ${tn} umgewandelt werden (möglicher Verlust von Genauigkeit)` + (target === 'int' && (vt === 'double' || vt === 'float') ? ' – Tipp: (int) davor schreiben' : ''), line);
        }
        if (vt === 'String') cerr(`inkompatible Typen: String kann nicht in ${tn} umgewandelt werden` + (target === 'int' ? ' – Tipp: Integer.parseInt(text)' : target === 'double' ? ' – Tipp: Double.parseDouble(text)' : ''), line);
        cerr(`inkompatible Typen: ${disp(vt)} kann nicht in ${tn} umgewandelt werden`, line);
      }
      if (target === 'boolean') { if (vt === 'boolean') return val; cerr(`inkompatible Typen: ${disp(vt)} kann nicht in boolean umgewandelt werden`, line); }
      if (tn === 'Object') return val;
      if (tn === 'String') cerr(`inkompatible Typen: ${disp(vt)} kann nicht in String umgewandelt werden` + (NUM.has(vt) || vt === 'boolean' ? ' – Tipp: "" + wert  oder  String.valueOf(wert)' : ''), line);
      if (tn.endsWith('[]')) { if (vt === tn || (vt.endsWith('[]') && tn === 'Object[]')) return val; cerr(`inkompatible Typen: ${disp(vt)} kann nicht in ${tn} umgewandelt werden`, line); }
      if (['List', 'ArrayList', 'Collection', 'LinkedList', 'Iterable'].includes(tn) && vt === 'ArrayList') return val;
      if (['Map', 'HashMap'].includes(tn) && vt === 'HashMap') return val;
      if (['Set', 'HashSet', 'Collection', 'Iterable'].includes(tn) && vt === 'HashSet') return val;
      if (tn === 'CharSequence' && (vt === 'String' || vt === 'StringBuilder')) return val;
      if (this.isSubclass(vt, tn)) return val;
      if (BOX[tn] && PRIMS.has(vt)) cerr(`inkompatible Typen: ${vt} kann nicht in ${tn} umgewandelt werden`, line);
      cerr(`inkompatible Typen: ${disp(vt)} kann nicht in ${tn} umgewandelt werden`, line);
    }
    truthy(val, line, what) {
      if (val.t !== 'boolean') cerr(`inkompatible Typen: ${disp(val.t)} kann nicht in boolean umgewandelt werden` + (what === 'if' && NUM.has(val.t) ? ' – meintest du == statt = ?' : ' – eine Bedingung muss true oder false ergeben'), line);
      return val.v;
    }

    // ---- Ausnahmen
    exc(cls, msg, line) { return new JavaThrow({ t: cls, v: { ex: true, cls, msg: msg == null ? null : msg, oid: ++OID } }, line); }
    npe(what, line) { return this.exc('NullPointerException', what, line); }

    // ---- Strings
    *str(val, line) {
      switch (val.t) {
        case 'String': return val.v;
        case 'null': return 'null';
        case 'boolean': return val.v ? 'true' : 'false';
        case 'int': case 'long': case 'short': case 'byte': case 'double': case 'float': case 'char': return numStr(val);
        case 'ArrayList': case 'HashSet': { const parts = []; for (const e of val.v.a) parts.push(e === val ? '(this Collection)' : yield* this.str(e, line)); return '[' + parts.join(', ') + ']'; }
        case 'HashMap': { const parts = []; for (const [, [k, v]] of val.v.m) parts.push((yield* this.str(k, line)) + '=' + (yield* this.str(v, line))); return '{' + parts.join(', ') + '}'; }
        case 'StringBuilder': return val.v.s;
        case 'Scanner': return 'java.util.Scanner';
        case 'Random': return 'java.util.Random@' + hashOf(val.v);
      }
      if (val.t.endsWith('[]')) { const code = { 'int[]': '[I', 'double[]': '[D', 'char[]': '[C', 'boolean[]': '[Z', 'long[]': '[J', 'String[]': '[Ljava.lang.String;' }[val.t] || '[L' + val.t.slice(0, -2) + ';'; return code + '@' + hashOf(val.v); }
      if (val.v && val.v.ex && !val.v.cls.fields) { const m = val.v.msg; return fqn(val.v.cls) + (m != null ? ': ' + m : ''); }
      if (val.v && val.v.cls && val.v.cls.fields) {
        const m = this.findMethod(val.v.cls.name, 'toString', 0);
        if (m) { const r = yield* this.invoke(m, val, [], line); return yield* this.str(r, line); }
        if (val.v.exMsg !== undefined) { const m2 = val.v.exMsg; return val.v.cls.name + (m2 != null ? ': ' + m2 : ''); }
        return val.v.cls.name + '@' + hashOf(val.v);
      }
      return String(val.v);
    }

    // ---- Klassen & Methoden
    userClass(name) { return this.classes.get(name); }
    *classChain(name) { let c = this.classes.get(name); while (c) { yield c; c = c.sup ? this.classes.get(c.sup) : null; } }
    findMethods(clsName, name) { const out = []; for (const c of this.classChain(clsName)) for (const m of c.methods) if (m.name === name && !out.some(o => sameSig(o, m))) out.push(m); return out; }
    findMethod(clsName, name, argc) { return this.findMethods(clsName, name).find(m => m.params.length === argc) || null; }
    findField(clsName, name) { for (const c of this.classChain(clsName)) { const f = c.fields.find(f => f.name === name); if (f) return f; } return null; }
    scoreArgs(params, args) {
      let score = 0;
      const varargs = params.length && params[params.length - 1].varargs;
      if (!varargs && params.length !== args.length) return -1;
      if (varargs && args.length < params.length - 1) return -1;
      for (let i = 0; i < args.length; i++) {
        let pt;
        if (varargs && i >= params.length - 1) { if (args.length === params.length && args[i].t === typeStr(params[i].type)) { score += 3; continue; } const p = params[params.length - 1].type; pt = typeStr(Object.assign({}, p, { dims: p.dims - 1 })); }
        else pt = typeStr(params[i].type);
        const at = args[i].t, tgt = BOX[pt] || pt;
        if (at === pt) score += 4;
        else if (at === 'null' && !PRIMS.has(pt)) score += 2;
        else if (NUM.has(at) && NUM.has(tgt) && WIDEN[at] && WIDEN[at].includes(tgt)) score += 2 - (WIDEN[at].indexOf(tgt) * 0.1);
        else if (BOX[pt] === at) score += 1.5;
        else if (pt === 'Object') score += 1;
        else if (!PRIMS.has(at) && this.isSubclass(at, pt)) score += 3;
        else if (['List', 'Collection'].includes(pt) && at === 'ArrayList') score += 3;
        else if (pt === 'Map' && at === 'HashMap') score += 3;
        else return -1;
      }
      return score - (varargs ? 0.5 : 0);
    }
    pickMethod(cands, args, line, what) {
      let best = null, bs = -1;
      for (const m of cands) { const s = this.scoreArgs(m.params, args); if (s > bs) { bs = s; best = m; } }
      if (!best) {
        const sig = cands.map(m => `${what}(${m.params.map(p => typeStr(p.type)).join(', ')})`).join(' oder ');
        cerr(`${what} kann nicht mit (${args.map(a => disp(a.t)).join(', ')}) aufgerufen werden – erwartet wird ${sig}`, line);
      }
      return best;
    }
    *bindArgs(m, args, scope, line) {
      const ps = m.params;
      const varargs = ps.length && ps[ps.length - 1].varargs;
      for (let i = 0; i < ps.length; i++) {
        let v;
        if (varargs && i === ps.length - 1 && !(args.length === ps.length && args[i].t === typeStr(ps[i].type))) {
          const et = Object.assign({}, ps[i].type, { dims: ps[i].type.dims - 1 });
          v = { t: typeStr(ps[i].type), v: { et: typeStr(et), a: args.slice(i).map(a => this.coerce(a, et, line)), oid: ++OID } };
        } else v = this.coerce(args[i], ps[i].type, line);
        scope.vars.set(ps[i].name, { t: typeStr(ps[i].type), v, init: true, fin: false });
      }
    }
    *invoke(m, thisVal, args, line) {
      if (++this.depth > 2500) { this.depth = 0; throw this.exc('StackOverflowError', null, line); }
      const scope = new Scope(null);
      yield* this.bindArgs(m, args, scope, line);
      const frame = { cls: this.classes.get(m.cls), thisVal: m.static ? null : thisVal, isStatic: m.static, scope, method: m };
      try {
        yield* this.execBody(m.body.body, frame, scope);
        if (m.ret.name !== 'void') cerr(`In der Methode ${m.name} fehlt ein return – sie muss einen Wert vom Typ ${typeStr(m.ret)} zurückgeben`, m.body.line);
        return null;
      } catch (e) {
        if (e instanceof ReturnSig) {
          if (m.ret.name === 'void') { if (e.val) cerr(`Die Methode ${m.name} ist void und darf keinen Wert zurückgeben`, line); return null; }
          if (!e.val) cerr(`Die Methode ${m.name} muss einen Wert vom Typ ${typeStr(m.ret)} zurückgeben`, line);
          return this.coerce(e.val, m.ret, this.curLine);
        }
        throw e;
      } finally { this.depth--; }
    }
    *instantiate(clsName, args, line) {
      const cls = this.classes.get(clsName);
      if (cls.mods.has('abstract')) cerr(`Von der abstrakten Klasse ${clsName} kann man keine Objekte erzeugen`, line);
      const obj = { cls, f: new Map(), oid: ++OID };
      for (const c of this.classChain(clsName)) for (const fd of c.fields) if (!fd.static) obj.f.set(fd.name, this.defaultVal(fd.type));
      const val = { t: clsName, v: obj };
      yield* this.construct(cls, val, args, line);
      return val;
    }
    *construct(cls, val, args, line) {
      let ctor = null;
      if (cls.ctors.length) ctor = this.pickMethod(cls.ctors, args, line, cls.name);
      else if (args.length) cerr(`Die Klasse ${cls.name} hat keinen Konstruktor mit Parametern (${args.map(a => disp(a.t)).join(', ')}) – schreib einen Konstruktor  ${cls.name}(…) { … }`, line);
      const scope = new Scope(null);
      const frame = { cls, thisVal: val, isStatic: false, scope, method: ctor || { name: cls.name, ret: { name: 'void' } } };
      if (ctor) yield* this.bindArgs(ctor, args, scope, line);
      let body = ctor ? ctor.body.body : [];
      const first = body[0];
      if (first && first.k === 'expr' && first.e.k === 'ctorcall') {
        const cargs = []; for (const a of first.e.args) cargs.push(yield* this.eval(a, frame, scope));
        if (first.e.which === 'this') { yield* this.construct(cls, val, cargs, first.line); body = body.slice(1); return yield* this.runCtorBody(body, frame, scope); }
        yield* this.superConstruct(cls, val, cargs, first.line);
        body = body.slice(1);
      } else yield* this.superConstruct(cls, val, [], line);
      for (const fd of cls.fields) if (!fd.static && fd.init) val.v.f.set(fd.name, this.coerce(yield* this.evalInit(fd.init, fd.type, frame), fd.type, fd.line, true));
      for (const ib of cls.inits) if (!ib.static) yield* this.execBody(ib.block.body, frame, new Scope(scope));
      yield* this.runCtorBody(body, frame, scope);
    }
    *runCtorBody(body, frame, scope) {
      try { yield* this.execBody(body, frame, scope); } catch (e) { if (!(e instanceof ReturnSig)) throw e; }
    }
    *superConstruct(cls, val, args, line) {
      if (!cls.sup || cls.sup === 'Object') { if (args.length) cerr('Object hat keinen Konstruktor mit Parametern', line); return; }
      const sc = this.classes.get(cls.sup);
      if (sc) return yield* this.construct(sc, val, args, line);
      if (EX_PARENT.hasOwnProperty(cls.sup)) { val.v.exMsg = args.length ? yield* this.str(args[0], line) : null; val.v.exUser = true; return; }
    }

    // ---- Start
    *run() {
      const prog = this.prog;
      for (const c of this.classes.values()) this.statics.set(c.name, new Map());
      for (const c of this.classes.values()) {
        const frame = { cls: c, thisVal: null, isStatic: true, scope: new Scope(null), method: { name: '<clinit>', ret: { name: 'void' } } };
        for (const fd of c.fields) if (fd.static) this.statics.get(c.name).set(fd.name, { t: typeStr(fd.type), v: fd.init ? this.coerce(yield* this.evalInit(fd.init, fd.type, frame), fd.type, fd.line, true) : this.defaultVal(fd.type), fin: fd.final, init: true });
        for (const ib of c.inits) if (ib.static) yield* this.execBody(ib.block.body, frame, new Scope(null));
      }
      const argsArr = { t: 'String[]', v: { et: 'String', a: [], oid: ++OID } };
      try {
        yield* this.invoke(prog.main, null, [argsArr], prog.main.line);
      } catch (e) { if (e instanceof ExitSig) return; throw e; }
    }

    // ---- Anweisungen
    *execBody(stmts, frame, scope) { for (const s of stmts) yield* this.exec(s, frame, scope); }
    *exec(n, frame, scope) {
      this.curLine = n.line;
      this.tick();
      if ((this.steps & 8191) === 0) yield { type: 'tick' };
      switch (n.k) {
        case 'block': return yield* this.execBody(n.body, frame, new Scope(scope));
        case 'empty': return;
        case 'local': {
          for (const d of n.decls) {
            if (scope.find(d.name) && this.isLocalInMethod(scope, d.name)) cerr(`Die Variable ${d.name} gibt es hier schon – jede Variable darf nur einmal deklariert werden`, d.line);
            this.checkType(d.type, d.line);
            let v;
            if (d.init) v = this.coerce(yield* this.evalInit(d.init, d.type, frame, scope), d.type, d.line, true);
            const t = d.type.name === 'var' ? (v ? v.t : 'var') : typeStr(d.type);
            if (d.type.name === 'var' && !d.init) cerr('var braucht einen Startwert, z. B. var x = 5;', d.line);
            scope.vars.set(d.name, { t, v, init: !!d.init, fin: n.fin });
          }
          return;
        }
        case 'expr': {
          const r = yield* this.eval(n.e, frame, scope);
          return n.arrowValue ? r : undefined;
        }
        case 'if':
          if (this.truthy(yield* this.eval(n.cond, frame, scope), n.line, 'if')) yield* this.exec(n.then, frame, new Scope(scope));
          else if (n.els) yield* this.exec(n.els, frame, new Scope(scope));
          return;
        case 'while':
          while (this.truthy(yield* this.eval(n.cond, frame, scope), n.line)) {
            try { yield* this.exec(n.body, frame, new Scope(scope)); }
            catch (e) { if (e instanceof BreakSig && (!e.label || e.label === n.label)) break; if (e instanceof ContinueSig && (!e.label || e.label === n.label)) continue; throw e; }
          }
          return;
        case 'do':
          do {
            try { yield* this.exec(n.body, frame, new Scope(scope)); }
            catch (e) { if (e instanceof BreakSig && (!e.label || e.label === n.label)) break; if (e instanceof ContinueSig && (!e.label || e.label === n.label)) continue; throw e; }
          } while (this.truthy(yield* this.eval(n.cond, frame, scope), n.line));
          return;
        case 'for': {
          const fs = new Scope(scope);
          for (const i of n.init) yield* this.exec(i, frame, fs);
          while (!n.cond || this.truthy(yield* this.eval(n.cond, frame, fs), n.line)) {
            try { yield* this.exec(n.body, frame, new Scope(fs)); }
            catch (e) { if (e instanceof BreakSig && (!e.label || e.label === n.label)) break; if (!(e instanceof ContinueSig && (!e.label || e.label === n.label))) throw e; }
            for (const u of n.upd) yield* this.eval(u, frame, fs);
          }
          return;
        }
        case 'foreach': {
          const it = yield* this.eval(n.iter, frame, scope);
          if (it.t === 'null') throw this.npe(null, n.line);
          let items;
          if (it.t.endsWith('[]')) items = it.v.a;
          else if (it.t === 'ArrayList' || it.t === 'HashSet') items = it.v.a.slice();
          else cerr(`for-each geht nur über Arrays und Listen, nicht über ${disp(it.t)}`, n.line);
          if (n.type.name !== 'var') this.checkType(n.type, n.line);
          for (const item of items) {
            const fs = new Scope(scope);
            fs.vars.set(n.name, { t: n.type.name === 'var' ? item.t : typeStr(n.type), v: n.type.name === 'var' ? item : this.coerce(item, n.type, n.line), init: true });
            try { yield* this.exec(n.body, frame, fs); }
            catch (e) { if (e instanceof BreakSig && (!e.label || e.label === n.label)) break; if (e instanceof ContinueSig && (!e.label || e.label === n.label)) continue; throw e; }
          }
          return;
        }
        case 'return': throw new ReturnSig(n.e ? yield* this.eval(n.e, frame, scope) : null);
        case 'break': throw new BreakSig(n.label);
        case 'continue': throw new ContinueSig(n.label);
        case 'switch': {
          const sel = yield* this.eval(n.sel, frame, scope);
          if (sel.t === 'null') throw this.npe(null, n.line);
          let start = -1;
          for (let i = 0; i < n.cases.length && start < 0; i++) {
            const c = n.cases[i]; if (!c.labels) continue;
            for (const l of c.labels) { const lv = yield* this.eval(l, frame, scope); if (this.valEquals(sel, lv)) { start = i; break; } }
          }
          if (start < 0) start = n.cases.findIndex(c => !c.labels);
          if (start < 0) return;
          const ss = new Scope(scope);
          try {
            for (let i = start; i < n.cases.length; i++) {
              yield* this.execBody(n.cases[i].body, frame, n.cases[i].arrow ? new Scope(ss) : ss);
              if (n.cases[i].arrow) break;
            }
          } catch (e) { if (e instanceof BreakSig && !e.label) return; throw e; }
          return;
        }
        case 'throw': {
          const v = yield* this.eval(n.e, frame, scope);
          if (v.t === 'null') throw this.npe(null, n.line);
          if (!(v.v && (v.v.ex || v.v.exUser || this.isSubclass(v.t, 'Throwable')))) cerr(`throw braucht ein Exception-Objekt, nicht ${disp(v.t)}`, n.line);
          throw new JavaThrow(v, n.line);
        }
        case 'try': {
          const ts = new Scope(scope);
          for (const r of n.resources) yield* this.exec(r, frame, ts);
          try {
            yield* this.exec(n.block, frame, ts);
          } catch (e) {
            let ex = e;
            if (e instanceof JavaError && e.kind === 'runtime-internal') ex = e;
            if (!(ex instanceof JavaThrow)) throw e;
            const c = n.catches.find(c => c.types.some(t => this.isSubclass(ex.val.t, t)));
            if (!c) throw e;
            const cs = new Scope(scope);
            cs.vars.set(c.name, { t: ex.val.t, v: ex.val, init: true });
            yield* this.exec(c.body, frame, cs);
          } finally {
            if (n.fin) yield* this.exec(n.fin, frame, new Scope(scope));
          }
          return;
        }
      }
      cerr('Unbekannte Anweisung', n.line);
    }
    isLocalInMethod(scope) { return true; }

    valEquals(a, b) {
      if (a.t === 'String' && b.t === 'String') return a.v === b.v;
      if (NUM.has(a.t) && NUM.has(b.t)) return a.v === b.v;
      if (a.t === 'boolean' && b.t === 'boolean') return a.v === b.v;
      return a.v === b.v;
    }
    *javaEquals(a, b, line) { // a.equals(b)
      if (a.t === 'null') throw this.npe('Cannot invoke "Object.equals(Object)" because value is null', line);
      if (a.t === 'String') return b.t === 'String' && a.v === b.v;
      if (NUM.has(a.t) || a.t === 'boolean') return b.t === a.t && a.v === b.v;
      if (a.v && a.v.cls && a.v.cls.fields) { const m = this.findMethods(a.t, 'equals').find(m => m.params.length === 1); if (m) return (yield* this.invoke(m, a, [b], line)).v; }
      if (a.t === 'ArrayList' && b.t === 'ArrayList') { if (a.v.a.length !== b.v.a.length) return false; for (let i = 0; i < a.v.a.length; i++) if (!(yield* this.javaEquals(a.v.a[i], b.v.a[i], line))) return false; return true; }
      return a.v === b.v;
    }

    // ---- Ausdrücke
    *evalInit(init, ty, frame, scope) {
      if (init.k === 'arrinit') return yield* this.evalArrInit(init, ty, frame, scope);
      return yield* this.eval(init, frame, scope);
    }
    *evalArrInit(n, ty, frame, scope) {
      if (ty.name === 'var') cerr('Bei var geht keine { … }-Liste – schreib z. B. int[] zahlen = {1, 2, 3};', n.line);
      if (!ty.dims) cerr(`Eine Liste { … } passt nur zu einem Array, nicht zu ${typeStr(ty)}`, n.line);
      const et = Object.assign({}, ty, { dims: ty.dims - 1 });
      const a = [];
      for (const e of n.elems) a.push(this.coerce(e.k === 'arrinit' ? yield* this.evalArrInit(e, et, frame, scope) : yield* this.eval(e, frame, scope), et, e.line, true));
      return { t: typeStr(ty), v: { et: typeStr(et), a, oid: ++OID } };
    }
    lookupVar(name, frame, scope, line) {
      const v = scope && scope.find(name);
      if (v) return { kind: 'local', ref: v };
      if (frame.cls) {
        for (const c of this.classChain(frame.cls.name)) {
          const f = c.fields.find(f => f.name === name);
          if (f) {
            if (f.static) return { kind: 'static', ref: this.statics.get(c.name).get(name), field: f };
            if (frame.isStatic) cerr(`Auf das Attribut ${name} kann man in einer static-Methode nicht direkt zugreifen (es gehört zu einem Objekt). Tipp: Objekt erzeugen oder das Attribut static machen`, line);
            return { kind: 'field', obj: frame.thisVal, name, field: f };
          }
        }
      }
      return null;
    }
    unknownVar(name, frame, scope, line) {
      const cands = (scope ? scope.names() : []).concat(frame.cls ? frame.cls.fields.map(f => f.name) : []);
      if (/^(system|string|math|scanner|integer)$/i.test(name) && name[0] !== name[0].toUpperCase()) cerr(`${name} gibt es nicht – Klassennamen beginnen mit Großbuchstaben: ${name[0].toUpperCase() + name.slice(1)}`, line);
      const s = suggest(name, cands);
      cerr(`Die Variable ${name} gibt es nicht` + (s ? ` – meintest du ${s}?` : ' – wurde sie vorher deklariert (z. B. int ' + name + ' = 0;)?'), line);
    }
    readRef(r, name, line) {
      if (r.kind === 'local' || r.kind === 'static') {
        if (!r.ref.init) cerr(`Die Variable ${name} hat noch keinen Wert – gib ihr zuerst einen (z. B. ${name} = 0;)`, line);
        return r.ref.v;
      }
      return r.obj.v.f.get(r.name);
    }
    writeRef(r, name, val, line) {
      if (r.kind === 'local' || r.kind === 'static') {
        if (r.ref.fin && r.ref.init) cerr(`Die Variable ${name} ist final und kann nicht mehr geändert werden`, line);
        const nv = this.coerce(val, r.ref.t, line);
        r.ref.v = nv; r.ref.init = true; return nv;
      }
      const fd = r.field;
      const nv = this.coerce(val, fd.type, line);
      if (fd.final && r.obj.v.f.has(r.name) && r.obj.v.fset && r.obj.v.fset.has(r.name)) cerr(`Das Attribut ${name} ist final und kann nicht mehr geändert werden`, line);
      if (fd.final) { (r.obj.v.fset = r.obj.v.fset || new Set()).add(r.name); }
      r.obj.v.f.set(r.name, nv); return nv;
    }
    *lvalue(t, frame, scope) {
      if (t.k === 'name') {
        const r = this.lookupVar(t.name, frame, scope, t.line);
        if (!r) this.unknownVar(t.name, frame, scope, t.line);
        return { get: () => this.readRef(r, t.name, t.line), set: v => this.writeRef(r, t.name, v, t.line), type: r.kind === 'field' ? typeStr(r.field.type) : r.ref.t };
      }
      if (t.k === 'field') {
        if (t.obj.k === 'name' && !this.lookupVar(t.obj.name, frame, scope) && this.classes.has(t.obj.name)) {
          const c = this.classes.get(t.obj.name); const f = c.fields.find(f => f.name === t.name && f.static);
          if (!f) cerr(`Die Klasse ${c.name} hat kein static-Attribut ${t.name}`, t.line);
          const ref = this.statics.get(c.name).get(t.name);
          return { get: () => ref.v, set: v => this.writeRef({ kind: 'static', ref }, t.name, v, t.line), type: ref.t };
        }
        const o = yield* this.eval(t.obj, frame, scope);
        if (o.t === 'null') throw this.npe(`Cannot assign field "${t.name}" because value is null`, t.line);
        if (!(o.v && o.v.cls && o.v.cls.fields)) cerr(`${disp(o.t)} hat kein Attribut ${t.name}`, t.line);
        const fd = this.findField(o.t, t.name);
        if (!fd) cerr(`Die Klasse ${o.t} hat kein Attribut ${t.name}`, t.line);
        this.checkAccess(fd, frame, t.line, 'Attribut');
        if (fd.static) { const ref = this.statics.get(fd.cls).get(t.name); return { get: () => ref.v, set: v => this.writeRef({ kind: 'static', ref }, t.name, v, t.line), type: ref.t }; }
        const r = { kind: 'field', obj: o, name: t.name, field: fd };
        return { get: () => o.v.f.get(t.name), set: v => this.writeRef(r, t.name, v, t.line), type: typeStr(fd.type) };
      }
      if (t.k === 'index') {
        const arr = yield* this.eval(t.arr, frame, scope);
        const idx = yield* this.eval(t.idx, frame, scope);
        if (arr.t === 'null') throw this.npe('Cannot store to array because value is null', t.line);
        if (!arr.t.endsWith('[]')) cerr(`${disp(arr.t)} ist kein Array – [ ] geht nur bei Arrays` + (arr.t === 'ArrayList' ? ' (bei ArrayList: get/set)' : ''), t.line);
        const i = this.intIndex(idx, t.line);
        if (i < 0 || i >= arr.v.a.length) throw this.exc('ArrayIndexOutOfBoundsException', `Index ${i} out of bounds for length ${arr.v.a.length}`, t.line);
        return { get: () => arr.v.a[i], set: v => (arr.v.a[i] = this.coerce(v, arr.v.et, t.line)), type: arr.v.et };
      }
      cerr('Links vom = muss eine Variable stehen', t.line);
    }
    checkAccess(member, frame, line, what) {
      if (member.mods && member.mods.has('private') && (!frame.cls || frame.cls.name !== member.cls)) cerr(`${what} ${member.name} ist private in ${member.cls} – von außen kein Zugriff (Tipp: Getter/Setter-Methode)`, line);
    }
    intIndex(idx, line) {
      if (!INTEGRAL.has(idx.t) || idx.t === 'long') cerr(`Ein Index muss eine ganze Zahl (int) sein, nicht ${disp(idx.t)}`, line);
      return idx.v;
    }

    *eval(n, frame, scope) {
      this.tick();
      switch (n.k) {
        case 'lit': return n.t === 'String' ? internStr(n.v) : n.t === 'null' ? NULL : mk(n.t, n.v);
        case 'paren': return yield* this.eval(n.e, frame, scope);
        case 'name': {
          const r = this.lookupVar(n.name, frame, scope, n.line);
          if (!r) {
            if (this.classes.has(n.name) || ['Math', 'System', 'Integer', 'String', 'Double', 'Character', 'Arrays', 'Collections'].includes(n.name)) cerr(`${n.name} ist eine Klasse, kein Wert`, n.line);
            this.unknownVar(n.name, frame, scope, n.line);
          }
          return this.readRef(r, n.name, n.line);
        }
        case 'this': if (frame.isStatic) cerr('this gibt es nicht in einer static-Methode', n.line); return frame.thisVal;
        case 'assign': { const lv = yield* this.lvalue(n.target, frame, scope); let v = yield* this.eval(n.e, frame, scope); if (n.e.k === 'lit' && v.t === 'int' && ['char', 'byte', 'short'].includes(BOX[lv.type] || lv.type)) v = this.coerce(v, lv.type, n.line, true); return lv.set(v); }
        case 'compound': {
          const lv = yield* this.lvalue(n.target, frame, scope);
          const cur = lv.get();
          const rhs = yield* this.eval(n.e, frame, scope);
          let res = yield* this.binop(n.op, cur, rhs, n.line);
          if (lv.type === 'String') return lv.set(res);
          res = this.castTo(res, BOX[lv.type] || lv.type, n.line);
          return lv.set(res);
        }
        case 'preinc': case 'postinc': {
          const lv = yield* this.lvalue(n.target, frame, scope);
          const cur = lv.get();
          if (!cur) cerr('Die Variable hat noch keinen Wert', n.line);
          if (!NUM.has(cur.t)) cerr(`++ und -- gehen nur bei Zahlen, nicht bei ${disp(cur.t)}`, n.line);
          const one = I(1);
          const res = this.castTo(yield* this.binop(n.op === '++' ? '+' : '-', cur, one, n.line), BOX[lv.type] || lv.type, n.line);
          lv.set(res);
          return n.k === 'preinc' ? res : cur;
        }
        case 'cond': return this.truthy(yield* this.eval(n.c, frame, scope), n.line) ? yield* this.eval(n.a, frame, scope) : yield* this.eval(n.b, frame, scope);
        case 'unary': {
          const v = yield* this.eval(n.e, frame, scope);
          if (n.op === '!') { if (v.t !== 'boolean') cerr(`! geht nur bei boolean, nicht bei ${disp(v.t)}`, n.line); return B(!v.v); }
          if (!NUM.has(v.t)) cerr(`Der Operator ${n.op} geht nicht bei ${disp(v.t)}`, n.line);
          const t = this.unaryType(v.t);
          if (n.op === '-') return mk(t, t === 'int' ? (-v.v) | 0 : -v.v);
          if (n.op === '+') return mk(t, v.v);
          if (n.op === '~') { if (!INTEGRAL.has(v.t)) cerr('~ geht nur bei ganzen Zahlen', n.line); return mk(t, ~v.v); }
          break;
        }
        case 'bin': {
          if (n.op === '&&' || n.op === '||') {
            const l = yield* this.eval(n.l, frame, scope);
            if (l.t !== 'boolean') cerr(`${n.op} geht nur bei boolean-Werten, nicht bei ${disp(l.t)}`, n.line);
            if (n.op === '&&' && !l.v) return B(false);
            if (n.op === '||' && l.v) return B(true);
            const r = yield* this.eval(n.r, frame, scope);
            if (r.t !== 'boolean') cerr(`${n.op} geht nur bei boolean-Werten, nicht bei ${disp(r.t)}`, n.line);
            return B(r.v);
          }
          const l = yield* this.eval(n.l, frame, scope);
          const r = yield* this.eval(n.r, frame, scope);
          return yield* this.binop(n.op, l, r, n.line);
        }
        case 'instanceof': {
          const v = yield* this.eval(n.e, frame, scope);
          const tn = typeStr(n.type);
          const ok = v.t !== 'null' && (v.t === tn || this.isSubclass(v.t, tn) || (tn === 'Object') || (BOX[tn] === v.t) || (['List', 'Collection'].includes(tn) && v.t === 'ArrayList'));
          if (ok && n.bind) scope.vars.set(n.bind, { t: tn, v, init: true });
          return B(ok);
        }
        case 'cast': {
          const v = yield* this.eval(n.e, frame, scope);
          const tn = typeStr(n.type);
          if (PRIMS.has(tn)) return this.castTo(v, tn, n.line, true);
          if (v.t === 'null') return v;
          if (BOX[tn]) return this.castTo(v, BOX[tn], n.line, true);
          if (v.t === tn || this.isSubclass(v.t, tn) || tn === 'Object' || (['List'].includes(tn) && v.t === 'ArrayList')) return v;
          throw this.exc('ClassCastException', `class ${v.t} cannot be cast to class ${tn}`, n.line);
        }
        case 'arrinit': cerr('Eine Liste { … } geht nur direkt bei der Deklaration – sonst: new int[]{1, 2, 3}', n.line); break;
        case 'newarr': {
          const sizes = [];
          for (const d of n.dimsExpr) { const s = yield* this.eval(d, frame, scope); const sz = this.intIndex(s, n.line); if (sz < 0) throw this.exc('NegativeArraySizeException', String(sz), n.line); sizes.push(sz); }
          this.checkType({ name: n.type.name, dims: 0 }, n.line);
          const make = (level) => {
            const ty = { name: n.type.name, dims: n.type.dims - level };
            const et = { name: n.type.name, dims: ty.dims - 1 };
            const a = [];
            if (level < sizes.length) for (let i = 0; i < sizes[level]; i++) a.push(level + 1 < sizes.length ? make(level + 1) : (et.dims ? NULL : this.defaultVal(et)));
            return { t: typeStr(ty), v: { et: typeStr(et), a, oid: ++OID } };
          };
          return make(0);
        }
        case 'index': {
          const arr = yield* this.eval(n.arr, frame, scope);
          const idx = yield* this.eval(n.idx, frame, scope);
          if (arr.t === 'null') throw this.npe(`Cannot load from array because ${this.exprName(n.arr)} is null`, n.line);
          if (!arr.t.endsWith('[]')) cerr(`${disp(arr.t)} ist kein Array – [ ] geht nur bei Arrays` + (arr.t === 'String' ? ' (bei Strings: charAt(i))' : arr.t === 'ArrayList' ? ' (bei ArrayList: get(i))' : ''), n.line);
          const i = this.intIndex(idx, n.line);
          if (i < 0 || i >= arr.v.a.length) throw this.exc('ArrayIndexOutOfBoundsException', `Index ${i} out of bounds for length ${arr.v.a.length}`, n.line);
          return arr.v.a[i];
        }
        case 'field': return yield* this.evalField(n, frame, scope);
        case 'call': return yield* this.evalCall(n, frame, scope);
        case 'new': return yield* this.evalNew(n, frame, scope);
        case 'ctorcall': cerr(`${n.which}(…) darf nur als erste Anweisung in einem Konstruktor stehen`, n.line); break;
        case 'super': cerr('super allein ist kein Wert', n.line); break;
      }
      cerr('Unbekannter Ausdruck', n.line);
    }
    exprName(e) { return e.k === 'name' ? `"${e.name}"` : e.k === 'field' ? `"${this.exprName(e.obj).replace(/"/g, '')}.${e.name}"` : 'the value'; }
    unaryType(t) { return t === 'double' || t === 'float' || t === 'long' ? t : 'int'; }
    castTo(v, tn, line, explicit) {
      if (tn === 'boolean') { if (v.t !== 'boolean') cerr(`${disp(v.t)} kann nicht in boolean umgewandelt werden`, line); return v; }
      if (!NUM.has(v.t)) {
        if (v.t === 'null') throw this.npe(null, line);
        cerr(`${disp(v.t)} kann nicht in ${tn} umgewandelt werden` + (v.t === 'String' && tn === 'int' ? ' – Tipp: Integer.parseInt(text)' : ''), line);
      }
      let x = v.v;
      switch (tn) {
        case 'int': x = (v.t === 'double' || v.t === 'float') ? (Number.isNaN(x) ? 0 : x >= 2147483647 ? 2147483647 : x <= -2147483648 ? -2147483648 : Math.trunc(x)) : (v.t === 'long' ? Number(BigInt.asIntN(32, BigInt(Math.trunc(x)))) : x | 0); return I(x);
        case 'long': return mk('long', (v.t === 'double' || v.t === 'float') ? (Number.isNaN(x) ? 0 : Math.trunc(x)) : x);
        case 'short': return mk('short', (((Math.trunc(x) | 0) << 16) >> 16));
        case 'byte': return mk('byte', (((Math.trunc(x) | 0) << 24) >> 24));
        case 'char': return mk('char', (Math.trunc(x) | 0) & 0xffff);
        case 'double': return D(x);
        case 'float': return mk('float', Math.fround(x));
      }
      cerr(`Umwandlung nach ${tn} nicht möglich`, line);
    }
    *binop(op, l, r, line) {
      if (op === '+' && (l.t === 'String' || r.t === 'String')) return S((yield* this.str(l, line)) + (yield* this.str(r, line)));
      if (op === '==' || op === '!=') {
        let eq;
        if (NUM.has(l.t) && NUM.has(r.t)) eq = l.v === r.v;
        else if (l.t === 'boolean' && r.t === 'boolean') eq = l.v === r.v;
        else if (l.t === 'String' && r.t === 'String') eq = l.sid === r.sid || l === r;
        else if (l.t === 'null' || r.t === 'null') eq = l.t === r.t;
        else if (PRIMS.has(l.t) !== PRIMS.has(r.t) && (PRIMS.has(l.t) || PRIMS.has(r.t))) cerr(`== kann ${disp(l.t)} und ${disp(r.t)} nicht vergleichen`, line);
        else eq = l.v === r.v;
        return B(op === '==' ? eq : !eq);
      }
      if (l.t === 'boolean' && r.t === 'boolean' && (op === '&' || op === '|' || op === '^')) return B(op === '&' ? l.v && r.v : op === '|' ? l.v || r.v : l.v !== r.v);
      if (!NUM.has(l.t) || !NUM.has(r.t)) {
        const bad = !NUM.has(l.t) ? l.t : r.t;
        if (bad === 'null') throw this.npe(null, line);
        if (['<', '>', '<=', '>='].includes(op) && l.t === 'String' && r.t === 'String') cerr(`Strings kann man nicht mit ${op} vergleichen – Tipp: text1.compareTo(text2)`, line);
        cerr(`Der Operator ${op} geht nicht mit ${disp(l.t)} und ${disp(r.t)}`, line);
      }
      const t = (l.t === 'double' || r.t === 'double') ? 'double' : (l.t === 'float' || r.t === 'float') ? 'float' : (l.t === 'long' || r.t === 'long') ? 'long' : 'int';
      const a = l.v, b = r.v;
      switch (op) {
        case '<': return B(a < b); case '>': return B(a > b); case '<=': return B(a <= b); case '>=': return B(a >= b);
        case '+': return t === 'int' ? I((a + b) | 0) : mk(t, t === 'float' ? Math.fround(a + b) : a + b);
        case '-': return t === 'int' ? I((a - b) | 0) : mk(t, t === 'float' ? Math.fround(a - b) : a - b);
        case '*': return t === 'int' ? I(Math.imul(a, b)) : mk(t, t === 'float' ? Math.fround(a * b) : a * b);
        case '/':
          if (t === 'int' || t === 'long') { if (b === 0) throw this.exc('ArithmeticException', '/ by zero', line); return mk(t, t === 'int' ? (a / b) | 0 : Math.trunc(a / b)); }
          return mk(t, t === 'float' ? Math.fround(a / b) : a / b);
        case '%':
          if ((t === 'int' || t === 'long') && b === 0) throw this.exc('ArithmeticException', '/ by zero', line);
          return mk(t, t === 'int' ? (a % b) | 0 : a % b);
        case '&': case '|': case '^': case '<<': case '>>': case '>>>':
          if (t === 'double' || t === 'float') cerr(`Der Operator ${op} geht nur bei ganzen Zahlen`, line);
          if (t === 'int' || op.length > 1) {
            const lt = (l.t === 'long') ? 'long' : 'int';
            if (lt === 'long') { const A = BigInt(Math.trunc(a)), Bv = BigInt(Math.trunc(b)); let res; switch (op) { case '&': res = A & Bv; break; case '|': res = A | Bv; break; case '^': res = A ^ Bv; break; case '<<': res = BigInt.asIntN(64, A << (Bv & 63n)); break; case '>>': res = A >> (Bv & 63n); break; case '>>>': res = BigInt.asUintN(64, A) >> (Bv & 63n); break; } return mk('long', Number(BigInt.asIntN(64, res))); }
            switch (op) { case '&': return I(a & b); case '|': return I(a | b); case '^': return I(a ^ b); case '<<': return I(a << b); case '>>': return I(a >> b); case '>>>': return I((a >>> b) | 0); }
          }
          { const A = BigInt(Math.trunc(a)), Bv = BigInt(Math.trunc(b)); const res = op === '&' ? A & Bv : op === '|' ? A | Bv : A ^ Bv; return mk('long', Number(BigInt.asIntN(64, res))); }
      }
      cerr(`Unbekannter Operator ${op}`, line);
    }

    // ---- Attribute
    *evalField(n, frame, scope) {
      if (n.obj.k === 'name' && !this.lookupVar(n.obj.name, frame, scope)) {
        const cn = n.obj.name;
        const sf = this.staticField(cn, n.name, n.line);
        if (sf !== undefined) return sf;
        if (this.classes.has(cn)) cerr(`Die Klasse ${cn} hat kein static-Attribut ${n.name}`, n.line);
      }
      const o = yield* this.eval(n.obj, frame, scope);
      if (n.name === 'length' && o.t.endsWith('[]')) return I(o.v.a.length);
      if (o.t === 'null') throw this.npe(`Cannot read field "${n.name}" because ${this.exprName(n.obj)} is null`, n.line);
      if (n.name === 'length' && o.t === 'String') cerr('Bei Strings ist length eine Methode: text.length()  (mit Klammern)', n.line);
      if (n.name === 'length' && o.t === 'ArrayList') cerr('Bei ArrayList heißt es liste.size()', n.line);
      if (o.v && o.v.cls && o.v.cls.fields) {
        const fd = this.findField(o.t, n.name);
        if (!fd) { const s = suggest(n.name, [...this.classChain(o.t)].flatMap(c => c.fields.map(f => f.name))); cerr(`Die Klasse ${o.t} hat kein Attribut ${n.name}` + (s ? ` – meintest du ${s}?` : ''), n.line); }
        this.checkAccess(fd, frame, n.line, 'Das Attribut');
        if (fd.static) return this.statics.get(fd.cls).get(n.name).v;
        return o.v.f.get(n.name);
      }
      cerr(`${disp(o.t)} hat kein Attribut ${n.name}`, n.line);
    }
    staticField(cn, name, line) {
      const uc = this.classes.get(cn);
      if (uc) { for (const c of this.classChain(cn)) { const f = c.fields.find(f => f.name === name && f.static); if (f) return this.statics.get(c.name).get(name).v; } return undefined; }
      const K = {
        Math: { PI: D(Math.PI), E: D(Math.E) },
        Integer: { MAX_VALUE: I(2147483647), MIN_VALUE: I(-2147483648) },
        Long: { MAX_VALUE: mk('long', 9223372036854775807), MIN_VALUE: mk('long', -9223372036854775808) },
        Double: { MAX_VALUE: D(Number.MAX_VALUE), MIN_VALUE: D(Number.MIN_VALUE), POSITIVE_INFINITY: D(Infinity), NEGATIVE_INFINITY: D(-Infinity), NaN: D(NaN) },
        Character: { MAX_VALUE: mk('char', 65535), MIN_VALUE: mk('char', 0) },
        System: { out: { t: 'PrintStream', v: 'out' }, err: { t: 'PrintStream', v: 'err' }, in: { t: 'InputStream', v: 'in' } },
      };
      if (K[cn]) { if (K[cn][name] === undefined) cerr(`${cn}.${name} gibt es nicht` + (suggest(name, Object.keys(K[cn])) ? ` – meintest du ${cn}.${suggest(name, Object.keys(K[cn]))}?` : ''), line); return K[cn][name]; }
      if (/^[a-z]/.test(cn) && /^(system|math|integer)$/i.test(cn)) cerr(`${cn} gibt es nicht – Klassennamen beginnen mit Großbuchstaben: ${cn[0].toUpperCase() + cn.slice(1)}`, line);
      return undefined;
    }

    // ---- Objekte erzeugen
    *evalNew(n, frame, scope) {
      const cn = n.type.name;
      const args = []; for (const a of n.args) args.push(yield* this.eval(a, frame, scope));
      if (this.classes.has(cn)) { const r = yield* this.instantiate(cn, args, n.line); return r; }
      this.checkType(n.type, n.line);
      switch (cn) {
        case 'Scanner':
          if (!args.length || args[0].t !== 'InputStream') { if (args[0] && args[0].t === 'String') return { t: 'Scanner', v: { oid: ++OID, src: args[0].v + '\n', own: true } }; cerr('Scanner braucht System.in:  new Scanner(System.in)', n.line); }
          return { t: 'Scanner', v: { oid: ++OID } };
        case 'Random': return { t: 'Random', v: new JRandom(args.length ? args[0].v : null) };
        case 'ArrayList': case 'LinkedList': {
          const v = { t: 'ArrayList', v: { a: [], oid: ++OID } };
          if (args.length && args[0].t === 'ArrayList') v.v.a = args[0].v.a.slice();
          return v;
        }
        case 'HashSet': { const v = { t: 'HashSet', v: { a: [], oid: ++OID } }; if (args.length && args[0].t === 'ArrayList') for (const e of args[0].v.a) yield* this.setAdd(v, e); return v; }
        case 'HashMap': return { t: 'HashMap', v: { m: new Map(), oid: ++OID } };
        case 'StringBuilder': return { t: 'StringBuilder', v: { s: args.length ? yield* this.str(args[0], n.line) : '', oid: ++OID } };
        case 'String': return S(args.length ? (args[0].t === 'char[]' ? args[0].v.a.map(c => String.fromCharCode(c.v)).join('') : yield* this.str(args[0], n.line)) : '');
        case 'Object': return { t: 'Object', v: { oid: ++OID } };
      }
      if (EX_PARENT.hasOwnProperty(cn)) return { t: cn, v: { ex: true, cls: cn, msg: args.length ? yield* this.str(args[0], n.line) : null, oid: ++OID } };
      if (BOX[cn]) cerr(`new ${cn}(…) ist veraltet – schreib einfach den Wert, z. B. ${cn} x = 5;`, n.line);
      cerr(`Die Klasse ${cn} gibt es nicht`, n.line);
    }

    // ---- Methodenaufrufe
    *evalArgs(args, frame, scope) { const out = []; for (const a of args) out.push(yield* this.eval(a, frame, scope)); return out; }
    *evalCall(n, frame, scope) {
      // System.out.println & Co.
      if (n.obj && n.obj.k === 'field' && n.obj.obj.k === 'name' && n.obj.obj.name === 'System' && (n.obj.name === 'out' || n.obj.name === 'err') && !this.lookupVar('System', frame, scope)) {
        const args = yield* this.evalArgs(n.args, frame, scope);
        return yield* this.print(n.name, args, n.line, n.obj.name === 'err');
      }
      if (n.obj && n.obj.k === 'field' && n.obj.obj.k === 'name' && /^system$/i.test(n.obj.obj.name) && n.obj.obj.name !== 'System' && !this.lookupVar(n.obj.obj.name, frame, scope)) cerr(`${n.obj.obj.name} gibt es nicht – richtig ist System (großes S)`, n.line);
      if (n.obj == null) {
        const args = yield* this.evalArgs(n.args, frame, scope);
        let cands = [];
        if (frame.thisVal && frame.thisVal.v && frame.thisVal.v.cls) cands = this.findMethods(frame.thisVal.t, n.name).filter(m => !(m.mods && m.mods.has('private')) || m.cls === frame.cls.name);
        if (!cands.length && frame.cls) cands = this.findMethods(frame.cls.name, n.name);
        if (!cands.length) {
          const all = frame.cls ? [...this.classChain(frame.cls.name)].flatMap(c => c.methods.map(m => m.name)) : [];
          const s = suggest(n.name, all);
          if (/^print(ln|f)?$/.test(n.name)) cerr(`Die Methode ${n.name}(…) gibt es so nicht – richtig ist System.out.${n.name}(…)`, n.line);
          cerr(`Die Methode ${n.name}(…) gibt es nicht` + (s ? ` – meintest du ${s}?` : ''), n.line);
        }
        const m = this.pickMethod(cands, args, n.line, n.name);
        if (!m.static && frame.isStatic) cerr(`Die Methode ${n.name} ist nicht static und kann aus der static-Methode ${frame.method.name} nicht direkt aufgerufen werden – Tipp: schreib static vor die Methode (public static …)`, n.line);
        return yield* this.invoke(m, m.static ? null : frame.thisVal, args, n.line);
      }
      if (n.obj.k === 'super') {
        const args = yield* this.evalArgs(n.args, frame, scope);
        const sup = frame.cls.sup;
        if (sup && this.classes.has(sup)) { const m = this.pickMethod(this.findMethods(sup, n.name), args, n.line, 'super.' + n.name); return yield* this.invoke(m, frame.thisVal, args, n.line); }
        if (n.name === 'toString') return S(frame.cls.name + '@' + hashOf(frame.thisVal.v));
        if (n.name === 'getMessage') return frame.thisVal.v.exMsg != null ? S(frame.thisVal.v.exMsg) : NULL;
        cerr(`super.${n.name}() gibt es nicht`, n.line);
      }
      // voll qualifiziert: java.util.Arrays.toString(…)
      const qn = this.qualifiedClass(n.obj, frame, scope);
      if (qn) {
        if (!STATIC_LIB[qn]) cerr(`${qn} hat keine statische Methode ${n.name}`, n.line);
        const fn = STATIC_LIB[qn][n.name];
        if (!fn) cerr(`${qn}.${n.name}(…) gibt es nicht`, n.line);
        const args = yield* this.evalArgs(n.args, frame, scope);
        return yield* fn.call(this, args, n.line);
      }
      // statischer Aufruf über Klassennamen?
      if (n.obj.k === 'name' && !this.lookupVar(n.obj.name, frame, scope)) {
        const cn = n.obj.name;
        if (this.classes.has(cn)) {
          const args = yield* this.evalArgs(n.args, frame, scope);
          const cands = this.findMethods(cn, n.name);
          if (!cands.length) cerr(`Die Klasse ${cn} hat keine Methode ${n.name}`, n.line);
          const m = this.pickMethod(cands, args, n.line, n.name);
          if (!m.static) cerr(`${cn}.${n.name}(…) geht nur, wenn die Methode static ist – sonst brauchst du ein Objekt: new ${cn}(…)`, n.line);
          this.checkAccess(m, frame, n.line, 'Die Methode');
          return yield* this.invoke(m, null, args, n.line);
        }
        if (STATIC_LIB[cn]) {
          if (UTIL.has(cn)) this.requireImport(cn, n.line);
          const args = yield* this.evalArgs(n.args, frame, scope);
          const fn = STATIC_LIB[cn][n.name];
          if (!fn) { const s = suggest(n.name, Object.keys(STATIC_LIB[cn])); cerr(`${cn}.${n.name}(…) gibt es nicht` + (s ? ` – meintest du ${cn}.${s}?` : ''), n.line); }
          return yield* fn.call(this, args, n.line);
        }
        if (/^[A-Z]/.test(cn) && !scope.find(cn)) {
          if (/^(math|integer|string|arrays|double|character)$/i.test(cn)) cerr(`${cn} gibt es nicht`, n.line);
          if (UTIL.has(cn)) this.requireImport(cn, n.line);
          const s = suggest(cn, Object.keys(STATIC_LIB).concat([...this.classes.keys()]));
          cerr(`Die Klasse ${cn} gibt es nicht` + (s ? ` – meintest du ${s}?` : ''), n.line);
        }
        if (/^(math|integer|string|arrays|double|character)$/.test(cn)) cerr(`${cn} gibt es nicht – Klassennamen beginnen mit Großbuchstaben: ${cn[0].toUpperCase() + cn.slice(1)}`, n.line);
      }
      const o = yield* this.eval(n.obj, frame, scope);
      const args = yield* this.evalArgs(n.args, frame, scope);
      return yield* this.callMethod(o, n.name, args, n.line, frame, n.obj);
    }
    qualifiedClass(e, frame, scope) {
      const parts = []; let x = e;
      while (x && x.k === 'field') { parts.unshift(x.name); x = x.obj; }
      if (!x || x.k !== 'name' || (x.name !== 'java' && x.name !== 'javax')) return null;
      if (this.lookupVar(x.name, frame, scope)) return null;
      parts.unshift(x.name);
      return parts.length >= 3 ? parts[parts.length - 1] : null;
    }
    *callMethod(o, name, args, line, frame, objExpr) {
      if (o.t === 'null') {
        let st = '';
        if (objExpr && objExpr.k === 'name' && frame) { const r = this.lookupVar(objExpr.name, frame, frame.scope); if (r && r.ref && r.ref.t) st = r.ref.t + '.'; else if (r && r.field) st = typeStr(r.field.type) + '.'; }
        throw this.npe(`Cannot invoke "${st}${name}()" because ${objExpr ? this.exprName(objExpr) : 'value'} is null`, line);
      }
      if (o.v && o.v.cls && o.v.cls.fields) {
        const cands = this.findMethods(o.t, name);
        if (cands.length) { const m = this.pickMethod(cands, args, line, name); this.checkAccess(m, frame || {}, line, 'Die Methode'); return yield* this.invoke(m, m.static ? null : o, args, line); }
        if (name === 'toString' && !args.length) return S(yield* this.str(o, line));
        if (name === 'equals' && args.length === 1) return B(o.v === args[0].v);
        if (name === 'hashCode' && !args.length) return I(parseInt(hashOf(o.v), 16) | 0);
        if (name === 'getClass') return { t: 'Class', v: o.t };
        if (o.v.exUser !== undefined || this.isSubclass(o.t, 'Throwable')) { const r = yield* this.exMethod(o, name, args, line); if (r !== undefined) return r; }
        const s = suggest(name, [...this.classChain(o.t)].flatMap(c => c.methods.map(m => m.name)));
        cerr(`Die Klasse ${o.t} hat keine Methode ${name}(…)` + (s ? ` – meintest du ${s}?` : ''), line);
      }
      if (o.v && o.v.ex) { const r = yield* this.exMethod(o, name, args, line); if (r !== undefined) return r; }
      let lib = INST_LIB[o.t];
      if (!lib && o.t.endsWith('[]')) lib = INST_LIB['[]'];
      if (!lib && NUM.has(o.t) || o.t === 'boolean') lib = INST_LIB.boxed;
      if (o.t === 'Class') { if (name === 'getSimpleName' || name === 'getName') return S(o.v); }
      if (!lib) cerr(`${disp(o.t)} hat keine Methode ${name}(…)`, line);
      const fn = lib[name];
      if (!fn) {
        if (PRIMS.has(o.t)) cerr(`${o.t} ist ein einfacher Datentyp und hat keine Methoden wie ${name}()`, line);
        if (o.t.endsWith('[]') && name === 'length') cerr('Bei Arrays ist length ein Attribut ohne Klammern: zahlen.length', line);
        if (o.t.endsWith('[]') && name === 'size') cerr('Bei Arrays heißt es zahlen.length (ohne Klammern)', line);
        const s = suggest(name, Object.keys(lib));
        cerr(`${disp(o.t)} hat keine Methode ${name}(…)` + (s ? ` – meintest du ${s}?` : ''), line);
      }
      return yield* fn.call(this, o, args, line);
    }
    *exMethod(o, name, args, line) {
      const msg = o.v.exUser ? o.v.exMsg : o.v.msg;
      if (name === 'getMessage' || name === 'getLocalizedMessage') return msg != null ? S(msg) : NULL;
      if (name === 'toString') return S(yield* this.str(o, line));
      if (name === 'printStackTrace') { this.emit((yield* this.str(o, line)) + '\n\tat Main.main(Main.java)\n', 'err'); return null; }
      return undefined;
    }

    // ---- Ausgabe
    emit(text, kind) { if (this.opts.onOut) this.opts.onOut(text, kind || 'out'); this.out += text; }
    *print(name, args, line, isErr) {
      const kind = isErr ? 'err' : 'out';
      if (name === 'println') { if (args.length > 1) cerr('println nimmt nur einen Wert – verbinde mehrere Werte mit +', line); this.emit((args.length ? yield* this.printStr(args[0], line) : '') + '\n', kind); return null; }
      if (name === 'print') { if (args.length !== 1) cerr(args.length ? 'print nimmt nur einen Wert – verbinde mehrere Werte mit +' : 'print braucht einen Wert, z. B. System.out.print("Hallo");', line); this.emit(yield* this.printStr(args[0], line), kind); return null; }
      if (name === 'printf' || name === 'format') { if (!args.length || args[0].t !== 'String') cerr('printf braucht zuerst einen Format-Text, z. B. printf("%d%n", zahl)', line); this.emit(yield* this.format(args[0].v, args.slice(1), line), kind); return null; }
      if (name === 'flush') return null;
      const s = suggest(name, ['println', 'print', 'printf']);
      cerr(`System.out.${name}(…) gibt es nicht` + (s ? ` – meintest du System.out.${s}(…)?` : ''), line);
    }
    *printStr(v, line) { if (v.t === 'char[]') return v.v.a.map(c => String.fromCharCode(c.v)).join(''); return yield* this.str(v, line); }
    *format(fmt, args, line) {
      let out = '', ai = 0;
      const re = /%(\d+\$)?([-#+ 0,(]*)(\d+)?(\.\d+)?([a-zA-Z%])/g;
      let last = 0, m;
      while ((m = re.exec(fmt))) {
        out += fmt.slice(last, m.index); last = re.lastIndex;
        const [spec, argIdx, flags, width, precS, conv] = m;
        if (conv === 'n') { out += '\n'; continue; }
        if (conv === '%') { out += '%'; continue; }
        let a;
        if (argIdx) a = args[parseInt(argIdx) - 1]; else a = args[ai++];
        if (a === undefined) throw this.exc('MissingFormatArgumentException', `Format specifier '${spec}'`, line);
        const prec = precS ? parseInt(precS.slice(1)) : null;
        let s;
        const lc = conv.toLowerCase();
        if (lc === 'd') {
          if (!INTEGRAL.has(a.t) || a.t === 'char') throw this.exc('IllegalFormatConversionException', `d != java.lang.${UNBOX_NAME[a.t] || a.t}`, line);
          s = String(Math.abs(a.v)); if (flags.includes(',')) s = groupThousands(s);
          s = this.signed(a.v < 0, s, flags);
        } else if (lc === 'f') {
          if (!(a.t === 'double' || a.t === 'float')) throw this.exc('IllegalFormatConversionException', `f != java.lang.${UNBOX_NAME[a.t] || a.t}`, line);
          s = fixedHalfUp(Math.abs(a.v), prec == null ? 6 : prec); if (flags.includes(',')) s = groupThousands(s);
          s = this.signed(a.v < 0 || Object.is(a.v, -0), s, flags);
        } else if (lc === 'e') {
          if (!(a.t === 'double' || a.t === 'float')) throw this.exc('IllegalFormatConversionException', `e != java.lang.${UNBOX_NAME[a.t] || a.t}`, line);
          s = sciJava(a.v, prec == null ? 6 : prec, conv === 'E');
        } else if (lc === 's') { s = yield* this.str(a, line); if (prec != null) s = s.slice(0, prec); }
        else if (lc === 'c') { if (a.t !== 'char' && a.t !== 'int') throw this.exc('IllegalFormatConversionException', `c != java.lang.${UNBOX_NAME[a.t] || a.t}`, line); s = String.fromCharCode(a.v); }
        else if (lc === 'b') { s = a.t === 'null' ? 'false' : a.t === 'boolean' ? String(a.v) : 'true'; }
        else if (lc === 'x') { if (!INTEGRAL.has(a.t)) throw this.exc('IllegalFormatConversionException', `x != java.lang.${UNBOX_NAME[a.t] || a.t}`, line); s = (a.t === 'long' ? BigInt.asUintN(64, BigInt(a.v)) : a.v >>> 0).toString(16); }
        else if (lc === 'o') { s = (a.v >>> 0).toString(8); }
        else throw this.exc('UnknownFormatConversionException', `Conversion = '${conv}'`, line);
        if (conv !== lc) s = s.toUpperCase();
        if (width) { const w = parseInt(width); if (s.length < w) { if (flags.includes('-')) s = s.padEnd(w); else if (flags.includes('0') && /[dfe]/.test(lc)) { const neg = /^[-+ (]/.test(s) ? s[0] : ''; s = neg + s.slice(neg.length).padStart(w - neg.length, '0'); } else s = s.padStart(w); } }
        out += s;
      }
      out += fmt.slice(last);
      return out;
    }
    signed(neg, s, flags) { if (neg) return flags.includes('(') ? '(' + s + ')' : '-' + s; if (flags.includes('+')) return '+' + s; if (flags.includes(' ')) return ' ' + s; return s; }

    // ---- Eingabe (Scanner)
    *ensureInput(sc) {
      if (sc && sc.own) return false;
      if (this.inputEOF) return false;
      const line = yield { type: 'input' };
      if (line == null) { this.inputEOF = true; return false; }
      this.inBuf += line + '\n';
      return true;
    }
    buf(sc) { return sc && sc.own ? sc.src : this.inBuf; }
    setBuf(sc, s) { if (sc && sc.own) sc.src = s; else this.inBuf = s; }
    *peekToken(sc) {
      while (true) {
        const b = this.buf(sc); const m = /^\s*(\S+)/.exec(b);
        if (m && (/\s/.test(b[m[0].length] || '') || false)) return { tok: m[1], len: m[0].length };
        if (!(yield* this.ensureInput(sc))) { const m2 = /^\s*(\S+)/.exec(this.buf(sc)); return m2 ? { tok: m2[1], len: m2[0].length } : null; }
      }
    }
    *nextToken(sc, line) { const p = yield* this.peekToken(sc); if (!p) throw this.exc('NoSuchElementException', null, line); this.setBuf(sc, this.buf(sc).slice(p.len)); return p.tok; }
    *nextLine(sc, line) {
      while (!this.buf(sc).includes('\n')) { if (!(yield* this.ensureInput(sc))) { if (this.buf(sc).length) { const r = this.buf(sc); this.setBuf(sc, ''); return r; } throw this.exc('NoSuchElementException', 'No line found', line); } }
      const b = this.buf(sc), i = b.indexOf('\n'); this.setBuf(sc, b.slice(i + 1)); return b.slice(0, i);
    }
  }
  function sameSig(a, b) { return a.name === b.name && a.params.length === b.params.length && a.params.every((p, i) => typeStr(p.type) === typeStr(b.params[i].type)); }

  // ------------------------------------------------------------------ Bibliothek: statische Methoden
  const need = (args, n, line, name) => { if (args.length !== n) cerr(`${name} braucht ${n} Wert${n === 1 ? '' : 'e'}, nicht ${args.length}`, line); };
  const num = (a, line, name) => { if (!NUM.has(a.t)) cerr(`${name} braucht eine Zahl, nicht ${disp(a.t)}`, line); return a.v; };
  const dbl = (a, line, name) => D(num(a, line, name));
  function* g(v) { return v; }
  const mathT = (args) => (args.some(a => a.t === 'double' || a.t === 'float') ? 'double' : args.some(a => a.t === 'long') ? 'long' : 'int');
  function parseIntJava(s, radix, line, rt) {
    if (s === null) throw rt.exc('NumberFormatException', 'Cannot parse null string: null', line);
    if (!/^[+-]?[0-9]+$/.test(s) || (radix && radix !== 10)) { if (radix && radix !== 10 && new RegExp('^[+-]?[0-9a-zA-Z]+$').test(s)) { const v = parseInt(s, radix); if (!Number.isNaN(v)) return v; } throw rt.exc('NumberFormatException', `For input string: "${s}"` + (radix && radix !== 10 ? ` under radix ${radix}` : ''), line); }
    const v = Number(s); if (v > 2147483647 || v < -2147483648) throw rt.exc('NumberFormatException', `For input string: "${s}"`, line);
    return v;
  }
  function parseDoubleJava(s, line, rt) {
    const t = (s || '').trim();
    if (!/^[+-]?(NaN|Infinity|((\d+\.?\d*|\.\d+)([eE][+-]?\d+)?)[fFdD]?)$/.test(t)) throw rt.exc('NumberFormatException', s === '' ? 'empty String' : `For input string: "${s}"`, line);
    return Number(t.replace(/[fFdD]$/, ''));
  }
  const STATIC_LIB = {
    Math: {
      *abs(a, l) { need(a, 1, l, 'Math.abs'); const t = mathT(a); return mk(t, t === 'int' ? Math.abs(a[0].v) | 0 : Math.abs(num(a[0], l, 'Math.abs'))); },
      *max(a, l) { need(a, 2, l, 'Math.max'); return mk(mathT(a), Math.max(num(a[0], l, 'Math.max'), num(a[1], l, 'Math.max'))); },
      *min(a, l) { need(a, 2, l, 'Math.min'); return mk(mathT(a), Math.min(num(a[0], l, 'Math.min'), num(a[1], l, 'Math.min'))); },
      *pow(a, l) { need(a, 2, l, 'Math.pow'); return D(Math.pow(num(a[0], l, 'Math.pow'), num(a[1], l, 'Math.pow'))); },
      *sqrt(a, l) { need(a, 1, l, 'Math.sqrt'); return dbl({ t: 'double', v: Math.sqrt(num(a[0], l, 'Math.sqrt')) }, l, ''); },
      *cbrt(a, l) { need(a, 1, l, 'Math.cbrt'); return D(Math.cbrt(num(a[0], l, 'Math.cbrt'))); },
      *round(a, l) { need(a, 1, l, 'Math.round'); const v = num(a[0], l, 'Math.round'); const r = Math.floor(v + 0.5); return a[0].t === 'float' ? I(r) : mk('long', Number.isNaN(v) ? 0 : r); },
      *floor(a, l) { need(a, 1, l, 'Math.floor'); return D(Math.floor(num(a[0], l, 'Math.floor'))); },
      *ceil(a, l) { need(a, 1, l, 'Math.ceil'); return D(Math.ceil(num(a[0], l, 'Math.ceil'))); },
      *random(a, l) { need(a, 0, l, 'Math.random'); return D(Math.random()); },
      *hypot(a, l) { need(a, 2, l, 'Math.hypot'); return D(Math.hypot(a[0].v, a[1].v)); },
      *signum(a, l) { return D(Math.sign(a[0].v)); },
      *sin(a) { return D(Math.sin(a[0].v)); }, *cos(a) { return D(Math.cos(a[0].v)); }, *tan(a) { return D(Math.tan(a[0].v)); },
      *log(a) { return D(Math.log(a[0].v)); }, *log10(a) { return D(Math.log10(a[0].v)); }, *exp(a) { return D(Math.exp(a[0].v)); },
      *toRadians(a) { return D(a[0].v * Math.PI / 180); }, *toDegrees(a) { return D(a[0].v * 180 / Math.PI); },
      *floorDiv(a, l) { if (a[1].v === 0) throw this.exc('ArithmeticException', '/ by zero', l); return mk(mathT(a), Math.floor(a[0].v / a[1].v)); },
      *floorMod(a, l) { if (a[1].v === 0) throw this.exc('ArithmeticException', '/ by zero', l); return mk(mathT(a), ((a[0].v % a[1].v) + a[1].v) % a[1].v); },
    },
    Integer: {
      *parseInt(a, l) { if (!a.length || (a[0].t !== 'String' && a[0].t !== 'null')) cerr('Integer.parseInt braucht einen String, z. B. Integer.parseInt("42")', l); return I(parseIntJava(a[0].v, a[1] && a[1].v, l, this)); },
      *valueOf(a, l) { if (a[0].t === 'String') return I(parseIntJava(a[0].v, null, l, this)); return this.coerce(a[0], 'int', l); },
      *toString(a, l) { return S(a.length > 1 ? (a[0].v).toString(a[1].v) : String(a[0].v)); },
      *toBinaryString(a) { return S((a[0].v >>> 0).toString(2)); }, *toHexString(a) { return S((a[0].v >>> 0).toString(16)); },
      *max(a) { return I(Math.max(a[0].v, a[1].v)); }, *min(a) { return I(Math.min(a[0].v, a[1].v)); }, *sum(a) { return I((a[0].v + a[1].v) | 0); },
      *compare(a) { return I(a[0].v < a[1].v ? -1 : a[0].v > a[1].v ? 1 : 0); },
    },
    Long: { *parseLong(a, l) { if (!/^[+-]?\d+$/.test(a[0].v || '')) throw this.exc('NumberFormatException', `For input string: "${a[0].v}"`, l); return mk('long', Number(a[0].v)); } },
    Double: {
      *parseDouble(a, l) { if (!a.length || (a[0].t !== 'String' && a[0].t !== 'null')) cerr('Double.parseDouble braucht einen String', l); if (a[0].t === 'null') throw this.npe(null, l); return D(parseDoubleJava(a[0].v, l, this)); },
      *valueOf(a, l) { if (a[0].t === 'String') return D(parseDoubleJava(a[0].v, l, this)); return this.coerce(a[0], 'double', l); },
      *toString(a) { return S(jDouble(a[0].v)); }, *isNaN(a) { return B(Number.isNaN(a[0].v)); },
      *compare(a) { return I(a[0].v < a[1].v ? -1 : a[0].v > a[1].v ? 1 : 0); }, *max(a) { return D(Math.max(a[0].v, a[1].v)); }, *min(a) { return D(Math.min(a[0].v, a[1].v)); },
    },
    Boolean: { *parseBoolean(a) { return B(a[0].t === 'String' && a[0].v.toLowerCase() === 'true'); } },
    Character: {
      *isDigit(a) { return B(/\p{Nd}/u.test(String.fromCharCode(a[0].v))); }, *isLetter(a) { return B(/\p{L}/u.test(String.fromCharCode(a[0].v))); },
      *isLetterOrDigit(a) { return B(/[\p{L}\p{Nd}]/u.test(String.fromCharCode(a[0].v))); }, *isWhitespace(a) { return B(/\s/.test(String.fromCharCode(a[0].v))); },
      *isUpperCase(a) { const c = String.fromCharCode(a[0].v); return B(c !== c.toLowerCase() && c === c.toUpperCase()); }, *isLowerCase(a) { const c = String.fromCharCode(a[0].v); return B(c !== c.toUpperCase() && c === c.toLowerCase()); },
      *toUpperCase(a) { const c = String.fromCharCode(a[0].v).toUpperCase(); return mk(a[0].t === 'int' ? 'int' : 'char', c.length === 1 ? c.charCodeAt(0) : a[0].v); },
      *toLowerCase(a) { return mk(a[0].t === 'int' ? 'int' : 'char', String.fromCharCode(a[0].v).toLowerCase().charCodeAt(0)); },
      *getNumericValue(a) { const c = String.fromCharCode(a[0].v); return I(/[0-9]/.test(c) ? Number(c) : /[a-z]/i.test(c) ? c.toLowerCase().charCodeAt(0) - 87 : -1); },
      *toString(a) { return S(String.fromCharCode(a[0].v)); }, *isAlphabetic(a) { return B(/\p{L}/u.test(String.fromCharCode(a[0].v))); },
    },
    String: {
      *valueOf(a, l) { if (a[0] && a[0].t === 'char[]') return S(a[0].v.a.map(c => String.fromCharCode(c.v)).join('')); return S(yield* this.str(a[0], l)); },
      *format(a, l) { if (!a.length || a[0].t !== 'String') cerr('String.format braucht zuerst einen Format-Text', l); return S(yield* this.format(a[0].v, a.slice(1), l)); },
      *join(a, l) {
        const sep = yield* this.str(a[0], l); const parts = [];
        const items = a.length === 2 && (a[1].t === 'ArrayList' || a[1].t.endsWith('[]')) ? a[1].v.a : a.slice(1);
        for (const x of items) parts.push(yield* this.str(x, l));
        return S(parts.join(sep));
      },
    },
    System: {
      *currentTimeMillis() { return mk('long', Date.now()); }, *nanoTime() { return mk('long', Math.round(performance.now() * 1e6)); },
      *exit(a) { throw new ExitSig(a[0] ? a[0].v : 0); }, *lineSeparator() { return S('\n'); },
    },
    Thread: { *sleep(a, l) { yield { type: 'sleep', ms: a[0].v }; return null; } },
    Arrays: {
      *toString(a, l) { if (a[0].t === 'null') return S('null'); if (!a[0].t.endsWith('[]')) cerr('Arrays.toString braucht ein Array', l); const parts = []; for (const x of a[0].v.a) parts.push(yield* this.str(x, l)); return S('[' + parts.join(', ') + ']'); },
      *sort(a, l) {
        if (!a[0].t.endsWith('[]')) cerr('Arrays.sort braucht ein Array', l);
        const arr = a[0].v.a, from = a.length >= 3 ? a[1].v : 0, to = a.length >= 3 ? a[2].v : arr.length;
        const part = arr.slice(from, to);
        if (part.length && part[0].t === 'String') part.sort((x, y) => (x.v < y.v ? -1 : x.v > y.v ? 1 : 0)); else if (part.length && NUM.has(part[0].t)) part.sort((x, y) => x.v - y.v);
        else { const cmp = []; for (const x of part) cmp.push(x); yield* this.sortObjects(cmp, l); part.splice(0, part.length, ...cmp); }
        arr.splice(from, part.length, ...part); return null;
      },
      *fill(a, l) { const et = a[0].v.et; for (let i = 0; i < a[0].v.a.length; i++) a[0].v.a[i] = this.coerce(a[1], et, l); return null; },
      *copyOf(a, l) { const src = a[0].v.a, n = a[1].v; const et = a[0].v.et; const out = []; for (let i = 0; i < n; i++) out.push(i < src.length ? src[i] : this.defaultVal({ name: et.replace(/\[\]/g, ''), dims: (et.match(/\[\]/g) || []).length })); return { t: a[0].t, v: { et, a: out, oid: ++OID } }; },
      *copyOfRange(a, l) { const src = a[0].v.a; return { t: a[0].t, v: { et: a[0].v.et, a: src.slice(a[1].v, a[2].v), oid: ++OID } }; },
      *equals(a) { const x = a[0].v.a, y = a[1].v.a; return B(x.length === y.length && x.every((e, i) => e.v === y[i].v)); },
      *asList(a) { const items = a.length === 1 && a[0].t.endsWith('[]') ? a[0].v.a.slice() : a.slice(); return { t: 'ArrayList', v: { a: items, oid: ++OID, fixed: true } }; },
    },
    Collections: {
      *sort(a, l) { const arr = a[0].v.a; if (arr.length && arr[0].t === 'String') arr.sort((x, y) => (x.v < y.v ? -1 : x.v > y.v ? 1 : 0)); else if (arr.length && NUM.has(arr[0].t)) arr.sort((x, y) => x.v - y.v); else yield* this.sortObjects(arr, l); return null; },
      *reverse(a) { a[0].v.a.reverse(); return null; },
      *shuffle(a) { const arr = a[0].v.a; for (let i = arr.length - 1; i > 0; i--) { const j = Math.floor(Math.random() * (i + 1)); [arr[i], arr[j]] = [arr[j], arr[i]]; } return null; },
      *max(a, l) { const arr = a[0].v.a; if (!arr.length) throw this.exc('NoSuchElementException', null, l); return arr.reduce((m, x) => (x.v > m.v ? x : m)); },
      *min(a, l) { const arr = a[0].v.a; if (!arr.length) throw this.exc('NoSuchElementException', null, l); return arr.reduce((m, x) => (x.v < m.v ? x : m)); },
      *frequency(a) { return I(a[0].v.a.filter(x => x.v === a[1].v).length); },
    },
  };
  Runtime.prototype.sortObjects = function* (arr, line) {
    const keyed = [];
    for (const x of arr) keyed.push(x);
    // einfache Einfüge-Sortierung über compareTo der Objekte
    for (let i = 1; i < keyed.length; i++) {
      const cur = keyed[i]; let j = i - 1;
      while (j >= 0) {
        const m = this.findMethod(keyed[j].t, 'compareTo', 1);
        if (!m) cerr(`Objekte vom Typ ${keyed[j].t} kann man nicht sortieren – sie brauchen eine compareTo-Methode`, line);
        const c = yield* this.invoke(m, keyed[j], [cur], line);
        if (c.v <= 0) break;
        keyed[j + 1] = keyed[j]; j--;
      }
      keyed[j + 1] = cur;
    }
    arr.splice(0, arr.length, ...keyed);
  };
  Runtime.prototype.setAdd = function* (set, e) { for (const x of set.v.a) if (yield* this.javaEquals(x, e, 0)) return false; set.v.a.push(e); return true; };

  // ------------------------------------------------------------------ Bibliothek: Methoden an Objekten
  const strIdx = (rt, s, i, line, len) => { if (i < 0 || i >= (len == null ? s.length : len)) throw rt.exc('StringIndexOutOfBoundsException', `Index ${i} out of bounds for length ${s.length}`, line); };
  const argStr = (a, line, what) => { if (a.t === 'char') return String.fromCharCode(a.v); if (a.t !== 'String') { if (a.t === 'null') return null; cerr(`${what} braucht einen String, nicht ${disp(a.t)}`, line); } return a.v; };
  function javaRegex(re) { return re.replace(/\\p\{Alpha\}/g, '[A-Za-z]').replace(/\\p\{Punct\}/g, '[!-\\/:-@\\[-`{-~]'); }
  const INST_LIB = {
    String: {
      *length(o, a, l) { need(a, 0, l, 'length()'); return I(o.v.length); },
      *charAt(o, a, l) { need(a, 1, l, 'charAt'); const i = this.intIndex(a[0], l); if (i < 0 || i >= o.v.length) throw this.exc('StringIndexOutOfBoundsException', `Index ${i} out of bounds for length ${o.v.length}`, l); return mk('char', o.v.charCodeAt(i)); },
      *substring(o, a, l) {
        const b = a[0].v, e = a.length > 1 ? a[1].v : o.v.length;
        if (b < 0 || e > o.v.length || b > e) throw this.exc('StringIndexOutOfBoundsException', b < 0 || b > e ? `begin ${b}, end ${e}, length ${o.v.length}` : `Range [${b}, ${e}) out of bounds for length ${o.v.length}`, l);
        return S(o.v.substring(b, e));
      },
      *indexOf(o, a, l) { const s = argStr(a[0], l, 'indexOf'); return I(o.v.indexOf(s, a[1] ? a[1].v : 0)); },
      *lastIndexOf(o, a, l) { const s = argStr(a[0], l, 'lastIndexOf'); return I(a[1] ? o.v.lastIndexOf(s, a[1].v) : o.v.lastIndexOf(s)); },
      *equals(o, a, l) { need(a, 1, l, 'equals'); return B(a[0].t === 'String' && a[0].v === o.v); },
      *equalsIgnoreCase(o, a, l) { return B(a[0].t === 'String' && a[0].v.toLowerCase() === o.v.toLowerCase()); },
      *compareTo(o, a, l) { const s = a[0].v; if (a[0].t === 'null') throw this.npe(null, l); const n = Math.min(o.v.length, s.length); for (let i = 0; i < n; i++) if (o.v.charCodeAt(i) !== s.charCodeAt(i)) return I(o.v.charCodeAt(i) - s.charCodeAt(i)); return I(o.v.length - s.length); },
      *compareToIgnoreCase(o, a, l) { const x = o.v.toLowerCase(), y = a[0].v.toLowerCase(); const n = Math.min(x.length, y.length); for (let i = 0; i < n; i++) if (x.charCodeAt(i) !== y.charCodeAt(i)) return I(x.charCodeAt(i) - y.charCodeAt(i)); return I(x.length - y.length); },
      *toUpperCase(o) { return S(o.v.toUpperCase()); }, *toLowerCase(o) { return S(o.v.toLowerCase()); },
      *trim(o) { return S(o.v.replace(/^[\x00-\x20]+|[\x00-\x20]+$/g, '')); }, *strip(o) { return S(o.v.trim()); },
      *isEmpty(o) { return B(o.v.length === 0); }, *isBlank(o) { return B(o.v.trim().length === 0); },
      *contains(o, a, l) { const s = argStr(a[0], l, 'contains'); if (s === null) throw this.npe(null, l); return B(o.v.includes(s)); },
      *startsWith(o, a, l) { return B(o.v.startsWith(argStr(a[0], l, 'startsWith'))); }, *endsWith(o, a, l) { return B(o.v.endsWith(argStr(a[0], l, 'endsWith'))); },
      *replace(o, a, l) { const x = argStr(a[0], l, 'replace'), y = argStr(a[1], l, 'replace'); return S(o.v.split(x).join(y)); },
      *replaceAll(o, a, l) { return S(o.v.replace(new RegExp(javaRegex(a[0].v), 'g'), a[1].v.replace(/\$(\d)/g, '$$$1'))); },
      *replaceFirst(o, a, l) { return S(o.v.replace(new RegExp(javaRegex(a[0].v)), a[1].v)); },
      *split(o, a, l) {
        const re = new RegExp(javaRegex(a[0].v)); let parts = o.v.split(re);
        if (o.v.length && parts.length && parts[0] === '' && o.v.search(re) === 0) { const m = o.v.match(re); if (m && m[0].length === 0) parts.shift(); }
        while (parts.length > 1 && parts[parts.length - 1] === '') parts.pop();
        if (o.v === '') parts = [''];
        return { t: 'String[]', v: { et: 'String', a: parts.map(p => S(p)), oid: ++OID } };
      },
      *toCharArray(o) { return { t: 'char[]', v: { et: 'char', a: [...o.v].map(c => mk('char', c.charCodeAt(0))), oid: ++OID } }; },
      *repeat(o, a) { return S(o.v.repeat(a[0].v)); }, *concat(o, a) { return S(o.v + a[0].v); },
      *hashCode(o) { let h = 0; for (let i = 0; i < o.v.length; i++) h = (Math.imul(31, h) + o.v.charCodeAt(i)) | 0; return I(h); },
      *matches(o, a) { return B(new RegExp('^(?:' + javaRegex(a[0].v) + ')$').test(o.v)); },
      *chars(o, a, l) { cerr('chars() (Streams) wird in dieser Lern-Version nicht unterstützt', l); },
      *toString(o) { return o; }, *intern(o) { return internStr(o.v); }, *strip_(o) { return o; },
    },
    StringBuilder: {
      *append(o, a, l) { o.v.s += yield* this.printStr(a[0], l); return o; }, *toString(o) { return S(o.v.s); }, *length(o) { return I(o.v.s.length); },
      *reverse(o) { o.v.s = [...o.v.s].reverse().join(''); return o; }, *charAt(o, a, l) { strIdx(this, o.v.s, a[0].v, l); return mk('char', o.v.s.charCodeAt(a[0].v)); },
      *insert(o, a, l) { const s = yield* this.str(a[1], l); o.v.s = o.v.s.slice(0, a[0].v) + s + o.v.s.slice(a[0].v); return o; },
      *deleteCharAt(o, a, l) { strIdx(this, o.v.s, a[0].v, l); o.v.s = o.v.s.slice(0, a[0].v) + o.v.s.slice(a[0].v + 1); return o; },
      *setCharAt(o, a, l) { strIdx(this, o.v.s, a[0].v, l); o.v.s = o.v.s.slice(0, a[0].v) + String.fromCharCode(a[1].v) + o.v.s.slice(a[0].v + 1); return null; },
      *indexOf(o, a) { return I(o.v.s.indexOf(a[0].v)); }, *isEmpty(o) { return B(!o.v.s.length); },
      *delete(o, a) { o.v.s = o.v.s.slice(0, a[0].v) + o.v.s.slice(a[1].v); return o; }, *setLength(o, a) { o.v.s = o.v.s.slice(0, a[0].v).padEnd(a[0].v, '\0'); return null; },
    },
    ArrayList: {
      *add(o, a, l) {
        if (o.v.fixed) throw this.exc('UnsupportedOperationException', null, l);
        if (a.length === 2) { const i = this.intIndex(a[0], l); if (i < 0 || i > o.v.a.length) throw this.exc('IndexOutOfBoundsException', `Index: ${i}, Size: ${o.v.a.length}`, l); o.v.a.splice(i, 0, a[1]); return null; }
        need(a, 1, l, 'add'); o.v.a.push(a[0]); return B(true);
      },
      *get(o, a, l) { need(a, 1, l, 'get'); const i = this.intIndex(a[0], l); if (i < 0 || i >= o.v.a.length) throw this.exc('IndexOutOfBoundsException', `Index ${i} out of bounds for length ${o.v.a.length}`, l); return o.v.a[i]; },
      *set(o, a, l) { const i = this.intIndex(a[0], l); if (i < 0 || i >= o.v.a.length) throw this.exc('IndexOutOfBoundsException', `Index ${i} out of bounds for length ${o.v.a.length}`, l); const old = o.v.a[i]; o.v.a[i] = a[1]; return old; },
      *size(o) { return I(o.v.a.length); }, *isEmpty(o) { return B(o.v.a.length === 0); }, *clear(o) { o.v.a.length = 0; return null; },
      *remove(o, a, l) {
        if (a[0].t === 'int' || a[0].t === 'short' || a[0].t === 'byte') { const i = a[0].v; if (i < 0 || i >= o.v.a.length) throw this.exc('IndexOutOfBoundsException', `Index ${i} out of bounds for length ${o.v.a.length}`, l); return o.v.a.splice(i, 1)[0]; }
        for (let i = 0; i < o.v.a.length; i++) if (yield* this.javaEquals(o.v.a[i], a[0], l)) { o.v.a.splice(i, 1); return B(true); }
        return B(false);
      },
      *contains(o, a, l) { for (const x of o.v.a) if (x.t !== 'null' && (yield* this.javaEquals(x, a[0], l))) return B(true); return B(false); },
      *indexOf(o, a, l) { for (let i = 0; i < o.v.a.length; i++) if (o.v.a[i].t !== 'null' && (yield* this.javaEquals(o.v.a[i], a[0], l))) return I(i); return I(-1); },
      *lastIndexOf(o, a, l) { for (let i = o.v.a.length - 1; i >= 0; i--) if (yield* this.javaEquals(o.v.a[i], a[0], l)) return I(i); return I(-1); },
      *addAll(o, a) { o.v.a.push(...a[0].v.a); return B(true); }, *toString(o, a, l) { return S(yield* this.str(o, l)); },
      *equals(o, a, l) { return B(yield* this.javaEquals(o, a[0], l)); },
      *forEach(o, a, l) { cerr('forEach mit Lambda wird noch nicht unterstützt – nimm  for (Typ x : liste)', l); },
    },
    HashSet: {
      *add(o, a, l) { return B(yield* this.setAdd(o, a[0])); }, *contains(o, a, l) { for (const x of o.v.a) if (yield* this.javaEquals(x, a[0], l)) return B(true); return B(false); },
      *size(o) { return I(o.v.a.length); }, *isEmpty(o) { return B(!o.v.a.length); },
      *remove(o, a, l) { for (let i = 0; i < o.v.a.length; i++) if (yield* this.javaEquals(o.v.a[i], a[0], l)) { o.v.a.splice(i, 1); return B(true); } return B(false); },
      *clear(o) { o.v.a.length = 0; return null; },
    },
    HashMap: {
      *put(o, a, l) { const k = (a[0].t) + ':' + (yield* this.str(a[0], l)); const old = o.v.m.get(k); o.v.m.set(k, [a[0], a[1]]); return old ? old[1] : NULL; },
      *get(o, a, l) { const k = (a[0].t) + ':' + (yield* this.str(a[0], l)); const e = o.v.m.get(k); return e ? e[1] : NULL; },
      *getOrDefault(o, a, l) { const k = (a[0].t) + ':' + (yield* this.str(a[0], l)); const e = o.v.m.get(k); return e ? e[1] : a[1]; },
      *containsKey(o, a, l) { return B(o.v.m.has((a[0].t) + ':' + (yield* this.str(a[0], l)))); },
      *containsValue(o, a, l) { for (const [, [, v]] of o.v.m) if (yield* this.javaEquals(v, a[0], l)) return B(true); return B(false); },
      *remove(o, a, l) { const k = (a[0].t) + ':' + (yield* this.str(a[0], l)); const e = o.v.m.get(k); o.v.m.delete(k); return e ? e[1] : NULL; },
      *size(o) { return I(o.v.m.size); }, *isEmpty(o) { return B(!o.v.m.size); }, *clear(o) { o.v.m.clear(); return null; },
      *keySet(o) { return { t: 'ArrayList', v: { a: [...o.v.m.values()].map(e => e[0]), oid: ++OID } }; },
      *values(o) { return { t: 'ArrayList', v: { a: [...o.v.m.values()].map(e => e[1]), oid: ++OID } }; },
      *toString(o, a, l) { return S(yield* this.str(o, l)); },
    },
    Scanner: {
      *nextLine(o, a, l) { return S(yield* this.nextLine(o.v, l)); },
      *next(o, a, l) { return S(yield* this.nextToken(o.v, l)); },
      *nextInt(o, a, l) {
        const p = yield* this.peekToken(o.v);
        if (!p) throw this.exc('NoSuchElementException', null, l);
        if (!/^[+-]?\d+$/.test(p.tok) || Math.abs(Number(p.tok)) > 2147483648) throw this.exc('InputMismatchException', null, l);
        this.setBuf(o.v, this.buf(o.v).slice(p.len)); return I(Number(p.tok));
      },
      *nextLong(o, a, l) { const p = yield* this.peekToken(o.v); if (!p) throw this.exc('NoSuchElementException', null, l); if (!/^[+-]?\d+$/.test(p.tok)) throw this.exc('InputMismatchException', `For input string: "${p.tok}"`, l); this.setBuf(o.v, this.buf(o.v).slice(p.len)); return mk('long', Number(p.tok)); },
      *nextDouble(o, a, l) {
        const p = yield* this.peekToken(o.v);
        if (!p) throw this.exc('NoSuchElementException', null, l);
        const t = p.tok.replace(',', '.');
        if (!/^[+-]?(\d+\.?\d*|\.\d+)([eE][+-]?\d+)?$/.test(t)) throw this.exc('InputMismatchException', null, l);
        this.setBuf(o.v, this.buf(o.v).slice(p.len)); return D(Number(t));
      },
      *nextBoolean(o, a, l) { const p = yield* this.peekToken(o.v); if (!p) throw this.exc('NoSuchElementException', null, l); if (!/^(true|false)$/i.test(p.tok)) throw this.exc('InputMismatchException', `For input string: "${p.tok}"`, l); this.setBuf(o.v, this.buf(o.v).slice(p.len)); return B(p.tok.toLowerCase() === 'true'); },
      *hasNextInt(o) { const p = yield* this.peekToken(o.v); return B(!!p && /^[+-]?\d+$/.test(p.tok)); },
      *hasNextDouble(o) { const p = yield* this.peekToken(o.v); return B(!!p && /^[+-]?(\d+[.,]?\d*|[.,]\d+)$/.test(p.tok)); },
      *hasNext(o) { const p = yield* this.peekToken(o.v); return B(!!p); },
      *hasNextLine(o) { if (this.buf(o.v).length) return B(true); return B(yield* this.ensureInput(o.v)); },
      *close() { return null; },
    },
    Random: {
      *nextInt(o, a, l) {
        if (a.length === 2) { const lo = a[0].v, hi = a[1].v; if (lo >= hi) throw this.exc('IllegalArgumentException', 'bound must be greater than origin', l); return I(lo + o.v.nextInt(hi - lo)); }
        if (a.length === 1 && a[0].v <= 0) throw this.exc('IllegalArgumentException', 'bound must be positive', l);
        return I(a.length ? o.v.nextInt(a[0].v) : o.v.nextInt());
      },
      *nextDouble(o) { return D(o.v.nextDouble()); }, *nextBoolean(o) { return B(o.v.nextBoolean()); },
    },
    '[]': {
      *clone(o) { return { t: o.t, v: { et: o.v.et, a: o.v.a.slice(), oid: ++OID } }; },
      *equals(o, a) { return B(o.v === a[0].v); }, *toString(o, a, l) { return S(yield* this.str(o, l)); },
    },
    boxed: {
      *equals(o, a) { return B(a[0].t === o.t && a[0].v === o.v); }, *compareTo(o, a) { return I(o.v < a[0].v ? -1 : o.v > a[0].v ? 1 : 0); },
      *intValue(o) { return I(o.v | 0); }, *doubleValue(o) { return D(o.v); }, *toString(o, a, l) { return S(yield* this.str(o, l)); },
      *booleanValue(o) { return o; }, *charValue(o) { return o; }, *longValue(o) { return mk('long', Math.trunc(o.v)); },
    },
    PrintStream: {},
  };

  // ------------------------------------------------------------------ Ausführen
  const EX_HINT = {
    ArithmeticException: 'Du teilst durch 0. Bei ganzen Zahlen (int) ist das in Java verboten.',
    ArrayIndexOutOfBoundsException: 'Du greifst auf einen Platz im Array zu, den es nicht gibt. Die Plätze gehen von 0 bis länge − 1.',
    StringIndexOutOfBoundsException: 'Du greifst auf eine Stelle im Text zu, die es nicht gibt. Die Stellen gehen von 0 bis length() − 1.',
    IndexOutOfBoundsException: 'Du greifst auf einen Platz in der Liste zu, den es nicht gibt. Die Plätze gehen von 0 bis size() − 1.',
    NullPointerException: 'Eine Variable zeigt auf kein Objekt (sie ist null), du benutzt sie aber so, als wäre eins da.',
    NumberFormatException: 'Der Text ist keine gültige Zahl und kann nicht umgewandelt werden.',
    InputMismatchException: 'Die Eingabe passt nicht zum erwarteten Typ (z. B. Buchstaben statt einer ganzen Zahl).',
    NoSuchElementException: 'Das Programm wollte etwas einlesen, aber es gab keine Eingabe mehr.',
    StackOverflowError: 'Eine Methode ruft sich endlos selbst auf (Rekursion ohne Abbruch).',
    IllegalFormatConversionException: 'Der Platzhalter passt nicht zum Wert: %d ist für ganze Zahlen, %f für Kommazahlen, %s für Text.',
    MissingFormatArgumentException: 'Für einen Platzhalter (z. B. %d) fehlt der passende Wert.',
    ClassCastException: 'Das Objekt hat nicht den Typ, in den du es umwandeln willst.',
    NegativeArraySizeException: 'Ein Array kann keine negative Größe haben.',
  };

  function describeError(e, rt) {
    if (e instanceof JavaError) {
      if (e.kind === 'compile') return { kind: 'compile', line: e.line, message: e.message, text: `Fehler in Zeile ${e.line}: ${e.message}` };
      if (e.kind === 'limit') return { kind: 'limit', line: e.line, message: e.message, text: e.message };
      return { kind: 'internal', message: e.message, text: e.message };
    }
    if (e instanceof JavaThrow) {
      const v = e.val; const cls = v.v.cls && v.v.cls.name ? v.v.cls.name : v.v.cls || v.t;
      const msg = v.v.exUser ? v.v.exMsg : v.v.msg;
      const name = v.v.exUser ? cls : fqn(cls);
      let hint = EX_HINT[cls];
      if (!hint && v.v.exUser) { let c = v.t; while (c && !EX_HINT[c]) { const uc = rt && rt.classes.get(c); c = uc ? uc.sup : EX_PARENT[c]; } hint = c ? EX_HINT[c] : null; }
      return { kind: 'exception', line: e.line, exception: cls, message: msg, text: `Exception in thread "main" ${name}${msg != null ? ': ' + msg : ''}\n\tat Main.main(Main.java:${e.line})`, hint: hint || null };
    }
    if (e instanceof RangeError) return { kind: 'exception', exception: 'StackOverflowError', text: 'Exception in thread "main" java.lang.StackOverflowError', hint: EX_HINT.StackOverflowError };
    return { kind: 'internal', message: String(e && e.message || e), text: 'Interner Fehler des Mini-Java-Interpreters: ' + (e && e.message || e) };
  }

  /** Synchron ausführen (für Tests, Benotung und Video-Ausgaben). input: Array von Zeilen. */
  function runSync(src, input, opts) {
    opts = opts || {};
    const res = { output: '', error: null, echo: [] };
    let prog;
    try { prog = compile(src); } catch (e) { res.error = describeError(e); return res; }
    const lines = (input || []).slice();
    const parts = [];
    const rt = new Runtime(prog, { maxSteps: opts.maxSteps || 5000000, onOut: (t, k) => parts.push({ text: t, kind: k }) });
    const gen = rt.run();
    let nextVal;
    try {
      while (true) {
        const r = gen.next(nextVal); nextVal = undefined;
        if (r.done) break;
        if (r.value && r.value.type === 'input') { const ln = lines.length ? lines.shift() : null; if (ln != null) { parts.push({ text: ln + '\n', kind: 'in' }); res.echo.push(ln); } nextVal = ln; }
      }
    } catch (e) { res.error = describeError(e, rt); }
    res.parts = parts;
    res.output = parts.filter(p => p.kind !== 'in').map(p => p.text).join('');
    res.transcript = parts.map(p => p.text).join('');
    return res;
  }

  /**
   * Interaktiv ausführen (Browser). callbacks: onOut(text, kind), onInput() -> Promise<string|null>,
   * onDone(result). Liefert { stop() }.
   */
  function startRun(src, cb) {
    let prog, stopped = false;
    try { prog = compile(src); } catch (e) { const err = describeError(e); setTimeout(() => cb.onDone({ error: err }), 0); return { stop() {} }; }
    const rt = new Runtime(prog, { maxSteps: cb.maxSteps || 50000000, onOut: cb.onOut });
    const gen = rt.run();
    const t0 = Date.now();
    async function loop(val) {
      try {
        let budgetEnd = performance.now() + 25;
        while (!stopped) {
          const r = gen.next(val); val = undefined;
          if (r.done) { cb.onDone({ error: null, ms: Date.now() - t0 }); return; }
          const y = r.value;
          if (y.type === 'input') { val = await cb.onInput(); if (stopped) return; budgetEnd = performance.now() + 25; continue; }
          if (y.type === 'sleep') { await new Promise(res => setTimeout(res, Math.min(y.ms, 5000))); budgetEnd = performance.now() + 25; continue; }
          if (performance.now() > budgetEnd) { await new Promise(res => setTimeout(res, 0)); budgetEnd = performance.now() + 25; }
        }
      } catch (e) { cb.onDone({ error: describeError(e, rt) }); }
    }
    loop();
    return { stop() { stopped = true; cb.onDone({ error: { kind: 'stopped', text: 'Programm wurde gestoppt.' } }); } };
  }

  const api = { compile, runSync, startRun, lex, JavaError, jDouble, version: '1.0' };
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  global.MiniJava = api;
})(typeof globalThis !== 'undefined' ? globalThis : this);
