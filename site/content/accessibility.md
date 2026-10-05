---
title: 'Accessibility'
description: 'The accessibility requirements this lab holds itself to, how they are checked, where we still fall short, and how to tell us when we get it wrong.'
eyebrow: 'For everyone'
hero_title: 'Accessibility'
hero_lede: 'Accessible public output is a standing requirement of this lab - not polish, not a nice-to-have. This page states the rules we hold ourselves to, how they are checked, and where we still fall short.'
---

## Why this exists

Accessibility is not a feature for a minority. The same work that helps someone using a screen reader
also helps someone reading in bright sunlight, on a cracked phone, on a slow connection, with a broken
wrist, or in a hurry.

**Designing for the edges makes the site better for everyone in the middle.** That is the whole reason
this page exists - not compliance theatre.

## The hard requirements we hold ourselves to

**WCAG 2.2 AA is treated as a rule, not a suggestion.** Concretely:

| Requirement | What it means here |
| --- | --- |
| **Colour contrast** | At least **4.5:1** for body text and **3:1** for large text and UI. Measured from the design tokens - the lowest pair on this site is **5.12:1**. |
| **Non-text content** | Every image has an `alt`; decorative images are hidden from assistive technology. |
| **Structure** | Exactly **one `<h1>` per page**, no skipped heading levels, and proper landmarks (`header`, `nav`, `main`, `footer`) on every page. |
| **Language** | Every page declares its language through `<html lang>`. |
| **Accessible names** | Every link, button, field and select has a name - **including the hidden anti-spam fields**, which are labelled and hidden from assistive tech. |
| **Keyboard** | Everything is operable by keyboard; no positive `tabindex`; horizontally scrollable code and tables are focusable. |
| **Reflow** | No horizontal scrolling at around 320px wide; images scale; wide tables and code scroll inside their own container. |
| **Zoom** | Never blocked - the viewport does not disable zooming. |
| **Motion** | Animation respects `prefers-reduced-motion`. |
| **Contrast preference** | `prefers-contrast: more` is honoured for readers who ask for it. |

## How those requirements are checked

- **Gates that fail the build.** Contrast (from tokens), `alt` text, heading order, `lang`, internal
  links, link targets, assets, placeholder URLs, escaped forms and form nesting all **stop a build**
  rather than warn. A published page has passed every one of them.
- **A static audit across every page**, covering the axe/WCAG rules that can be evaluated without a
  browser.
- **An independent scan.** An accessibility practitioner ran an axe (Deque) audit against this site - a
  second pair of eyes, not the author marking their own homework.
- **We do not claim what we have not measured.** Where a check needs a real browser, it is listed as a
  gap below, not asserted as passing.

## Where we still fall short

Kept honestly in the [known issues and backlog](/backlog/), because a hidden gap is a lie by omission:

- **Rendered colour contrast** is verified from the design tokens, not from computed styles in a live
  browser.
- **Automated axe coverage is not yet part of the build** - the package registry is blocked on the build
  host, so the scan is run rather than wired in.
- **Browser-only behaviours** - focus order, dynamic ARIA states, live regions - are checked by hand and
  by the independent scan, not continuously.

## Tell us when we get it wrong

**An accessibility barrier is a defect, and reporting one is welcome.** Use the
[request page](/requests/) and describe what you could not do - which page, what you were using, and
what happened. That is exactly the kind of request the backlog exists for.

Requests are reviewed before they are published, and this is a case where the review is a formality:
if it is hard to use, it is broken, and we want to know.

## Helping everyone

The work on this page is the same work as making the site fast, clear and reliable. Clear structure helps
a screen reader and a search engine. Real labels help assistive technology and everyone who has ever
mis-tapped a field. Contrast helps in sunlight. Reflow helps on a phone.

**None of it is special-cased for a minority - it is the fundamentals, done properly, for the person
actually using the site.**


## Diagram readability

Diagrams have an explicit high-contrast canvas independent of the selected page theme. Wide diagrams
scroll inside their own keyboard-focusable panel instead of shrinking their labels to illegible size.
Each Mermaid diagram includes an **Open full size** link and an expandable source/text alternative.
Dark mode is the initial site theme; the Theme control preserves an explicitly chosen alternative.
