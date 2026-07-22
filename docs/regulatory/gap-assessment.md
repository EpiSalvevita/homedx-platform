# homeDX Regulatory Engineering Gap-Scan

**Original scan:** 2026-07-02  
**Updated:** 2026-07-22 (result-path fix + classification draft + staleness refresh)  
**Scope:** `backend/` (NestJS/Prisma) and `frontend/mobile/hdx_mobile/` (Flutter)  
**Method:** static, read-only code/repo scan against
[`.cursor/rules/mdr-compliance.mdc`](../../.cursor/rules/mdr-compliance.mdc),
plus follow-up engineering closures.

> **What this document is:** a code-derived list of what regulatory-relevant
> artifacts and practices exist vs. are missing in this repository.
>
> **What this document is not:** a legal determination, a completed technical
> file, or a substitute for a PRRC / Cube manufacturer QMS / Notified Body.
> “Closed” means an *engineering* gap was addressed — not that homeDX is CE-conformant.

---

## 2026-07-22 update (this pass)

### Closed / improved (engineering)

1. **Flutter no longer invents POSITIVE/NEGATIVE from numeric `value`**
   (`cube_service.dart` `_determineResultString`). Missing/unknown class →
   **`INCONCLUSIVE`** (aligned with backend fail-closed). Tests updated in
   `cube_service_test.dart`.
2. **Backend prefers `resultData[].class` over client `result`**; if
   `resultData` is present but has no usable class, client POS/NEG is
   **ignored** → `INCONCLUSIVE`. New e2e cases in `submit-cube-data.e2e-spec.ts`.
3. **`CUBE_USE_TIMER` forced `true` in release builds** (`constants.dart`) so
   production cannot skip assay incubation via `.env`.
4. **Draft classification document added:**
   [`classification-draft.md`](./classification-draft.md) — IVDR primary;
   working draft **IVDR Class C** for RheumaCheck-style marker pathway;
   MDR Rule 11 **analogy Class IIa** if that regime is applied. **Still needs
   PRRC sign-off** (not CE certification).

### Still open (unchanged intent)

- Formal PRRC approval of classification + manufacturer of record.
- SRS, ISO 14971 risk file, IEC 62366 usability file, traceability matrix, PMS log.
- Certificate “Valid until” wording; telemedicine “Empfohlen” claims language.
- Positive/error color overlap; unstyled pre-consent result text.
- GDPR erasure/retention policy decision.
- Synthetic TestKit auto-create on Cube submit (traceability).

---

## 1. Scope and classification

- ✅ **Draft in-repo:** [`classification-draft.md`](./classification-draft.md)
  (2026-07-22).
- **Still open for humans:** PRRC must approve IVDR class (draft **C**) and
  whether any MDR Rule 11 (**IIa** analogy) dual-regime applies. Until signed,
  do not market “CE Class IIa/IIb certified.”

## 2. Roles

- No PRRC / software manufacturer-of-record named in-repo.
- **Gap:** add a one-pager under `docs/regulatory/` once organizationally decided.

## 3. Software lifecycle — IEC 62304

| Area | Backend | Mobile |
|---|---|---|
| Cube ingest (`submit-cube-data`) | Covered — `submit-cube-data.e2e-spec.ts` | Covered — `cube_service_test.dart` |
| Result normalization | Covered + **2026-07-22** class-authority tests | Covered + **no numeric invent**; fail closed to INCONCLUSIVE |
| `INVALID` / `INCONCLUSIVE` | Covered | Covered (badge + submit path) |
| Certificate gate POSITIVE/NEGATIVE only | Covered — `mobile-certificate.service.e2e-spec.ts` | List smoke; detail/PDF still thin |
| Unit tests under `backend/src/` | Still zero `*.spec.ts` (e2e-named tests in CI) | Stronger service/widget coverage |
| Coverage gate in CI | Not found | `flutter test`, no coverage threshold |

- **SOUP:** [`soup-list.md`](./soup-list.md) exists; Dependabot + `npm audit` in CI present (see §9).
- **Versioning / CHANGELOG:** exist; bump on regulated-surface changes (see root `CHANGELOG.md`).
- **Still open:** SRS, architecture design doc, CAPA log.

## 4. Risk management — ISO 14971

- **No formal risk management file** in-repo.
- Result path risk reduced 2026-07-22 (client thresholding removed; server authority).
- Certificate gate POSITIVE/NEGATIVE only — product decision; PRRC should confirm clinically.
- AuditLog written on login / Cube submit / certificate issue — retention/access/review process still undecided.
- Usability hazards (§5) still lack hazard-log entries.

## 5. Usability engineering — IEC 62366-1

- Positive vs error **coral color overlap** — known gap, pinned by test; design review deferred.
- Invalid vs pending gray similarity — open.
- Pre-consent plain-text result (`test_submission_screen.dart`) — open.
- Measurement failure UX — previously assessed as clear.

## 6. Data protection and cybersecurity

- Health data in plaintext DB columns (infra encryption outside repo visibility).
- No GDPR erasure API — deferred pending legal retention decision.
- `CUBE_VERBOSE` off by default in release — closed 2026-07-02.
- Backend logs mostly metadata-level — reasonable.
- CI gitleaks / patient-upload guards — positive control.

## 7. Technical documentation and traceability

**Updated 2026-07-22:** `docs/regulatory/` is no longer empty:

| Document | Status |
|----------|--------|
| README scaffold | Present |
| gap-assessment (this file) | Present |
| soup-list.md | Present |
| questionnaire-submissions-v1.md | Present |
| **classification-draft.md** | Present (draft) |
| SRS / risk file / usability file / traceability matrix / PMS log | **Missing** |

## 8. Post-market surveillance and vigilance

- No PMS/vigilance log.
- **Corrected:** AuditLog **is** populated on login/Cube/cert (older §8 text that said “not populated” was stale). Retention and review process still open.

## 9. Change control and versioning

- CHANGELOG + version fields exist.
- **Corrected:** Dependabot config and CI `npm audit` (critical level) exist — older “none” claim was stale. SOUP list still needs periodic human refresh.

## 10. AI/agent guardrails

- `.cursor/rules/mdr-compliance.mdc` §10 Regulatory note discipline remains active.
- No in-app AI/ML result interpretation found (2026-07-22 scan).

---

## Top remaining gaps (priority)

1. **PRRC sign-off** on [`classification-draft.md`](./classification-draft.md) (IVDR C / MDR IIa analogy).
2. **Technical file population** — SRS, ISO 14971, IEC 62366, traceability, PMS.
3. **Claims language** — certificate “Valid until”; telemedicine specialty “Empfohlen”.
4. **Usability** — positive/error color; pre-consent badge.
5. **GDPR erasure** — after retention policy.
6. **Synthetic TestKit** creation on Cube submit — traceability design.

---

## Disclaimer (restated)

Produced by an AI coding agent from repository evidence only. It cannot see
contracts, QMS documents outside the repo, or Notified Body correspondence.
Treat every item as a question for a qualified PRRC — including the draft
class call in [`classification-draft.md`](./classification-draft.md).
