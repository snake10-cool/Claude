// Vergleicht Mini-Java mit echtem Java (javac/java 21): gleiche Ausgabe? gleiche Exception?
//   node test/differential.mjs [filter]
import { createRequire } from 'node:module';
import { execFileSync } from 'node:child_process';
import { mkdtempSync, writeFileSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import path from 'node:path';
const require = createRequire(import.meta.url);
const MJ = require('../src/minijava.js');
const { PROGRAMS } = await import('./programs.mjs');

const filter = process.argv[2];
let pass = 0, fail = 0;
for (const p of PROGRAMS) {
  if (filter && !p.name.includes(filter)) continue;
  const dir = mkdtempSync(path.join(tmpdir(), 'mj-'));
  writeFileSync(path.join(dir, 'Main.java'), p.src);
  let real = '', realErr = '';
  try {
    execFileSync('javac', ['-encoding', 'UTF-8', 'Main.java'], { cwd: dir, stdio: ['ignore', 'pipe', 'pipe'] });
    try {
      real = execFileSync('java', ['-Dfile.encoding=UTF-8', '-Dstdout.encoding=UTF-8', '-Duser.language=en', '-cp', '.', 'Main'], { cwd: dir, input: (p.input || []).join('\n') + (p.input ? '\n' : ''), stdio: ['pipe', 'pipe', 'pipe'], env: { ...process.env, JAVA_TOOL_OPTIONS: '' } }).toString();
    } catch (e) { real = e.stdout.toString(); realErr = e.stderr.toString().split('\n').find(l => l.includes('Exception') || l.includes('Error')) || 'ERR'; }
  } catch (e) { realErr = 'COMPILE: ' + e.stderr.toString().split('\n')[0]; }
  rmSync(dir, { recursive: true, force: true });
  const mine = MJ.runSync(p.src, p.input || []);
  const myErr = mine.error ? (mine.error.kind === 'compile' ? 'COMPILE: ' + mine.error.text : mine.error.text.split('\n')[0]) : '';
  const outOk = real === mine.output;
  const errOk = (!realErr && !myErr) || (realErr && myErr && (realErr.startsWith('COMPILE') ? myErr.startsWith('COMPILE') : realErr.replace(/^.*?(java\.\S+)/, '$1').split(':')[0] === myErr.replace(/^.*?(java\.\S+)/, '$1').split(':')[0]));
  const errMsgOk = !realErr || realErr.startsWith('COMPILE') || realErr.replace(/^.*?(java\.)/, '$1') === myErr.replace(/^.*?(java\.)/, '$1');
  if (outOk && errOk) { pass++; if (!errMsgOk) console.log(`~ ${p.name}: Meldung weicht ab\n    java: ${realErr}\n    mini: ${myErr}`); }
  else {
    fail++;
    console.log(`✗ ${p.name}`);
    if (!outOk) { console.log('  --- java:\n' + JSON.stringify(real)); console.log('  --- mini:\n' + JSON.stringify(mine.output)); }
    if (!errOk) console.log(`  Fehler java: ${realErr}\n  Fehler mini: ${myErr}`);
  }
}
console.log(`\n${pass} ok, ${fail} falsch`);
process.exit(fail ? 1 : 0);
