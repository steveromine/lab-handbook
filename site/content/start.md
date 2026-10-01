---
title: 'Where to start'
description: 'Four audience paths through this site: plain-language, the idea, the build, and the technical reference.'
hero_title: 'Where to start'
hero_lede: 'The same lab, described for four different readers. Pick the one that matches why you are here.'
---

## If you are not technical

Start with **[Explain it like I am 5](/handbook/eli5/)**. No jargon: one box, many little rooms, one front door - and the part that matters most, which is that **machines build and check the work**, while a person decides what should exist and makes the risky calls.

Then read **[Then and now](/then-and-now/)** for why the machines matter. Nothing there requires you to know what a hypervisor is.

## If you are here for the idea

Read **[One person can now assemble a small autonomous platform](/)** - the homepage - and then **[Then and now](/then-and-now/)**.

The short version: the interesting change is not that a model got clever. It is that the *undifferentiated* half of operating infrastructure - patching, capturing configuration, proving a backup restores, writing the runbook - became delegable, and the guardrails that make that safe are the actual engineering.

## If you want to build it

Go to **[Build your own](/build/)**, then work through the handbook tracks in order:

1. [The Proxmox host](/handbook/build-proxmox-host/) - somewhere to run things, with isolation you can enforce.
2. [The VPS edge](/handbook/build-vps-edge/) - a public edge so nothing at home is exposed.
3. [The agent VM](/handbook/build-agent-vm/) - the agent itself, and the questionnaire that designs it.

Budget a weekend for the first track and an evening for the second. Track three is mostly *thinking*, not typing - and it is the one people skip.

## If you are technical and want the detail

The **[handbook](/handbook/)** is the reference layer: architecture, every service, the integrations map, the AI platform, the agent platform, the edge and security posture, operations, current status and lessons.

Good entry points:

| Document | Why |
|---|---|
| [Architecture](/handbook/architecture/) | Compute, zones, storage and capacity |
| [Services](/handbook/services/) | Every service, how it runs, and how it fails |
| [Integrations](/handbook/integrations/) | How everything talks to everything, and each failure mode |
| [Edge and security](/handbook/edge-and-security/) | Trust boundaries, the auth model, the honest caveat |
| [Current status](/handbook/current-status/) | What is recorded as running, and the known gaps |

## If you are skeptical - good

Read **[Status and known gaps](/status/)** and **[Lessons](/lessons/)** first. They are the pages that say what is designed rather than deployed, what a configuration did not prove, and where the assumptions live.

That is the intended way to read everything else here: the confident pages are only worth reading because the sceptical ones are honest.

## One more thing

Every page on this site is generated from the public handbook repository, and the build refuses to publish if it finds an internal address, a private hostname, a credential shape or a non-public subdomain in its own output. If you find something it should have caught, that is a bug worth reporting - and a more useful finding than anything on the marketing pages this site deliberately does not have.
