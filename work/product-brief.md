# homeDX — product brief (for non-code work)

Short product context for market, roadmap, partnerships, brand, and other project work outside the codebase. For engineering detail see [`README.md`](../README.md) and [`docs/`](../docs/).

## One-liner

homeDX is a **software accessory** to the **Cube** rapid-test reader: a mobile (and web) app plus backend that connects to the Cube over Bluetooth, captures on-device measurement results, stores them, and shows them to the user—with **telemedicine** (specialist booking + online video via Daily.co), payments, licenses, certificates, and related platform features.

## What we sell / deliver (product shape)

- **Hardware partner:** Cube IVD/medical device (reader); homeDX does not replace the Cube’s on-device evaluation.
- **Client:** Flutter app (`frontend/mobile/hdx_mobile/`) — Android primary for Cube Bluetooth; also web/desktop targets where relevant (including doctor portal for appointments/video).
- **Backend:** NestJS API + PostgreSQL — auth, rapid tests, Cube result submission, doctor appointments and Daily.co video tokens, payments (Stripe/PayPal), licenses, kits, certificates, notifications, legal pages, uploads.
- **Telemedicine:** After a **positive** result, the user can book a matching specialist (Facharzt) by test type and join an online consultation (Daily.co). Doctors manage availability and join calls via the doctor web flows.

## Core user journey (market-relevant)

1. User pairs phone ↔ Cube (Bluetooth; pairing PIN = last six digits of Cube serial when prompted).
2. User runs a measurement; Cube SDK evaluates **on device**.
3. App reads results and submits normalized data to the backend.
4. Backend stores a rapid-test record; app displays results (and related flows: paywall/licenses, certificates, etc.).
5. **If the result is positive:** user is offered to book a specialist appointment (matched by test → medical specialization); online video call runs through Daily.co (patient app + doctor side).

## Positioning anchors (fill in over time)

- **Category:** Home / near-patient rapid testing software accessory (Cube ecosystem) **plus care pathway** (test → specialist teleconsult)—not a standalone lab analyzer and not a full general telemedicine marketplace.
- **Regulatory class (draft only):** see [`../docs/regulatory/classification-draft.md`](../docs/regulatory/classification-draft.md) — primary regime **IVDR**, working draft **Class C** for RheumaCheck-style markers; MDR Rule 11 **analogy Class IIa** if that framing applies. Requires PRRC sign-off before any CE claim.
- **Geography focus:** EU / Germany regulatory context matters (IVDR/MDR accessory framing, MPDG, health data; telemedicine/practice rules may apply separately). See regulatory docs; do not invent clinical or CE claims in market or brand copy without review.
- **Differentiators (draft — validate with evidence):** Cube software platform (account, history, payments, certificates) **and** positive-result → Facharzt video consult vs. bare device usage or result-only apps.

## Capabilities to cite carefully

Safe to describe at a high level when true in product:

- Bluetooth Cube connect / measure / display results
- Cloud-backed test history via backend
- Positive result → book matching specialist → online video consult (Daily.co)
- Doctor-side appointment / availability / join-call flows
- Payments and licensing for access
- Certificates / related documents (as implemented)

Avoid claiming:

- That the app itself performs the diagnostic measurement (Cube does evaluation on-device)
- That a video consult replaces in-person care, diagnosis, or treatment where that is not true or not reviewed
- Unverified clinical performance, sensitivity/specificity, or disease claims
- Regulatory status (CE, notified body outcomes) unless sourced and approved

## Open questions

Track deeper work under the folders in [`README.md`](README.md)—e.g. [`strategy/`](strategy/), [`roadmap/`](roadmap/), [`partnerships/`](partnerships/):

- Target segments (consumers, clinics, pharmacies, B2B kits)?
- Geographic rollout priority?
- Pricing / license model?
- Moat: device lock-in, software UX, partnerships, data/compliance?

## Related repo pointers

- Architecture sketch: [`../README.md`](../README.md)
- Feature matrix: [`../docs/APP_FUNCTIONALITIES.md`](../docs/APP_FUNCTIONALITIES.md)
- Appointments & Daily.co video: [`../docs/APPOINTMENTS_VIDEO.md`](../docs/APPOINTMENTS_VIDEO.md)
- Regulatory engineering guardrails: [`../docs/regulatory/`](../docs/regulatory/)
