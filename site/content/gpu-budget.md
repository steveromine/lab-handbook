---
title: 'GPU as a budget'
description: 'One 8 GB card shared by three workloads: what fits, what does not, and how a few-step model became a sharing strategy rather than a compromise.'
hero_title: 'GPU as a budget, not a checkbox'
hero_lede: 'One consumer card, 8 GB of VRAM, and a set of models larger than the card - so the lab swaps them on demand. Almost every AI decision here follows from that constraint rather than from preference.'
---

## The constraint

| Workload | Character | VRAM behaviour |
|---|---|---|
| Local language models | **Swappable** - one resident at a time | one model's weights on the card; the rest of the set waits on disk |
| Image generation | **Streaming** - modules loaded on demand | a few hundred megabytes at steady state |
| Media transcoding | Bursty, latency tolerant | dedicated encoder, contended on demand |

A GPU is a **budget**, not a checkbox. Two workloads that each "fit" in isolation may still not fit together, and the failure mode is deceptive: the model *loads* successfully and then dies at inference with an out-of-memory error. That reads as "the model is broken" rather than "you over-committed the card".

## Two rules fell out of it

1. **The card holds one model at a time.** 8 GB fits one set of weights, so the lab's language models are **swapped on demand** rather than kept side by side. Giving the lab four selectable models did not mean four resident ones - it meant a swapper that loads whichever was asked for and unloads the last.
2. **Streaming beats resident for the second model.** A model that loads its modules on demand costs a little latency and almost no standing memory - which is the only way two models coexist on this card at all.

## The memory decision, step by step

~~~text
Load the image model fully resident
        |
        +-- enough free VRAM? -- NO --> out of memory at inference time
        |                                   |
        |                                   v
        |                        stream modules in on demand
        |                                   |
        +-- YES --> serve                  v
                                    steady state: a few hundred MB
                                           |
                                           v
                                    runs alongside the resident LLM
                                           |
                                           v
                                    trades a little latency for coexistence
~~~

Measured on the real hardware with the language model running: **roughly 1.5-2.5 seconds per image**, at a cost of only a couple of hundred megabytes above the resident model. The alternative - a fully resident diffusion model - failed outright at inference.

## The choice that looks like a downgrade and is not

The image model is a **distilled few-step** model (one to four steps, small resolution by design) rather than a conventional many-step one. On a spec sheet that looks like a compromise. In reality it is a **sharing strategy**: a few-step model tolerates being streamed, and its speed is a side effect that happens to be welcome.

Two more defaults had to be corrected, both of which fail in ways that look like something else:

| Setting | Default | Why it is wrong here |
|---|---|---|
| Diffusion step count | Large (suits conventional models) | A distilled model needs **few** steps; the default is slow and pointless |
| Tunnel MTU | An optimistic default | Silently black-holes larger packets - see [Lessons](/lessons/) |

## What the GPU does not do

- **It does not understand images.** There is no vision model and no multimodal projector, so an uploaded photograph is opaque to the model. Documents and archives are readable; pictures are not. This is the stack's clearest remaining gap, and it is listed rather than discovered.
- **It does not run a frontier model.** A quantised 7B-class model is chosen for *operations* work - reading configuration, writing scripts, summarising - not for open-ended reasoning. The platform accepts that and keeps an escalation path to larger models rather than pretending the small one is enough.

## Why this generalises

"A GPU is a budget" is the local case of a broader rule the lab applies elsewhere: **measure the number that actually moves**. A volume group's free space is not a thin pool's usage; a container's disk usage is not the host's; a tunnel's throughput is not the link's. Picking the wrong number makes a working change look broken and a broken one look fine.

> **Watch VRAM as a first-class metric.** VRAM pressure is exactly the kind of thing that builds silently until something fails at the worst moment, so the hourly monitor checks it - with a script, not a model.


## The budget, visually

{{FORM:gpu-budget}}

The bar is the whole argument: **the resident model is most of the card**, the streaming model is a thin
slice because a few-step model loads only what it needs, and transcoding is bursty enough to share. The
remaining headroom is what makes the sharing safe rather than lucky. Every figure above is an
**estimate from documented configuration and measurement**, not a live telemetry readout, and it is
labelled as such on purpose.
