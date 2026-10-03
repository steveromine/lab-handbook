---
title: 'Break the lab'
description: 'Pick a scenario - edge outage, a compromised client, a missing firewall rule - and see which paths break, marked honestly as verified, documented or illustrative.'
eyebrow: 'Interactive'
hero_title: 'Break the lab on purpose'
hero_lede: 'Every scenario below is labelled with how much is actually known about it. Some are backed by a real test; some are documented configuration; some are a walkthrough that teaches the shape of the system. None of them is a live simulation, and the page says so.'
---

## How to read a scenario

| Label | Meaning |
|---|---|
| **verified** | A test was run and the outcome recorded. |
| **documented** | Follows from written configuration, but was not exercised. |
| **illustrative** | A teaching walkthrough. Not a measurement. |

Nothing here changes the lab. Choosing a scenario only changes what this page shows you.

{{FORM:break-lab}}

## The honest summary

The **edge outage** and **missing firewall rule** paths are drawable from documented configuration but
were **not** exercised end to end in this build, so they are labelled *documented*. The **compromised
client** path leans on the one thing that *was* measured - the denied edge probe in the
[service map](/service-map/) - and the rest is *illustrative*. The distinction is the point: a demo that
looked the same whether or not anything had been tested would be worthless as evidence.
