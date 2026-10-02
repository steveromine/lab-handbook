# The agent platform

_Detail behind the [README](../README.md). How automated work is organised, routed and kept honest._

The lab does not just run a chatbot. It runs an **agent platform**: software that takes a task, does
multi-step work against real infrastructure, verifies it, and records what it did.

---

## Why agents at all

Running a lab is mostly undifferentiated work: patching, checking, capturing configuration, writing
down what changed. That work is:

- **Bounded** — the correct outcome is checkable.
- **Repetitive** — the same shapes recur.
- **Reversible or gated** — most of it can be undone, and the rest can require approval.

Those three properties are exactly what makes a task safe to hand to an agent. Work that is ambiguous,
irreversible, or security-critical is not *forbidden* — it is **routed to a more capable model and
gated on a human decision** rather than handed to the cheapest worker.

---

## The roster

```mermaid
flowchart TB
    COORD[Coordinator]
    HI[High-capability worker]
    CHEAP[Low-cost bulk worker]
    LOCAL[Local offline agent]
    COORD --> HI
    COORD --> CHEAP
    COORD --> LOCAL
    COORD --> HUMAN[Human operator]
```

| Role | Model class | Used for |
|---|---|---|
| **Coordinator** | Frontier | Decomposition, ambiguity, security-sensitive judgement, final verification, talking to the operator |
| **High-capability worker** | Frontier | Real implementation, debugging, review |
| **Low-cost bulk worker** | Cheap and fast | Discovery, summarisation, classification, reversible first passes |
| **Local offline agent** | The lab's own GPU model | Always-available operations work with no external dependency; escalates when stuck |

The **local agent is the interesting one**: it runs on its own guest against the lab's own LLM, so it
keeps working when the internet or a provider does not. It is deliberately given an escalation path,
because a small local model is good at *routine* operations and bad at novel reasoning — and pretending
otherwise is how you get confident nonsense.

---

## Model routing

Routing is by **risk and cost**, not by availability:

```mermaid
flowchart LR
    T[Task] --> Q1{Reversible?}
    Q1 -->|no| HI2[Frontier model + human gate]
    Q1 -->|yes| Q2{Ambiguous or security-relevant?}
    Q2 -->|yes| HI3[Frontier model]
    Q2 -->|no| Q3{High volume?}
    Q3 -->|yes| CH2[Cheap fast model]
    Q3 -->|no| LO2[Local model]
```

Two consequences worth stating plainly:

1. **The expensive model is not the default.** Most work is cheap work, and treating it as cheap is
   what makes the platform affordable to run continuously.
2. **Escalation is a feature.** A worker that recognises it is out of its depth and hands up is worth
   more than a worker that never admits it.

---

## Shared state, not shared memory

```mermaid
flowchart TB
    WS[Single shared workspace] --> R1[Operating contract]
    WS --> R2[Activity log]
    WS --> R3[Decision log]
    WS --> R4[Runbooks and skills]
    WS --> R5[Repositories]
    R5 --> GITREPO2[(Git)]
```

Agents do not rely on conversation history for correctness. Durable state lives in Git:

| Artefact | Purpose |
|---|---|
| **Operating contract** | The rules every agent reads before acting |
| **Activity log** | What changed, when, and how it was verified |
| **Decision log** | Architectural choices with alternatives, consequences, rollback |
| **Runbooks** | Rebuild and rollback instructions per service |
| **Repositories** | Configuration, playbooks and captured host state |

**Why:** conversation context is lossy, private to one session, and invisible to the next agent.
A repository is none of those things.

---

## The task lifecycle

```mermaid
flowchart LR
    A[Read the contract and current state] --> B[Make the change]
    B --> C[Verify with the real artifact]
    C --> D[Log the activity]
    D --> E{Architectural?}
    E -->|yes| F[Record the decision]
    E -->|no| G[Commit and push]
    F --> G
    G --> H{Verified?}
    H -->|no| I[Roll back using written steps]
    H -->|yes| J[Done]
```

The **unusual** step is "verify with the real artifact". It is not enough that a service was
configured. The image must render, the archive must extract, the page must load, the file must contain
the expected text. Several of this lab's most expensive mistakes were configurations that validated
perfectly and did nothing.

---

## Guardrails

### Authority

```mermaid
flowchart TB
    subgraph Operator["Operator"]
        DEC[Decisions, credentials, publication]
    end
    subgraph Auto["Agents"]
        BUILD[Build, verify, document, roll back]
    end
    DEC -->|delegates work| BUILD
    BUILD -->|reports and proposes| DEC
    BUILD -.->|never autonomous| DEC
```

Agents may build, verify, document, and roll back their own work. They do not decide to expand
exposure, rotate credentials, or take irreversible action. Those require the operator.

### Secrets

- Credentials live in a **managed secret store**, injected into the environment only for the hosts they
  are scoped to. They are never written into repositories, and never printed into logs.
- Where a credential must be *used*, it is consumed by the command that needs it, not read into the
  agent's reasoning.
- Repositories are private as a second layer, not as the primary control.

### Verification of subordinate work

A worker's report is **evidence**, not a conclusion. The coordinator checks the artifact before acting
on it. This is the same rule as "verify with the real artifact", applied to people-shaped inputs.

### Blast radius

```mermaid
flowchart LR
    P[Prefer reversible] --> Q[Capture rollback before the change]
    Q --> R[Change one thing at a time]
    R --> S[Prefer gated over autonomous for the irreversible]
```

---

## Skills: reusable procedure

Because the same tasks recur, procedure is captured as **skills** — short, opinionated runbooks that
an agent loads when the task matches. Examples in this lab:

| Skill | Covers |
|---|---|
| Edge operations | Publishing, unpublishing, password-protecting, overlay peers |
| Service deployment | Standing up a web app or container service on its own guest |
| Protected credentials | Requesting and consuming stored secrets without seeing them |
| Hypervisor access | Key installation and verification for guests |
| GPU media guests | Handing the shared GPU to a guest and proving it works |
| Log collection | Standing up a collector and pointing sources at it |
| Secrets handling | Reading and relocating credential files safely |

Skills encode the **sharp edges** discovered the hard way — the tunnel MTU that must be pinned, the
JSON output that must be enabled, the step count that must be lowered. A skill is where a lesson stops
being a memory and becomes a procedure.

---

## What the platform does not do

- **It does not act on its own goals.** There are no standing objectives, no self-directed expansion,
  no background acquisition of capability.
- **It does not hold credentials it does not need.** Access is per-task and scoped.
- **It does not hide its work.** Every material action lands in a log someone can read.
- **It does not treat a green check as proof.** The artifact is the proof.

---

## A worked example

A representative task end to end:

```mermaid
sequenceDiagram
    participant O as Operator
    participant C as Coordinator
    participant W as Worker
    participant E as Estate
    participant G as Git
    O->>C: "publish this service publicly"
    C->>C: decompose, assess risk, choose a model
    C->>W: implement (with the edge skill loaded)
    W->>E: create DNS record, add overlay peer, add proxy block
    W->>E: verify: no-credential request refused, credentialed request succeeds
    W->>G: log activity, update runbook, commit
    W-->>C: report with evidence
    C->>C: verify the evidence independently
    C-->>O: result, plus what was deliberately not done
```

The last line matters as much as the first: the platform is expected to say what it did **and** what it
left alone, including the gaps it knows about.
## Current routing override

The operator has selected DeepSeek-only routing for all seven configured coordinator/worker
identities, without automatic provider fallback. The tiered-model diagrams and descriptions below
describe the prior design, not current routing policy. The local offline service is a separate
capability. See [rollout](rollout.md) for runtime verification gates and sequencing.
