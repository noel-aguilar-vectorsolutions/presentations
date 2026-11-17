// Export an archify diagram HTML to light and dark SVG, by clicking the viewer's own
// export menu (SVG · Light, SVG · Dark) in headless Chrome over the DevTools protocol.
// Usage: node export-svg.mjs <diagram.html> <out-dir> <basename>
//   writes <out-dir>/<basename>-light.svg and <out-dir>/<basename>-dark.svg
import { spawn } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { pathToFileURL } from 'node:url';

const [htmlArg, outDirArg, base] = process.argv.slice(2);
if (!htmlArg || !outDirArg || !base) {
  console.error('Usage: node export-svg.mjs <diagram.html> <out-dir> <basename>');
  process.exit(1);
}
const html = path.resolve(htmlArg);
const outDir = path.resolve(outDirArg);
fs.mkdirSync(outDir, { recursive: true });
const dl = fs.mkdtempSync(path.join(os.tmpdir(), 'archify-dl-'));
const profile = fs.mkdtempSync(path.join(os.tmpdir(), 'archify-prof-'));
const chrome = process.env.CHROME || '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';
const port = 9300 + Math.floor(Math.random() * 500);

const proc = spawn(chrome, [
  '--headless=new', '--disable-gpu', `--remote-debugging-port=${port}`,
  `--user-data-dir=${profile}`, '--window-size=1600,1000', 'about:blank',
], { stdio: 'ignore' });

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
async function json(url) {
  for (let i = 0; i < 100; i++) {
    try { const r = await fetch(url); if (r.ok) return await r.json(); } catch {}
    await sleep(100);
  }
  throw new Error('Chrome did not start');
}

let ws; let id = 0; const pending = new Map();
function send(method, params = {}, sessionId) {
  return new Promise((resolve, reject) => {
    const msg = { id: ++id, method, params };
    if (sessionId) msg.sessionId = sessionId;
    pending.set(msg.id, { resolve, reject });
    ws.send(JSON.stringify(msg));
  });
}

try {
  const ver = await json(`http://127.0.0.1:${port}/json/version`);
  ws = new WebSocket(ver.webSocketDebuggerUrl);
  await new Promise((r, j) => { ws.onopen = r; ws.onerror = j; });
  ws.onmessage = (ev) => {
    const m = JSON.parse(ev.data);
    if (m.id && pending.has(m.id)) {
      const p = pending.get(m.id); pending.delete(m.id);
      m.error ? p.reject(new Error(JSON.stringify(m.error))) : p.resolve(m.result);
    }
  };
  await send('Browser.setDownloadBehavior', { behavior: 'allow', downloadPath: dl, eventsEnabled: true });
  const { targetId } = await send('Target.createTarget', { url: 'about:blank' });
  const { sessionId } = await send('Target.attachToTarget', { targetId, flatten: true });
  await send('Page.enable', {}, sessionId);
  await send('Page.navigate', { url: pathToFileURL(html).href }, sessionId);
  await sleep(2500);

  for (const theme of ['light', 'dark']) {
    const before = new Set(fs.readdirSync(dl));
    const r = await send('Runtime.evaluate', {
      expression: `(() => { const b = document.querySelector('button[data-format="svg-${theme}"]'); if (!b) return 'missing'; b.click(); return 'ok'; })()`,
      returnByValue: true,
    }, sessionId);
    if (r.result.value !== 'ok') throw new Error(`export button svg-${theme}: ${r.result.value}`);
    let file;
    for (let i = 0; i < 100 && !file; i++) {
      await sleep(100);
      file = fs.readdirSync(dl).find((f) => !before.has(f) && f.endsWith('.svg'));
    }
    if (!file) throw new Error(`no SVG downloaded for ${theme}`);
    await sleep(200);
    const target = path.join(outDir, `${base}-${theme}.svg`);
    // Transparent background (the slide shows through): drop the canvas fill and the grid.
    let svg = fs.readFileSync(path.join(dl, file), 'utf8');
    svg = svg.replace(/<rect x="0" y="0" width="[\d.]+" height="[\d.]+" fill="#[0-9a-fA-F]{3,8}"\/>/, '')
      .replace(/<rect width="100%" height="100%" fill="url\(#grid\)"\/>/, '')
      // JetBrains Mono's code ligatures join "<app>-site" into "<app>—site" on a slide: turn them off.
      .replace(/<\/svg>\s*$/, '<style>text, tspan { font-variant-ligatures: none; font-feature-settings: "calt" 0, "liga" 0; }</style></svg>\n');
    fs.writeFileSync(target, svg);
    // Crop the canvas to the drawn content, plus a margin.
    await send('Page.navigate', { url: pathToFileURL(target).href }, sessionId);
    await sleep(800);
    const bb = await send('Runtime.evaluate', {
      expression: `(() => { const b = document.documentElement.getBBox(); return [b.x, b.y, b.width, b.height]; })()`,
      returnByValue: true,
    }, sessionId);
    const [x, y, w, h] = bb.result.value;
    const m = 10;
    const vb = [Math.floor(x - m), Math.floor(y - m), Math.ceil(w + 2 * m), Math.ceil(h + 2 * m)];
    svg = svg.replace(/<svg([^>]*?) viewBox="[^"]*"/, `<svg$1 viewBox="${vb.join(' ')}"`)
      .replace(/(<svg[^>]*?) width="[\d.]+" height="[\d.]+"/, `$1 width="${vb[2]}" height="${vb[3]}"`)
      .replace(/(<svg[^>]*?style="[^"]*?)width: [\d.]+px; height: [\d.]+px;/, `$1width: ${vb[2]}px; height: ${vb[3]}px;`);
    fs.writeFileSync(target, svg);
    console.log(`${target} ${fs.statSync(target).size} bytes, viewBox ${vb.join(' ')}`);
    await send('Page.navigate', { url: pathToFileURL(html).href }, sessionId);
    await sleep(2500);
  }
} finally {
  try { ws && ws.close(); } catch {}
  proc.kill();
  fs.rmSync(dl, { recursive: true, force: true });
  setTimeout(() => fs.rmSync(profile, { recursive: true, force: true }), 500);
}
