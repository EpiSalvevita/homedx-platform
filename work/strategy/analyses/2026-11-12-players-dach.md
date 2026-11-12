# Analysis: Further DACH players around home/near-patient testing and doctor access

- **Date:** 2026-11-12 | **Status:** draft | **Sources:** [`../sources/2026-11-12-players-dach.md`](../sources/2026-11-12-players-dach.md) | **Data:** `../dashboard/staging/players-dach.json`
- Does not assess homeDX's regulatory status. No CE status, performance, prices or user numbers are claimed beyond what a cited page states.

## Method
About 33 searches/fetches. Search snippets were leads only; each entry rests on a page that loaded. Company statements are marked "X states". Pages were fetched once; notes were then checked against the fetched text (9 of 9). Re-fetching was not done separately (15-minute cache).

## Players (9)
| Player | Country | Model | Overlap | Reason |
|---|---|---|---|---|
| Liftric (Reader-App) | DE | Smartphone test reading | Mittel | Closest on the reading step (app evaluates a rapid test); no doctor access stated |
| Ocumeda | unclear | Optician screening, remote specialist review | Mittel | Near-patient measurement then specialist review; eye care, not rapid tests |
| Swica TytoHome | CH | Home device + doctors (santé24) | Mittel | Home device plus doctor path; insurer-bound, 2021 source |
| DoctorBox | DE | Mail-in home test + app | Mittel | Home test with app result; page names no doctor consult |
| Medgate | CH | Telemedicine + pharmacy diagnostics | Mittel | Doctor access plus pharmacy diagnostics sent to doctors |
| Aids-Hilfe Check at Home | CH | Mail-in test | Niedrig | Non-profit, service suspended |
| Shop Apotheke Online-Arzt | unclear | Online prescription | Niedrig | Doctor access only, narrow topics |
| Medi24 | CH | Telemedicine | Niedrig | No tests on page |
| Galenica Book a Doc | CH | Pharmacy video link to doctor | Niedrig | Pharmacy tests not yet part of it |

## Removed
- Fernarzt: PZ (2024-01-02) reports home tests, video and e-prescription stopped; HealthHero page still lists self-tests. Conflict, left out.
- Healthy.io: page names no DACH country; not shown to be active in DACH.

## Unverified leads
Zava home tests, DocMorris/Homehulab self-tests (pages returned 403); Kry/Livi DACH (no current source); Castalytics (research report only); Aidian QuikRead pharmacy use (professional listings only).

## Skipped
Selfcheck, Sanego (no hits), Austrian providers (no home-test + doctor player found), mySugr-type apps, pharmacy chains' own test services.
