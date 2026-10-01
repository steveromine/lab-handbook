---
title: 'The Lab Handbook'
description: 'One person, one hypervisor, one shared GPU and a small team of agents: a documented, sanitised tour of a self-hosted lab built to be operated, not admired.'
eyebrow: 'A public, sanitised tour'
hero_title: 'One person can now assemble a small autonomous platform'
hero_lede: 'Not because a model got smarter, but because the boring half of running infrastructure became delegable. This is a real lab: one hypervisor, one GPU shared three ways, one hardened edge, and agents that build, verify and document their own work.'
facts: true
---

## The 2026 idea, stated plainly

For twenty years the bottleneck in a home lab was **you**: the person who remembers the workaround, holds the passwords, and notices that the backup stopped running. That bottleneck is now partly removable.

Four things became cheap at the same time:

1. **Virtualisation on one box.** A single Proxmox host runs a dozen guests with real isolation, no cluster, no licence.
2. **A consumer GPU that earns its keep.** One 8 GB card serves a local language model, an image model and hardware video transcoding.
3. **A public edge that is genuinely cheap.** A small VPS terminates TLS in front of a DNS proxy, and the lab at home makes only *outbound* connections.
4. **Agents that hold a task.** Software that decomposes work, uses tools, checks the artefact it produced, and writes down what it changed.

The interesting claim is not "AI runs my house". It is narrower and more useful: **the undifferentiated half of operations is now delegable** - patching, capturing configuration, proving a restore, writing the runbook - *provided* the guardrails are designed first and the agent is not given authority it did not earn.

> If any of that reads like a pitch, it is the wrong reading. The lab's own rule is that a worker's report is **evidence**, not a conclusion, and that a green check is not proof. The same rule applies to this page.

## What is actually here

A single hypervisor hosting ten containers and three virtual machines: media front-ends over a read-only library, a syslog collector feeding a search index, a password vault, filtering DNS, a local LLM with a chat front-end, an image-generation service, a geospatial visualiser, and an operations agent that runs on the lab's own model.

The [architecture page](/architecture/) draws it; the [services reference](/handbook/services/) lists every one of them, including how each fails.

## The four parts worth understanding

### The edge is the only door

Nothing in the lab is reachable from the internet except through a single hardened edge host. Lab services have **no public listeners**; the edge reaches them over a private overlay network, and its own firewall accepts HTTP and HTTPS only from the DNS proxy in front of it. Every published name is revocable in three steps. The design is in [Security](/security/), including the parts that are assumptions rather than controls.

### The GPU is a budget, not a checkbox

One 8 GB card, three workloads. Two models that each "fit" in isolation do not fit together - so one is pinned resident and the other streams its modules in on demand. That single constraint explains most of the AI design. It is written up in [GPU as a budget](/gpu-budget/).

### Agents are an org chart before they are software

Five roles are specified: a manager who owns the outcome, and four specialists who build, audit, research and record. **One of the five is live.** The other four are designed and not yet built, which is exactly the sort of thing this site is meant to say out loud. See [the agent org chart](/agents/).

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
