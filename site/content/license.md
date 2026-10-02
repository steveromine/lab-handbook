---
title: 'Licence and credits'
description: 'What you may do with this site: MIT for code, CC BY-SA for words and media, and an honest list of the closed things it still leans on.'
eyebrow: 'Use it freely'
hero_title: 'Licence and credits'
hero_lede: 'Do what you like with this. Credit me, and it is not my fault if you break something. Below that simple wish is the honest small print - including the parts that are not open, which I would rather name than hide.'
---

## In plain English

**Use it, fork it, sell it, rebuild it, feed it to a machine.** No fee, no permission slip, no strings
worth the name. Just **credit me**, and accept that it comes **with no warranty** - if it eats your
weekend, that is between you and the weekend.

## The split

| What | Licence | Means |
|---|---|---|
| **Code and configuration** (scripts, build, Caddyfiles, configs) | **MIT** | Permissive. Do anything, keep the notice, no warranty. |
| **Prose and media** (words, images, songs, this site's text) | **CC BY-SA 4.0** | Credit me and share alike. Copyleft - the friendly kind. |
| **Bundled third-party components** | **Their own** | Proxmox (AGPLv3), Docker (Apache-2.0), llama.cpp (MIT), Qwen2.5 (Apache-2.0) and others keep their terms. |

Full text: [LICENSE](https://github.com/steveromine/lab-handbook/blob/main/LICENSE).

## ⚠️ The model-weight caveat

Our own writing is ours to license. The **models that make the media are a different story**, and this
is the trap most people never read:

- **`facebook/musicgen-*` weights** are **CC-BY-NC** - *non-commercial*.
- **`stabilityai/sd-turbo`** ships under **non-commercial** community terms.

So: everything here is legitimately ours to publish, but the **generated media inherits a
non-commercial limitation** from the weights that produced it. MIT on the prose, **no-commercial** on
the pictures and the songs. If you ever wanted to sell something with this art in it, that is the line.

## 🔒 Closed source, and honestly named

I would rather list these than pretend. This lab is not 100% free software yet, and these are the parts
that are not:

- **Cloudflare** - the CDN, TLS termination and DNS proxying in front of this site. Proprietary and
  hosted. It sees our traffic before we do.
- **NVIDIA CUDA / driver** - the GPU stack that runs every local model here. Proprietary.
- **the VPS host** - the VPS that serves this site. A proprietary service, not a machine we own.
- **GitHub** - where this source lives and the failover copy is pulled from. Proprietary platform.
- **Proxmox VE** - free software (**AGPLv3**), but its *Enterprise* repository is subscription-gated;
  this lab runs the no-subscription one.
- **Model weights** - open to download, but under non-commercial or custom licences, not OSI-approved
  free licences.

None of this makes the lab a lie. It makes it honest: **free where it can be, and candid where it
cannot.** Closing every one of these gaps is a standing goal, tracked on the [backlog](/backlog/).

*If you fork this, fork the honesty too - ship your own list of what you have not freed yet.*
