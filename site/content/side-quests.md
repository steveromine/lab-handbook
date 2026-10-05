---
title: 'Side quests'
description: 'The projects that are not the lab and never claimed to be: a Flipper Zero, the OSINT workbench, Nomad, and the Gods Eye View - with an honest status for each.'
hero_title: 'Side quests'
hero_lede: 'The main plot is the lab: one hypervisor, one GPU, an agent team that documents its own work. These are the detours - kept here so they stay visible without pretending to be finished.'
---

## Why a page for the detours

Every lab accumulates work that is neither the core build nor abandoned - the thing you started because
it was interesting, then parked half-done. Silently dropping those is how a lab ends up looking tidier
than it is. So they get a page, and each one gets an **honest status**: built, in progress, or spec still
missing.

| Side quest | What it is | Status |
|---|---|---|
| **Flipper Zero** | A physical RF/wireless tool, attached to the lab hypervisor | <span class="pill pill-gap">KNOWN GAP</span> attached, not built |
| **OSINT workbench** | Five isolated research tools plus the lab's own GPU analyst | <span class="pill pill-verified">VERIFIED</span> built and in use |
| **Nomad** | A "survival tool" the operator asked for, with no spec yet | <span class="pill pill-planned">PLANNED</span> spec needed |
| **Gods Eye View** | A self-hosted geospatial/visualisation application, published through the edge | <span class="pill pill-verified">VERIFIED</span> deployed |

## Flipper Zero

A Flipper Zero is attached to the lab hypervisor. That is the whole of it so far: **it does not yet
enumerate**, which points at the physical layer - cable and USB passthrough into the guest - rather than
software. Nothing has been built on top of it.

It stays listed rather than quietly dropped. The failure mode worth avoiding is a piece of hardware that
someone assumes is working because it was bought and plugged in.

## OSINT workbench

The furthest along, and the one that stopped being a side quest and started carrying real weight. Five
upstream research tools - **Shodan, theHarvester, SpiderFoot, Maigret, Blackbird** - each run as its own
non-root, read-only, capability-dropped container, wired to an **admin-owned model on the lab's own
GPU**. The design rule is the interesting part: **evidence stays strictly separate from inference.** The
receipt that a tool ran is produced by the application, never written by the language model, so a
plausible-sounding summary can never manufacture a successful lookup.

Both the repository and the model are private to the lab administrator. Read the full
[OSINT workbench](/osint/) write-up for the tool-by-tool detail and the explicit limits.

## Nomad

The least defined, and it is recorded that way on purpose. The operator asked for a **"survival tool"** -
internal first, no GPU, wired into existing inference, with the agent setting up the admin login. That is
the entire brief. **Nothing in the repository or the public record defines what software "Nomad" is**, and
a guest named `nomad` exists on the hypervisor.

So it sits at **spec needed**. Deploying an unidentified service - especially one described as public-facing
- is not a cheap thing to undo, and guessing at a spec is how you build the wrong thing carefully. The
honest next step is a named stack, not a hopeful deployment.

## The rule for this page

A side quest leaves this page in one of two ways: it gets built and promoted to a real part of the lab
(the OSINT workbench is on that path), or it is **explicitly dropped and said so**. It does not get to
fade into silence, because silence reads as "done" to anyone who was not there.

The known gaps stay listed on the [public backlog](/backlog/) too, where the wireless work was already
logged as a side quest.

## Gods Eye View

A self-hosted **geospatial / visualisation** application, published through the edge like the lab front-ends. It is a side quest rather than lab plumbing: it is here because it was interesting to stand up, and it is kept because a map you can actually look at is a better way to reason about where things are than a table.
