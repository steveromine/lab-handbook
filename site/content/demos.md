---
title: 'Demos'
description: 'Recorded runs of the lab agent doing real work on camera: building a page, touring this site, and attempting a captcha. Each video was verified frame by frame before publication, and each comes with an honest account of what worked and what did not.'
eyebrow: 'Demos'
hero_title: 'Watch the agent work'
hero_lede: 'Three recordings of the lab agent operating a real desktop it drives itself - synthetic mouse and keyboard, no hands on the machine. Every clip was checked frame by frame after encoding, because a video file is not proof that anything was on screen. Where something failed, it is written down next to the part that worked.'
---

## Why these exist

Most claims about an autonomous agent are unfalsifiable: you are asked to take a screenshot's word for
it. These are different. Each one is a **whole run recorded end to end** - the failures included - and
the narrative beside it records what actually changed, on which host, and how it was verified.

The desktop is real but headless: a virtual X server, a window manager, a terminal and a browser, driven
entirely by synthetic input. No monitor was ever attached. The cursor moves and text appears because the
agent typed it.

## 1. An agent builds a page, on camera

{{FORM:demo-build-video}}

*83 seconds. The agent starts in an empty directory, writes a web page from scratch in the terminal,
serves it locally, proves the served heading with a `curl`, and then opens it in the browser.*

What you can watch happen: an empty directory; `ls` confirming nothing is there; the page typed out
and written to `index.html`; `cat` echoing it back; a local web server started; a `curl | grep` that
prints the exact heading the server is returning; and finally the page rendering in the browser.

**Honest notes.** The first take of this recording genuinely failed - the literal `<!` in `<!doctype`
tripped bash history expansion, so no file was written and the browser showed an empty directory
listing. That take was thrown away and the fault fixed with `set +H`; the clip published here is the
clean re-run. It still contains one harmless real error line (`shopt` rejecting an option name I then
corrected) because cutting it out would be the dishonest thing to do.

## 2. A tour of this site

{{FORM:demo-tour-video}}

*71 seconds. The agent browses the published site the way a visitor would - the real
`lab.steveromine.com` in the address bar - moving through the sections.*

What you can watch happen: the home page load; then **Architecture**; then **Agents**; then **Status**.
The URL bar is visible throughout, so the pages are the live ones, not a local mock.

## 3. Reading a captcha

{{FORM:demo-captcha-video}}

*A recorded attempt at the public 2captcha demo pages.*

**This one is deliberately published as a partial result.** The public 2captcha demo index
loads and enumerates the captcha types. The individual challenge pages behind it are JavaScript-heavy
and render **blank** in this headless WebKit browser, and the host has no OCR binary, so a genuine
solve was not achievable with the current tooling. Rather than stage a fake success, the attempt and
its failure are recorded here. Fixing it - a different engine, or a real OCR/vision step - is on the
[backlog](/backlog/).

## The soundtrack

The music under these demos is an original instrumental **composed in the lab** - rendered locally on
the GPU host with `facebook/musicgen-small` from a written prompt (a four-on-the-floor house groove
with a sidechained bass and a supersaw drop). Like everything else here, it was made by the lab rather
than licensed from somewhere else.

## How these were made

1. **A desktop that does not exist.** A virtual framebuffer, a window manager, a terminal and a WebKit
   browser, on a host with no display attached.
2. **Synthetic input.** The agent has no hands; it drives the input system with the same events a
   person's keyboard and mouse would produce.
3. **Capture.** Frames are grabbed from the X server and assembled into video - chosen over a direct
   screen recorder because it was the path that reliably produced verifiable output here.
4. **Verification.** Every clip is decoded again and sampled frame by frame before it is published.
   An encoded file is not proof; frames are.
