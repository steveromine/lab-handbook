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

## The network gateway

The edge of the network - routing, firewall, VLANs, and the WireGuard dial-in that reaches the
services - is handled by a **UniFi Dream Machine Pro (UDM Pro)**. It is part of what the agent
operates: the same care that applies to the servers applies to the gateway that fronts them.

## Live from the rack

A snapshot straight off the Proxmox host - the machine these containers actually run on. Updated by the
site-refresh job; the timestamp is the honest part.

| | |
|---|---|
| **CPU** | Intel Core i9-10900K - 20 threads @ 3.70 GHz |
| **Load average** | 3.24 / 2.26 / 3.53 (1 / 5 / 15 min, across 20 threads ~15% busy) |
| **Memory** | 125 GiB total - 59 GiB used, 66 GiB available |
| **Root storage** | 94 GB, 59 GB used (66%) |
| **Guest storage (LVM thin)** | 815 GB pool, 190 GB used (23%) |
| **GPU** | NVIDIA GeForce RTX 3070 - 5237 / 8192 MiB in use, 0% utilisation, 30°C |
| **Guests** | 17 containers, 3 virtual machines |
| **Host uptime** | 3 days, 7 hours |

*Measured 2026-10-03 08:03 UTC. Two things reading this are worth noting: the GPU shows over half its
memory in use at idle - that is the resident language model holding its weights, the price of having an
assistant that is always on - and the storage pool sits at 23%, which is the number that actually decides
how much offline knowledge this thing can carry.*
## What it costs to run

**These are estimates, not measurements.** No metered plug has been fitted to this box, so the numbers
below are derived from component power ratings (TDP) plus typical idle behaviour - stated openly rather
than dressed up as readings from a wall meter.

### The power envelope

| State | What is happening | Estimated draw |
| --- | --- | --- |
| **Idle** | Hypervisor up, guests running, GPU parked, no inference | **~85 W** |
| **Typical** | Light inference, backups, media, normal agent work | **~180 W** |
| **Heavy inference** | The GPU pinned by a language model | **~350 W** |

The heavy figure is dominated by the **RTX 3070 (220 W)** - the i9-10900K adds up to ~125 W under
sustained load, the board, memory, drives and fans account for the rest, and PSU efficiency takes a
little more again at the wall.

### What that translates to

Running continuously (24/7), the box consumes:

| State | Per day | Per month | Per year |
| --- | --- | --- | --- |
| Idle (~85 W) | ~2.0 kWh | ~61 kWh | ~744 kWh |
| **Typical (~180 W)** | ~4.3 kWh | **~130 kWh** | **~1,560 kWh** |
| Heavy (~350 W) | ~8.4 kWh | ~252 kWh | ~3,066 kWh |

Cost depends entirely on your tariff, so here it is at two plausible prices:

| State | At $0.15 / kWh | At $0.30 / kWh |
| --- | --- | --- |
| Idle | ~$9 / month | ~$18 / month |
| **Typical** | **~$19 / month** | **~$39 / month** |
| Heavy | ~$38 / month | ~$76 / month |

**In plain terms: a home lab like this costs roughly the price of a streaming subscription per month**
at typical load - and noticeably more if you leave a language model pinned to the GPU around the clock.

### The other half of the bill

- **The VPS at the edge** is a few dollars a month - trivial next to the GPU, but it is a real line item.
- **Cooling is not counted here.** A 350 W load warms a room, and in summer that heat either raises
  comfort costs or is actively removed - add a meaningful fraction on top of the figures above.
- **Idle is not free.** The single biggest lever is not peak draw; it is whether the box runs 24/7 or
  sleeps. Most of the monthly cost above is idle-time cost.

### How to make these numbers real

A **metered smart plug** (or a PSU with telemetry) would turn every estimate on this page into a
measurement. It is on the [backlog](/backlog/) - and until then, the honest label for all of this is
*estimate*, not *reading*.
