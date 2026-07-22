# Competitor: opTricon GmbH

- **Slug:** `optricon`
- **Last updated:** 2026-07-22
- **Owner:** _

## Snapshot

| Field | Value |
|-------|--------|
| Website | https://www.optricon.de/en |
| HQ / geos | Berlin-Adlershof (Schwarzschildstraße 1, 12489 Berlin); OEM customers worldwide |
| Category | OEM lateral-flow reader manufacturer (Cube / CubePlus, theReader, opTrilyzer) + first-party APP/API and PC DataReader |
| Target customer | Test manufacturers / distributors (OEM); end users via OEM brands |
| Overlap with homeDX | Medium — hardware dependency; native APP/SDK is a software baseline |
| One-line pitch (theirs) | Customized, Made-in-Germany optical readers for quantitative/qualitative LFA evaluation |

## Product & offer

- Hardware: CubePlus (~41×41×40 mm, ~40 g); Bluetooth 5.0, USB-C, rechargeable Li battery; RFID lot configuration; cassette/strip adapters. Also larger analyzers (theReader / opTrilyzer) and custom OEM builds.
- Software / app: Windows DataReader; Android/iOS APP and API/SDK for USB or Bluetooth; configuration software for test methods.
- Tests / assays supported (public): Open platform — “adapt to almost any” LFA (human IVD, vet, food/feed, forensics, lifestyle, environmental, etc.). Specific assays come from OEM customers, not opTricon as a consumer brand.
- Pricing / licensing (public): Not list-priced for end consumers; EVA/starter kits offered for evaluation. Deployed base cited as **more than 40,000** readers globally (acquisition messaging).
- Channels: OEM supply to diagnostics companies; networks (DiagnostikNet-BB, Berlin Partner, Fraunhofer HHI, PolyPhotonics Berlin). Long-standing link to Biosynex SA / Chembio.

## Comparison to homeDX

| Dimension | Them | homeDX | Implication |
|-----------|------|--------|-------------|
| Device model | Builds the Cube/CubePlus | Cube + accessory app | They supply the device class we depend on |
| Result capture | On-device optical eval; BT/USB export | Bluetooth → on-device eval → backend | Same measurement layer; we add cloud + care pathway |
| Account / history | Device memory + DataReader / APP | Cloud-backed account/history | Native tools may be “good enough” for professional users |
| Payments / access | Hardware OEM sale | Licenses / Stripe / PayPal | Different monetization layer |
| Certificates / docs | Device + OEM IFUs | Certificates / docs in platform | Ours is software/product feature, not theirs |
| Regulatory claims (public only) | ISO 13485:2016 (TÜV Rheinland); CubePlus offered for lab use and IVD purposes per IVDR (manufacturer statements) | Accessory framing — no invented claims | Align OEM letters / interface boundaries carefully |
| Distribution | B2B OEM | Consumer/near-patient software + teleconsult | Complementary more than substitute — unless partners ship their own apps |

## Strengths

- Entrenched OEM platform; small form factor; Bluetooth + APP/API for integrators.
- Quality / “Made in Germany” positioning; Adlershof manufacturing base.
- Broad vertical coverage → large installed ecosystem of branded Cubes.

## Weaknesses / gaps

- Not a care-pathway or telemedicine company.
- End-user brand belongs to OEM customers; opTricon is mostly invisible to patients.
- Ownership churn (Chembio → Biosynex Technologies → opTricon again) can create partnership ambiguity until contracts are clear.

## Threat level

- **Now:** Medium as **dependency / software baseline** (not as a rival DTC product) — partners can ship Cube + native app without homeDX.
- **12–24 months:** Medium–High if opTricon or large OEMs productize a richer consumer cloud + care pathway on the same SDK.

## Sources

- See [`../sources/2026-07-22-cube-oem-sources.md`](../sources/2026-07-22-cube-oem-sources.md) (accessed 2026-07-22): opTricon about-us, CubePlus pages, Acquisition25, Adlershof news.

## Open questions

- Exact commercial terms / SDK license for homeDX-style accessories.
- Whether first-party APP is positioned for consumers or professionals only.
- Full public list of active OEM brands (many are white-label and undisclosed).
