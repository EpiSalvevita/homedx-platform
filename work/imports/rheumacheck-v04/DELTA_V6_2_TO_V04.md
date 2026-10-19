# Delta: app catalogue v6.2 → RheumaCheck V04 (internal review draft)

Status: `INTERNAL_REVIEW_DRAFT_NOT_MEDICALLY_OR_REGULATORILY_APPROVED`. Content of V04 is not reviewed or approved by this repository. Do not treat wording or rules as clinically validated.

## Sources

| Item | Source | SHA-256 (prefix) |
| --- | --- | --- |
| Previous app catalogue | `backend/data/questionnaires/rheumacheck_questionnaires_v6_2.forms.json` (package `6.2`) | — |
| New catalogue | `docs/imports/rheumacheck-v04/catalogue/questionnaires.de-DE.V04.public.json` (package `3.0.0-internal-review.20261007`) | `09c18640` |

The V04 file is copied byte-identical to `backend/data/questionnaires/rheumacheck_questionnaires_v04.public.json` and `frontend/mobile/hdx_mobile/assets/questionnaires/rheumacheck_questionnaires_v04.public.json`.

## Structure

| Module | v6.2 (fields) | V04 (items) | V04 ID / role | Notes |
| --- | --- | --- | --- | --- |
| A | 40 | 45 | RC-A, patient | Pre-visit symptom survey |
| B | 38 | 34 | RC-B, professional | Current care pathway |
| C | 52 | 47 | RC-C, patient | Experience after documented use |
| C-FU | — | 8 | RC-C-FU, patient | Follow-up; not yet approved for invitation |
| D | 30 | 37 | RC-D, professional | Implementability |
| **Total** | **160** | **171** | | |

## Identity

- **Zero overlap of item IDs.** v6.2 uses names such as `A_joint_pain`, `B_…`; V04 uses `A00`…`D36`. No ID mapping exists; answers stored under v6.2 IDs cannot be re-keyed onto V04 items.
- Module keys change: app `A/B/C/D` → catalogue `RC-A/RC-B/RC-C/RC-D` plus `RC-C-FU`. The app keeps its own `moduleId` for routing; the catalogue `id` is stored as `catalogueId`.
- Legacy submissions: the local database was not reachable during this check. The user confirmed the existing `QuestionnaireSubmission` rows are synthetic/test only. Decision: v6.2 rows stay readable as archived legacy (keyed by `moduleVersion` `6.2`), new runs use V04 only.

## Schema differences (engine-relevant)

| Aspect | v6.2 | V04 |
| --- | --- | --- |
| Visibility | flat `show_if {field, equals}` | `visibilityRule` with `any`, `all`, `eq`, `neq`, `in`, `contains`, `answered`, `feature/shown` |
| Item types | `single_choice`, `likert_5`, `multi_choice`, `text`, `nrs_0_10` | `single`, `multi`, `scale_agree`, `scale_0_10`, `scale_1_5`, `rank_top3`, `rank_top5`, `matrix_presence`, `matrix_importance`, `bodymap_multi`, `lab_multi`, `multi_with_detail`, `textarea`, `review` (UI only), `version` |
| Option identity | label text | `optionCodes` (stable code per option) |
| Exclusive options | not modelled | explicit `exclusiveOptions` (must not be guessed from wording) |
| Other | `depth` kurz/voll | `optionSource` (C02 → C43), `responseContract`, `responseCoding`, `recallPeriodProposal` |

## Rules that must be honoured

- Unanswered parent is never "not equal to No" (`answered` required on the parent).
- Cyclic or unknown references are configuration errors (fail closed).
- `required` applies only to visible items.
- Scales 0–10 accept scalar numbers only.
- `review` items are UI controls and never stored as answers.
- The reference engine (`reference/engine.js`) contains a word-based `exclusive()` fallback. It is **not** ported; only explicit `exclusiveOptions` are used.

## Open items (not decided by this integration)

C03–C05 exposure applicability, minor/safety route, study endpoints, C-FU timing and invitation, consent wording, regulatory classification. See `FACHLICHE_PRUEFPUNKTE_V04.md`.
