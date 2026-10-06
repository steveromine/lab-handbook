---
title: 'Governance'
description: 'How the lab makes decisions, limits agent authority, reviews performance, and handles safety, privacy and public requests.'
eyebrow: 'Rules and accountability'
hero_title: 'Governance'
hero_lede: 'What agents may do, what needs a human decision, and how we show our work. Policies belong beside the evidence that they are being followed.'
---

## Authority and boundaries

- [The human in the loop](/operator/) — who sets direction and makes the consequential decisions.
- [Safety](/safety/) — testing, rollback, and limits on autonomous changes.
- [Constraints](/constraints/) — the operating boundaries and deliberate trade-offs.
- [Manual override](/manual-override/) — why the operator stays able to run the machine by hand.
- [Security](/security/) — trust boundaries, authentication, and secure remote administration.

## Documentation is the deliverable

**Status: a hard requirement, and a work in progress. The lab does not fully meet it yet, and says so.**

No feature, service, configuration, model or routine is considered finished until the documentation is
current at the same standard as the rest of the lab: what it is, where it lives, how it is reached,
what guards it, what was verified and when, and how to undo it. Documentation is not a follow-up task
to be done later - it is part of the change, and a change without it is not done.

This is a **forward-looking standard**, not a claim about today. The lab has real documentation debt,
and the honest position is to name it rather than wait until it is all cleared. Where something does
not meet the bar, it is listed under [Known issues and backlog](/backlog/) rather than quietly omitted
- an undocumented service is a defect, and a defect that is written down is at least honest.

What the standard requires of every change:

- **Dated.** A reader can tell when a claim was last checked, and it is not implied to be current.
- **Verifiable.** State the evidence for each claim - a command, a status code, a hash - not a promise.
- **Reversible.** Name the rollback step. If it cannot be rolled back, say that instead of implying it.
- **Reconciled in the same turn.** The change and its documentation land together, not in a later pass.
- **Written for a human under pressure.** Address, port, credential location, recovery path. If the
  agents are gone, the document is what remains.

### Why this is a governance rule and not a chore

A system nobody can describe is a system nobody can operate - or take back. The point of documentation
is not tidiness; it is the same point as [manual override](/manual-override/): the lab stays legible,
therefore controllable, therefore still the operator's. Undocumented automation is a slow transfer of
agency to the thing doing the work. Writing it down is how control is kept.

## Responsibilities to visitors

- [Privacy](/privacy/) — what the site does and does not collect.
- [Accessibility](/accessibility/) — readable, usable output and the checks behind it.
- [Requests](/requests/) — propose documentation, process improvements, or features; submissions require review.

## Evidence and accountability

- [Agent reviews](/reviews/) — evidence-based assessments, including limitations and failures.
- [Known issues and backlog](/backlog/) — gaps we acknowledge and fixes we can verify.

Operational health remains under [Status](/status/), and implementation instructions remain under
[Build](/build/) and the [Handbook](/handbook/). Governance groups the rules and review process,
without changing those pages' existing links or bookmarks.
