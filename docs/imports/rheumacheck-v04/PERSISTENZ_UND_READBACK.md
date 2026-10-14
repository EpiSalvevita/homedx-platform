# Persistenz, Reload und Readback – HomeDX-Übergabe V03

Status IST / PLAN / OFFEN getrennt. Kein implementierter Serveradapter.

## IST: lokale Vorlagen

Nur synthetische Daten. Ohne Opt-in Arbeitsspeicher. Bei Opt-in getrennte
localStorage-Keys je Variante, nach jeder Änderung versionsmarkierter Snapshot.
Nach `setItem` erfolgt `getItem`, Schema-/Modusprüfung und Vergleich der tatsächlich
gelesenen Entwürfe mit den geschriebenen Entwürfen. Erst danach wird „gespeichert“
angezeigt. Sperr-/Quota-/Readbackfehler deaktivieren automatische Speicherung und
lassen den aktuellen RAM-Entwurf bestehen; JSON-Export bleibt als Alternative.

Reload zerstört RAM-Daten, nicht bestätigte Browserdateien. Gespeicherte Daten
werden auf der Startauswahl angeboten und erst über eine ausdrückliche Import-
bestätigung wieder geladen. Kommentare werden separat behandelt, nicht automatisch
mitgespeichert. Deaktivieren löscht nur den eigenen Key; bei gesperrtem Speicher
keine bestätigte Löschung behaupten. Heruntergeladene Dateien bleiben beim Nutzer.
Ein Backup-Import kann kein Patientenregister freischalten und keinen Moduswechsel
von Demo nach echter Erhebung autorisieren.

## PLAN: neutraler Adapter für Epirots Test-/Produktionssystem

Keine erfundenen HTTP-Endpunkte, Tabellen oder Frameworkdateien. Die folgenden
Operationen werden an seine vorhandene Architektur angepasst:

1. `createRun`: Server ordnet autorisierten Nutzer, Rolle, Kontext, Formular-ID,
   Inhalts-/UI-/Schemaversion und Test/Produktionsumgebung zu. Neue runId serverseitig
   erzeugen; Subject-/Studienzuordnung nur nach Zweck-/Datenschutzentscheidung.
2. `saveDraft`: runId, clientRevision, idempotencyKey und versionierter Antwortpatch.
   Server prüft Authentifizierung, Eigentümerschaft/Rolle, Kontext und Datenmodus.
   Clientangaben zu Rolle/Subject/Produktionsmodus niemals allein vertrauen.
3. `readRun`: nach erfolgreichem Schreibversuch gespeicherten Stand über denselben
   autorisierten Lesepfad abrufen. runId, Formular-/Inhaltsversion, serverRevision
   und kanonische Antworten vergleichen. Nicht nur Toast oder HTTP-Status prüfen.
4. `finalizeRun`: separate, idempotente Abschlussoperation; Server berechnet aktive
   Fragen neu und prüft sichtbare Pflichtfelder, Werte und Sicherheitsstopps.
   Abschluss bestätigt weder medizinische Validität noch diagnostische Wirksamkeit.
5. `deleteOrWithdraw`: Verfahren, Rechte, Aufbewahrung und Forschungsfolgen vorher
   festlegen. Keine automatischen Löschfristen oder rechtsverbindlichen Zusagen erfinden.

## PLAN: Minimalmetadaten und Zustände

Erforderliche technische Identität: runId, packageId, packageVersion,
questionnaireId (RC-A/B/C/D/C-FU), questionnaireVersion, schemaVersion, uiBuild,
environmentMode, serverRevision. Zusätzlich zulässige Studien-/Subjectzuordnung,
Einwilligungsbezug und Zeitereignisse nach fachlichem/Datenschutzkonzept entscheiden.
Keine Namen/E-Mail-Adressen als alleinige Forschungskennung verwenden.

Clientzustände: dirty, saving, saved_pending_readback, saved_verified,
save_failed, conflict, offline. Nur saved_verified darf zuverlässig „gespeichert“
anzeigen. Abschlusszustand und Ablagezustand getrennt: „Bogen abgeschlossen“ ist
ohne bestätigten Server-Readback kein Nachweis einer abgelegten Forschungsantwort.

## PLAN: Fehler und Retry

Timeout/Offline: Entwurf erhalten, sichtbarer Fehlhinweis, keine Erfolgsmeldung;
begrenzter Retry mit demselben idempotencyKey und ansteigender Wartezeit. Konkrete
Grenzen in Epirots Implementierung festlegen, keine Endlosschleife.
401: Anmeldung erforderlich, nicht immer wieder blind senden.
403: Zugriff verweigert; Rechte nicht für Bequemlichkeit umgehen.
409/Revisionskonflikt: aktuelle Serverrevision lesen, Änderungen vergleichen,
kontrolliertes Zusammenführen oder Nutzerentscheidung; kein Last-write-wins ohne Plan.
Ungültige Version/Schema: stoppen und konkrete Änderung/Migration erfragen.
Doppelter Abschluss mit gleichem Schlüssel: derselbe Run, kein zweiter Datensatz.
Browser-Sperre/Quota: kein unverschlüsseltes Patientendatenbackup als automatische
Ausweichlösung; für echte Daten zulässige Offlinehaltung gesondert entscheiden.

## PLAN: belastbarer Server-Abnahmetest

Nur autorisierte synthetische Testdaten in der getrennten Testumgebung.
Neuen A-Run erzeugen, 0-Skala plus leere freiwillige Angabe schreiben, serverRevision
merken. Leseoperation ausführen und Feld für Feld vergleichen. Browser neu laden,
erneut anmelden/Resume wählen, denselben Run wieder lesen; keine zweite runId.
Mit anderer nicht berechtigter Testrolle Zugriff verweigert sehen. Elternantwort
ändern, abhängige aktive Felder verschwinden; gespeicherte Revision nachvollziehbar.
Netzwerkunterbrechung/Retry/Doppelklick simulieren: kein Datenverlust/Duplikat.
Ergebnis mit exakter Build-/Formversion und Soll/IST dokumentieren.

## OFFEN

Es gibt in diesem Paket keine Datenbankcredentials, kein API-URL und keine echten
Auth-/Rollenentscheidungen. SQL-/ORM-Modell, Endpunkte, Speicherung, Exportrechte,
Einwilligung, Aufbewahrung, Logging und Ereignisexposition entscheidet das Projekt
mit Epi. Serverseitige Tests sind NICHT bereits bestanden.
