// Rendert die lange Version.
//   node render.mjs                     -> claude-pro-lang.mp4
//   node render.mjs --stills 10,40,90   -> Standbilder in stills/
//   node render.mjs --script            -> nur sprechertext.md neu schreiben
// Sprecherstimme: Liegen Dateien in sprecher/ (01.mp3, 02.mp3 … wie in sprechertext.md),
// werden sie eingebaut und das Timing richtet sich nach ihrer Länge. Sonst: Untertitel ohne Stimme.
import { createRequire } from 'node:module';
import { spawn, execFileSync } from 'node:child_process';
import { writeFileSync, mkdirSync, existsSync, readdirSync, rmSync } from 'node:fs';
import { fileURLToPath, pathToFileURL } from 'node:url';
import os from 'node:os';
import path from 'node:path';
const { chromium } = createRequire(import.meta.url)('playwright');

const dir = path.dirname(fileURLToPath(import.meta.url));
const FPS = 30;
const args = process.argv.slice(2);
const opt = (k) => (args.includes(k) ? args[args.indexOf(k) + 1] : null);
const WORKERS = Number(opt('--workers')) || Math.max(1, os.cpus().length);

const browser = await chromium.launch();
async function openPage() {
  const page = await browser.newPage({ viewport: { width: 1920, height: 1080 } });
  await page.goto(pathToFileURL(path.join(dir, 'index.html')).href + '?render');
  await page.evaluate(() => window.ready);
  return page;
}
const page = await openPage();
const texts = await page.evaluate(() => window.voiceTexts());

// Sprechertext-Liste für eine externe Stimm-KI
const pad2 = (i) => String(i + 1).padStart(2, '0');
writeFileSync(path.join(dir, 'sprechertext.md'),
  '# Sprechertexte\n\nJeden Satz einzeln vertonen und als `sprecher/NN.mp3` (oder .wav) speichern, z. B. `sprecher/01.mp3`.\n' +
  'Danach `node render.mjs` ausführen (oder Claude Bescheid geben): Das Video passt sich automatisch an die Länge der Dateien an.\n\n' +
  `Insgesamt ${texts.length} Sätze, ${texts.reduce((a, t) => a + t.text.length, 0)} Zeichen.\n\n` +
  texts.map((t, i) => `**${pad2(i)}** ${t.text}`).join('\n\n') + '\n');
if (args.includes('--script')) { await browser.close(); process.exit(0); }

// Stimme suchen
const durs = {};
const vdir = path.join(dir, 'sprecher');
if (existsSync(vdir)) {
  const files = readdirSync(vdir);
  texts.forEach((t, i) => {
    const f = files.find((n) => n.startsWith(pad2(i) + '.'));
    if (!f) return;
    const file = path.join(vdir, f);
    const dur = Number(execFileSync('ffprobe', ['-v', 'error', '-show_entries', 'format=duration', '-of', 'csv=p=0', file]).toString());
    durs[t.id] = { file, dur };
  });
  console.log(`Sprecher: ${Object.keys(durs).length}/${texts.length} Dateien gefunden`);
}
const tl = await page.evaluate((d) => window.build(d), durs);
console.log(`Länge: ${Math.floor(tl.end / 60)}:${String(Math.round(tl.end % 60)).padStart(2, '0')} min, ${tl.scenes.length} Szenen`);

const canvas = await page.$('canvas');
const shot = async (pg, cv, t, type = 'jpeg') => { await pg.evaluate((t) => window.draw(t), t); return cv.screenshot(type === 'png' ? { type } : { type, quality: 92 }); };

const stills = opt('--stills');
if (stills) {
  const out = path.join(dir, 'stills'); mkdirSync(out, { recursive: true });
  for (const t of stills.split(',').map(Number)) writeFileSync(path.join(out, `t${t}.png`), await shot(page, canvas, t, 'png'));
  await browser.close(); process.exit(0);
}

// Ton
writeFileSync(path.join(dir, 'timeline.json'), JSON.stringify(tl, null, 1));
execFileSync('python3', [path.join(dir, 'synth.py'), path.join(dir, 'timeline.json'), path.join(dir, 'audio.wav')], { stdio: 'inherit' });

// Bilder parallel rendern: jeder Worker macht ein Stück und kodiert es selbst
const frames = Math.round(tl.end * FPS);
const segDir = path.join(dir, 'segments'); rmSync(segDir, { recursive: true, force: true }); mkdirSync(segDir);
const per = Math.ceil(frames / WORKERS);
let done = 0; const t0 = Date.now();
await Promise.all(Array.from({ length: WORKERS }, async (_, w) => {
  const from = w * per, to = Math.min(frames, from + per); if (from >= to) return;
  const pg = w === 0 ? page : await openPage();
  await pg.evaluate((d) => window.build(d), durs);
  const cv = await pg.$('canvas');
  const ff = spawn('ffmpeg', ['-y', '-loglevel', 'error', '-f', 'image2pipe', '-framerate', String(FPS), '-i', '-',
    '-c:v', 'libx264', '-preset', 'veryfast', '-crf', '20', '-pix_fmt', 'yuv420p', path.join(segDir, `seg${w}.mp4`)], { stdio: ['pipe', 'inherit', 'inherit'] });
  for (let i = from; i < to; i++) {
    const buf = await shot(pg, cv, i / FPS);
    if (!ff.stdin.write(buf)) await new Promise((r) => ff.stdin.once('drain', r));
    if (++done % 600 === 0) console.log(`Bild ${done}/${frames} (${Math.round((Date.now() - t0) / 1000)} s)`);
  }
  ff.stdin.end(); await new Promise((r) => ff.on('close', r));
}));
await browser.close();

const list = path.join(segDir, 'list.txt');
writeFileSync(list, Array.from({ length: WORKERS }, (_, w) => `file 'seg${w}.mp4'`).filter((_, w) => existsSync(path.join(segDir, `seg${w}.mp4`))).join('\n'));
execFileSync('ffmpeg', ['-y', '-loglevel', 'error', '-f', 'concat', '-safe', '0', '-i', list, '-i', path.join(dir, 'audio.wav'),
  '-map', '0:v', '-map', '1:a', '-c:v', 'copy', '-c:a', 'aac', '-b:a', '192k', '-shortest', '-movflags', '+faststart', path.join(dir, 'claude-pro-lang.mp4')], { stdio: 'inherit' });
console.log(`Fertig: claude-pro-lang.mp4 (${Math.round((Date.now() - t0) / 1000)} s)`);
