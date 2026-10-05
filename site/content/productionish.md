---
title: 'Productionish'
description: 'The parts of the lab the operator actually depends on - the media and library stack - kept in the lab on purpose, as the most honest fault-finding rig available.'
eyebrow: 'Productionish'
hero_title: 'Productionish: real use, on purpose'
hero_lede: 'Not demos, and not side quests. These are services the operator genuinely relies on, run inside the lab deliberately - because something you depend on is the only test that does not flatter you.'
---

## Why these live here

A lab that only ever runs things it can afford to break never finds the faults that matter. So this
section is the opposite: **services with real users and real consequences** - the media and library
stack - deliberately run on the lab's own hardware.

The point is not to pretend the lab is production. The point is that **dependence is a better fault
injector than any synthetic test**: when the library is the one you actually watch from, a broken mount
or a stalled transcode stops being a graph and becomes an evening.

Calling it **Productionish** is the honest label. It carries the weight of production expectations
without claiming production guarantees.

## What is in it

| Service | What it is | Depends on |
|---|---|---|
| **Plex** | Media front-end | GPU transcoding, read-only media export |
| **Jellyfin** | Second media front-end, deliberately run alongside Plex | GPU transcoding, read-only media export |
| **media-nfs** | The library itself, on its own guest, exported read-only | Storage pool |
| **media automation** | The acquisition stack: requests, metadata/indexers, a download client | Indexers, download paths |

Running **two** front-ends over one library is deliberate: different client support and different
transcode behaviour, and neither vendor becomes a single point of failure for access.

Separating the library from the applications is what makes *"the applications cannot damage the
library"* true rather than aspirational - the export is read-only.

## What it has taught the lab

- The GPU is a **three-way contention point** (inference, image generation, transcoding). Streaming the
  image model instead of making it resident exists because of this section.
- A **missing media mount looks like data loss** and is almost always a mount problem.
- **Indexers go stale or get rate-limited**, and the symptom is silence - "nothing downloads" - rather
  than an error. That is the same class of failure the rest of the lab tries to design out.
