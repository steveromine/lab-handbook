# Services

_Detail behind the [README](../README.md). Roles only; no addresses._

Every service in the lab, what it actually is, how it is supervised, and what breaks when it does.

---

## AI and agents

Covered in depth in [ai-platform.md](ai-platform.md) and [agents.md](agents.md). In brief:

| Service | Role |
|---|---|
| **ops-llm** | Local GPU LLM behind an OpenAI-compatible API |
| **open-webui** | Chat front-end with retrieval, uploads, image generation, search |
| **image-gen** | Text-to-image API, Automatic1111-compatible |
| **ops-agent** | Operations agent on the local model, with escalation |

Supporting sidecars run alongside the chat front-end on the same guest:

| Sidecar | Role |
|---|---|
| **parser** | Extracts text from documents **and archives** |
| **search** | Self-hosted metasearch for the model's web lookups |

---

## Infrastructure

### logging — the collector (container)

Receives syslog from the hypervisor, the edge, the firewall and the guests, and writes it into a
single searchable index with a retention policy.

**Why it matters:** the edge's logs are the only record of who tried to reach published services, and
the firewall's logs are how zone policy is proved rather than assumed.

**What breaks:** if the index fills its disk, ingestion stops silently and the *loss of observability*
is the real outage.

### vault — password vault (container)

Self-hosted secret storage for human credentials.

**What breaks:** it is only as good as its backups. A vault without a tested restore is a liability
that feels like an asset.

### pihole — filtering DNS (container)

Network-wide DNS filtering.

**What breaks:** if it dies, everything that resolves through it fails at once and the failure looks
like a total network outage. It is a deliberate single point of failure and is treated as such.

## The edge

### edge proxy (public VPS)

Terminates TLS, applies security headers, enforces authentication, logs access, and forwards to lab
services **only over the private overlay**. It runs a host firewall that allows HTTP/HTTPS from the
proxy provider only.

**What breaks:** the overlay. Without it, every published service disappears simultaneously while the
lab itself is perfectly healthy — which is why the overlay link is monitored separately from the apps.

---

## Cross-cutting properties

| Property | How it is achieved |
|---|---|
| Static addressing | Every guest holds a fixed address recorded in the inventory |
| Log centralisation | Everything ships syslog to the collector |
| Config in Git | Host configuration captured on a schedule |
| Rebuildability | One runbook per service, describing rebuild **and** rollback |
| No public listeners | Only the edge is reachable; everything else is tunnelled |
| One auth layer | Applications own their login, or the edge provides one — never both |
