# Current status and known gaps

Reconciled on 2026-10-01 from private activity records and service runbooks. This is a
documentation reconciliation, not a fresh live audit of every service.

| Area | Recorded result | Remaining verification or limitation |
|---|---|---|
| Agent UI | Client-zone HTTPS proxy configured; Gateway remains loopback-only; page responded successfully from the control host | Actual client-zone traversal and authenticated browser pairing were not demonstrated |
| Local model | GPU-backed text inference is deployed, not a future migration; raw interface and richer chat front-end are separate | Raw API is unauthenticated on allowed internal paths; source restrictions need deliberate review |
| Backup | Weekly guest coverage corrected; vault restored to an isolated scratch guest and application data verified | Restored login not proved; backups share the hypervisor failure domain |
| Monitoring | Hourly deterministic checks cover capacity, backup age, ingestion growth, GPU pressure and service health | File/syslog reporting only; no push notification destination configured |
| SDN | Isolated proof-of-concept networks and ordered firewall policy exist as code | Later traffic testing found a flow open that should be denied; enforcement is not established |
| SSH recovery | Single-account password exception restored operator access | Operator key installation and removal of the exception remain pending in the records |
| Handbook | Publication recovered using a sanitized starting history | Every later publication must scan the entire reachable history, including metadata |

## SDN: configuration is not enforcement

The initial phase verified bridges, rule ordering and explicit rule enablement. A later
investigation found the active firewall ruleset lacked the intended guest and virtual-network
rules; a traffic probe passed when policy said it should be blocked. These results supersede
any implication that microsegmentation already protects workloads.

A host-side firewall alternative was proposed, not established as deployed. Do not migrate
real workloads on the assumption of isolation until both allowed and denied traffic tests pass,
including tests between workloads on the same segment. Preserve rollback and repeat probes
after each policy or firewall-backend change.

## Publication recovery

A previous public-history incident showed that replacing a branch is not proof that an old
object is unavailable. The recovery found an empty public remote and retained the old local
history privately for investigation. Only reviewed documentation is included in the replacement
publication. Operational addresses, real DNS names, credentials, account details and private
access paths remain outside this handbook.
