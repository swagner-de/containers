import { createServer } from 'node:http';
import { readFile } from 'node:fs/promises';
import { existsSync } from 'node:fs';
import { extname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT        = join(fileURLToPath(import.meta.url), '..', 'public');
const CONFIG_PATH = existsSync('/config/config.json')
  ? '/config/config.json'
  : join(fileURLToPath(import.meta.url), '..', 'config.json');
const PORT = process.env.PORT || 8080;

const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.js':   'application/javascript',
  '.json': 'application/json',
  '.css':  'text/css',
  '.ico':  'image/x-icon',
};

// Pre-allocate a 256 MB pool of random bytes; sliced per request.
const RANDOM_POOL = (() => {
  const buf = Buffer.allocUnsafe(256 * 1024 * 1024);
  for (let i = 0; i < buf.length; i += 4) buf.writeUInt32LE((Math.random() * 0xffffffff) >>> 0, i);
  return buf;
})();

function handleDown(req, res) {
  const bytes = Math.min(Math.max(parseInt(new URL(req.url, 'http://x').searchParams.get('bytes') || '0'), 0), RANDOM_POOL.length);
  res.writeHead(200, {
    'Content-Type': 'application/octet-stream',
    'Content-Length': bytes,
    'Cache-Control': 'no-store',
    'Access-Control-Allow-Origin': '*',
  });
  res.end(RANDOM_POOL.slice(0, bytes));
}

function handleUp(req, res) {
  const start = Date.now();
  req.resume();
  req.on('end', () => {
    res.writeHead(200, {
      'Content-Type': 'text/plain',
      'Access-Control-Allow-Origin': '*',
      'Server-Timing': `cfRequestDuration;dur=${Date.now() - start}`,
    });
    res.end('ok');
  });
}

createServer(async (req, res) => {
  if (req.method === 'OPTIONS') {
    res.writeHead(204, { 'Access-Control-Allow-Origin': '*', 'Access-Control-Allow-Methods': 'GET, POST', 'Access-Control-Allow-Headers': '*' });
    res.end();
    return;
  }

  const pathname = req.url.split('?')[0];

  if (pathname === '/__down' && req.method === 'GET')  { handleDown(req, res); return; }
  if (pathname === '/__up'   && req.method === 'POST') { handleUp(req, res);   return; }

  // config.json is served from the mount path, not from public/
  if (pathname === '/config.json') {
    try {
      const data = await readFile(CONFIG_PATH);
      res.writeHead(200, { 'Content-Type': 'application/json', 'Cache-Control': 'no-store' });
      res.end(data);
    } catch {
      res.writeHead(404); res.end('config.json not found');
    }
    return;
  }

  const file = join(ROOT, pathname === '/' ? '/index.html' : pathname);
  try {
    const data = await readFile(file);
    res.writeHead(200, { 'Content-Type': MIME[extname(file)] || 'application/octet-stream' });
    res.end(data);
  } catch {
    res.writeHead(404);
    res.end('Not found');
  }
}).listen(PORT, () => console.log(`Listening on http://0.0.0.0:${PORT}`));
