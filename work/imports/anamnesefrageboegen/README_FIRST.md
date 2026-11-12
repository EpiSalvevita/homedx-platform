# RheumaCheck / HomeDX – Zusatzpaket für Online-Fragebögen V6.2

Dieses Zusatzpaket ist als technischer Übergabeanhang für die Umsetzung der RheumaCheck-Fragebögen im HomeDX-System gedacht.

Es ergänzt das fachliche Paket `2026_05_11_RheumaCheck_Fragebogenpaket_V6_Final_QA_und_Gesamtpaket.zip`.

## Zweck

Die Dateien sollen Epi / salvevita helfen, aus dem fachlichen Fragebogenpaket eine benutzerfreundliche Online-Umsetzung zu planen:

- datengetriebene Online-Fragebögen für vier Module A–D,
- digitale Sprunglogik,
- Pflicht-/Optionalfelder,
- Export nach CSV/JSON,
- spätere Anbindung an HomeDX/App/CUBE/Terminlogik,
- klare Trennung von Patienten- und Ärzte-/Rheumanetzwerk-Fragebögen.

## Wichtigste fachliche Struktur

- **Bogen A**: Patient:innen-Vorab-Anamnese und Stratifizierung
- **Bogen B**: Rheumanetzwerk-/Ärzteumfrage zur Standardmethode und zum Versorgungspfad
- **Bogen C**: Patient:innen-Usability, Ergebnisverständnis und Versorgungsnutzen nach Nutzung
- **Bogen D**: Ärztliche Implementierbarkeit und erwarteter Nutzen

## Empfohlene Nutzung durch Entwickler

1. Zuerst `markdown/01_implementation_overview.md` lesen.
2. Dann `data/rheumacheck_questionnaires_v6_2.forms.json` als strukturierte Ausgangsbasis prüfen.
3. **Fachliche Master-Dateien** in `source/` (PDF/Word) für QA, Copy-Review und regulatorische Abnahme — nicht für die laufende App.
4. Danach den Prompt `prompts/cloud_code_masterprompt.md` in Cloud Code verwenden.
5. Die Checkliste `checklists/acceptance_criteria.md` als Abnahme-/QA-Grundlage nutzen.

## `source/` — fachliches Fragebogenpaket (PDF + Word)

Vom Team abgelegte Originaldokumente (V6.1/V6.2). Die **Online-App** liest `data/*.forms.json`; die Dateien hier dienen als menschenlesbare Referenz:

| Datei | Inhalt |
|-------|--------|
| `*_BogenA_*` | Patienten-Anamnese / Stratifizierung (Modul A) |
| `*_BogenB_*` | Rheumanetzwerk Standardmethode (Modul B) |
| `*_BogenC_*` | Patienten Usability / Versorgungsnutzen (Modul C) |
| `*_BogenD_*` | Ärztliche Implementierbarkeit (Modul D) |
| `*_Gesamtpaket_V6_2.*` | Gesamtpaket V6.2 |
| `*_Finaler_QA_Durchgang.*` | Finaler QA-Durchgang |
| `*_Audit_Bestandsabgleich_ToDo.*` | Bestandsabgleich / offene Punkte |
| `*_Roter_Faden_V6_2.*` | Roter Faden / Gesamtlogik |
| `RheumaCheck_Fragebogenarchitektur_V6_*` | Architektur, Quellen, Konzept |

**Hinweis:** Einzelbögen sind teils als **V6.1** benannt, die JSON-Definition ist **v6.2** — bei Abweichungen gilt die JSON für die App, bis ein bewusstes Update erfolgt; PDF/Word für fachliche Klärung heranziehen.

## Hinweis

Dieses Paket ist eine technische Arbeitsgrundlage, keine finale regulatorische Spezifikation und kein Medizinprodukt-Konzept. Medizinische, datenschutzrechtliche und regulatorische Prüfung müssen vor produktiver Nutzung separat erfolgen.
