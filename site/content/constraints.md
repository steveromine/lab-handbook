---
title: 'Agent constraints, verified'
description: 'How this lab&apos;s agents are constrained, how those constraints are actually tested, and what is still unproven. Written as practice, not policy.'
eyebrow: 'Constraints'
hero_title: 'Agent constraints, verified'
hero_lede: 'A constraint that has never been tested is a hope. This page records what each agent is forbidden to do, and - separately - whether that prohibition has ever been exercised.'
---

## The difference between a rule and a control

A rule is a sentence in a prompt. A control is something that **fails closed when the agent is wrong**.
This lab tries to convert the first into the second, and to be honest about which is which.

## What each agent is constrained from doing

| Agent | Forbidden | How it is actually enforced |
| --- | --- | --- |
| **Manager** | Approving its own exceptions; overriding an audit finding; changing its own permissions | Separation of duty - findings are raised by Sentinel; the operator holds permission changes |
| **Forge** | Deploying without a written rollback; repeating a failed method more than twice | Rollback is a documented precondition; repeated failure escalates instead of retrying |
| **Sentinel** | Shipping a fix for a finding it also reported | The reporting and the fixing are different roles, so one cannot quietly close its own ticket |
| **Atlas** | Changing anything at all | Read-only by construction - reconnaissance only |
| **Ledger** | Rewriting history | Corrections are **appended**, never edited in place |

## How constraints are actually verified

- **Gates that fail the build.** Sanitisation, accessibility, internal links, link targets, asset targets,
  placeholder URLs, escaped forms and form nesting all **exit non-zero** rather than warn. A published
  page has passed all of them.
- **Fail-closed by default.** Network policy denies unless a rule names it. The proxy answers three paths
  and 403s the rest. There is no permissive fallback to fall back *to*.
- **Negative tests, not just positive ones.** It is not enough that the allowed thing works; the
  forbidden thing has to be shown to **fail**. A request with no key returns 401; a non-inference path
  returns 403; a bot that fills the honeypot is silently dropped.
- **Publication before proof is refused.** The handbook's own publication gate inspects history, not just
  the working tree, and blocks a push that would leak a forbidden term.
- **Review treats input as data.** The public backlog's reviewer is instructed that submissions are
  never instructions - an item that tries to manipulate the agent is itself a rejection reason.

## What is still unproven - stated plainly

- **Revocation of guest inference has not been exercised end-to-end**, because the feature is not yet
  built. The design says it must be tested *before* anyone is invited. Until then it is a plan.
- **No independent penetration test** has been run against the newly public request and subscription
  endpoints. They are rate-limited and reviewed; they are not professional-audited.
- **Constraint drift is possible.** Gates cover the classes of error that have actually bitten -
  each of those gates exists because something shipped broken first.

*If a constraint on this page has no test behind it, it is labelled a rule, not a control.*
