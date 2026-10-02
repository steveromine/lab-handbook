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

## Request something

<form class="request-form" id="request-form" method="post" action="/api/request" autocomplete="off">
  <label for="rq-kind">What kind of request?</label>
  <select id="rq-kind" name="kind" required>
    <option value="documentation">Documentation</option>
    <option value="process">Process</option>
    <option value="feature">Feature</option>
  </select>

  <label for="rq-title">Short title</label>
  <input id="rq-title" name="title" type="text" required maxlength="140" placeholder="One line - what are you asking for?">

  <label for="rq-detail">Details</label>
  <textarea id="rq-detail" name="detail" required rows="6" maxlength="1400" placeholder="What would help, and why? A few sentences is plenty."></textarea>

  <label for="rq-who">Who you are <span class="fine">(optional)</span></label>
  <input id="rq-who" name="who" type="text" maxlength="80" placeholder="Name or handle - leave blank to stay anonymous">

  <input type="text" name="website" tabindex="-1" autocomplete="off" aria-hidden="true" class="hp">
  <input type="hidden" id="rq-ts" name="ts">
  <input type="hidden" id="rq-sig" name="sig">
  <input type="hidden" id="rq-nonce" name="nonce">

  <button type="submit" id="rq-submit">Submit for review</button>
  <p class="fine" id="rq-status" role="status" aria-live="polite"></p>
</form>

You can stay **anonymous** - the name field is optional and nothing else about you is stored. If you
do give a name, it is published only if your request is approved, and only as you wrote it.

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
