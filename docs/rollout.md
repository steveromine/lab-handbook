# Phased rollout

Current direction: the configured coordinator and six worker identities use one economical
DeepSeek API route, without automatic cross-provider fallback. Agent roles and verification
responsibilities remain distinct. Existing sessions require separate routing checks.
Configuration alone is not proof of completed work; runtime tests remain a release gate.

| Phase | Work | Required proof |
|---|---|---|
| 0 | Single-provider agent routing | Valid configuration and actual completed agent runs |
| 1 | Recovery and inventory | Isolated database restore, timestamped package/image/caller inventory |
| 2 | Resolver, names and TLS | Segment-level DNS tests, certificate renewal and one-service canary |
| 3 | Access controls and patching | Both allowed and denied paths, console recovery and rollback |
| 4 | Logs, alerts and review jobs | Synthetic events delivered; timezone-aware queue; read-only reviews |
| 5 | Image provenance and off-host recovery | Digest/protocol checks and encrypted remote restore proof |
| 6 | Optional identity, registry and GPU work | Measured need and explicit resource decisions |

Each service changes independently with rollback prepared first. Resolver, firewall, SSH and
hypervisor changes do not share one maintenance window. Protected infrastructure changes remain
supervised. A maintenance queue is not automatic reboot authorization.

Pending choices affect only their own lanes: backup destination/budget, notification recipient,
out-of-band access scope, supervised maintenance window and optional hardware spending.
Public history cleanup is separate; a failing publication gate is never waived.

This is an execution plan, not a claim that later phases are deployed. Names such as
`<resolver>` and `<edge>` are role placeholders, not real infrastructure identifiers.
