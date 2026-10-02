> **Use all of this at your own risk.** These are unvetted recipes from a live lab, not a
> supported build. They can brick a bootloader, strand your own remote access, or quietly erase a
> disk. Never point any of it at a machine, a file, or an account you would not be willing to
> destroy. Keep a known-good way back, test the rollback before you need it, and assume every
> command will do exactly what it says - because it will.

# Build Your Own: the agent VM

This is the centrepiece of the DIY track: how to go from a blank Ubuntu VM to **an agent that is
conceptually *you*, with agents under it**. It starts from the bootstrap script and generalises it —
the original script was written for one harness (Codex); this one works across all of them.

- Track 1 — [the Proxmox host](build-proxmox-host.md)
- Track 2 — [the VPS edge](build-vps-edge.md)
- **Track 3 — the agent VM (this page)**

---

## 0. The idea

Most "install an AI agent" guides stop at *it replies to a message*. That is not the interesting part.
The interesting part is the moment the agent stops being a chatbot and becomes **an operator with a
name, a job, a workspace, tools, a budget, and colleagues** — the point where you are conceptually
modelling yourself and delegating.

That is what the questionnaire at the end of this page is for. The install is mechanical; the
questionnaire is the design.

## 1. What the VM needs

| Resource | Minimum | Why |
|---|---|---|
| vCPU | 2 | Gateway + Node runtime + git operations |
| RAM | 4 GB | Under this, the runtime and harness OOM |
| Disk | 16 GB | Node runtime + agent state + logs |
| OS | Ubuntu Server LTS | What the script targets |

The VM is deliberately boring. All the interesting state lives in **Git plus a secret store**, so the
machine is disposable.

> This is a design walkthrough, not a self-contained installer release. The referenced bootstrap
> script is not distributed in this handbook; verify its supported flags and harnesses in the
> implementation you actually use. The example below is illustrative, not verified for every harness.

## 2. What the bootstrap script does

The script (`bootstrap-openclaw-agent-vm.sh`) is one-shot and idempotent-ish. Before it exits 0 it has:

1. Created a **dedicated Unix account** for the agent — the agent is not root.
2. Installed OpenClaw **rootless** under `/opt`, with its own Node runtime.
3. Created a **workspace + config repository** in Git, with secrets excluded by construction.
4. Bound the Gateway to **loopback only** with token auth, run as a `systemd --user` service.
5. Installed **provider credentials** and pinned them in the auth order.
6. Granted **host exec + passwordless sudo** (only if you asked for "lab mode").
7. Turned on **auditd**, trace logging and logrotate — so there is a record of what the agent did.
8. Installed a **periodic Git checkpoint timer**.
9. **Proved a real end-to-end agent turn succeeded** — the script does not exit 0 on "installed but
   broken".

It refuses to run without a provider credential. That is deliberate: finishing with an agent that 401s
on its first message is worse than not finishing.

> **The single most important behaviour:** the script verifies by *doing*, not by checking exit codes.
> Everything in this handbook that says "the API said success and the system disagreed" is the reason.

## 3. Supporting all harnesses

The original script assumed one provider. A harness is **the runtime that actually drives the model** —
not the model itself. OpenClaw fronts several, and they have different auth stories:

| Harness | Auth | Notes |
|---|---|---|
| **Codex app-server** | ChatGPT subscription (device-code sign-in) or OpenAI API key | The default path; subscription auth avoids per-token billing |
| **Claude Code / Claude CLI** | Claude subscription or Anthropic API key | CLI backends drive the official CLI |
| **Gemini CLI** | Google account or API key | |
| **OpenCode** | Provider keys | |
| **Qwen** | Provider key | |
| **ACP** | Varies by underlying agent | One protocol in front of many harnesses |
| **API providers** | API key | OpenAI, Anthropic, Google, DeepSeek, … |
| **Local** | none | Ollama or llama.cpp — no credential, no egress |

**Design rule:** pick the *harness* first, then the *model*. Mixing them freely is how you end up with
a config that looks right and authenticates nowhere.

## 4. The questionnaire

This is the part that matters. Each question maps to a config decision; answer them and the script
writes the setup. Do this **before** you install, on paper.

### Round 1 — you

1. **What name and email should the agent commit as?** It writes Git history; make that attributable.
2. **Which harness do you already pay for?** Subscription beats API key on cost; API key beats
   subscription on automation. Answer honestly — this is the biggest cost lever.
3. **What is the single job you want done?** One sentence. If you cannot write it, you are not ready to
   install; you are ready to think.

### Round 2 — the agent's body

4. **How much access should it have?**
   - *Sandboxed* — cannot touch the host. Safe, and can do surprisingly little.
   - *Host exec, no sudo* — can run commands as its own user.
   - *Lab mode: host exec + passwordless sudo* — it can rebuild the machine it lives on.
   Choose the **least** that does the job. You can widen later; you cannot un-see a bad command.
5. **Loopback only, or reachable?** Default to loopback. Remote access is a separate decision with a
   separate threat model — do it deliberately, not as an install option.
6. **Where do credentials live?** A secret store with an egress allow-list, never a config file and
   never Git.

### Round 3 — you and your agents

This is the part people skip, and it is the whole point.

7. **What are the roles?** A working split:
   - **main / coordinator** — owns decomposition, verification, and talking to you. Runs on the
     strongest model. It is *your* representative.
   - **implementation / review** — normal-complexity work, stronger than a budget model.
   - **budget** — high-volume, low-risk, reversible: discovery, summarising, classification.
   Map each role to a harness+model, not the other way round.
8. **Who may delegate to whom?** This is a real security boundary, not a formality. In this lab only
   the **coordinator** may spawn the billed agents; the budget agent may only spawn itself. Decide it
   *explicitly* — the default is usually wrong in one direction or the other.
9. **What is each agent's write scope?** Shared workspace, shared repo, but a stated scope. Agents
   that can all write everywhere cannot review each other.
10. **What happens when an agent is wrong?** Review of agent output is a role, not an afterthought.
    Assign it.

### Round 4 — what runs without you

11. **What should happen on a schedule?** Health checks, backups, patch windows. Anything that has to
    work while you sleep needs a **deterministic** script, not a model call.
12. **How do you find out it broke?** The monitor must watch for *its own absence* — a heartbeat whose
    missing line is the alarm. This is the check everyone forgets.
13. **What is the escape hatch?** How do you stop it, and how do you rebuild it from Git alone?

## 5. Then, and only then, install

```bash
# 1. Copy the script to the VM and make it executable.
chmod +x bootstrap-openclaw-agent-vm.sh

# 2. Preview the plan without changing anything.
./bootstrap-openclaw-agent-vm.sh -test

# 3. Run it, choosing your harness and auth path.
sudo ./bootstrap-openclaw-agent-vm.sh \
     --git-name "You" --git-email "<git-author-email>" \
     --harness codex --auth subscription

# 4. The script exits 0 only after a real agent turn has succeeded.
```

Every harness is selected with `--harness`; every credential path with `--auth`. Refusing a credential
up front is the point — see §2.

## 6. What "done" looks like

- The agent has a **name and a job**, not just a socket.
- **You** talk to a coordinator; the coordinator talks to workers.
- Credentials are in a store, **never** in the repo.
- The Gateway is **loopback-only** unless you deliberately changed that.
- Something checks the checkers, and the absence of a heartbeat is an alarm.
- **You can rebuild the whole thing from Git plus two secrets.**

If any line above is false, the install is not done — regardless of what the script printed.
