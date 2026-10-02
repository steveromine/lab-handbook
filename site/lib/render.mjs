// Layout and templates for the lab handbook site. No template literals, no dependencies.
import { readFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const __dirname = dirname(fileURLToPath(import.meta.url));
function assetVersion() {
  try {
    const a = readFileSync(join(__dirname, '..', 'assets', 'style.css'));
    const b = readFileSync(join(__dirname, '..', 'assets', 'app.js'));
    return createHash('sha1').update(a).update(b).digest('hex').slice(0, 8);
  } catch (e) { return '0'; }
}
const ASSET_V = assetVersion();

export const SITE = {
  // The public origin is injected at build time (SITE_URL) so this repository carries no
  // real hostname. The fallback is a reserved, non-resolvable example origin.
  url: process.env.SITE_URL || 'https://lab-handbook.invalid',
  title: 'The Lab Handbook',
  tagline: 'One person, a small autonomous platform - documented honestly.',
  description: 'A public, sanitised tour of a small self-hosted lab: one hypervisor, one GPU shared three ways, a hardened public edge, and an agent platform that builds, verifies and documents its own work.',
  lang: 'en'
};

export const NAV = [
  { label: 'Home', href: '/' },
  { label: 'Then & Now', href: '/then-and-now/' },
  { label: 'Architecture', href: '/architecture/' },
  { label: 'Agents', href: '/agents/' },
  { label: 'GPU budget', href: '/gpu-budget/' },
  { label: 'Security', href: '/security/' },
  { label: 'Status', href: '/status/' },
  { label: 'Lessons', href: '/lessons/' },
  { label: 'Build', children: [
    { href: '/build/', label: 'Build your own (map)' },
    { href: '/handbook/build-proxmox-host/', label: 'The Proxmox host' },
    { href: '/handbook/build-vps-edge/', label: 'The VPS edge' },
    { href: '/handbook/build-agent-vm/', label: 'The agent VM' }
  ] },
  { label: 'Handbook', children: [
    { href: '/handbook/', label: 'Handbook (index)' },
    { href: '/handbook/architecture/', label: 'Architecture' },
    { href: '/handbook/services/', label: 'Services' },
    { href: '/handbook/agents/', label: 'Agents' },
    { href: '/handbook/agent-org-chart/', label: 'Agent org chart' },
    { href: '/handbook/ai-platform/', label: 'AI platform' },
    { href: '/handbook/deepseek-routing/', label: 'Model routing' },
    { href: '/handbook/integrations/', label: 'Integrations' },
    { href: '/handbook/edge-and-security/', label: 'Edge & security' },
    { href: '/handbook/operations/', label: 'Operations' },
    { href: '/handbook/rollout/', label: 'Rollout' },
    { href: '/handbook/cost-expectations/', label: 'Cost expectations' },
    { href: '/handbook/current-status/', label: 'Current status' },
    { href: '/handbook/lessons/', label: 'Lessons (reference)' },
    { href: '/handbook/eli5/', label: 'Explain it simply (ELI5)' }
  ] },
  { label: 'More', children: [
    { href: '/start/', label: 'Where to start' },
    { href: '/hardware/', label: 'The hardware' },
    { href: '/about/', label: 'About' },
    { href: '/operator/', label: 'The human in the loop' },
    { href: '/brand/', label: 'Brand sheet' },
    { href: '/time-machine/', label: 'Time machine' },
    { href: '/privacy/', label: 'Privacy' }
    , { href: '/backlog/', label: 'Known issues & backlog' }
    , { href: '/comments/', label: 'Comments' }
    , { href: '/uptime/', label: 'Uptime (nines)' }
    , { href: '/cabin/', label: 'Cabin outage board' }
    , { href: '/gallery/', label: 'Gallery' }
  ] }
];

export function esc(s) {
  return String(s)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
}

export function navHtml(current) {
  return NAV.map(function (item) {
    if (!item.children) {
      const on = item.href === current;
      return '<li><a href="' + item.href + '"' + (on ? ' aria-current="page"' : '') + '>' + esc(item.label) + '</a></li>';
    }
    const on = item.children.some(function (c) { return c.href === current; });
    const items = item.children.map(function (c) {
      if (c.group) { return '<li class="menu-group" role="presentation">' + esc(c.group) + '</li>'; }
      const onc = c.href === current;
      return '<li><a href="' + c.href + '"' + (onc ? ' aria-current="page"' : '') + '>' + esc(c.label) + '</a></li>';
    }).join('');
    return '<li class="has-menu"><a href="' + item.children[0].href + '" class="menu-label' + (on ? ' on' : '') + '" aria-haspopup="true">' +
      esc(item.label) + ' <span class="caret" aria-hidden="true">&#9662;</span></a><ul class="menu">' + items + '</ul></li>';
  }).join('');
}
export function tocHtml(headings) {
  const items = headings.filter(function (h) { return h.depth >= 2 && h.depth <= 3; });
  if (items.length < 3) return '';
  return '<nav class="toc" aria-label="On this page"><h2>On this page</h2><ul>' +
    items.map(function (h) { return '<li class="d' + h.depth + '"><a href="#' + h.id + '">' + esc(h.text) + '</a></li>'; }).join('') +
    '</ul></nav>';
}

const REPO_URL = process.env.REPO_URL || 'https://github.com/example/lab-handbook';

export function layout(opts) {
  const title = opts.title ? opts.title + ' - ' + SITE.title : SITE.title;
  const desc = opts.description || SITE.description;
  const url = opts.url || '/';
  const canonical = SITE.url + (url === '/' ? '/' : url);
  const ogImage = SITE.url + '/assets/og.png';
  const bodyClass = opts.bodyClass || '';
  const crumb = opts.crumb ? '<nav class="crumbs" aria-label="Breadcrumb">' + opts.crumb + '</nav>' : '';
  const parts = [];
  parts.push('<!doctype html>');
  parts.push('<html lang="' + SITE.lang + '">');
  parts.push('<head>');
  parts.push('<meta charset="utf-8">');
  parts.push('<meta name="viewport" content="width=device-width, initial-scale=1">');
  parts.push('<title>' + esc(title) + '</title>');
  parts.push('<meta name="description" content="' + esc(desc) + '">');
  parts.push('<link rel="canonical" href="' + esc(canonical) + '">');
  parts.push('<meta name="robots" content="index,follow">');
  parts.push('<meta name="theme-color" content="#0c1017">');
  parts.push('<meta property="og:type" content="website">');
  parts.push('<meta property="og:site_name" content="' + esc(SITE.title) + '">');
  parts.push('<meta property="og:title" content="' + esc(title) + '">');
  parts.push('<meta property="og:description" content="' + esc(desc) + '">');
  parts.push('<meta property="og:url" content="' + esc(canonical) + '">');
  parts.push('<meta property="og:image" content="' + esc(ogImage) + '">');
  parts.push('<meta property="og:image:width" content="1200">');
  parts.push('<meta property="og:image:height" content="630">');
  parts.push('<meta name="twitter:card" content="summary_large_image">');
  parts.push('<meta name="twitter:title" content="' + esc(title) + '">');
  parts.push('<meta name="twitter:description" content="' + esc(desc) + '">');
  parts.push('<meta name="twitter:image" content="' + esc(ogImage) + '">');
  parts.push('<link rel="icon" href="/assets/favicon.svg" type="image/svg+xml">');
  parts.push('<link rel="icon" href="/assets/favicon.png" sizes="32x32" type="image/png">');
  parts.push('<link rel="apple-touch-icon" href="/assets/apple-touch-icon.png">');
  parts.push('<meta name="generator" content="Wren (agent) - text model deepseek/deepseek-flash; images openai/gpt-image-2">');
  parts.push('<link rel="stylesheet" href="/assets/style.css?v=' + ASSET_V + '">');
  parts.push('<script src="/assets/app.js?v=' + ASSET_V + '" defer></script>');
  parts.push('<script type="application/ld+json">' + JSON.stringify({
    '@context': 'https://schema.org', '@type': 'WebSite', name: SITE.title,
    url: SITE.url, description: SITE.description, inLanguage: 'en'
  }) + '</script>');
  parts.push('</head>');
  parts.push('<body class="' + esc(bodyClass) + '">');
  parts.push('<a class="skip" href="#main">Skip to content</a>');
  parts.push('<header class="site-head">');
  parts.push('<div class="wrap head-inner">');
  parts.push('<a class="brand" href="/"><span class="brand-mark" aria-hidden="true">LH</span><span class="brand-text">' + esc(SITE.title) + '</span></a>');
  parts.push('<button type="button" class="nav-toggle" aria-expanded="false" aria-controls="site-nav">Menu</button>');
  parts.push('<nav id="site-nav" class="site-nav" aria-label="Primary"><ul>' + navHtml(opts.navCurrent || url) + '</ul></nav>');
  parts.push('<button type="button" class="search-open" data-search-open aria-label="Search this site">Search</button>');
  parts.push('<button type="button" class="theme-toggle" data-theme-toggle aria-label="Switch colour theme">Theme</button>');
  parts.push('<button type="button" class="rating-toggle" data-rating-toggle aria-label="Switch content rating: G or PG-13">Rated: PG-13</button>');
  parts.push('</div>');
  parts.push('</header>');
  parts.push('<main id="main" class="wrap">');
  parts.push(crumb);
  parts.push(opts.content);
  parts.push('</main>');
  parts.push('<footer class="site-foot"><div class="wrap">');
  if (process.env.FAILOVER) parts.push('<p class="fine failover-banner"><strong>Failover copy:</strong> served from the edge and synced from the public repository, because the primary lab may be unreachable. <a href="/outage/">What happened?</a></p>');
  parts.push('<p><strong>' + esc(SITE.title) + '</strong> - public by intention, sanitised by design. No credentials, no internal addresses, no access paths.</p>');
  parts.push('<p class="fine age-note"><strong>Age note:</strong> not everything here is PG. This is a virtual IT shop - strong language is part of the furniture and the humour is grown-up. Mind the workshop floor.</p>');
  parts.push('<p class="fine disclaimer"><strong>Disclaimer:</strong> this entire site is machine-generated. It is not an accurate representation of its owner, of any AI, or of any entity associated with either. Quirks and oddities happen - we fix them when we see them.</p>');
  parts.push('<p class="fine model-credit"><strong>Generated by:</strong> Wren - text model <code>deepseek/deepseek-flash</code>; generated images credit their model beneath the image.</p>');
  parts.push('<p class="fine">Source: the <a href="' + esc(REPO_URL) + '">lab-handbook</a> repository. Static site, no trackers, no third-party scripts, no external fonts.</p>');
  parts.push('<p class="fine">Licence: <a href="https://github.com/steveromine/lab-handbook/blob/main/LICENSE">MIT</a> - use it freely, credit me, no warranty. Bundled components keep their own terms; generated media credits its model.</p>');
  parts.push('<p class="fine">Deployed <time datetime="' + new Date().toISOString().slice(0, 10) + '">' + new Date().toISOString().slice(0, 10) + '</time></p>');
  parts.push('</div></footer>');
  parts.push('<dialog id="search-dialog" class="search-dialog" aria-label="Search">');
  parts.push('<form method="dialog" class="search-form"><label for="q">Search the handbook</label>');
  parts.push('<input id="q" name="q" type="search" autocomplete="off" placeholder="e.g. MTU, GPU, overlay">');
  parts.push('<button value="close" class="search-close" aria-label="Close search">Close</button></form>');
  parts.push('<div id="search-results" class="search-results" role="list"></div>');
  parts.push('<p class="fine">Search runs entirely in your browser against a static index. Nothing is sent anywhere.</p>');
  parts.push('</dialog>');
  parts.push('</body></html>');
  return parts.join('\n');
}

export function statusPill(kind) {
  const k = String(kind).toLowerCase();
  const map = {
    verified: 'DESIGNED|CONFIGURED|VERIFIED|KNOWN GAP|PLANNED'
  };
  void map;
  return '<span class="pill pill-' + esc(k.replace(/[^a-z]/g, '')) + '">' + esc(String(kind).toUpperCase()) + '</span>';
}

export function factCard(label, value, note) {
  return '<div class="fact"><dt>' + esc(label) + '</dt><dd>' + esc(value) + (note ? '<span class="fact-note">' + esc(note) + '</span>' : '') + '</dd></div>';
}
