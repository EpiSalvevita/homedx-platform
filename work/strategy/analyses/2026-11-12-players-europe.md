# Analysis: Players in Europe outside DACH (home test, reader, doctor access)

- **Date:** 2026-11-12 | **Status:** draft, not PRRC-reviewed | **Sources:** [`../sources/2026-11-12-players-europe.md`](../sources/2026-11-12-players-europe.md) | **Data:** `../dashboard/staging/players-europe.json`

## Method
About 32 searches/fetches. Search snippets were treated as leads only; every field in the JSON comes from a page that loaded. Company statements are phrased "X states ...". No view on homeDX's regulatory status is taken. Cube OEM peers and the earlier telemedicine players were excluded.

## Players (10)
| Player | Country | Model | Overlap | Reason |
|---|---|---|---|---|
| Healthy.io (UK service) | UK | Smartphone home test | High | App-evaluated home test with results passed to a clinician; no reader, single analyte (kidney); payer not stated |
| Withings U-Scan | France | Reader home device | Medium | Connected home reader with app, but wellness framing and no doctor path in the source |
| Thriva | UK | Mail-in test + doctor | Medium | Home sample, doctor review and video call; lab-based, not rapid |
| Kry | Sweden | Home test + clinician | Medium | Test, then midwife/nurse video; STI only; mail-in |
| NowPatient | UK | Home test + video | Medium | Every order includes a clinician video call; mail-in, self-pay |
| Aidian QuikRead | Finland | POC reader | Low | Professional reader with results to clinicians; no home use stated |
| Medichecks | UK | Mail-in test | Low | Self-pay kits; no doctor access described on page |
| Numan | UK | Telemedicine + tests | Low | Doctor-led care; home sampling not stated |
| Werlabs | Sweden | Blood test, doctor comment | Low | Sampling at a site, not at home |
| Qare | France | Video consult | Low | Doctor half only; reimbursed route; possible partner type |

## Unverified leads (pages failed to load; not in JSON)
Forth (UK), Zava (UK/DE; 403), TestCard (UK, smartphone urine card), Qassay (Spain, reader for self-test kits; timeout), Novarum/BBI (UK smartphone reader platform, B2B, search snippet only), Ixensor, Livi (Kry brand in UK/France; snippet only). The reader/smartphone leads are the closest to homeDX and worth a second pass.

## Skipped (budget)
Abingdon Health, Preventx/SH:24, Boots/Superdrug Online Doctor, Doctor Care Anywhere, Medicspot (fetched, no home test offered now), Italy/Spain/Poland-based players, Nordics other than Kry/Werlabs.

## Caveats
Withings is sourced from a news article, not the company page. Healthy.io's HQ is not on the cited page; "Vereinigtes Königreich" reflects the UK service only. Payer is "unklar" wherever the page is silent.
