// Node-Variante der JS-Laufzeit (nur fürs Bauen und Testen): gleiche Vorbereitung, gleiche Formatierung, vm statt Worker.
const vm = require('node:vm');
const path = require('node:path');
const JR = require(path.join(__dirname, 'jsrun.js'));

let current = null;
process.on('unhandledRejection', r => { if (current) current(r); });

function runNode(code, opts = {}) {
  const timeout = opts.timeout || 4000;
  return new Promise(resolve => {
    const parts = [];
    let done = false;
    const finish = error => {
      if (done) return; done = true; clearTimeout(timer); current = null;
      resolve({ parts, output: parts.filter(p => p.kind !== 'meta').map(p => p.text).join(''), error });
    };
    const emit = (k, p) => {
      if (k === 'out') parts.push({ text: p.text, kind: p.kind });
      else if (k === 'error') { const d = JR.describe(p); finish(Object.assign({ kind: d.syntax ? 'syntax' : 'runtime' }, d)); }
      else if (k === 'done') finish(null);
    };
    const host = { setTimeout, clearTimeout, setInterval, clearInterval };
    const ctx = vm.createContext({ __emit: emit, __host: host });
    const timer = setTimeout(() => finish({ kind: 'timeout', text: 'Zeitlimit überschritten' }), timeout + 500);
    current = r => { const g = ctx.__rejected; if (g) g(r); };
    try {
      vm.runInContext(JR.PRELUDE + '\n' + code + '\n;__finish();', ctx, { filename: 'main.js', timeout });
    } catch (e) {
      const d = JR.describe({ name: e && e.name, message: e && e.message, stack: e && e.stack, line: e && e.name === 'SyntaxError' ? syntaxLine(e) : 0 });
      finish(Object.assign({ kind: d.syntax ? 'syntax' : 'runtime' }, d));
    }
  });
}
function syntaxLine(e) {
  const m = /main\.js:(\d+)/.exec(String(e.stack || ''));
  return m ? Number(m[1]) - JR.OFFSET : 0;
}
module.exports = { runNode, OFFSET: JR.OFFSET };
