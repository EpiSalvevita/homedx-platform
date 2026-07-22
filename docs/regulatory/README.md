# Regulatory Documentation (homeDX)

This folder is the intended home for homeDX's regulatory documentation
references under EU MDR/IVDR and German MPDG. It is a stub scaffold, not a
completed technical file — see the disclaimer below.

See [`.cursor/rules/mdr-compliance.mdc`](../../.cursor/rules/mdr-compliance.mdc)
for the coding-agent guardrails that reference this folder, and for the
open classification question (MDR vs IVDR vs DiGA) that must be resolved by
a qualified regulatory affairs professional before any of the documents
below are considered authoritative.

## Intended contents (to be populated)

- **Software Requirements Specification (SRS)** — what the homeDX
  backend/mobile app is required to do, and to whom it belongs (accessory
  vs standalone software scope).
- **Risk management file** (ISO 14971) — hazard analysis for result
  display, Cube data handling, and certificate generation.
- **Traceability matrix** — linking requirements, risk controls, design,
  and test evidence (IEC 62304).
- **Usability engineering file** (IEC 62366-1) — use-related risk analysis
  for result screens, status indicators, and certificate content.
- **SOUP list** — third-party/open-source dependencies (npm, pub packages)
  with version and known-issue tracking.
- **Post-market surveillance log** — bug reports and incidents that
  affected a result or certificate already shown to a user.

## Status

No SRS, risk file, traceability matrix, or usability file exist yet.
Populating them requires a qualified Person Responsible for Regulatory
Compliance (PRRC) and, where applicable, alignment with the Cube device
manufacturer's Quality Management System — not just engineering effort.

Two documents do exist:

- [`gap-assessment.md`](./gap-assessment.md) — an AI-agent-produced,
  code-only scan of what evidence for the items above is currently present
  or missing in this repository, including an update on which engineering
  gaps have since been closed. It is a starting point for a real review,
  not a substitute for one (see its own disclaimer).
- [`soup-list.md`](./soup-list.md) — a generated inventory of backend/mobile
  dependencies. It's a snapshot, not a maintained process (see its own
  "known gaps" section).
- [`questionnaire-submissions-v1.md`](./questionnaire-submissions-v1.md) —
  regulatory note for RheumaCheck Anamnesefragebögen A–D (capture-only v1):
  health data scope, risk table, test evidence, PRRC sign-off guidance.
- [`classification-draft.md`](./classification-draft.md) — **draft** IVDR/MDR
  class call for the RheumaCheck + telemedicine pathway (working draft:
  IVDR Class C; MDR Rule 11 analogy Class IIa). Requires PRRC approval.
