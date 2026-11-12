# Implementierungsübersicht HomeDX / RheumaCheck V6.2

## Modulübersicht

| Modul | Zielgruppe | Zeitpunkt | Zweck |
|---|---|---|---|
| A | Patient:innen | vor Test / vor Prozessstart | Vorab-Anamnese, Symptomprofil, Stratifizierung |
| B | Ärzt:innen / Rheumanetzwerk | vor oder parallel zur Pilotierung | Standardmethode, Versorgungspfad, Verzögerungen |
| C | Patient:innen / Testnutzer:innen | nach Nutzung von Test/App/Workflow | Usability, Ergebnisverständnis, Vertrauen, Nutzen |
| D | Ärzt:innen / Versorgungsakteure | vor oder während Pilotierung | erwarteter Nutzen, Implementierbarkeit, Evidenzbedarf |

## Empfohlene technische Umsetzung

- Ein datengetriebenes Formularsystem verwenden: Fragebögen werden aus JSON/Schema gerendert.
- Antworttypen standardisieren: Single Choice, Multiple Choice, Likert, NRS 0–10, Freitext, Datum/Zeitraum.
- Jede Frage erhält eine stabile Variable-ID.
- Jede Antwort muss mit Modulversion gespeichert werden, z. B. `module=A`, `version=6.2`.
- Exportformate: CSV für schnelle Auswertung; JSON für vollständige Rohdaten; optional später API/FHIR-kompatible Ableitung.

## Empfohlene Nutzerführung

Startseite:

1. „Ich bin Patient:in“ → Bogen A oder C
2. „Ich bin Ärzt:in / Mitglied des Rheumanetzwerks“ → Bogen B oder D
3. „Ich teste nur die Demo“ → Demo-Modus ohne produktive Speicherung

## Priorisierung

1. Bogen A und B zuerst als klickbare Prototypen.
2. Bogen C aktivieren, sobald ein Test-/App-Workflow real oder simuliert genutzt wird.
3. Bogen D für ärztliche Pilot-/Netzwerkbefragung nutzen.
