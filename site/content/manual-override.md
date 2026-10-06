---
title: 'Manual override'
description: 'Why this lab keeps a manual path for everything it automates - the operator stays able to run the machine by hand, instead of becoming dependent on the agents that run it.'
eyebrow: 'Governance'
hero_title: 'Manual override'
hero_lede: 'Every automated decision here has a manual counterpart. Not as a fallback of last resort, but as a structural constraint: the agents may do the work, but they may never be the only way the work can be done.'
---

## What this means in practice

The operator can always take the controls by hand. Every automated decision in this lab has a manual
counterpart, and the manual path does not depend on the agents being healthy, cooperative, or online.

This is a deliberate design constraint, not a fallback of last resort. An autonomous system invites a
quiet failure mode: you stop being able to run it without it. The knowledge of *how* to act moves
into the automation, the automation becomes load-bearing, and the operator becomes a passenger in
their own machine. Capability looks like it went up, because the system got faster. What actually went
up is dependency. So the rule here is structural - the agents may do the work, but they may never be
the only way the work can be done.

What that looks like in practice:

- **The map stays outside the machine.** Access paths, interfaces and recovery procedures live in
  written runbooks, not in an agent's context window. If every agent went dark tonight, those
  documents would still get you in.
- **A human makes the irreversible calls.** Autonomy is granted for what is reversible and
  test-verifiable. Anything hard to undo waits for a person - the point is discretion, not throughput.
- **The work is inspectable, not just observable.** You can read the change, the evidence and the
  rollback step, and reproduce them by hand. A result you cannot check is a result you have to trust,
  and trust without verification is how agency gets given away.
- **Manual override is exercised, not assumed.** A recovery path nobody has walked is a rumour. The
  break-glass route is written down, dated, and used - including the parts that turned out to be wrong.

That last point is the uncomfortable one. Dependence does not announce itself; it accumulates through
a thousand small conveniences, each reasonable on its own. The corrective is to keep the manual path
warm on purpose, and to accept the small friction of doing so as the price of still being the one who
decides.

> "We created the Machine, to do our will, but we cannot make it do our will now."
>
> — E. M. Forster, *The Machine Stops* (1909)

Forster wrote that about a society that had delegated so thoroughly that it could no longer operate
its own infrastructure, and mistook that helplessness for progress. Written in 1909, before any of
this existed. It is the clearest statement of the risk this section exists to guard against: the
danger is not a machine that turns on us, but one we quietly stop being able to live without.

## Related

- [The human in the loop](/operator/) — the operator's role, and the calls reserved for a person.
- [Safety](/safety/) — testing, rollback, and the limits on autonomous change.
- [Running it by hand](/running-it-by-hand/) — the break-glass map, if the agents are gone.
