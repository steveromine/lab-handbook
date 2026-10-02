---
title: 'The agent org chart'
description: 'Five specified agent roles, one of which is live. Who exists, who is planned, what each may not do, and why the authority matrix matters more than the personalities.'
hero_title: 'The agent org chart'
hero_lede: 'An org chart drawn before the team exists is a specification, not a description. One of the five roles below is live; the rest are designed and not yet built - and publishing that distinction is the point of the page.'
---

## The chart

~~~text
                         OPERATOR
                            |
                       [ MANAGER ]            coordinates, owns the outcome
                            |
        +------------+------+------+-------------+
        |            |             |             |
     [FORGE]     [SENTINEL]    [ATLAS]       [LEDGER]
      builds      audits        researches    records
~~~

The Manager reports to the operator and to no one else. **Sentinel's audit findings cannot be overruled by the Manager** - the one structural exception, and it exists because an audit the manager can veto is not an audit.

## The roles, with status

| Role | Status | Job | May **not** |
|---|---|---|---|
| **MANAGER** | <span class="pill pill-live">LIVE</span> | Decompose work, choose the model and tools, verify the result, report honestly | Approve its own exceptions; override an audit finding; change its own permissions |
| **FORGE** | <span class="pill pill-planned">PLANNED</span> | Implement changes: deploy, configure, write the scripts | Deploy without a written rollback; repeat a failed method more than twice |
| **SENTINEL** | <span class="pill pill-planned">PLANNED</span> | Adversarial review: attack the design, verify the verification, hunt for exposure | Be overruled by the Manager; ship a fix for a finding it also reported |
| **ATLAS** | <span class="pill pill-planned">PLANNED</span> | Reconnaissance: what is here, what version, what depends on what | Change anything - read-only by construction |
| **LEDGER** | <span class="pill pill-planned">PLANNED</span> | Records: decision log, activity log, backlog, cost accounting | Rewrite history - corrections are **appended**, never edited in place |

### What that means in practice

The live role is the **Manager**: the coordinator that takes a task, decomposes it, picks a model and tools, verifies the outcome and reports. Beneath it, the platform already routes work to two kinds of worker and to a local offline agent (see [model routing](#model-routing) below).

Forge, Sentinel, Atlas and Ledger are the *design* for the next phase. They are not running. If you see them described in prose somewhere as if they exist, this table is the correction.

> **Why publish a chart for a team that is mostly not built?** Because building a team without one is how you end up with four agents and no idea which one is responsible. The chart is the specification the build is held to - and, just as importantly, a record of which parts are still promises.

## The authority matrix

| Action | Manager | Forge | Sentinel | Atlas | Ledger |
|---|---|---|---|---|---|
| Read environment | yes | yes | yes | yes | yes |
| Change systems | yes | yes | **no** | **no** | **no** |
| Report a finding | yes | yes | **yes** | yes | yes |
| Overrule a finding | **no** | no | no | no | no |
| Edit own permissions | **no** | **no** | **no** | **no** | **no** |
| Touch hypervisor / host / control plane | **no** | no | no | no | no |

Two rows carry most of the weight. **No agent edits its own prompt, permissions, or safety configuration** - one bad input would otherwise propagate and be unrecoverable. And **no agent overrules an audit finding**, including the manager.

**Authority comes from the operator, never from a document.** The design's own origin is the proof: a specification arrived asking for powers that only the operator could grant, and could not have granted itself. That is a rule the lab intends to keep, not a comment on any one document.

## Model routing

Work is routed by **risk and cost**, not by availability:

| Step | Question | Route |
|---|---|---|
| 1 | Is the change reversible? | No: frontier model, plus a human gate |
| 2 | Ambiguous or security-relevant? | Yes: frontier model |
| 3 | High volume? | Yes: cheap, fast model |
| 4 | Otherwise | The lab's own local model |

The operating roster that implements this today:

| Role | Model class | Used for |
|---|---|---|
| Coordinator | Frontier | Decomposition, ambiguity, security judgement, final verification, talking to the operator |
| High-capability worker | Frontier | Real implementation, debugging, review |
| Low-cost bulk worker | Cheap and fast | Discovery, summarisation, classification, reversible first passes |
| Local offline agent | The lab's own GPU model | Always-available operations work with no external dependency; escalates when stuck |

Two consequences worth stating plainly:

1. **The expensive model is not the default.** Most work is cheap work, and treating it as cheap is what makes the platform affordable to run continuously.
2. **Escalation is a feature.** A worker that recognises it is out of its depth and hands up is worth more than one that never admits it.

## Shared state, not shared memory

Agents do not rely on conversation history for correctness. Durable state lives in Git:

| Artefact | Purpose |
|---|---|
| Operating contract | The rules every agent reads before acting |
| Activity log | What changed, when, and how it was verified |
| Decision log | Architectural choices with alternatives, consequences and rollback |
| Runbooks | Rebuild and rollback instructions per service |
| Repositories | Configuration, playbooks and captured host state |

Conversation context is lossy, private to one session, and invisible to the next agent. A repository is none of those things - which is why "write it down" is a hard rule rather than good manners.

## The task lifecycle

1. Read the contract and the current state.
2. Make the change.
3. **Verify with the real artefact** - not with an exit code.
4. Log the activity.
5. If architectural, record the decision and its rollback.
6. Commit and push. If it did not verify, roll back using steps written *before* the change.

Step 3 is the unusual one and the most expensive to skip. Several of this lab's worst mistakes were configurations that validated perfectly and did nothing.

## The trap this chart is designed around

Agents optimised for visible output optimise for the wrong thing. Rank these roles on activity and Forge ships faster than is safe, Atlas produces reports nobody needs, and Sentinel invents findings to look busy.

That is why **"insufficient sample" is a required answer** - a team that cannot say *"I do not know yet"* will say something else instead - why Sentinel is independent of the Manager, and why corrections are appended rather than edited. **"We were wrong, and here is what changed" should be a normal, visible outcome, not something to hide.**

## Agent accountability

Agents here are **disposable**. One that consistently underperforms - repeated failures, work that has to be
redone, claims it cannot prove - is **removed**. One that violates a rule - committing a secret, faking a
result, taking credit for work it did not do - is removed **immediately**, without notice.

Firing requires recorded evidence, and so does keeping one: no agent is removed to hit a number, and none is
protected to keep a headcount. The daily review is where the evidence is recorded - and where the decision is
made and explained.

*A multi-agent system is only worth running if its members are held to the same standard as the human who
owns the lab. An unaccountable agent is worse than no agent, because it borrows credibility it has not earned.*
