// UI-Test einer gebauten Lektion im Browser (ohne claude-Capabilities -> Speicher im Browser, automatische Note).
//   node test/ui.mjs dist/lektion-01.html [out-dir]
import { createRequire } from 'node:module';
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import path from 'node:path';
const require = createRequire(import.meta.url);
const { chromium } = require('playwright');

const file = process.argv[2] || 'dist/lektion-01.html';
const out = process.argv[3] || '/tmp/claude-0/-home-user-Claude/050c17a6-3f65-563d-8ed3-c6340c15350e/scratchpad/ui';
mkdirSync(out, { recursive: true });
// wie beim Veröffentlichen: in ein Grundgerüst mit doctype einbetten
const body = readFileSync(file, 'utf8');
const wrapped = `<!doctype html><html><head><meta charset=utf-8><meta name=viewport content="width=device-width,initial-scale=1,viewport-fit=cover"><style>:root{color-scheme:light;padding-top:env(safe-area-inset-top);padding-bottom:env(safe-area-inset-bottom)}body{margin:0;font:14px system-ui}img{max-width:100%}[hidden]{display:none!important}</style></head><body>${body}</body></html>`;
const wf = path.join(out, 'page.html'); writeFileSync(wf, wrapped);

const browser = await chromium.launch();
const errors = [];
async function open(viewport) {
  const page = await browser.newPage({ viewport });
  page.on('pageerror', e => errors.push('pageerror: ' + e.message));
  page.on('console', m => { if (m.type() === 'error') errors.push('console: ' + m.text()); });
  await page.goto('file://' + wf);
  await page.waitForTimeout(600);
  return page;
}
const page = await open({ width: 1280, height: 900 });
const info = await page.evaluate(() => ({ total: window.__player.TOTAL, steps: window.__player.steps.length, gates: window.__player.steps.filter(s => s.quiz || s.task).map(s => ({ start: s.start, id: s.quiz ? s.quiz.id : s.task.id })) }));
console.log(`Dauer: ${(info.total / 60).toFixed(1)} min, ${info.steps} Schritte, Gates:`, info.gates.map(g => `${g.id}@${g.start.toFixed(0)}s`).join(', '));

// Szenen-Screenshots (Zeit relativ zum Gesamtvideo)
const shots = process.argv[4] ? process.argv[4].split(',').map(Number) : [0.02, 0.06, 0.12, 0.2, 0.26, 0.33, 0.4, 0.48, 0.55, 0.62];
for (const f of shots) {
  await page.evaluate(f => { const P = window.__player; P.state.quizzes = {}; for (const s of P.steps) if (s.quiz) P.state.quizzes[s.quiz.id] = { ok: true }; for (const s of P.steps) if (s.task) P.state.tasks[s.task.id] = { result: { note: 2, punkte: 80 }, code: '' }; P.player.seek(P.TOTAL * f + 1.5, true); }, f);
  await page.waitForTimeout(700);
  await (await page.$('#stage')).screenshot({ path: path.join(out, `scene-${String(Math.round(f * 100)).padStart(2, '0')}.png`) });
}
await page.close();

// Ablauf: Quiz + Aufgabe mit Sperre (frische Seite, frischer Speicher)
const p2 = await open({ width: 1280, height: 900 });
await p2.evaluate(() => localStorage.clear());
await p2.reload(); await p2.waitForTimeout(500);
const firstGate = info.gates[0];
await p2.evaluate(t => { const P = window.__player; P.player.seek(t - 0.5, true); P.player.play(); }, firstGate.start);
await p2.waitForTimeout(1500);
const quizVisible = await p2.$eval('.st-gate', el => !el.hidden && !!el.querySelector('.quiz-card'));
console.log('Quiz erscheint:', quizVisible);
await p2.click('.qopt[data-i="1"]');
await p2.waitForTimeout(300);
await (await p2.$('#stage')).screenshot({ path: path.join(out, 'quiz.png') });
await p2.click('[data-act="quiz-next"]');
const task = info.gates.find(g => g.id.includes('steckbrief')) || info.gates.find(g => !g.id.includes('-q'));
await p2.evaluate(t => { const P = window.__player; for (const s of P.steps) if (s.quiz) P.state.quizzes[s.quiz.id] = { ok: true }; P.player.pause(false); P.player.seek(t - 0.4, true); P.player.play(); }, task.start);
await p2.waitForTimeout(1500);
const locked = await p2.evaluate(() => ({ stage: document.querySelector('#stage').classList.contains('locked'), task: !document.querySelector('#task').hidden, seekDisabled: document.querySelector('#c-seek').disabled }));
console.log('Sperre aktiv:', JSON.stringify(locked));
await p2.screenshot({ path: path.join(out, 'locked.png'), fullPage: false });
// Neu laden: Sperre muss bleiben
await p2.reload(); await p2.waitForTimeout(800);
const stillLocked = await p2.evaluate(() => document.querySelector('#stage').classList.contains('locked') && !document.querySelector('#task').hidden);
console.log('Sperre nach Neuladen:', stillLocked);
// Code schreiben und ausführen
await p2.evaluate(() => { const ta = document.querySelector('#task .ce-ta'); ta.value = `public class Main {\n    public static void main(String[] args) {\n        // Steckbrief\n        System.out.println("== Ich ==");\n        System.out.println("Name:\\tMax");\n        System.out.print("Alter: ");\n        System.out.println(15);\n        System.out.println("Hobby: \\"Zocken\\"");\n    }\n}\n`; ta.dispatchEvent(new Event('input')); });
await p2.click('#task [data-act="run"]');
await p2.waitForTimeout(800);
const conText = await p2.$eval('#task .con-live', el => el.innerText);
console.log('Konsole:', JSON.stringify(conText.slice(0, 160)));
await p2.click('#task [data-act="submit"]');
await p2.click('#task [data-act="confirm"]');
await p2.waitForTimeout(12500);
const res = await p2.evaluate(() => ({ grade: document.querySelector('.gnum') && document.querySelector('.gnum').textContent, unlocked: !document.querySelector('#stage').classList.contains('locked'), avg: document.querySelector('#grade-avg').textContent }));
console.log('Ergebnis:', JSON.stringify(res));
await (await p2.$('#task')).screenshot({ path: path.join(out, 'result.png') });
await p2.close();

// Handy-Ansicht
const p3 = await open({ width: 390, height: 844 });
await p3.evaluate(() => { const P = window.__player; P.player.seek(P.TOTAL * 0.3, true); });
await p3.waitForTimeout(600);
await p3.screenshot({ path: path.join(out, 'mobile.png'), fullPage: false });
const overflow = await p3.evaluate(() => document.documentElement.scrollWidth > window.innerWidth + 1);
console.log('Handy: waagrechtes Scrollen?', overflow);
await browser.close();
console.log(errors.length ? 'FEHLER:\n' + errors.join('\n') : 'Keine JS-Fehler');
