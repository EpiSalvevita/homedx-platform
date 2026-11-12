# Analysis: home-test and telehealth players outside Europe

- Date: 2026-11-12. Status: draft, not PRRC-reviewed. Sources: `../sources/2026-11-12-players-global.md`. Data: `../dashboard/staging/players-global.json`.
- Scope: global ex-Europe players, not already covered (Cube OEM peers, Cerascreen, Lykon, Medivere, TeleClinic, DoktorABC, Doctolib, Ada, LetsGetChecked). No judgement on homeDX's regulatory status.

## Method
About 33 searches/fetches. Only facts read on a fetched page are used; search snippets were leads. Many sites returned HTTP 403 (Cue/Becker's, GenomeWeb, Hims.com, Ro.co, BusinessWire, MobiHealthNews, Fierce), so those players or claims were dropped or marked "unklar".

## Players
| Player | Model | Overlap | Reason |
|---|---|---|---|
| Cue Health (USA, shut down May 2024) | home molecular test | Niedrig | Discontinued; lesson: single-product, regulator-dependent business. |
| Lucira Health / Pfizer (USA, authorizations revoked Oct 2025) | home test with device | Niedrig | Discontinued; bankruptcy 2023, Pfizer takeover; no app/doctor link on cited pages. |
| Scanwell Health / BD (HQ unklar) | smartphone-camera test reading | Mittel | Similar tech idea (app reads test, stores/reports results); doctor access not on cited page; current status unverified. |
| Healthy.io (Israel/USA) | smartphone-read home kidney test | Mittel | App-based home test sold in the UK too; partners are health plans; doctor role not on page. |
| Everlywell (USA) | mail-in home test + physician/telehealth | Mittel | Closest business model (test then doctor); US-focused, no EU presence verified. |
| imaware (HQ unklar) | mail-in home test, clinician access | Niedrig | Mail-in lab test, self-pay; no EU presence seen. |
| Hims & Hers (USA) | telehealth + lab tests (at-home draw being built) | Niedrig | Telehealth-led, test rollout was only planned as of Feb 2025. |

Lesson (sourced): Cue and Lucira show regulatory and cost risk for home-test hardware makers.

## Unverified leads (not in JSON)
- Ro (at-home kits ordered by a provider): only search snippet, ro.co returned 403.
- NOWDiagnostics (First To Know syphilis OTC test): no app/telehealth found; page 403.
- DOC2US (Malaysia, RTKis rapid-test system with app): MobiHealthNews 403.
- Lemonaid/Scanwell UTI test + telehealth (2019): Fierce 403.

## Skipped
Teladoc, Amwell, Amazon One Medical, Detect, Testcard, Asia-Pacific beyond DOC2US (budget). Only 7 players, below the 8-12 target.
