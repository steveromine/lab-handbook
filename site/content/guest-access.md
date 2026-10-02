---
title: 'Guest inference access'
description: 'How one invited friend can use this lab&apos;s LLM from his own agents over a private network - what he gets, what he does not, and exactly how it is bounded.'
eyebrow: 'Access'
hero_title: 'Guest inference access'
hero_lede: 'One friend, one model, one door. An invited guest can reach this lab&apos;s language model from his own agents over a private network - and can reach nothing else in the lab, by construction rather than by promise.'
---

## What this is

A small experiment: give **one named person** the use of this lab's LLM inference from his own agent
setup, over a private overlay network (Tailscale) rather than the public internet. It exists to find
out whether a shared home-lab model can be a genuinely useful tool for someone else's agents - and to
work out, honestly, how to bound that without trusting anyone's good behaviour.

This page describes the **shape** of it. It deliberately does not publish addresses, network names,
keys or identifiers - the exact configuration lives in the lab's private operating repository.

## The shape

```
friend's agents  --private network-->  [ guest node ]  --lab network-->  the model
                                            |
                                            +-- one port, three endpoints, one key
```

A single dedicated node is enrolled on a private overlay. It runs exactly one thing: a proxy in front
of the model. The guest is granted access to **that node**, and to nothing else.

## What the guest gets

- **Three endpoints, and no more:** chat completions, completions, and a model list.
- **A key of his own**, distinct from every key the lab uses - and revocable on its own.
- **A rate limit**, so his agents cannot starve the lab's own use of the shared GPU.

## What the guest does not get

- **No shell.** Not on the guest node, not on anything else.
- **No files.** No storage, no shared directory, no uploads.
- **No other service.** No dashboards, no databases, no management interface, no other machine.
- **No route into the lab.** The overlay hands out one node - not a path to the network behind it.
- **No public surface.** This is not the internet-facing endpoint and does not widen it.

## How it is bounded

The bounding is structural, not a matter of trust:

- **Default deny.** The network policy grants the guest **one destination and one port**. Everything
  else is denied unless a rule names it - and no rule does.
- **Path allowlist.** The proxy answers three API paths and returns **403 for everything else**,
  including any attempt to reach an admin or metrics route.
- **Its own identity.** The guest is a distinct principal, so revoking access is revoking *him* -
  not rotating a shared secret.
- **No egress for the guest node.** The node talks to the model and to nothing else.
- **Shields up.** The node refuses inbound traffic except what the policy explicitly allows.

## Revocation, and why we test it first

Access is removed in one action: drop the policy grant and remove the node's key. **This is tested
before anyone is invited** - a revocation path that has never been exercised is a hope, not a control.
After revocation, the guest's requests must fail hard. There is no fallback, and no cached credential.

## The honest limits

- **It is a home lab.** The model is a small local one, not a frontier service. Expect modest
  capability, variable latency, and downtime when the lab is busy.
- **The GPU is shared and the lab comes first.** Guest requests are best-effort; the rate limit is the
  guarantee, not a promise of performance.
- **Traffic is logged without content.** The proxy records timestamp, path, status and token counts -
  never prompts, never completions, never keys.
- **A guest is a guest.** If the experiment ends, is abused, or the lab's own work needs the whole
  model, access is withdrawn. That is the arrangement, and it was agreed up front.

*The exact configuration - policy fragment, node settings, proxy bounds and the revocation procedure -
is held in the lab's private operating repository. This page is the part the guest and the public may
see.*
