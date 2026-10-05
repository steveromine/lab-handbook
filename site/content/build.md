---
title: 'Build your own'
description: 'Three tracks - a Proxmox host, a VPS edge, an agent VM - plus the three rules that carry the whole thing and what done actually looks like.'
hero_title: 'Build your own'
hero_lede: 'How to get here from nothing: a Proxmox host, a cheap VPS at the edge, and an agent VM whose agent is conceptually you - with agents under it.'
---

> **Use all of this at your own risk.** These are unvetted recipes from a live lab, not a
> supported build. They can brick a bootloader, strand your own remote access, or quietly erase a
> disk. Never point any of it at a machine, a file, or an account you would not be willing to
> destroy. Keep a known-good way back, test the rollback before you need it, and assume every
> command will do exactly what it says - because it will.


The depth lives in the handbook, one page per track. This page is the map and the rules.

| Track | Page | What you end up with |
|---|---|---|
| 1 | [The Proxmox host](/handbook/build-proxmox-host/) | One hypervisor with real segmentation, GPU sharing and tested backups |
| 2 | [The VPS edge](/handbook/build-vps-edge/) | A public edge that exposes nothing at home |
| 3 | [The agent VM](/handbook/build-agent-vm/) | An agent with a name, a job, tools, a budget - and colleagues |

Read them in order the first time. The agent VM assumes there is somewhere for the agent to *act*.
Every track page — and the scripts they reference, including the agent VM's bootstrap script — is in
the public repository: [lab-handbook on GitHub](https://github.com/steveromine/lab-handbook).

## Why this shape

The three tracks are not three projects. They are three answers to one question: **how do you get something useful and safe to operate without you?**

- The **hypervisor** gives you somewhere to run things, with isolation you can enforce.
- The **edge** means the lab is never directly exposed, so a mistake is contained.
- The **agent** is what makes it a lab rather than a pile of services: something that builds, verifies, documents and repairs.

## The three rules that carry the whole thing

1. **The machine is disposable; Git and the secret store are not.** If you cannot rebuild a machine from a repository plus two secrets, you have not finished setting it up.
2. **Verify by doing, not by exit code.** Every expensive failure in this handbook returned success. Read the artefact the system produced, not the summary.
3. **Prefer the reversible change.** A mirrored disk, a dead-man switch, a snapshot before the edit. The clever fix is worth less than the boring escape hatch.

## What this assumes

- You are comfortable on a Linux command line.
- You can reinstall a machine without panicking.
- You accept that the first version will be wrong - the tracks are written to make being wrong survivable.

## The questionnaire that matters most

The install is mechanical; the design is not. Before installing anything, answer these on paper:

1. **What is the single job you want done?** One sentence. If you cannot write it, you are not ready to install - you are ready to think.
2. **How much access should the agent have?** Sandboxed, host exec without sudo, or full lab mode. Choose the least that does the job; you can widen later, and you cannot un-see a bad command.
3. **Loopback only, or reachable?** Default to loopback. Remote access is a separate decision with a separate threat model.
4. **Where do credentials live?** A secret store with an egress allow-list, never a config file and never Git.
5. **What are the roles, and who may delegate to whom?** This is a real security boundary, not a formality.
6. **What runs on a schedule, and how do you find out it broke?** Anything that has to work while you sleep needs a deterministic script, not a model call - and the monitor must watch for its own absence.
7. **What is the escape hatch?** How do you stop it, and how do you rebuild it from Git alone?

## What done looks like

- The agent has a **name and a job**, not just a socket.
- **You** talk to a coordinator; the coordinator talks to workers.
- Credentials are in a store, **never** in the repository.
- The gateway is **loopback-only** unless you deliberately changed that.
- Something checks the checkers, and the absence of a heartbeat is an alarm.
- You can rebuild the whole thing from Git plus two secrets.

> If any line above is false, the install is not done - regardless of what the script printed.

## How this website is built and deployed

The site you are reading is generated from the public handbook repository by a small, dependency-free script and deployed to the edge host. There is no CMS, no database and no third-party JavaScript.

| Step | What happens |
|---|---|
| 1 | The repository holds the handbook markdown plus a `site/` directory: a build script, a curated story layer, and static assets. |
| 2 | The build renders every page to static HTML, writes a search index, a sitemap and a set of generated assets, and then runs the sanitisation gate. |
| 3 | The gate scans the **generated output** for IP addresses, private hostnames, non-public subdomains, key material and token shapes. If anything trips, the build fails and nothing is uploaded. |
| 4 | The files are copied to the edge host over SSH, into a directory owned by a dedicated, unprivileged deploy account. |
| 5 | The edge's reverse proxy serves that directory for this hostname, obtaining and renewing its own TLS certificate. |
| 6 | Verification is external: the live page is fetched over HTTPS and its **content** is checked - the title, a deep page, the redirect from plain HTTP - not just the status code. |

The rules are the same ones the rest of the lab follows: the build is reproducible from the repository, the gate runs before publication rather than after, and "a 200" is not treated as proof that the right page was served.
