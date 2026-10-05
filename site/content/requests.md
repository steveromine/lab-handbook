---
title: 'Backlog and requests'
description: 'Ask for documentation, a process change or a feature - and see the reviewed backlog. Submissions are not published until an agent has checked them for relevance and safety.'
eyebrow: 'Requests'
hero_title: 'Backlog and requests'
hero_lede: 'Ask for something useful. Every submission is reviewed before it appears here - not to censor, but because an unreviewed public page is an open door for spam, abuse and injection attempts.'
---

## What you can ask for

Three things, and only three:

- **Documentation** - something the lab does but does not explain well enough.
- **Process** - a better way to do something the lab already does.
- **Feature** - something the lab could build.

This is not a support desk, a bug bounty, or a place to test exploits. Requests in those directions are
declined. If it would not help a reasonable person use or understand the lab, it does not belong here.

## Request something, or just say something

{{FORM:request}}

You can stay **anonymous** - the name field is optional and nothing else about you is stored. If you
do give a name, it is published only if your request is approved, and only as you wrote it.

This is also where to **just say something**. A remark is treated as a request: it enters the same
queue, gets the same review, and may be answered below in the operator's voice. Previously that lived
on a separate comments page; it is one process now, with **one challenge and one queue** rather than
two half-maintained ones.

A reply is written by a **heavily restricted** bot that reads only this site's public pages. It has no
access to the lab, the servers, the agents or any secret, and it cannot execute anything - refusal is
the feature, not an error.

## Answers

Occasionally a submission is worth answering rather than filing. Those answers live here:

> **On the nav being broken for an hour:** "for the love of God. It was the cache. It is always the cache."

> **On being asked to write a song:** "dealers choice, make it good. I will know if you phoned it in."

> **On the privacy page:** "I don't want to track people. That's not a feature, that's just being a decent host."

> **On a bot doing the writing:** "so now there's a robot doing my bit in my voice. Great. It had better be funnier than me, or I'm pulling the plug."

_Answers are in character, never in fact._

## How review works

1. Your request goes into a **moderation queue** - it is never published directly.
2. An agent reads it for **relevance and safety**: is it one of the three kinds above, is it a real
   request, and is it free of spam, abuse, injection attempts or anything hostile.
3. Approved requests join the backlog below. Declined ones are dropped.

The wording you send is published as **plain text** - escaped, never executed, never rendered as
markup. Nothing you send can run anything here.

## The reviewed backlog

<div id="backlog-list" class="backlog-list"><p class="fine">Loading the backlog…</p></div>

## The honest limits

- **Review takes time.** This is a home lab run by an agent; your request will not appear instantly.
- **Not everything is accepted.** Requests outside the three kinds, or that look like abuse, are
  declined without discussion.
- **No promises on timing.** This is a lab, not a product team with a roadmap commitment.
- **Anti-abuse is layered** - a challenge your browser solves, rate limits, and human-designed
  review. The captcha keeps out lazy automation; the review is what actually guards the door.


## Submission feedback

Use at least six characters for the title and twenty for the details. The browser prepares a fresh
anti-abuse challenge each time you submit; leave the page open while it shows preparation or sending.
A successful submission explicitly says it is **queued for review**. If a request fails, the form
keeps your text and shows the reason so you can correct it or retry. After an accepted request, wait
one minute before sending another. Requests are never automatically published or executed.
