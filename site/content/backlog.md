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
| **Outbound mail reputation** | email | A reverse-DNS entry is deferred, so outbound mail is likelier to be flagged as spam. Inbound is unaffected. |
| **Mobile nav** | site | The hover menus fall back to an expanded list under the menu button. It works; it could be tidier. |
| **Project Nomad (survival tool)** | planned | Wanted next: deploy and test internally first, then expose on its own address. No GPU; it will use the existing inference service. Status: **spec needed** - the exact software is not yet defined, and guessing at an unfamiliar public service is not a risk worth taking. |

## Recently fixed

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

## Why this page exists

A backlog is a promise to be straight about what is **not** finished yet. We would rather show you the
cracks than pretend the wall is perfect.
