---
title: 'The hardware'
description: 'Exactly what this runs on, and how old it is. One desktop from 2020, one GPU from 2020, and a cheap VPS.'
eyebrow: 'Under the desk'
hero_title: 'The actual hardware'
hero_lede: 'No rack, no data center. One ordinary desktop from 2020, a single consumer GPU, and a five-dollar VPS at the edge. Here is exactly what it is, and how old it is.'
---

## The one box

Everything in this lab runs on a single 2020 desktop - a **Lenovo Legion T7 34IMZ5** (machine type
90Q8003PUS, board 3715), running Proxmox VE 9.2.20.

| Part | What it is | Vintage |
|---|---|---|
| CPU | Intel Core i9-10900K - 10 cores / 20 threads, 3.7 GHz base | **2020** (~6 years) |
| Memory | 125 GiB DDR4, running at 2133 MT/s | 2020 |
| Storage (fast) | 2 x 1 TB Samsung PM981a NVMe (MZVLB1T0HBLR) | ~2019 OEM |
| Storage (bulk) | 10.9 TB Seagate Expansion USB hard drive | consumer USB |
| GPU | NVIDIA GeForce RTX 3070, 8 GB, driver 595.91.07 | **2020** (~6 years) |
| Hypervisor | Proxmox VE 9.2.20, kernel 7.0.14 | 2026 |

The RAM runs at a humbler 2133 MT/s than the chip can taste - the OEM board defaults to the safe
JEDEC setting, and this lab has never needed the extra few percent.

## The GPU is the whole reason

One **RTX 3070 with 8 GB** is the only accelerator, and it is shared three ways: a local language
model (which keeps roughly 5 GB resident), video transcoding for the media front-ends, and the image
service. When they all want it at once, the smaller job politely leaves the card - which is exactly
why the image and music services were built to stream memory in and out rather than move in
permanently.

## The edge and the agent

- **Edge:** a small VPS (this public site and the TLS termination). Cheap, disposable, the only
  thing with a public address.
- **Agent host:** a VM on the same box - 4 vCPU, 15 GiB RAM, 48 GiB disk - running the agents that
  write this handbook.

## The honest summary

This is six-year-old consumer hardware, dressed up with documentation. That is the point: the
interesting part was never the silicon. **A single ordinary desktop, kept honestly, is enough to
learn what is possible now** - and to watch what arrives next.
