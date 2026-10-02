> **Use all of this at your own risk.** These are unvetted recipes from a live lab, not a
> supported build. They can brick a bootloader, strand your own remote access, or quietly erase a
> disk. Never point any of it at a machine, a file, or an account you would not be willing to
> destroy. Keep a known-good way back, test the rollback before you need it, and assume every
> command will do exactly what it says - because it will.

# Build Your Own: the VPS edge

The edge VPS is a small, cheap, **expendable** machine in a datacentre that faces the internet, so your
lab at home never has to.

- Track 1 — [the Proxmox host](build-proxmox-host.md)
- **Track 2 — the VPS edge (this page)**
- Track 3 — [the agent VM](build-agent-vm.md)

---

## 1. Why an edge at all

Home connections are usually behind CGNAT, have no static address, and are the wrong place to terminate
TLS. An edge VPS inverts the model:

- **Nothing at home is published.** The lab makes only *outbound* connections.
- **The public attack surface is one small machine** you can rebuild in ten minutes.
- **TLS and DNS live where they belong** — at the edge.

The size of the VPS barely matters; 1 vCPU / 1–2 GB is plenty for a reverse proxy and a tunnel.

## 2. Base hardening

Do these before anything is published:

1. **SSH keys only.** Install your public key, confirm login works, *then* disable password auth —
   including root. Never disable passwords before you have proven key login.
2. **Watch for the drop-in trap.** A cloud image can ship a drop-in under `/etc/ssh/sshd_config.d/`
   that silently re-enables password auth and overrides your main config. Verify with
   `sshd -T | grep passwordauthentication` — **read the effective config, not the file you edited.**
3. **A host firewall** allowing only what you publish.
4. **Unattended upgrades.**
5. **Rate-limit SSH yourself.** Repeated failed logins will get you throttled by the provider — and
   from inside, it looks like *your key stopped working*. Know that before you debug it at 2am.

## 3. DNS at Cloudflare

Keep DNS in one place with an API you can script. For each service: a record pointing at the edge, and
proxying on. Then TLS can be terminated at the edge.

**One thing Cloudflare will not do:** it cannot relay **outbound SMTP**. If you need the lab to send
mail, that is an authenticated relay (or a transactional provider) — see the agent VM page.

## 4. TLS and the reverse proxy

Use a single static binary that obtains and renews certificates itself — **Caddy** is the obvious
choice, and this one decision removes an entire category of expiry outages that used to eat a day a
year.

```
# One hostname, one backend, automatic TLS.
<service-hostname> {
    reverse_proxy <overlay-address>:<port>
}
```

Note the backend address: it is an address **on the overlay**, not a LAN address. The lab is not
reachable any other way.

## 5. The overlay — WireGuard back to the lab

This is the keystone. A WireGuard tunnel joins the edge to the lab so that services are reachable
across it without anything at home being exposed.

- The **edge** is the reachable endpoint; the **lab** dials out and keeps the tunnel alive.
- Give each participant a stable address in a **private overlay range**, and use those addresses in
  the proxy config — never a LAN address.
- **Keepalive** on the lab side so the tunnel survives NAT.
- Restrict `allowed ips` per peer to exactly what that peer needs.

A healthy tunnel looks like: recent handshakes (seconds to a minute), and **byte counters that move**.
A tunnel with a stale handshake and static counters is down even though the interface exists.

## 6. Publishing a service

The order that avoids surprise:

1. Service running in the lab and reachable **on the overlay address**.
2. Tunnel up, verified by handshake.
3. Caddy block with `reverse_proxy` to the overlay address.
4. DNS record.
5. **Then** decide whether it needs an outer gate — and choose deliberately:
   - The app's own accounts (best, if it has them)
   - An identity-aware proxy (Cloudflare Access and friends)
   - **Not** HTTP Basic over a modern app unless you mean it — it interacts badly with apps that
     speak their own auth, and it trains people to share one password.

## 7. Logs

Ship the edge's logs to the lab's collector. The edge is the one machine that sees the whole internet,
so it is the one whose logs you will actually want — and the one you will lose if it is rebuilt.

## 8. What "done" looks like

- Password auth is off **and you verified it in the effective config**.
- DNS, TLS and the tunnel are all reproducible from code, not from memory.
- Nothing at home is published; the only open ports are the ones you chose.
- You can rebuild the edge from scratch and the lab reconnects on its own.
