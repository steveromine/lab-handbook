---
title: 'The Lab Handbook'
description: 'One person, one hypervisor, one shared GPU and a small team of agents: a documented, sanitised tour of a self-hosted lab built to be operated, not admired.'
eyebrow: 'A public, sanitised tour'
hero_title: 'One person can now assemble a small autonomous platform'
hero_lede: 'Not because a model got smarter, but because the boring half of running infrastructure became delegable. This is a real lab: one hypervisor, one GPU shared three ways, one hardened edge, and agents that build, verify and document their own work.'
facts: true
---

> **Scope.** A field notebook from one person's home lab - an experiment, not a product. It exists to
> show how far today's tools reach, and to be honest about what is proved and what is not.

## The result, first

The strongest material here is not a promise; it is agents finding real faults. One worked example,
end to end:

- **Problem.** A monitor was sampling the wrong host, so the panel stayed green while the thing it was
  meant to watch went unmeasured.
- **Agent action.** Sentinel's health sweep caught the mismatch between the configured target and the
  one actually sampled.
- **Verification.** The fix landed with before/after evidence in the [reviewed backlog](/requests/) and
  the [status page](/status/).

Three agents have found and fixed real faults this way, including a publication gate that was
silently blocking deploys. See [The team at work](#the-team-at-work), or watch
[an agent build a page on camera](/example-desktop-demo/).

## The idea, stated plainly

For twenty years the bottleneck in a home lab was **you**: the person who remembers the workaround,
holds the passwords, and notices that the backup stopped running. That bottleneck is now partly
removable, because four things became cheap at once - virtualisation on one box, a consumer GPU that
earns its keep, a genuinely cheap public edge, and agents that hold a task and check their own work.
The claim is not "AI runs my house". It is narrower and more useful: **the undifferentiated half of
operations is now delegable** - provided the guardrails are designed first.

## What is actually here

A single hypervisor hosting its service containers and three virtual machines: media front-ends over a
read-only library, a syslog collector feeding a search index, a password vault, filtering DNS, a local
LLM with a chat front-end, an image-generation service, a geospatial visualiser, and an operations
agent running on the lab's own model. The [architecture page](/architecture/) draws it; the
[services reference](/handbook/services/) lists every one of them, including how each fails.

Four parts carry the design:

- **The edge is the only door.** No lab service has a public listener. [Security](/security/).
- **The GPU is a budget, not a checkbox.** One 8 GB card, three workloads, one pinned resident.
  [GPU as a budget](/gpu-budget/).
- **Agents are an org chart before they are software.** Five roles, all configured, all with completed
  runs. [The agent org chart](/agents/).
- **Honest status beats a green dashboard.** Every claim is labelled *designed*, *configured*,
  *verified*, a *known gap*, or *planned*. [Status](/status/).

## Where to start

| If you are... | Start here |
|---|---|
| Curious, not technical | [Explain it like I'm 5](/handbook/eli5/) - plain language, no jargon |
| Here for the idea | [Then and now](/then-and-now/) - the change that made this possible |
| Here to build it | [Build your own](/build/) - hypervisor, edge, agent VM |
| Technical, wants detail | [The handbook](/handbook/) - every document, indexed |
| Skeptical, wants limits | [Status and known gaps](/status/) and [Lessons](/lessons/) |

## The team at work

This lab is not run by hand. Five agent roles hold **standing duties** and work without being asked -
and the evidence is in the repository, not in a promise.

| Role | Standing duty | Last verified activity |
|---|---|---|
| **Manager** | Works the backlog every 15 minutes and audits the site for drift | Running continuously |
| **Forge** | Ships one small verified improvement an hour | Runs completed |
| **Sentinel** | Health sweep every 30 minutes; reviews public requests every 30 | Running |
| **Ledger** | Reconciles public and private documentation twice a day | Runs completed |
| **Atlas** | Audits the estate daily - proves or disproves what is configured | Run completed; daily audit unproven |

The count is deliberately unflattering where it should be: **Atlas has completed runs but its
scheduled daily estate audit has still not passed**, so estate drift-auditing is described as
unproven rather than claimed. A role that stops performing is demoted or removed - see the
[accountability policy](/agents/).

## Licence and credit

**Use it, fork it, sell it, rebuild it, feed it to a machine - just credit me, and it comes with no
warranty.**

- **Code and configuration** (scripts, build, configs): **MIT**.
- **Words and media** (prose, images, songs, this site's text): **CC BY-SA 4.0** - credit me and share
  alike.

Bundled third-party components and the models keep their own licences, and generated media names the
model that produced it - credit where it is due, blame nowhere it is not. Full text:
[LICENSE](https://github.com/steveromine/lab-handbook/blob/main/LICENSE). The
[licence page](/license/) names the split and, honestly, the closed things this lab still leans on.

## About this lab, as of 2026-10-03

One person, one hypervisor, one shared GPU, and a small team of agents that now have to earn their
keep. Everything here is made in the lab on its own hardware; agents are accountable and disposable;
and nothing is finished - a timer works the backlog every fifteen minutes, and goes looking for
something to verify when it is empty. The detail lives in the [handbook](/handbook/).
