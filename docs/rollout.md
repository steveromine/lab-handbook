# Phased rollout

Current direction: the configured coordinator and six worker identities use one economical
DeepSeek API route, without automatic cross-provider fallback. Agent roles and verification
responsibilities remain distinct. Existing sessions require separate routing checks.
Configuration alone is not proof of completed work; runtime tests remain a release gate.

Latest verification (2026-10-02): all seven identities passed fresh text and tool-call
probes on DeepSeek without fallback. See [routing verification](deepseek-routing.md) for
settings, evidence limits and the remaining large-context recovery limitation. This
supersedes the failed fresh-session probe status below, not later deployment gates.

Historical verification: both bounded routing probes timed out without completed output. The provider
accepted streaming requests, but that does not prove inference completion. Deployment is held at
phase zero; no automatic provider fallback was added. Existing-session overrides also remain a
separate migration issue. The root cause is unresolved; further investigation must distinguish
upstream stream progress from local stream handling before another rollout attempt.

| Phase | Work | Required proof |
|---|---|---|
| 0 | Single-provider agent routing | Valid configuration and actual completed agent runs |
| 1 | Recovery and inventory | Isolated database restore, timestamped package/image/caller inventory |
| 2 | Resolver, names and TLS | Segment-level DNS tests, certificate renewal and one-service canary |
| 3 | Access controls and patching | Both allowed and denied paths, console recovery and rollback |
| 4 | Logs, alerts and review jobs | Synthetic events delivered; timezone-aware queue; read-only reviews |
| 5 | Image provenance and local recovery | Digest/protocol checks, local restore proof and management-only alternate access |
| 6 | Optional identity, registry and GPU work | Measured need and explicit resource decisions |

Each service changes independently with rollback prepared first. Resolver, firewall, SSH and
hypervisor changes do not share one maintenance window. Protected infrastructure changes remain
supervised. A maintenance queue is not automatic reboot authorization.

Operator scope decisions: backups remain local; offsite backup work is removed. Local restore
verification remains required, without a claim of site-loss protection. SSH changes are in an
inactive future-state backlog, outside this rollout. Tailscale is limited to management hosts:
no subnet routes, exit-node service or Tailscale SSH.

Notification email will use a send/receive server accepting only the operator's designated
sender, with authenticated sender checks rather than a From-address string alone. No open relay
or email-triggered command execution is intended. Domain/mailbox selection is pending; the
service is not deployed. Public documentation uses role placeholders such as `<operator-mailbox>`
and omits real addresses and domains.

Pending choices affect only their own lanes: mail domain/mailbox, supervised infrastructure
reboot window and optional hardware spending. SSH work is not awaiting scheduling.
Public history cleanup is separate; a failing publication gate is never waived.

This is an execution plan, not a claim that later phases are deployed. Names such as
`<resolver>` and `<edge>` are role placeholders, not real infrastructure identifiers.
