---
title: 'Outage'
description: 'What you are looking at when the lab in the woods has stopped answering.'
eyebrow: '502, but funny'
hero_title: 'The lab is down'
hero_lede: 'You reached the datacentre. What you cannot reach is the cabin - the log one, in the woods, behind a cell tower with opinions. This page is served from the boring part that is still standing.'
---

## What probably happened

Pick one. They are all true at least once a season:

- **The power** went out, and the generator is having a moment of reflection.
- **The cellular link** decided that today it is more of a suggestion than a service.
- **A storm** rearranged the sky, the trees, and the delivery estimate.
- **The mains dipped** and there was nothing standing between the rack and the wall - because there
  is no UPS. He is too cheap to buy one. The power is being raw-dogged, and the power knows it.
- **A bear** found the network cabinet. This has not happened. It is on the list anyway, because it
  *could*.

## Meanwhile, on the datacentre side

This page loaded, which tells you something useful: the **public edge is fine**. It is the cabin that is
having a day. The split is deliberate - the part you visit is meant to be boring; the part in the woods
is allowed to be mortal.

## What you can still do

- **Try again in a few minutes.** Outages out here are measured in cups of coffee, not tickets.
- **Read the [cabin outage board](/cabin/)** - it explains the home side with more jokes and fewer excuses.
- **Check the [nines](/uptime/)** - it is the honest scoreboard, and it counts the bad days too.

## What is not happening

No one has lost data. No one is being paged at 3am for a colour on a dashboard. The wren is fine. The
logs are being written down, because that is the one habit this lab never drops.

> A lab that never goes down is a lab that is not in the woods yet.

## What a failure actually looks like

Two different failures, two different pages - worth knowing which one you are seeing:

- **The lab is down, the edge is up** - you get the [failover copy](https://failover.steveromine.com/),
  a static copy served from the edge and re-synced from the public repository. It carries a
  *"Failover copy"* banner at the bottom so you can tell it apart at a glance.
- **The edge itself is down** - nothing of ours can answer, so you would get the CDN's own error page
  instead. Stock, not bespoke. We cannot draw on a screen that is not switched on.

## Live demo: what the CDN serves when we are gone

This one is a genuine, deliberately dead hostname: it points at an address that will never answer, so
the CDN in front of our domain has to give up and speak for itself. Nothing about the real site is
touched by it.

**→ [See the stock failure page](https://down.steveromine.com/)**

That stark, unbranded "web server is down" page is what a visitor sees when the edge itself is lost - as
opposed to the [failover copy](https://failover.steveromine.com/), which is what they see when only the
lab is lost. Two failures, two faces, and now you can compare them side by side.
