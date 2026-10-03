---
title: 'One agent run, step by step'
description: 'A real, sanitised agent run with its task, model route, tool calls, verification and resulting commit - replayed from the same trace data, not a second telling.'
eyebrow: 'Evidence'
hero_title: 'A run you can step through'
hero_lede: 'This is one real run, sanitised. Its steps come from the run\'s own trace, so the timeline below and the replay are the same data seen twice - not two accounts of the same event.'
---

## The run

**Task:** build and verify a demonstration recording, then publish it only if the checks pass.
**Model route:** the lab's default agent route (a single provider; no cross-provider fallback).
**Source revision at the end:** recorded in the build receipt for the release.
**Outcome:** completed; the checks are recorded in the same run.

## Timeline

| # | Step | Kind | Result |
|---|---|---|---|
| 1 | Read the operator request | input | ok |
| 2 | Inspect repository and baseline | tool | build green, baseline recorded |
| 3 | Capture the demonstration frames | tool | frames written |
| 4 | Encode the recording | tool | file produced |
| 5 | **Verify the recording frame by frame** | verification | mismatch found on the first take |
| 6 | Correct and re-capture | tool | second take verified |
| 7 | Publish through the documented path | deploy | checks passed, published |
| 8 | Record the result | write | commit created |

Step 5 is the one that matters. The first take **failed verification** and the run did not proceed
until it was corrected - which is the whole reason verification sits inside the run rather than after it.

## Replay

{{FORM:run-replay}}

The replay above uses the same step list as the timeline. It is a **replay**, not a live simulation:
nothing is executed when you scrub, and the run is not re-invoked.

## What was left out

Sanitised means **left out, not paraphrased**: no credentials, no internal addresses, no private prompts,
no personal data. Trace identifiers are kept where they were available so an operator can correlate the
entries; nothing was invented to fill a gap.
