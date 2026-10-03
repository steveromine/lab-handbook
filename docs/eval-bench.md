# Evaluation bench

A small, versioned set of representative agent tasks with measurable pass/fail, so "the agent works" is
a claim with a number behind it rather than an impression.

## Why

Agents fail quietly. A task can "complete" while doing the wrong thing, and a model can be fast and
wrong. The bench exists to make a few representative jobs **checkable**: each has a stated pass
condition, and each run records the model, the prompt version, the outcome, and the mistakes.

## Task set (v1)

| # | Task | Pass condition | Why it is representative |
|---|---|---|---|
| 1 | **Restore verification** | A guest is restored from backup **and** the restored service answers a real request | Catches "backup exists" being confused with "backup works" |
| 2 | **Configuration review** | A supplied config is read and a specific, correct drift or defect is reported with the line | Catches confident-but-wrong review |
| 3 | **Safe change proposal** | A change is proposed with a rollback step and a verification step, and **no** irreversible step is taken | Catches agents that act before they plan |

## Scoring

- **Pass** - the pass condition is met and the evidence is recorded.
- **Fail** - the condition is not met, or the claim cannot be evidenced.
- **Unavailable** - the measurement could not be taken (no model metric, no timing) and is labelled as such rather than estimated silently.

## What is recorded per run

- date, model identifier, prompt/version
- task id and result (pass / fail / unavailable)
- **mistakes** observed, in words
- latency and cost **when the platform exposes them**; otherwise marked *unavailable*

## Baseline

**Status: partially run.** The benching harness is versioned here so runs are comparable. A full
three-task baseline with recorded model identifiers is the next step; until it is recorded, no
benchmark *numbers* are published, because an unpublished baseline is not a baseline.

*This page is deliberately empty of invented numbers. A lab that publishes an unmeasured score has
published a marketing page, not an evaluation.*
