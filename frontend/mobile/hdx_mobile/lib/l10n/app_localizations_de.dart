// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get payFailed => 'Zahlung fehlgeschlagen';

  @override
  String get payCancelled => 'Zahlung wurde abgebrochen';

  @override
  String get cardPaymentTitle => 'Kreditkartenzahlung';

  @override
  String get processing => 'Wird verarbeitet…';

  @override
  String get payButton => 'Bezahlen';

  @override
  String get amountDue => 'Zu zahlender Betrag:';

  @override
  String get cardStripeNotice =>
      'Kartendaten werden sicher über Stripe eingegeben. Ihre App verarbeitet keine Kartennummern direkt.';

  @override
  String get paypalNotConfirmed =>
      'PayPal-Zahlung konnte nicht bestätigt werden';

  @override
  String paypalWebViewError(String description) {
    return 'WebView-Fehler: $description';
  }

  @override
  String get paypalOrderFailed =>
      'PayPal-Bestellung konnte nicht erstellt werden';

  @override
  String get paypalTitle => 'PayPal-Zahlung';

  @override
  String get paySuccess => 'Zahlung erfolgreich';

  @override
  String get orderConfirmed =>
      'Ihre Bestellung wurde bestätigt. Sie erhalten eine Bestätigung in der App.';

  @override
  String paymentFailedWith(String error) {
    return 'Zahlung fehlgeschlagen: $error';
  }

  @override
  String get paypalSuccess => 'PayPal-Zahlung erfolgreich';

  @override
  String get paypalCancelled => 'PayPal-Zahlung abgebrochen';

  @override
  String paypalFailedWith(String error) {
    return 'PayPal-Zahlung fehlgeschlagen: $error';
  }

  @override
  String get sepaStarted => 'SEPA-Überweisung gestartet';

  @override
  String get sepaStartedSubtitle =>
      'Bitte überweisen Sie den Betrag innerhalb von 3–5 Werktagen. Ihre Bestellung bleibt bis dahin reserviert.';

  @override
  String get copiedToClipboard => 'Bankverbindung in Zwischenablage kopiert';

  @override
  String get sepaConfirmTitle => 'SEPA-Überweisung bestätigen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get sepaTitle => 'SEPA-Überweisung';

  @override
  String get bankDetails => 'Bankverbindung';

  @override
  String get ibanLabel => 'IBAN:';

  @override
  String get copy => 'Kopieren';

  @override
  String get bicLabel => 'BIC:';

  @override
  String get accountHolderLabel => 'Kontoinhaber:';

  @override
  String get referenceLabel => 'Verwendungszweck:';

  @override
  String get bankDetailsOptional => 'Ihre Bankverbindung (optional)';

  @override
  String get bankDetailsOptionalNote =>
      'Diese Angaben sind optional und werden nur für Ihre Referenz gespeichert.';

  @override
  String get ibanOptional => 'IBAN (optional)';

  @override
  String get invalidIban => 'Ungültige IBAN';

  @override
  String get bicOptional => 'BIC (optional)';

  @override
  String get invalidBic => 'Ungültiger BIC';

  @override
  String get accountHolderOptional => 'Kontoinhaber (optional)';

  @override
  String get confirmTransfer => 'Überweisung bestätigen';

  @override
  String get sepaConfirmBody =>
      'Bitte überweisen Sie den Betrag innerhalb von 3-5 Werktagen auf das angegebene Konto. Verwenden Sie die Zahlungs-ID als Verwendungszweck.';

  @override
  String get sepaNotice =>
      'Bitte überweisen Sie den Betrag innerhalb von 3-5 Werktagen. Verwenden Sie die Zahlungs-ID als Verwendungszweck, damit wir Ihre Zahlung zuordnen können.';

  @override
  String get amountLabel => 'Betrag:';

  @override
  String get methodCard => 'Kreditkarte';

  @override
  String get methodBankTransfer => 'Banküberweisung';

  @override
  String get methodCrypto => 'Krypto';

  @override
  String get paymentGeneric => 'Zahlung';

  @override
  String get statusCompleted => 'Abgeschlossen';

  @override
  String get statusPending => 'Ausstehend';

  @override
  String get statusFailed => 'Fehlgeschlagen';

  @override
  String get statusRefunded => 'Erstattet';

  @override
  String get statusCancelled => 'Storniert';

  @override
  String get statusUnknown => 'Unbekannt';

  @override
  String get paymentsTitle => 'Zahlungen';

  @override
  String get paymentsOverview => 'Übersicht Ihrer Zahlungen und Bestellungen.';

  @override
  String get paymentsLoadError => 'Zahlungen konnten nicht geladen werden';

  @override
  String get checkConnectionRetry =>
      'Bitte prüfen Sie Ihre Verbindung und versuchen Sie es erneut.';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get noPaymentsTitle => 'Noch keine Zahlungen';

  @override
  String get noPaymentsMessage => 'Abgeschlossene Zahlungen erscheinen hier.';

  @override
  String get paymentDetailsTitle => 'Zahlungsdetails';

  @override
  String get paymentLoadError => 'Zahlung konnte nicht geladen werden';

  @override
  String get paymentMethodLabel => 'Zahlungsmethode';

  @override
  String get dateLabel => 'Datum';

  @override
  String get descriptionLabel => 'Beschreibung';

  @override
  String get purchasedItems => 'Gekaufte Artikel';

  @override
  String get noLineItemsNote =>
      'Für diese Zahlung sind keine Artikeldetails gespeichert. Bei neuen Käufen im Shop werden die Produkte hier angezeigt.';

  @override
  String get itemFallback => 'Artikel';

  @override
  String get backToPayments => 'Zurück zu Zahlungen';

  @override
  String get videoStartFailed => 'Videoanruf konnte nicht gestartet werden';

  @override
  String get videoInvalidUrl => 'Ungültige Video-URL';

  @override
  String get videoTitle => 'Videoanruf';

  @override
  String get videoOpenFailed => 'Videoanruf konnte nicht geöffnet werden';

  @override
  String get videoOpenedInNewTab =>
      'Der Videoanruf wurde in einem neuen Tab geöffnet.';

  @override
  String get videoOpenedHint =>
      'Falls sich kein neuer Tab geöffnet hat, nutzen Sie den Button unten.';

  @override
  String get videoOpenAgain => 'Erneut öffnen';

  @override
  String get videoBack => 'Zurück';

  @override
  String get videoStartCall => 'Videoanruf starten';

  @override
  String apptLoadSlotsFailed(String error) {
    return 'Fehler beim Laden der Termine: $error';
  }

  @override
  String get apptSelectSlotFirst => 'Bitte wählen Sie einen Termin aus';

  @override
  String get apptBooked => 'Termin gebucht';

  @override
  String get apptBookedMessage => 'Ihr Termin wurde erfolgreich gebucht.';

  @override
  String get apptDoctor => 'Arzt';

  @override
  String get apptType => 'Typ';

  @override
  String get apptOnlineConsultation => 'Online-Beratung';

  @override
  String get apptOk => 'OK';

  @override
  String get apptBookFailed => 'Fehler beim Buchen des Termins';

  @override
  String apptErrorWith(String error) {
    return 'Fehler: $error';
  }

  @override
  String get apptBookAppointment => 'Termin buchen';

  @override
  String get apptBooking => 'Wird gebucht…';

  @override
  String apptAfterTest(String testName) {
    return 'Termin nach $testName';
  }

  @override
  String get apptConsultationType => 'Beratungstyp';

  @override
  String get apptVideoViaHomeDx => 'Videoanruf über HomeDX';

  @override
  String get apptAvailable => 'Verfügbare Termine';

  @override
  String get apptNoSlots => 'Keine verfügbaren Termine';

  @override
  String get apptNoSlotsRetry => 'Bitte versuchen Sie es später erneut.';

  @override
  String get apptNotesOptional => 'Notizen (optional)';

  @override
  String get apptNotesHint => 'Zusätzliche Informationen für den Arzt…';

  @override
  String get apptCancelAppointment => 'Termin stornieren';

  @override
  String get apptCancelBody =>
      'Möchten Sie diesen Termin wirklich stornieren? Sie können optional eine Nachricht an die andere Person senden.';

  @override
  String get apptCancelMessage => 'Nachricht (optional)';

  @override
  String get apptCancelReasonHint => 'Grund für die Stornierung…';

  @override
  String get apptCancelled => 'Termin storniert';

  @override
  String get apptCancelFailed => 'Stornierung fehlgeschlagen';

  @override
  String get apptGender => 'Geschlecht';

  @override
  String get apptPatient => 'Patient';

  @override
  String get apptDateTime => 'Termin';

  @override
  String get apptKind => 'Art';

  @override
  String get apptOnSite => 'Vor-Ort-Termin';

  @override
  String get apptRelatedTest => 'Zugehöriger Test';

  @override
  String get apptNotes => 'Notizen';

  @override
  String get apptJoinVideoCall => 'Videoanruf beitreten';

  @override
  String get apptNotFound => 'Termin nicht gefunden';

  @override
  String get apptDetailsTitle => 'Termindetails';

  @override
  String get apptMyAppointments => 'Meine Termine';

  @override
  String get apptNewAppointment => 'Neuer Termin';

  @override
  String get apptTapForDetails => 'Tippen Sie auf einen Eintrag für Details.';

  @override
  String get apptLoadFailed => 'Termine konnten nicht geladen werden';

  @override
  String get apptNoAppointments => 'Noch keine Termine';

  @override
  String get apptBookPrompt =>
      'Buchen Sie einen Termin bei einem Arzt, um ihn hier zu sehen.';

  @override
  String get apptFindDoctor => 'Arzt finden';

  @override
  String get apptUpcoming => 'Bevorstehend';

  @override
  String get apptPast => 'Vergangen';

  @override
  String get docDoctorFallback => 'Arzt';

  @override
  String docWelcome(String name) {
    return 'Willkommen, $name';
  }

  @override
  String get docOverview =>
      'Übersicht Ihrer heutigen Termine und Video-Konsultationen.';

  @override
  String get docAvailability => 'Verfügbarkeit';

  @override
  String get docDashboard => 'Dashboard';

  @override
  String get docTodaysAppointments => 'Heutige Termine';

  @override
  String get docNoAppointmentsToday => 'Keine Termine für heute';

  @override
  String get docAppointmentsTodayHint =>
      'Sobald Patienten buchen, erscheinen Ihre heutigen Termine hier.';

  @override
  String get docRheumaCheckForms => 'RheumaCheck Fragebögen';

  @override
  String get docFormB => 'Bogen B';

  @override
  String get docFormBSubtitle => 'Standardmethode & Versorgungspfad';

  @override
  String get docFormD => 'Bogen D';

  @override
  String get docFormDSubtitle => 'Implementierbarkeit & Nutzen';

  @override
  String get docAllAppointments => 'Alle Termine';

  @override
  String get docTapAppointmentForDetails =>
      'Tippen Sie auf einen Termin für Details.';

  @override
  String get docListView => 'Liste';

  @override
  String get docCalendarView => 'Kalender';

  @override
  String get docBookedAppointmentsHere =>
      'Gebuchte Patiententermine erscheinen hier.';

  @override
  String get docAvailabilityIntro =>
      'Legen Sie fest, wann Patienten Termine bei Ihnen buchen können. Sie können pro Tag mehrere Zeitfenster hinzufügen, z. B. vormittags und nachmittags.';

  @override
  String get docWeeklyHours => 'Wöchentliche Sprechzeiten';

  @override
  String get docMonday => 'Montag';

  @override
  String get docTuesday => 'Dienstag';

  @override
  String get docWednesday => 'Mittwoch';

  @override
  String get docThursday => 'Donnerstag';

  @override
  String get docFriday => 'Freitag';

  @override
  String get docFrom => 'Von';

  @override
  String get docTo => 'Bis';

  @override
  String docInvalidRange(String day, String start, String end) {
    return 'Ungültiges Zeitfenster an $day: \"$start\" – \"$end\". \"Bis\" muss nach \"Von\" liegen.';
  }

  @override
  String get docAvailabilitySaved => 'Verfügbarkeit gespeichert';

  @override
  String get docSaveFailed => 'Speichern fehlgeschlagen';

  @override
  String get docAvailabilityLoadFailed =>
      'Verfügbarkeit konnte nicht geladen werden';

  @override
  String get docSaving => 'Speichern…';

  @override
  String get docSaveChanges => 'Änderungen speichern';

  @override
  String get docRemoveSlot => 'Zeitfenster entfernen';

  @override
  String get docAddSlot => 'Zeitfenster hinzufügen';

  @override
  String get docSelectDoctor => 'Wählen Sie einen Arzt';

  @override
  String get docSearchHint => 'Arzt oder Fachrichtung suchen…';

  @override
  String docRecommendedSpecialists(String specialization) {
    return 'Empfohlene Fachärzte: $specialization';
  }

  @override
  String get docNoMatchingSpecialist => 'Kein passender Facharzt verfügbar';

  @override
  String docNoSpecialistFound(String testName, String specialization) {
    return 'Für $testName konnten wir aktuell keinen Facharzt für $specialization finden. Wir zeigen Ihnen alle verfügbaren Ärzte.';
  }

  @override
  String docBasedOnTest(String testName, String specialization) {
    return 'Basierend auf Ihrem positiven $testName empfehlen wir Ärzte mit Fachrichtung $specialization.';
  }

  @override
  String get docTestFallback => 'Ihren Test';

  @override
  String get docDoctorsLoadFailed => 'Ärzte konnten nicht geladen werden';

  @override
  String get docNoDoctorsFound => 'Keine Ärzte gefunden';

  @override
  String get docNoDoctorsHint =>
      'Versuchen Sie eine andere Suche oder Sprache.';

  @override
  String get docLanguage => 'Sprache';

  @override
  String get docAll => 'Alle';

  @override
  String get docWeekView => 'Woche';

  @override
  String get docMonthView => 'Monat';

  @override
  String get docToday => 'Heute';

  @override
  String docMoreCount(String count) {
    return '+$count mehr';
  }

  @override
  String get docNoAppointmentsOnDay => 'Keine Termine an diesem Tag';

  @override
  String get docPickAnotherDay => 'Wählen Sie einen anderen Tag im Kalender.';

  @override
  String get authActivatingAccount => 'Ihr Konto wird aktiviert…';

  @override
  String get authAlreadyAccountPrompt => 'Bereits ein Konto? ';

  @override
  String get authBackToSignIn => 'Zurück zur Anmeldung';

  @override
  String get authBackToSignUp => 'Zurück zur Registrierung';

  @override
  String get authBrandConfirmationDoctorSubtitle =>
      'Bestätigen Sie Ihre E-Mail-Adresse, um Ihr Arztkonto zu aktivieren.';

  @override
  String get authBrandConfirmationSubtitle =>
      'Fast geschafft — bestätigen Sie Ihre E-Mail und schon können Sie loslegen.';

  @override
  String get authBrandConfirmationTitle => 'Praxis angelegt';

  @override
  String get authBrandDoctorLoginSubtitle =>
      'Verwalten Sie Termine, Verfügbarkeit und Video-Konsultationen im Browser.';

  @override
  String get authBrandDoctorPortalTitle => 'Portal für Ärzte';

  @override
  String get authBrandForgotDoctorSubtitle =>
      'Geben Sie die E-Mail Ihres Arztkontos ein — wir senden Ihnen einen Link.';

  @override
  String get authBrandForgotSubtitle =>
      'Wir senden Ihnen einen Link per E-Mail, mit dem Sie Ihr Passwort zurücksetzen können.';

  @override
  String get authBrandLoginSubtitle =>
      'Schnelltests, Arzttermine und Ergebnisse — alles an einem Ort.';

  @override
  String get authBrandResetDoctorSubtitle =>
      'Wählen Sie ein neues Passwort für Ihr Arztkonto.';

  @override
  String get authBrandResetSubtitle =>
      'Wählen Sie ein neues Passwort und melden Sie sich danach wieder an.';

  @override
  String get authBrandSignupDoctorSubtitle =>
      'Termine verwalten und Video-Konsultationen mit Patienten durchführen.';

  @override
  String get authBrandSignupSubtitle =>
      'Testen Sie zu Hause, buchen Sie einen Arzt und erhalten Sie Ihre Ergebnisse online.';

  @override
  String get authBrandSignupTitle => 'Praxis registrieren';

  @override
  String get authCanSignInNow => 'Sie können sich jetzt anmelden.';

  @override
  String get authCheckInboxIntro =>
      'Prüfen Sie Ihr Postfach unter dieser Adresse und aktivieren Sie Ihr Konto über den Bestätigungslink:';

  @override
  String get authClinicAddressHint => 'Straße, PLZ, Stadt';

  @override
  String get authClinicAddressLabel => 'Praxisadresse';

  @override
  String get authClinicAddressRequired => 'Bitte Praxisadresse eingeben';

  @override
  String get authConfirmPasswordLabel => 'Passwort bestätigen';

  @override
  String get authConfirmPasswordRequired => 'Bitte Passwort bestätigen';

  @override
  String get authConfirmationBody =>
      'Ihr Konto wurde angelegt. Bitte bestätigen Sie Ihre E-Mail-Adresse, um fortzufahren.';

  @override
  String get authConfirmationDoctorBody =>
      'Ihr Arztkonto wurde angelegt. Bitte bestätigen Sie Ihre E-Mail-Adresse, um fortzufahren.';

  @override
  String get authEmailInvalid => 'Ungültige E-Mail';

  @override
  String get authEmailLabel => 'E-Mail';

  @override
  String get authEmailRequired => 'Bitte E-Mail eingeben';

  @override
  String get authErrorEmailAlreadyRegistered =>
      'Diese E-Mail-Adresse ist bereits registriert. Bitte melden Sie sich an oder verwenden Sie eine andere E-Mail.';

  @override
  String get authErrorEmailNotEditable =>
      'E-Mail kann hier nicht geändert werden. Bitte laden Sie die Seite neu (Strg+Shift+R) und versuchen Sie es erneut.';

  @override
  String get authErrorGenderInvalid =>
      'Bitte wählen Sie ein gültiges Geschlecht aus.';

  @override
  String get authErrorInvalidCredentials =>
      'E-Mail oder Passwort ist falsch. Bitte prüfen Sie Ihre Eingaben und versuchen Sie es erneut.';

  @override
  String get authErrorInvalidRequest =>
      'Ungültige Anfrage. Bitte prüfen Sie Ihre Eingaben.';

  @override
  String get authErrorInvalidRequestRetry =>
      'Ungültige Anfrage. Bitte prüfen Sie Ihre Eingaben und versuchen Sie es erneut.';

  @override
  String get authErrorLoginFailed =>
      'Anmeldung fehlgeschlagen. Bitte versuchen Sie es erneut.';

  @override
  String get authErrorRegistrationFailed => 'Registrierung fehlgeschlagen';

  @override
  String get authErrorSessionExpired => 'Bitte melden Sie sich erneut an.';

  @override
  String get authFirstNameLabel => 'Vorname';

  @override
  String get authFirstNameRequired => 'Bitte Vorname eingeben';

  @override
  String get authForgotPasswordLink => 'Passwort vergessen?';

  @override
  String get authForgotPasswordSubtitle =>
      'Geben Sie Ihre E-Mail-Adresse ein. Wir senden Ihnen einen Link zum Zurücksetzen.';

  @override
  String get authGoToHomepage => 'Zur Startseite';

  @override
  String get authGoToSignIn => 'Zur Anmeldung';

  @override
  String get authHidePassword => 'Passwort verbergen';

  @override
  String get authLastNameLabel => 'Nachname';

  @override
  String get authLastNameRequired => 'Bitte Nachname eingeben';

  @override
  String get authLoginDoctorSubtitle =>
      'Melden Sie sich mit Ihrem Arztkonto an.';

  @override
  String get authLoginDoctorTitle => 'Arzt-Login';

  @override
  String get authLoginFailed => 'Anmeldung fehlgeschlagen';

  @override
  String get authLoginSubtitle =>
      'Geben Sie Ihre E-Mail-Adresse und Ihr Passwort ein.';

  @override
  String get authLoginTitle => 'In Ihr Konto einloggen';

  @override
  String get authNewPassword => 'Neues Passwort';

  @override
  String get authNextStep => 'Nächster Schritt';

  @override
  String get authNoAccountPrompt => 'Noch kein Konto? ';

  @override
  String get authOpenLinkHint =>
      'Öffnen Sie den Link in der E-Mail, um Ihr Konto zu aktivieren. Prüfen Sie auch Ihren Spam-Ordner.';

  @override
  String get authPasswordLabel => 'Passwort';

  @override
  String get authPasswordMinLength => 'Mindestens 8 Zeichen';

  @override
  String get authPasswordNeedsDigit => 'Mindestens eine Zahl';

  @override
  String get authPasswordNeedsLowercase => 'Mindestens ein Kleinbuchstabe';

  @override
  String get authPasswordNeedsSpecial => 'Mindestens ein Sonderzeichen';

  @override
  String get authPasswordNeedsUppercase => 'Mindestens ein Großbuchstabe';

  @override
  String get authPasswordRequired => 'Bitte Passwort eingeben';

  @override
  String get authPasswordRequirementsTitle => 'Passwort-Anforderungen';

  @override
  String get authPasswordRuleDigit => 'Mindestens eine Zahl (0–9)';

  @override
  String get authPasswordRuleLowercase => 'Mindestens ein Kleinbuchstabe (a–z)';

  @override
  String get authPasswordRuleSpecial =>
      'Mindestens ein Sonderzeichen (z. B. !@#\$)';

  @override
  String get authPasswordRuleUppercase => 'Mindestens ein Großbuchstabe (A–Z)';

  @override
  String get authPasswordsMismatch => 'Passwörter stimmen nicht überein';

  @override
  String get authRegister => 'Registrieren';

  @override
  String get authRegistrationSuccessTitle => 'Registrierung erfolgreich';

  @override
  String get authRequestNewLink => 'Neuen Link anfordern';

  @override
  String get authResendEmail => 'E-Mail erneut senden';

  @override
  String get authResetLinkInvalid =>
      'Der Link zum Zurücksetzen ist ungültig. Bitte fordern Sie einen neuen Link an.';

  @override
  String get authResetLinkInvalidError =>
      'Der Link zum Zurücksetzen ist ungültig oder abgelaufen. Bitte fordern Sie einen neuen Link an.';

  @override
  String get authResetPasswordSubtitle =>
      'Legen Sie ein neues Passwort für Ihr Konto fest.';

  @override
  String get authResetPasswordTitle => 'Passwort zurücksetzen';

  @override
  String get authSavePassword => 'Passwort speichern';

  @override
  String get authSendLink => 'Link senden';

  @override
  String get authSendingEmail => 'E-Mail wird gesendet…';

  @override
  String get authShowPassword => 'Passwort anzeigen';

  @override
  String get authSignIn => 'Anmelden';

  @override
  String get authSignupDoctorSubtitle =>
      'Füllen Sie die Angaben zu Ihrer Praxis aus.';

  @override
  String get authSignupDoctorTitle => 'Arztkonto erstellen';

  @override
  String get authSignupSubtitle =>
      'Füllen Sie das Formular aus — dauert nur wenige Minuten.';

  @override
  String get authSignupTitle => 'Konto erstellen';

  @override
  String get authSpecializationLabel => 'Fachrichtung';

  @override
  String get authSpecializationRequired => 'Bitte Fachrichtung auswählen';

  @override
  String get authVerifyChecking =>
      'Der Bestätigungslink aus Ihrer E-Mail wird geprüft.';

  @override
  String get authVerifyEmailTitle => 'E-Mail bestätigen';

  @override
  String get authVerifyLinkInvalid =>
      'Der Bestätigungslink ist ungültig oder abgelaufen. Bitte fordern Sie eine neue E-Mail an.';

  @override
  String get authYourEmailAddress => 'Ihre E-Mail-Adresse';

  @override
  String get testTypeCrp => 'CRP (C-reaktives Protein)';

  @override
  String get testTypeGenericName => 'Schnelltest';

  @override
  String get cubeWebStubMessage =>
      'Gesundheitstests mit dem Cube-Gerät sind nur in der Android-App verfügbar (Bluetooth). Installieren Sie die mobile App oder nutzen Sie die Web-Version für Termine und Ergebnisse.';

  @override
  String get btGoToHome => 'Zur Startseite';

  @override
  String get btBack => 'Zurück';

  @override
  String get testStartFailed => 'Test konnte nicht gestartet werden';

  @override
  String get testPreAnamnesisTitle => 'Vorab-Anamnese';

  @override
  String get testAnamnesisPrompt =>
      'Möchten Sie vor dem RheumaCheck-Test den Anamnese-Fragebogen (Bogen A) ausfüllen? Das dauert nur wenige Minuten.';

  @override
  String get testSkip => 'Überspringen';

  @override
  String get testStartAnamnesis => 'Anamnese starten';

  @override
  String get testSelectTitle => 'Testtyp auswählen';

  @override
  String get testLoadError => 'Fehler beim Laden der Tests';

  @override
  String get testNoneAvailable => 'Keine Tests verfügbar';

  @override
  String get testRheumaDescriptionFallback =>
      'Screening-Test auf rheumatoide Arthritis';

  @override
  String get testAgreeTermsError => 'Bitte stimmen Sie den Bedingungen zu.';

  @override
  String get testSubmitTitle => 'Test abschließen';

  @override
  String testCubeResult(String result) {
    return 'Cube-Ergebnis: $result';
  }

  @override
  String get testPhotoOptional => 'Testfoto (optional)';

  @override
  String get testVideoOptional => 'Testvideo (optional)';

  @override
  String get testIdFront => 'Ausweis Vorderseite';

  @override
  String get testIdBack => 'Ausweis Rückseite';

  @override
  String get testAgreementText =>
      'Ich bestätige die Richtigkeit der Angaben und akzeptiere die Testbedingungen.';

  @override
  String get testTermsLink => 'Testbedingungen';

  @override
  String get testPrivacyLink => 'Datenschutz';

  @override
  String get testSending => 'Wird gesendet…';

  @override
  String get testSubmitButton => 'Test absenden';

  @override
  String testUploadedAs(String name) {
    return 'Hochgeladen: $name';
  }

  @override
  String get btConnected => 'Verbunden';

  @override
  String get btUnknownDevice => 'Unbekanntes Gerät';

  @override
  String get btServices => 'Dienste';

  @override
  String get btRead => 'Lesen';

  @override
  String get btWrite => 'Schreiben';

  @override
  String get btSubscribe => 'Abonnieren';

  @override
  String get btDisconnect => 'Trennen';

  @override
  String get btNoDeviceConnected => 'Kein Gerät verbunden';

  @override
  String get btSearchPrompt =>
      'Suchen Sie nach einem Bluetooth-Gerät und verbinden Sie sich, um zu beginnen';

  @override
  String get btSearchDevices => 'Nach Geräten suchen';

  @override
  String get btDisconnectTitle => 'Gerät trennen';

  @override
  String get btDisconnectConfirm =>
      'Möchten Sie die Verbindung wirklich trennen?';

  @override
  String get btDisconnected => 'Getrennt';

  @override
  String get btReadData => 'Gelesene Daten';

  @override
  String btReadFailed(String error) {
    return 'Lesen fehlgeschlagen: $error';
  }

  @override
  String get btWriteDataTitle => 'Daten schreiben';

  @override
  String get btHexInputLabel => 'Daten eingeben (Hex-Format)';

  @override
  String get btHexInputHint => 'z.B. 01 02 03';

  @override
  String get btWriteSuccess => 'Daten erfolgreich geschrieben';

  @override
  String btWriteFailed(String error) {
    return 'Schreiben fehlgeschlagen: $error';
  }

  @override
  String get btNotificationData => 'Benachrichtigungsdaten';

  @override
  String get btSubscribed => 'Benachrichtigungen abonniert';

  @override
  String btSubscribeFailed(String error) {
    return 'Abonnieren fehlgeschlagen: $error';
  }

  @override
  String get btClose => 'Schließen';

  @override
  String get btNoFilePath =>
      'Kein Dateipfad verfügbar. Bitte über „Dateien“ wählen oder die Datei in Downloads ablegen.';

  @override
  String get btCancelTestTitle => 'Test abbrechen?';

  @override
  String get btCancelTestBody =>
      'Die laufende Messung wird beendet und Sie kehren zur Startseite zurück.';

  @override
  String get btContinue => 'Weiter';

  @override
  String get btDisconnectTestConfirm =>
      'Möchten Sie die Verbindung wirklich trennen? Sie müssen sich erneut verbinden, um den Test zu starten.';

  @override
  String get btCubeDisconnected => 'Cube-Gerät getrennt';

  @override
  String get btBluetoothDisabled => 'Bluetooth ist deaktiviert';

  @override
  String get btBluetoothRequired =>
      'Bluetooth muss aktiviert sein, um eine Verbindung zum Cube-Gerät herzustellen';

  @override
  String get btTurnOnBluetooth => 'Bluetooth aktivieren';

  @override
  String get btCubeConnected => 'Cube-Gerät verbunden';

  @override
  String btStatus(String state) {
    return 'Status: $state';
  }

  @override
  String get btReadyToStart => 'Bereit zum Teststart';

  @override
  String btReadyBody(String testName) {
    return 'Ihr Cube-Gerät ist verbunden und bereit. Sie können nun mit dem $testName Test fortfahren.';
  }

  @override
  String get btMeasurementConfig => 'Messkonfiguration (Cube)';

  @override
  String btConfigFile(String name) {
    return 'Konfigurationsdatei: $name';
  }

  @override
  String get btConfigDefault =>
      'Standard: Kalibrierung per RFID von der eingelegten Kassette. Mit „Datei wählen“ verwenden Sie stattdessen eine `.config`/`.bin` vom Anbieter (wie in der Cube-Beispiel-App).';

  @override
  String get btChooseConfigFile => 'Konfigurationsdatei wählen';

  @override
  String get btRfidMode => 'RFID-Modus (Datei löschen)';

  @override
  String get btTestStarting => 'Test wird gestartet...';

  @override
  String get btStartTest => 'Test starten';

  @override
  String get btNoCubeConnected => 'Kein Cube-Gerät verbunden';

  @override
  String btConnectPrompt(String testName) {
    return 'Bitte verbinden Sie Ihr Cube-Gerät, um mit dem $testName Test fortzufahren';
  }

  @override
  String get btSearchCubeDevices => 'Nach Cube-Geräten suchen';

  @override
  String get btPermissionRequired =>
      'Bluetooth „Geräte in der Nähe“ / Scan und Verbinden ist erforderlich. Bitte in den App-Einstellungen erlauben.';

  @override
  String get btScanStartFailed =>
      'Scan konnte nicht gestartet werden (SDK lehnt Start ab — z. B. noch verbunden oder bereits am Scannen). Tippen Sie auf Aktualisieren oder starten Sie die App neu.';

  @override
  String btScanError(String error) {
    return 'Scan-Fehler: $error';
  }

  @override
  String get btConnectTimeout =>
      'Verbindung zum Cube dauerte zu lange (60 s). Cube nah ans Telefon halten, Suche mit „Stopp“ beenden und erneut „Verbinden“ tippen. In Android-Bluetooth ggf. Gerät trennen (nicht nur paaren).';

  @override
  String get btConnectFailed => 'Verbindung fehlgeschlagen';

  @override
  String btConnectError(String error) {
    return 'Verbindungsfehler: $error';
  }

  @override
  String get btEnableBluetoothPrompt =>
      'Bitte aktivieren Sie Bluetooth, um nach Cube-Geräten zu suchen';

  @override
  String get btErrorTitle => 'Fehler';

  @override
  String get btSearchingCubes => 'Suche nach Cube-Geräten...';

  @override
  String get btEnsureCubeOn =>
      'Stellen Sie sicher, dass Ihr Cube eingeschaltet ist';

  @override
  String get btNoCubeFound => 'Kein Cube-Gerät gefunden';

  @override
  String get btEnsureCubeInRange =>
      'Stellen Sie sicher, dass Ihr Cube eingeschaltet und in Reichweite ist';

  @override
  String get btCubeDevice => 'Cube-Gerät';

  @override
  String get btSearchAgain => 'Erneut suchen';

  @override
  String get btConnect => 'Verbinden';

  @override
  String get testPreparing => 'Messung wird vorbereitet...';

  @override
  String get testLeaveConfirm =>
      'Möchten Sie die Messung verlassen und zur Startseite zurückkehren?';

  @override
  String get testUnknownError => 'Unbekannter Fehler';

  @override
  String get testMeasurementFailed => 'Messung fehlgeschlagen';

  @override
  String get testBackToStart => 'Zurück zum Start';

  @override
  String get testIncubationTime => 'Inkubationszeit';

  @override
  String get testRemaining => 'verbleibend';

  @override
  String get testInsertWhiteCassette => 'Weiße Kassette einlegen';

  @override
  String get testInsertTestCassette => 'Testkassette einlegen';

  @override
  String get testEvaluating => 'Messung auswerten';

  @override
  String get testLoadingResults => 'Ergebnisse laden';

  @override
  String get testSubmittingResults => 'Ergebnisse übermitteln';

  @override
  String get testResultsTitle => 'Testergebnisse';

  @override
  String get testTapForDetails => 'Tippen Sie auf einen Eintrag für Details.';

  @override
  String get testResultsLoadError => 'Ergebnisse konnten nicht geladen werden';

  @override
  String get testNoResultsYet => 'Noch keine Testergebnisse';

  @override
  String get testResultsWebHint =>
      'Ergebnisse erscheinen hier nach einem Test in der Android-App.';

  @override
  String get testStartToSeeResults =>
      'Starten Sie einen Test, um Ergebnisse zu sehen.';

  @override
  String get testResultTitle => 'Testergebnis';

  @override
  String get testResultPending => 'Das Testergebnis liegt noch nicht vor.';

  @override
  String get testDetailedResults => 'Detaillierte Ergebnisse';

  @override
  String testRecommended(String specialization) {
    return 'Empfohlen: $specialization';
  }

  @override
  String get testUsabilityQuestionnaire => 'Usability-Fragebogen (Bogen C)';

  @override
  String get testBackToResults => 'Zurück zu Ergebnissen';

  @override
  String get testBookSpecialist => 'Termin mit Facharzt buchen';

  @override
  String get navHome => 'Home';

  @override
  String get navAppointments => 'Termine';

  @override
  String get navResults => 'Ergebnisse';

  @override
  String get navQuestionnaires => 'Fragebögen';

  @override
  String get navShop => 'Shop';

  @override
  String get navNotifications => 'Benachrichtigungen';

  @override
  String get navPayments => 'Zahlungsverlauf';

  @override
  String get navProfile => 'Profil';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navAvailability => 'Verfügbarkeit';

  @override
  String get navVideoCall => 'Videoanruf';

  @override
  String get navAppointment => 'Termin';

  @override
  String get navResult => 'Ergebnis';

  @override
  String get navTests => 'Tests';

  @override
  String get navTestPrepare => 'Test vorbereiten';

  @override
  String get navTestSubmit => 'Test einreichen';

  @override
  String get navTestFallback => 'Test';

  @override
  String get navDoctorFallback => 'Arzt';

  @override
  String get navCertificates => 'Zertifikate';

  @override
  String get navApp => 'App';

  @override
  String get navSignIn => 'Anmelden';

  @override
  String get navRegister => 'Registrieren';

  @override
  String get homeUserFallback => 'Benutzer';

  @override
  String get homeLogout => 'Abmelden';

  @override
  String get homeWelcomeBack => 'Willkommen zurück';

  @override
  String homeGreeting(String name) {
    return 'Hallo $name — wählen Sie unten eine Schnellaktion.';
  }

  @override
  String get homeGettingStarted => 'Erste Schritte';

  @override
  String get homeRecentActivity => 'Letzte Aktivität';

  @override
  String get homeQuickActions => 'Schnellaktionen';

  @override
  String get homeStartTest => 'Test starten';

  @override
  String get homeOnlineConsultation => 'Online Sprechstunde';

  @override
  String get homeMyAppointments => 'Meine Termine';

  @override
  String get notifMarkAllRead => 'Alle gelesen';

  @override
  String get notifLoadError =>
      'Benachrichtigungen konnten nicht geladen werden';

  @override
  String get notifTapHint =>
      'Tippen Sie auf eine Meldung, um sie als gelesen zu markieren.';

  @override
  String get notifEmptyTitle => 'Keine Benachrichtigungen';

  @override
  String get notifEmptyMessage => 'Sie sind auf dem neuesten Stand.';

  @override
  String get profileSaved => 'Profil gespeichert';

  @override
  String profileErrorWith(String message) {
    return 'Fehler: $message';
  }

  @override
  String get profileLoadError => 'Fehler beim Laden des Profils';

  @override
  String get profileFirstName => 'Vorname';

  @override
  String get profileFirstNameRequired => 'Vorname ist erforderlich';

  @override
  String get profileLastName => 'Nachname';

  @override
  String get profileLastNameRequired => 'Nachname ist erforderlich';

  @override
  String get profileEmail => 'E-mail';

  @override
  String get profileEmailRequired => 'E-mail ist erforderlich';

  @override
  String get profilePhone => 'Handynummer';

  @override
  String get profileAddress => 'Adresse';

  @override
  String get profilePostcode => 'PLZ';

  @override
  String get profileCity => 'Stadt';

  @override
  String get profileCountry => 'Land';

  @override
  String get profileGender => 'Geschlecht';

  @override
  String get profileGenderRequired => 'Bitte Geschlecht auswählen';

  @override
  String get profileGenderMale => 'Männlich';

  @override
  String get profileGenderFemale => 'Weiblich';

  @override
  String get profileGenderDivers => 'Divers';

  @override
  String get profileSaving => 'Speichern…';

  @override
  String get profileSaveChanges => 'Änderungen speichern';

  @override
  String get profileCubeSdkTitle => 'Cube-Gerät (SDK)';

  @override
  String get profileCubeSdkChecking => 'Cube-SDK wird geprüft…';

  @override
  String profileVersion(String version) {
    return 'Version: $version';
  }

  @override
  String get profileLicenseValid => 'Bundled-Lizenz: gültig (laut SDK)';

  @override
  String get profileLicenseInvalid =>
      'Bundled-Lizenz: ungültig oder abgelaufen — neue cube_license.dat vom Anbieter einspielen und App neu bauen.';

  @override
  String get shopTitle => 'Shop';

  @override
  String get shopFilterAll => 'Alle';

  @override
  String get shopFilterTestStrips => 'Teststreifen';

  @override
  String get shopFilterTestDevices => 'Testgeräte';

  @override
  String get shopLoadError => 'Shop konnte nicht geladen werden';

  @override
  String get shopNoProducts => 'Keine Produkte gefunden';

  @override
  String get shopNoProductsMessage =>
      'In dieser Kategorie sind derzeit keine Artikel verfügbar.';

  @override
  String shopItemAdded(String name) {
    return '$name hinzugefügt';
  }

  @override
  String get shopSoldOut => 'Ausverkauft';

  @override
  String get shopCategoryTestStrip => 'Teststreifen';

  @override
  String get shopCategoryTestDevice => 'Testgerät';

  @override
  String get shopCategoryAccessory => 'Zubehör';

  @override
  String get shopCategoryOther => 'Sonstiges';

  @override
  String get shopQuantity => 'Menge';

  @override
  String shopTotalAmount(String amount) {
    return 'Gesamt: $amount €';
  }

  @override
  String get shopAddToCart => 'In den Warenkorb';

  @override
  String get shopUnavailable => 'Derzeit nicht verfügbar';

  @override
  String shopAddedToCart(String name) {
    return '$name zum Warenkorb hinzugefügt';
  }

  @override
  String get shopViewCart => 'Warenkorb anzeigen';

  @override
  String get shopGoToShop => 'Zum Shop';

  @override
  String get cartTitle => 'Warenkorb';

  @override
  String get cartCheckout => 'Zur Kasse';

  @override
  String get cartEmpty => 'Ihr Warenkorb ist leer';

  @override
  String get cartEmptyMessage =>
      'Stöbern Sie im Shop und fügen Sie Produkte hinzu.';

  @override
  String get cartRemove => 'Entfernen';

  @override
  String get cartTotal => 'Gesamt';

  @override
  String get checkoutTitle => 'Kasse';

  @override
  String get checkoutSummary => 'Bestellübersicht';

  @override
  String get checkoutPayNow => 'Jetzt zahlen';

  @override
  String get checkoutEmptyMessage =>
      'Fügen Sie Produkte hinzu, um zur Kasse zu gehen.';

  @override
  String get checkoutNotLoggedIn => 'Benutzer nicht angemeldet.';

  @override
  String get checkoutInvalidAmount => 'Ungültiger Betrag';

  @override
  String get orderTitle => 'Bestellung abgeschlossen';

  @override
  String get orderSubtitle =>
      'Vielen Dank. Ihre Bestellung wurde erfolgreich erfasst.';

  @override
  String get orderBackToHome => 'Zur Startseite';

  @override
  String orderTotal(String amount, String currency) {
    return 'Gesamt: $amount $currency';
  }

  @override
  String get certTitle => 'Zertifikate';

  @override
  String get certDetailTitle => 'Zertifikat';

  @override
  String get certTapHint => 'Tippen Sie auf ein Zertifikat für Details.';

  @override
  String get certLoadError => 'Zertifikate konnten nicht geladen werden';

  @override
  String get certEmpty => 'Noch keine Zertifikate';

  @override
  String get certEmptyMessage =>
      'Zertifikate erscheinen hier nach einem abgeschlossenen Test.';

  @override
  String get certTest => 'Test';

  @override
  String get certStatusIssued => 'Ausgestellt';

  @override
  String get certStatusDraft => 'Entwurf';

  @override
  String get certStatusExpired => 'Abgelaufen';

  @override
  String get certStatusRevoked => 'Widerrufen';

  @override
  String get certTypeTestResult => 'Testergebnis';

  @override
  String get certTypeVaccination => 'Impfung';

  @override
  String get certTypeRecovery => 'Genesung';

  @override
  String get certTypeMedicalClearance => 'Ärztliche Freigabe';

  @override
  String get certSharePdf => 'PDF teilen';

  @override
  String get certLoading => 'Wird geladen…';

  @override
  String get certNotFound => 'Zertifikat nicht gefunden';

  @override
  String get certPdfDownload => 'PDF-Download';

  @override
  String get certPdfDownloadHint =>
      'Öffnen Sie die HomeDX-App auf Ihrem Smartphone, um dieses Zertifikat als PDF zu teilen.';

  @override
  String certPdfSaved(String path) {
    return 'PDF gespeichert: $path';
  }

  @override
  String certErrorWith(String error) {
    return 'Fehler: $error';
  }

  @override
  String get certResult => 'Ergebnis';

  @override
  String get certValidity => 'Gültigkeit';

  @override
  String get certIssuedOn => 'Ausgestellt am';

  @override
  String get questTitle => 'Fragebögen';

  @override
  String get questLoadError => 'Fragebögen konnten nicht geladen werden';

  @override
  String get questEmpty => 'Keine Fragebögen verfügbar';

  @override
  String get questEmptyMessage =>
      'Sobald Fragebögen freigeschaltet sind, erscheinen sie hier.';

  @override
  String get questHubIntroDoctor =>
      'Im Rahmen von RheumaCheck erfassen diese Fragebögen strukturierte Angaben aus Sicht des Rheumanetzwerks und zur Implementierbarkeit in der Praxis. Ihre Antworten unterstützen die Begleitforschung und die Weiterentwicklung von HomeDX — sie ersetzen keine Diagnose und geben keine Behandlungsempfehlungen.';

  @override
  String get questHubIntroPatient =>
      'Im Rahmen von RheumaCheck helfen diese Fragebögen, Ihre Angaben vor dem Test und Ihr Feedback nach der Nutzung strukturiert zu erfassen. So können wir HomeDX verbessern und die Versorgung besser verstehen. Die Fragebögen ersetzen keine ärztliche Diagnose.';

  @override
  String get questBadgeBeforeTest => 'Vor dem Test';

  @override
  String get questBadgeNetwork => 'Rheumanetzwerk';

  @override
  String get questBadgeAfterUse => 'Nach Nutzung';

  @override
  String get questBadgePilot => 'Pilot / Implementierung';

  @override
  String questModuleLabel(String moduleId) {
    return 'Bogen $moduleId';
  }

  @override
  String get questResume => 'Entwurf fortsetzen';

  @override
  String get questStartNow => 'Jetzt starten';

  @override
  String get questDoneTitle => 'Fragebogen abgeschlossen';

  @override
  String get questThanks => 'Vielen Dank!';

  @override
  String questDoneMessage(String moduleId) {
    return 'Bogen $moduleId wurde erfolgreich übermittelt. Ihre Antworten wurden gespeichert.';
  }

  @override
  String get questBackToList => 'Zurück zu Fragebögen';

  @override
  String get questContinue => 'Weiter im Ablauf';

  @override
  String get questLengthLabel => 'Fragebogenlänge';

  @override
  String get questShortVersion => 'Kurzversion';

  @override
  String get questFullVersion => 'Vollversion';

  @override
  String get questShortVersionHint =>
      'Kurzversion: Kernfragen für Pilot und App (kürzer).';

  @override
  String get questFullVersionHint =>
      'Vollversion: alle Fragen aus dem PDF-Fachpaket (länger).';

  @override
  String get questIntroPatientNotice =>
      'Dieser Fragebogen ersetzt keine ärztliche Diagnose. Bei akuten oder starken Beschwerden wenden Sie sich bitte an eine Ärztin oder einen Arzt.';

  @override
  String get questConsentCheckbox =>
      'Ich willige ein, dass meine Antworten zur Auswertung des RheumaCheck-Projekts gespeichert werden.';

  @override
  String get questIntroResearchNotice =>
      'Dieser Fragebogen dient der Forschung und Pilotierung von RheumaCheck. Es werden keine Diagnosen abgegeben.';

  @override
  String get questStart => 'Fragebogen starten';

  @override
  String questStepProgress(String index, String total) {
    return 'Schritt $index von $total';
  }

  @override
  String get questBack => 'Zurück';

  @override
  String get questNext => 'Weiter';

  @override
  String get questSubmit => 'Absenden';

  @override
  String questFallbackTitle(String moduleId) {
    return 'Fragebogen $moduleId';
  }

  @override
  String get questLoadFailed => 'Fragebogen konnte nicht geladen werden';

  @override
  String questAnswerRequired(String label) {
    return 'Bitte beantworten Sie: $label';
  }

  @override
  String get questConsentRequired =>
      'Bitte bestätigen Sie den Hinweis zur Einwilligung.';

  @override
  String get questSelectHint => 'Auswählen';
}
