// Layout and templates for the lab handbook site. No template literals, no dependencies.
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
  { href: '/', label: 'Home' },
  { href: '/then-and-now/', label: 'Then & Now' },
  { href: '/architecture/', label: 'Architecture' },
  { href: '/agents/', label: 'Agents' },
  { href: '/gpu-budget/', label: 'GPU budget' },
  { href: '/security/', label: 'Security' },
  { href: '/status/', label: 'Status' },
  { href: '/lessons/', label: 'Lessons' },
  { href: '/futures/', label: 'Futures' },
  { href: '/brand/', label: 'Brand' },
  { href: '/hardware/', label: 'Hardware' },
  { href: '/song/', label: 'Song' },
  { href: '/time-machine/', label: 'Time machine' },
  { href: '/operator/', label: 'The human' },
  { href: '/build/', label: 'Build it' },
  { href: '/handbook/', label: 'Handbook' }
];

export function esc(s) {
  return String(s)
    .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
}

export function navHtml(current) {
  return NAV.map(function (item) {
    const on = item.href === current;
    return '<li><a href="' + item.href + '"' + (on ? ' aria-current="page"' : '') + '>' + esc(item.label) + '</a></li>';
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
  parts.push('<link rel="stylesheet" href="/assets/style.css">');
  parts.push('<script src="/assets/app.js" defer></script>');
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
  parts.push('</div>');
  parts.push('</header>');
  parts.push('<main id="main" class="wrap">');
  parts.push(crumb);
  parts.push(opts.content);
  parts.push('</main>');
  parts.push('<footer class="site-foot"><div class="wrap">');
  parts.push('<p><strong>' + esc(SITE.title) + '</strong> - public by intention, sanitised by design. No credentials, no internal addresses, no access paths.</p>');
  parts.push('<p class="fine">Source: the <a href="' + esc(REPO_URL) + '">lab-handbook</a> repository. Static site, no trackers, no third-party scripts, no external fonts.</p>');
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
