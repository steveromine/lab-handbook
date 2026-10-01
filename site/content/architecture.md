---
title: 'Architecture'
description: 'One hypervisor, a single hardened edge, three network zones and a shared GPU - the shape of the lab, with its deliberate trade-offs named.'
hero_title: 'Architecture'
hero_lede: 'A small estate drawn simply. The interesting choices are not the boxes but the boundaries between them - and the trades that were accepted on purpose.'
---

## The whole thing on one page

<svg class="figure" viewBox="0 0 960 660" role="img" aria-labelledby="archT archD"><title id="archT">Simplified lab architecture</title><desc id="archD">The internet reaches a DNS and proxy provider, then the public edge host which terminates TLS and runs the private overlay hub. The edge forwards over that private overlay into the lab server zone, which holds one hypervisor with the GPU and a set of service guests. An untrusted client zone reaches the lab only through the firewall, on allowlisted destinations.</desc><rect x="380" y="14" width="200" height="38" rx="8" fill="#131a24" stroke="#2b3a4d"/><text x="480" y="38" text-anchor="middle" fill="#cfe3f5" font-size="14">The internet</text><line x1="480" y1="52" x2="480" y2="76" stroke="#4b6076" stroke-width="2"/><polygon points="480,80 474,68 486,68" fill="#4b6076"/><rect x="330" y="80" width="300" height="38" rx="8" fill="#131a24" stroke="#2b3a4d"/><text x="480" y="104" text-anchor="middle" fill="#cfe3f5" font-size="14">DNS + proxy provider (absorbs floods)</text><line x1="480" y1="118" x2="480" y2="142" stroke="#4b6076" stroke-width="2"/><polygon points="480,146 474,134 486,134" fill="#4b6076"/><rect x="60" y="146" width="840" height="104" rx="12" fill="none" stroke="#7dd3fc" stroke-width="1.5"/><text x="78" y="168" fill="#7dd3fc" font-size="14" font-weight="600">Public edge host (VPS) - the only door</text><rect x="80" y="180" width="420" height="52" rx="8" fill="#131a24" stroke="#2b3a4d"/><text x="290" y="202" text-anchor="middle" fill="#cfe3f5" font-size="13">Reverse proxy: TLS, headers, access log</text><text x="290" y="220" text-anchor="middle" fill="#8fa6bd" font-size="12">one auth layer per service - app, or edge</text><rect x="520" y="180" width="360" height="52" rx="8" fill="#131a24" stroke="#2b3a4d"/><text x="700" y="202" text-anchor="middle" fill="#cfe3f5" font-size="13">Private overlay hub</text><text x="700" y="220" text-anchor="middle" fill="#8fa6bd" font-size="12">Lab dials out; nothing at home listens</text><line x1="480" y1="250" x2="480" y2="292" stroke="#7dd3fc" stroke-width="2" stroke-dasharray="6 4"/><polygon points="480,298 474,286 486,286" fill="#7dd3fc"/><text x="600" y="276" fill="#7dd3fc" font-size="12">private overlay (encrypted tunnel)</text><rect x="40" y="300" width="880" height="286" rx="14" fill="none" stroke="#33465e" stroke-dasharray="4 4"/><text x="62" y="324" fill="#9fb6cd" font-size="14" font-weight="600">Lab - server zone (no public listeners)</text><rect x="60" y="336" width="200" height="46" rx="8" fill="#131a24" stroke="#2b3a4d"/><text x="160" y="364" text-anchor="middle" fill="#e6eef7" font-size="13">Hypervisor + GPU</text><rect x="275" y="336" width="200" height="46" rx="8" fill="#131a24" stroke="#2b3a4d"/><text x="375" y="364" text-anchor="middle" fill="#e6eef7" font-size="13">Agent control host</text><rect x="490" y="336" width="200" height="46" rx="8" fill="#131a24" stroke="#2b3a4d"/><text x="590" y="364" text-anchor="middle" fill="#e6eef7" font-size="13">Storage (read-only export)</text><rect x="705" y="336" width="195" height="46" rx="8" fill="#131a24" stroke="#2b3a4d"/><text x="802" y="364" text-anchor="middle" fill="#e6eef7" font-size="13">Media automation</text><rect x="60" y="398" width="150" height="46" rx="8" fill="#131a24" stroke="#2b3a4d"/><text x="135" y="426" text-anchor="middle" fill="#e6eef7" font-size="13">Local LLM</text><rect x="225" y="398" width="170" height="46" rx="8" fill="#131a24" stroke="#2b3a4d"/><text x="310" y="426" text-anchor="middle" fill="#e6eef7" font-size="13">Chat front-end</text><rect x="410" y="398" width="150" height="46" rx="8" fill="#131a24" stroke="#2b3a4d"/><text x="485" y="426" text-anchor="middle" fill="#e6eef7" font-size="13">Image service</text><rect x="575" y="398" width="150" height="46" rx="8" fill="#131a24" stroke="#2b3a4d"/><text x="650" y="420" text-anchor="middle" fill="#e6eef7" font-size="13">Parser + search</text><text x="650" y="436" text-anchor="middle" fill="#8fa6bd" font-size="11">sidecars</text><rect x="740" y="398" width="160" height="46" rx="8" fill="#131a24" stroke="#2b3a4d"/><text x="820" y="426" text-anchor="middle" fill="#e6eef7" font-size="13">Log index</text><rect x="60" y="460" width="150" height="46" rx="8" fill="#131a24" stroke="#2b3a4d"/><text x="135" y="488" text-anchor="middle" fill="#e6eef7" font-size="13">Password vault</text><rect x="225" y="460" width="170" height="46" rx="8" fill="#131a24" stroke="#2b3a4d"/><text x="310" y="488" text-anchor="middle" fill="#e6eef7" font-size="13">Filtering DNS</text><rect x="410" y="460" width="150" height="46" rx="8" fill="#131a24" stroke="#2b3a4d"/><text x="485" y="488" text-anchor="middle" fill="#e6eef7" font-size="13">Visualiser</text><rect x="575" y="460" width="150" height="46" rx="8" fill="#131a24" stroke="#2b3a4d"/><text x="650" y="488" text-anchor="middle" fill="#e6eef7" font-size="13">Ops agent</text><rect x="740" y="460" width="160" height="46" rx="8" fill="#131a24" stroke="#2b3a4d"/><text x="820" y="482" text-anchor="middle" fill="#e6eef7" font-size="13">Media front-ends</text><text x="820" y="498" text-anchor="middle" fill="#8fa6bd" font-size="11">GPU transcode</text><text x="60" y="534" fill="#8fa6bd" font-size="12">Most services here listen broadly and rely on the network boundary. That is an assumption, not a control - see Security.</text><text x="60" y="556" fill="#8fa6bd" font-size="12">All of this runs on one physical host: a deliberate single point of failure.</text><rect x="60" y="580" width="330" height="46" rx="8" fill="#1b1a12" stroke="#8a6d1f"/><text x="225" y="602" text-anchor="middle" fill="#f4d27a" font-size="13">Client zone (treated as untrusted)</text><text x="225" y="618" text-anchor="middle" fill="#b99f57" font-size="11">devices reach named services, not the network</text><line x1="398" y1="603" x2="470" y2="603" stroke="#8a6d1f" stroke-width="2"/><polygon points="474,603 462,597 462,609" fill="#8a6d1f"/><rect x="480" y="580" width="420" height="46" rx="8" fill="#131a24" stroke="#2b3a4d"/><text x="690" y="602" text-anchor="middle" fill="#e6eef7" font-size="13">Firewall + routing</text><text x="690" y="618" text-anchor="middle" fill="#8fa6bd" font-size="11">allowlisted destinations; policy-controlled egress</text></svg>

## The shape of the estate

Everything runs on **one physical hypervisor**. That is a deliberate trade: a single host is simple, cheap and easy to reason about, and the lab's purpose is to get the *patterns* right rather than to demonstrate high availability. The cost is stated rather than hidden - the hypervisor is a single point of failure, and its GPU is a single point of contention.

| Layer | What it is |
|---|---|
| Hypervisor | One Proxmox VE host; the only machine with a GPU |
| Containers | Ten, for single-process services: cheap, fast to clone |
| Virtual machines | Three, for guests that want a real kernel: agent host, storage, media automation |
| Storage | Guest disks on a thin-provisioned pool; media on its own guest, exported read-only |

### Why containers for most things

Most services are Linux containers: cheap, fast to clone, and a natural fit for a single-process service. Virtual machines are reserved for the three guests that want a real kernel of their own - the agent control host, the storage server, and the media automation host.

## Three zones

| Zone | Character |
|---|---|
| **Management** | The firewall and the infrastructure that defines policy |
| **Client** | Treated as hostile. Devices reach named services, not the network |
| **Server** | Every guest. Reached from the client zone only through explicit policy |

Client-to-server access is **allowlisted, not universally denied**. Selected management and AI interfaces are explicitly reachable from the client zone. A compromised client can attempt those allowed services; application authentication and narrow destination rules still matter.

The lab is **segmented, not overlaid**. An overlay network is the usual way to do this, but it needs a second node to tunnel to - and this lab has one. Calling an isolated bridge an overlay would hide the fact that it solves a different problem. So the honest description is: SDN segmentation with ordered firewall policy.

## Storage, and the number that matters

Two distinct storage ideas coexist:

- **Guest disks** live on a thin-provisioned LVM pool. Thin provisioning lets guests be given generous disks without pre-allocating the estate - but it also means the pool's *actual* usage is the number that matters, and it is invisible in the place people usually look.
- **Media** lives on its own guest and is exported to the media front-ends **read-only**, so a misbehaving application cannot damage the library.

> **Capacity lesson.** After the cleanup, the reclaim showed up in the thin pool's data percentage and not in the volume group's free space. A volume group that hosts a thin pool reports *its own* unallocated space, which barely moves when guest volumes are deleted. Watching the wrong number makes a successful reclaim look like a failed one.

A thin pool also has **metadata** space, and when metadata runs out the pool goes read-only - guests fail with confusing errors rather than cleanly. So the monitor watches both numbers, not just free space.

## Guest anatomy

Each guest follows the same shape, and the shape is the point:

1. A static address on the server zone, recorded in an inventory.
2. A service under a supervisor.
3. Logs forwarded to the collector.
4. Configuration captured into Git on a schedule.
5. A runbook describing rebuild **and** rollback.

A guest without a runbook is a guest that cannot be rebuilt - which makes it an undocumented dependency rather than an asset.

## Headroom, honestly

| Resource | Character |
|---|---|
| CPU | Comfortably over-provisioned; the hypervisor schedules it |
| Memory | Generous per guest; the GPU host is the tight one |
| Storage | Thin pool back to roughly one-eighth used after reclamation |
| GPU | **The scarce resource** - see [GPU as a budget](/gpu-budget/) |

## Growth path

- Add a second hypervisor, move the always-on services to it, and leave the GPU host for GPU work.
- Split the local LLM and the image model onto different cards so neither has to yield.
- Keep the media library on dedicated storage rather than a guest disk.

> **The honest caveat.** The lab's later traffic probes did **not** prove the configured segmentation policy was enforced: a flow that policy said should be denied passed. Rule presence and a healthy firewall daemon are not evidence of isolation. That finding is carried in [Status](/status/) rather than smoothed over here.
