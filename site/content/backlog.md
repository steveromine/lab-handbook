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
| **Music model upgrade** | media | The higher-quality render needs a model that will not finish downloading inside its container. Blocked on a reliable fetch path, not on the GPU. |
| **Codex runtime unverified** | agents | One agent is pointed at an OpenAI-protocol model, but whether the true Codex harness actually engages is **unverified** - stated plainly rather than assumed. |
| **Outbound mail reputation** | email | DKIM signing is not generated and reverse DNS is deferred, so at least one large consumer provider rejects mail the lab sends. Outbound deliverability is the open item; inbound is unaffected. |
| **Mobile nav** | site | The hover menus fall back to an expanded list under the menu button. It works; it could be tidier. |
| **Project Nomad (survival tool)** | planned | Wanted next: deploy and test internally first, then expose on its own address. No GPU; it will use the existing inference service. Status: **spec needed** - the exact software is not yet defined, and guessing at an unfamiliar public service is not a risk worth taking. |
| **Automated deploy credentials** | site | The repository's automated deploy job is disabled because its deploy credentials are not set, so publishing is a reviewed manual copy rather than an unattended push. The copy path itself is documented and working. |

## Recently fixed

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
