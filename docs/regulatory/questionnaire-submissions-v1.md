# Regulatory note — RheumaCheck Anamnesefragebögen A–D (v1)

**Change:** JSON-driven questionnaire capture (modules A–D) with backend persistence (`QuestionnaireSubmission`), patient consent, audit metadata, and hub/flow integration in the mobile/web app.

## Regulatory relevance

**Yes — health data (GDPR Art. 9).** Questionnaire answers are self-reported health-related information. This feature does **not** alter Cube `RapidTest` result interpretation, thresholds, or certificate generation.

**v1 scope (intentional limits):**

- Capture and store answers only; no automatic diagnosis, stratification score, or care-path routing shown to users.
- Patient modules A/C require explicit consent before save/submit.
- Audit logs record submission metadata (module, version, submission id) — **not** full answer payloads.

## Risk if buggy (ISO 14971-style)

| Failure mode | Impact |
|--------------|--------|
| Wrong branching / validation | Incomplete or inconsistent anamnesis data; user frustration; study data quality issues |
| Consent bypass | GDPR / informed-consent non-compliance |
| Duplicate or lost submissions | Missing or duplicated research/clinical workflow records |
| Accidental clinical output in UI | Could blur accessory vs SaMD boundary — **not implemented in v1** |

## Test evidence

| Layer | Evidence |
|-------|----------|
| Backend e2e | `backend/test/questionnaire.e2e-spec.ts` — role guards, patient A submit, doctor B submit, draft resume (6 tests) |
| Flutter unit | `test/questionnaires/questionnaire_branching_test.dart` — `show_if`, short-route, step builder |
| Flutter widget | `test/questionnaires/questionnaire_field_widgets_test.dart` — `single_choice`, `likert_5` |
| Manual (recommended) | End-to-end flows: A before RheumaCheck, C after result, doctor B/D; consent gate; draft resume |

## Human / PRRC sign-off

Recommended before production use of questionnaire data in any clinical or regulatory submission:

- Confirm intended purpose remains **data capture for study/UX** (not diagnostic decision support).
- Confirm privacy notice and consent copy with legal/DPO.
- Confirm whether modules B/D physician forms require separate professional-use labeling.

**Not required for merge of v1 capture-only implementation** if team accepts documented deferrals (no clinical routing, no CSV/FHIR export UI yet).

## Deferred (documented out of scope)

- Automatic stratification or care recommendations
- Full CSV export UI (admin JSON export API exists)
- FHIR export
- GDPR erasure endpoint (platform-wide gap)
- Editing submitted responses after submit
