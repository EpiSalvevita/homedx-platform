# Certification roadmap — homeDX software

**Date:** 2026-07-22  
**Owner (fill in):** _PRRC / regulatory affairs_  
**Status:** Living plan (non-code). Engineering evidence lives under [`docs/regulatory/`](../../docs/regulatory/).

**Interactive view:** open the Cursor canvas
[certification-roadmap](/home/epi_linux/.cursor/projects/home-epi-linux-homedx-platform/canvases/certification-roadmap.canvas.tsx)
beside chat. (Canvases live in Cursor’s managed `canvases/` folder so they can render — not inside `work/`. See note at the bottom.)

**Draft class target:** IVDR **Class C** (primary); MDR Rule 11 analogy **Class IIa** only if dual-regime applies — see [`classification-draft.md`](../../docs/regulatory/classification-draft.md).

---

## Goal

Place homeDX (Flutter app + NestJS backend as Cube accessory / IVD MDSW) on the EU market with a defensible conformity assessment: clear intended purpose, locked classification, technical documentation, Notified Body involvement as required for the final class, and post-market surveillance.

This roadmap does **not** certify the product. It sequences the work until a human PRRC and (where required) a Notified Body can.

---

## North-star assumptions

1. **Primary regulation:** IVDR (EU) 2017/746 — rapid-test / RheumaCheck-style result pathway.  
2. **Most intrusive clinical loop:** Cube assay → display result → on **positive**, specialist booking + Daily.co video.  
3. **Software does not** optically evaluate the cassette (Cube does) and must not invent POS/NEG from raw numbers (fixed 2026-07-22).  
4. **Germany:** MPDG + BfArM; DiGA is out of scope unless deliberately pursued later.

---

## Phases

### Phase 0 — Governance lock-in (weeks 0–4)

| # | Deliverable | Owner | Done when |
|---|-------------|-------|-----------|
| 0.1 | Name **manufacturer of record** for the software | Leadership / legal | Written decision on file |
| 0.2 | Appoint **PRRC** (Art. 15 IVDR) | Leadership | Named person + qualifications recorded |
| 0.3 | Written **intended purpose** (DE + EN) | PRRC + product | Matches IFU / app claims / marketing |
| 0.4 | Cube OEM letter: assay class, accessory listing, interface boundaries | Partnerships + PRRC | Signed or equivalent QMS ref |
| 0.5 | Approve or revise [`classification-draft.md`](../../docs/regulatory/classification-draft.md) | PRRC | Status → “approved” with date/signatory |

**Exit:** No CE claims in brand/marketing until 0.5 is signed.

### Phase 1 — QMS & lifecycle (months 1–3, overlaps Phase 0)

| # | Deliverable | Standard | Repo home |
|---|-------------|----------|-----------|
| 1.1 | Software development lifecycle SOP | IEC 62304 | Process outside git + pointers in `docs/regulatory/` |
| 1.2 | **SRS** (software requirements) | IEC 62304 | `docs/regulatory/` (create) |
| 1.3 | Architecture / detailed design as required by safety class | IEC 62304 | `docs/regulatory/` |
| 1.4 | **SOUP** maintenance process (not one-shot list) | IEC 62304 | Extend [`soup-list.md`](../../docs/regulatory/soup-list.md) + Dependabot review cadence |
| 1.5 | Configuration management / versioning discipline | IEC 62304 | Enforce CHANGELOG on regulated-surface PRs |
| 1.6 | Problem resolution / CAPA log | IEC 62304 | `docs/regulatory/` or QMS tool |

**Exit:** Auditable process exists; engineers know how to escalate regulated changes.

### Phase 2 — Risk, usability, security (months 2–5)

| # | Deliverable | Standard | Notes |
|---|-------------|----------|-------|
| 2.1 | ISO **14971** risk management file | Hazard analysis for wrong/missed result, bad certificate, failed teleconsult handoff | |
| 2.2 | Risk controls ↔ requirements ↔ tests **traceability matrix** | Link to SRS + test IDs | |
| 2.3 | IEC **62366-1** usability engineering file | Fix or accept: positive/error color; pre-consent plain text; “Empfohlen” wording | |
| 2.4 | Cybersecurity / health-software posture | MDCG 2019-16, IEC 81001-5-1 (as scoped by PRRC) | Auth, logging, Art. 9 data |
| 2.5 | GDPR Art. 9 retention & erasure policy → implement | Legal first, then engineering | Still open in gap-assessment |
| 2.6 | Claims cleanup | Certificate “Valid until”; telemedicine CTA disclaimers | PRRC + legal copy |

**Exit:** Residual risk accepted by PRRC; usability and claims signed off.

### Phase 3 — Verification & validation (months 4–7)

| # | Deliverable | Notes |
|---|-------------|-------|
| 3.1 | V&V plan covering Cube → normalize → store → display → certificate → positive booking → video | |
| 3.2 | Expand automated evidence (e2e + UI) on regulated path; close certificate detail/PDF gaps | |
| 3.3 | System / clinical evaluation inputs as required by class (IVDR clinical evidence / performance) | Align with Cube manufacturer evidence — do not invent |
| 3.4 | Labeling / IFU / in-app legal pages consistent with intended purpose | |
| 3.5 | Freeze release candidate + known residual anomalies list | |

**Exit:** Objective evidence pack ready for technical documentation Annex II/III.

### Phase 4 — Technical file & conformity assessment (months 6–12+)

| # | Deliverable | Notes |
|---|-------------|-------|
| 4.1 | Compile **technical documentation** (IVDR Annex II) + PMS plan (Annex III) | |
| 4.2 | Select **Notified Body** (Class C typically requires NB involvement) | Timeline dominated by NB queue |
| 4.3 | Conformity assessment application + Q&A cycles | |
| 4.4 | **EU declaration of conformity** + CE marking | Only after successful assessment |
| 4.5 | **EUDAMED** registration / UDI as applicable | |
| 4.6 | Economic operator setup (importer/distributor) if placing on DE/EU market | MPDG |

**Exit:** Legally placed on market under the approved intended purpose.

### Phase 5 — Post-market (ongoing)

| # | Deliverable | Notes |
|---|-------------|-------|
| 5.1 | PMS / vigilance SOP (wrong result shown to user = potential reportable) | |
| 5.2 | PMCF / performance follow-up as required by class | |
| 5.3 | Change control: any new interpretation, AI, or triage logic → re-open classification | |
| 5.4 | Periodic SOUP / security review | |

---

## Parallel workstreams (do not serialize everything)

```text
Governance (0) ──┬──► QMS/SRS (1) ──► Risk/Usability (2) ──► V&V (3) ──► NB/CE (4) ──► PMS (5)
                 │
                 ├──► Cube OEM alignment (0.4)
                 ├──► Claims & UX copy (2.6 / 2.3)
                 └──► Engineering closures from gap-assessment (ongoing)
```

---

## Engineering backlog already known (from gap scan)

Prioritize inside Phases 2–3; detail in [`gap-assessment.md`](../../docs/regulatory/gap-assessment.md):

1. PRRC sign-off on classification draft  
2. Certificate PDF wording (“Valid until”)  
3. Telemedicine “Empfohlen” / specialty mapping claims  
4. Positive vs error color; pre-consent result badge  
5. GDPR erasure after retention policy  
6. Synthetic TestKit auto-create (traceability)

**Already improved (2026-07-22):** client/server result authority (no numeric invent; fail closed to INCONCLUSIVE); release incubation timer forced on.

---

## Success metrics

- Intended purpose + class **approved** (not draft)  
- Technical file complete enough for NB kickoff  
- Zero untracked changes to result/certificate surfaces (CHANGELOG + Regulatory note discipline)  
- PMS pathway tested with a tabletop “wrong result already shown” drill  

---

## Related links

| Doc | Role |
|-----|------|
| [`product-brief.md`](../product-brief.md) | Product framing for non-code work |
| [`classification-draft.md`](../../docs/regulatory/classification-draft.md) | Draft IVDR C / MDR IIa analogy |
| [`gap-assessment.md`](../../docs/regulatory/gap-assessment.md) | Engineering gaps |
| [`APPOINTMENTS_VIDEO.md`](../../docs/APPOINTMENTS_VIDEO.md) | Telemedicine mechanics |
| [`.cursor/rules/mdr-compliance.mdc`](../../.cursor/rules/mdr-compliance.mdc) | Agent guardrails while coding |

---

## Note: why the canvas is not inside `work/`

Cursor **Canvases** (`.canvas.tsx`) only render when they live under the IDE’s managed `canvases/` directory. This `.md` file is the durable, git-friendly roadmap in `work/`; the canvas is the interactive companion. Keep both in sync when phases change.

## Note: `.md` vs `.mdc` (quick)

| | `.md` (Markdown) | `.mdc` (Cursor Rule) |
|--|------------------|----------------------|
| Purpose | Human docs (README, roadmaps, notes) | Instructions injected into the AI agent |
| Frontmatter | Optional / ignored by most tools | YAML: `description`, `globs`, `alwaysApply` |
| Who reads it | You, GitHub, the agent *if opened* | Cursor automatically when rule matches |
| Example here | This file | [`mdr-compliance.mdc`](../../.cursor/rules/mdr-compliance.mdc), [`homedx-work.mdc`](../../.cursor/rules/homedx-work.mdc) |
