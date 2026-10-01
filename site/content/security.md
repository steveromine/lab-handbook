---
title: 'Security design'
description: 'The actual design: trust boundaries, the edge chain, one authentication layer per service, exposure discipline, and the internal-trust assumption stated instead of hidden.'
hero_title: 'The security design, stated honestly'
hero_lede: 'Not "military grade". A small number of real controls, a clear trust boundary, and one assumption about the internal network that is written down rather than relied upon silently.'
---

## The principle

**Internet-facing services use the edge.** A public service exists only because it was deliberately published through the edge, with authentication, and with the ability to unpublish it in one step.

## Trust boundaries

| Boundary | Control |
|---|---|
| Internet to provider | The DNS and proxy provider absorbs floods and hides the origin |
| Provider to edge host | The host firewall allows HTTP and HTTPS **only** from the provider's ranges |
| Edge host to lab | A private overlay; lab services have **no public listeners** |
| Lab to secrets | Scoped injection for a named host; never a wildcard |
| Client zone to server zone | Explicit destination allowances; **not** a blanket isolation claim |

Every boundary is crossed in exactly one direction and for a stated reason. That is the whole design; there is no additional layer of cleverness.

## The edge chain

1. A request arrives at the DNS and proxy provider, which hides the origin and absorbs floods.
2. The request reaches the edge host, which applies security headers and writes an access log.
3. The edge authenticates **when the application has no login of its own**.
4. The edge forwards over the private overlay to the service's overlay address.
5. The service answers; the response travels back the same way.

The edge's access logs are the only record of who tried to reach a published service, which is why they are shipped to the lab's collector rather than left on the box.

## One authentication layer, and why

**Exactly one authentication layer per published service.** Two is worse than one: it doubles the failure modes, and the second prompt is usually the one that breaks.

| The application... | Then... |
|---|---|
| Parses the <code>Authorization</code> header itself | Let the app own its login; publish the UI plainly and gate any raw API separately |
| Is a bare API with no login | Put exactly one auth layer at the edge |

This is not stylistic. HTTP Basic credentials and an application's own bearer token occupy the **same request header**. If the edge injects a Basic header into a request to an app that reads that header, the app tries to interpret the edge's credentials as its own token, rejects them, and its front-end signs the user out - *while the login itself appears to succeed*. The symptom reads as a wrong password, which is why it consumes so much time. It is [Lesson 2](/lessons/).

**The trap in the fix:** stripping the header at the edge does not work either - that same header carries the application's *own* token, so removing it breaks the app instead. The fix is architectural, not a header tweak.

## Exposure discipline

- Public HTTP and HTTPS on the edge are reachable **only through the provider**; from anywhere else they read as closed. That is intended, and it is why an outside port scan of the edge looks like a down host.
- Lab services are reachable from the internet **only** through the private overlay.
- Every published hostname is individually revocable in three steps: remove the proxy block, remove the DNS record, remove the overlay peer. Removing any one breaks the path; none of the three is a silent dependency on the others.
- The agent platform's own control plane stays **loopback-only** on its host. An HTTPS reverse proxy on the control host provides the approved client-zone path, and only that local proxy is trusted to forward client identity - it overwrites forwarded headers rather than trusting them.

## Host hardening

| Control | Applies to |
|---|---|
| SSH hardening, key-only | Most hosts, with a **recorded temporary exception** for one recovery account - so do not describe the estate as uniformly key-only |
| Connection rate limiting on SSH | The edge host. A burst of new connections is refused for a while, which looks like the host being down - a known false alarm |
| Host firewall allowlisting the provider | The edge host |
| Private overlay instead of open ports | All lab services |
| Secret-free repositories (private where they hold internal detail) | Everything |

## Secrets handling

1. The operator supplies a credential.
2. It is stored in a **managed secret store**, not in a file inside a repository.
3. It is injected into the environment for **specific destinations only**; a request to any other host receives nothing.
4. Agents **use** credentials without reading them into their reasoning whenever the tooling allows.

Being secret-free is the first layer of defence; repository privacy is only the second. Nothing that grants access is documented - not the value, and not the location.

## The honest caveat: trust inside the server zone

The edge is hardened. The server zone is where the assumptions live.

A security review found that **most services in the server zone listen on all interfaces and rely on the network boundary rather than on authentication**. That is a defensible posture for a lab - but it should be stated rather than assumed, because it means a single compromised guest currently has a lot of reach: it could call the model APIs, query the log index, and reach management interfaces.

The two least defensible exposures have been fixed: an unauthenticated document parser and the full log index are no longer reachable from the network. The remaining items are mostly **policy choices** about how much the internal network should be trusted, and they are tracked as findings rather than silently accepted.

One existing exposure is recorded rather than recommended: the raw local-model interface has an approved client-zone allowance and was recorded as unauthenticated. It is distinct from the richer chat front-end, which owns its login. Publishing an unauthenticated model API is not a recommendation; it is a documented state.

> **If you build this pattern yourself:** decide explicitly whether the internal network is trusted. If it is not, every service needs either its own authentication or a source restriction at the firewall. The day you discover this by compromise is too late to make it a choice.

## What the lab would not do

- Put two authentication layers on one path.
- Expose a lab service directly to the internet.
- Store a credential in Git "temporarily".
- Let an agent decide to widen exposure.
- Treat a validated configuration as a working service.
- Describe the estate as more secure than the review found it to be.
