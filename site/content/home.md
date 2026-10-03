---
title: 'The Lab Handbook'
description: 'One person, one hypervisor, one shared GPU and a small team of agents: a documented, sanitised tour of a self-hosted lab built to be operated, not admired.'
eyebrow: 'A public, sanitised tour'
hero_title: 'One person can now assemble a small autonomous platform'
hero_lede: 'Not because a model got smarter, but because the boring half of running infrastructure became delegable. This is a real lab: one hypervisor, one GPU shared three ways, one hardened edge, and agents that build, verify and document their own work.'
facts: true
---

> **This is an experiment, not a product.** The Lab Handbook documents one person's home lab: a
> working playground for learning how far today's tools actually reach. Nothing here is polished,
> supported, or certified. It exists to demonstrate a technology and where it seems to be heading,
> to help you understand that future, and to leave you a little more knowledgeable about what is
> possible today - and what may be possible next. Read it as a field notebook, not a manual.

## Three ways in

- **The story** - why any of this exists, and what changed. Start with [Then & Now](/then-and-now/),
  then [Lessons](/lessons/).
- **The build** - the actual blueprint. [Build your own](/build/) maps the three tracks; the
  [handbook](/handbook/) has the depth, one page per track.
- **The machine** - what it runs on and what it costs. [The hardware](/hardware/) is the honest spec
  sheet; [GPU budget](/gpu-budget/) is how one old card is shared three ways.

New here? [Where to start](/start/) is the guided version.

## The 2026 idea, stated plainly

For twenty years the bottleneck in a home lab was **you**: the person who remembers the workaround, holds the passwords, and notices that the backup stopped running. That bottleneck is now partly removable.

Four things became cheap at the same time:

1. **Virtualisation on one box.** A single Proxmox host runs every lab guest with real isolation, no cluster, no licence.
2. **A consumer GPU that earns its keep.** One 8 GB card serves a local language model, an image model and hardware video transcoding.
3. **A public edge that is genuinely cheap.** A small VPS terminates TLS in front of a DNS proxy, and the lab at home makes only *outbound* connections.
4. **Agents that hold a task.** Software that decomposes work, uses tools, checks the artefact it produced, and writes down what it changed.

The interesting claim is not "AI runs my house". It is narrower and more useful: **the undifferentiated half of operations is now delegable** - patching, capturing configuration, proving a restore, writing the runbook - *provided* the guardrails are designed first and the agent is not given authority it did not earn.

> If any of that reads like a pitch, it is the wrong reading. The lab's own rule is that a worker's report is **evidence**, not a conclusion, and that a green check is not proof. The same rule applies to this page.

## What is actually here

A single hypervisor hosting its service containers and three virtual machines: media front-ends over a read-only library, a syslog collector feeding a search index, a password vault, filtering DNS, a local LLM with a chat front-end, an image-generation service, a geospatial visualiser, and an operations agent that runs on the lab's own model.

The [architecture page](/architecture/) draws it; the [services reference](/handbook/services/) lists every one of them, including how each fails.

## The four parts worth understanding

### The edge is the only door

Nothing in the lab is reachable from the internet except through a single hardened edge host. Lab services have **no public listeners**; the edge reaches them over a private overlay network, and its own firewall accepts HTTP and HTTPS only from the DNS proxy in front of it. Every published name is revocable in three steps. The design is in [Security](/security/), including the parts that are assumptions rather than controls.

### The GPU is a budget, not a checkbox

One 8 GB card, three workloads. Two models that each "fit" in isolation do not fit together - so one is pinned resident and the other streams its modules in on demand. That single constraint explains most of the AI design. It is written up in [GPU as a budget](/gpu-budget/).

### Agents are an org chart before they are software

Five roles are specified: a manager who owns the outcome, and four specialists who build, audit, research and record. All five now exist as configured agents and have completed runs - though the four specialists share the manager's fast cloud route, with Atlas moved onto the lab's own local model on 2026-10-03, rather than the frontier-class split the design describes. The honest accounting is on [the agent org chart](/agents/).

### Honest status beats a green dashboard

Every claim here is labelled: **designed**, **configured**, **verified**, a **known gap**, or **planned**. The [status page](/status/) records what has been proved and, more usefully, what has not.

## What this is not

- **Not a product, and not high availability.** One hypervisor is a single point of failure, deliberately. The lab exists to get the *patterns* right, not to survive a disk failure.
- **Not "military-grade" anything.** The edge is hardened; the server zone is where the assumptions live. Most services there listen broadly and rely on the network boundary. That is a defensible choice for a lab, and it is stated rather than implied.
- **Not finished.** Several items are designed and unbuilt, and a few are configured and unproven. Where that is true, the documentation says so instead of rounding up.

## Where to start

| If you are... | Start here |
|---|---|
| Curious, not technical | [Explain it like I'm 5](/handbook/eli5/) - plain language, no jargon |
| Here for the idea | [Then and now](/then-and-now/) - the change that made this possible |
| Here to build it | [Build your own](/build/) - hypervisor, edge, agent VM |
| Technical, wants detail | [The handbook](/handbook/) - every document, indexed |
| Skeptical, wants limits | [Status and known gaps](/status/) and [Lessons](/lessons/) |

## Licence and credit

**Do what you like with this. Just credit me, and it is not my fault if you break something.**

The words, configuration, scripts and generated media in this project are released under the **MIT
Licence** - the shortest one that means what I mean:

- **Use it, fork it, sell it, rebuild it, feed it to a machine.** No permission needed, no fee, no
  strings worth the name.
- **Credit me.** Keep the copyright notice and a link back. That is the whole ask.
- **No warranty.** It comes as-is. If you point this at production and it eats your weekend, that is
  between you and the weekend. I am not liable - see the licence text, which I did not write and
  which nonetheless says exactly this, at length, in capitals.

Bundled third-party components keep their own licences, and the software this lab runs on
(Proxmox, Docker, the models, the offline knowledge sets) belongs to its respective authors under
their own terms. The machine-generated media on this site names the model that produced it, for the
same reason: credit where it is due, blame nowhere it is not.

Full text: [LICENSE](https://github.com/steveromine/lab-handbook/blob/main/LICENSE). The [licence page](/license/) names the split and, honestly, the closed things this lab still leans on.

## About this lab, as of 2026-10-03

One person, one hypervisor, one shared GPU, and a small team of agents that now have to earn their keep.

- **Everything here is made in the lab.** Every image and song is rendered on this machine's own hardware,
  by models running locally. No outside models. If it cannot be made here, it is not published here.
- **Licensed honestly:** MIT for code, CC BY-SA 4.0 for words and media - with the closed things this lab
  still leans on named out loud on the [licence page](/license/), not quietly ignored.
- **The agents are accountable.** One that consistently underperforms, or breaches a rule, is removed.
  They are disposable; the work is not.
- **Nothing here is finished.** A timer works the backlog every fifteen minutes, and when it empties, it
  goes looking for something to verify or improve. Nothing is ever perfect - that is the point, not the
  excuse.
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

The count is deliberately unflattering where it should be: **Atlas has now completed runs but its
scheduled daily estate audit has still not passed**, so estate drift-auditing is described as unproven
rather than claimed. A role that stops performing is demoted or removed - see the
[accountability policy](/agents/).

Three of these agents found and fixed real faults on their own, including a monitor that measured the
wrong host and a publication gate that was silently blocking deploys. **You can see the results in the
[reviewed backlog](/requests/) and the [current status](/agents/).**
