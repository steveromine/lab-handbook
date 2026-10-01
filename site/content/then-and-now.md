---
title: 'Then and now'
description: 'What the lab looked like before consolidation, what changed, and the three problems that forced the change.'
hero_title: 'Then and now'
hero_lede: 'The lab did not start as a platform. It started as a pile of half-finished guests, and it stayed that way until three problems became impossible to ignore.'
---

## Then: archaeology, not operations

One Proxmox host carrying guests that had accumulated organically. A service would be built, half-finished, replaced, and left switched off. By the time consolidation began the host carried:

- **Seven retired guests**, several still literally named <code>*-retired-pending-deletion</code>.
- **Duplicated agent VMs** across two generations, both nominally live.
- **A storage pool close to full**, mostly with disk images nobody would ever boot again.
- **Configuration that lived in shell history**, not in a repository.

Three problems stood out, and each one is a class of problem rather than an incident:

| Problem | What it actually cost |
|---|---|
| **No source of truth** | Configuration and knowledge existed only on the hosts, so a rebuild meant archaeology |
| **Secrets hygiene** | Credentials were scattered across the estate, and some services assumed nobody would ever look |
| **No shared spine** | Media, logging, DNS, secrets, AI and public access were separate islands with no consistent pattern |

## What changed

### 1. Git became the source of truth

Every material change lands in a repository: an operating contract, an activity log, a decision log, runbooks, and captured host configuration. The rule is blunt - *if it is not in Git, it did not happen* - and it is what makes the next four changes possible.

### 2. The estate was cleaned, not tidied

Abandoned guests were **captured** (their configuration preserved) and then **destroyed**. Their roles were folded into properly named, documented replacements. Seven guests were reclaimed, taking the thin pool from nearly full to roughly one-eighth used.

That reclaim taught a lesson worth repeating: the number that moved was the **thin pool's own usage**, not the volume group's free space. Watching the wrong number makes a successful cleanup look like a failed one - see [Lessons](/lessons/).

### 3. A real edge replaced direct exposure

Instead of exposing services directly, the lab now publishes through a single edge: a small public VPS terminating TLS behind a DNS proxy, joined to the lab by a private overlay network. Nothing at home is reachable from the internet except through that edge, and every published service is authenticated at exactly one layer.

### 4. The AI platform was consolidated

A local GPU model so routine work does not depend on a paid API, surfaced through a full-featured chat front-end, with image generation, web search, and document *and archive* ingestion. Local embeddings mean retrieval never sends a user's document anywhere.

### 5. Operations went onto rails

Ansible handles patching and configuration capture. Logs from the hypervisor, the edge, the firewall and the guests flow into one searchable index. The agent platform runs from a documented workspace with explicit rules, and its monitoring is **deterministic** - a script on an hourly timer, not a model narrating a healthy system.

## Now

A small, documented, reproducible platform: segmented networks, a hardened edge, a shared GPU doing three jobs, centralised observability, and an AI layer genuinely usable from a browser - with the whole thing described in Git rather than in someone's memory.

## What did not change

- **One host.** Still a single point of failure. That is a trade, not an oversight.
- **Trust inside the server zone.** Most services still listen broadly and rely on the network boundary. A security review named this rather than papering over it; the [security page](/security/) states it plainly.
- **The tendency to believe a green check.** The lab's most expensive mistakes were configurations that validated perfectly and did nothing. The countermeasure is procedural: *verify with the artefact*.

## The thing that made it 2026 and not 2016

None of the individual pieces is new. Hypervisors, VPN tunnels, reverse proxies and log collectors are all decades old. What changed is that the **coordination layer** - the part that reads the estate, decides what to do, does it, proves it, and writes it down - can now be delegated to software with a written contract and a rollback note. That is the whole difference, and it is why the [agent org chart](/agents/) is on this site at all.
