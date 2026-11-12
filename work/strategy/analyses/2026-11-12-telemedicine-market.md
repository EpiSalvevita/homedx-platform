# Analysis: Telemedicine market for "home test + app + doctor access" (Germany, EU at a glance)

- **Date:** 2026-11-12
- **Author:** Claude (research agent), for founder review
- **Status:** draft (not PRRC-reviewed)
- **Related:** [`../../product-brief.md`](../../product-brief.md), [`../market/overview.md`](../market/overview.md), competitors (Cube OEM peers, not repeated here): [`../competitors/_index.md`](../competitors/_index.md). Sources: [`../sources/2026-11-12-telemedicine-market.md`](../sources/2026-11-12-telemedicine-market.md). Dashboard data: `../dashboard/telemed_players.json`, `../dashboard/telemed_market.json`.

All URLs below were accessed 2026-11-12. A fact appears only if the fetched page contained it.

## Question

What does the market look like for "home test device + app + access to a doctor" in Germany (EU at a glance)? Who else does this, how do they get paid, and which rules shape the model?

## Scope

- In scope: published market figures (context only), 8 players, German payment routes, four rule areas (industry context, not legal advice).
- Out of scope: Cube OEM peers; any homeDX TAM/SAM/SOM; homeDX regulatory classification; pricing and user numbers.

## Method

- About 40 web searches/fetches. Search snippets were used as leads only; every cited fact comes from a page that was fetched and read.
- Company statements are quoted as "X states ...".
- Market-research firms measure different scopes; figures are not comparable with each other and are not homeDX's market.

## Findings

### A. Published market figures (context only)

1. **ITA (US Dept. of Commerce): German telehealth market $2.79 billion in 2024, projected $4.4 billion by 2030 (9.54% CAGR)**, "excluding digital fitness products and health trackers". Page dated 07/07/2025; not paywalled; page names no underlying data source. Broader than homeDX: all telehealth, not at-home testing. https://www.trade.gov/market-intelligence/germany-telehealth
2. **Same ITA page: "digital treatment and care" (excluding online doctor consultations) $2.32 billion in 2024**, 3.82 (currency symbol missing on page) in 2029. Different scope from finding 1; do not add them up.
3. **IMARC Group: Germany telemedicine market "increased from USD 3.2 Billion in 2025 to USD 4.0 Billion in 2026"**, USD 15.3 billion by 2034, 18.40% CAGR 2026-2034. Full report gated (paid licences shown). Broader than homeDX: all telemedicine services and technology. https://www.imarcgroup.com/germany-telemedicine-market
4. **Credence Research: Europe telemedicine USD 41.08 billion in 2024**, USD 160.8 billion by 2032, 18.6% CAGR. Page says "Last Updated: Dec 5" (no year); free sample plus "Request Quote", so the full report appears paid. Broader than homeDX: all European telemedicine. https://www.credenceresearch.com/report/europe-telemedicine-market
5. **Statista Market Insights "Digital Health, Germany"**: the market volume value and year are masked on the public page ("Limitierter Zugang"; Professional Account needed). No number can be cited. https://de.statista.com/outlook/hmo/digital-health/deutschland/
6. **The figures differ widely** (e.g. 2.79 vs 4.0 USD bn for nearby years) because scopes differ. None measures "home test + doctor access". This confirms the existing note in `market/overview.md`: no published figure sizes homeDX's offer.

### B. Payment and reimbursement in Germany

7. **Self-pay / IGeL.** Verbraucherzentrale (Stand 15 July 2025): IGeL are "freiwillige und medizinisch nicht notwendige Leistungen"; doctors must conclude a written contract before treatment; the bill should follow the GOÄ; "Eine Berechnung von Pauschalhonoraren oder Erfolgshonoraren ist unzulässig." https://www.verbraucherzentrale.de/wissen/gesundheit-pflege/aerzte-und-kliniken/10-tipps-fuer-patientinnen-und-patienten-11695
8. **GKV video consultations (EBM limits).** KBV news item (URL path 2025/04-03): the former limit on video services across all patients ("patientenübergreifende Begrenzung der Leistungen im Videokontakt"; previously "bei 30 Prozent") "rückwirkend zum 1. Januar entfällt" (2025); from 1 April the limit for known patients is "bis zu 50 Prozent statt maximal 30 Prozent aller Behandlungsfälle"; for unknown patients "bleibt es bei den 30 Prozent"; applied per practice (Betriebsstättennummer), not per physician. A known patient had a personal contact "in mindestens einem der drei Vorquartale". New surcharge of 3,72 Euro (30 points) for known patients treated exclusively by video in a quarter. KBV: https://www.kbv.de/praxis/tools-und-services/praxisnachrichten/2025/04-03/Videosprechstunden%20in%20noch%20gr%C3%B6%C3%9Ferem%20Umfang%20m%C3%B6glich%20-%20KBV%20und%20Kassen%20vereinbaren%20Ma%C3%9Fnahmenpaket . KV Baden-Wuerttemberg (article dated 4 April 2025) confirms the 30% to 50% change for known patients and the 30-point surcharge (3,72 Euro in 2025): https://www.kvbawue.de/praxis/aktuelles/nachrichten-zum-praxisalltag/news-artikel/videosprechstunde-begrenzungsregelungen-angepasst-und-neuer-zuschlag
   - Implication: a GKV video consult by a contract physician is billed by the practice within these quotas. The quotas apply per practice, and a new (unknown) patient, typical for an app-driven funnel, falls in the tighter 30% category.
9. **GKV/PKV/self-pay in practice (company wording).** TeleClinic states "Die Kosten für den Online-Arztbesuch werden von Ihrer Krankenkasse übernommen", privately insured patients "können die Rechnung wie gewohnt einreichen", and "Elektronische Privatrezepte müssen vom Patienten in voller Höhe selbst bezahlt werden." https://www.teleclinic.com
10. **DiGA (reference point only).** ITA states DiGA-registry services are entitled to reimbursement by public health insurance under the DVG and DiGAV; 69 approved services as of June 2025; manufacturers bear costs during provisional listing (up to 12 months); public insurance covers 73 million people (86.5%). No euro amounts on that page. Reference only; whether homeDX could fall into any such category is not assessed here. https://www.trade.gov/market-intelligence/germany-telehealth
11. **Home test kits themselves:** in the sources read, Cerascreen, Lykon and Medivere show euro prices and do not mention insurance coverage (see players). No source on GKV reimbursement of consumer home test kits was found; treat as not established.

### C. Rules that shape the model (industry context, not legal advice)

12. **Remote treatment, §7(4) MBO-Ä.** The Bundesärztekammer page states the (Muster-)Berufsordnung 2018 allows doctors "auch bei noch unbekannten Patienten eine ausschließliche Beratung oder Behandlung" via communication media, "sofern dies ärztlich vertretbar und die erforderliche ärztliche Sorgfalt gewahrt ist." The 121st Deutscher Ärztetag 2018 loosened the ban. This is the model rule; each Landesärztekammer adopts its own version (not checked). The full text of §7(4) was not read (the PDF fetch failed). https://www.bundesaerztekammer.de/themen/aerzte/digitalisierung/telemedizin-fernbehandlung
13. **Advertising for remote treatment, §9 HWG.** Text (gesetze-im-internet.de): para. 1 "Unzulässig ist eine Werbung für die Erkennung oder Behandlung von Krankheiten, Leiden, Körperschäden oder krankhaften Beschwerden, die nicht auf eigener Wahrnehmung an dem zu behandelnden Menschen oder Tier beruht (Fernbehandlung)." Para. 2: this does not apply to advertising for remote treatment via communication media "wenn nach allgemein anerkannten fachlichen Standards ein persönlicher ärztlicher Kontakt mit dem zu behandelnden Menschen nicht erforderlich ist." So advertising a doctor video call for a given condition depends on whether the professional standard requires in-person contact. https://www.gesetze-im-internet.de/heilmwerbg/__9.html
14. **IVDR self-testing.** Art. 2 of Regulation (EU) 2017/746 as adopted: "device for self-testing" is "any device intended by the manufacturer to be used by lay persons"; "near-patient testing" device is "any device that is not intended for self-testing but is intended to perform testing outside a laboratory environment". Source is a UK-hosted copy of the EU text as adopted (EUR-Lex was not retrievable); later consolidated versions may differ. Specific self-test requirements (Annex I information duties, advertising/claims, distance sales) were NOT read. https://legislation.gov.uk/eur/2017/746/article/2/adopted
15. **Health data, GDPR Art. 9.** Art. 9(1): processing of "data concerning health" "shall be prohibited". Exceptions include 9(2)(a) "explicit consent ... for one or more specified purposes" and 9(2)(h) processing necessary for "preventive or occupational medicine ... medical diagnosis, the provision of health or social care or treatment" on the basis of Union or Member State law or a contract with a health professional, subject to Art. 9(3) safeguards. Read on gdpr-info.eu (unofficial copy; EUR-Lex was not retrievable). https://gdpr-info.eu/art-9-gdpr/

## Players (8; checked against the company's own page unless stated)

| Player | Sells | Home test | Doctor access | Payer | Overlap | Reason / sourced note |
|---|---|---|---|---|---|---|
| Cerascreen (DE) | Mail-in lab test kits, supplements | yes | yes (link "Online-Sprechstunde mit Ärzt*in buchen") | Self-pay | Medium | Home test plus doctor booking, but sample-and-send lab kits, not a rapid reader. States many values "können als Grundlage für ein Arztgespräch dienen". https://www.cerascreen.de |
| Lykon (DE) | Dried-blood and DNA home tests, app results | yes | no (none found) | Self-pay | Low | familie.de (29.05.2025): Lykon states "Es geht nicht darum, den persönlichen Arztbesuch zu ersetzen"; price 199 EUR (13 values). Company site returned "Not found". https://www.familie.de/familienleben/gesundheit-checken-vom-sofa-aus-unser-ehrlicher-test-des-lykon-bluttests-fuer-frauen--01JC079WBSKX2JHFGMGRVSF1GT |
| Medivere (DE) | Mail-in lab tests via shop | yes | no | Self-pay (shop prices; no insurance mentioned) | Low | States "Ihr Arzt, Heilpraktiker oder Apotheker berät Sie gerne"; offers to send results to a practitioner on request. https://www.medivere.de |
| TeleClinic (DE) | Video consultation, e-prescriptions | no (not mentioned) | yes | Mixed (GKV, PKV, self-pay items) | Medium | Overlaps only on the doctor-access half; also a possible partner type. https://www.teleclinic.com |
| DoktorABC (DE) | Online pre-consultation, prescriptions, OTC incl. "Testzentrum" | unclear (OTC strips, pregnancy tests listed) | yes | Unclear | Medium | States "100 % Online-Arzt- und Apothekenservice"; payer not stated on page. https://www.doktorabc.com/de |
| Doctolib (FR/DE) | Booking platform; video consultation section | no (not mentioned) | yes (video page title only) | Unclear | Low | Page shows TÜV Nord "Trusted Site Video Consultation" badge; no payer detail read. https://www.doctolib.de/videosprechstunde |
| Ada Health (DE) | AI symptom assessment | no | no (not mentioned) | Unclear | Low | States "KI-gestützte, von Ärztinnen und Ärzten optimierte Symptomanalyse"; shows EN ISO 13485 badge, no class stated. https://ada.com/de/ |
| LetsGetChecked | At-home test kits, clinical support, pharmacy | yes | yes (secure messaging with clinicians, US page) | Unclear | Medium | Fetched page is the US site ("LetsGetChecked USA"); no EU/Germany statement found, so EU presence is unverified. https://www.letsgetchecked.com/ |

Overlap is a judgement on the combination "home test + doctor pathway + consumer payer". No player read here combines a rapid-test reader with a result-triggered specialist booking. Not shown: Zava, Kry/Livi, Fernarzt (see unverified leads).

## Implications for homeDX

- **Positioning:** The sourced market is split: home-test sellers (Cerascreen, Lykon, Medivere) mostly stop at "talk to your doctor", while doctor platforms (TeleClinic, DoktorABC, Doctolib) have no test. A kit-to-specialist pathway is not visible among the 8 checked, but this is absence in a small sample, not proof of a gap.
- **Go-to-market:** Self-pay is the model the home-test players use. The GKV video route has practice-level quotas (30% for unknown patients) and is billed by the treating practice, so a GKV pathway depends on partner practices rather than on homeDX.
- **Competitive response:** Cerascreen already links a bookable online doctor consult next to kits; closest overlap seen.
- **Risks (regulatory / claims):** wording such as "preventive diagnosis" and any statement that the app or reader detects disease is claim-sensitive (see `.cursor/rules/mdr-compliance.mdc`, `docs/regulatory/`). Competitors' own wording is cautious (results as "Hinweise", not a diagnosis, "basis for a doctor conversation"). Not decided here.

## Recommendations

| Action | Priority | Owner | Notes |
|---|---|---|---|
| Give PRRC the open questions below | High | Founder | Before any consumer wording |
| Verify IVDR self-test/advertising text from EUR-Lex | High | PRRC / counsel | Not read in this pass |
| Re-check Zava, Kry/Livi, Fernarzt on pages that load | Medium | Strategy | Fetches failed |
| Read full §7(4) MBO-Ä and the relevant Landesärztekammer rule | Medium | Counsel | Only a BÄK summary page read |

## Open questions for the PRRC / qualified person

1. Does wording like "preventive diagnosis" for a home test plus doctor access change the intended-purpose statement or the claims that can be made? (Not decided here.)
2. What IVDR self-testing requirements apply to a lay-person kit sold with an app (information duties, advertising limits)? The article text was not read.
3. Does advertising a doctor video call after a positive result fall under §9 HWG para. 1 or the para. 2 exception for the target condition?
4. Is a specialist consult after a self-test a "Fernbehandlung" under the relevant Landesärztekammer rule, and who is the treating physician legally?
5. GDPR Art. 9 basis for test results shared with a booked doctor (explicit consent vs. 9(2)(h)); roles with Daily.co.

## Unverified leads (not cited as facts)

- Zava (fetch 403, twice), Fernarzt (fetch 403, then a page whose content did not clearly identify the company), Kry/Livi (TLS error), Lykon own site ("Not found"): no company page read.
- A search summary mentioned a Grand View Research global telehealth figure (USD 77.4 billion in 2025); page not fetched.
- Search summaries mentioned other Germany telemedicine estimates (Market Research Future, Spherical Insights, Ken Research); pages not fetched.
- Search summaries mentioned an EBM number for the 30-point surcharge and 10-30% fee reductions for video-only care; the KV page did not confirm them, so they are omitted.
- Statista Germany digital health EUR 4.51 bn (2024) appeared in a search summary from a university proxy; the public page is masked.

## Not checked (budget)

- EUR-Lex official texts for IVDR and GDPR; full §7(4) MBO-Ä; IVDR Annex I self-test requirements and advertising rules.
- BfArM DiGA primary page (404); PKV reimbursement of telemedicine; GKV coverage of home tests.
- EU outside Germany (one Europe market figure only); Doctolib payer model; aware and other DE apps; regulatory status of the kits sold by Cerascreen/Medivere.

## Verification note

Every number and quote above was read in the fetched page content at the time of fetching (about 25 figures and quotes). Pages were not re-opened a second time. Removed because a page did not confirm them: the GOP number for the surcharge, "Quotierung" wording, fee-reduction percentages, global and other-publisher figures, and the Fernarzt row.
