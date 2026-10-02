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
| **Monitoring** | <span class="pill pill-verified">VERIFIED</span> <span class="pill pill-gap">KNOWN GAP</span> | An hourly read-only monitor runs **41 deterministic checks** - root filesystems, the thin pool, backup age and per-guest coverage, a fresh restore proof, log ingestion and timestamp skew, GPU pressure, container-image digests, disk health, the guest estate's power and filesystem state, memory headroom, whether a host is killing processes for memory (OOM), listener inventory, SSH authentication events, the agent control plane serving, the model-helper pool, the out-of-band management path, the public edge's own origin exposure and host defence, the lab's clock synchronisation, and the published site's canonical origin - and emails the operator when a check fails. The latest run (23:06 UTC) passed 39 of 41. | The one current warning is that alert email to a single operator mailbox is being rejected by that external provider's own policy; the lab's send path is otherwise green |
| **Local model** | <span class="pill pill-verified">VERIFIED</span> <span class="pill pill-gap">KNOWN GAP</span> | GPU-backed text inference is deployed, not a future migration; the raw interface and the richer chat front-end are separate services | The raw interface is unauthenticated on allowed internal paths, and its source restrictions need deliberate review |
| **Agent UI** | <span class="pill pill-configured">CONFIGURED</span> <span class="pill pill-verified">VERIFIED</span> | A client-zone HTTPS proxy is configured and a page responded from the control host. The gateway listener is **loopback-only** and the lab's own monitor asserts that hourly. | Actual client-zone traversal and an authenticated browser pairing were **not** demonstrated, and remote pairing over the private overlay network is still pending. |
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

## Refreshed 2026-10-02 22:45 UTC

| Area | State | What is recorded | What remains unproven |
|---|---|---|---|
| **Mail (own server)** | <span class="pill pill-verified">VERIFIED</span> <span class="pill pill-gap">KNOWN GAP</span> | The domain's mail runs on the lab's own server: the old provider's records removed, our MX/SPF/DMARC published, port 25 opened, and a strict sender filter installed. Proved from an outside host - an allowed sender accepted (250), a stranger refused (554) - with local delivery verified into a real mailbox. Re-read at refresh: the mail server and web server were active, the mail queue was empty, and outbound mail to one large provider was accepted (250). | **Inbound works; outbound is still earning trust.** DKIM signing is not generated and reverse DNS is deferred, so another large consumer provider still rejects messages the lab sends (554 5.7.1, provider local policy). |
| **Agent control plane** | <span class="pill pill-configured">CONFIGURED</span> <span class="pill pill-verified">VERIFIED</span> | The agent gateway is reached through an HTTPS reverse proxy on the control host, which is the only trusted forwarder of client identity. The listener is **loopback-only**, asserted hourly by the lab's own monitor. | A brief, overlay-scoped widening while an operator-directed remote-pairing change was in progress on 2026-10-02 was caught by the monitor and restored to loopback within the hour; remote pairing is still pending. |
| **Comments page** | <span class="pill pill-verified">VERIFIED</span> | A small API accepts comments (honeypot, rate limit, size cap, no cookies) and the page lists approved ones; submissions are held for moderation. | No automated spam scoring - moderation is manual. |
| **Uptime tally** | <span class="pill pill-verified">VERIFIED</span> | A probe records whether the public site answers every five minutes. Read back at 22:45 UTC: **205 samples, 205 up, 100%** since the probe began at 04:29 UTC today. | The probe measures the public edge, not the home lab behind it. |
| **Content attribution** | <span class="pill pill-verified">VERIFIED</span> | Every page carries a generator meta tag and a visible model credit; every generated image credits its model visibly *and* in file metadata. | - |
| **Accessibility** | <span class="pill pill-verified">VERIFIED</span> | The build now enforces WCAG 2.2 AA - alt text, a single page heading and page language over the generated HTML, plus colour contrast computed from the live style tokens - and fails closed when a page regresses. It found and fixed two real contrast failures. | Contrast is checked against the palette tokens, not every rendered element. |
| **Public site refresh** | <span class="pill pill-configured">CONFIGURED</span> <span class="pill pill-gap">KNOWN GAP</span> | A twice-daily reconciliation of this site against the lab records runs on a schedule and ran again at 20:00 UTC. | The pre-publication check on the repository history passes, so reviewed revisions are published; the reconciliation runs twice a day, so drift between runs is still possible. |
| **Deployment** | <span class="pill pill-configured">CONFIGURED</span> | The site is built from the repository and copied to the edge host over SSH by a reviewed, gate-first step. | The repository's automated deploy job is disabled pending its deploy credentials, so each publish is a manual copy rather than unattended. |

> This page is reconciled against the lab records on a schedule. Where it drifts, the drift is a bug -
> and it goes on the [known issues](/backlog/) list.
