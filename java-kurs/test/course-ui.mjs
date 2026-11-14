// Browser-Test der Kursseite (ohne claude-Capabilities -> Speicher im Browser, automatische Note).
//   node test/course-ui.mjs [out-dir]
import { createRequire } from 'node:module';
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import path from 'node:path';
const require = createRequire(import.meta.url);
const { chromium } = require('playwright');
const out = process.argv[2] || '/tmp/claude-0/-home-user-Claude/050c17a6-3f65-563d-8ed3-c6340c15350e/scratchpad/course';
mkdirSync(out, { recursive: true });
const body = readFileSync('dist/kurs.html', 'utf8');
const wf = path.join(out, 'page.html');
writeFileSync(wf, `<!doctype html><html><head><meta charset=utf-8><meta name=viewport content="width=device-width,initial-scale=1,viewport-fit=cover"><style>:root{color-scheme:light}body{margin:0;font:14px system-ui}[hidden]{display:none!important}</style></head><body>${body}</body></html>`);
const browser = await chromium.launch();
const errors = [];
const ok = (label, cond) => console.log(`${cond ? '✓' : '✗'} ${label}`);
async function open(vp, hash = '') {
  const p = await browser.newPage({ viewport: vp });
  p.on('pageerror', e => errors.push('pageerror: ' + e.message));
  p.on('console', m => { if (m.type() === 'error') errors.push('console: ' + m.text()); });
  await p.goto('file://' + wf + hash); await p.waitForTimeout(500);
  return p;
}
const p = await open({ width: 1280, height: 900 });
await p.evaluate(() => localStorage.clear()); await p.reload(); await p.waitForTimeout(500);
await p.screenshot({ path: path.join(out, 'home.png'), fullPage: true });
ok('Startseite zeigt 5 Lektionen + Challenges + geplante', await p.evaluate(() => document.querySelectorAll('.path .lesson').length === 5 + 1 + 7));
// Lektion 1 -> Aufgabe öffnen
await p.evaluate(() => { location.hash = '#lektion-1'; }); await p.waitForTimeout(500);
const gate = await p.evaluate(() => { const A = window.JK.active; const st = A.steps.find(s => s.task); for (const s of A.steps) if (s.quiz && s.start < st.start) window.JK.course.S.quizzes[s.quiz.id] = { ok: true }; A.player.seek(st.start - 0.3, true); A.player.play(); return st.task.id; });
await p.waitForTimeout(1500);
ok('Aufgabe öffnet sich und sperrt Lektion 1', await p.evaluate(() => document.querySelector('#stage').classList.contains('locked') && !document.querySelector('#task').hidden));
await p.evaluate(() => { location.hash = '#lektion-3'; }); await p.waitForTimeout(500);
ok('Auch Lektion 3 ist gesperrt (kursweit)', await p.evaluate(() => document.querySelector('#stage').classList.contains('locked') && /Lektion 1/.test(document.querySelector('.lock-txt').textContent)));
await (await p.$('#stage')).screenshot({ path: path.join(out, 'locked-other.png') });
await p.evaluate(() => { location.hash = '#start'; }); await p.waitForTimeout(300);
ok('Sperr-Leiste auf der Startseite', await p.evaluate(() => !document.querySelector('#lockbar').hidden));
await p.reload(); await p.waitForTimeout(600);
ok('Sperre bleibt nach Neuladen', await p.evaluate(() => !document.querySelector('#lockbar').hidden && !!window.JK.course.S.openTask));
// abgeben
await p.evaluate(() => { location.hash = '#lektion-1'; }); await p.waitForTimeout(600);
await p.evaluate(() => { const ta = document.querySelector('#task .ce-ta'); ta.value = 'public class Main {\n    public static void main(String[] args) {\n        // Steckbrief\n        System.out.println("== Ich ==");\n        System.out.println("Name:\\tMax");\n        System.out.print("Alter: ");\n        System.out.println(15);\n        System.out.println("Hobby: \\"Zocken\\"");\n    }\n}\n'; ta.dispatchEvent(new Event('input')); });
await p.click('#task [data-act="submit"]'); await p.click('#task [data-act="confirm"]');
await p.waitForTimeout(12000);
ok('Note da und Sperre aufgehoben', await p.evaluate(() => !!document.querySelector('.gnum') && !window.JK.course.S.openTask && !document.querySelector('#stage').classList.contains('locked')));
// Challenge
await p.evaluate(() => { location.hash = '#challenge-c3'; }); await p.waitForTimeout(500);
await p.evaluate(() => { const ta = document.querySelector('#task .ce-ta'); ta.value = 'import java.util.Scanner;\n\npublic class Main {\n    public static void main(String[] args) {\n        Scanner sc = new Scanner(System.in);\n        int n = sc.nextInt();\n        int s = 0;\n        while (n > 0) { s += n % 10; n /= 10; }\n        System.out.println("Quersumme: " + s);\n    }\n}\n'; ta.dispatchEvent(new Event('input')); });
await p.screenshot({ path: path.join(out, 'challenge.png'), fullPage: true });
await p.click('#task [data-act="submit"]'); await p.click('#task [data-act="confirm"]');
await p.waitForTimeout(12000);
ok('Challenge benotet', await p.evaluate(() => !!document.querySelector('.gnum')));
await p.evaluate(() => { location.hash = '#noten'; }); await p.waitForTimeout(500);
const gb = await p.evaluate(() => ({ rows: document.querySelectorAll('.grow-row').length, graded: document.querySelectorAll('.grow-row:not([data-empty])').length, avg: document.querySelector('.stat.accent b').textContent }));
ok(`Notenbuch: ${gb.rows} Zeilen, ${gb.graded} benotet, Schnitt ${gb.avg}`, gb.rows === 16 && gb.graded === 2);
await p.screenshot({ path: path.join(out, 'noten.png'), fullPage: true });
await p.evaluate(() => { location.hash = '#challenges'; }); await p.waitForTimeout(400);
await p.screenshot({ path: path.join(out, 'challenges.png'), fullPage: true });
await p.close();
// Handy
const m = await open({ width: 390, height: 844 }, '#start');
await m.screenshot({ path: path.join(out, 'mobile-home.png') });
ok('Handy: kein waagrechtes Scrollen (Start)', await m.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth + 1));
await m.evaluate(() => { location.hash = '#lektion-2'; }); await m.waitForTimeout(500);
ok('Handy: kein waagrechtes Scrollen (Lektion)', await m.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth + 1));
await m.screenshot({ path: path.join(out, 'mobile-lesson.png') });
await browser.close();
console.log(errors.length ? 'FEHLER:\n' + errors.join('\n') : 'Keine JS-Fehler');
