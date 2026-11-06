// Rendert das Hype-Edit.   node render.mjs   |   node render.mjs --stills 3,10,30
import { createRequire } from 'node:module';
import { spawn, execFileSync } from 'node:child_process';
import { writeFileSync, mkdirSync, existsSync, rmSync } from 'node:fs';
import { fileURLToPath, pathToFileURL } from 'node:url';
import os from 'node:os';
import path from 'node:path';
const { chromium } = createRequire(import.meta.url)('playwright');

const dir = path.dirname(fileURLToPath(import.meta.url));
const FPS = 30, args = process.argv.slice(2), WORKERS = os.cpus().length;
const browser = await chromium.launch();
async function openPage() {
  const page = await browser.newPage({ viewport: { width: 1920, height: 1080 } });
  page.on('pageerror', (e) => console.log('Seitenfehler:', e.message));
  await page.goto(pathToFileURL(path.join(dir, 'index.html')).href + '?render');
  await page.evaluate(() => window.ready);
  return page;
}
const page = await openPage();
const tl = await page.evaluate(() => window.timeline());
tl.voice.forEach((v) => { v.file = path.resolve(dir, v.file); });
const durs = tl.voice.map((v) => Number(execFileSync('ffprobe', ['-v', 'error', '-show_entries', 'format=duration', '-of', 'csv=p=0', v.file]).toString()) - .15);
const shot = async (pg, t, type = 'jpeg') => { await pg.evaluate((t) => window.draw(t), t); return (await pg.$('canvas')).screenshot(type === 'png' ? { type } : { type, quality: 92 }); };

const stills = args.includes('--stills') ? args[args.indexOf('--stills') + 1] : null;
if (stills) {
  await page.evaluate((d) => window.setVoiceDurs(d), durs);
  mkdirSync(path.join(dir, 'stills'), { recursive: true });
  for (const t of stills.split(',').map(Number)) writeFileSync(path.join(dir, 'stills', `t${t}.png`), await shot(page, t, 'png'));
  await browser.close(); process.exit(0);
}
writeFileSync(path.join(dir, 'timeline.json'), JSON.stringify(tl));
execFileSync('python3', [path.join(dir, 'synth.py'), path.join(dir, 'timeline.json'), path.join(dir, 'audio.wav')], { stdio: 'inherit' });

const frames = Math.round(tl.end * FPS), per = Math.ceil(frames / WORKERS);
const seg = path.join(dir, 'segments'); rmSync(seg, { recursive: true, force: true }); mkdirSync(seg);
let done = 0; const t0 = Date.now();
await Promise.all(Array.from({ length: WORKERS }, async (_, w) => {
  const from = w * per, to = Math.min(frames, from + per); if (from >= to) return;
  const pg = w === 0 ? page : await openPage();
  await pg.evaluate((d) => window.setVoiceDurs(d), durs);
  const ff = spawn('ffmpeg', ['-y', '-loglevel', 'error', '-f', 'image2pipe', '-framerate', String(FPS), '-i', '-', '-c:v', 'libx264', '-preset', 'medium', '-crf', '21', '-pix_fmt', 'yuv420p', path.join(seg, `seg${w}.mp4`)], { stdio: ['pipe', 'inherit', 'inherit'] });
  for (let i = from; i < to; i++) {
    const buf = await shot(pg, i / FPS);
    if (!ff.stdin.write(buf)) await new Promise((r) => ff.stdin.once('drain', r));
    if (++done % 500 === 0) console.log(`Bild ${done}/${frames}`);
  }
  ff.stdin.end(); await new Promise((r) => ff.on('close', r));
}));
await browser.close();
const list = path.join(seg, 'list.txt');
writeFileSync(list, Array.from({ length: WORKERS }, (_, w) => `seg${w}.mp4`).filter((f) => existsSync(path.join(seg, f))).map((f) => `file '${f}'`).join('\n'));
execFileSync('ffmpeg', ['-y', '-loglevel', 'error', '-f', 'concat', '-safe', '0', '-i', list, '-i', path.join(dir, 'audio.wav'), '-map', '0:v', '-map', '1:a', '-c:v', 'copy', '-c:a', 'aac', '-b:a', '192k', '-shortest', '-movflags', '+faststart', path.join(dir, 'claude-pro-hype.mp4')], { stdio: 'inherit' });
console.log(`Fertig: claude-pro-hype.mp4 (${Math.round((Date.now() - t0) / 1000)} s)`);
