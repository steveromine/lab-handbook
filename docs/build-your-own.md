> **Use all of this at your own risk.** These are unvetted recipes from a live lab, not a
> supported build. They can brick a bootloader, strand your own remote access, or quietly erase a
> disk. Never point any of it at a machine, a file, or an account you would not be willing to
> destroy. Keep a known-good way back, test the rollback before you need it, and assume every
> command will do exactly what it says - because it will.

# Build Your Own

How to build this lab from nothing: **a Proxmox host, a cheap VPS at the edge, and an agent VM whose
agent is conceptually *you* — with agents under it.**

This track is written so that the *reasoning* survives even if the versions do not. Commands age;
decisions do not.

| Track | Page | What you end up with |
|---|---|---|
| 1 | [The Proxmox host](build-proxmox-host.md) | One hypervisor with real segmentation, GPU sharing, tested backups |
| 2 | [The VPS edge](build-vps-edge.md) | A public edge that exposes nothing at home |
| 3 | [The agent VM](build-agent-vm.md) | An agent with a name, a job, tools, a budget — and colleagues |

Read them in order the first time. The agent VM assumes somewhere for the agent to *act*.

---

## Why this shape

The three tracks are not three projects. They are three answers to one question: **how do you get
something useful and safe to operate without you?**

- The **hypervisor** gives you somewhere to run things, with isolation you can enforce.
- The **edge** means the lab is never directly exposed, so a mistake is contained.
- The **agent** is what makes it a *lab* rather than a pile of services: something that builds,
  verifies, documents and repairs.

## The three rules that carry the whole thing

1. **The machine is disposable; Git and the secret store are not.** If you cannot rebuild a machine
   from a repo plus two secrets, you have not finished setting it up.
2. **Verify by doing, not by exit code.** Every expensive failure in this handbook returned
   "success". Read the artefact the system produced, not the summary.
3. **Prefer the reversible change.** Mirrored disk, dead-man switch, snapshot before the edit. The
   clever fix is worth less than the boring escape hatch.

## What this assumes

- You are comfortable on a Linux command line.
- You can reinstall a machine without panicking.
- You accept that the first version will be wrong — the tracks are written to make being wrong
  survivable.

## Where the depth lives

This DIY track is the *how*. The rest of the handbook is the *what*: [architecture](architecture.md),
[agents](agents.md), [operations](operations.md), [lessons](lessons.md), and the
[plain-language tour](eli5.md).
