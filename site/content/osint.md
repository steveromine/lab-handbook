---
title: 'OSINT with local intelligence'
description: 'Five isolated research tools, a local GPU analyst, and explicit limits on what the model can execute.'
hero_title: 'Research tools. Local reasoning.'
hero_lede: 'An OSINT workbench connects public-source research tools to the lab’s own GPU model. Evidence stays distinct from inference.'
---

## Five tools, separate environments

| Tool | Role in the workbench |
|---|---|
| Shodan Python | Look up already-indexed public host information; a provider key is required. |
| theHarvester | Domain research through certificate-transparency records. |
| SpiderFoot | A narrow passive certificate module for the model, plus a private operator interface. |
| Maigret | Bounded username checks with recursion disabled. |
| Blackbird | Username checks with request concurrency bounded and cloud-AI features disabled. |

Each project is pinned to an upstream revision and runs in a separate non-root container.
The tools do not gain a shell, host administration rights or access to the container engine.
The language model gets a constrained lookup function, not arbitrary command execution.

## Local GPU integration

The chat frontend offers an administrator-owned **Lab OSINT (local GPU)** model. It uses the
existing local GPU inference service to produce a schema-constrained tool selection and summarize
the returned evidence. The application displays an actual worker receipt separately from the
model’s interpretation; free-form model claims are not execution proof.
Research queries still contact upstream public sources; **local reasoning does not mean offline research**.
No cloud language model is used by this integration.

Tool output is treated as untrusted evidence. A result can be incomplete, time out, or require a
credential. Those states must remain visible. Matching a username on a site is a lead, not proof
that two accounts belong to the same person.

## Boundaries

- Worker APIs have no published host ports and require a private bearer credential.
- The SpiderFoot interface is loopback-only and reached through an operator tunnel.
- Jobs have a time limit, output limit, and per-worker concurrency limit.
- Evidence and keys stay outside Git. Recent worker results have bounded local retention;
  chat history and upstream caches follow separate retention rules.
- No recurring investigations or automatic expansion to new targets are configured.

Infrastructure names here are role-based placeholders: **chat frontend**, **GPU inference service**,
**OSINT worker** and **operator tunnel**. They are not real hostnames or network addresses.

## Availability and limitations

Shodan is installed but its authenticated lookup path needs a locally provisioned provider key.
The model adapters intentionally expose a subset of each upstream application's features.
The full SpiderFoot interface is an operator tool, not an unrestricted model action.

The public page is staged while the handbook's historical publication gate is blocked. The gate
must pass before this change is published; a clean working tree cannot erase an unsafe old revision.

## Verification on 2026-10-05

All five tools passed authenticated CLI-help checks and all five completed a chat-to-worker
self-test through the GPU pipeline. Unauthenticated requests were denied. Output caps,
timeouts, invalid targets, missing-key errors and stop/restore procedures were exercised.
These are installation and integration tests, not a claim that every upstream source works
or that paid Shodan access has been activated. No real-person investigation was performed.
