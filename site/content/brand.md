---
title: 'Brand'
description: 'The Lab Handbook brand sheet: logo, colors, type and voice - everything needed to stay on-brand.'
eyebrow: 'Brand sheet'
hero_title: 'Brand, without the drama'
hero_lede: 'A small, opinionated style sheet so the handbook looks like one thing instead of a yard sale. Colors, type, logo rules and a voice guide. No committee required.'
---

![The Lab Handbook logo](/assets/logo.svg)

## The logo

Geometric, calm, and built from three stacked bars plus one orange dot - data, plus the agent that
tidies up after it. Two files: a full lockup and a square mark.

| File | Use it for |
|---|---|
| `/assets/logo.svg` | Headers, README, anywhere there is room for the wordmark |
| `/assets/logo-mark.svg` | Favicons, avatars, small square spots |

**Rules of thumb.** Keep clear space of at least one bar-width on all sides. Never stretch it,
recolor it, or drop a shadow on it - it is a logo, not a bumper sticker.

## Color

| Role | Hex | Where |
|---|---|---|
| Ink | `#0E1116` | Body text, headings |
| Paper | `#F7F5F0` | Page background |
| Signal | `#4C7DFF` | Primary accents, links |
| Violet | `#8A6BFF` | Gradient partner |
| Flame | `#FF7A45` | The one accent dot, warnings |
| Meadow | `#2FBF71` | Success, healthy status |
| Slate | `#8B95A7` | Muted text, captions |

The gradient runs **Signal -> Violet**, top-left to bottom-right. Use it on the mark and hero rules
only, or it stops feeling special fast.

## Type

- **Headings:** system UI sans, bold, tight tracking. No fancy display faces - this is a lab, not a perfume ad.
- **Body:** the same family, regular weight, generous line height (about 1.6).
- **Code:** the monospace stack, for paths, commands and hex values.

If it renders well with no network and no webfonts, it is on-brand.

## Voice

Plain, honest, a little dry. Say what changed and how it was verified. A green check is not proof,
and a theory is not a finding. A joke is allowed; a euphemism is not.

- **Do:** "The restore was tested, then tested again."
- **Don't:** "Leveraging synergies to action robust resilience." (Someone has to answer for this sentence.)

## Applying it

Keep one source of truth: colors live here, the logo lives in `site/assets/`, and pages borrow both.
When in doubt, subtract. A quieter page is almost always the more polished one.

## Self-test

Want to check the site is working from where you are? There is a [self-test page](/test/) that runs
the checks live in your browser - API, images, navigation and all.
