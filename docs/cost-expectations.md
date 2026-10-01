# What This Costs to Run

A question every newcomer asks, usually right after "what does it do?": **what does it cost?**
This page answers it honestly, which means it includes the parts that aren't flattering.

## Three kinds of cost, only one of which has a bill

| Kind | What it is | Marginal cost |
|---|---|---|
| **Local models** | Models served on the lab's own GPU | **~zero** — electricity. No token bill, no rate limit, works offline. |
| **Metered API models** | Tokens billed per use | Per-token, and the tiers differ by **~100x** |
| **Your time** | Reviewing output that turned out to be wrong | The expensive one, and the one nobody measures |

The third is real. A cheap answer that's wrong and needs redoing costs more than the
expensive answer that was right — which is the entire argument for paying for the good model
when the question is hard.

## The cost driver nobody expects

Most people assume cost tracks *messages*. It doesn't. **It tracks context length × turns.**

Every turn re-sends the conversation so far. So a long session doesn't grow linearly — it
grows roughly **quadratically** in turns:

- 10 turns, small context → negligible
- 50 turns, growing context → noticeable
- 200+ turns → **millions of cumulative input tokens**, even if every individual answer was short

**Rule of thumb:** a session costs according to *how much context it carries*, not how much
the model writes. A one-line question in a huge session is expensive. A long answer in a
small one is cheap. This surprises everyone exactly once.

## Rough magnitudes, for planning

| Task shape | Input tokens | Output tokens |
|---|---|---|
| Single lookup or classification | 1k – 5k | 100 – 500 |
| Investigate a host, report back | 20k – 80k | 1k – 4k |
| A code change plus verification | 20k – 60k | 2k – 5k |
| Deploy a service end to end | 50k – 200k | 3k – 10k |
| A long interactive session (100+ turns) | **1M – 5M+** | 20k – 80k |

## What to actually expect

| Scenario | Route it through | Expect |
|---|---|---|
| "Is the pool full?" — a scheduled check | **a script. no model.** | **$0** |
| "Why is this service down?" | cheap model | pennies |
| "Deploy this and document it" | mid-tier | cents |
| "Redesign the network segmentation" | frontier | dollars, not cents |
| A long day of interactive work | mixed | **single-digit dollars**, mostly context |

## The two rules that keep it sane

1. **Deterministic work should not be reasoned about at all.** A script that checks whether a
   backup ran costs nothing and cannot hallucinate. A model narrating a healthy system costs
   money to say nothing. Reasoning is for *exceptions*.
2. **Escalating to a frontier model needs a written reason.** Not to police it — but writing
   the reason usually reveals whether it was actually needed.

## An honest caveat

**Treat these as planning estimates, not invoices.** They're derived from token magnitudes and
tier ratios. Making them exact means reading real per-model token counts from the gateway's
usage data and multiplying by current published prices — and even then, measured and estimated
figures should be labelled as such, because presenting an estimate as a measurement is how
budgets get quietly wrong.

The one figure we're confident in: **the scheduled health checks cost nothing**, because they
don't use a model at all. That's a design decision, and it's the one that keeps the bill boring.
