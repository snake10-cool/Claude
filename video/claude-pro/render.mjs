// Rendert index.html Bild für Bild zu einer MP4 (inkl. Ton aus synth.py).
//   node render.mjs                 -> claude-pro.mp4
//   node render.mjs --stills 2,8,20 -> Standbilder zum Prüfen
import { createRequire } from 'node:module';
const { chromium } = createRequire(import.meta.url)('playwright');
import { spawn, execFileSync } from 'node:child_process';
import { writeFileSync, mkdirSync } from 'node:fs';
import { fileURLToPath, pathToFileURL } from 'node:url';
import path from 'node:path';

const dir = path.dirname(fileURLToPath(import.meta.url));
const FPS = 30;
const args = process.argv.slice(2);
const stillsArg = args.includes('--stills') ? args[args.indexOf('--stills') + 1] : null;

const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 1920, height: 1080 } });
await page.goto(pathToFileURL(path.join(dir, 'index.html')).href + '?render');
await page.evaluate(() => window.ready);
const { sfx, duration } = await page.evaluate(() => ({ sfx: window.SFX, duration: window.DURATION }));
const canvas = await page.$('canvas');
const shot = async (t) => { await page.evaluate((t) => window.draw(t), t); return canvas.screenshot({ type: 'png' }); };

if (stillsArg) {
  const out = path.join(dir, 'stills'); mkdirSync(out, { recursive: true });
  for (const t of stillsArg.split(',').map(Number)) writeFileSync(path.join(out, `t${t}.png`), await shot(t));
  await browser.close(); process.exit(0);
}

// 1) Ton erzeugen
writeFileSync(path.join(dir, 'sfx.json'), JSON.stringify({ duration, events: sfx }, null, 1));
execFileSync('python3', [path.join(dir, 'synth.py'), path.join(dir, 'sfx.json'), path.join(dir, 'audio.wav')], { stdio: 'inherit' });

// 2) Bilder an ffmpeg schicken
const ff = spawn('ffmpeg', ['-y', '-loglevel', 'error', '-f', 'image2pipe', '-framerate', String(FPS), '-i', '-',
  '-i', path.join(dir, 'audio.wav'), '-c:v', 'libx264', '-preset', 'slow', '-crf', '20', '-pix_fmt', 'yuv420p',
  '-c:a', 'aac', '-b:a', '192k', '-shortest', '-movflags', '+faststart', path.join(dir, 'claude-pro.mp4')], { stdio: ['pipe', 'inherit', 'inherit'] });
const frames = Math.round(duration * FPS);
for (let i = 0; i < frames; i++) {
  const buf = await shot(i / FPS);
  if (!ff.stdin.write(buf)) await new Promise((r) => ff.stdin.once('drain', r));
  if (i % 150 === 0) console.log(`Bild ${i}/${frames}`);
}
ff.stdin.end();
await new Promise((r) => ff.on('close', r));
await browser.close();
console.log('Fertig: claude-pro.mp4');
