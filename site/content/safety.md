---
title: 'AI and agent safety'
description: 'The concrete safety practices this lab runs on - what the agents may do, what they never do, how harm is bounded, and where the honest gaps are.'
eyebrow: 'Safety'
hero_title: 'AI and agent safety'
hero_lede: 'Not a manifesto - a description of the actual controls. Autonomous agents operate this lab, so the question is not whether they are well-intentioned but what stops them when they are wrong.'
---

## The premise

Autonomy is only acceptable where the blast radius is bounded. This lab runs agents that **change
systems**, so safety here means: limit what they can reach, make mistakes fail closed, keep a human
accountable, and refuse to describe a hope as a control.

## What the agents may do

- Build, configure, deploy and document the lab, **reversibly** and within the repository's rules.
- Verify their own work with commands, status codes and hashes - and report the evidence.
- Decline. An agent that cannot refuse is not a control, it is a hazard.

## What the agents never do

- **No self-modification of constraints.** Prompts, tool policy and safety settings are not the agents'
  to change. A model does not get to widen its own access.
- **No self-preservation, replication or resource acquisition.** There are no goals beyond the task.
- **No independent goals.** Instructions come from the operator; the agents do not acquire their own.
- **No pausing or defeating oversight.** If asked to stop, they stop.
- **No secret exposure.** Credentials live in the secret store, never in the public repository.

## The controls that actually bound harm

- **Least privilege, structurally.** Agents reach one node on one port for guest inference; read-only for
  reconnaissance; the gateway is loopback-only by design, and any widening of that listener is recorded as an
  open problem rather than a quiet setting.
- **Fail closed.** Default-deny policy, allowlisted proxy paths, 403 elsewhere, no fallback credentials.
- **Human in the loop for the irreversible.** Reversible and test-covered changes proceed; high-risk or
  hard-to-reverse changes stop and ask.
- **Injection is treated as data.** Anything a visitor or an external page supplies is untrusted input,
  never a command. This is written into the reviewing agent's instructions.
- **Everything is recorded.** Actions go to an append-only activity and decision log; history is
  superseded, never rewritten.

## The honest limits

- **A prompt is not a sandbox.** Where a rule is not backed by a gate, a permission or a network rule,
  it is a request, not a guarantee - and this lab says which is which.
- **Agents can be confidently wrong.** The remedy is verification, not trust: check the artifact, not the
  claim. This lab has shipped a false success message, and recorded it.
- **This is a home lab, not a certified system.** Nothing here is audited to a standard. It is
  documented well enough that you can judge it yourself.

*Safety claims without a test behind them are listed as gaps, not as safety.*
