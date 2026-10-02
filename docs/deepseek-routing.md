# Agent routing verification — 2026-10-02

The coordinator and six specialist identities select DeepSeek Flash as their primary
generation model, with no automatic cross-provider fallback. A legacy identity name does
not select a different provider. Existing conversation overrides must be checked separately;
the coordinator override has been reset to its configured default. An already running turn
cannot demonstrate the provider used by its successor.

Earlier requests reached the provider but hit a two-minute idle watchdog. The retained
configuration now allows ten minutes for provider requests/idle progress and thirty minutes
for an agent run; child runs retain a fifteen-minute limit. A smaller explicit run budget
still takes precedence. The historical cause of missing stream progress was not isolated.

Current verification: all seven identities completed concurrent fresh-session text probes,
and all seven completed harmless tool round trips. Receipts confirmed the actual DeepSeek
model, exact expected reply, successful tool execution and no fallback. Initial text runs
took roughly five to eleven seconds; initial tool probes took roughly three to ten seconds.
These tests establish current fresh-session health, not unlimited long-session reliability.

A separate large background task exceeded the provider context limit. The supported mid-turn
context-pressure check is enabled to detect growth after tool results before another model
call. It uses normal compaction; no conversation history was deleted. Recovery of the
previously oversized background job has not been demonstrated.

Credentials, role permissions and network exposure are unchanged. Later infrastructure
rollout phases are not deployed by these tests. Public publication remains subject to the
full-history sanitization gate; a local documentation update is not proof of publication.

Names such as `<coordinator>` and `<worker>` are role placeholders, not infrastructure names.

After the context-check change, all seven agents also passed concurrent tool probes in
roughly four to fourteen seconds without fallback. The configuration validated and
hot-reloaded without a service restart.
