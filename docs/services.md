# Services

_Detail behind the [README](../README.md). Roles only; no addresses._

Every service in the lab, what it actually is, how it is supervised, and what breaks when it does.

---

## Media

### plex · jellyfin — media front-ends (containers)

Two independent front-ends over one library. Running both is intentional: they have different client
support, different transcoding behaviour, and running both keeps the library from being hostage to one
vendor's decisions.

| Aspect | Detail |
|---|---|
| Deployment | Containerised, one container per guest |
| Storage | Read-only mount of the media export |
| GPU | Both use hardware transcoding through the shared card |
| Exposure | Published through the edge, authenticated |

**Transcoding is the interesting part.** The CPU cannot transcode modern video in real time, so both
front-ends depend on the GPU's dedicated encoder. That makes the GPU a three-way contention point
(inference, image generation, transcoding), which is why the LLM is pinned resident and the image
model streams.

**What breaks:** if the GPU is unavailable, playback falls back to CPU and stalls. If the media export
is unavailable, libraries go empty — which looks like a data-loss incident but is almost always a
mount problem.

### nfs-media — the library (VM)

A dedicated guest holding the media and exporting it read-only. Separating storage from the
applications is what makes "the applications cannot damage the library" true rather than aspirational.

### media-automation — the acquisition stack (VM)

A collection of cooperating tools that turn a *request* into an organised file: a request front-end, a
metadata/indexer service, and a download client. It is a VM rather than a container because the stack
is several processes with their own dependencies, and because its blast radius is worth containing.

**What breaks:** indexers go stale or get rate-limited, and the symptom is "nothing downloads" rather
than an error.

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

### gods-eye-view — visualisation (container)

A self-hosted geospatial/visualisation application, published through the edge.

---

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
