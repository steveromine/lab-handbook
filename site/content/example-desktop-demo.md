---
title: 'An agent, a desktop, and a website it built on camera'
description: 'A worked example of driving the lab agent: a headless desktop, synthetic mouse and keyboard, a prompt that builds a page, and a recording of the whole run - with an honest account of what actually changed.'
eyebrow: 'Example'
hero_title: 'An agent builds a website, on camera'
hero_lede: 'A worked example of how to interact with this lab: a virtual desktop with no monitor, synthetic mouse and keyboard, a prompt that builds a page - and a video of the whole run. The agent recorded itself doing it. There was no human at the keyboard.'
---

## What this shows

This is an example, end to end, of how to get work out of the lab agent - and how the lab tries to be
honest about it. A prompt is given; the agent builds a page; the page goes live; and the whole thing is
recorded so you can see it happen rather than take my word for it.

It is deliberately unglamorous. The point is not that the result is beautiful. The point is that **the
work is visible**, and that **the parts that did not work are written down next to the parts that did**.

## The recording

<video controls preload="metadata" poster="/assets/desktop-demo.png" src="/assets/desktop-demo.mp4"></video>

*28 seconds, 1280x720. A headless X desktop (Xvfb), a window manager, a terminal, and a web browser -
driven entirely by synthetic mouse and keyboard input, recorded with ffmpeg. No monitor was ever
attached. The cursor moves and text appears because the agent typed it.*

## The process, step by step

1. **A desktop that does not exist.** The host has no monitor and no desktop. One is built: a virtual X
   server, a lightweight window manager, and a terminal.
2. **Synthetic input.** The agent does not have hands. It types and clicks by driving the input system
   directly - the same events a person's keyboard and mouse would produce.
3. **A prompt.** The instruction is typed into the terminal: build a website about yourself.
4. **The build.** The page is generated and served.
5. **The browser.** The built page is opened and rendered.
6. **The recording.** The whole run is captured to video, then verified frame by frame before it is
   published here - because an encoded file is not proof that anything was on screen.

## What actually changed

Being specific, because "it worked" is not a change log:

- **Installed** a minimal GUI stack on the agent host: a virtual framebuffer, a window manager, an X
  terminal, a WebKit browser, and two small paint programs.
- **Added** a site page and its assets: the demo video (139 KB, h264, faststart) and a poster frame.
- **No service was restarted. No existing guest was touched.** The work is additive.
- **Fixed three real faults along the way**, each of which is now written down: the window manager was
  being started with an argument it does not accept; the browser needed a session bus it was not being
  given; and the browser was inheriting a proxy meant for something else, which refused its requests.

## The honest part: the video was the agent, too

Every demo of an agent quietly asks the same question - *who is really doing this?* So, plainly:

**The video was made by the agent operating the desktop itself.** The hands on the keyboard were
synthetic. The agent chose what to type, typed it, opened the browser, and recorded the result. Nobody
sat at a machine and drove it for the camera.

What that does **not** prove is that the agent is clever. It proves the loop is closed: a prompt went in,
a page came out, the page is live, and the evidence is a video you can watch. Where a step failed, the
failure is written down here rather than edited out.

*The page this example describes is live on its own host; the recording above is the run that produced it. Nothing here links to a host the public handbook is not cleared to name.*
