# Regulatory note — RheumaCheck questionnaires (V04 catalogue, file kept as v1 for links)

Status: **change in review**, not merged. Content `3.0.0-internal-review.20261007`
is an internal-review draft and is not medically or regulatorily approved.

## Change

Questionnaire capture moves from the v6.2 catalogue to the V04 catalogue
(171 items; modules A, B, C, optional follow-up CFU, D). Backend persistence
stays in `QuestionnaireSubmission`. Rows are marked with the moduleVersion prefix
`v04:`. Earlier v6.2 rows stay in the database and are excluded from every
read path. See `CHANGELOG.md` (Unreleased) and `work/imports/rheumacheck-v04/`.

## Regulatory relevance

**Yes — health data (GDPR Art. 9).** Answers are self-reported and
health-related. The feature does not change Cube `RapidTest` result
interpretation, thresholds, certificates or any status mapping. No score, sum or
risk value is computed. Only the response kind and the rules in the catalogue
decide what is accepted.

Intended purpose remains data capture for study and usability (see
`work/imports/rheumacheck-v04/FACHLICHE_PRUEFPUNKTE_V04.md`). Not diagnostic
decision support.

## Failure modes (ISO 14971 terms)

| Failure mode | Possible effect | Control in this change |
| --- | --- | --- |
| Wrong branching drops or keeps an answer | Incomplete or inconsistent data | Server visibility engine plus identical client rules; hidden answers are pruned on save; unit tests on real catalogue |
| Unanswered parent treated as "not Yes" | Follow-up questions shown or stored wrongly | `answered` required before `eq`/`neq`/`in`/`contains`; tests |
| Scale stored as default 0 | Unanswered pain or function recorded as 0 | Server accepts integers only; app starts unanswered; widget test |
| Exclusive options inferred from wording | Wrong option combinations accepted | Only explicit `exclusiveOptions` are used; the reference heuristic was not ported |
| Synthetic example answers reach a real endpoint | Test data mixed into real records | Demo build never calls the server for questionnaire data; prefill exists only behind the demo define; default builds have no prefill control |
| Follow-up opened by someone not allowed | Data collected outside the invitation step | Allowlist in `QUESTIONNAIRE_REVIEWER_USER_IDS`; default empty; e2e test shows patient still refused |
| Completion page read as a result | Respondent takes the own-answers page as an assessment | Page states it is neither an assessment nor a diagnosis; shows only entered values, no score; wording to be reviewed |
| Stale or concurrent save overwrites newer draft | Lost or altered answers | Conditional write on status and revision; missing token refused for existing drafts; `REVISION_CONFLICT`; submit finalises at its own save's revision |
| Submit without consent | Consent requirement breached | Server requires `consentStatus: yes` for patient modules |
| Follow-up answered before assignment | Data collected without the invitation step | Server returns `NOT_ASSIGNED`; no invitation mechanism exists yet |
| Demo or synthetic data reaches a real endpoint | Test data mixed into real records | Server accepts only catalogue ids, types and codes. The client cannot set a mode. Demo export is not part of this app |
| Stored D11 rating differs from the label shown | Respondent misreads the rating | **Open**: D11 stores `nicht beurteilbar`, help text says `kann ich nicht beurteilen`. Content owner to decide. |

## Test evidence

| Layer | Evidence |
| --- | --- |
| Backend unit (`npm test`) | `questionnaire-v04-engine.spec.ts`, 21 cases incl. real-catalogue checks (171 items, unique ids, no unknown or cyclic references, form split, roles) |
| Backend e2e | `test/questionnaire.e2e-spec.ts`, 20 cases (incl. reviewer allowlist): role boundary, unknown module keys, follow-up refused, strict and lenient validation, consent, stale and missing revision token, two concurrent saves (one wins), idempotent retry, readback equality, legacy isolation on read, submit and listing, hidden-answer pruning |
| Flutter unit and widget | `test/questionnaires/questionnaire_branching_test.dart` (incl. parse of the real catalogue), `questionnaire_field_widgets_test.dart` (scale starts unanswered, explicit exclusivity, rank cap, matrix rating) |
| Demo | Flutter tests: synthetic answers complete every visible required question on the real catalogue; answers never store a hidden value |
| Build | `flutter analyze` clean; `flutter test` 129 passing; `flutter build web --release` ok |
| Second opinion | `regulatory-reviewer` read (read-only). Its two blocking findings (race on the revision check; no token required) are fixed and tested above. |
| **Missing** | Manual check at 320/390/768 px; real device; screen reader; a full run with a real patient and doctor account on a local database; a legacy-row test for draft save by module and for export |

## Human and PRRC sign-off

Required before merge:

- Whether patient submissions made before this change lack consent. The old
  code did not check consent. This is a DPO and PRRC question. The reviewer
  judged that vigilance is probably not triggered, since it is not a result
  error. A human has to confirm.
- Whether questionnaire answers feed any booking or referral trigger. If they
  do, the intended purpose may change. Not checked here.

- Content owner: question wording, D11 label choice, and the open clinical
  decisions in `FACHLICHE_PRUEFPUNKTE_V04.md` (C03–C05 exposure applicability,
  safety and minor route, endpoints, follow-up timing).
- Privacy and consent wording with the DPO.
- PRRC: classification question (intended purpose) and whether professional
  forms B and D need separate labelling.

Not decided by this change. No classification, no CE claim, no clinical
validity claim.

## Deferred (documented out of scope)

- Invitation and scheduling for the follow-up (CFU)
- Automatic scoring, stratification or care recommendations
- CSV or FHIR export UI (admin JSON export only)
- Editing a submitted response
- GDPR erasure endpoint (platform-wide gap)
