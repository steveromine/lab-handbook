---
title: 'Credits and licences'
description: 'Every product and service this lab runs on, open or closed, named with its licence - the full dependency list rather than the convenient excerpt.'
eyebrow: 'Standing on shoulders'
hero_title: 'Everything this lab leans on'
hero_lede: 'A lab is a stack of other people\'s work. This page names all of it - the open source, the closed source, and the non-commercial terms that quietly bind the generated media - because a credit you have to hunt for is not a credit.'
---

## How this page is meant to be read

The [licence page](/license/) states what *you* may do with this site. **This** page is the other half:
an inventory of everything the lab itself stands on, with the licence each piece carries. Where a term
is restrictive or non-commercial, it says so plainly rather than in a footnote.

Legends: **open** - OSI-approved or equivalent free licence · **source-available / controlled** - usable
but not free · **non-commercial** - restricts commercial use · **service** - a hosted product, not code.

## Platform and hypervisor

| Piece | Role | Licence |
|---|---|---|
| **Proxmox VE** | Hypervisor and container host | AGPLv3 (**open**) |
| **Debian** / **Ubuntu Server** | Guest and container base images | Various free (DFSG) (**open**) |
| **Linux kernel** | The actual operating system | GPLv2 (**open**) |

## Containers and orchestration

| Piece | Role | Licence |
|---|---|---|
| **Docker** / **containerd** | Container runtime | Apache-2.0 (**open**) |
| **LXC** | System containers | LGPL-2.1 (**open**) |

## Web, proxy and networking

| Piece | Role | Licence |
|---|---|---|
| **Caddy** | Edge reverse proxy, TLS | Apache-2.0 (**open**) |
| **Cloudflare** | DNS and edge CDN in front of the public site | **service** (closed, free tier) |
| **Tailscale** | Private overlay network | BSD-3-Clause client (**open**); coordination **service** (closed) |
| **OpenSSH** | Remote access | BSD-style (**open**) |
| **UFW** / **nftables** | Host firewalling | GPLv2 (**open**) |
| **Pi-hole** | Filtering DNS | EUPL-1.2 (**open**) |
| **fail2ban** | Intrusion defence | GPLv2 (**open**) |

## Mail and content delivery

| Piece | Role | Licence |
|---|---|---|
| **Postfix** | Mail transport | IBM Public Licence / EPL (**open**) |
| **Hosted mailbox** | Operator mailbox, sending and receiving | **service** (closed) |
| **GitHub** | Repository hosting and CI | **service** (closed, free tier) |

## Storage, monitoring and infrastructure

| Piece | Role | Licence |
|---|---|---|
| **ZFS** (OpenZFS) | Checksummed storage | CDDL (**open**) |
| **LVM2** | Thin-provisioned guest volumes | GPLv2 / LGPL-2.1 (**open**) |
| **systemd** | Services and timers | LGPL-2.1 (**open**) |
| **rsync** | Site publication | GPLv3 (**open**) |
| **Prometheus** (where used) | Metrics collection | Apache-2.0 (**open**) |
| **Grafana** (where used) | Dashboards | AGPLv3 (**open**) |

## Media

| Piece | Role | Licence |
|---|---|---|
| **Plex** | Media front-end | **source-available / controlled** (closed, proprietary) |
| **Jellyfin** | Media front-end | GPLv2 (**open**) |
| **FFmpeg** | Transcoding, muxing, capture | LGPL/GPL (**open**) |
| **MusicGen** (`facebook/musicgen-*`) | In-lab song and soundtrack generation | **non-commercial** (CC-BY-NC weights) |
| **SD-Turbo** (`stabilityai/sd-turbo`) | In-lab image generation | **non-commercial** community terms |
| **Whisper** (where used) | Speech-to-text | MIT (**open**, weights MIT) |

## AI runtime and models

| Piece | Role | Licence |
|---|---|---|
| **llama.cpp** | Local model inference server | MIT (**open**) |
| **llama-swap** | Loads the requested model on demand and unloads the last, so a set of models shares one 8 GB card | MIT (**open**) |
| **Qwen2.5** (and variants) | The default local language model (`ops-llm`) | Apache-2.0 (**open**) |
| **Qwen3.5 / Qwen3.8** (optional) | Optional selectable local models - not used by any agent | Apache-2.0 for most weights; **check each model card**, derivatives vary |
| **DeepSeek** models | Agent reasoning route | **service/weights** - per their terms (**controlled**) |
| **Hugging Face Transformers** | Model loading | Apache-2.0 (**open**) |
| **PyTorch** | ML runtime | BSD-3-Clause (**open**) |
| **NVIDIA CUDA / driver** | GPU compute | **source-available / controlled** (proprietary) |
| **2captcha** | Captcha demo target (public site) | **service** (closed) |

## Agent and site tooling

| Piece | Role | Licence |
|---|---|---|
| **OpenClaw** | The agent platform running this lab | see its own terms |
| **Node.js** | Site build and agent runtime | MIT (**open**) |
| **Playwright / Chromium** | Headless browsing and capture | Apache-2.0 / BSD (**open**) |
| **tesseract** | OCR for the demo pipeline | Apache-2.0 (**open**) |
| **Xvfb / X.Org** | Virtual display for headless capture | MIT (**open**) |
| **xdotool** | Synthetic input | MIT (**open**) |
| **ImageMagick** | Frame and image manipulation | ImageMagick Licence (**open**) |
| **Inkscape** (where used) | SVG authoring | GPLv3 (**open**) |
| **Git** | Version control | GPLv2 (**open**) |

## OSINT and research

Five upstream research tools, each run as its **own non-root container**, joined to the lab's internal
network with no published host port, and pinned by image digest:

| Piece | Role | Licence |
|---|---|---|
| **shodan-python** | Host and exposure lookups against the Shodan API | per upstream (**not declared** to the licence registry) |
| **theHarvester** | Domain, host and email reconnaissance | **GPL-2.0** (**open**) |
| **SpiderFoot** | Attack-surface scanning (loopback UI only) | **MIT** (**open**) |
| **Maigret** | Username and profile discovery | **MIT** (**open**) |
| **Blackbird** | Account search across public sources | **none declared upstream** - see the caveat below |
| **Open WebUI** | Chat front-end that hosts the Lab OSINT model | **its own licence** (**source-available / controlled**) |

### The honest part

The **licences here genuinely differ, and one of them is missing.** Blackbird ships **no licence file at
all**, which means the default "all rights reserved" applies until its author says otherwise - so it is
used only as an unmodified, internal, non-redistributed tool, and that limitation is written down rather
than assumed away. Shodan's Python client likewise flags no licence to the registry. Neither fact is
buried in a footnote: if a credit is wrong or missing, that is a bug worth
[reporting](/requests/). The pinned source revisions live in the lab's own `sources.json`.

Running alongside them is an **admin-owned `lab-osint` model** served on the lab's own GPU - so the
research tools and the language model that summarises their output both stay inside the lab.

## Non-commercial caveat, restated

Everything on this site is legitimately ours to publish, **but the generated pictures and songs inherit
a non-commercial limitation** from the musicgen and sd-turbo weights that produced them. Prose and code
are ours to license freely; the generated media is not, for commercial purposes. The
[licence page](/license/) carries the same caveat.

## With thanks

Not everything here is a dependency. Some of it is **inspiration** - people whose work, curiosity or
plain stubbornness shaped how this lab approaches a problem. With thanks, in no particular order:

- **Hugh**
- **Ian**
- **Ilya**
- **Captain Tim**
- **Sean**

...and many others who lent a thought, a correction or the right question at the right moment.
The good ideas are partly theirs; the mistakes remain entirely the lab's.

## Corrections welcome

If a licence above is wrong or a dependency is missing, that is a bug worth
[reporting](/requests/) - an incorrect credit is worse than none.
