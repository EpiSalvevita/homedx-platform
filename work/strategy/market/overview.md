# Market overview

Starter for market sizing and segment notes. Update with dated sources under [`../sources/`](../sources/) and deeper write-ups under [`../analyses/`](../analyses/). Product context: [`../../product-brief.md`](../../product-brief.md).

Last web pass: [`../sources/2026-08-26-cube-oem-refresh.md`](../sources/2026-08-26-cube-oem-refresh.md) and [`../analyses/2026-08-26-cube-oem-refresh.md`](../analyses/2026-08-26-cube-oem-refresh.md).

**Interactive view:** open the Cursor canvas
[market-overview](/home/epi_linux/.cursor/projects/home-epi-linux-homedx-platform/canvases/market-overview.canvas.tsx)
(EN) or
[market-overview-de](/home/epi_linux/.cursor/projects/home-epi-linux-homedx-platform/canvases/market-overview-de.canvas.tsx)
(DE) beside chat. (Canvases live in Cursor’s managed `canvases/` folder so they can render — not inside `work/`.)

## Category

Home / near-patient **rapid diagnostic test (RDT) reading** and related software accessories—especially ecosystems around dedicated readers such as the Cube.

homeDX is a **software accessory** to the Cube (Bluetooth → on-device evaluation → backend → display) plus a **care pathway** after positive results. Do not treat the figures below as a TAM for that offer.

## Segments (draft)

| Segment | Who | Jobs to be done | Notes |
|---------|-----|-----------------|-------|
| Consumer / home | Individuals | RA-related near-patient test + history | RheumaCheck in development; claims constraints are strict |
| Pharmacy / retail | Staff + customers | Guided testing, throughput | Closest *human Cube* analog: VHC (Vitamin D + Ferritin) — not rheumatology |
| Clinic / POC | Clinicians | Reliable capture, documentation | Biosynex/Chembio kit+reader bundles |
| B2B kit / OEM | Partners | Bundle software with kits/devices | opTricon APP/SDK is the hardware baseline |

Fill priority markets and discard segments that do not fit homeDX’s Cube-accessory model.

## Job, buyer, alternatives (the rest of a market analysis)

**Job:** shorten time from first joint symptoms to a rheumatologist (near-patient test + booking). Not “another reader.” RheumaCheck in development; video is not diagnosis/treatment.

| Role | Who | Today |
|------|-----|--------|
| User | Patient | App: Cube, result, on positive rheumatology video |
| Buyer / channel | Pharmacy, practice, or kit partner — undecided | Closest analog: VHC in pharmacy (Vitamin D + Ferritin) |
| Specialist | Rheumatology | Decision-maker on the call |
| Payer | Unclear (self-pay / IGeL vs GKV) | Stripe/PayPal exist; reimbursement **not sourced** |

**Same-job alternatives (not Cube OEM peers):** lab RF/CCP; visual LFAs (e.g. Orgentec Rheumachec); questionnaire-only sites; waiting for a Facharzt slot; opTricon APP/SDK (“why not the bundled app?”).

**So-what:** market = that job, not the $8.7B at-home pot. SOM stays empty until kit + channel + PRRC are locked. DE/EU first. OEM landscape = same hardware, different job.

## Geography

- Primary regulatory lens today: **EU / Germany** (IVDR/MDR accessory context, MPDG, health data).
- Expand only with evidence (reimbursement, distribution, language, local partners).

## Sizing (TAM / SAM / SOM)

Cube-accessory + care-pathway dollars are **not measured by any report we have**. The figures below are the **least-wrong published proxies** (accuracy issues remain; some are paywalled teasers). **SOM has no sourced number** — do not invent one.

Three nested circles (each smaller than the one outside):

| Layer | For homeDX | Least-wrong published proxy | Estimate |
|-------|------------|------------------------------|----------|
| **TAM** | All spend on our kind of offer (accessory + near-patient + path after positive) | Europe *at-home testing* USD 8.7B (2026, MarkWide, paywalled; glucose/OTC-heavy) | **USD 8.7B** (proxy) |
| **SAM** | What we could serve at all with Cube, human IVD, EU/DE, IVDR (RheumaCheck in development) | Global rapid-test *readers* ~USD 1.2B (2025, Verified Market Reports, paywalled; all reader types, worldwide) | **USD 1.2B** (proxy) |
| **SOM** | What homeDX can actually win in 12–36 months (kits, PRRC, distribution, specialists) | None | **—** |

### Context estimates (not homeDX TAM)

| Slice | Published figure | Why it is not our TAM | Source (accessed 2026-08-26) |
|-------|------------------|----------------------|------------------------------|
| Europe IVD (all) | USD **30.58B (2026)**; 5.22% CAGR 2026–2031 | • Entire human IVD (labs, analyzers, reagents, POC)<br>• homeDX sells none of that<br>• POC is mostly glucose / infectious / emergency, not RA<br>• Our offer is Cube accessory + RheumaCheck (in development) + rheumatology video | [Mordor Intelligence](https://www.mordorintelligence.com/industry-reports/europe-in-vitro-diagnostics-market) |
| Europe IVD (other vendors) | ~USD 24.8B–30.9B (2026) depending on firm | • Same too-wide category<br>• ~$6B / ~20% spread in the same year<br>• Averaging teasers is not a TAM | IMARC, Towards Healthcare, Morgan Reed — see sources file |
| Global rapid-test *readers* | ~USD **1.2B (2025)** → ~USD 2.5B (2034) | • Paywalled teaser only<br>• All reader types worldwide, not Cube-only<br>• Global, not EU/DE; hardware $, not software + care pathway<br>• opTricon “>40k readers” is installed base, not a $ SAM | [Verified Market Reports](https://www.verifiedmarketreports.com/product/rapid-test-reader-market/) |
| Europe *at-home testing* | USD **8.7B (2026)** | • Paywalled<br>• Dominated by glucose / pregnancy / OTC<br>• Most $ never touch a Cube or rheumatologist<br>• RA near-patient + video still has no sourced euro size | [MarkWide](https://markwideresearch.com/europe-at-home-testing-market) |

Do not invent a Cube-accessory SAM by scaling these down.

## Trends to watch

- Home diagnostics growth vs. clinic POC (Mordor cites a higher home-care / POC *end-user* CAGR than overall Europe IVD — still not Cube-specific).
- Reader + app ecosystems vs. smartphone-camera LFAs.
- **EU IVDR Class C gates for *legacy* devices** under (EU) 2024/1860 (industry context, **not** a homeDX status claim; confirm with PRRC):
  - IVDR QMS: 26 May 2025
  - Notified-body **application**: 26 May 2026 *(already past as of this note)*
  - **Signed NB agreement**: **26 September 2026**
  - Placing on the market into **31 Dec 2028** only if those conditions hold
  - Primary explainer: [European Commission Q&A on the IVDR extension](https://health.ec.europa.eu/document/download/dfd7a1c6-f319-4682-9bac-77bef1165818_en); also [HPRA](https://www.hpra.ie/regulation/medical-devices/manufacturers-and-authorised-representatives/ivdr-transitional-provisions)
- Payments / subscription models for test access.
- Data privacy (GDPR Art. 9 health data) as a trust differentiator.

## Implications for homeDX

July 2026 landscape still holds: compete on **accessory + care pathway**, not on making a Cube. **Assay gap (scoped):** none of the five current Cube-class peers publicly sell a rheumatoid-arthritis rapid test; RheumaCheck is homeDX’s in-development RA pathway (not a global “no RA tests exist” claim — lab panels and visual LFAs remain). Closest *human Cube* analog is still VHC (Vitamin D + Ferritin, professional). Mologic/HeadStart Cube use in 2026 is unconfirmed.

## Note: why the canvas is not inside `work/`

Cursor **Canvases** (`.canvas.tsx`) only render when they live under the IDE’s managed `canvases/` directory. This `.md` file is the durable, git-friendly copy; the canvas is the interactive companion. Keep both in sync when figures change.
