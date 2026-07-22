# Draft classification — homeDX software (IVDR / MDR Rule 11 mapping)

**Date:** 2026-07-22  
**Status:** **Engineering draft for PRRC / regulatory affairs — not a CE certificate, not a Notified Body opinion, not legal advice.**  
**Intended purpose used for this draft** (product owner framing): homeDX is an accessory software platform to the Cube rapid-test reader. Its most clinically intrusive loop is: run a Cube assay (e.g. RheumaCheck / rheumatoid-arthritis–related markers) → display the Cube-computed result → on **positive**, offer booking of a matching specialist and an online video consult (Daily.co). The app does **not** perform on-device optical evaluation (Cube SDK does); after the 2026-07-22 fix it must not invent POSITIVE/NEGATIVE from numeric thresholds.

---

## 1. Which regulation?

| Question | Draft answer | Why |
|----------|--------------|-----|
| Is the core purpose *in vitro* diagnostic (examining specimens / presenting IVD results)? | **Yes → IVDR (EU) 2017/746 is the primary regime** | Rapid-test / Cube result path is IVD-adjacent by definition. MDR Art. 1(6)(f) excludes devices covered by IVDR. |
| Does “MDR Class IIa / IIb” apply literally? | **Only if a qualified person concludes part of homeDX is MDR MDSW** (e.g. care-pathway software with a medical purpose *outside* IVDR) | IVDR uses **Classes A–D**, not I / IIa / IIb / III. Teams often say “2a/2b” as shorthand for MDR Rule 11 — map carefully. |
| Is video-call-only a medical device? | **Usually no**, if it only provides communication | Telemedicine *alone* is typically not CE-marked as MDR/IVDR; coupling to IVD results + specialty routing is what triggers device analysis. |

**Germany:** MPDG applies alongside the EU regulations; BfArM is the competent authority. DiGA is a separate pathway and is **not** assumed here.

---

## 2. Qualification (is it a device / accessory at all?)

**Draft qualification:** homeDX backend + mobile app qualify as **software that is an accessory to an IVD** (the Cube reader + assays), and/or **IVD medical device software (MDSW)** insofar as it presents assay results used in a diagnostic pathway.

- Accessories are **classified in their own right** (IVDR Annex VIII implementing rules), separately from the Cube hardware.
- Software that **drives or influences** an IVD is typically same class as that device; software **independent** of another device is classified on its own intended purpose (MDCG 2019-11 / IVDR Annex VIII 1.4).
- homeDX primarily **receives Cube-computed classes** and displays/stores them. That supports an **accessory / display+pathway** story — **provided** the app does not re-interpret raw signals (numeric inventing of POS/NEG was a conformity risk and is removed).

---

## 3. IVDR class (primary draft call)

**Working draft: IVDR Class C** for the IVD-related software functions tied to RheumaCheck / similar disease-marker assays.

| Factor | Reasoning |
|--------|-----------|
| Intended purpose | Present qualitative (and related) results from Cube assays used in assessing rheumatoid / autoimmune–related markers, then route positives into specialist care. |
| Risk to individual | False negative → delayed rheumatology care; false positive → unnecessary anxiety / consult (mitigated by physician). Not typical Class D (life-threatening transfusion/HIV-style public-health catastrophic). |
| Rule family (indicative) | Disease-marker / serious-condition IVDs commonly land in **Class C** under IVDR Annex VIII Rule 3-type logic; exact rule indent depends on assay IFU and Cube manufacturer documentation. |
| Accessory note | If PRRC proves homeDX **only** displays Cube output with no independent medical purpose, class may track Cube assay class or a lower accessory analysis — **still PRRC-owned**. Default engineering stance: treat as **at least Class B, draft Class C** until Cube assay class + intended purpose statement are locked. |

**Not Class D** on current product story (no blood-screening / high public-health catastrophic IVD purpose described).  
**Not Class A** (not general lab equipment / reagent-only).

**IEC 62304 software safety class (parallel, not CE class):** draft **Class B** (injury possible from wrong result / missed follow-up); escalate to **C** only if PRRC judges serious injury/death plausible from software failure modes for these assays.

---

## 4. MDR Rule 11 mapping (if someone asks “IIa or IIb?”)

If — and only if — regulatory affairs frames (part of) homeDX under **MDR** as MDSW that “provides information used to take decisions with diagnosis or therapeutic purposes” (Annex VIII Rule 11):

| Call | Draft |
|------|--------|
| **Recommended analogy: Class IIa** | Default Rule 11 bucket for diagnostic/therapeutic decision information. Clinician remains in the loop via scheduled video consult; app does not autonomously prescribe treatment or declare emergency triage. |
| **When it would become Class IIb** | If intended purpose claims the software’s output can cause **serious deterioration of health** or drive **surgical intervention** without adequate HCP control — e.g. autonomous urgency triage, treatment recommendations, or “do not see a doctor” advice based on negative results. |
| **Class III** | Not indicated for current RA rapid-test + specialist booking story (no death/irreversible deterioration as the software’s intended decision impact). |

**Telemedicine CTA “Empfohlen: Facharzt …”** is borderline decision-support wording. Keep it as **booking assistance** with clear non-diagnostic disclaimer, or PRRC may push the MDR Rule 11 analysis harder (still usually IIa if HCP decides).

---

## 5. What this draft does *not* certify

- CE marking, Notified Body certificate, or EUDAMED registration.
- Cube hardware / assay classification (owned by Cube manufacturer’s technical file).
- That homeDX is “only” an accessory forever — adding AI interpretation, thresholds, or autonomous triage would **re-open** qualification and class.
- DiGA listing or reimbursement status.

---

## 6. Required human lock-in (before claiming conformity)

1. Named **PRRC** and software **manufacturer of record**.
2. Written **intended purpose** (DE/EN) aligned with IFU / labeling.
3. Cube manufacturer confirmation of assay class + whether homeDX is listed as accessory in their file.
4. Final class: **IVDR A/B/C/D** (and MDR class only if dual-regime).
5. Update this file’s status from “draft” to “approved” with date and signatory.

---

## Related

- Guardrails: [`.cursor/rules/mdr-compliance.mdc`](../../.cursor/rules/mdr-compliance.mdc)
- Gap scan: [`gap-assessment.md`](./gap-assessment.md)
- Product brief: [`../../work/product-brief.md`](../../work/product-brief.md)
- Appointments/video: [`../APPOINTMENTS_VIDEO.md`](../APPOINTMENTS_VIDEO.md)
