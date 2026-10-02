/* Lab Handbook site script: nav toggle, colour theme, static search. No dependencies. */
(function () {
  'use strict';
  var STORE_KEY = 'lab-handbook-theme';
  var root = document.documentElement;

  // --- theme ---
  try {
    var saved = localStorage.getItem(STORE_KEY);
    if (saved === 'light' || saved === 'dark') root.setAttribute('data-theme', saved);
  } catch (e) {}
  var themeBtn = document.querySelector('[data-theme-toggle]');
  if (themeBtn) {
    themeBtn.addEventListener('click', function () {
      var current = root.getAttribute('data-theme');
      if (!current) {
        current = window.matchMedia('(prefers-color-scheme: light)').matches ? 'light' : 'dark';
      }
      var next = current === 'light' ? 'dark' : 'light';
      root.setAttribute('data-theme', next);
      try { localStorage.setItem(STORE_KEY, next); } catch (e) {}
    });
  }

  // --- nav toggle (small screens) ---
  var navBtn = document.querySelector('.nav-toggle');
  var nav = document.getElementById('site-nav');
  if (navBtn && nav) {
    navBtn.addEventListener('click', function () {
      var open = nav.classList.toggle('open');
      navBtn.setAttribute('aria-expanded', open ? 'true' : 'false');
    });
  }

  // --- search ---
  var dialog = document.getElementById('search-dialog');
  var openBtn = document.querySelector('[data-search-open]');
  var input = document.getElementById('q');
  var results = document.getElementById('search-results');
  var index = null;
  var loading = false;

  function esc(s) {
    return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  }

  function load() {
    if (index || loading) return Promise.resolve(index);
    loading = true;
    return fetch('/search-index.json').then(function (r) { return r.json(); }).then(function (data) {
      index = data; loading = false; return index;
    }).catch(function () { loading = false; return []; });
  }

  function score(item, terms) {
    var text = (item.t + ' ' + item.x).toLowerCase();
    var total = 0;
    for (var i = 0; i < terms.length; i++) {
      var t = terms[i];
      if (!t) continue;
      var at = text.indexOf(t);
      if (at === -1) return 0;
      total += 1 + (item.t.toLowerCase().indexOf(t) !== -1 ? 3 : 0);
    }
    return total;
  }

  function render(terms) {
    if (!terms.length) { results.innerHTML = '<p class="hint">Type to search pages, headings and body text.</p>'; return; }
    var scored = index.map(function (item) { return { item: item, s: score(item, terms) }; })
      .filter(function (x) { return x.s > 0; })
      .sort(function (a, b) { return b.s - a.s; })
      .slice(0, 12);
    if (!scored.length) { results.innerHTML = '<p class="hint">No matches.</p>'; return; }
    results.innerHTML = scored.map(function (x) {
      var snippet = x.item.x.slice(0, 190);
      return '<a href="' + x.item.u + '"><strong>' + esc(x.item.t) + '</strong> <span class="hint">- ' + esc(x.item.k) + '</span><br><span class="hint">' + esc(snippet) + '...</span></a>';
    }).join('');
  }

  function run() {
    var q = (input.value || '').trim().toLowerCase();
    var terms = q.split(/\s+/).filter(function (t) { return t.length > 1; });
    load().then(function () { render(terms); });
  }

  if (dialog && openBtn) {
    openBtn.addEventListener('click', function () {
      if (typeof dialog.showModal === 'function') dialog.showModal();
      else dialog.setAttribute('open', 'open');
      load().then(function () { render([]); });
      setTimeout(function () { if (input) input.focus(); }, 20);
    });
    if (input) {
      input.addEventListener('input', run);
      input.addEventListener('keydown', function (e) {
        if (e.key === 'Enter') {
          e.preventDefault();
          var first = results.querySelector('a');
          if (first) window.location.href = first.getAttribute('href');
        }
      });
    }
    document.addEventListener('keydown', function (e) {
      if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'k') {
        e.preventDefault();
        openBtn.click();
      }
    });
  }
})();


// --- live comments (only on the comments page) ---
(function () {
  'use strict';
  if (location.pathname.replace(/\/+$/, '') !== '/comments') return;
  var main = document.querySelector('main') || document.body;
  var wrap = document.createElement('section');
  wrap.className = 'live-comments';
  wrap.innerHTML =
    '<h2 id="say-something">Say something</h2>' +
    '<p class="fine">Comments are held for a wren to approve. No accounts, no tracking, no cookies.</p>' +
    '<form id="comment-form" autocomplete="off">' +
      '<label>Name <input name="name" maxlength="60" placeholder="optional"></label>' +
      '<label>Comment <textarea name="body" maxlength="1000" required rows="4" placeholder="Be kind. Be funny. Be brief."></textarea></label>' +
      '<input type="text" name="hp" class="hp" tabindex="-1" autocomplete="off" aria-hidden="true">' +
      '<button type="submit">Say it</button>' +
      '<p id="comment-status" role="status" class="fine"></p>' +
    '</form>' +
    '<div id="comment-list" aria-live="polite"><p class="fine">Loading comments...</p></div>';
  main.appendChild(wrap);

  var list = wrap.querySelector('#comment-list');
  var form = wrap.querySelector('#comment-form');
  var status = wrap.querySelector('#comment-status');

  function esc(t) { var d = document.createElement('div'); d.textContent = t == null ? '' : t; return d.innerHTML; }
  function render(items) {
    if (!items.length) { list.innerHTML = '<p class="fine">No approved comments yet. Yours could be the first.</p>'; return; }
    list.innerHTML = items.map(function (c) {
      return '<blockquote><p>' + esc(c.body) + '</p><footer>- ' + esc(c.name) + '</footer></blockquote>';
    }).join('');
  }
  fetch('/api/comments').then(function (r) { return r.json(); })
    .then(function (d) { render(d.comments || []); })
    .catch(function () { list.innerHTML = '<p class="fine">Could not load comments.</p>'; });

  form.addEventListener('submit', function (e) {
    e.preventDefault();
    var fd = new FormData(form);
    status.textContent = 'sending...';
    fetch('/api/comments', {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name: fd.get('name'), body: fd.get('body'), hp: fd.get('hp') })
    }).then(function (r) { return r.json(); })
      .then(function (d) {
        if (d.ok) { status.textContent = 'Thank you. ' + (d.note || 'Held for approval.'); form.reset(); }
        else { status.textContent = 'Could not post: ' + (d.error || 'error'); }
      })
      .catch(function () { status.textContent = 'Could not reach the server.'; });
  });
})();
