// Baut die EINE Kursseite:  node build.mjs [--java]  ->  dist/kurs.html
// Prüft dabei: jedes Code-Beispiel im Video läuft (oder zeigt absichtlich einen Fehler), jede Musterlösung
// (Lektionen und Challenges) besteht ihre eigenen Tests, und mit --java auch, dass sie mit echtem javac kompiliert.
import { readFileSync, writeFileSync, mkdirSync, readdirSync, mkdtempSync, rmSync } from 'node:fs';
import { createRequire } from 'node:module';
import { execFileSync } from 'node:child_process';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
const dir = path.dirname(fileURLToPath(import.meta.url));
const require = createRequire(import.meta.url);
const MJ = require('./src/minijava.js');
const withJava = process.argv.includes('--java');
const read = f => readFileSync(path.join(dir, f), 'utf8');
const imp = async f => (await import(pathToFileURL(path.join(dir, f)).href + '?t=' + Date.now())).default;

const lessons = [];
for (const f of readdirSync(path.join(dir, 'lessons')).filter(f => /^l\d+\.mjs$/.test(f)).sort()) lessons.push(await imp('lessons/' + f));
const kurs = await imp('lessons/kurs.mjs');
let problems = 0;
const warn = msg => { problems++; console.log('  ⚠ ' + msg); };
const hit = (c, out) => { const h = c.re ? new RegExp(c.re, c.flags || 'i').test(out) : out.toLowerCase().includes(String(c.has).toLowerCase()); return c.not ? !h : h; };

function javacCheck(src) {
  const d = mkdtempSync(path.join(tmpdir(), 'jk-'));
  try { writeFileSync(path.join(d, 'Main.java'), src); execFileSync('javac', ['-encoding', 'UTF-8', 'Main.java'], { cwd: d, stdio: ['ignore', 'pipe', 'pipe'] }); return null; }
  catch (e) { return (e.stderr || '').toString().split('\n').slice(0, 3).join(' | '); }
  finally { rmSync(d, { recursive: true, force: true }); }
}
function checkTask(t, label) {
  for (const k of ['id', 'title', 'text', 'req', 'starter', 'solution', 'rubric']) if (!t[k]) warn(`${label}: ${k} fehlt`);
  const sum = t.rubric.reduce((a, r) => a + r[1], 0); if (sum !== 100) warn(`${label}: Punkte ergeben ${sum}, nicht 100`);
  for (const test of t.tests || []) {
    const r = MJ.runSync(t.solution, test.input || []);
    if (r.error) warn(`${label}: Musterlösung scheitert in Test „${test.name}“: ${r.error.text}`);
    for (const c of test.expect || []) if (!hit(c, r.output)) warn(`${label}: Musterlösung erfüllt „${c.label || c.has || c.re}“ nicht (Test ${test.name})`);
  }
  for (const c of t.codeChecks || []) if (!new RegExp(c.re, c.flags || '').test(t.solution)) warn(`${label}: Musterlösung erfüllt Code-Prüfung „${c.label}“ nicht`);
  // Der unveränderte Startcode darf die Tests NICHT bestehen
  const st = MJ.runSync(t.starter, (t.tests && t.tests[0] && t.tests[0].input) || []);
  if (st.error && st.error.kind === 'compile') warn(`${label}: Startcode kompiliert nicht: ${st.error.text}`);
  if ((t.tests || []).length && (t.tests || []).every(test => { const r = MJ.runSync(t.starter, test.input || []); return !r.error && (test.expect || []).every(c => hit(c, r.output)); })) warn(`${label}: schon der Startcode besteht alle Tests`);
  if (withJava) { const e = javacCheck(t.solution); if (e) warn(`${label}: Musterlösung – javac: ${e}`); }
}

const ids = new Set();
for (const L of lessons) {
  console.log(`Lektion ${L.nr}: ${L.title}`);
  let code = '';
  for (const ch of L.chapters) for (const st of ch.steps) {
    if (st.code !== undefined) code = st.code.replace(/^\n/, '');
    if (st.run) {
      const r = MJ.runSync(code, st.input || []);
      if (r.error && !st.expectError) warn(`„${ch.title}“: Beispiel läuft nicht: ${r.error.text}`);
      if (!r.error && st.expectError) warn(`„${ch.title}“: Beispiel sollte einen Fehler zeigen, läuft aber`);
      if (withJava && !st.expectError) { const e = javacCheck(code); if (e) warn(`javac: ${e}`); }
    }
    const id = st.task ? st.task.id : st.quiz ? st.quiz.id : null;
    if (id) { if (ids.has(id)) warn(`ID ${id} doppelt`); ids.add(id); }
    if (st.task) checkTask(st.task, `Aufgabe ${st.task.id}`);
    if (st.quiz && (st.quiz.correct == null || !st.quiz.options[st.quiz.correct])) warn(`Quiz ${st.quiz.id}: richtige Antwort fehlt`);
  }
}
console.log(`Challenges: ${kurs.challenges.length}`);
for (const c of kurs.challenges) { if (ids.has(c.id)) warn(`ID ${c.id} doppelt`); ids.add(c.id); checkTask(c, `Challenge ${c.id}`); }
{ const r = MJ.runSync(kurs.playground, []); if (r.error) warn('Spielplatz-Code: ' + r.error.text); }

const course = { lessons, challenges: kurs.challenges, plan: kurs.plan, goal: kurs.goal, canDo: kurs.canDo, playground: kurs.playground };
const json = JSON.stringify(course).replace(/<\/script/gi, '<\\/script').split(String.fromCharCode(0x2028)).join('\\u2028').split(String.fromCharCode(0x2029)).join('\\u2029');
const noScriptEnd = s => s.replace(/<\/script/gi, '<\\/script');
const html = read('src/course.html')
  .replace('{{CSS}}', () => read('src/player.css') + '\n' + read('src/course.css'))
  .replace('{{MINIJAVA}}', () => noScriptEnd(read('src/minijava.js')))
  .replace('{{COURSE}}', () => json)
  .replace('{{COMMON}}', () => noScriptEnd(read('src/common.js')))
  .replace('{{PLAYER}}', () => noScriptEnd(read('src/player.js')))
  .replace('{{APP}}', () => noScriptEnd(read('src/course.js')));
mkdirSync(path.join(dir, 'dist'), { recursive: true });
writeFileSync(path.join(dir, 'dist', 'kurs.html'), html);
console.log(`→ dist/kurs.html (${(html.length / 1024).toFixed(0)} KB, ${lessons.length} Lektionen, ${kurs.challenges.length} Challenges)`);
console.log(problems ? `\n${problems} Problem(e) gefunden` : '\nAlles geprüft ✓');
process.exit(problems ? 1 : 0);
