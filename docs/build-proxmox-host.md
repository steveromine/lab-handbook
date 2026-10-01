# Build Your Own: the Proxmox host

The hypervisor is the **only machine in the lab with a GPU**, and the only one you must treat as
precious. Everything else is disposable and rebuildable. Design accordingly.

- **Track 1 — the Proxmox host (this page)**
- Track 2 — [the VPS edge](build-vps-edge.md)
- Track 3 — [the agent VM](build-agent-vm.md)

---

## 1. Hardware

One box. A consumer CPU, as much RAM as you will pay for, NVMe, and — if you want the AI
capabilities — a single consumer GPU.

| Component | Guidance | Why |
|---|---|---|
| CPU | 6+ cores | Guests are cheap; contention is not |
| RAM | 32 GB+ | The single best upgrade; VMs are RAM-hungry |
| NVMe | 1 TB+ | **Never single-disk for guest storage** — see §4 |
| GPU | One mid-range card | Shared between LLM, transcoding and image work — see §6 |

**Two disks minimum.** One for the OS, and a mirrored pair (or better) for guest storage. A hypervisor
with one disk is not a lab, it is a countdown.

## 2. Install Proxmox VE

Install Proxmox VE from the ISO. It is Debian underneath, which is the whole reason this stack works —
everything you know about Debian applies.

Post-install, before anything else:

1. **Remove the enterprise repository** and enable the no-subscription repo, or `apt update` fails
   forever and you will not notice for a week.
2. **Update**, then reboot.
3. **Verify the management interface** is reachable and on the address you expect.
4. **Set up a root SSH key** and confirm you can log in with *no password*. Do this before you start
   changing network config — it is the difference between a mistake and a drive to the machine.

## 3. Networking

Start simple, then add isolation.

```
auto vmbr0
iface vmbr0 inet manual
        bridge-ports <nic>
        bridge-stp off
        bridge-fd 0
        bridge-vlan-aware yes
```

Two things that cost real time:

- **VLAN-aware bridge from day one.** Retrofitting it means touching live guest networking.
- **`source /etc/network/interfaces.d/*` must exist** in `/etc/network/interfaces`. If it does not,
  Proxmox SDN writes perfectly valid bridge definitions into that directory and **nothing reads them**.
  The SDN apply reports success, and no interface ever appears. Verify with `ifquery <iface>`.

Then add segmentation. Proxmox has a real SDN stack — zones, VNets, subnets and a per-VNet firewall —
which gives you **microsegmentation without a VMware licence**:

| Zone type | Use |
|---|---|
| `simple` | Isolated local bridges. Zero blast radius — **start here** |
| `vlan` | 802.1q on an existing bridge |
| `vxlan` / `evpn` | Real overlay; needs peers (i.e. usually a second node) |

Order of operations, and it matters:

1. Zone → VNet → subnet → **apply** → confirm the bridge exists.
2. **Then** firewall rules. Verify the *order*: SDN rules are first-match-wins, and
   `pvesh create` **prepends** — creating rules in their declared order silently inverts them, turning
   "allow X, then deny the rest" into "deny everything". Check `pos` after creating.
3. Confirm rules are actually **enabled** and not merely present.

## 4. Storage — the silent killer

If you use thin provisioning (LVM-thin or ZFS), understand this before you trust it:

> **A thin pool has *data* space and *metadata* space. When metadata runs out, the pool goes
> read-only.** Guests do not fail cleanly; they fail with confusing errors, and writes stop.

Watch both numbers, not just free space. This is the archetypal silent failure: nothing alarms, and
the capability is simply gone.

Other rules:

- **Mirror your guest storage.** Always.
- **Back up the irreplaceable guests**, and prove a restore. A backup you have never restored is a
  hope, not a backup. Restore-test to a scratch VMID before you trust the archive.
- Keep the OS on its own disk so you can reinstall the hypervisor without touching guest data.

## 5. Guests

The choice is about isolation, not performance:

| | LXC container | VM |
|---|---|---|
| Overhead | Very low | Low |
| Isolation | Shared kernel | Real boundary |
| GPU passthrough | Possible, fiddly | Clean |
| Best for | Services, apps, media | Anything untrusted, or needing a GPU |

Use containers for services and VMs for anything you do not fully trust. **Retire guests you no longer
use** — dead guests are standing attack surface and stale config that lies to you.

## 6. GPU passthrough

One consumer GPU can serve a local LLM, hardware transcoding, and image generation at once — which is
genuinely a few years ahead of what this cost before. Two lessons:

- **VRAM is the constraint, not compute.** Three workloads contending for 8 GB will hit OOM under load,
  and the failure looks like "the model is broken".
- **Monitor VRAM as a first-class metric.** It is exactly the kind of pressure that builds silently.

## 7. Backups and the monitor

Two scheduled things, both deterministic (no model calls — a scheduler that needs an LLM to decide
whether to run is a liability):

1. **Backups** — a job covering *every* VMID that exists, not the list you happened to write once.
   Reconcile the job against reality periodically.
2. **A health monitor** — the checks that catch *silent* failure:
   - root filesystem full
   - thin pool **data and metadata**
   - newest backup archive age
   - log index reachable **and growing**
   - GPU VRAM
   - sidecars actually functioning
   - published endpoints responding
   - **a heartbeat whose absence is the alarm** — the monitor catching its own death

## 8. What "done" looks like

- You can reach the host with a key, with no password, from a known-good path.
- Guest storage is mirrored; the OS is on its own disk.
- A restore has been **performed**, not just configured.
- The monitor runs hourly and its absence would be noticed.
- You know which single guest, if lost, would actually hurt — and it is backed up.

## Lab result versus tutorial intent

The lab's later traffic probes did **not** prove the configured SDN policy was enforced.
See [the current enforcement finding](current-status.md#sdn-configuration-is-not-enforcement).
Do not use rule presence or a healthy firewall daemon as proof of isolation.
