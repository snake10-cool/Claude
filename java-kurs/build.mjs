// Baut die Lektionsseiten:  node build.mjs   ->  dist/lektion-01.html …
// Prüft dabei: jedes Code-Beispiel im Video läuft (oder zeigt absichtlich einen Fehler),
// jede Musterlösung besteht ihre eigenen Tests, und optional (--java) dass sie auch mit echtem javac kompiliert.
import { readFileSync, writeFileSync, mkdirSync, readdirSync, existsSync, mkdtempSync, rmSync } from 'node:fs';
import { createRequire } from 'node:module';
import { execFileSync } from 'node:child_process';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
const dir = path.dirname(fileURLToPath(import.meta.url));
const require = createRequire(import.meta.url);
const MJ = require('./src/minijava.js');
const withJava = process.argv.includes('--java');

const files = readdirSync(path.join(dir, 'lessons')).filter(f => /^l\d+\.mjs$/.test(f)).sort();
const links = existsSync(path.join(dir, 'links.json')) ? JSON.parse(readFileSync(path.join(dir, 'links.json'), 'utf8')) : {};
const tpl = readFileSync(path.join(dir, 'src/page.html'), 'utf8');
const css = readFileSync(path.join(dir, 'src/player.css'), 'utf8');
const mj = readFileSync(path.join(dir, 'src/minijava.js'), 'utf8');
const player = readFileSync(path.join(dir, 'src/player.js'), 'utf8');
mkdirSync(path.join(dir, 'dist'), { recursive: true });

const lessons = [];
for (const f of files) lessons.push((await import(pathToFileURL(path.join(dir, 'lessons', f)).href + '?t=' + Date.now())).default);
const COUNT = Number(links.count || lessons.length);
let problems = 0;
const warn = (msg) => { problems++; console.log('  ⚠ ' + msg); };

function javacCheck(src, label) {
  const d = mkdtempSync(path.join(tmpdir(), 'jk-'));
  try { writeFileSync(path.join(d, 'Main.java'), src); execFileSync('javac', ['-encoding', 'UTF-8', 'Main.java'], { cwd: d, stdio: ['ignore', 'pipe', 'pipe'] }); return null; }
  catch (e) { return (e.stderr || '').toString().split('\n').slice(0, 3).join(' | '); }
  finally { rmSync(d, { recursive: true, force: true }); }
}

for (const [i, L] of lessons.entries()) {
  console.log(`Lektion ${L.nr}: ${L.title}`);
  // 1) Video-Code prüfen
  let code = '', est = 0, nTasks = 0, nQuiz = 0;
  for (const ch of L.chapters) for (const st of ch.steps) {
    if (st.code !== undefined) code = st.code.replace(/^\n/, '');
    if (st.run) {
      const r = MJ.runSync(code, st.input || []);
      if (r.error && !st.expectError) warn(`Kapitel „${ch.title}“: Beispiel läuft nicht: ${r.error.text}`);
      if (!r.error && st.expectError) warn(`Kapitel „${ch.title}“: Beispiel sollte einen Fehler zeigen, läuft aber`);
      if (withJava && !st.expectError) { const e = javacCheck(code); if (e) warn(`javac: ${e}`); }
    }
    if (st.task) {
      nTasks++;
      const t = st.task;
      for (const k of ['id', 'title', 'text', 'req', 'starter', 'solution', 'rubric']) if (!t[k]) warn(`Aufgabe ${t.id}: ${k} fehlt`);
      const sum = t.rubric.reduce((a, r) => a + r[1], 0); if (sum !== 100) warn(`Aufgabe ${t.id}: Punkte ergeben ${sum}, nicht 100`);
      for (const test of t.tests || []) {
        const r = MJ.runSync(t.solution, test.input || []);
        if (r.error) warn(`Aufgabe ${t.id}: Musterlösung scheitert in Test „${test.name}“: ${r.error.text}`);
        for (const c of test.expect || []) { const ok = c.re ? new RegExp(c.re, c.flags || 'i').test(r.output) : r.output.toLowerCase().includes(String(c.has).toLowerCase()); if (!ok) warn(`Aufgabe ${t.id}: Musterlösung erfüllt „${c.label || c.has || c.re}“ nicht (Test ${test.name})`); }
      }
      for (const c of t.codeChecks || []) if (!new RegExp(c.re, c.flags || '').test(t.solution)) warn(`Aufgabe ${t.id}: Musterlösung erfüllt Code-Prüfung „${c.label}“ nicht`);
      const starterRun = MJ.runSync(t.starter, (t.tests && t.tests[0] && t.tests[0].input) || []);
      if (starterRun.error && starterRun.error.kind === 'compile') warn(`Aufgabe ${t.id}: Startcode kompiliert nicht: ${starterRun.error.text}`);
      if (withJava) { const e = javacCheck(t.solution); if (e) warn(`Aufgabe ${t.id}: Musterlösung – javac: ${e}`); }
    }
    if (st.quiz) { nQuiz++; if (st.quiz.correct == null || !st.quiz.options[st.quiz.correct]) warn(`Quiz ${st.quiz.id}: richtige Antwort fehlt`); }
    // grobe Dauer (die echte rechnet der Player)
    est += Math.max(st.say ? 1.6 + st.say.length / 15 : 0, st.t ? 3.2 : 0, 1.2) + (st.wait || 0);
  }
  if (L.playground) { const r = MJ.runSync(L.playground, ['17']); if (r.error && r.error.kind === 'compile') warn('Spielplatz-Code kompiliert nicht: ' + r.error.text); }
  // 2) Seite bauen
  const next = lessons[i + 1] ? links[lessons[i + 1].id] : null;
  const data = Object.assign({}, L, { next: next || null, count: COUNT });
  const json = JSON.stringify(data).replace(/<\/script/gi, '<\\/script').split(String.fromCharCode(0x2028)).join('\\u2028').split(String.fromCharCode(0x2029)).join('\\u2029');
  const courseLink = links.course ? `<a href="${links.course}" target="_blank" rel="noopener">☕ Java-Kurs</a>` : '<span class="brand">☕ Java-Kurs</span>';
  const html = tpl
    .replace('{{PAGETITLE}}', `Java ${L.nr}: ${L.title}`)
    .replace('{{COURSELINK}}', courseLink)
    .replace('{{NR}}', L.nr).replace('{{COUNT}}', COUNT)
    .replace('{{TITLE}}', L.title).replace('{{SUB}}', L.sub)
    .replace('{{MIN}}', Math.round(est / 60))
    .replace('{{NTASKS}}', nTasks === 1 ? '1 Aufgabe mit Note' : `${nTasks} Aufgaben mit Note`)
    .replace('{{NQUIZ}}', nQuiz === 1 ? '1 Kurz-Check' : `${nQuiz} Kurz-Checks`)
    .replace('{{CSS}}', () => css).replace('{{MINIJAVA}}', () => mj.replace(/<\/script/gi, '<\\/script')).replace('{{LESSON}}', () => json).replace('{{PLAYER}}', () => player.replace(/<\/script/gi, '<\\/script'));
  const out = path.join(dir, 'dist', `lektion-${String(L.nr).padStart(2, '0')}.html`);
  writeFileSync(out, html);
  console.log(`  → ${path.relative(dir, out)} (${(html.length / 1024).toFixed(0)} KB, ca. ${Math.round(est / 60)} min, ${nTasks} Aufgaben, ${nQuiz} Quiz)`);
}
console.log(problems ? `\n${problems} Problem(e) gefunden` : '\nAlles geprüft ✓');
process.exit(problems ? 1 : 0);
