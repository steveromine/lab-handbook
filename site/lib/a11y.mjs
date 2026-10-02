import fs from 'node:fs';
import path from 'node:path';
// Accessibility gate for the public handbook build. Node standard library only.
//
// Structural checks run against the generated HTML (image alt text, exactly one <h1>, a set
// <html lang>). Colour-contrast checks are computed from the *live* CSS custom properties in
// site/assets/style.css, so the thresholds can never drift from the real token values.
//
// Target: WCAG 2.2 AA - 4.5:1 for normal text.

const AA_NORMAL = 4.5;

function hexToRgb(h) {
  h = h.replace('#', '');
  if (h.length === 3) h = h.split('').map(function (c) { return c + c; }).join('');
  return [0, 2, 4].map(function (i) { return parseInt(h.slice(i, i + 2), 16) / 255; });
}

function relLum(hex) {
  const parts = hexToRgb(hex).map(function (v) {
    return v <= 0.03928 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4);
  });
  return 0.2126 * parts[0] + 0.7152 * parts[1] + 0.0722 * parts[2];
}

function contrast(a, b) {
  const la = relLum(a), lb = relLum(b);
  const hi = Math.max(la, lb), lo = Math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

// Parse the CSS custom properties for each theme block (":root" and any "[data-theme=...]").
function parseThemes(css) {
  const themes = [];
  css = css.replace(/\/\*[\s\S]*?\*\//g, ''); // strip comments so a leading comment is not read as part of a selector
  const blockRe = /([^{}]+)\{([^{}]*)\}/g;
  let m;
  while ((m = blockRe.exec(css))) {
    const selector = m[1].trim();
    if (!/^:root$/.test(selector) && !/\[data-theme=/.test(selector)) continue;
    const tokens = {};
    const tokRe = /(--[a-z0-9-]+)\s*:\s*(#[0-9a-fA-F]{3,6})\b/g;
    let t;
    while ((t = tokRe.exec(m[2]))) tokens[t[1]] = t[2];
    if (tokens['--bg'] && tokens['--fg']) themes.push({ selector: selector, tokens: tokens });
  }
  if (themes.length === 0) {
    // Fail closed: an unparsed stylesheet must not silently report a clean audit.
    themes.push({ selector: '(none)', tokens: {} });
  }
  return themes;
}

const FOREGROUNDS = ['fg', 'fg-soft', 'muted', 'accent', 'ok', 'warn', 'gap'];
const BACKGROUNDS = ['bg', 'bg-soft', 'bg-card'];

export function contrastFindings(css) {
  const findings = [];
  const themes = parseThemes(css);
  for (const theme of themes) {
    if (theme.selector === '(none)') {
      findings.push('no CSS theme tokens parsed from the stylesheet - contrast audit cannot run');
      continue;
    }
    const get = function (n) { return theme.tokens['--' + n]; };
    for (const f of FOREGROUNDS) {
      for (const b of BACKGROUNDS) {
        if (!get(f) || !get(b)) continue;
        const ratio = contrast(get(f), get(b));
        if (ratio < AA_NORMAL) {
          findings.push('contrast ' + theme.selector + ': --' + f + ' on --' + b + ' = ' + ratio.toFixed(2) + ' (< ' + AA_NORMAL + ')');
        }
      }
    }
    if (get('accent-ink') && get('accent')) {
      const ratio = contrast(get('accent-ink'), get('accent'));
      if (ratio < AA_NORMAL) {
        findings.push('contrast ' + theme.selector + ': --accent-ink on --accent = ' + ratio.toFixed(2) + ' (< ' + AA_NORMAL + ')');
      }
    }
  }
  return findings;
}

function htmlFiles(dir) {
  const out = [];
  (function walk(d) {
    for (const name of fs.readdirSync(d)) {
      const p = path.join(d, name);
      if (fs.statSync(p).isDirectory()) walk(p);
      else if (name.endsWith('.html')) out.push(p);
    }
  })(dir);
  return out;
}

export function structuralFindings(distDir) {
  const findings = [];
  for (const f of htmlFiles(distDir)) {
    const t = fs.readFileSync(f, 'utf8');
    const rel = path.relative(distDir, f);
    const imgs = t.match(/<img\b[^>]*>/gi) || [];
    for (const im of imgs) {
      if (!/\salt\s*=/.test(im)) findings.push('img without alt: ' + rel + ' ' + im.slice(0, 80));
    }
    const h1 = (t.match(/<h1\b/gi) || []).length;
    if (h1 !== 1) findings.push('expected exactly one <h1>, found ' + h1 + ': ' + rel);
    const lang = t.match(/<html\b[^>]*\blang\s*=\s*["']([^"']*)["']/i);
    if (!lang || !lang[1].trim()) findings.push('missing or empty <html lang>: ' + rel);
  }
  return findings;
}

export function checkA11y(args) {
  return contrastFindings(args.css).concat(structuralFindings(args.dist));
}
