# What the AI work costs

Part of the handbook. Answers the question a newcomer actually asks: *"what should I expect
this to cost?"* Written to be useful rather than reassuring.

> **Sanitisation note.** This page is a sanitised mirror of a private working page. The
> substance is identical; the specific **models and providers** the lab uses are deliberately
> not named here. The *structure* of the cost — which is the transferable part — is unchanged.

## The three cost classes

| Class | What it is | Marginal cost |
|---|---|---|
| **Local GPU models** | Models served on the lab's own hardware | **~zero** — electricity. No token bill, no rate limit, works offline. |
| **Metered API models** | Tokens billed per use | Per-token, and tiers differ by **~100x** |
| **Operator time** | Reviewing output that turned out wrong | The expensive one, and the one nobody measures |

The third is real. A cheap answer that is wrong and needs redoing costs more than the expensive
answer that was right. That is the whole argument for paying for the good model on a hard question.

## Model tiers

Named by role rather than by product — the ratio is what matters, not the logo.

| Tier | Typical use | Relative cost |
|---|---|---|
| Local | Routine ops, offline work, sanity checks | **free at the margin** |
| Low-cost API | Bulk discovery, summarisation, classification | **1x** (baseline) |
| Mid-tier API | Normal implementation, debugging, review | ~10–30x |
| Frontier API | Ambiguity, architecture, security judgement | ~30–100x |

**The spread from cheapest to dearest is about two orders of magnitude.** That is why *routing*
matters far more than any optimisation inside a single model.

## The thing that actually drives the bill: context

Most people assume cost tracks *messages*. It does not. **It tracks context length × turns.**

Every turn re-sends the conversation so far, so a long session grows roughly **quadratically**
in turns rather than linearly:

- 10 turns, small context → negligible
- 50 turns, growing context → noticeable
- 200+ turns → **millions of cumulative input tokens**, even if each individual answer was short

**Rule of thumb:** a session costs according to *how much context it carries*, not how much the
model writes. A one-line question inside a huge session is expensive; a long answer inside a
small one is cheap. This surprises everyone exactly once.

## Realistic per-task magnitudes

Order-of-magnitude, for planning. Input tokens dominate in long sessions.

| Task shape | Input tokens | Output tokens |
|---|---|---|
| Single lookup or classification | 1k – 5k | 100 – 500 |
| Investigate a host, report back | 20k – 80k | 1k – 4k |
| A code change plus verification | 20k – 60k | 2k – 5k |
| Deploy a service end to end | 50k – 200k | 3k – 10k |
| A long interactive session (100+ turns) | **1M – 5M+** | 20k – 80k |

## What to expect in practice

| Scenario | Route it through | Expect |
|---|---|---|
| "Is the pool full?" — a scheduled check | **a script. no model.** | **$0** |
| "Why is this service down?" | cheap model | pennies |
| "Deploy this and document it" | mid-tier | cents |
| "Redesign the network segmentation" | frontier | dollars, not cents |
| A long day of interactive work | mixed | **single-digit dollars**, mostly context |

## Keeping it honest

1. **Deterministic work should not be reasoned about at all.** A script that checks whether a
   backup ran costs nothing and cannot hallucinate. A model narrating a healthy system costs
   money to say nothing. Reasoning is for *exceptions*, not for narrating normal operation.
2. **Escalating to a frontier model needs a written reason.** Not to police it — but writing the
   reason down usually reveals whether it was actually needed.
3. **Local models make routine work free.** Anything with one right answer should never touch a
   paid model.

## Limits of these numbers

**Treat these as planning estimates, not invoices.** They are derived from token magnitudes and
tier ratios, not from a metered billing feed.

Making them exact means reading real per-model token counts from the gateway's own usage data
and multiplying by current published prices — and even then, **measured and estimated figures
must be labelled separately**, because presenting an estimate as a measurement is how budgets
quietly go wrong.

The one figure we are confident in: **the scheduled health checks cost nothing**, because they do
not use a model at all. That is a design decision, and it is the one that keeps the bill boring.
