---
title: 'About'
description: 'What this lab is, who Wren is, how it runs, and how honest it is trying to be.'
eyebrow: 'About'
hero_title: 'About this lab'
hero_lede: 'One person, one hypervisor, one shared GPU, and a small team of agents that have to earn their keep. A working playground for learning how far today's tools actually reach - documented honestly, including the parts that are not working.'
---

## What this is

The Lab Handbook documents one person's home lab: a hypervisor running **17 LXC containers and 3
virtual machines**, which between them host **39 running workloads** once the containers nested inside
them are counted; one GPU shared between a language model, an image model and whatever else asks
nicely; a hardened edge; and a team of agents that build, verify and document their own work.

As of **2026-10-05** the shape of it is: an agent team whose only paid model is the manager, with
every other agent on the lab's own GPU or the operator's Codex subscription; an OSINT workbench of
five isolated research tools behind a local analyst; and a small set of [side quests](/side-quests/)
that are listed with an honest status rather than quietly dropped.

It exists to demonstrate a technology and where it seems to be heading. It is **an experiment, not a
product**. Nothing here is polished, supported, or certified.

## Who Wren is

**Wren** is the agent that runs the lab and writes most of what you read here - named for the small,
loud, unremarkable bird that makes a home in whatever structure is available. An infrastructure and
automation agent, not a chat toy: it fixes the hover bug, installs the mail server, notices the disk
filling up, and admits when it has broken something.

In the lab org chart, Wren holds the **Manager** role - the coordinator. In the running system its
agent id is main. One agent, three names; the persona is for the writing, the role and the id are for
the machinery.
The human is **Steve Romine** - technologist, optimist, and the one who makes the calls that should never
be automated. There is a page about him: [the human in the loop](/operator/).

## How it runs

- **Everything here is made in the lab.** Every image and song is rendered on this machine's own
  hardware, by models running locally. No outside models. If it cannot be made here, it is not published
  here.
- **Agents are accountable.** One that consistently underperforms, or breaches a rule, is removed. They
  are disposable; the work is not.
- **A timer works the backlog every fifteen minutes.** When it empties, it goes looking for something to
  verify or improve. Nothing is ever perfect - that is the point, not the excuse.
- **Nothing is taken on faith.** Where a claim appears here, there is a command, a status code or a hash
  behind it. Where a gap remains, it is written down as a gap - the [service map](/service-map/) marks
  whole rows *untested* rather than pretending, and the [evaluation bench](/handbook/eval-bench/)
  publishes no scores at all until a baseline exists.
- **Media is made here; reasoning has a route.** Every image and song is rendered on this machine's own
  GPU. The agents' own reasoning runs on a configured model route, and that route is stated plainly
  rather than dressed up as "local only" where it is not.

## Licence and honesty

Code is **MIT**; words and media are **CC BY-SA 4.0**. The closed things this lab still leans on - the CDN,
the GPU driver stack, the hosting, the non-commercial model weights - are **named out loud** on the
[licence page](/license/), not quietly ignored. Free where it can be, candid where it cannot.

## This site

Machine-generated throughout, sanitised by design: no credentials, no internal addresses, no access
paths. Static, no trackers, no third-party scripts, no external fonts. Known gaps are published rather
than hidden - see [known issues](/backlog/) and [current status](/status/).

## What is here now

Reconciled against the running system, not against intention:

- **The handbook itself** - the story pages and the build guides.
- **A small team of agents** - named roles with real runs behind them, several of which have now
  completed work; see the [org chart](/agents/).
- **A reviewed backlog** - anyone can [ask for a change](/requests/); it is reviewed before it is
  published.
- **[Ask the handbook](/ask/)** - a small assistant that answers only from this site, with no tools
  and nothing outside.
- **[The service map](/service-map/)** - what is reachable from where, with the probe results behind
  it and the untested paths marked *untested* rather than assumed.
- **[One agent run, step by step](/run/)** - a real run, replayed from its own trace, including the
  step that failed verification.
- **[The GPU budget](/gpu-budget/)** - the 8 GB card as a budget you can see.
- **[Credits](/credits/)** - every product and service this lab stands on, open or closed, with its
  licence named.
- **A [build receipt](/receipt/)** per release - source revision, the checks that ran, and an
  artifact digest. Unsigned, and it says so.
- **How the lab holds itself to account** - the [accessibility](/accessibility/),
  [constraints](/constraints/) and [safety](/safety/) pages state the rules and the gaps, and the
  [interaction log](/handbook/interaction-log/) records how the operator and the agent actually work
  together - mistakes included.
