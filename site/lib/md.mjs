// Minimal, dependency-free Markdown subset renderer for the lab handbook site.
const BT = String.fromCharCode(96); // backtick, without writing one literally
const NUL = String.fromCharCode(0);

export function escapeHtml(s) {
  return String(s)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

export function slugify(s) {
  return String(s).toLowerCase()
    .replace(/[^a-z0-9\s-]/g, '')
    .trim()
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-')
    .replace(/^-|-$/g, '') || 'section';
}

const RAW_TAGS = ['code','br','span','div','details','summary','ul','ol','li','strong','em','abbr','kbd','mark','sub','sup','table','thead','tbody','tr','th','td','p','figure','figcaption','h3','h4','a','svg','g','rect','circle','ellipse','path','line','polyline','polygon','text','tspan','defs','marker','linearGradient','stop','title','desc','use'];
const RAW_RE = new RegExp('<\\/?(' + RAW_TAGS.join('|') + ')(\\s[^<>]*)?\\/?>', 'gi');

function inline(src) {
  const store = [];
  const keep = (html) => { store.push(html); return NUL + (store.length - 1) + NUL; };
  let s = String(src);
  const codeRe = new RegExp(BT + '{1,2}([^' + BT + ']+?)' + BT + '{1,2}', 'g');
  s = s.replace(codeRe, (m, code) => keep('<code>' + escapeHtml(code.trim()) + '</code>'));
  s = s.replace(RAW_RE, (m) => keep(m));
  s = escapeHtml(s);
  s = s.replace(/!\[([^\]]*)\]\(([^)\s]+)(?:\s+&quot;([^&]*)&quot;)?\)/g, (m, alt, href, title) =>
    '<img src="' + href + '" alt="' + alt + '"' + (title ? ' title="' + title + '"' : '') + ' loading="lazy">');
  s = s.replace(/\[([^\]]+)\]\(([^)\s]+)(?:\s+&quot;([^&]*)&quot;)?\)/g, (m, text, href, title) => {
    const ext = /^https?:\/\//.test(href);
    return '<a href="' + href + '"' + (ext ? ' rel="noopener"' : '') + (title ? ' title="' + title + '"' : '') + '>' + text + '</a>';
  });
  s = s.replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>');
  s = s.replace(/(^|[^\w_])__([^_]+)__/g, '$1<strong>$2</strong>');
  s = s.replace(/(^|[^*])\*([^*\s][^*]*)\*/g, '$1<em>$2</em>');
  s = s.replace(/~~([^~]+)~~/g, '<del>$1</del>');
  s = s.replace(/&lt;(https?:\/\/[^&\s]+)&gt;/g, '<a href="$1" rel="noopener">$1</a>');
  s = s.replace(new RegExp(NUL + '(\\d+)' + NUL, 'g'), (m, i) => store[Number(i)]);
  return s;
}

function plainText(md) {
  let s = String(md);
  s = s.replace(new RegExp(BT + '([^' + BT + ']+)' + BT, 'g'), '$1');
  s = s.replace(/\[([^\]]+)\]\([^)]*\)/g, '$1');
  s = s.replace(/[*_~#>`]/g, '');
  return s.trim();
}

export function renderMarkdown(src, opts) {
  opts = opts || {};
  const headings = [];
  const textParts = [];
  const lines = String(src).replace(/\r\n?/g, '\n').split('\n');
  const out = [];
  let i = 0;

  function heading(depth, body) {
    const id = slugify(plainText(body));
    let uniq = id, n = 2;
    while (headings.some(h => h.id === uniq)) { uniq = id + '-' + n; n++; }
    headings.push({ depth, text: plainText(body), id: uniq });
    textParts.push(plainText(body));
    const lvl = Math.min(depth, 6);
    return '<h' + lvl + ' id="' + uniq + '">' + inline(body) + '<a class="anchor" href="#' + uniq + '" aria-hidden="true">#</a></h' + lvl + '>';
  }

  function renderList(startIdx, indent) {
    let idx = startIdx;
    const items = [];
    let tag = 'ul';
    while (idx < lines.length) {
      const raw = lines[idx];
      if (!raw.trim()) {
        const nxt = lines[idx + 1] || '';
        const mNext = nxt.match(/^(\s*)([-*+]|\d+[.)])\s+(.*)$/);
        if (mNext && mNext[1].length >= indent) { idx++; continue; }
        break;
      }
      const m = raw.match(/^(\s*)([-*+]|\d+[.)])\s+(.*)$/);
      if (!m) break;
      if (m[1].length < indent) break;
      if (m[1].length > indent) {
        const sub = renderList(idx, m[1].length);
        if (items.length) items[items.length - 1].children.push(sub.html);
        idx = sub.next;
        continue;
      }
      tag = /\d/.test(m[2]) ? 'ol' : 'ul';
      let body = m[3];
      let j = idx + 1;
      const cont = [];
      while (j < lines.length) {
        const l = lines[j];
        if (!l.trim()) break;
        if (/^(\s*)([-*+]|\d+[.)])\s+/.test(l)) break;
        if (/^(#{1,6}\s|\||>)/.test(l.trim())) break;
        cont.push(l.trim()); j++;
      }
      if (cont.length) { body = body + ' ' + cont.join(' '); idx = j - 1; }
      textParts.push(plainText(body));
      items.push({ html: inline(body), children: [] });
      idx++;
    }
    const html = '<' + tag + '>' + items.map(it => '<li>' + it.html + it.children.join('') + '</li>').join('') + '</' + tag + '>';
    return { html, next: idx };
  }

  while (i < lines.length) {
    const line = lines[i];
    const fence = line.match(/^\s*(~~~+|`{3,})\s*([\w+-]*)\s*$/);
    if (fence) {
      const marker = fence[1][0];
      const lang = (fence[2] || '').toLowerCase();
      const buf = [];
      i++;
      while (i < lines.length && !new RegExp('^\\s*' + marker + '{3,}\\s*$').test(lines[i])) { buf.push(lines[i]); i++; }
      i++;
      const code = buf.join('\n');
      if (lang === 'mermaid') {
        out.push('<figure class="diagram" data-diagram="mermaid"><div class="diagram-src"><pre><code>' + escapeHtml(code) + '</code></pre></div><figcaption>Diagram source (Mermaid) - rendered form lives in the repository.</figcaption></figure>');
      } else {
        out.push('<div class="codeblock"><pre><code' + (lang ? ' class="language-' + lang + '"' : '') + '>' + escapeHtml(code) + '</code></pre></div>');
      }
      continue;
    }
    if (!line.trim()) { i++; continue; }
    if (/^\s*([-*_])(\s*\1){2,}\s*$/.test(line)) { out.push('<hr>'); i++; continue; }
    const h = line.match(/^(#{1,6})\s+(.*)$/);
    if (h) { out.push(heading(h[1].length, h[2])); i++; continue; }
    if (/^\s*>/.test(line)) {
      const buf = [];
      while (i < lines.length && /^\s*>/.test(lines[i])) {
        buf.push(lines[i].replace(/^\s*>\s?/, ''));
        i++;
      }
      const inner = renderMarkdown(buf.join('\n'));
      inner.headings.forEach(x => headings.push(x));
      out.push('<blockquote>' + inner.html + '</blockquote>');
      textParts.push(inner.text);
      continue;
    }
    if (/\|/.test(line) && i + 1 < lines.length && /^\s*\|?\s*:?-{2,}:?\s*(\|\s*:?-{2,}:?\s*)*\|?\s*$/.test(lines[i + 1])) {
      const parseRow = (l) => l.trim().replace(/^\|/, '').replace(/\|$/, '').split('|').map(c => c.trim());
      const head = parseRow(line);
      i += 2;
      const rows = [];
      while (i < lines.length && /\|/.test(lines[i]) && lines[i].trim()) { rows.push(parseRow(lines[i])); i++; }
      const th = head.map(c => '<th>' + inline(c) + '</th>').join('');
      const tb = rows.map(r => '<tr>' + head.map((c, k) => '<td>' + inline(r[k] || '') + '</td>').join('') + '</tr>').join('');
      out.push('<div class="tablewrap"><table><thead><tr>' + th + '</tr></thead><tbody>' + tb + '</tbody></table></div>');
      head.forEach(c => textParts.push(plainText(c)));
      rows.forEach(r => r.forEach(c => textParts.push(plainText(c))));
      continue;
    }
    const lm = line.match(/^(\s*)([-*+]|\d+[.)])\s+/);
    if (lm) {
      const res = renderList(i, lm[1].length);
      out.push(res.html);
      i = res.next;
      continue;
    }
    const buf = [];
    while (i < lines.length && lines[i].trim() &&
      !/^(#{1,6}\s|\s*>|\s*([-*_])(\s*\1){2,}\s*$)/.test(lines[i]) &&
      !/^\s*(~~~+|`{3,})/.test(lines[i]) &&
      !/^(\s*)([-*+]|\d+[.)])\s+/.test(lines[i])) {
      buf.push(lines[i].trim());
      i++;
    }
    if (buf.length) {
      const para = buf.join(' ');
      textParts.push(plainText(para));
      out.push('<p>' + inline(para) + '</p>');
    } else { i++; }
  }
  return { html: out.join('\n'), headings, text: textParts.join(' ').replace(/\s+/g, ' ').trim() };
}

export function stripFrontMatter(src) {
  const m = String(src).match(/^---\n([\s\S]*?)\n---\n?/);
  if (!m) return { meta: {}, body: String(src) };
  const meta = {};
  m[1].split('\n').forEach(line => {
    const mm = line.match(/^([A-Za-z0-9_-]+):\s*(.*)$/);
    if (mm) meta[mm[1]] = mm[2].replace(/^["']|["']$/g, '').trim();
  });
  return { meta, body: String(src).slice(m[0].length) };
}
