// Dependency-free PNG writer + a tiny 5x7 bitmap font (uppercase only).
import zlib from 'node:zlib';

const F = {
  'A': ['01110','10001','10001','11111','10001','10001','10001'],
  'B': ['11110','10001','11110','10001','10001','10001','11110'],
  'C': ['01111','10000','10000','10000','10000','10000','01111'],
  'D': ['11110','10001','10001','10001','10001','10001','11110'],
  'E': ['11111','10000','11110','10000','10000','10000','11111'],
  'F': ['11111','10000','11110','10000','10000','10000','10000'],
  'G': ['01111','10000','10000','10111','10001','10001','01111'],
  'H': ['10001','10001','11111','10001','10001','10001','10001'],
  'I': ['11111','00100','00100','00100','00100','00100','11111'],
  'J': ['00111','00010','00010','00010','00010','10010','01100'],
  'K': ['10001','10010','10100','11000','10100','10010','10001'],
  'L': ['10000','10000','10000','10000','10000','10000','11111'],
  'M': ['10001','11011','10101','10101','10001','10001','10001'],
  'N': ['10001','11001','10101','10011','10001','10001','10001'],
  'O': ['01110','10001','10001','10001','10001','10001','01110'],
  'P': ['11110','10001','11110','10000','10000','10000','10000'],
  'Q': ['01110','10001','10001','10001','10101','10010','01101'],
  'R': ['11110','10001','11110','10100','10010','10001','10001'],
  'S': ['01111','10000','10000','01110','00001','00001','11110'],
  'T': ['11111','00100','00100','00100','00100','00100','00100'],
  'U': ['10001','10001','10001','10001','10001','10001','01110'],
  'V': ['10001','10001','10001','10001','10001','01010','00100'],
  'W': ['10001','10001','10001','10101','10101','11011','10001'],
  'X': ['10001','10001','01010','00100','01010','10001','10001'],
  'Y': ['10001','10001','01010','00100','00100','00100','00100'],
  'Z': ['11111','00001','00010','00100','01000','10000','11111'],
  '0': ['01110','10011','10101','10101','11001','10001','01110'],
  '1': ['00100','01100','00100','00100','00100','00100','01110'],
  '2': ['01110','10001','00001','00110','01000','10000','11111'],
  '3': ['11111','00010','00100','00010','00001','10001','01110'],
  '4': ['00110','01010','10010','11111','00010','00010','00010'],
  '5': ['11111','10000','11110','00001','00001','10001','01110'],
  '6': ['00110','01000','10000','11110','10001','10001','01110'],
  '7': ['11111','00001','00010','00100','01000','01000','01000'],
  '8': ['01110','10001','01110','10001','10001','10001','01110'],
  '9': ['01110','10001','10001','01111','00001','00010','01100'],
  ' ': ['00000','00000','00000','00000','00000','00000','00000'],
  '.': ['00000','00000','00000','00000','00000','01100','01100'],
  '-': ['00000','00000','00000','11111','00000','00000','00000'],
  ':': ['00000','01100','01100','00000','01100','01100','00000'],
  '/': ['00001','00010','00010','00100','01000','01000','10000'],
  '+': ['00000','00100','00100','11111','00100','00100','00000'],
  '#': ['01010','01010','11111','01010','11111','01010','01010'],
  '&': ['01100','10010','10100','01000','10101','10010','01101'],
  '!': ['00100','00100','00100','00100','00100','00000','00100']
};

export function textWidth(text, scale) { return String(text).length * 6 * scale; }

export function drawText(buf, W, x0, y0, text, scale, rgb) {
  const s = String(text).toUpperCase();
  for (let i = 0; i < s.length; i++) {
    const glyph = F[s[i]] || F[' '];
    for (let r = 0; r < 7; r++) {
      for (let c = 0; c < 5; c++) {
        if (glyph[r][c] !== '1') continue;
        for (let dy = 0; dy < scale; dy++) {
          for (let dx = 0; dx < scale; dx++) {
            const x = x0 + i * 6 * scale + c * scale + dx;
            const y = y0 + r * scale + dy;
            if (x < 0 || y < 0 || x >= W) continue;
            const p = (y * W + x) * 4;
            if (p + 3 >= buf.length) continue;
            buf[p] = rgb[0]; buf[p + 1] = rgb[1]; buf[p + 2] = rgb[2]; buf[p + 3] = 255;
          }
        }
      }
    }
  }
}

export function fillRect(buf, W, x0, y0, w, h, rgb, alpha) {
  const a = alpha === undefined ? 255 : alpha;
  for (let y = y0; y < y0 + h; y++) {
    for (let x = x0; x < x0 + w; x++) {
      const p = (y * W + x) * 4;
      if (p < 0 || p + 3 >= buf.length) continue;
      buf[p] = rgb[0]; buf[p + 1] = rgb[1]; buf[p + 2] = rgb[2]; buf[p + 3] = a;
    }
  }
}

const CRC_TABLE = (() => {
  const t = new Int32Array(256);
  for (let n = 0; n < 256; n++) {
    let c = n;
    for (let k = 0; k < 8; k++) c = (c & 1) ? (0xEDB88320 ^ (c >>> 1)) : (c >>> 1);
    t[n] = c;
  }
  return t;
})();

function crc32(buf) {
  let c = 0xFFFFFFFF;
  for (let i = 0; i < buf.length; i++) c = CRC_TABLE[(c ^ buf[i]) & 0xFF] ^ (c >>> 8);
  return (c ^ 0xFFFFFFFF) >>> 0;
}

function chunk(type, data) {
  const len = Buffer.alloc(4); len.writeUInt32BE(data.length, 0);
  const t = Buffer.from(type, 'ascii');
  const crc = Buffer.alloc(4); crc.writeUInt32BE(crc32(Buffer.concat([t, data])), 0);
  return Buffer.concat([len, t, data, crc]);
}

export function encodePNG(width, height, rgba) {
  const raw = Buffer.alloc((width * 4 + 1) * height);
  for (let y = 0; y < height; y++) {
    raw[y * (width * 4 + 1)] = 0;
    rgba.copy ? rgba.copy(raw, y * (width * 4 + 1) + 1, y * width * 4, (y + 1) * width * 4)
              : Buffer.from(rgba.slice(y * width * 4, (y + 1) * width * 4)).copy(raw, y * (width * 4 + 1) + 1);
  }
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(width, 0); ihdr.writeUInt32BE(height, 4);
  ihdr[8] = 8; ihdr[9] = 6; ihdr[10] = 0; ihdr[11] = 0; ihdr[12] = 0;
  return Buffer.concat([
    Buffer.from([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]),
    chunk('IHDR', ihdr),
    chunk('IDAT', zlib.deflateSync(raw, { level: 9 })),
    chunk('IEND', Buffer.alloc(0))
  ]);
}

export function makeCard(width, height, opts) {
  opts = opts || {};
  const bg = opts.bg || [12, 16, 22];
  const fg = opts.fg || [235, 240, 245];
  const accent = opts.accent || [125, 211, 252];
  const buf = Buffer.alloc(width * height * 4);
  // background with a subtle vertical gradient
  for (let y = 0; y < height; y++) {
    const t = y / Math.max(1, height - 1);
    const r = Math.round(bg[0] * (1 - t) + (bg[0] + 26) * t);
    const g = Math.round(bg[1] * (1 - t) + (bg[1] + 22) * t);
    const b = Math.round(bg[2] * (1 - t) + (bg[2] + 34) * t);
    fillRect(buf, width, 0, y, width, 1, [r, g, b]);
  }
  // accent rules
  fillRect(buf, width, 0, 0, width, 10, accent);
  fillRect(buf, width, 80, height - 90, width - 160, 4, accent);
  // text
  drawText(buf, width, 80, 120, opts.title || '', opts.titleScale || 8, fg);
  drawText(buf, width, 80, 260, opts.subtitle || '', opts.subScale || 3, accent);
  drawText(buf, width, 80, height - 150, opts.footer || '', 2, [150, 165, 180]);
  return buf;
}
