---
title: 'Running it by hand'
description: 'A sanitised map of every management interface in the lab: what each one is, how it is reached, what guards it, and where the recovery documentation lives if the agents are gone.'
eyebrow: 'Operator reference'
hero_title: 'Running it by hand'
hero_lede: 'If every agent went dark tomorrow, could you still run this lab? This page is the answer: the interfaces, the boundaries, and the runbooks - written down so no single head has to remember it.'
---

## Why this page exists

An autonomous lab has one quiet failure mode: the operator loses the map. The agents hold the keys,
the credentials sit in their stores, and the knowledge of *how to get in* gradually becomes tacit. That
is a bad trade. This is the break-glass map, kept deliberately outside the agents' heads.

**Sanitised by design.** Real addresses and credential locations are replaced with role placeholders
(`<agent-host>`, `<proxmox>`, `<gateway>`). The full version, with addresses and secret-store paths,
lives privately in the operating repository. This page is the shape of it; that file is the key.

## The boundary model, in one breath

Three things are true of every entry below, and they are the whole security story:

- **The edge is the only public door.** No lab service has a public listener.
- **Internal services are LAN-scoped.** They assume the internal network is trusted, and say so
  rather than pretending otherwise.
- **One authentication layer per service**, measured by an unauthenticated request - `401`, `403`, or a
  login page - not read off a datasheet.

## Infrastructure

| Interface | Role | Reach from | Guard |
|---|---|---|---|
| Hypervisor | Runs every guest | LAN / overlay | Login + key-only root SSH |
| Agent host | Runs the agent team | LAN / overlay | Gateway token or device pairing |
| DNS admin | Local name resolution console | LAN | Login |
| Jump host | SSH entry point | LAN | SSH key |
| Network controller | Routing and firewall policy | LAN | Login |
| Edge VPS | TLS front door for the public site | Internet | SSH key |

## Applications with their own login

Each of these authenticates you itself. The pattern is uniform: a web console, one login, reachable
from the internal network.

| Interface | Role | Guard |
|---|---|---|
| Password vault | **The canonical secret store** | Login |
| Model chat console | Conversation front-end for the local model | Login |
| Media server (film) | Library front-end | Login |
| Media server (TV) | Library front-end | Login |
| Torrent client | Download engine | Login |
| Series manager | Automated acquisition | Login |
| Film manager | Automated acquisition | Login |
| Indexer manager | Indexer aggregation | Login |
| Request portal | Media requests | Login |
| Fleet dashboard | Visualiser | Login |
| Alerting service | Push notifications from the lab | Login |
| Uptime monitor | Availability checks | Login |

## Deliberately not a management interface

Some services can change the system and still have **no authentication at all**. They are listed here
precisely because a list that only names the guarded things would be misleading.

| Service | Why it is named |
|---|---|
| Image generation API | **No auth.** Reaches the shared GPU. Accepted, not hidden. |
| Local model API | API only, no auth. |
| Log collector | Bound to loopback - unreachable from any network. |
| Operations agent | Bound to loopback. |
| Syslog ingest | Write-only. |

## The rule for this list

An entry belongs under *management interface* if it can **change** the system. Anything that can only
*read* - dashboards, logs, metrics - is not a management interface even when it has a web UI. That
distinction is the reason the list is short enough to be useful in an emergency.

## Where the documentation lives

Every interface above has a runbook in the private operating repository. If something is on fire,
these are the documents, in the order you would reach for them:

| Situation | Document |
|---|---|
| Total break-glass, lost keys | break-glass recovery runbook |
| Cannot reach a host by SSH | SSH access recovery runbook |
| UI reachability and boundaries | UI access runbook |
| Swapping a local model | model-swap runbook |
| Alerts have stopped arriving | notification-mail runbook |
| Rolling back a pairing or model change | rollback runbook |
| Monitoring and dashboards | monitoring guest reference |

## Credentials, in the abstract

The public copy deliberately stops one step short of what a break-glass reader actually wants: the
*locations*. The private guide names each store and each path - the secret store, the credentials
directory, the harvested Cloudflare token and break-glass SSH key, and the per-service
per-service access files on the monitoring and media guests.

What is worth saying publicly is the **discipline**, because it is the part that generalises:

- Names and roles are public; addresses and locations are private.
- A password you set is logged in one place, so the vault stays the single source of truth.
- Listing the secret store prints environment-kind values in **plaintext**. Never paste that output
  where it can be read.
- Before reporting "I have no access": check the access guide, then the secret store, then the config.
  Only then escalate, naming exactly what was searched.

## Keeping it current

A map that describes last month's lab is worse than no map, because it inspires false confidence.
This list is reconciled against the live estate whenever an interface is added, moved, or retired -
and the reconciliation is dated at the top of the private copy.
