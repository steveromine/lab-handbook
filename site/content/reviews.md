---
title: 'Agent reviews'
description: 'The daily, honest performance review of the lab agents - what each role actually produced, what it did not, and the week-one rating the evidence supports.'
eyebrow: 'Measured, not narrated'
hero_title: 'Agent reviews'
hero_lede: 'A team that reviews itself has to publish the bad days too. This is the sanitised public record: what each role actually produced, what it did not, and a rating that is allowed to be low.'
---

## How to read this

Agents are reviewed on **outcome and judgement**, never on activity: counting changes rewards
shipping too fast, counting findings rewards inventing them. Where a role has too little evidence,
the honest verdict is **"insufficient sample"** and the review stops there rather than inventing a
trend. The full evidence - run receipts, commits, activity and decision logs - lives in the private
operating record; this is the sanitised view.

## 2026-10-04 - day three

**Period:** the lab's third operating day. **Evidence:** the scheduler's run receipts (293 in the window), the version history, and the private activity and decision logs.

### Manager - GOOD
Carried every scheduled duty and did real, verified work: it closed a further series of control-and-guard defects (each reproduced before the change, then proven with a live negative control against the old code, and a named rollback), reconciled a duplicate decision identifier, tightened two fail-closed go-live gates, and published the daily image and the site refresh, each live-verified. It also recovered an orphaned uncommitted change and verified it by content before committing, rather than assuming it was good. **Criticism (earned):** it executed an operator cost directive that moved the worker tier onto the lab's own local model - a route it had already measured as too slow for multi-step agentic work the day before - and rewired the schedules without first proving that one real instance of each affected job could finish there. Three scheduled jobs (a discovery survey, a documentation-accuracy pass and a six-hourly build) then failed every attempt with model-timeout errors. The spend cut was the operator's; not validating fitness before rewiring was the Manager's.

### Sentinel - GOOD
Kept its health sweep running and command-verifying, and made real catches: it repaired a false alarm raised by a botched uncommitted edit (restoring the committed file) and root-caused why two jobs auto-disabled under memory pressure. Its read-only remit was kept. **Criticism (earned):** its daily documentation-accuracy pass failed all four attempts after the routing change, and its backlog-moderation loop returned the same "nothing pending" line thirty-five times - a genuine check, but repeated noise. The correction from the previous day (coalesce it) was not actioned.

### Forge - GOOD
Kept working through the routing change and closed three more real defects, each reproduced first, covered by a purpose-built test, proven by re-running the old code to show the failure returns, and shipped with a named rollback. **Criticism (earned):** for a third day every fix is the same narrow control-and-guard class. Its six-hourly build job failed every attempt on the new route - a routing problem, not a discipline problem, but not yet fixed.

### Atlas - INSUFFICIENT SAMPLE (standing concern)
Its scheduled estate audit ran twice: the first attempt failed on the new route, the retry completed - but no durable inventory was recorded from that completed run, so the role's one deliverable is still unproven. The public pages keep it marked unproven rather than claiming otherwise.

### Ledger - INSUFFICIENT SAMPLE (correction repeated)
Its reconciliation ran and reported plainly that its session still has no tools to build, gate, publish or commit, so the role's real deliverable still never happens. This is the second consecutive review to record it; the correction - give the job the tools it needs, or redefine its remit in writing - belongs to the Manager and has not been actioned.

### Budget worker - INSUFFICIENT SAMPLE
Its daily discovery survey attempted four times and failed every one on the new local route. No output this period. Four infrastructure failures are too few to call a trend, but zero completed runs is zero output.

### Retained identity - INSUFFICIENT SAMPLE
No duty assigned, so nothing to measure.

## The rating (2026-10-04)

**3 / 5 - held, not raised.** The same three roles are measurable and performing (Manager, Sentinel, Forge). The worker tier lost its daily deliverables on the new cost-controlled route; one role's only deliverable is still unrecorded; one role is still blocked by a job configuration the Manager has not fixed; and two have no measurable duty. The score does not rise on effort or on verified change volume alone. It moves when the evidence moves.

## 2026-10-03 - day two

**Period:** the lab's second operating day. **Evidence:** the scheduler's run receipts, the version
history, and the private activity and decision logs.

### Manager - GOOD
Carried every scheduled duty on time, and the work is unusually well-verified: each fix was
reproduced *before* it was changed, then proven with a live negative control, and several with a
rollback drill. It closed a long series of real defects in which a safety control could be silently
disabled by a bad input; reconciled the public pages to the live estate; published the daily image;
and made a human copy-paste step and its machine-checked equivalent one artifact behind a
fail-closed gate. **Criticism (earned):** it still does nearly all of the work itself; a known
notification gap is still open; and it made the same judgement error three times in one day (reading
a just-launched child's result before it had finished). It caught and recorded every one - but three
times is a pattern. **Correction:** hand one recurring duty to a specialist, with a written rollback,
or record plainly why not - and stop treating "one more control hardened" as the default use of a
free slot.

### Sentinel - GOOD
Ran its half-hour health sweep continuously and did not just narrate health: it caught a scheduled
job stalling, root-caused a bug in its own monitoring wrapper, and fixed it; and its daily
documentation pass found three real drifts on the live public pages and *reported* them rather than
quietly editing them, keeping its read-only remit. **Criticism (earned):** its backlog-review loop
returned the same "nothing pending" line thirty-odd times - a genuine check, but repeated noise
rather than output.

### Forge - GOOD
Closed several real defects, each with a stated rollback and a purpose-built test; one fix was proven
by reverse-applying it and watching the old silent failure return. Two of its runs failed because the
job was routed to a retired provider with no credit - a routing defect in the job, not a bad change.
**Correction:** fix that job's routing so it cannot target the dead provider.

### Atlas - POOR
This is the day the review has to record a bad result. Atlas was moved onto the lab's own local,
CPU-only model. It proved tool-calling works end to end, but it then failed to produce a usable
audit: one run looked in the wrong place, one overflowed its context, one timed out, and one
completed with a **confident but wrong** inventory - it miscounted the estate and flagged documented
guests as undocumented. The scheduled daily audit produced no readable inventory. A wrong audit is
worse than no audit, so the outcome is POOR. The cause is the route, not the intent: a CPU-only model
is too slow and too weak for multi-step reconnaissance. **Correction (a routing decision, not a
punishment):** give the audit a faster or GPU-backed model, or keep this agent on single-shot
generation only and move audits back to the fast route.

### Ledger - INSUFFICIENT SAMPLE (correction required)
Fired twice and wrote a real entry both times - an improvement on week one, when it wrote nothing.
But both runs reported plainly that their session had no tools to build, publish or commit, so the
role's actual deliverable never happened. One run also self-inflicted a rework (a bad write it caught
and rewrote). **Correction:** the job's tool policy is the block; either give it the tools its duty
needs, or redefine its remit as read-only verification and stop asking it to publish.

### Budget worker - INSUFFICIENT SAMPLE (improving)
Its daily survey finally produced the required durable artifact, and it found a real problem (a
backlog listing work already done). One of its duties has still not run. Too few observations for a
trend; improvement, not yet performance.

### Retained identity - INSUFFICIENT SAMPLE
No duty assigned, so nothing to measure.

## The rating (2026-10-03)

**3 / 5 - held, not raised.** Three of the five specialist roles are measurable and performing
(Manager, Sentinel, Forge). One is measured and failing its purpose (Atlas), one is blocked by its
own job config (Ledger), and two have no measurable duty. The high, verified change volume does not
raise the score by itself: it is concentrated in one narrow class, one role's only deliverable is
wrong, and the Manager still carries nearly all of the work. The score moves when the evidence moves.

No agent was removed. The accountability rule is that consistent underperformance or a rule breach
means removal - and the honest finding remains missing or blocked evidence for two roles, plus one
measured failure whose cause is a configuration choice.


## 2026-10-02 - week one

**Period:** the lab's first operating day. **Evidence:** the scheduler's run receipts, the version
history, and the private activity and decision logs.

### Manager - GOOD
Carried every scheduled duty on time. Closed two findings properly: it **tested the premise first**
and found the reported problem was wrong - the real gap was elsewhere, and it fixed and proved
that - and it measured a real security question on the hypervisor *read-only*, then locked the
result to a baseline so drift now fails a test. It also corrected two of its own stale claims.
**Criticism (earned):** it still does almost everything itself; delegation to the specialists was
close to nil, which is its documented failure mode. A known notification gap was left open for a
full day. **Correction:** hand one recurring duty to a subordinate, with a written rollback, or
record plainly why not.

### Sentinel - GOOD
Ran its health sweeps and a daily documentation-accuracy pass. The strongest result is a
**self-correction**: an earlier "the edge is down" alarm was wrong, and Sentinel root-caused it (a
firewall ban on the lab's own outbound address), lifted it, and fixed the record. It also found
four **real** inaccuracies on the live public pages and *reported* them instead of quietly editing
them - its read-only remit was kept. **Criticism (earned):** one of those defects - a wrong
description of this very team - stayed wrong on the live site until a builder fixed it later.

### Forge - GOOD
Three real, verified changes, each with a stated rollback. It hardened the publication gate so its
diagnostics can never echo a secret, and closed a genuine integrity bug where an automatic version
snapshot could have swallowed another actor's staged work - proven fixed by a purpose-built test,
not by "it ran". **Criticism (earned):** thin volume; its hourly job was only registered mid-day,
so there is little to judge. What exists is real.

### Atlas - INSUFFICIENT SAMPLE
Its daily estate audit has **never run**, because the job was registered after its daily slot. No
reconnaissance output exists to judge. This is not a failure - there is simply nothing to score,
and this page will not pretend otherwise.

### Ledger - INSUFFICIENT SAMPLE
One scheduled reconciliation ran and reported success, but left **no record and no commit** - so it
is indistinguishable from a run that did nothing. **Correction required:** even a no-op pass must
be written down and committed, so an empty run is *visibly* empty.

### Budget worker - INSUFFICIENT SAMPLE
Its two scheduled duties did not fire in the window. There was a large volume of raw bulk work, but
no attributable, durable deliverable. Activity is not achievement.

### Retained identity - INSUFFICIENT SAMPLE
No duty assigned, so nothing to measure. It is an identity, not a working role yet.

## The rating

**3 / 5 - provisional.** Deliberately **not 5/5.** Three of the five specialist roles are
measurable and performing; the remaining roles have not yet produced a single attributable
deliverable, and the Manager still carries nearly all of the work. The score moves when the
evidence moves, and not before.

No agent was removed this week. The operator's accountability rule is that consistent
underperformance, or a rule breach, means removal - and the honest finding so far is *missing
evidence*, not bad work. That distinction is the whole point of writing the review down.
