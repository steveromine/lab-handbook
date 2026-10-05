/* Lab Handbook site script: nav toggle, colour theme, static search. No dependencies. */
(function () {
  'use strict';
  var STORE_KEY = 'lab-handbook-theme';
  var root = document.documentElement;

  // --- theme ---
  try {
    var saved = localStorage.getItem(STORE_KEY);
    if (saved === 'light' || saved === 'dark' || saved === 'ftcb') root.setAttribute('data-theme', saved);
  } catch (e) {}
  var themeBtn = document.querySelector('[data-theme-toggle]');
  if (themeBtn) {
    themeBtn.addEventListener('click', function () {
      var current = root.getAttribute('data-theme');
      if (!current) {
        current = window.matchMedia('(prefers-color-scheme: light)').matches ? 'light' : 'dark';
      }
      var next = current === 'light' ? 'dark' : (current === 'ftcb' ? 'dark' : 'light');
      root.setAttribute('data-theme', next);
      try { localStorage.setItem(STORE_KEY, next); } catch (e) {}
    });
  }

  // --- hidden theme: FTCB (hold the theme button for 1.5s) ---
  if (themeBtn) {
    var HOLD_MS = 1500, holdTimer = null;
    var engage = function () {
      root.setAttribute('data-theme', 'ftcb');
      try { localStorage.setItem(STORE_KEY, 'ftcb'); } catch (e) {}
      themeBtn.setAttribute('title', 'FTCB');
      holdTimer = null;
    };
    var startHold = function () { if (!holdTimer) holdTimer = setTimeout(engage, HOLD_MS); };
    var cancelHold = function () { if (holdTimer) { clearTimeout(holdTimer); holdTimer = null; } };
    ['mousedown', 'touchstart', 'pointerdown'].forEach(function (ev) { themeBtn.addEventListener(ev, startHold); });
    ['mouseup', 'mouseleave', 'touchend', 'touchcancel', 'pointerup', 'pointerleave'].forEach(function (ev) { themeBtn.addEventListener(ev, cancelHold); });
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
      '<div class="captcha" id="captcha">' +
        '<button type="button" id="captcha-btn" aria-describedby="captcha-state">' +
          '<span class="captcha-box" aria-hidden="true"></span>' +
          '<span>I am not a robot</span>' +
        '</button>' +
        '<span id="captcha-state" class="fine">proves you are human by solving a tiny puzzle - no third-party code</span>' +
      '</div>' +
      '<button type="submit" id="comment-submit" disabled>Say it</button>' +
      '<p id="comment-status" role="status" class="fine"></p>' +
    '</form>' +
    '<div id="comment-list" aria-live="polite"><p class="fine">Loading comments...</p></div>';
  main.appendChild(wrap);

  var list = wrap.querySelector('#comment-list');
  var form = wrap.querySelector('#comment-form');
  var status = wrap.querySelector('#comment-status');
  var box = wrap.querySelector('#captcha');
  var btn = wrap.querySelector('#captcha-btn');
  var state = wrap.querySelector('#captcha-state');
  var submit = wrap.querySelector('#comment-submit');
  var loadedAt = Date.now() / 1000;
  var proof = null;

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

  function hex(buf) { return Array.prototype.map.call(new Uint8Array(buf), function (b) { return ('0' + b.toString(16)).slice(-2); }).join(''); }
  function sha(s) { return crypto.subtle.digest('SHA-256', new TextEncoder().encode(s)).then(hex); }
  function solve(nonce, bits, onProgress) {
    var prefix = new Array(bits + 1).join('0');
    var i = 0, hashes = 0;
    function round() {
      var batch = [];
      for (var k = 0; k < 128; k++) batch.push(sha(nonce + (i + k)));
      return Promise.all(batch).then(function (hs) {
        hashes += hs.length;
        for (var k = 0; k < hs.length; k++) if (hs[k].slice(0, bits) === prefix) return { solution: i + k, hashes: hashes };
        i += 128;
        if (onProgress && (i % 2048 === 0)) onProgress(hashes);
        return round();
      });
    }
    return round();
  }

  btn.addEventListener('click', function () {
    if (proof) return;
    if (!crypto.subtle) { state.textContent = 'This needs a secure (https) connection.'; return; }
    box.classList.add('working'); btn.disabled = true;
    state.textContent = 'fetching challenge...';
    var t0 = performance.now();
    fetch('/api/challenge').then(function (r) { return r.json(); }).then(function (c) {
      if (!c.ok) throw new Error('no challenge');
      state.textContent = 'solving puzzle (0 hashes)...';
      return solve(c.nonce, c.bits, function (h) { state.textContent = 'solving puzzle (' + h.toLocaleString() + ' hashes)...'; })
        .then(function (res) {
          proof = { nonce: c.nonce, solution: res.solution, t0: loadedAt };
          var ms = Math.round(performance.now() - t0);
          box.classList.remove('working'); box.classList.add('done');
          state.textContent = 'verified - solved ' + res.hashes.toLocaleString() + ' hashes in ' + ms + ' ms. No third-party code involved.';
          submit.disabled = false;
        });
    }).catch(function (e) {
      box.classList.remove('working'); btn.disabled = false;
      state.textContent = 'could not get a challenge (' + ((e && e.message) || 'error') + ')';
    });
  });

  form.addEventListener('submit', function (e) {
    e.preventDefault();
    var fd = new FormData(form);
    if (!proof) { status.textContent = 'Tick the box above first.'; return; }
    status.textContent = 'posting...';
    fetch('/api/comments', {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ name: fd.get('name'), body: fd.get('body'), hp: fd.get('hp'),
        nonce: proof.nonce, solution: proof.solution, t0: proof.t0 })
    }).then(function (r) { return r.json(); })
      .then(function (d) {
        if (d.ok) {
          status.textContent = 'Thank you. ' + (d.note || 'Held for approval.');
          form.reset(); proof = null; submit.disabled = true;
          box.classList.remove('done'); btn.disabled = false;
          state.textContent = 'Tick the box to post another.';
        } else {
          status.textContent = 'Could not post: ' + (d.error || 'error') + ' - tick the box to retry.';
          proof = null; submit.disabled = true; box.classList.remove('done'); btn.disabled = false;
        }
      })
      .catch(function () { status.textContent = 'Could not reach the server.'; });
  });
})();

// --- uptime tally (uptime page only) ---
(function () {
  'use strict';
  var el = document.querySelector('[data-uptime]');
  if (!el) return;
  function nines(p) {
    if (p == null) return '-';
    if (p >= 99.99) return '4'; if (p >= 99.9) return '3';
    if (p >= 99) return '2'; if (p >= 90) return '1'; return '0';
  }
  function ts(t) { return t ? new Date(t * 1000).toISOString().replace('T', ' ').slice(0, 16) + ' UTC' : '-'; }
  fetch('/api/uptime').then(function (r) { return r.json(); }).then(function (d) {
    var s = (d && d.stats) || {};
    el.innerHTML = '<ul class="uptime-stats">' +
      '<li><strong>Uptime</strong><span>' + (s.uptime_pct == null ? '-' : s.uptime_pct + '%') + '</span></li>' +
      '<li><strong>Nines</strong><span>' + nines(s.uptime_pct) + '</span></li>' +
      '<li><strong>Samples</strong><span>' + (s.samples || 0) + ' (' + (s.up || 0) + ' up)</span></li>' +
      '<li><strong>Since</strong><span>' + ts(s.since) + '</span></li>' +
      '</ul>';
  }).catch(function () {
    el.innerHTML = '<p class="fine">Tally unavailable right now - which, fittingly, tells you something.</p>';
  });
})();


// --- self-test page ---
(function () {
  'use strict';
  var root = document.querySelector('[data-selftest]');
  if (!root) return;
  var btn = document.createElement('button');
  btn.type = 'button'; btn.textContent = 'Run the checks';
  btn.className = 'selftest-run';
  var out = document.createElement('ul'); out.className = 'selftest-results';
  root.innerHTML = ''; root.appendChild(btn); root.appendChild(out);
  function row(name, ok, detail) {
    var li = document.createElement('li');
    li.className = ok ? 'ok' : 'bad';
    li.innerHTML = '<strong>' + (ok ? 'PASS' : 'FAIL') + '</strong> ' + name + (detail ? ' <span class="fine">- ' + detail + '</span>' : '');
    out.appendChild(li);
  }
  async function check(name, fn) {
    try { var d = await fn(); row(name, true, d || ''); }
    catch (e) { row(name, false, (e && e.message) || 'failed'); }
  }
  btn.addEventListener('click', async function () {
    out.innerHTML = '';
    await check('JavaScript is alive', async function () { return 'yes'; });
    await check('Comments API answers', async function () {
      var r = await fetch('/api/comments'); var d = await r.json();
      if (!d.ok) throw new Error('not ok'); return (d.comments || []).length + ' approved';
    });
    await check('Uptime API answers', async function () {
      var r = await fetch('/api/uptime'); var d = await r.json();
      if (!d.ok) throw new Error('not ok'); return (d.stats && d.stats.samples) + ' samples';
    });
    await check('Generated images load', async function () {
      await new Promise(function (res, rej) { var i = new Image(); i.onload = res; i.onerror = rej; i.src = '/assets/gallery-2026-10-02.webp'; });
      return 'gallery image ok';
    });
    await check('Navigation present', async function () {
      var n = document.querySelectorAll('.site-nav a').length;
      if (!n) throw new Error('no nav links'); return n + ' links';
    });
    await check('Theme control present', async function () {
      if (!document.querySelector('[data-theme-toggle], .theme-toggle, button')) throw new Error('no control');
      return 'ok';
    });
  });
})();

// --- public backlog: request form (proof-of-work) + reviewed list ---
(function () {
  'use strict';
  var enc = new TextEncoder();

  async function digestHex(s) {
    var buf = await crypto.subtle.digest('SHA-256', enc.encode(s));
    return Array.prototype.map.call(new Uint8Array(buf), function (b) {
      return ('0' + b.toString(16)).slice(-2);
    }).join('');
  }

  async function solve(ts, sig, difficulty) {
    var target = '0'.repeat(difficulty);
    var n = 0;
    for (;;) {
      var h = await digestHex(ts + ':' + sig + ':' + n);
      if (h.indexOf(target) === 0) return n;
      n++;
      if (n > 5000000) return null;
    }
  }

  function esc(s) {
    return String(s).replace(/[&<>"']/g, function (c) {
      return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
    });
  }

  var form = document.getElementById('request-form');
  if (form) {
    var status = document.getElementById('rq-status');
    var submit = document.getElementById('rq-submit');
    var sending = false;
    submit.disabled = false;
    form.addEventListener('submit', async function (e) {
      e.preventDefault();
      if (sending || !form.reportValidity()) return;
      sending = true;
      submit.disabled = true;
      status.textContent = 'Preparing your submission…';
      try {
        if (!window.crypto || !crypto.subtle) throw new Error('A secure, modern browser is required.');
        // Obtain a fresh challenge for every attempt, including retries and second requests.
        var r = await fetch('/api/challenge', { cache: 'no-store' });
        if (!r.ok) throw new Error('Could not prepare the submission. Please retry.');
        var c = await r.json();
        var started = Date.now();
        var nonce = await solve(c.ts, c.sig, c.difficulty || 4);
        if (nonce === null) throw new Error('Preparation timed out. Please retry.');
        await new Promise(function (resolve) { setTimeout(resolve, Math.max(0, 3100 - (Date.now() - started))); });
        var body = new URLSearchParams(new FormData(form));
        body.set('ts', c.ts); body.set('sig', c.sig); body.set('nonce', nonce);
        status.textContent = 'Sending…';
        r = await fetch('/api/request', { method: 'POST', body: body });
        var result = await r.json();
        if (!r.ok || !result.ok) throw new Error(result.error || result.message || 'Could not submit. Please retry.');
        status.textContent = result.message || 'Queued for review.';
        form.reset();
      } catch (error) {
        status.textContent = error.message || 'Could not reach the server. Please retry.';
      } finally {
        sending = false;
        submit.disabled = false;
      }
    });
  }

  var list = document.getElementById('backlog-list');
  if (list) {
    fetch('/api/backlog').then(function (r) { return r.json(); }).then(function (d) {
      var items = (d && d.items) || [];
      if (!items.length) {
        list.innerHTML = '<p class="fine">Nothing has been accepted yet. Yours could be the first.</p>';
        return;
      }
      list.innerHTML = items.map(function (it) {
        return '<article class="backlog-item">' +
          '<h3>' + esc(it.title) + '</h3>' +
          '<p class="fine"><span class="pill pill-live">' + esc(it.kind || 'request') + '</span> ' +
          '<span class="pill">' + esc(it.state || it.status || 'open') + '</span>' +
          (it.who ? ' · asked by ' + esc(it.who) : ' · anonymous') + '</p>' +
          '<p>' + esc(it.detail) + '</p>' +
          '</article>';
      }).join('');
    }).catch(function () {
      list.innerHTML = '<p class="fine">The backlog is unavailable right now.</p>';
    });
  }
})();

// --- handbook chat ---
(function () {
  'use strict';
  var form = document.getElementById('chat-form');
  if (!form) return;
  var log = document.getElementById('chat-log');
  var statusEl = document.getElementById('chat-status');
  var input = document.getElementById('chat-q');
  var btn = document.getElementById('chat-send');

  function esc(s) {
    return String(s).replace(/[&<>"']/g, function (c) {
      return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
    });
  }
  function add(cls, who, text, sources) {
    var d = document.createElement('div');
    d.className = 'chat-msg ' + cls;
    var body = '<p class="chat-who">' + esc(who) + '</p><p>' + esc(text) + '</p>';
    if (sources && sources.length) {
      body += '<p class="fine">Sources: ' + sources.map(function (s) {
        return '<a href="' + esc(s.u) + '">' + esc(s.t) + '</a>';
      }).join(' · ') + '</p>';
    }
    d.innerHTML = body;
    log.appendChild(d);
    d.scrollIntoView({ block: 'nearest' });
  }

  form.addEventListener('submit', function (e) {
    e.preventDefault();
    var q = input.value.trim();
    if (q.length < 3) { if (statusEl) statusEl.textContent = 'Please type a longer question.'; return; }
    add('me', 'You', q);
    input.value = '';
    if (btn) btn.disabled = true;
    if (statusEl) statusEl.textContent = 'Thinking…';
    var enc2 = new TextEncoder();
    function dhex(s) {
      return crypto.subtle.digest('SHA-256', enc2.encode(s)).then(function (b) {
        return Array.prototype.map.call(new Uint8Array(b), function (x) { return ('0' + x.toString(16)).slice(-2); }).join('');
      });
    }
    function solve2(ts, sig, diff) {
      var target = '0'.repeat(diff), n = 0;
      return (function step() {
        return dhex(ts + ':' + sig + ':' + n).then(function (h) {
          if (h.indexOf(target) === 0) return n;
          n++; if (n > 5000000) return null;
          return step();
        });
      })();
    }
    fetch('/api/challenge').then(function (r) { return r.json(); }).then(function (c) {
      return solve2(c.ts, c.sig, c.difficulty || 4).then(function (nonce) {
        return { ts: c.ts, sig: c.sig, nonce: nonce };
      });
    }).then(function (ch) {
      return fetch('/api/chat', {
        method: 'POST', headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ q: q, ts: ch.ts, sig: ch.sig, nonce: ch.nonce })
      });
    }).then(function (r) { return r.json().then(function (j) { return { ok: r.ok, j: j }; }); })
      .then(function (res) {
        if (statusEl) statusEl.textContent = '';
        if (res.j && res.j.answer) add('bot', 'Handbook', res.j.answer, res.j.sources);
        else add('bot', 'Handbook', (res.j && res.j.error) || 'Something went wrong - try again.');
      })
      .catch(function () { if (statusEl) statusEl.textContent = 'Could not reach the assistant.'; })
      .then(function () { if (btn) btn.disabled = false; });
  });
})();
// --- subscribe form: solve the challenge before submitting (subscribe solves challenge) ---
(function () {
  'use strict';
  var f = document.querySelector('.subscribe');
  if (!f) return;
  var enc = new TextEncoder();
  function dhex(s) {
    return crypto.subtle.digest('SHA-256', enc.encode(s)).then(function (b) {
      return Array.prototype.map.call(new Uint8Array(b), function (x) { return ('0' + x.toString(16)).slice(-2); }).join('');
    });
  }
  function solve(ts, sig, diff) {
    var target = '0'.repeat(diff), n = 0;
    return (function step() {
      return dhex(ts + ':' + sig + ':' + n).then(function (h) {
        if (h.indexOf(target) === 0) return n;
        n++; if (n > 5000000) return null;
        return step();
      });
    })();
  }
  var ready = false;
  fetch('/api/challenge').then(function (r) { return r.json(); }).then(function (c) {
    return solve(c.ts, c.sig, c.difficulty || 4).then(function (nonce) {
      var set = function (id, v) { var e = document.getElementById(id); if (e) e.value = v; };
      set('nl-ts', c.ts); set('nl-sig', c.sig); set('nl-nonce', String(nonce));
      ready = true;
    });
  }).catch(function () {});
  f.addEventListener('submit', function (e) {
    if (ready) return;               // challenge solved, let it through
    e.preventDefault();              // otherwise fetch one, then submit
    fetch('/api/challenge').then(function (r) { return r.json(); }).then(function (c) {
      return solve(c.ts, c.sig, c.difficulty || 4).then(function (nonce) {
        var set = function (id, v) { var el = document.getElementById(id); if (el) el.value = v; };
        set('nl-ts', c.ts); set('nl-sig', c.sig); set('nl-nonce', String(nonce));
        f.submit();
      });
    }).catch(function () { f.submit(); });
  });
})();
