---
title: 'Status and known gaps'
description: 'What is designed, configured, verified, a known gap, or merely planned - reconciled against the lab records, with the unproven parts named.'
hero_title: 'Status, and the gaps that come with it'
hero_lede: 'A documentation reconciliation, not a fresh live audit of every service. It records what has actually been proved, and - more usefully - what has not.'
---

## How to read this

| Label | Means |
|---|---|
| <span class="pill pill-designed">DESIGNED</span> | Agreed and written down; not built. |
| <span class="pill pill-configured">CONFIGURED</span> | The configuration exists and validates. That is not the same as working. |
| <span class="pill pill-verified">VERIFIED</span> | The artefact was produced and read: a page loaded, a restore completed, a file contained the expected text. |
| <span class="pill pill-gap">KNOWN GAP</span> | A limitation that is understood, recorded and not yet fixed. |
| <span class="pill pill-planned">PLANNED</span> | Intended, with no work started. |

> "Configured" and "verified" are deliberately different words on this page. Several of the lab's most expensive mistakes were configurations that validated perfectly and did nothing - so a green check gets the weaker label until something has actually been exercised.

## The reconciliation

| Area | State | What is recorded | What remains unproven |
|---|---|---|---|
| **Backup** | <span class="pill pill-verified">VERIFIED</span> | Weekly guest coverage corrected; the vault was restored to an isolated scratch guest and its application data verified | A restored *login* was never proved, and every archive still lives on the same hypervisor - host loss remains an unresolved recovery gap |
| **Monitoring** | <span class="pill pill-verified">VERIFIED</span> <span class="pill pill-gap">KNOWN GAP</span> | Hourly deterministic checks cover capacity, backup age, log-ingestion growth, GPU pressure and service health; an alerting service and availability monitor are deployed on a dedicated guest | The push destination is configured but the availability monitor still needs its first-run setup, and alert routing from the hypervisor is not wired yet |
| **Local model** | <span class="pill pill-verified">VERIFIED</span> <span class="pill pill-gap">KNOWN GAP</span> | GPU-backed text inference is deployed, not a future migration; the raw interface and the richer chat front-end are separate services | The raw interface is unauthenticated on allowed internal paths, and its source restrictions need deliberate review |
| **Agent UI** | <span class="pill pill-configured">CONFIGURED</span> <span class="pill pill-gap">KNOWN GAP</span> | A client-zone HTTPS proxy is configured; the gateway listener itself remains loopback-only; a page responded from the control host | Actual client-zone traversal and an authenticated browser pairing were **not** demonstrated |
| **SDN segmentation** | <span class="pill pill-configured">CONFIGURED</span> <span class="pill pill-gap">KNOWN GAP</span> | Isolated proof-of-concept networks and ordered firewall policy exist as code | **Enforcement is not established.** A later traffic probe passed when policy said it should be blocked |
| **SSH recovery** | <span class="pill pill-configured">CONFIGURED</span> <span class="pill pill-gap">KNOWN GAP</span> | A single-account password exception restored operator access to the control host | Operator key installation, and removal of that exception, remain pending in the records |
| **Time** | <span class="pill pill-verified">VERIFIED</span> <span class="pill pill-gap">KNOWN GAP</span> | One internal time authority serves the whole lab, with a local fallback so the lab drifts together rather than apart | The edge host and the gateway keep their own clock sources |
| **Naming and TLS** | <span class="pill pill-designed">DESIGNED</span> <span class="pill pill-planned">PLANNED</span> | An internal naming scheme and a split-horizon design are agreed and recorded | Certificate issuance and service-by-name cutover are not done |
| **Documentation** | <span class="pill pill-verified">VERIFIED</span> <span class="pill pill-gap">KNOWN GAP</span> | Naming registry, admin-interface inventory, version inventory, master recovery guide and a field-notes page exist | Package-level versions and the edge/gateway firmware are not yet captured |
| **This website** | <span class="pill pill-verified">VERIFIED</span> | Built from the handbook repository, sanitised by an automated pre-publish gate, deployed to the edge, and read back over HTTPS | Automated redeployment from the repository is documented but not yet running unattended - see [Build it](/build/) |

## Segmentation: configuration is not enforcement

The initial phase verified bridges, rule ordering and explicit rule enablement. A later investigation found that the active firewall ruleset lacked the intended guest and virtual-network rules, and **a traffic probe passed when policy said it should be blocked**. Those results supersede any earlier implication that microsegmentation protects workloads.

A host-side firewall alternative was proposed, not established as deployed. The rule is now explicit: **do not migrate real workloads on the assumption of isolation** until both allowed and denied traffic tests pass, including tests between workloads on the same segment.

## Publication recovery

A previous public-history incident showed that replacing a branch is not proof that an old object is unavailable. The recovery retained the old history privately for investigation and published only reviewed documentation.

That incident is why this site is generated from a repository with an automated sanitisation gate that runs **before** anything is uploaded, and why the gate scans the generated output rather than trusting the source.

## What changed most recently

- **Alerting exists now.** A dedicated guest runs a push-alert service and an availability monitor. Previously the lab could fail silently and tell no one - the single largest gap in the recorded status.
- **Time is centralised.** Hosts had each picked their own time source and at least one had no sync at all; there is now one internal authority with a local fallback.
- **One private working repository.** The operating records and the management records were consolidated into a single repository, history preserved rather than squashed.
- **Documentation expanded.** Naming registry, admin-interface inventory, version inventory, a master recovery guide, a costing page, and field notes recording the mistakes worth not repeating.

The theme of that day was **verification**: several items that reported success had not actually worked, and several that looked like failures were fine. The [Lessons](/lessons/) page records the specifics.

## Refreshed 2026-10-02

| Area | State | What is recorded | What remains unproven |
|---|---|---|---|
| **Mail (own server)** | <span class="pill pill-verified">VERIFIED</span> | The domain's mail was cut over to the lab's own server: the old provider's records removed, our MX/SPF/DMARC published, port 25 opened, and a strict sender filter installed. Proved from an outside host - an allowed sender accepted (250), a stranger refused (554) - with local delivery verified into a real mailbox. | Outbound DKIM signing is not generated yet and reverse-DNS is deferred, so mail the lab *sends* is likelier to be flagged. |
| **Comments page** | <span class="pill pill-verified">VERIFIED</span> | A small API accepts comments (honeypot, rate limit, size cap, no cookies) and the page lists approved ones; submissions are held for moderation. | No automated spam scoring - moderation is manual. |
| **Uptime tally** | <span class="pill pill-verified">VERIFIED</span> | A probe records whether the public site answers every 5 minutes; the tally is served live on the [nines page](/uptime/). | The probe measures the public site, not the home lab behind it. |
| **Content attribution** | <span class="pill pill-verified">VERIFIED</span> | Every page carries a generator meta tag and a visible model credit; every generated image credits its model visibly *and* in file metadata. | - |
| **Public site refresh** | <span class="pill pill-configured">CONFIGURED</span> | A twice-daily refresh is scheduled to reconcile this site with the lab's real state. | It has not yet had its first scheduled run. |

> This page is refreshed at least twice a day. Where it drifts, the drift is a bug - and it goes on the
> [known issues](/backlog/) list.

## Refreshed 2026-10-02

| Area | State | What is recorded | What remains unproven |
|---|---|---|---|
| **Mail (own server)** | <span class="pill pill-verified">VERIFIED</span> | The domain's mail was cut over to the lab's own server: the old provider's records removed, our MX/SPF/DMARC published, port 25 opened, and a strict sender filter installed. Proved from an outside host - an allowed sender accepted (250), a stranger refused (554) - with local delivery verified into a real mailbox. | Outbound DKIM signing is not generated yet and reverse-DNS is deferred, so mail the lab *sends* is likelier to be flagged. |
| **Comments page** | <span class="pill pill-verified">VERIFIED</span> | A small API accepts comments (honeypot, rate limit, size cap, no cookies) and the page lists approved ones; submissions are held for moderation. | No automated spam scoring - moderation is manual. |
| **Uptime tally** | <span class="pill pill-verified">VERIFIED</span> | A probe records whether the public site answers every 5 minutes; the tally is served live on the [nines page](/uptime/). | The probe measures the public site, not the home lab behind it. |
| **Content attribution** | <span class="pill pill-verified">VERIFIED</span> | Every page carries a generator meta tag and a visible model credit; every generated image credits its model visibly *and* in file metadata. | - |
| **Public site refresh** | <span class="pill pill-configured">CONFIGURED</span> | A twice-daily refresh is scheduled to reconcile this site with the lab's real state. | It has not yet had its first scheduled run. |

> This page is refreshed at least twice a day. Where it drifts, the drift is a bug - and it goes on the
> [known issues](/backlog/) list.
