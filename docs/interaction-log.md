# Interaction log (sanitised)

A running, sanitised record of how the operator and the agent work together - requests, decisions,
mistakes and how they were corrected. Kept so the collaboration itself is inspectable, not just its
outputs.

**Sanitisation rules:** no credentials, no addresses or internal hostnames, no private prompts, no
personal data. Requests are summarised, not quoted verbatim.

## Format

```
### <date> - <short title>
- **Asked:** what the operator requested (summarised)
- **Decided:** what the agent chose to do
- **Mistake (if any):** what went wrong, stated plainly
- **Correction:** how it was put right
- **Artifacts:** links/commits
```

## Entries

### 2026-10-03 - Real demos replace the staged one
- **Asked:** make real demo recordings, a dedicated demos page linked from the More menu, remove the
  old fake demo, and add an in-lab EDM soundtrack.
- **Decided:** build three recordings for real (build-on-camera, site tour, 2captcha attempt), verify
  each frame by frame, publish only after checking; compose the music in-lab.
- **Mistake:** the first automated captcha attempt mistyped because the on-screen coordinates were
  measured against a shifted layout, and the virtual display died mid-run.
- **Correction:** the failure was published as an honest partial result rather than hidden, and the
  tooling gap (no OCR, blank-rendering browser) was recorded as a backlog item.
- **Artifacts:** the demos page; the demos commit.

### 2026-10-03 - Tooling gap closed (OCR + browser)
- **Asked:** obtain the tools needed to do the demo properly and to browse the web and record sessions.
- **Decided:** install an OCR engine and use a browser engine that renders the modern challenge pages.
- **Mistake:** an early attempt to fix the captcha demo typed nothing useful and was caught only by
  looking at the frame.
- **Correction:** recognised that reading the frame is part of the loop, not an optional extra.
- **Artifacts:** recorded in the project checklist.

### 2026-10-03 - Boundary proof project begins
- **Asked:** complete a seven-item evidence project end to end, protecting the existing site.
- **Decided:** record the baseline first, write a durable checklist, work in dependency order, keep
  changes additive.
- **Mistake:** the agent spent a long stretch repeating the same no-op tool call instead of progressing -
  a real self-inflicted delay.
- **Correction:** named openly here rather than glossed; work resumed item by item.
- **Artifacts:** the project checklist (baseline + items).

### 2026-10-03 - Standing preference: operator mail
- **Asked:** always reply to and accept email from the operator's three addresses.
- **Decided:** treat those three addresses as trusted correspondents; accept and reply without further
  confirmation; still apply the no-secrets-in-content rule to any reply.
- **Artifacts:** recorded in the operator preferences below.

## Operator preferences (standing)

| Preference | Value |
|---|---|
| Trusted correspondents | the operator's three addresses (three provider mailboxes) - accept and reply automatically |
| Tone | direct; mistakes stated rather than hidden |
| Autonomy | act on reversible/testing-verified changes; escalate only high-risk ones |
