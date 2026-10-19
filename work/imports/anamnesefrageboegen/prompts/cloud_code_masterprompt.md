# Cloud-Code-Masterprompt: HomeDX Online-Fragebögen RheumaCheck V6.2

Du arbeitest im HomeDX-Codebestand. Ziel ist, die RheumaCheck-Fragebögen V6.2 als benutzerfreundliche Online-Fragebögen umzusetzen.

## Ausgangsdateien

Nutze zuerst:

- `data/rheumacheck_questionnaires_v6_2.forms.json`
- `data/rheumacheck_questionnaires_v6_2.schema.json`
- `markdown/01_implementation_overview.md`
- `markdown/03_branching_logic.md`
- `checklists/acceptance_criteria.md`

Das fachliche Vollpaket liegt separat vor: `2026_05_11_RheumaCheck_Fragebogenpaket_V6_Final_QA_und_Gesamtpaket.zip`.

## Arbeitsweise

1. Inspiziere zuerst den bestehenden HomeDX-Codebestand: Framework, Routing, Formularlogik, Styling, Persistenz, API.
2. Implementiere nicht hartcodiert, sondern datengetrieben aus JSON, soweit sinnvoll.
3. Baue eine Startseite mit Rollenwahl:
   - Patient:in
   - Ärzt:in / Rheumanetzwerk
   - Demo/Testmodus
4. Erzeuge für jedes Modul A–D eine eigene Route oder Tab-Struktur.
5. Implementiere Antworttypen:
   - single_choice
   - multi_choice
   - likert_5
   - nrs_0_10
   - number
   - text
   - conditional_group
6. Implementiere einfache Sprunglogik nach den `show_if`-Regeln.
7. Speichere pro Submission die Modulversion und alle Antworten.
8. Ergänze Export nach JSON und perspektivisch CSV.
9. Baue zunächst keine medizinische Diagnose- oder Priorisierungsautomatik.
10. Achte auf Datenschutz-Hinweis und Demo-Modus.

## Qualitätsziel

Die Umsetzung soll für eine interne Demo und Abstimmung mit IMDB/salvevita/IKB geeignet sein. Produktive Nutzung erst nach fachlicher, datenschutzrechtlicher und ggf. regulatorischer Prüfung.

## Akzeptanzkriterien

- Alle vier Module A–D sind auswählbar.
- Alle Pflichtfelder werden geprüft.
- Sprunglogik funktioniert mindestens für die in `03_branching_logic.md` beschriebenen Kernfälle.
- Export enthält stabile Variable-IDs.
- Nutzer sieht keine technischen IDs.
- Keine Tabellen oder Texte laufen mobil aus dem Viewport.
- Patiententexte sind verständlich und nicht alarmistisch.
- Ärztetexte sind präzise und auswertbar.
