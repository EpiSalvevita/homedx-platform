# Digitale Sprunglogik / Branching

## Bogen A – Patient:innen-Vorab-Anamnese

- Wenn `A_joint_pain = nein`, dann reduzierte Kurzroute anzeigen und prüfen, ob der Bogen überhaupt passt.
- Wenn `A_morning_stiffness = ja`, dann Dauer abfragen.
- Wenn kleine Hand-/Fußgelenke betroffen sind, dann Detailblock zu Händen/Füßen anzeigen.
- Wenn Laborwerte bekannt sind, dann RF/Anti-CCP/CRP/BSG abfragen; sonst überspringen.
- Wenn starke Einschränkung oder sehr hoher Schmerz angegeben wird, optional Hinweis anzeigen: „Bitte ärztlich abklären lassen.“ Keine Diagnose formulieren.

## Bogen B – Standardmethode / Versorgungspfad

- Wenn Befragte:r Hausarztpraxis ist, Fokusfragen zu Erstkontakt, Basislabor, Überweisung anzeigen.
- Wenn Rheumatologie/Klinik, Fokusfragen zu Vorselektion, Terminpriorisierung, Befundqualität anzeigen.
- Wenn keine Wartezeitangabe möglich, stattdessen Schätzbereich abfragen.

## Bogen C – Usability nach Nutzung

- Wenn App nicht genutzt wurde, App-spezifische Fragen überspringen.
- Wenn Test nicht selbst durchgeführt wurde, Handling-/Blutentnahme-Fragen als „nicht zutreffend“ behandeln.
- Wenn Ergebnis nicht angezeigt wurde, Ergebnisverständnis-Fragen überspringen und Abbruch-/Fehlergrund erfassen.

## Bogen D – Ärztliche Implementierbarkeit

- Je nach Fachgebiet unterschiedliche Detailfragen priorisieren:
  - Hausarzt: Früherkennung, Überweisung, Workflow.
  - Rheumatologie: Vorselektion, Testgüte, klinische Plausibilität.
  - Klinik/Ambulanz: Triage, Terminsteuerung, Schnittstellen.
  - Labor/Diagnostik: Präanalytik, Ergebnisformat, Qualitätsanforderungen.
