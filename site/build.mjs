#!/usr/bin/env node
// Build the public lab handbook site from the existing handbook markdown.
// Dependency-free: Node standard library only.
import fs from 'node:fs';
import path from 'node:path';
import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { renderMarkdown, stripFrontMatter, slugify } from './lib/md.mjs';
import { layout, SITE, NAV } from './lib/render.mjs';
import { encodePNG, makeCard, drawText, fillRect } from './lib/png.mjs';
import { checkA11y } from './lib/a11y.mjs';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(HERE, '..');
const DIST = path.join(HERE, 'dist');
const CONTENT = path.join(HERE, 'content');
const ASSETS = path.join(HERE, 'assets');
const DOCS = path.join(ROOT, 'docs');

const STORY = [
  { slug: '/', file: 'home.md', nav: '/' },
  { slug: '/then-and-now/', file: 'then-and-now.md', nav: '/then-and-now/', section: 'Story' },
  { slug: '/architecture/', file: 'architecture.md', nav: '/architecture/', section: 'Story' },
  { slug: '/agents/', file: 'agents.md', nav: '/agents/', section: 'Story' },
  { slug: '/reviews/', file: 'reviews.md', nav: '/reviews/', section: 'Story' },
  { slug: '/gpu-budget/', file: 'gpu-budget.md', nav: '/gpu-budget/', section: 'Story' },
  { slug: '/security/', file: 'security.md', nav: '/security/', section: 'Story' },
  { slug: '/status/', file: 'status.md', nav: '/status/', section: 'Story' },
  { slug: '/lessons/', file: 'lessons.md', nav: '/lessons/', section: 'Story' },
  { slug: '/hardware/', file: 'hardware.md', nav: '/hardware/', section: 'Story' },
  { slug: '/song/', file: 'song.md', nav: '/song/', section: 'Story' },
  { slug: '/license/', file: 'license.md', nav: '/license/', section: 'Story' },
  { slug: '/about/', file: 'about.md', nav: '/about/', section: 'Story' },
  { slug: '/wren/', file: 'wren.md', nav: '/wren/', section: 'Story' },
  { slug: '/time-machine/', file: 'time-machine.md', nav: '/time-machine/', section: 'Story' },
  { slug: '/operator/', file: 'operator.md', nav: '/operator/', section: 'Story' },
  { slug: '/brand/', file: 'brand.md', nav: '/brand/', section: 'Story' },
  { slug: '/futures/', file: 'futures.md', nav: '/futures/', section: 'Story' },
  { slug: '/privacy/', file: 'privacy.md', nav: '/privacy/', section: 'Story' },
  { slug: '/backlog/', file: 'backlog.md', nav: '/backlog/', section: 'Story' },
  { slug: '/comments/', file: 'comments.md', nav: '/comments/', section: 'Story' },
  { slug: '/gallery/', file: 'gallery.md', nav: '/gallery/', section: 'Story' },
  { slug: '/uptime/', file: 'uptime.md', nav: '/uptime/', section: 'Story' },
  { slug: '/cabin/', file: 'cabin.md', nav: '/cabin/', section: 'Story' },
  { slug: '/test/', file: 'test.md', nav: '/test/', section: 'Story' },
  { slug: '/outage/', file: 'outage.md', nav: '', section: 'Story' },
  { slug: '/build/', file: 'build.md', nav: '/build/', section: 'Story' },
  { slug: '/start/', file: 'start.md', nav: '/start/', section: 'Story' }
];

function ensureDir(p) { fs.mkdirSync(p, { recursive: true }); }
function write(rel, data) { const p = path.join(DIST, rel); ensureDir(path.dirname(p)); fs.writeFileSync(p, data); }
function read(p) { return fs.readFileSync(p, 'utf8'); }

function readStory(entry) {
  const raw = read(path.join(CONTENT, entry.file));
  const fm = stripFrontMatter(raw);
  const rendered = renderMarkdown(fm.body);
  return { entry, meta: fm.meta, rendered };
}

function heroHtml(meta) {
  if (!meta.hero_title) return '';
  const parts = ['<header class="hero">'];
  if (meta.eyebrow) parts.push('<p class="eyebrow">' + meta.eyebrow + '</p>');
  parts.push('<h1>' + meta.hero_title + '</h1>');
  if (meta.hero_lede) parts.push('<p class="lede">' + meta.hero_lede + '</p>');
  parts.push('<p class="hero-actions"><a class="btn" href="/handbook/">Read the handbook</a> <a class="btn btn-ghost" href="/start/">Where do I start?</a></p>');
  parts.push('</header>');
  return parts.join('');
}

const FACTS = [
  ['Hypervisor', '1', 'One physical Proxmox VE host. A deliberate single point of failure.'],
  ['Guests in service', '10 + 3', 'Ten containers and three virtual machines; seven retired guests reclaimed.'],
  ['GPU', '8 GB', 'One consumer card, shared three ways on purpose.'],
  ['GPU workloads', '3', 'Resident LLM (~5 GB), streaming image model, bursty media transcode.'],
  ['Image generation', '1-4 steps', 'A distilled few-step model; ~1.5-2.5 s per image alongside the LLM.'],
  ['Network zones', '3', 'Management, untrusted client, servers.'],
  ['Public entry points', '1', 'A single hardened edge; lab services have no public listeners.'],
  ['Auth layers per service', '1', 'Exactly one - the app, or the edge. Never both.'],
  ['Agent roles live', '1 of 5', 'Manager is live; Forge, Sentinel, Atlas and Ledger are designed, not built.']
];

function factsHtml() {
  return '<section class="snapshot" aria-labelledby="snapshot-h"><h2 id="snapshot-h">The platform in numbers</h2>' +
    '<dl class="facts">' + FACTS.map(function (f) {
      return '<div class="fact"><dt>' + f[0] + '</dt><dd><span class="fact-value">' + f[1] + '</span><span class="fact-note">' + f[2] + '</span></dd></div>';
    }).join('') + '</dl>' +
    '<p class="fine">Every figure above is taken from the handbook in this repository. Where the lab has not verified something, the <a href="/status/">status page</a> says so.</p></section>';
}

function handbookPages() {
  const pages = [];
  const readme = read(path.join(ROOT, 'README.md'));
  const rf = stripFrontMatter(readme);
  const rr = renderMarkdown(rf.body);
  pages.push({ slug: '/handbook/', kind: 'index', title: 'Handbook', source: 'README.md', rendered: rr });
  const files = fs.readdirSync(DOCS).filter(f => f.endsWith('.md')).sort();
  for (const f of files) {
    const raw = read(path.join(DOCS, f));
    const fm = stripFrontMatter(raw);
    const rendered = renderMarkdown(fm.body);
    const h1 = (rendered.headings.find(h => h.depth === 1) || { text: f.replace(/\.md$/, '') }).text;
    pages.push({ slug: '/handbook/' + f.replace(/\.md$/, '') + '/', kind: 'doc', title: h1, source: 'docs/' + f, rendered });
  }
  return pages;
}

// Handbook markdown links to sibling files as docs/<name>.md; on the site those live at
// /handbook/<name>/. Rewrite only relative .md targets; leave external, absolute and anchor links alone.
function rewriteRefLinks(html) {
  return String(html).replace(/href="([^"]+)"/g, function (m, href) {
    if (/^(https?:|mailto:|#|\/)/.test(href)) return m;
    if (/(^|\/)README\.md$/.test(href)) return 'href="/handbook/"';
    const mm = href.match(/^(?:\.\/|\.\.\/|docs\/)*([A-Za-z0-9][A-Za-z0-9._-]*)\.md$/);
    if (mm) return 'href="/handbook/' + mm[1] + '/"';
    return m;
  });
}

function writePage(slug, html) {
  if (slug === '/') write('index.html', html);
  else write(slug.replace(/^\//, '').replace(/\/$/, '') + '/index.html', html);
}

// ---------- assets ----------
const FAVICON_SVG = ['<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" role="img" aria-label="Lab Handbook">',
  '<rect width="64" height="64" rx="12" fill="#0c1017"/>',
  '<rect x="10" y="14" width="6" height="36" fill="#7dd3fc"/>',
  '<rect x="10" y="44" width="22" height="6" fill="#7dd3fc"/>',
  '<rect x="22" y="14" width="6" height="30" fill="#7dd3fc"/>',
  '<rect x="38" y="14" width="6" height="36" fill="#e2e8f0"/>',
  '<rect x="48" y="14" width="6" height="36" fill="#e2e8f0"/>',
  '<rect x="38" y="30" width="16" height="6" fill="#e2e8f0"/>',
  '</svg>'].join('');

function assets() {
  write('assets/favicon.svg', FAVICON_SVG);
  const icon = Buffer.alloc(32 * 32 * 4);
  fillRect(icon, 32, 0, 0, 32, 32, [12, 16, 22]);
  drawText(icon, 32, 6, 9, 'LH', 3, [125, 211, 252]);
  write('assets/favicon.png', encodePNG(32, 32, icon));
  const touch = Buffer.alloc(180 * 180 * 4);
  fillRect(touch, 180, 0, 0, 180, 180, [12, 16, 22]);
  drawText(touch, 180, 42, 62, 'LH', 10, [125, 211, 252]);
  write('assets/apple-touch-icon.png', encodePNG(180, 180, touch));
  const publicHost = (function () { try { return new URL(SITE.url).host.toUpperCase(); } catch (e) { return 'THE LAB HANDBOOK'; } })();
  const og = makeCard(1200, 630, { title: 'THE LAB HANDBOOK', titleScale: 9, subtitle: 'ONE PERSON, A SMALL AUTONOMOUS PLATFORM', footer: publicHost + '  -  PUBLIC BY INTENTION, SANITISED BY DESIGN' });
  write('assets/og.png', encodePNG(1200, 630, og));
  copyAssets(ASSETS, 'assets/');
}

// Copy the static assets verbatim, descending into subdirectories so nested
// asset trees (e.g. gallery/<set>/images) are supported instead of failing with EISDIR.
function copyAssets(dir, prefix) {
  for (const name of fs.readdirSync(dir).sort()) {
    const src = path.join(dir, name);
    if (fs.statSync(src).isDirectory()) { copyAssets(src, prefix + name + '/'); continue; }
    write(prefix + name, fs.readFileSync(src));
  }
}

// ---------- search / sitemap ----------
function searchIndex(pages) {
  const entries = pages.map(function (p) {
    return { u: p.slug, t: p.title, k: p.kind === 'doc' ? 'Handbook' : p.kind === 'index' ? 'Handbook' : 'Story', x: p.text.slice(0, 1500) };
  });
  write('search-index.json', JSON.stringify(entries));
}

function sitemap(pages) {
  const urls = pages.map(p => '  <url><loc>' + SITE.url + p.slug + '</loc></url>').join('\n');
  write('sitemap.xml', '<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n' + urls + '\n</urlset>\n');
}

function robots() {
  write('robots.txt', 'User-agent: *\nAllow: /\nSitemap: ' + SITE.url + '/sitemap.xml\n');
}

// ---------- sanitisation gate ----------
// The canonical origin is supplied at build time, so this repository contains no real hostname.
// The gate derives the apex from it rather than spelling it out - a gate that embeds the string it
// looks for would trip on itself.
const CANON_HOST = (function () { try { return new URL(SITE.url).host; } catch (e) { return 'lab-handbook.invalid'; } })();
const APEX = CANON_HOST.split('.').slice(-2).join('\\.');
// Hosts that are public by design, not leaks: the canonical site host (its own label under the
// apex) plus the failure-mode hosts the public outage page links to. Labels only - no full
// hostname is spelled out, so the gate cannot trip on itself. Any OTHER subdomain of the apex
// is still treated as a leak, and the gate stays fail-closed for everything else.
const CANON_LABEL = CANON_HOST.split('.').length > 2 ? CANON_HOST.split('.')[0] : null;
const PUBLIC_LABELS = [CANON_LABEL, 'failover', 'down'].filter(Boolean);
const APEX_HOST = CANON_HOST.split('.').slice(-2).join('.');
const PUBLIC_HOSTS = PUBLIC_LABELS.map(function (l) { return l + '.' + APEX_HOST; });
const PATTERNS = [
  { label: 'IPv4 address', re: /\b(?:\d{1,3}\.){3}\d{1,3}\b/g },
  { label: 'private hostname', re: /\b(pve1|agent-manager|racknerd|localadmin|labadmin|cabin\.local|cabin\.private)\b/gi },
  { label: 'internal FQDN scheme', re: new RegExp('\\.int\\.' + APEX, 'gi') },
  { label: 'non-canonical subdomain', re: new RegExp('(?:^|[^a-z0-9-])([a-z0-9-]+)\\.' + APEX, 'gi') },
  { label: 'private key material', re: /BEGIN [A-Z ]*PRIVATE KEY/g },
  { label: 'bcrypt hash', re: /\$2[aby]\$\d\d\$/g },
  { label: 'cloudflare/github token', re: /\b(gh[pous]_[A-Za-z0-9]{20,}|sk-[A-Za-z0-9]{20,})\b/g }
];

// Mask the canonical and deliberately-public hosts before pattern testing, so benign public
// links are ignored while a leak on any other subdomain still fails the gate.
function maskPublicHosts(line) {
  let out = line.split(CANON_HOST).join('<canonical-host>');
  for (const h of PUBLIC_HOSTS) out = out.split(h).join('<public-host>');
  return out;
}

function scanTree(dir, isSource) {
  const hits = [];
  const walk = (d) => {
    for (const name of fs.readdirSync(d)) {
      const p = path.join(d, name);
      const st = fs.statSync(p);
      if (st.isDirectory()) { walk(p); continue; }
      if (/\.(png|jpg|jpeg|gif|ico|woff2?)$/i.test(name)) continue;
      const text = fs.readFileSync(p, 'utf8');
      const lines = text.split('\n');
      for (const pat of PATTERNS) {
        lines.forEach(function (line, n) {
          pat.re.lastIndex = 0;
          const masked = maskPublicHosts(line);
          if (pat.re.test(masked)) {
            hits.push({ file: path.relative(dir, p), line: n + 1, pattern: pat.label, snippet: masked.trim().slice(0, 140) });
          }
        });
      }
    }
  };
  if (fs.existsSync(dir)) walk(dir);
  return hits;
}

function gate() {
  const hits = [].concat(scanTree(CONTENT, true), scanTree(ASSETS, true), scanTree(DIST, false));
  if (hits.length) {
    console.error('SANITISATION GATE FAILED - ' + hits.length + ' finding(s):');
    hits.forEach(h => console.error('  ' + h.file + ':' + h.line + ' [' + h.pattern + '] ' + h.snippet));
    process.exit(2);
  }
  console.log('Sanitisation gate: clean (' + PATTERNS.length + ' pattern classes over content, assets and generated output).');
}

// ---------- accessibility gate ----------
// Contrast thresholds are computed from the live CSS custom properties (never hardcoded), and
// alt/lang/heading structure is checked against the generated HTML. Fails the build closed.
function a11yGate() {
  const findings = checkA11y({ dist: DIST, css: read(path.join(ASSETS, 'style.css')) });
  if (findings.length) {
    console.error('ACCESSIBILITY GATE FAILED - ' + findings.length + ' finding(s):');
    findings.forEach(function (f) { console.error('  ' + f); });
    process.exit(3);
  }
  console.log('Accessibility gate: clean (WCAG 2.2 AA contrast from CSS tokens; alt/lang/heading over generated HTML).');
}

// The time-machine page is generated from git history. Regenerate it before rendering so the
// page cannot claim a stale "full history" (finding D-2: it was last regenerated by hand at 68
// commits and had silently fallen to 19 changes behind). Best-effort: gen-history.mjs refuses to
// shrink the page when history is unavailable or shallower (e.g. a depth-1 CI checkout), in which
// case we keep the committed page rather than failing the build.
function syncHistory() {
  try {
    const out = execFileSync(process.execPath, [path.join(ROOT, 'scripts', 'gen-history.mjs'), ROOT], { encoding: 'utf8' });
    process.stdout.write(out);
  } catch (e) {
    console.warn('gen-history: skipped - ' + (e.stderr ? String(e.stderr).trim() : e.message));
  }
}

// ---------- main ----------
function main() {
  fs.rmSync(DIST, { recursive: true, force: true });
  ensureDir(DIST);
  const allPages = [];
  syncHistory();

  for (const entry of STORY) {
    const { meta, rendered } = readStory(entry);
    const title = meta.title || 'The Lab Handbook';
    const content = heroHtml(meta) + (meta.facts === 'true' ? factsHtml() : '') + rendered.html;
    const html = layout({
      title: entry.slug === '/' ? null : title,
      description: meta.description, url: entry.slug, navCurrent: entry.slug, content,
      bodyClass: entry.slug === '/' ? 'home' : ''
    });
    writePage(entry.slug, html);
    allPages.push({ slug: entry.slug, title, kind: entry.slug === '/' ? 'home' : 'story', text: rendered.text });
  }

  const hb = handbookPages();
  for (const p of hb) {
    const content = '<p class="eyebrow">Reference</p>' + rewriteRefLinks(p.rendered.html);
    const html = layout({ title: p.title, description: 'Handbook reference: ' + p.title, url: p.slug, navCurrent: '/handbook/', content });
    writePage(p.slug, html);
    allPages.push({ slug: p.slug, title: p.title, kind: p.kind, text: p.rendered.text });
  }

  assets();
  searchIndex(allPages);
  sitemap(allPages);
  robots();
  write('404.html', layout({
    title: 'Page not found',
    description: 'That page does not exist on this site.',
    url: '/404.html',
    content: '<header class="hero"><p class="eyebrow">404</p><h1>That page does not exist</h1><p class="lede">The link may be old, or the page may have moved. Try the <a href="/handbook/">handbook index</a>, or press the Search button to look for it.</p></header>'
  }));
  gate();
  a11yGate();
  console.log('Built ' + allPages.length + ' pages into ' + path.relative(ROOT, DIST));
  console.log('Story pages: ' + STORY.length + ', handbook pages: ' + hb.length);
}

main();
