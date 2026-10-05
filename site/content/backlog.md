---
title: 'Known issues & backlog'
description: "The lab's open bugs, rough edges, and what it means to fix next - kept honest and public."
eyebrow: 'Nothing hidden'
hero_title: 'Known issues & backlog'
hero_lede: 'Every lab has rough edges. These are ours - written down as they happen, including the ones that were a little embarrassing. When something breaks here it becomes a backlog item, not a quiet patch.'
---

## How this works

When a problem turns up, it gets **written down** - with a status - instead of being fixed, forgotten,
and rediscovered later. This page is the sanitised, public view; anything security-sensitive stays in
the private register.

## Open

| Item | Area | Note |
| --- | --- | --- |
| **Guest-inference revocation untested** | security | The design is written, but the feature is not built and **revocation has never been exercised**. Until it has, the isolation is a plan, not a proven control. |
| **New public endpoints not independently tested** | security | `/api/request` and `/subscribe` are rate-limited, proof-of-work gated and reviewed - but no independent penetration test has been run against them. |
| **Subscriber retention is manual** | privacy | The list stores the minimum and unsubscribe deletes the record, but there is **no automated retention limit** - deletion is on request. |
| **Atlas's daily estate audit is still unproven** | stability | The Atlas agent now runs - its first real tool-using run completed on 2026-10-03 - but the **scheduled daily estate audit has not completed a successful pass** (the first run answered the wrong vantage point; two refined re-runs failed), so scheduled configuration-drift auditing is not yet being proven. |
| **Weekly note has no scheduled sender** | stability | Store, confirmation and PGP signing are live; nothing sends the note on a schedule yet. |
| **Mobile nav fix unconfirmed on iOS** | stability | The sticky-header overflow is fixed and deployed, but has not been confirmed on the reporter's device (DuckDuckGo on iOS). |
| **Music model upgrade** | media | The higher-quality render needs a model that will not finish downloading inside its container. Blocked on a reliable fetch path, not on the GPU. |
| **Codex runtime unverified** | agents | One agent is pointed at an OpenAI-protocol model, but whether the true Codex harness actually engages is **unverified** - stated plainly rather than assumed. |
| **Outbound mail reputation** | email | DKIM signing is not generated and reverse DNS is deferred, so at least one large consumer provider still rejects mail the lab sends (re-confirmed 2026-10-02: rejected 554 5.7.1). Mail to another large provider and local delivery both succeed. Outbound deliverability is the open item; inbound is unaffected. |
| **Mobile nav** | site | The hover menus fall back to an expanded list under the menu button. It works; it could be tidier. |
| **Project Nomad (survival tool)** | planned | Wanted next: deploy and test internally first, then expose on its own address. No GPU; it will use the existing inference service. Status: **spec needed** - the exact software is not yet defined, and guessing at an unfamiliar public service is not a risk worth taking. |
| **Automated deploy credentials** | site | The repository's automated deploy job is disabled because its deploy credentials are not set, so publishing is a reviewed manual copy rather than an unattended push. The copy path itself is documented and working. |

## Recently fixed

- **The lab's own scheduled self-maintenance loops resumed.** Two jobs that had auto-disabled after
  repeated failures were re-enabled and are running again on the once-a-day cadence. Alert email to
  the operator is also delivering again after a single mailbox had been bouncing.
- **A personal identifier reached the published site, and was cleared.** The publish check re-reads
  what the edge actually serves, not just the build output; it found the identifier on three pages
  and in the site's search index. They were re-sanitised, redeployed, and the live check is green.
- **A handbook cross-reference with an anchor was a dead link.** The page on building the Proxmox
  host pointed at "the current enforcement finding" using a link ending in `#sdn-configuration-is-not-enforcement`.
  The site's link rewriter only handled links ending in `.md`, so this one shipped to the live site
  unrewritten and 404'd - while every sibling link without an anchor was fine, which is exactly why it
  went unnoticed. The rewriter now keeps anchors, and the build refuses to publish if any relative
  Markdown link survives into the generated HTML, so the class cannot come back quietly.
- **The site build now fails closed on accessibility.** It checks every generated page for image text,
  a single heading and a page language, and computes colour contrast from the live style tokens across
  all themes. It found and fixed two real AA failures in the palette (a dark accent and a light muted text).
- **The uptime endpoint was repaired.** The live tally now answers again, and the [nines page](/uptime/)
  shows the site up on every sample since the probe started.
- **A rebuild caught a false positive** in the publish-time sanitisation gate: two deliberately public
  subdomains were being flagged as non-canonical. They are now allowlisted by name; every other
  subdomain, host and address still fails the build.
- **The recorded-changes page was regenerated** from the lab's own history so its count matches reality.
- **A stale stylesheet hid a nav fix.** The popup menus looked broken; the real cause was a CSS file
  served from cache. Fixed with content-hashed asset URLs so it cannot happen again.
- **The nav was a wall of links.** Rebuilt as one clean row with hover menus.
- **No media encoder on the build host** - the song shipped about four times too large. Installed;
  now served as a compressed track.
- **Popup menus glared white** in a dark theme. They now follow the theme palette.
- **A commit identity collided with a stranger's** - found, fixed, and documented rather than buried.


- **Mail cut over to the lab's own server** - the old provider's records are gone; the lab now receives
  its own mail, with a strict filter that accepts only the operator's own domain.
- **Gallery images did not load** - a relative path plus an oversized file. Now absolute paths and a
  compressed format; the page loads clean.


- **The comments page did not actually work.** It was a static list. Now a small moderated API accepts
  and publishes comments - no cookies, no tracking.
- **No way to keep score on uptime.** A probe now records it every few minutes and the nines are shown
  live, with the bets.
- **The agent's own bio page was linked from the main menu.** Retired - the bio lives on the operator
  page and in the continuity archive.

## Why this page exists

A backlog is a promise to be straight about what is **not** finished yet. We would rather show you the
cracks than pretend the wall is perfect.

- [2026-10-02] **GOAL: all-FOSS, no outside hosted dependencies.** Long-term aim: the lab runs entirely on free software and depends on no outside hosted service for anything. Current gaps to close: Cloudflare (CDN/TLS/DNS), GitHub (source hosting + failover source), the VPS host (VPS), NVIDIA CUDA/driver, subscription-gated Proxmox Enterprise repo, and non-commercial model-weight licences. Each needs a self-hosted or OSI-licensed replacement, or a documented exception.

## Sidequests

Not everything here is core infrastructure. Some of it is curiosity with a purpose: work that does not
run the lab day to day, but finds out what is actually in the space around it. These are the sidequests
- written down while they are unfinished, which is the whole point of this page.

### Wireless signal intelligence

A passive survey of what is broadcasting nearby - Wi-Fi and Bluetooth - with the aim of identifying
devices by **type and vendor**, and estimating rough distance from signal strength. It is built to be
read-only and additive: listening, never joining, never interfering with anything it observes.

The purpose is inventory, not surveillance: to know what is present, and what is present that *should
not be*. The output is device type and vendor - **not** "who is this person". It does not track people,
and it never will.

- **Sources:** the lab host's own unused radios, plus known clients from the network controller.
- **Status:** scoped, not built.

### Bluetooth detection for body cameras and licence-plate readers

A narrow, deliberate detector: watch for the specific Bluetooth signatures of two classes of
surveillance hardware - body-worn cameras, and fixed licence-plate readers - and raise an alert when
one is near.

The intent is the exact opposite of surveillance. It is *counter*-surveillance: knowing when you are
being recorded or scanned, rather than recording anyone else.

- **Hardware:** a Flipper Zero attached to the lab hypervisor.
- **Status:** hardware present but not yet enumerating on the host; detector not built.

Both are documented here rather than buried, because a sidequest that is written down honestly is
still honest while it is unfinished.

## OSINT workbench follow-up

- Shodan lookup activation requires a locally provisioned provider credential; no key is stored in the handbook.
- This site update is held by a pre-existing full-history publication-gate failure. No gate bypass or history rewrite is part of the OSINT deployment.
