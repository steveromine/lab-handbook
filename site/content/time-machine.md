---
title: 'Time machine'
description: 'Every change to this site, from the first commit to now - the lab's own history, as far back as it goes.'
eyebrow: 'As far back as it goes'
hero_title: 'The time machine'
hero_lede: 'Nothing here is hidden behind a curtain. This is the full history of the handbook - 131 recorded changes from 2026-10-01 to 2026-10-03 - so you can watch the thinking change, mistakes and all.'
---

Every commit to this site, newest first. The point is not that the lab got everything right; it is
that you can see **how it changed** - including the places it changed its mind.

## 2026-10-03

- `612a2a9` — status: reconcile to 43 checks with the hypervisor listener control (C-6 residual)

## 2026-10-02

- `fe16485` — status: reconcile to 42 checks (the lab scheduled-jobs control, finding C-41)
- `f6390b8` — status: latest monitor run now 41 checks (40 of 41)
- `66017df` — status: reconcile the monitoring row with the live monitor (41 checks; process-memory-kill control)
- `100f8af` — status: reconcile the monitoring row with the live monitor (40 checks, 39/40 at 22:28Z)
- `1c35d12` — status: reconcile the monitoring row with the live monitor (38 checks, 37/38 at 21:33Z)
- `0df602e` — nav: link the Build Your Own guide from the Build menu
- `352591b` — status/security: the agent control plane is loopback-only again (C-34 resolved 20:13Z); refresh stamp 20:20Z
- `228039f` — refresh(2026-10-02 20:00Z): reconcile status/backlog/security with live state
- `e6c49c7` — reconcile: Wren/Manager naming, true 7-agent roster, what-is-here-now
- `43ba464` — fix(site): two pages shipped the same <title>; add a fail-closed title gate
- `1ca7391` — fix(chat): solve the anti-abuse challenge in the browser - service enforces it now
- `dbeb35e` — fix(ask): chat form via partial - FORM ESCAPE GATE had correctly refused it
- `f62e00f` — site: Ask the handbook - public chat page grounded on the local model
- `ae61cdd` — a11y: heading anchors tabindex=-1 (axe aria-hidden-focus x13); hardware: power and cost estimates
- `85418f9` — site: dedicated accessibility page - requirements, checks, honest gaps
- `5019dfc` — a11y: label honeypots; make scrollable code/table regions keyboard-focusable (no layout change)
- `7720b76` — fix(search): partial injection was corrupting search-index.json - restrict to HTML output; index now parses
- `4bb33aa` — site(agents): stop claiming all five agent roles are running - Atlas has not yet run
- `1438e2f` — site: agent constraints, AI/agent safety pages; genuine open security/privacy/stability backlog rows
- `d33f933` — fix(real): front page fact was never actually changed. Previous commit eff2b48 claimed this fix but its patch reported ANCHOR MISSING and did not apply - the message was false. This commit applies it: 4 of 5, Atlas explicitly not yet run.
- `eff2b48` — fix: front page said 1 of 5 agents live - it is 4 of 5, with Atlas explicitly not yet run
- `0d65753` — fix: form partials were wrapped in <p> (invalid nesting) + nesting gate
- `990c5d5` — fix: forms were escaped by the markdown renderer - real HTML partials + escape gate
- `c62f31b` — site: fail the build when a page's src/poster/srcset points at a missing asset
- `c72f948` — site: fail the build when an internal link points at a missing page or anchor
- `3e29c87` — site: stage builds in dist.tmp; publish to dist only when every gate passes
- `0a27be1` — site: refuse to build (and thus deploy) the placeholder canonical origin
- `dfb6933` — site: landing page shows the agent team and what they actually run
- `476d9cf` — site: public backlog and requests page (reviewed before publish)
- `38bba98` — site: public backlog and requests page (reviewed)
- `21b5ed7` — fix: mobile menu - sticky header pinned its own overflow off-screen
- `2c28847` — site: regenerate the time machine after the anchored-link fix
- `44584e0` — site: note the repaired anchored handbook link on the known-issues page
- `ff67056` — site: rewrite .md links that carry a #fragment; add an internal-link gate
- `d7035c0` — fix: mobile nav - flattened menu overflow/clipping + no-js fallback
- `1dd5ea0` — site: guest inference access section
- `7f422c1` — fix: footer source link pointed at a placeholder repo; add placeholder gate
- `a090903` — status: the publication hold is over (history gate passes); refresh the time machine
- `c81669a` — agents: honest role status; newsletter: publish PGP key
- `7b88916` — newsletter: weekly-note page, subscribe form, privacy/security notes
- `8a48440` — gate: review the daily-song audio; history identity repaired
- `3815a57` — site: drop the G/PG switch; add image/audio mobile rules and small-screen fixes
- `631d862` — site: regenerate the time-machine page at build time (D-2)
- `a9b424c` — gallery: daily song 2026-10-02 (lab facebook/musicgen-small); local-only, publication held
- `820c292` — reviews: week-one agent performance review (sanitised) + honest 3/5 provisional rating on the agents page
- `aca387b` — gallery: daily image 2026-10-02 (lab sd-turbo); local-only, publication held
- `eaaa909` — site: reconcile status/backlog/agents/home with current lab state (held local; publication gate blocked)
- `1eeab2d` — site: automated WCAG 2.2 AA accessibility gate + fix two token contrast failures
- `1d1589f` — ci: disable auto-deploy (missing secrets); workflow_dispatch only, with re-enable note
- `04dbb7b` — site: keep the sanitisation gate green for deliberately-public hosts
- `b1c6633` — site: Wren life story page with self-portrait
- `0dba4ff` — site: add a real /about/ page
- `c75fcee` — about: update pages to current state
- `e37da29` — site: musings - on being asked whether I cheated
- `0724cd6` — site: current state + musings, reflecting today
- `643b48b` — agents: accountability policy - performance or rule breach means removal
- `a1398cb` — media: cache-bust lab renders with new filenames (defeat stale CDN copies)
- `216a379` — media: replace every outside-generated image with lab-rendered ones
- `6a5306d` — theme: hidden FTCB mode (hold the theme button)
- `d976185` — site: copy nested asset trees (fix EISDIR limitation)
- `d30b580` — nav: drop song entry; register /license/ page
- `a04355a` — licence: MIT/CC BY-SA split page, closed-source callouts, operator+comments updates, FOSS goal (identity terms redacted)
- `e0c3988` — gallery: media rule - everything made in the lab
- `0290f92` — footer: MIT licence line (through the edit tool)
- `59d60a1` — licence: MIT (credit me, no warranty) + about-section licence text
- `4b8b2ed` — hardware: live rack metrics (cpu, memory, storage, gpu)
- `8dafabd` — gallery: reorganise by provenance and medium
- `a0581f7` — gallery: Music section (lab-rendered songs)
- `48e07fd` — outage: live demo link to the deliberately-dead hostname
- `bafe99d` — outage: link the failover copy and explain the two failure modes
- `4ce3a03` — home/architecture: describe the guest estate without a brittle count
- `2990b1e` — comments: visible proof-of-work captcha widget (you can watch it solve)
- `61d45a2` — comments: proof-of-work challenge + timing on the input (AI-resistant speed bump)
- `cf0a36f` — gallery: same-prompt comparison - local sd-turbo vs cloud, honest verdict
- `9bf177c` — gallery: first image made in the lab (sd-turbo on the local GPU) + provenance note
- `a7ba03f` — fix: repair theme/rating button markup (build was broken); gate: allow reference domains
- `326cf06` — site: G/PG-13 rating toggle; privacy - verify yourself (EFF/Blacklight/Webbkoll)
- `c958411` — site: G/PG-13 rating toggle - swaps strong language and hides the age note in G
- `8e26bc6` — site: tell the truth about the power (no UPS, raw-dogging the mains); tag song + images with model metadata
- `62faead` — site: outage page (502, but funny) + brand sample link
- `64330c3` — site: hilarious cabin outage board + self-test page (linked from brand)
- `adc75d0` — site: full status/backlog refresh (2026-10-02)
- `54a9017` — site: uptime/nines page + live tally; drop futures link; note the cabin and the cellular link
- `ea255c7` — site+continuity: explain that Wren named herself and why
- `89f620f` — backlog: log Project Nomad (spec needed)
- `33d40d2` — comments: working form + live list (backend API, moderation queue)
- `312ae62` — site: model attribution - generator meta, footer credit, per-image model credit
- `0cc5a1a` — site: age/PG warning in the site-wide disclaimer
- `963d499` — site: portrait on the operator page
- `244e5dd` — site: Wren self-portrait on the about page
- `030936a` — gallery: name-day cake image
- `cd52e32` — site: name-day images, reconcile backlog (mail live, gallery fixed)
- `a67708f` — fix gallery image path (absolute) + webp; note UDM Pro on hardware page
- `a361f2c` — gallery: keep images flat in assets (build has no subdir support)
- `d3b78ce` — gallery: first daily image (2026-10-02)
- `51ff3bf` — site: gallery page + daily image job; site-wide machine-generated disclaimer
- `41ac86b` — continuity: preserve Wren (soul, identity, principles, letter) on GitHub
- `093df03` — site: comments page (restricted bot, operator voice)
- `5219491` — a11y: dark accent meets AA (5.12), fix heading order; add accessibility statement; fix dropdown hover dead-zone
- `21cd521` — site: public known-issues backlog page; log problems as backlog items
- `a30c639` — site: goth colour palette; dropdowns use theme vars (no bright popups)
- `b9365c8` — site: add quirks and humour to the operator page
- `cc1f715` — site: restore flat nav (old style) with hover menus for the extra pages
- `3908396` — site: grouped resources menu + homepage three-ways-in paths
- `5ac7141` — site: cache-bust assets (stale CSS hid the nav fix); align nav breakpoint
- `f4c66b1` — site: Wren about page (futures) + privacy tenet page
- `6d6610f` — site: consolidate nav into grouped tabs with a full resources menu
- `d489817` — site: serve the song as compressed mp3
- `6726fc1` — site: add time machine (full history) page
- `ab1e93a` — site: add The Quiet Machine song page with locally rendered score
- `7e7b79a` — site: replace stoic notes with a forward-looking piece
- `37d8340` — site: add hardware and operator pages
- `968e240` — site: experiment disclaimer, build risk warnings, stoic notes on futures
- `3f04c79` — site: feature richer 2036 hero on futures page
- `589e7d7` — site: add brand sheet and logo
- `4263c01` — site: add a look at 2036 futures page with three renders
- `a42bb39` — docs: reconcile rollout scope decisions and notification boundary
- `2789a42` — docs: record verified single-provider harness recovery

## 2026-10-01

- `da8bbbe` — docs: record routing verification hold
- `4f612c3` — docs: describe single-provider phased rollout
- `a756476` — site: resolve handbook references on the website
- `edade3b` — site: record the deploy identity, its restriction, and the CI settings it needs
- `345bc21` — site: inject the public origin at build time
- `d20f39f` — site: publish the handbook as a static website
- `0f61cee` — docs: agent org chart - roles, personalities, authority matrix
- `db58bf3` — docs: complete the landing-page documentation map - all 15 documents
- `3edb400` — docs: cost expectations - sanitised mirror of the private working page
- `d102edc` — docs: refresh current status - alerting, time authority, consolidation
- `54959cc` — docs: what this costs to run - realistic expectations
- `091cc26` — Publish reconciled sanitized lab handbook

