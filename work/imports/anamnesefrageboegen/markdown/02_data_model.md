# Datenmodell und Variablenlogik

## Grundprinzipien

Jede Antwort sollte mindestens folgende Metadaten enthalten:

- `submission_id`: UUID
- `module_id`: A, B, C oder D
- `module_version`: z. B. `6.2`
- `respondent_type`: patient, physician, rheuma_network_member, staff, test_user
- `created_at`, `updated_at`
- `language`: de-DE
- `consent_status`: yes/no/withdrawn/not_applicable
- `answers`: Objekt mit Feld-IDs und Werten

## Variable IDs

Variable IDs sollten stabil, kurz und sprechend sein:

- `A_symptom_duration`
- `A_morning_stiffness_duration`
- `B_wait_rheumatology_weeks`
- `C_result_understood`
- `D_pilot_willingness`

Keine Umlaute oder Leerzeichen in IDs verwenden.

## Antwortformate

- `single_choice`: genau eine Antwort
- `multi_choice`: mehrere Antworten
- `likert_5`: 1 = stimme gar nicht zu, 5 = stimme voll zu
- `nrs_0_10`: numerische Skala 0–10
- `number`: numerischer Wert
- `text`: Freitext
- `date`: Datum
- `conditional_group`: Fragenblock mit Sichtbarkeitsregel

## Export

CSV: eine Zeile pro Submission, Spalten pro Variable.  
JSON: vollständige strukturierte Rohdaten inklusive Labels, Version und Branching-Historie.
