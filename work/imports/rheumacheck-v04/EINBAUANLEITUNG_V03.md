# HomeDX: Fragebögen einbauen und intern gemeinsam prüfen

Übergabe V03, 12.10.2026. Führender Frageninhalt: V04-R2 vom 07.10.2026, `3.0.0-internal-review.20261007`. 171 Katalogeinträge, alle 159 bisherigen IDs und zwölf Ergänzungen erhalten. Dies ist eine technische und methodische Arbeitsgrundlage für die interne Partnerprüfung, keine medizinische oder produktive Freigabe. V03 ergänzt Einbauorte, Rollenkennzeichnung, direkte lokale Revieweinstiege und heutige Live-Befunde; es kürzt oder ersetzt den Fragenkatalog nicht.

## 1. Zuerst Epirots vorhandene Umsetzung lesen

Bestehenden Code, API, Datenbank, Katalogversion und eigene Änderungen feststellen; nicht blind neue Dateien über die vorhandene Plattform kopieren. Die sichtbare Startseite nennt 1.1.1, aber damit ist die tatsächlich hinterlegte Fragebogenversion nicht identifiziert. `catalogue/questionnaires.de-DE.V04.public.json` ist die eine führende Inhaltsquelle; `FRAGEN_UND_REGELN.json`, Lesefassung, PDF und UI sind Ableitungen.

Das heute geprüfte Originalsystem ist von dieser lokalen Zuarbeit getrennt. Beide Konten wurden erfolgreich angemeldet und erneut angemeldet. Die Fragebogenlisten der Patienten und Ärzte sind leer. B/D werden im Ärzte-Dashboard und C in einem RheumaCheck-Ergebnisdetail angeboten, aber die drei Aufrufe enden in Ladefehlern. Für A und C-FU wurde kein Einstieg gefunden. Aus diesen Befunden folgt nicht, dass der Server keinen Fragebogen besitzt. Fragenwortlaut, Umfang, Pflichtfelder und Speicherung auf dem Originalserver konnten nicht geprüft werden.

## 2. Exakte Einbauorte: Rolle, Zweck und Zeitpunkt

Die Routen unten sind beobachtete Container. Neue Detailrouten sind ein PLAN; Epi kann seine bestehenden äquivalenten Routen erhalten. Keine erfundenen Routen als bereits funktionierende Links ausgeben.

### A - Beschwerden und Vorgeschichte, 45 Einträge

Patientenperspektive: strukturierter Selbstbericht und Gesprächsvorbereitung, kein Diagnosescore. Hauptort: Patientenmenü `Fragebögen` im vorhandenen Container `/questionnaires`. Zusätzlich eine beschriftete Karte auf `/home`: **„Beschwerden und Vorgeschichte - Bogen A“**, Unterzeile „Vor der weiteren Abklärung“. Beginn nicht automatisch aus einem Testergebnis ableiten. Einzelfall-Zuweisung und studienspezifischer Beginn bleiben festzulegen. Vorschlag Detailroute: `/questionnaires/RC-A`.

### B - Der heutige Versorgungspfad, 34 Einträge

Fachanwenderperspektive: derzeitige Abläufe, Übergaben und Versorgungslücken erfassen; keine patientenseitige Krankheitsanamnese und kein Beweis einer Versorgungsverbesserung. Hauptort: `/doctor/questionnaires`; zusätzlicher Einstieg aus `/doctor/dashboard` **„Der heutige Versorgungspfad - Bogen B“**. Der vorhandene B-Einstieg soll denselben Katalog/Status nutzen wie die Liste. Nicht als Pflichtvorstufe zu jeder Patientenbuchung verwenden. Vorschlag Detailroute: `/doctor/questionnaires/RC-B`.

### C - Erfahrung mit HomeDX, 47 unmittelbare Einträge

Patientenperspektive nach konkret erlebter Nutzung. Hauptort: `/questionnaires`, zusätzlich der bereits vorhandene Einstieg im passenden RheumaCheck-Ergebnisdetail und eine fällige Karte auf `/home`. Nicht jede bewertete Komponente wurde nur deshalb genutzt, weil ein Test oder ein Ergebnis existiert. Demo, selbst bedienter Prototyp, Cube, Blutentnahme und Beratung nach tatsächlicher Exposition unterscheiden. Vorschlag Detailroute: `/questionnaires/RC-C`.

### D - Implementierbarkeit und Nutzen, 37 Einträge

Fachanwenderperspektive nach dokumentierter Demonstration/Piloterfahrung. Hauptort: `/doctor/questionnaires`, zusätzliche Karte auf `/doctor/dashboard` **„HomeDX im professionellen Alltag - Bogen D“**. Erwartungen und beobachtete Erfahrungen getrennt halten. Kein klinischer Wirksamkeitsnachweis und keine regulatorische Abstimmung per Meinungsfrage. Vorschlag Detailroute: `/doctor/questionnaires/RC-D`.

### C-FU - Wie ist es weitergegangen?, acht spätere Einträge

Separater Patienten-Follow-up, kein fünfter unmittelbar verpflichtender Bogen und keine starre Fortsetzung von C am selben Tag. In `/questionnaires` erst nach definierter Einladung/Fälligkeit anbieten. Bis dahin verständlicher Status „Noch nicht vorgesehen“; für interne Reviewer unabhängig davon vollständig zugänglich. Zeitpunkt, Einwilligung, Bezugseinheit und Endpunkte festlegen. Historische „4-8 Wochen“ sind nicht beschlossen. Vorschlag Detailroute: `/questionnaires/RC-C-FU`.

## 3. Rollen dürfen nicht aus Namen geraten werden

„Dr. Harald Peter“ kann Patient sein; „Harald Peter“ kann einen Fachzugang bedienen. Die aktive Serverrolle, nicht Titel, Geschlecht, URL allein oder Perspektivfilter, bestimmt Berechtigung und Menüs.

Immer sichtbare Kennzeichnung im Kopf UND Kontobereich: **„Patientenbereich | Dr. Harald Peter“** beziehungsweise **„Ärztebereich | Dr. Harald Peter“**. Haralds Titel bleibt in beiden Rollen derselbe; die Bereichsbezeichnung macht den Unterschied. Patientenbereich mittleres Blau, Fachbereich dunkleres Blau/Teal als zusätzliche Akzentfarbe; Farbe nie als einziges Signal. Im späteren Partnerreview ebenfalls „Interne Fachprüfung“ und Inhalt-/UI-Version zeigen. Forschungszweck und Reviewerrechte sind getrennt von regulären Benutzerrollen.

„Wählen Sie einen Arzt“ bleibt ausschließlich im Patientenablauf. Eigene Sprechzeiten, Arztprofil und Praxisverwaltung gehören in den Fachbereich. Patienten dürfen fremde Arztprofile oder deren Avatare nicht bearbeiten. Rollenwechsel nur ausdrücklich, wenn das Konto beide Rollen besitzt; kein stiller Wechsel durch Titel oder durch offene andere Browser-Tabs.

## 4. Einfache und ehrliche Fragebogenoberfläche

Vorhandenes HomeDX-Design beibehalten: serifenfrei, abgerundete Karten, klare Blau-/Mintakzente, beschriftete Icons, kurze Statusfelder. Unter 850px Navigation einklappbar oder oberhalb des Inhalts statt einer dauerhaft breiten Seitenleiste. Das Original-Ärzte-Dashboard ist bei 390px wegen der ca.272px breiten Sidebar kaum lesbar; die lokale Vorlage vermeidet diese Engstelle.

Eine Karte zeigt Bogen, Zweck, Zielgruppe, Zeitpunkt, Inhaltversion und Status. Zustände unterscheiden: nicht zugewiesen, noch nicht fällig, verfügbar, begonnen, abgeschlossen, neue Version zur Prüfung, technisch nicht ladbar. Leere Liste und Ladefehler nicht als denselben Normalzustand behandeln. Beim Fehler: konkreter Bogen und nicht sensitiver Supportcode, erneuter Versuch, zurück zur Übersicht. Keine Zugangstoken oder Gesundheitsdaten in Fehlermeldungen.

Abschnittsweise Eingabe, nachvollziehbare Pflicht-/Optionalmarkierung, komplett beschriftete Skalen und Matrixzeilen. Zurück und Bearbeiten erhalten gültige Eingaben; Pfadwechsel entfernt nicht mehr zulässige aktive Folgeantworten. „Unbekannt“ nicht als „Nein“ oder Null werten. Zeitbedarf im Pilot messen; bis dahin Abschnitte/antwortabhängige Fragenzahlen zeigen statt erfundenem Countdown. Fortschritt als Abschnittsposition kennzeichnen, „abgeschlossen“ erst nach Prüfung.

Abschluss: freundlicher Dank, eigene prüfbare Antwortübersicht, gegebene Einzelwerte ohne Diagnosefarbe, klarer nächster Schritt und optionaler Export nach freigegebenem Konzept. Keine erfundene Vergleichsstatistik, kein Krankheitsrisiko, kein Gutschein für bestimmte Antworten, kein medizinisches Zertifikat aus einer bloßen Befragung.

## 5. Demo, leere Eingabe und Fachprüfung sauber trennen

`demo/`: ausdrücklich synthetischer Demo-Modus. Der Schalter **„Synthetisches Beispiel vorbefüllen“** befüllt erst nach bewusster Auswahl; anschließend normale Schritte, Pfadprüfung und Abschluss. Keine Vorbefüllung in echten Erhebungen.

`entry-template/`: alle Antworten leer, kein Beispielschalter. Auch diese lokale technische Vorlage ist noch NICHT für reale Gesundheitsdaten freigegeben. Eigene Modi, Exportkennzeichen, UI-Versionen und Speicherkeys bleiben getrennt. Ein Demo-Import in die leere Vorlage wird abgewiesen.

V03 ergänzt direkte lokale Bogeneinstiege und sichtbare Perspektivbeschriftung. Ein URL-Parameter ist nur Navigation, NIE Autorisierung oder Auswahl eines Produktionsmodus. Der spätere Server bestimmt Identität, Rolle, Umfeld und erlaubte Form-ID aus vertrauenswürdiger Konfiguration.

Partnerprüfung: getrennten geschützten Reviewerbereich auf Epirots internem System anbieten; vollständigen Katalog einschließlich normalerweise verborgener Zweige zeigen. Kommentare mit Item-ID, Inhaltversion, UI-Version, Kontext und Status erfassen. `Kommentar` oder `Änderungsvorschlag` ist keine fachliche Abnahme. Die lokale Kommentaransicht hält Kommentare nur im Fenster und bietet eine Exportvorschau, keine automatische Übermittlung. PDF/JSON und Rückmeldungen nur ausdrücklich teilen.

## 6. Technischer Einbauvertrag

`EINBAUORTE_UND_ABNAHME_V03.json` ist der neue ergänzende Mapping-/Testplan. Vorhandene `ROLE_TIME_MAPPING.json`, `INTERFACE_CONTRACT.json` und `PERSISTENZ_UND_READBACK.md` bleiben die Detailbasis. URLs/Serverendpunkte daraus nicht als implementiert behandeln.

Erstens Form-ID und Paketversion exakt verknüpfen. Alle 171 IDs erhalten. Katalogreferenzen und Operatoren validieren; Pflichtangabe nur bei aktiver Sichtbarkeit. Matrix/Rang, optionCodes, exklusiv markierte Optionen und optionSource korrekt behandeln. Keine Heuristik aus Wortlaut und kein ungefragter Gesamtwert.

Zweitens echte Serverantworten nur unter berechtigtem Konto, festgelegtem Zweck und freigegebenem Umfeld speichern. Formversion, runId und Revision führen. Schreibbestätigung durch tatsächliches Lesen derselben Revision kontrollieren; unklare Speicherung nie als „gespeichert“ anzeigen. Reload/Resume, Rollenwechsel, Wiederholungen, Versionskonflikt und Netzverlust testen. Keine Historie still überschreiben.

Drittens Demo-/Produktionsdaten serverseitig isolieren. Synthetische Payloads an realen Erhebungsendpunkten zurückweisen. Keine Kontodaten in Testantworten, keine stillen Analytics-/Form-Uploads. Keine neue Auth-/Datenbankarchitektur allein aufgrund dieser Zuarbeit erzeugen.

Login-Autofill: vorhandene Framework-Implementierung auf konsistente Benutzername-/aktuelles-Passwort-Hinweise und stabile Feldzuordnung prüfen. Beobachtet wurden E-Mail=email, Passwort zunächst off und fokussiert on; allein off ist keine bewiesene Fehlerursache. Nach vollem Seitenaufruf gelangten beide geprüften Rollen zum Login, ohne betätigten Logout; Rollen-/Sitzungswiederaufnahme auf der vorhandenen Plattform untersuchen.

## 7. Fachliche Güte: Nutzen und noch offene Verbesserungen

Die vier Perspektiven decken Selbstbericht, Ausgangsversorgung, Nutzungserfahrung und Implementierbarkeit sinnvoll getrennt ab. V04-R2 ist umfangreich und technisch prüfbar; das ist kein Nachweis medizinischer Relevanz jeder Frage, Validität oder diagnostischer Wirksamkeit.

Vor Patientenbetrieb klären: Population/Erwachsenenscope, Sicherheitsroute, Studienendpunkte und Bezugseinheiten, Einladungszeitpunkte, Zweck/Einwilligungen, Umgang mit sensiblen optionalen Angaben und Freigaben. Die bisherigen deutschen/europäischen Quellenreviews sind Orientierung mit dokumentierten Grenzen, keine DGRh-/EULAR-Abnahme.

Besonders konkret: C03-C05 verlangen im aktuellen Katalog immer Angaben zum Ablauf. Nach bloßer Demonstration kann dies methodisch unpassend sein. Zur Fachentscheidung vorschlagen: nur nach tatsächlich selbst genutzter Komponente zeigen, Wortlaut auf diese Nutzung beziehen; unbekannte Exposition nicht als Nutzung setzen. Diese Variante ist NICHT still in den führenden JSON-Katalog eingearbeitet. B braucht für Wirkungsvergleiche definierte Fall-/Zeitbezüge statt allein erinnerter typischer Wartezeiten. D muss Erwartung von Beobachtung unterscheiden. Strukturiertes Labor-/Medikationsdetail in A erst nach fachlicher Entscheidung erweitern. Keine eigenen Skalen/Scores erfinden.

## 8. Avatare und zwei gleichnamige Arztkarten

In der Patienten-Arztauswahl sind zwei gleichnamige „Dr. Harald Peter, Rheumatologie“-Karten sichtbar, mit verschiedenen Beispielavataren. Beide öffnen Buchungsansichten ohne verfügbare Termine. Sichtbare UI-Knoten-IDs sind keine Backend-Konto-IDs. Dort ist weder Konto-E-Mail noch stabile doctorId sichtbar; linker/rechter Eintrag lässt sich daher nicht sicher dem aktuell verwendeten IMDB-Arztkonto zuordnen. Heute keine Registrierung vorgenommen. Historische doppelte Kontoanlage ist ein Prüfansatz, keine bestätigte Ursache.

Epi soll beide Datensätze anhand stabiler doctorId, zugehöriger Konto-E-Mail, Verifizierungs-/Freigabestatus, Anlagezeit und Referenzen zu Terminen/Antworten unterscheiden. Gewünschtes aktives Profil mit Harald bestätigen, danach überflüssiges Profil zunächst deaktivieren/archivieren, nicht unkontrolliert löschen oder Antworten umhängen. Eine sichere Löschentscheidung fehlt noch.

Im Fachprofil fehlt eine sichtbare Foto-/Avatarbearbeitung. Ergänzung: „Profilbild ändern“ nur für das eigene Arztprofil, Vorschau, erlaubte Dateitypen/Größe, verständliche Validierung, serverseitige Berechtigung und Speicherung; alternativ wählbare generische Illustrationen. Das beigelegte SVG ist nur ein generischer männlicher Demo-Avatar mit dunklen Haaren, kein echtes Portrait Haralds und kein Qualifikationsnachweis. Geschlecht/Stammdaten nicht verändern, um das Bild indirekt zu manipulieren.

## 9. Abnahme in zwei getrennten Stufen

Interner Partnerreview: beide Rollen eindeutig, A/B/C/D/FU kontrolliert erreichbar, Content-/UI-Version sichtbar, sämtliche Zweige lesbar, synthetischer Demo-Modus isoliert, Kommentierung/Export nachvollziehbar und mobile Bedienung geprüft. Der geschützte Partnerlink und Kontofreigaben werden von Epi bestätigt, nicht durch diese lokalen Dateien erzeugt.

Patientenfreigabe zusätzlich: medizinische/methodische Entscheidungen dokumentiert, Datenschutz/Zweck/Einwilligung und regulatorische Abgrenzung entschieden, Serverrollen/Speicherung/Readback/Resume geprüft, Freigaben erteilt. Keine automatische Freischaltung aus einem bestandenen Klicktest ableiten.

## 10. Übergabereihenfolge ohne Doppelarbeit

Epi bekommt die neueste technische Zuarbeit samt Lesefassung und diesen Mapping-/Abnahmeplan. Das getrennte Webseitenfeedback-ZIP enthält Live-Befunde und Screenshots. Er meldet seine vorhandene Katalogversion und die übernommenen Deltas, statt parallel eine zweite Plattform zu bauen. Nach seiner Reparatur gezielt dieselben Aufrufe wiederholen; erst dann Fragenstand und Serverdurchläufe vergleichen. Der öffentliche Netlify-Demostand bleibt unverändert; V03 ist lokal vorbereitet, nicht hochgeladen oder versandt.

Technische Primärquellen zum Autofill: https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Attributes/autocomplete ; https://api.flutter.dev/flutter/material/TextField/autofillHints.html ; https://api.flutter.dev/flutter/widgets/AutofillGroup-class.html . Ein Framework ist erst nach Einsicht in Epirots Projektcode verbindlich festgestellt.
