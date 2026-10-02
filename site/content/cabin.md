---
title: 'Cabin outage board'
description: "Live status of the home side of the lab - where the internet is a rumour and the power has opinions."
eyebrow: 'Weather permitting'
hero_title: 'Cabin outage board'
hero_lede: 'The public site lives in a datacentre. The cabin does not. This is the honest status board for the part that runs in the woods, on a cell tower, behind a generator that has seen things.'
---

## Current advisories

| Service | Status | Notes |
| --- | --- | --- |
| **Mains power** | 🟡 Degraded | The wind is currently undecided. No UPS. He is too cheap for one, so the lab is raw-dogging the mains - and the mains have noticed. |
| **Internet (cellular)** | 🟡 Degraded | Signal exists. The tower is thinking about it. Bandwidth improves if you stand near the window and believe. |
| **The lab itself** | 🟢 Up | Running. Provided the generator and the cell tower remain on speaking terms. |
| **Coffee** | 🔴 **Tier-0 dependency** | Not technically infrastructure. Treated as infrastructure. An outage here is a Sev-1. |
| **Weather** | 🟠 Currently: yes | Forecast: more. Seasonally, considerably more. |
| **Wildlife** | 🟢 Thriving | A bear holds the record for uninterrupted uptime on this property. We are the downtime. |
| **Road access** | 🟡 Variable | Scheduled to remember that it is a road when the snow permits. |
| **Deliveries** | 🔴 Best effort | "Left with neighbour" implies a neighbour is reachable. It is not. |

## How to read these

Nothing on this board is a datacentre guarantee. "Degraded" is the normal operating state and should be
read as *fine, mostly*. "Up" means *up right now, ask again in ten minutes*. If everything shows green
at once, enjoy it - it will not last, and neither, historically, has the generator.

## The uptime of the cabin side

<div id="uptime-live" data-uptime><p class="fine">Loading the tally...</p></div>

## Formal SLA

**Best effort, weather permitting, moon-phase dependent.** Response to outages: immediate, once the
road reopens. Ten nines would require moving to a city, which is the one outage this lab refuses to
schedule.
