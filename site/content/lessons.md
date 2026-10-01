---
title: 'Lessons, written down'
description: 'Expensive failures from a real lab, each with the symptom, what was assumed, what it actually was, the fix and the permanent rule it produced.'
hero_title: 'Failures, and what they actually were'
hero_lede: 'These are not general principles. Each one cost hours in this lab, and each is now encoded in a skill or a runbook so it cannot recur silently.'
---

> The most common shape of failure here is **a claim that reported success and did nothing**. The second most common is **a failure that looked like a different failure**. Both are why the lab's first rule is *verify with the artefact*.

## 1. The network is broken - usually it is an MTU problem

**SYMPTOM** - A page prompts for a password and then hangs. Small requests succeed. Large ones never complete. A ping works fine.

**WHAT WE THOUGHT** - An application bug, then an authentication bug. The investigation started in the wrong place entirely, twice.

**WHAT IT ACTUALLY WAS** - An overlay link without working path-MTU discovery. Small packets pass; anything larger is silently dropped. Nothing errors - the payload simply never arrives.

**FIX** - Pin the tunnel's MTU below the path MTU on **both** ends, and verify with a correctly sized probe: a payload just under the limit must pass, and one over it must fail for the expected reason.

**PERMANENT LESSON** - A selective failure keyed to payload size is a network fault, not an application fault. Check the link before rewriting the app.

## 2. Two authentication layers fight each other

**SYMPTOM** - The login POST succeeds, the profile loads, and then the front-end signs the user out in a burst. It reads as a wrong password.

**WHAT WE THOUGHT** - The password was wrong, then that the app had a session bug, then that the edge credentials were mistyped.

**WHAT IT ACTUALLY WAS** - An edge proxy fronting an application that has its own login, with both using the **same request header**. The app tried to read the edge's credentials as its own token and rejected them.

**FIX** - Exactly one authentication layer. An application with its own login gets a bare edge block. **Stripping the header at the edge does not work** - that same header carries the application's own token, so removing it breaks the app instead. The fix is architectural.

**PERMANENT LESSON** - Count your authentication layers before you debug a login. A success that is immediately undone is a layering problem, not a credential problem.

## 3. Validation is not verification

**SYMPTOM** - A configuration edit is reported as applied. Validation passes. The reload succeeds. Nothing changed.

**WHAT WE THOUGHT** - The change was live, because the tool said so and the service accepted it.

**WHAT IT ACTUALLY WAS** - A programmatic edit that matched nothing - a pattern aimed at a structure that had since nested one level deeper. Two rounds were lost reporting a rule change that was never written, on an unchanged file.

**FIX** - Read the file back after editing and compare against what was intended, not against the exit code. Match on structure, such as balanced blocks, rather than on a pattern.

**PERMANENT LESSON** - Every claim of done needs an artefact: a rendered image, an extracted archive, a page that loads, a file containing the expected text.

## 4. A GPU is a budget, not a checkbox

**SYMPTOM** - A model loads successfully, then fails at inference with an out-of-memory error.

**WHAT WE THOUGHT** - The model was broken, or the quantisation was bad, or the driver was at fault.

**WHAT IT ACTUALLY WAS** - Two workloads that each fit in 8 GB, but not together. The first owns roughly 5 GB permanently.

**FIX** - Make the second workload **stream** rather than reside. Modules move in on demand; steady-state cost drops to a few hundred megabytes. The model class is then chosen for its ability to stream - see [GPU as a budget](/gpu-budget/).

**PERMANENT LESSON** - Capacity that works in isolation is not capacity that works together. Budget VRAM the way you would budget RAM on a shared host, and monitor it as a first-class metric.
## 5. Retirement is a task, not a state

**SYMPTOM** - Guests accumulate, each labelled <code>*-retired-pending-deletion</code>, consuming hundreds of gigabytes of a pool that is slowly filling. The label reads like a process; nothing is progressing.

**WHAT WE THOUGHT** - The work was essentially done, because everything was marked for deletion.

**WHAT IT ACTUALLY WAS** - Renaming is easy and deleting feels risky, so nothing forced the second step. The naming convention had become a way of *feeling* organised.

**FIX** - Capture the configuration, then destroy the guest. The configuration is what you might want again; the disk image almost never is.

**PERMANENT LESSON** - A state label is not a task. If nothing schedules the second half of the work, the first half is decoration.

## 6. Measure the number that actually moves

**SYMPTOM** - Several hundred gigabytes of guest disks are deleted and the storage free space is unchanged. The cleanup looks like a failure.

**WHAT WE THOUGHT** - The deletion had not worked, or the space was not reclaimed.

**WHAT IT ACTUALLY WAS** - The volume group reports *its own* unallocated space. A thin pool owns the space, so the volume group's free space barely moves when thin volumes are deleted. The pool's own usage percentage is the number that moved.

**FIX** - Measure the layer that owns the resource - and watch the thin pool's **metadata** as well as its data, because a pool that runs out of metadata goes read-only and its guests fail confusingly.

**PERMANENT LESSON** - Picking the wrong metric makes a working change look broken and a broken one look fine. This generalises far beyond storage.

## 7. Silent capability gaps are better stated than hidden

**SYMPTOM** - A user attaches a picture and the model says nothing useful about it. Or attaches an archive and the model knows nothing, while the interface happily shows the file attached.

**WHAT WE THOUGHT** - The model was weak, or the upload had failed.

**WHAT IT ACTUALLY WAS** - Two different things: there is no vision model at all, and a parser sidecar was unreachable, so the upload indexed as empty while still appearing attached.

**FIX** - State the gap in the documentation and make the failure mode explicit. A documented gap is a roadmap item; an undocumented one is a support incident.

**PERMANENT LESSON** - If you cannot say how a capability fails, you do not yet understand it. Write the failure mode next to the feature.

## 8. The default is often wrong for your case

**SYMPTOM** - Three unrelated components behaved strangely: an image model was slow, a web search silently returned nothing, and a tunnel black-holed large packets.

**WHAT WE THOUGHT** - Three separate bugs, in three separate subsystems.

**WHAT IT ACTUALLY WAS** - Three defaults, all reasonable for the common case and wrong for this one: a large diffusion step count, JSON output disabled in a metasearch service, and an optimistic tunnel MTU.

**FIX** - Set the values explicitly rather than inheriting them: few steps for a distilled model, JSON enabled for a trusted internal caller, MTU pinned on both ends.

**PERMANENT LESSON** - Defaults are tuned for the common case. When your case is unusual, the default fails in a way that looks like something else entirely. Read the defaults of every component you introduce, and record the sharp edges in the runbook.

## The summary

| Lesson | Now encoded as |
|---|---|
| MTU black-holing | A rule in the edge operations skill |
| One authentication layer | A rule in the edge operations skill |
| Validation is not verification | A step in the operating contract |
| GPU as a budget | A note in the image-generation runbook |
| Retirement is a task | This page |
| Measure the right number | This page |
| State your gaps | The roadmap section of every document |
| Defaults are wrong for unusual cases | The sharp-edges sections of the runbooks |
| Context belongs in Git | The operating contract |
| Sidecars for capabilities | The parser and search deployment pattern |

## Where these came from

Each lesson is a summary of a real incident recorded in the private operating logs. The public handbook keeps the shape of the failure and the rule it produced; it deliberately omits the addresses, credentials and access paths involved.
