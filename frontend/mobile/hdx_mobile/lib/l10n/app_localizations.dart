import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @payFailed.
  ///
  /// In de, this message translates to:
  /// **'Zahlung fehlgeschlagen'**
  String get payFailed;

  /// No description provided for @payCancelled.
  ///
  /// In de, this message translates to:
  /// **'Zahlung wurde abgebrochen'**
  String get payCancelled;

  /// No description provided for @cardPaymentTitle.
  ///
  /// In de, this message translates to:
  /// **'Kreditkartenzahlung'**
  String get cardPaymentTitle;

  /// No description provided for @processing.
  ///
  /// In de, this message translates to:
  /// **'Wird verarbeitet…'**
  String get processing;

  /// No description provided for @payButton.
  ///
  /// In de, this message translates to:
  /// **'Bezahlen'**
  String get payButton;

  /// No description provided for @amountDue.
  ///
  /// In de, this message translates to:
  /// **'Zu zahlender Betrag:'**
  String get amountDue;

  /// No description provided for @cardStripeNotice.
  ///
  /// In de, this message translates to:
  /// **'Kartendaten werden sicher über Stripe eingegeben. Ihre App verarbeitet keine Kartennummern direkt.'**
  String get cardStripeNotice;

  /// No description provided for @paypalNotConfirmed.
  ///
  /// In de, this message translates to:
  /// **'PayPal-Zahlung konnte nicht bestätigt werden'**
  String get paypalNotConfirmed;

  /// No description provided for @paypalWebViewError.
  ///
  /// In de, this message translates to:
  /// **'WebView-Fehler: {description}'**
  String paypalWebViewError(String description);

  /// No description provided for @paypalOrderFailed.
  ///
  /// In de, this message translates to:
  /// **'PayPal-Bestellung konnte nicht erstellt werden'**
  String get paypalOrderFailed;

  /// No description provided for @paypalTitle.
  ///
  /// In de, this message translates to:
  /// **'PayPal-Zahlung'**
  String get paypalTitle;

  /// No description provided for @paySuccess.
  ///
  /// In de, this message translates to:
  /// **'Zahlung erfolgreich'**
  String get paySuccess;

  /// No description provided for @orderConfirmed.
  ///
  /// In de, this message translates to:
  /// **'Ihre Bestellung wurde bestätigt. Sie erhalten eine Bestätigung in der App.'**
  String get orderConfirmed;

  /// No description provided for @paymentFailedWith.
  ///
  /// In de, this message translates to:
  /// **'Zahlung fehlgeschlagen: {error}'**
  String paymentFailedWith(String error);

  /// No description provided for @paypalSuccess.
  ///
  /// In de, this message translates to:
  /// **'PayPal-Zahlung erfolgreich'**
  String get paypalSuccess;

  /// No description provided for @paypalCancelled.
  ///
  /// In de, this message translates to:
  /// **'PayPal-Zahlung abgebrochen'**
  String get paypalCancelled;

  /// No description provided for @paypalFailedWith.
  ///
  /// In de, this message translates to:
  /// **'PayPal-Zahlung fehlgeschlagen: {error}'**
  String paypalFailedWith(String error);

  /// No description provided for @sepaStarted.
  ///
  /// In de, this message translates to:
  /// **'SEPA-Überweisung gestartet'**
  String get sepaStarted;

  /// No description provided for @sepaStartedSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Bitte überweisen Sie den Betrag innerhalb von 3–5 Werktagen. Ihre Bestellung bleibt bis dahin reserviert.'**
  String get sepaStartedSubtitle;

  /// No description provided for @copiedToClipboard.
  ///
  /// In de, this message translates to:
  /// **'Bankverbindung in Zwischenablage kopiert'**
  String get copiedToClipboard;

  /// No description provided for @sepaConfirmTitle.
  ///
  /// In de, this message translates to:
  /// **'SEPA-Überweisung bestätigen'**
  String get sepaConfirmTitle;

  /// No description provided for @cancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In de, this message translates to:
  /// **'Bestätigen'**
  String get confirm;

  /// No description provided for @sepaTitle.
  ///
  /// In de, this message translates to:
  /// **'SEPA-Überweisung'**
  String get sepaTitle;

  /// No description provided for @bankDetails.
  ///
  /// In de, this message translates to:
  /// **'Bankverbindung'**
  String get bankDetails;

  /// No description provided for @ibanLabel.
  ///
  /// In de, this message translates to:
  /// **'IBAN:'**
  String get ibanLabel;

  /// No description provided for @copy.
  ///
  /// In de, this message translates to:
  /// **'Kopieren'**
  String get copy;

  /// No description provided for @bicLabel.
  ///
  /// In de, this message translates to:
  /// **'BIC:'**
  String get bicLabel;

  /// No description provided for @accountHolderLabel.
  ///
  /// In de, this message translates to:
  /// **'Kontoinhaber:'**
  String get accountHolderLabel;

  /// No description provided for @referenceLabel.
  ///
  /// In de, this message translates to:
  /// **'Verwendungszweck:'**
  String get referenceLabel;

  /// No description provided for @bankDetailsOptional.
  ///
  /// In de, this message translates to:
  /// **'Ihre Bankverbindung (optional)'**
  String get bankDetailsOptional;

  /// No description provided for @bankDetailsOptionalNote.
  ///
  /// In de, this message translates to:
  /// **'Diese Angaben sind optional und werden nur für Ihre Referenz gespeichert.'**
  String get bankDetailsOptionalNote;

  /// No description provided for @ibanOptional.
  ///
  /// In de, this message translates to:
  /// **'IBAN (optional)'**
  String get ibanOptional;

  /// No description provided for @invalidIban.
  ///
  /// In de, this message translates to:
  /// **'Ungültige IBAN'**
  String get invalidIban;

  /// No description provided for @bicOptional.
  ///
  /// In de, this message translates to:
  /// **'BIC (optional)'**
  String get bicOptional;

  /// No description provided for @invalidBic.
  ///
  /// In de, this message translates to:
  /// **'Ungültiger BIC'**
  String get invalidBic;

  /// No description provided for @accountHolderOptional.
  ///
  /// In de, this message translates to:
  /// **'Kontoinhaber (optional)'**
  String get accountHolderOptional;

  /// No description provided for @confirmTransfer.
  ///
  /// In de, this message translates to:
  /// **'Überweisung bestätigen'**
  String get confirmTransfer;

  /// No description provided for @sepaConfirmBody.
  ///
  /// In de, this message translates to:
  /// **'Bitte überweisen Sie den Betrag innerhalb von 3-5 Werktagen auf das angegebene Konto. Verwenden Sie die Zahlungs-ID als Verwendungszweck.'**
  String get sepaConfirmBody;

  /// No description provided for @sepaNotice.
  ///
  /// In de, this message translates to:
  /// **'Bitte überweisen Sie den Betrag innerhalb von 3-5 Werktagen. Verwenden Sie die Zahlungs-ID als Verwendungszweck, damit wir Ihre Zahlung zuordnen können.'**
  String get sepaNotice;

  /// No description provided for @amountLabel.
  ///
  /// In de, this message translates to:
  /// **'Betrag:'**
  String get amountLabel;

  /// No description provided for @methodCard.
  ///
  /// In de, this message translates to:
  /// **'Kreditkarte'**
  String get methodCard;

  /// No description provided for @methodBankTransfer.
  ///
  /// In de, this message translates to:
  /// **'Banküberweisung'**
  String get methodBankTransfer;

  /// No description provided for @methodCrypto.
  ///
  /// In de, this message translates to:
  /// **'Krypto'**
  String get methodCrypto;

  /// No description provided for @paymentGeneric.
  ///
  /// In de, this message translates to:
  /// **'Zahlung'**
  String get paymentGeneric;

  /// No description provided for @statusCompleted.
  ///
  /// In de, this message translates to:
  /// **'Abgeschlossen'**
  String get statusCompleted;

  /// No description provided for @statusPending.
  ///
  /// In de, this message translates to:
  /// **'Ausstehend'**
  String get statusPending;

  /// No description provided for @statusFailed.
  ///
  /// In de, this message translates to:
  /// **'Fehlgeschlagen'**
  String get statusFailed;

  /// No description provided for @statusRefunded.
  ///
  /// In de, this message translates to:
  /// **'Erstattet'**
  String get statusRefunded;

  /// No description provided for @statusCancelled.
  ///
  /// In de, this message translates to:
  /// **'Storniert'**
  String get statusCancelled;

  /// No description provided for @statusUnknown.
  ///
  /// In de, this message translates to:
  /// **'Unbekannt'**
  String get statusUnknown;

  /// No description provided for @paymentsTitle.
  ///
  /// In de, this message translates to:
  /// **'Zahlungen'**
  String get paymentsTitle;

  /// No description provided for @paymentsOverview.
  ///
  /// In de, this message translates to:
  /// **'Übersicht Ihrer Zahlungen und Bestellungen.'**
  String get paymentsOverview;

  /// No description provided for @paymentsLoadError.
  ///
  /// In de, this message translates to:
  /// **'Zahlungen konnten nicht geladen werden'**
  String get paymentsLoadError;

  /// No description provided for @checkConnectionRetry.
  ///
  /// In de, this message translates to:
  /// **'Bitte prüfen Sie Ihre Verbindung und versuchen Sie es erneut.'**
  String get checkConnectionRetry;

  /// No description provided for @retry.
  ///
  /// In de, this message translates to:
  /// **'Erneut versuchen'**
  String get retry;

  /// No description provided for @noPaymentsTitle.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Zahlungen'**
  String get noPaymentsTitle;

  /// No description provided for @noPaymentsMessage.
  ///
  /// In de, this message translates to:
  /// **'Abgeschlossene Zahlungen erscheinen hier.'**
  String get noPaymentsMessage;

  /// No description provided for @paymentDetailsTitle.
  ///
  /// In de, this message translates to:
  /// **'Zahlungsdetails'**
  String get paymentDetailsTitle;

  /// No description provided for @paymentLoadError.
  ///
  /// In de, this message translates to:
  /// **'Zahlung konnte nicht geladen werden'**
  String get paymentLoadError;

  /// No description provided for @paymentMethodLabel.
  ///
  /// In de, this message translates to:
  /// **'Zahlungsmethode'**
  String get paymentMethodLabel;

  /// No description provided for @dateLabel.
  ///
  /// In de, this message translates to:
  /// **'Datum'**
  String get dateLabel;

  /// No description provided for @descriptionLabel.
  ///
  /// In de, this message translates to:
  /// **'Beschreibung'**
  String get descriptionLabel;

  /// No description provided for @purchasedItems.
  ///
  /// In de, this message translates to:
  /// **'Gekaufte Artikel'**
  String get purchasedItems;

  /// No description provided for @noLineItemsNote.
  ///
  /// In de, this message translates to:
  /// **'Für diese Zahlung sind keine Artikeldetails gespeichert. Bei neuen Käufen im Shop werden die Produkte hier angezeigt.'**
  String get noLineItemsNote;

  /// No description provided for @itemFallback.
  ///
  /// In de, this message translates to:
  /// **'Artikel'**
  String get itemFallback;

  /// No description provided for @backToPayments.
  ///
  /// In de, this message translates to:
  /// **'Zurück zu Zahlungen'**
  String get backToPayments;

  /// No description provided for @videoStartFailed.
  ///
  /// In de, this message translates to:
  /// **'Videoanruf konnte nicht gestartet werden'**
  String get videoStartFailed;

  /// No description provided for @videoInvalidUrl.
  ///
  /// In de, this message translates to:
  /// **'Ungültige Video-URL'**
  String get videoInvalidUrl;

  /// No description provided for @videoTitle.
  ///
  /// In de, this message translates to:
  /// **'Videoanruf'**
  String get videoTitle;

  /// No description provided for @videoOpenFailed.
  ///
  /// In de, this message translates to:
  /// **'Videoanruf konnte nicht geöffnet werden'**
  String get videoOpenFailed;

  /// No description provided for @videoOpenedInNewTab.
  ///
  /// In de, this message translates to:
  /// **'Der Videoanruf wurde in einem neuen Tab geöffnet.'**
  String get videoOpenedInNewTab;

  /// No description provided for @videoOpenedHint.
  ///
  /// In de, this message translates to:
  /// **'Falls sich kein neuer Tab geöffnet hat, nutzen Sie den Button unten.'**
  String get videoOpenedHint;

  /// No description provided for @videoOpenAgain.
  ///
  /// In de, this message translates to:
  /// **'Erneut öffnen'**
  String get videoOpenAgain;

  /// No description provided for @videoBack.
  ///
  /// In de, this message translates to:
  /// **'Zurück'**
  String get videoBack;

  /// No description provided for @videoStartCall.
  ///
  /// In de, this message translates to:
  /// **'Videoanruf starten'**
  String get videoStartCall;

  /// No description provided for @apptLoadSlotsFailed.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Laden der Termine: {error}'**
  String apptLoadSlotsFailed(String error);

  /// No description provided for @apptSelectSlotFirst.
  ///
  /// In de, this message translates to:
  /// **'Bitte wählen Sie einen Termin aus'**
  String get apptSelectSlotFirst;

  /// No description provided for @apptBooked.
  ///
  /// In de, this message translates to:
  /// **'Termin gebucht'**
  String get apptBooked;

  /// No description provided for @apptBookedMessage.
  ///
  /// In de, this message translates to:
  /// **'Ihr Termin wurde erfolgreich gebucht.'**
  String get apptBookedMessage;

  /// No description provided for @apptDoctor.
  ///
  /// In de, this message translates to:
  /// **'Arzt'**
  String get apptDoctor;

  /// No description provided for @apptType.
  ///
  /// In de, this message translates to:
  /// **'Typ'**
  String get apptType;

  /// No description provided for @apptOnlineConsultation.
  ///
  /// In de, this message translates to:
  /// **'Online-Beratung'**
  String get apptOnlineConsultation;

  /// No description provided for @apptOk.
  ///
  /// In de, this message translates to:
  /// **'OK'**
  String get apptOk;

  /// No description provided for @apptBookFailed.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Buchen des Termins'**
  String get apptBookFailed;

  /// No description provided for @apptErrorWith.
  ///
  /// In de, this message translates to:
  /// **'Fehler: {error}'**
  String apptErrorWith(String error);

  /// No description provided for @apptBookAppointment.
  ///
  /// In de, this message translates to:
  /// **'Termin buchen'**
  String get apptBookAppointment;

  /// No description provided for @apptBooking.
  ///
  /// In de, this message translates to:
  /// **'Wird gebucht…'**
  String get apptBooking;

  /// No description provided for @apptAfterTest.
  ///
  /// In de, this message translates to:
  /// **'Termin nach {testName}'**
  String apptAfterTest(String testName);

  /// No description provided for @apptConsultationType.
  ///
  /// In de, this message translates to:
  /// **'Beratungstyp'**
  String get apptConsultationType;

  /// No description provided for @apptVideoViaHomeDx.
  ///
  /// In de, this message translates to:
  /// **'Videoanruf über HomeDX'**
  String get apptVideoViaHomeDx;

  /// No description provided for @apptAvailable.
  ///
  /// In de, this message translates to:
  /// **'Verfügbare Termine'**
  String get apptAvailable;

  /// No description provided for @apptNoSlots.
  ///
  /// In de, this message translates to:
  /// **'Keine verfügbaren Termine'**
  String get apptNoSlots;

  /// No description provided for @apptNoSlotsRetry.
  ///
  /// In de, this message translates to:
  /// **'Bitte versuchen Sie es später erneut.'**
  String get apptNoSlotsRetry;

  /// No description provided for @apptNotesOptional.
  ///
  /// In de, this message translates to:
  /// **'Notizen (optional)'**
  String get apptNotesOptional;

  /// No description provided for @apptNotesHint.
  ///
  /// In de, this message translates to:
  /// **'Zusätzliche Informationen für den Arzt…'**
  String get apptNotesHint;

  /// No description provided for @apptCancelAppointment.
  ///
  /// In de, this message translates to:
  /// **'Termin stornieren'**
  String get apptCancelAppointment;

  /// No description provided for @apptCancelBody.
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie diesen Termin wirklich stornieren? Sie können optional eine Nachricht an die andere Person senden.'**
  String get apptCancelBody;

  /// No description provided for @apptCancelMessage.
  ///
  /// In de, this message translates to:
  /// **'Nachricht (optional)'**
  String get apptCancelMessage;

  /// No description provided for @apptCancelReasonHint.
  ///
  /// In de, this message translates to:
  /// **'Grund für die Stornierung…'**
  String get apptCancelReasonHint;

  /// No description provided for @apptCancelled.
  ///
  /// In de, this message translates to:
  /// **'Termin storniert'**
  String get apptCancelled;

  /// No description provided for @apptCancelFailed.
  ///
  /// In de, this message translates to:
  /// **'Stornierung fehlgeschlagen'**
  String get apptCancelFailed;

  /// No description provided for @apptGender.
  ///
  /// In de, this message translates to:
  /// **'Geschlecht'**
  String get apptGender;

  /// No description provided for @apptPatient.
  ///
  /// In de, this message translates to:
  /// **'Patient'**
  String get apptPatient;

  /// No description provided for @apptDateTime.
  ///
  /// In de, this message translates to:
  /// **'Termin'**
  String get apptDateTime;

  /// No description provided for @apptKind.
  ///
  /// In de, this message translates to:
  /// **'Art'**
  String get apptKind;

  /// No description provided for @apptOnSite.
  ///
  /// In de, this message translates to:
  /// **'Vor-Ort-Termin'**
  String get apptOnSite;

  /// No description provided for @apptRelatedTest.
  ///
  /// In de, this message translates to:
  /// **'Zugehöriger Test'**
  String get apptRelatedTest;

  /// No description provided for @apptNotes.
  ///
  /// In de, this message translates to:
  /// **'Notizen'**
  String get apptNotes;

  /// No description provided for @apptJoinVideoCall.
  ///
  /// In de, this message translates to:
  /// **'Videoanruf beitreten'**
  String get apptJoinVideoCall;

  /// No description provided for @apptNotFound.
  ///
  /// In de, this message translates to:
  /// **'Termin nicht gefunden'**
  String get apptNotFound;

  /// No description provided for @apptDetailsTitle.
  ///
  /// In de, this message translates to:
  /// **'Termindetails'**
  String get apptDetailsTitle;

  /// No description provided for @apptMyAppointments.
  ///
  /// In de, this message translates to:
  /// **'Meine Termine'**
  String get apptMyAppointments;

  /// No description provided for @apptNewAppointment.
  ///
  /// In de, this message translates to:
  /// **'Neuer Termin'**
  String get apptNewAppointment;

  /// No description provided for @apptTapForDetails.
  ///
  /// In de, this message translates to:
  /// **'Tippen Sie auf einen Eintrag für Details.'**
  String get apptTapForDetails;

  /// No description provided for @apptLoadFailed.
  ///
  /// In de, this message translates to:
  /// **'Termine konnten nicht geladen werden'**
  String get apptLoadFailed;

  /// No description provided for @apptNoAppointments.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Termine'**
  String get apptNoAppointments;

  /// No description provided for @apptBookPrompt.
  ///
  /// In de, this message translates to:
  /// **'Buchen Sie einen Termin bei einem Arzt, um ihn hier zu sehen.'**
  String get apptBookPrompt;

  /// No description provided for @apptFindDoctor.
  ///
  /// In de, this message translates to:
  /// **'Arzt finden'**
  String get apptFindDoctor;

  /// No description provided for @apptUpcoming.
  ///
  /// In de, this message translates to:
  /// **'Bevorstehend'**
  String get apptUpcoming;

  /// No description provided for @apptPast.
  ///
  /// In de, this message translates to:
  /// **'Vergangen'**
  String get apptPast;

  /// No description provided for @docDoctorFallback.
  ///
  /// In de, this message translates to:
  /// **'Arzt'**
  String get docDoctorFallback;

  /// No description provided for @docWelcome.
  ///
  /// In de, this message translates to:
  /// **'Willkommen, {name}'**
  String docWelcome(String name);

  /// No description provided for @docOverview.
  ///
  /// In de, this message translates to:
  /// **'Übersicht Ihrer heutigen Termine und Video-Konsultationen.'**
  String get docOverview;

  /// No description provided for @docAvailability.
  ///
  /// In de, this message translates to:
  /// **'Verfügbarkeit'**
  String get docAvailability;

  /// No description provided for @docDashboard.
  ///
  /// In de, this message translates to:
  /// **'Dashboard'**
  String get docDashboard;

  /// No description provided for @docTodaysAppointments.
  ///
  /// In de, this message translates to:
  /// **'Heutige Termine'**
  String get docTodaysAppointments;

  /// No description provided for @docNoAppointmentsToday.
  ///
  /// In de, this message translates to:
  /// **'Keine Termine für heute'**
  String get docNoAppointmentsToday;

  /// No description provided for @docAppointmentsTodayHint.
  ///
  /// In de, this message translates to:
  /// **'Sobald Patienten buchen, erscheinen Ihre heutigen Termine hier.'**
  String get docAppointmentsTodayHint;

  /// No description provided for @docRheumaCheckForms.
  ///
  /// In de, this message translates to:
  /// **'RheumaCheck Fragebögen'**
  String get docRheumaCheckForms;

  /// No description provided for @docFormB.
  ///
  /// In de, this message translates to:
  /// **'Bogen B'**
  String get docFormB;

  /// No description provided for @docFormBSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Standardmethode & Versorgungspfad'**
  String get docFormBSubtitle;

  /// No description provided for @docFormD.
  ///
  /// In de, this message translates to:
  /// **'Bogen D'**
  String get docFormD;

  /// No description provided for @docFormDSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Implementierbarkeit & Nutzen'**
  String get docFormDSubtitle;

  /// No description provided for @docAllAppointments.
  ///
  /// In de, this message translates to:
  /// **'Alle Termine'**
  String get docAllAppointments;

  /// No description provided for @docTapAppointmentForDetails.
  ///
  /// In de, this message translates to:
  /// **'Tippen Sie auf einen Termin für Details.'**
  String get docTapAppointmentForDetails;

  /// No description provided for @docListView.
  ///
  /// In de, this message translates to:
  /// **'Liste'**
  String get docListView;

  /// No description provided for @docCalendarView.
  ///
  /// In de, this message translates to:
  /// **'Kalender'**
  String get docCalendarView;

  /// No description provided for @docBookedAppointmentsHere.
  ///
  /// In de, this message translates to:
  /// **'Gebuchte Patiententermine erscheinen hier.'**
  String get docBookedAppointmentsHere;

  /// No description provided for @docAvailabilityIntro.
  ///
  /// In de, this message translates to:
  /// **'Legen Sie fest, wann Patienten Termine bei Ihnen buchen können. Sie können pro Tag mehrere Zeitfenster hinzufügen, z. B. vormittags und nachmittags.'**
  String get docAvailabilityIntro;

  /// No description provided for @docWeeklyHours.
  ///
  /// In de, this message translates to:
  /// **'Wöchentliche Sprechzeiten'**
  String get docWeeklyHours;

  /// No description provided for @docMonday.
  ///
  /// In de, this message translates to:
  /// **'Montag'**
  String get docMonday;

  /// No description provided for @docTuesday.
  ///
  /// In de, this message translates to:
  /// **'Dienstag'**
  String get docTuesday;

  /// No description provided for @docWednesday.
  ///
  /// In de, this message translates to:
  /// **'Mittwoch'**
  String get docWednesday;

  /// No description provided for @docThursday.
  ///
  /// In de, this message translates to:
  /// **'Donnerstag'**
  String get docThursday;

  /// No description provided for @docFriday.
  ///
  /// In de, this message translates to:
  /// **'Freitag'**
  String get docFriday;

  /// No description provided for @docFrom.
  ///
  /// In de, this message translates to:
  /// **'Von'**
  String get docFrom;

  /// No description provided for @docTo.
  ///
  /// In de, this message translates to:
  /// **'Bis'**
  String get docTo;

  /// No description provided for @docInvalidRange.
  ///
  /// In de, this message translates to:
  /// **'Ungültiges Zeitfenster an {day}: \"{start}\" – \"{end}\". \"Bis\" muss nach \"Von\" liegen.'**
  String docInvalidRange(String day, String start, String end);

  /// No description provided for @docAvailabilitySaved.
  ///
  /// In de, this message translates to:
  /// **'Verfügbarkeit gespeichert'**
  String get docAvailabilitySaved;

  /// No description provided for @docSaveFailed.
  ///
  /// In de, this message translates to:
  /// **'Speichern fehlgeschlagen'**
  String get docSaveFailed;

  /// No description provided for @docAvailabilityLoadFailed.
  ///
  /// In de, this message translates to:
  /// **'Verfügbarkeit konnte nicht geladen werden'**
  String get docAvailabilityLoadFailed;

  /// No description provided for @docSaving.
  ///
  /// In de, this message translates to:
  /// **'Speichern…'**
  String get docSaving;

  /// No description provided for @docSaveChanges.
  ///
  /// In de, this message translates to:
  /// **'Änderungen speichern'**
  String get docSaveChanges;

  /// No description provided for @docRemoveSlot.
  ///
  /// In de, this message translates to:
  /// **'Zeitfenster entfernen'**
  String get docRemoveSlot;

  /// No description provided for @docAddSlot.
  ///
  /// In de, this message translates to:
  /// **'Zeitfenster hinzufügen'**
  String get docAddSlot;

  /// No description provided for @docSelectDoctor.
  ///
  /// In de, this message translates to:
  /// **'Wählen Sie einen Arzt'**
  String get docSelectDoctor;

  /// No description provided for @docSearchHint.
  ///
  /// In de, this message translates to:
  /// **'Arzt oder Fachrichtung suchen…'**
  String get docSearchHint;

  /// No description provided for @docRecommendedSpecialists.
  ///
  /// In de, this message translates to:
  /// **'Empfohlene Fachärzte: {specialization}'**
  String docRecommendedSpecialists(String specialization);

  /// No description provided for @docNoMatchingSpecialist.
  ///
  /// In de, this message translates to:
  /// **'Kein passender Facharzt verfügbar'**
  String get docNoMatchingSpecialist;

  /// No description provided for @docNoSpecialistFound.
  ///
  /// In de, this message translates to:
  /// **'Für {testName} konnten wir aktuell keinen Facharzt für {specialization} finden. Wir zeigen Ihnen alle verfügbaren Ärzte.'**
  String docNoSpecialistFound(String testName, String specialization);

  /// No description provided for @docBasedOnTest.
  ///
  /// In de, this message translates to:
  /// **'Basierend auf Ihrem positiven {testName} empfehlen wir Ärzte mit Fachrichtung {specialization}.'**
  String docBasedOnTest(String testName, String specialization);

  /// No description provided for @docTestFallback.
  ///
  /// In de, this message translates to:
  /// **'Ihren Test'**
  String get docTestFallback;

  /// No description provided for @docDoctorsLoadFailed.
  ///
  /// In de, this message translates to:
  /// **'Ärzte konnten nicht geladen werden'**
  String get docDoctorsLoadFailed;

  /// No description provided for @docNoDoctorsFound.
  ///
  /// In de, this message translates to:
  /// **'Keine Ärzte gefunden'**
  String get docNoDoctorsFound;

  /// No description provided for @docNoDoctorsHint.
  ///
  /// In de, this message translates to:
  /// **'Versuchen Sie eine andere Suche oder Sprache.'**
  String get docNoDoctorsHint;

  /// No description provided for @docLanguage.
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get docLanguage;

  /// No description provided for @docAll.
  ///
  /// In de, this message translates to:
  /// **'Alle'**
  String get docAll;

  /// No description provided for @docWeekView.
  ///
  /// In de, this message translates to:
  /// **'Woche'**
  String get docWeekView;

  /// No description provided for @docMonthView.
  ///
  /// In de, this message translates to:
  /// **'Monat'**
  String get docMonthView;

  /// No description provided for @docToday.
  ///
  /// In de, this message translates to:
  /// **'Heute'**
  String get docToday;

  /// No description provided for @docMoreCount.
  ///
  /// In de, this message translates to:
  /// **'+{count} mehr'**
  String docMoreCount(String count);

  /// No description provided for @docNoAppointmentsOnDay.
  ///
  /// In de, this message translates to:
  /// **'Keine Termine an diesem Tag'**
  String get docNoAppointmentsOnDay;

  /// No description provided for @docPickAnotherDay.
  ///
  /// In de, this message translates to:
  /// **'Wählen Sie einen anderen Tag im Kalender.'**
  String get docPickAnotherDay;

  /// No description provided for @authActivatingAccount.
  ///
  /// In de, this message translates to:
  /// **'Ihr Konto wird aktiviert…'**
  String get authActivatingAccount;

  /// No description provided for @authAlreadyAccountPrompt.
  ///
  /// In de, this message translates to:
  /// **'Bereits ein Konto? '**
  String get authAlreadyAccountPrompt;

  /// No description provided for @authBackToSignIn.
  ///
  /// In de, this message translates to:
  /// **'Zurück zur Anmeldung'**
  String get authBackToSignIn;

  /// No description provided for @authBackToSignUp.
  ///
  /// In de, this message translates to:
  /// **'Zurück zur Registrierung'**
  String get authBackToSignUp;

  /// No description provided for @authBrandConfirmationDoctorSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Bestätigen Sie Ihre E-Mail-Adresse, um Ihr Arztkonto zu aktivieren.'**
  String get authBrandConfirmationDoctorSubtitle;

  /// No description provided for @authBrandConfirmationSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Fast geschafft — bestätigen Sie Ihre E-Mail und schon können Sie loslegen.'**
  String get authBrandConfirmationSubtitle;

  /// No description provided for @authBrandConfirmationTitle.
  ///
  /// In de, this message translates to:
  /// **'Praxis angelegt'**
  String get authBrandConfirmationTitle;

  /// No description provided for @authBrandDoctorLoginSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Verwalten Sie Termine, Verfügbarkeit und Video-Konsultationen im Browser.'**
  String get authBrandDoctorLoginSubtitle;

  /// No description provided for @authBrandDoctorPortalTitle.
  ///
  /// In de, this message translates to:
  /// **'Portal für Ärzte'**
  String get authBrandDoctorPortalTitle;

  /// No description provided for @authBrandForgotDoctorSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Geben Sie die E-Mail Ihres Arztkontos ein — wir senden Ihnen einen Link.'**
  String get authBrandForgotDoctorSubtitle;

  /// No description provided for @authBrandForgotSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Wir senden Ihnen einen Link per E-Mail, mit dem Sie Ihr Passwort zurücksetzen können.'**
  String get authBrandForgotSubtitle;

  /// No description provided for @authBrandLoginSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Schnelltests, Arzttermine und Ergebnisse — alles an einem Ort.'**
  String get authBrandLoginSubtitle;

  /// No description provided for @authBrandResetDoctorSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Wählen Sie ein neues Passwort für Ihr Arztkonto.'**
  String get authBrandResetDoctorSubtitle;

  /// No description provided for @authBrandResetSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Wählen Sie ein neues Passwort und melden Sie sich danach wieder an.'**
  String get authBrandResetSubtitle;

  /// No description provided for @authBrandSignupDoctorSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Termine verwalten und Video-Konsultationen mit Patienten durchführen.'**
  String get authBrandSignupDoctorSubtitle;

  /// No description provided for @authBrandSignupSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Testen Sie zu Hause, buchen Sie einen Arzt und erhalten Sie Ihre Ergebnisse online.'**
  String get authBrandSignupSubtitle;

  /// No description provided for @authBrandSignupTitle.
  ///
  /// In de, this message translates to:
  /// **'Praxis registrieren'**
  String get authBrandSignupTitle;

  /// No description provided for @authCanSignInNow.
  ///
  /// In de, this message translates to:
  /// **'Sie können sich jetzt anmelden.'**
  String get authCanSignInNow;

  /// No description provided for @authCheckInboxIntro.
  ///
  /// In de, this message translates to:
  /// **'Prüfen Sie Ihr Postfach unter dieser Adresse und aktivieren Sie Ihr Konto über den Bestätigungslink:'**
  String get authCheckInboxIntro;

  /// No description provided for @authClinicAddressHint.
  ///
  /// In de, this message translates to:
  /// **'Straße, PLZ, Stadt'**
  String get authClinicAddressHint;

  /// No description provided for @authClinicAddressLabel.
  ///
  /// In de, this message translates to:
  /// **'Praxisadresse'**
  String get authClinicAddressLabel;

  /// No description provided for @authClinicAddressRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte Praxisadresse eingeben'**
  String get authClinicAddressRequired;

  /// No description provided for @authConfirmPasswordLabel.
  ///
  /// In de, this message translates to:
  /// **'Passwort bestätigen'**
  String get authConfirmPasswordLabel;

  /// No description provided for @authConfirmPasswordRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte Passwort bestätigen'**
  String get authConfirmPasswordRequired;

  /// No description provided for @authConfirmationBody.
  ///
  /// In de, this message translates to:
  /// **'Ihr Konto wurde angelegt. Bitte bestätigen Sie Ihre E-Mail-Adresse, um fortzufahren.'**
  String get authConfirmationBody;

  /// No description provided for @authConfirmationDoctorBody.
  ///
  /// In de, this message translates to:
  /// **'Ihr Arztkonto wurde angelegt. Bitte bestätigen Sie Ihre E-Mail-Adresse, um fortzufahren.'**
  String get authConfirmationDoctorBody;

  /// No description provided for @authEmailInvalid.
  ///
  /// In de, this message translates to:
  /// **'Ungültige E-Mail'**
  String get authEmailInvalid;

  /// No description provided for @authEmailLabel.
  ///
  /// In de, this message translates to:
  /// **'E-Mail'**
  String get authEmailLabel;

  /// No description provided for @authEmailRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte E-Mail eingeben'**
  String get authEmailRequired;

  /// No description provided for @authErrorEmailAlreadyRegistered.
  ///
  /// In de, this message translates to:
  /// **'Diese E-Mail-Adresse ist bereits registriert. Bitte melden Sie sich an oder verwenden Sie eine andere E-Mail.'**
  String get authErrorEmailAlreadyRegistered;

  /// No description provided for @authErrorEmailNotEditable.
  ///
  /// In de, this message translates to:
  /// **'E-Mail kann hier nicht geändert werden. Bitte laden Sie die Seite neu (Strg+Shift+R) und versuchen Sie es erneut.'**
  String get authErrorEmailNotEditable;

  /// No description provided for @authErrorGenderInvalid.
  ///
  /// In de, this message translates to:
  /// **'Bitte wählen Sie ein gültiges Geschlecht aus.'**
  String get authErrorGenderInvalid;

  /// No description provided for @authErrorInvalidCredentials.
  ///
  /// In de, this message translates to:
  /// **'E-Mail oder Passwort ist falsch. Bitte prüfen Sie Ihre Eingaben und versuchen Sie es erneut.'**
  String get authErrorInvalidCredentials;

  /// No description provided for @authErrorInvalidRequest.
  ///
  /// In de, this message translates to:
  /// **'Ungültige Anfrage. Bitte prüfen Sie Ihre Eingaben.'**
  String get authErrorInvalidRequest;

  /// No description provided for @authErrorInvalidRequestRetry.
  ///
  /// In de, this message translates to:
  /// **'Ungültige Anfrage. Bitte prüfen Sie Ihre Eingaben und versuchen Sie es erneut.'**
  String get authErrorInvalidRequestRetry;

  /// No description provided for @authErrorLoginFailed.
  ///
  /// In de, this message translates to:
  /// **'Anmeldung fehlgeschlagen. Bitte versuchen Sie es erneut.'**
  String get authErrorLoginFailed;

  /// No description provided for @authErrorRegistrationFailed.
  ///
  /// In de, this message translates to:
  /// **'Registrierung fehlgeschlagen'**
  String get authErrorRegistrationFailed;

  /// No description provided for @authErrorSessionExpired.
  ///
  /// In de, this message translates to:
  /// **'Bitte melden Sie sich erneut an.'**
  String get authErrorSessionExpired;

  /// No description provided for @authFirstNameLabel.
  ///
  /// In de, this message translates to:
  /// **'Vorname'**
  String get authFirstNameLabel;

  /// No description provided for @authFirstNameRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte Vorname eingeben'**
  String get authFirstNameRequired;

  /// No description provided for @authForgotPasswordLink.
  ///
  /// In de, this message translates to:
  /// **'Passwort vergessen?'**
  String get authForgotPasswordLink;

  /// No description provided for @authForgotPasswordSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Geben Sie Ihre E-Mail-Adresse ein. Wir senden Ihnen einen Link zum Zurücksetzen.'**
  String get authForgotPasswordSubtitle;

  /// No description provided for @authGoToHomepage.
  ///
  /// In de, this message translates to:
  /// **'Zur Startseite'**
  String get authGoToHomepage;

  /// No description provided for @authGoToSignIn.
  ///
  /// In de, this message translates to:
  /// **'Zur Anmeldung'**
  String get authGoToSignIn;

  /// No description provided for @authHidePassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort verbergen'**
  String get authHidePassword;

  /// No description provided for @authLastNameLabel.
  ///
  /// In de, this message translates to:
  /// **'Nachname'**
  String get authLastNameLabel;

  /// No description provided for @authLastNameRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte Nachname eingeben'**
  String get authLastNameRequired;

  /// No description provided for @authLoginDoctorSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Melden Sie sich mit Ihrem Arztkonto an.'**
  String get authLoginDoctorSubtitle;

  /// No description provided for @authLoginDoctorTitle.
  ///
  /// In de, this message translates to:
  /// **'Arzt-Login'**
  String get authLoginDoctorTitle;

  /// No description provided for @authLoginFailed.
  ///
  /// In de, this message translates to:
  /// **'Anmeldung fehlgeschlagen'**
  String get authLoginFailed;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Geben Sie Ihre E-Mail-Adresse und Ihr Passwort ein.'**
  String get authLoginSubtitle;

  /// No description provided for @authLoginTitle.
  ///
  /// In de, this message translates to:
  /// **'In Ihr Konto einloggen'**
  String get authLoginTitle;

  /// No description provided for @authNewPassword.
  ///
  /// In de, this message translates to:
  /// **'Neues Passwort'**
  String get authNewPassword;

  /// No description provided for @authNextStep.
  ///
  /// In de, this message translates to:
  /// **'Nächster Schritt'**
  String get authNextStep;

  /// No description provided for @authNoAccountPrompt.
  ///
  /// In de, this message translates to:
  /// **'Noch kein Konto? '**
  String get authNoAccountPrompt;

  /// No description provided for @authOpenLinkHint.
  ///
  /// In de, this message translates to:
  /// **'Öffnen Sie den Link in der E-Mail, um Ihr Konto zu aktivieren. Prüfen Sie auch Ihren Spam-Ordner.'**
  String get authOpenLinkHint;

  /// No description provided for @authPasswordLabel.
  ///
  /// In de, this message translates to:
  /// **'Passwort'**
  String get authPasswordLabel;

  /// No description provided for @authPasswordMinLength.
  ///
  /// In de, this message translates to:
  /// **'Mindestens 8 Zeichen'**
  String get authPasswordMinLength;

  /// No description provided for @authPasswordNeedsDigit.
  ///
  /// In de, this message translates to:
  /// **'Mindestens eine Zahl'**
  String get authPasswordNeedsDigit;

  /// No description provided for @authPasswordNeedsLowercase.
  ///
  /// In de, this message translates to:
  /// **'Mindestens ein Kleinbuchstabe'**
  String get authPasswordNeedsLowercase;

  /// No description provided for @authPasswordNeedsSpecial.
  ///
  /// In de, this message translates to:
  /// **'Mindestens ein Sonderzeichen'**
  String get authPasswordNeedsSpecial;

  /// No description provided for @authPasswordNeedsUppercase.
  ///
  /// In de, this message translates to:
  /// **'Mindestens ein Großbuchstabe'**
  String get authPasswordNeedsUppercase;

  /// No description provided for @authPasswordRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte Passwort eingeben'**
  String get authPasswordRequired;

  /// No description provided for @authPasswordRequirementsTitle.
  ///
  /// In de, this message translates to:
  /// **'Passwort-Anforderungen'**
  String get authPasswordRequirementsTitle;

  /// No description provided for @authPasswordRuleDigit.
  ///
  /// In de, this message translates to:
  /// **'Mindestens eine Zahl (0–9)'**
  String get authPasswordRuleDigit;

  /// No description provided for @authPasswordRuleLowercase.
  ///
  /// In de, this message translates to:
  /// **'Mindestens ein Kleinbuchstabe (a–z)'**
  String get authPasswordRuleLowercase;

  /// No description provided for @authPasswordRuleSpecial.
  ///
  /// In de, this message translates to:
  /// **'Mindestens ein Sonderzeichen (z. B. !@#\$)'**
  String get authPasswordRuleSpecial;

  /// No description provided for @authPasswordRuleUppercase.
  ///
  /// In de, this message translates to:
  /// **'Mindestens ein Großbuchstabe (A–Z)'**
  String get authPasswordRuleUppercase;

  /// No description provided for @authPasswordsMismatch.
  ///
  /// In de, this message translates to:
  /// **'Passwörter stimmen nicht überein'**
  String get authPasswordsMismatch;

  /// No description provided for @authRegister.
  ///
  /// In de, this message translates to:
  /// **'Registrieren'**
  String get authRegister;

  /// No description provided for @authRegistrationSuccessTitle.
  ///
  /// In de, this message translates to:
  /// **'Registrierung erfolgreich'**
  String get authRegistrationSuccessTitle;

  /// No description provided for @authRequestNewLink.
  ///
  /// In de, this message translates to:
  /// **'Neuen Link anfordern'**
  String get authRequestNewLink;

  /// No description provided for @authResendEmail.
  ///
  /// In de, this message translates to:
  /// **'E-Mail erneut senden'**
  String get authResendEmail;

  /// No description provided for @authResetLinkInvalid.
  ///
  /// In de, this message translates to:
  /// **'Der Link zum Zurücksetzen ist ungültig. Bitte fordern Sie einen neuen Link an.'**
  String get authResetLinkInvalid;

  /// No description provided for @authResetLinkInvalidError.
  ///
  /// In de, this message translates to:
  /// **'Der Link zum Zurücksetzen ist ungültig oder abgelaufen. Bitte fordern Sie einen neuen Link an.'**
  String get authResetLinkInvalidError;

  /// No description provided for @authResetPasswordSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Legen Sie ein neues Passwort für Ihr Konto fest.'**
  String get authResetPasswordSubtitle;

  /// No description provided for @authResetPasswordTitle.
  ///
  /// In de, this message translates to:
  /// **'Passwort zurücksetzen'**
  String get authResetPasswordTitle;

  /// No description provided for @authSavePassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort speichern'**
  String get authSavePassword;

  /// No description provided for @authSendLink.
  ///
  /// In de, this message translates to:
  /// **'Link senden'**
  String get authSendLink;

  /// No description provided for @authSendingEmail.
  ///
  /// In de, this message translates to:
  /// **'E-Mail wird gesendet…'**
  String get authSendingEmail;

  /// No description provided for @authShowPassword.
  ///
  /// In de, this message translates to:
  /// **'Passwort anzeigen'**
  String get authShowPassword;

  /// No description provided for @authSignIn.
  ///
  /// In de, this message translates to:
  /// **'Anmelden'**
  String get authSignIn;

  /// No description provided for @authSignupDoctorSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Füllen Sie die Angaben zu Ihrer Praxis aus.'**
  String get authSignupDoctorSubtitle;

  /// No description provided for @authSignupDoctorTitle.
  ///
  /// In de, this message translates to:
  /// **'Arztkonto erstellen'**
  String get authSignupDoctorTitle;

  /// No description provided for @authSignupSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Füllen Sie das Formular aus — dauert nur wenige Minuten.'**
  String get authSignupSubtitle;

  /// No description provided for @authSignupTitle.
  ///
  /// In de, this message translates to:
  /// **'Konto erstellen'**
  String get authSignupTitle;

  /// No description provided for @authSpecializationLabel.
  ///
  /// In de, this message translates to:
  /// **'Fachrichtung'**
  String get authSpecializationLabel;

  /// No description provided for @authSpecializationRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte Fachrichtung auswählen'**
  String get authSpecializationRequired;

  /// No description provided for @authVerifyChecking.
  ///
  /// In de, this message translates to:
  /// **'Der Bestätigungslink aus Ihrer E-Mail wird geprüft.'**
  String get authVerifyChecking;

  /// No description provided for @authVerifyEmailTitle.
  ///
  /// In de, this message translates to:
  /// **'E-Mail bestätigen'**
  String get authVerifyEmailTitle;

  /// No description provided for @authVerifyLinkInvalid.
  ///
  /// In de, this message translates to:
  /// **'Der Bestätigungslink ist ungültig oder abgelaufen. Bitte fordern Sie eine neue E-Mail an.'**
  String get authVerifyLinkInvalid;

  /// No description provided for @authYourEmailAddress.
  ///
  /// In de, this message translates to:
  /// **'Ihre E-Mail-Adresse'**
  String get authYourEmailAddress;

  /// No description provided for @testTypeCrp.
  ///
  /// In de, this message translates to:
  /// **'CRP (C-reaktives Protein)'**
  String get testTypeCrp;

  /// No description provided for @testTypeGenericName.
  ///
  /// In de, this message translates to:
  /// **'Schnelltest'**
  String get testTypeGenericName;

  /// No description provided for @cubeWebStubMessage.
  ///
  /// In de, this message translates to:
  /// **'Gesundheitstests mit dem Cube-Gerät sind nur in der Android-App verfügbar (Bluetooth). Installieren Sie die mobile App oder nutzen Sie die Web-Version für Termine und Ergebnisse.'**
  String get cubeWebStubMessage;

  /// No description provided for @btGoToHome.
  ///
  /// In de, this message translates to:
  /// **'Zur Startseite'**
  String get btGoToHome;

  /// No description provided for @btBack.
  ///
  /// In de, this message translates to:
  /// **'Zurück'**
  String get btBack;

  /// No description provided for @testStartFailed.
  ///
  /// In de, this message translates to:
  /// **'Test konnte nicht gestartet werden'**
  String get testStartFailed;

  /// No description provided for @testPreAnamnesisTitle.
  ///
  /// In de, this message translates to:
  /// **'Vorab-Anamnese'**
  String get testPreAnamnesisTitle;

  /// No description provided for @testAnamnesisPrompt.
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie vor dem RheumaCheck-Test den Anamnese-Fragebogen (Bogen A) ausfüllen? Das dauert nur wenige Minuten.'**
  String get testAnamnesisPrompt;

  /// No description provided for @testSkip.
  ///
  /// In de, this message translates to:
  /// **'Überspringen'**
  String get testSkip;

  /// No description provided for @testStartAnamnesis.
  ///
  /// In de, this message translates to:
  /// **'Anamnese starten'**
  String get testStartAnamnesis;

  /// No description provided for @testSelectTitle.
  ///
  /// In de, this message translates to:
  /// **'Testtyp auswählen'**
  String get testSelectTitle;

  /// No description provided for @testLoadError.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Laden der Tests'**
  String get testLoadError;

  /// No description provided for @testNoneAvailable.
  ///
  /// In de, this message translates to:
  /// **'Keine Tests verfügbar'**
  String get testNoneAvailable;

  /// No description provided for @testRheumaDescriptionFallback.
  ///
  /// In de, this message translates to:
  /// **'Screening-Test auf rheumatoide Arthritis'**
  String get testRheumaDescriptionFallback;

  /// No description provided for @testAgreeTermsError.
  ///
  /// In de, this message translates to:
  /// **'Bitte stimmen Sie den Bedingungen zu.'**
  String get testAgreeTermsError;

  /// No description provided for @testSubmitTitle.
  ///
  /// In de, this message translates to:
  /// **'Test abschließen'**
  String get testSubmitTitle;

  /// No description provided for @testCubeResult.
  ///
  /// In de, this message translates to:
  /// **'Cube-Ergebnis: {result}'**
  String testCubeResult(String result);

  /// No description provided for @testPhotoOptional.
  ///
  /// In de, this message translates to:
  /// **'Testfoto (optional)'**
  String get testPhotoOptional;

  /// No description provided for @testVideoOptional.
  ///
  /// In de, this message translates to:
  /// **'Testvideo (optional)'**
  String get testVideoOptional;

  /// No description provided for @testIdFront.
  ///
  /// In de, this message translates to:
  /// **'Ausweis Vorderseite'**
  String get testIdFront;

  /// No description provided for @testIdBack.
  ///
  /// In de, this message translates to:
  /// **'Ausweis Rückseite'**
  String get testIdBack;

  /// No description provided for @testAgreementText.
  ///
  /// In de, this message translates to:
  /// **'Ich bestätige die Richtigkeit der Angaben und akzeptiere die Testbedingungen.'**
  String get testAgreementText;

  /// No description provided for @testTermsLink.
  ///
  /// In de, this message translates to:
  /// **'Testbedingungen'**
  String get testTermsLink;

  /// No description provided for @testPrivacyLink.
  ///
  /// In de, this message translates to:
  /// **'Datenschutz'**
  String get testPrivacyLink;

  /// No description provided for @testSending.
  ///
  /// In de, this message translates to:
  /// **'Wird gesendet…'**
  String get testSending;

  /// No description provided for @testSubmitButton.
  ///
  /// In de, this message translates to:
  /// **'Test absenden'**
  String get testSubmitButton;

  /// No description provided for @testUploadedAs.
  ///
  /// In de, this message translates to:
  /// **'Hochgeladen: {name}'**
  String testUploadedAs(String name);

  /// No description provided for @btConnected.
  ///
  /// In de, this message translates to:
  /// **'Verbunden'**
  String get btConnected;

  /// No description provided for @btUnknownDevice.
  ///
  /// In de, this message translates to:
  /// **'Unbekanntes Gerät'**
  String get btUnknownDevice;

  /// No description provided for @btServices.
  ///
  /// In de, this message translates to:
  /// **'Dienste'**
  String get btServices;

  /// No description provided for @btRead.
  ///
  /// In de, this message translates to:
  /// **'Lesen'**
  String get btRead;

  /// No description provided for @btWrite.
  ///
  /// In de, this message translates to:
  /// **'Schreiben'**
  String get btWrite;

  /// No description provided for @btSubscribe.
  ///
  /// In de, this message translates to:
  /// **'Abonnieren'**
  String get btSubscribe;

  /// No description provided for @btDisconnect.
  ///
  /// In de, this message translates to:
  /// **'Trennen'**
  String get btDisconnect;

  /// No description provided for @btNoDeviceConnected.
  ///
  /// In de, this message translates to:
  /// **'Kein Gerät verbunden'**
  String get btNoDeviceConnected;

  /// No description provided for @btSearchPrompt.
  ///
  /// In de, this message translates to:
  /// **'Suchen Sie nach einem Bluetooth-Gerät und verbinden Sie sich, um zu beginnen'**
  String get btSearchPrompt;

  /// No description provided for @btSearchDevices.
  ///
  /// In de, this message translates to:
  /// **'Nach Geräten suchen'**
  String get btSearchDevices;

  /// No description provided for @btDisconnectTitle.
  ///
  /// In de, this message translates to:
  /// **'Gerät trennen'**
  String get btDisconnectTitle;

  /// No description provided for @btDisconnectConfirm.
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie die Verbindung wirklich trennen?'**
  String get btDisconnectConfirm;

  /// No description provided for @btDisconnected.
  ///
  /// In de, this message translates to:
  /// **'Getrennt'**
  String get btDisconnected;

  /// No description provided for @btReadData.
  ///
  /// In de, this message translates to:
  /// **'Gelesene Daten'**
  String get btReadData;

  /// No description provided for @btReadFailed.
  ///
  /// In de, this message translates to:
  /// **'Lesen fehlgeschlagen: {error}'**
  String btReadFailed(String error);

  /// No description provided for @btWriteDataTitle.
  ///
  /// In de, this message translates to:
  /// **'Daten schreiben'**
  String get btWriteDataTitle;

  /// No description provided for @btHexInputLabel.
  ///
  /// In de, this message translates to:
  /// **'Daten eingeben (Hex-Format)'**
  String get btHexInputLabel;

  /// No description provided for @btHexInputHint.
  ///
  /// In de, this message translates to:
  /// **'z.B. 01 02 03'**
  String get btHexInputHint;

  /// No description provided for @btWriteSuccess.
  ///
  /// In de, this message translates to:
  /// **'Daten erfolgreich geschrieben'**
  String get btWriteSuccess;

  /// No description provided for @btWriteFailed.
  ///
  /// In de, this message translates to:
  /// **'Schreiben fehlgeschlagen: {error}'**
  String btWriteFailed(String error);

  /// No description provided for @btNotificationData.
  ///
  /// In de, this message translates to:
  /// **'Benachrichtigungsdaten'**
  String get btNotificationData;

  /// No description provided for @btSubscribed.
  ///
  /// In de, this message translates to:
  /// **'Benachrichtigungen abonniert'**
  String get btSubscribed;

  /// No description provided for @btSubscribeFailed.
  ///
  /// In de, this message translates to:
  /// **'Abonnieren fehlgeschlagen: {error}'**
  String btSubscribeFailed(String error);

  /// No description provided for @btClose.
  ///
  /// In de, this message translates to:
  /// **'Schließen'**
  String get btClose;

  /// No description provided for @btNoFilePath.
  ///
  /// In de, this message translates to:
  /// **'Kein Dateipfad verfügbar. Bitte über „Dateien“ wählen oder die Datei in Downloads ablegen.'**
  String get btNoFilePath;

  /// No description provided for @btCancelTestTitle.
  ///
  /// In de, this message translates to:
  /// **'Test abbrechen?'**
  String get btCancelTestTitle;

  /// No description provided for @btCancelTestBody.
  ///
  /// In de, this message translates to:
  /// **'Die laufende Messung wird beendet und Sie kehren zur Startseite zurück.'**
  String get btCancelTestBody;

  /// No description provided for @btContinue.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get btContinue;

  /// No description provided for @btDisconnectTestConfirm.
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie die Verbindung wirklich trennen? Sie müssen sich erneut verbinden, um den Test zu starten.'**
  String get btDisconnectTestConfirm;

  /// No description provided for @btCubeDisconnected.
  ///
  /// In de, this message translates to:
  /// **'Cube-Gerät getrennt'**
  String get btCubeDisconnected;

  /// No description provided for @btBluetoothDisabled.
  ///
  /// In de, this message translates to:
  /// **'Bluetooth ist deaktiviert'**
  String get btBluetoothDisabled;

  /// No description provided for @btBluetoothRequired.
  ///
  /// In de, this message translates to:
  /// **'Bluetooth muss aktiviert sein, um eine Verbindung zum Cube-Gerät herzustellen'**
  String get btBluetoothRequired;

  /// No description provided for @btTurnOnBluetooth.
  ///
  /// In de, this message translates to:
  /// **'Bluetooth aktivieren'**
  String get btTurnOnBluetooth;

  /// No description provided for @btCubeConnected.
  ///
  /// In de, this message translates to:
  /// **'Cube-Gerät verbunden'**
  String get btCubeConnected;

  /// No description provided for @btStatus.
  ///
  /// In de, this message translates to:
  /// **'Status: {state}'**
  String btStatus(String state);

  /// No description provided for @btReadyToStart.
  ///
  /// In de, this message translates to:
  /// **'Bereit zum Teststart'**
  String get btReadyToStart;

  /// No description provided for @btReadyBody.
  ///
  /// In de, this message translates to:
  /// **'Ihr Cube-Gerät ist verbunden und bereit. Sie können nun mit dem {testName} Test fortfahren.'**
  String btReadyBody(String testName);

  /// No description provided for @btMeasurementConfig.
  ///
  /// In de, this message translates to:
  /// **'Messkonfiguration (Cube)'**
  String get btMeasurementConfig;

  /// No description provided for @btConfigFile.
  ///
  /// In de, this message translates to:
  /// **'Konfigurationsdatei: {name}'**
  String btConfigFile(String name);

  /// No description provided for @btConfigDefault.
  ///
  /// In de, this message translates to:
  /// **'Standard: Kalibrierung per RFID von der eingelegten Kassette. Mit „Datei wählen“ verwenden Sie stattdessen eine `.config`/`.bin` vom Anbieter (wie in der Cube-Beispiel-App).'**
  String get btConfigDefault;

  /// No description provided for @btChooseConfigFile.
  ///
  /// In de, this message translates to:
  /// **'Konfigurationsdatei wählen'**
  String get btChooseConfigFile;

  /// No description provided for @btRfidMode.
  ///
  /// In de, this message translates to:
  /// **'RFID-Modus (Datei löschen)'**
  String get btRfidMode;

  /// No description provided for @btTestStarting.
  ///
  /// In de, this message translates to:
  /// **'Test wird gestartet...'**
  String get btTestStarting;

  /// No description provided for @btStartTest.
  ///
  /// In de, this message translates to:
  /// **'Test starten'**
  String get btStartTest;

  /// No description provided for @btNoCubeConnected.
  ///
  /// In de, this message translates to:
  /// **'Kein Cube-Gerät verbunden'**
  String get btNoCubeConnected;

  /// No description provided for @btConnectPrompt.
  ///
  /// In de, this message translates to:
  /// **'Bitte verbinden Sie Ihr Cube-Gerät, um mit dem {testName} Test fortzufahren'**
  String btConnectPrompt(String testName);

  /// No description provided for @btSearchCubeDevices.
  ///
  /// In de, this message translates to:
  /// **'Nach Cube-Geräten suchen'**
  String get btSearchCubeDevices;

  /// No description provided for @btPermissionRequired.
  ///
  /// In de, this message translates to:
  /// **'Bluetooth „Geräte in der Nähe“ / Scan und Verbinden ist erforderlich. Bitte in den App-Einstellungen erlauben.'**
  String get btPermissionRequired;

  /// No description provided for @btScanStartFailed.
  ///
  /// In de, this message translates to:
  /// **'Scan konnte nicht gestartet werden (SDK lehnt Start ab — z. B. noch verbunden oder bereits am Scannen). Tippen Sie auf Aktualisieren oder starten Sie die App neu.'**
  String get btScanStartFailed;

  /// No description provided for @btScanError.
  ///
  /// In de, this message translates to:
  /// **'Scan-Fehler: {error}'**
  String btScanError(String error);

  /// No description provided for @btConnectTimeout.
  ///
  /// In de, this message translates to:
  /// **'Verbindung zum Cube dauerte zu lange (60 s). Cube nah ans Telefon halten, Suche mit „Stopp“ beenden und erneut „Verbinden“ tippen. In Android-Bluetooth ggf. Gerät trennen (nicht nur paaren).'**
  String get btConnectTimeout;

  /// No description provided for @btConnectFailed.
  ///
  /// In de, this message translates to:
  /// **'Verbindung fehlgeschlagen'**
  String get btConnectFailed;

  /// No description provided for @btConnectError.
  ///
  /// In de, this message translates to:
  /// **'Verbindungsfehler: {error}'**
  String btConnectError(String error);

  /// No description provided for @btEnableBluetoothPrompt.
  ///
  /// In de, this message translates to:
  /// **'Bitte aktivieren Sie Bluetooth, um nach Cube-Geräten zu suchen'**
  String get btEnableBluetoothPrompt;

  /// No description provided for @btErrorTitle.
  ///
  /// In de, this message translates to:
  /// **'Fehler'**
  String get btErrorTitle;

  /// No description provided for @btSearchingCubes.
  ///
  /// In de, this message translates to:
  /// **'Suche nach Cube-Geräten...'**
  String get btSearchingCubes;

  /// No description provided for @btEnsureCubeOn.
  ///
  /// In de, this message translates to:
  /// **'Stellen Sie sicher, dass Ihr Cube eingeschaltet ist'**
  String get btEnsureCubeOn;

  /// No description provided for @btNoCubeFound.
  ///
  /// In de, this message translates to:
  /// **'Kein Cube-Gerät gefunden'**
  String get btNoCubeFound;

  /// No description provided for @btEnsureCubeInRange.
  ///
  /// In de, this message translates to:
  /// **'Stellen Sie sicher, dass Ihr Cube eingeschaltet und in Reichweite ist'**
  String get btEnsureCubeInRange;

  /// No description provided for @btCubeDevice.
  ///
  /// In de, this message translates to:
  /// **'Cube-Gerät'**
  String get btCubeDevice;

  /// No description provided for @btSearchAgain.
  ///
  /// In de, this message translates to:
  /// **'Erneut suchen'**
  String get btSearchAgain;

  /// No description provided for @btConnect.
  ///
  /// In de, this message translates to:
  /// **'Verbinden'**
  String get btConnect;

  /// No description provided for @testPreparing.
  ///
  /// In de, this message translates to:
  /// **'Messung wird vorbereitet...'**
  String get testPreparing;

  /// No description provided for @testLeaveConfirm.
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie die Messung verlassen und zur Startseite zurückkehren?'**
  String get testLeaveConfirm;

  /// No description provided for @testUnknownError.
  ///
  /// In de, this message translates to:
  /// **'Unbekannter Fehler'**
  String get testUnknownError;

  /// No description provided for @testMeasurementFailed.
  ///
  /// In de, this message translates to:
  /// **'Messung fehlgeschlagen'**
  String get testMeasurementFailed;

  /// No description provided for @testBackToStart.
  ///
  /// In de, this message translates to:
  /// **'Zurück zum Start'**
  String get testBackToStart;

  /// No description provided for @testIncubationTime.
  ///
  /// In de, this message translates to:
  /// **'Inkubationszeit'**
  String get testIncubationTime;

  /// No description provided for @testRemaining.
  ///
  /// In de, this message translates to:
  /// **'verbleibend'**
  String get testRemaining;

  /// No description provided for @testInsertWhiteCassette.
  ///
  /// In de, this message translates to:
  /// **'Weiße Kassette einlegen'**
  String get testInsertWhiteCassette;

  /// No description provided for @testInsertTestCassette.
  ///
  /// In de, this message translates to:
  /// **'Testkassette einlegen'**
  String get testInsertTestCassette;

  /// No description provided for @testEvaluating.
  ///
  /// In de, this message translates to:
  /// **'Messung auswerten'**
  String get testEvaluating;

  /// No description provided for @testLoadingResults.
  ///
  /// In de, this message translates to:
  /// **'Ergebnisse laden'**
  String get testLoadingResults;

  /// No description provided for @testSubmittingResults.
  ///
  /// In de, this message translates to:
  /// **'Ergebnisse übermitteln'**
  String get testSubmittingResults;

  /// No description provided for @testResultsTitle.
  ///
  /// In de, this message translates to:
  /// **'Testergebnisse'**
  String get testResultsTitle;

  /// No description provided for @testTapForDetails.
  ///
  /// In de, this message translates to:
  /// **'Tippen Sie auf einen Eintrag für Details.'**
  String get testTapForDetails;

  /// No description provided for @testResultsLoadError.
  ///
  /// In de, this message translates to:
  /// **'Ergebnisse konnten nicht geladen werden'**
  String get testResultsLoadError;

  /// No description provided for @testNoResultsYet.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Testergebnisse'**
  String get testNoResultsYet;

  /// No description provided for @testResultsWebHint.
  ///
  /// In de, this message translates to:
  /// **'Ergebnisse erscheinen hier nach einem Test in der Android-App.'**
  String get testResultsWebHint;

  /// No description provided for @testStartToSeeResults.
  ///
  /// In de, this message translates to:
  /// **'Starten Sie einen Test, um Ergebnisse zu sehen.'**
  String get testStartToSeeResults;

  /// No description provided for @testResultTitle.
  ///
  /// In de, this message translates to:
  /// **'Testergebnis'**
  String get testResultTitle;

  /// No description provided for @testResultPending.
  ///
  /// In de, this message translates to:
  /// **'Das Testergebnis liegt noch nicht vor.'**
  String get testResultPending;

  /// No description provided for @testDetailedResults.
  ///
  /// In de, this message translates to:
  /// **'Detaillierte Ergebnisse'**
  String get testDetailedResults;

  /// No description provided for @testRecommended.
  ///
  /// In de, this message translates to:
  /// **'Empfohlen: {specialization}'**
  String testRecommended(String specialization);

  /// No description provided for @testUsabilityQuestionnaire.
  ///
  /// In de, this message translates to:
  /// **'Usability-Fragebogen (Bogen C)'**
  String get testUsabilityQuestionnaire;

  /// No description provided for @testBackToResults.
  ///
  /// In de, this message translates to:
  /// **'Zurück zu Ergebnissen'**
  String get testBackToResults;

  /// No description provided for @testBookSpecialist.
  ///
  /// In de, this message translates to:
  /// **'Termin mit Facharzt buchen'**
  String get testBookSpecialist;

  /// No description provided for @navHome.
  ///
  /// In de, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navAppointments.
  ///
  /// In de, this message translates to:
  /// **'Termine'**
  String get navAppointments;

  /// No description provided for @navResults.
  ///
  /// In de, this message translates to:
  /// **'Ergebnisse'**
  String get navResults;

  /// No description provided for @navQuestionnaires.
  ///
  /// In de, this message translates to:
  /// **'Fragebögen'**
  String get navQuestionnaires;

  /// No description provided for @navShop.
  ///
  /// In de, this message translates to:
  /// **'Shop'**
  String get navShop;

  /// No description provided for @navNotifications.
  ///
  /// In de, this message translates to:
  /// **'Benachrichtigungen'**
  String get navNotifications;

  /// No description provided for @navPayments.
  ///
  /// In de, this message translates to:
  /// **'Zahlungsverlauf'**
  String get navPayments;

  /// No description provided for @navProfile.
  ///
  /// In de, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @navDashboard.
  ///
  /// In de, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navAvailability.
  ///
  /// In de, this message translates to:
  /// **'Verfügbarkeit'**
  String get navAvailability;

  /// No description provided for @navVideoCall.
  ///
  /// In de, this message translates to:
  /// **'Videoanruf'**
  String get navVideoCall;

  /// No description provided for @navAppointment.
  ///
  /// In de, this message translates to:
  /// **'Termin'**
  String get navAppointment;

  /// No description provided for @navResult.
  ///
  /// In de, this message translates to:
  /// **'Ergebnis'**
  String get navResult;

  /// No description provided for @navTests.
  ///
  /// In de, this message translates to:
  /// **'Tests'**
  String get navTests;

  /// No description provided for @navTestPrepare.
  ///
  /// In de, this message translates to:
  /// **'Test vorbereiten'**
  String get navTestPrepare;

  /// No description provided for @navTestSubmit.
  ///
  /// In de, this message translates to:
  /// **'Test einreichen'**
  String get navTestSubmit;

  /// No description provided for @navTestFallback.
  ///
  /// In de, this message translates to:
  /// **'Test'**
  String get navTestFallback;

  /// No description provided for @navDoctorFallback.
  ///
  /// In de, this message translates to:
  /// **'Arzt'**
  String get navDoctorFallback;

  /// No description provided for @navCertificates.
  ///
  /// In de, this message translates to:
  /// **'Dokumente'**
  String get navCertificates;

  /// No description provided for @navApp.
  ///
  /// In de, this message translates to:
  /// **'App'**
  String get navApp;

  /// No description provided for @navSignIn.
  ///
  /// In de, this message translates to:
  /// **'Anmelden'**
  String get navSignIn;

  /// No description provided for @navRegister.
  ///
  /// In de, this message translates to:
  /// **'Registrieren'**
  String get navRegister;

  /// No description provided for @homeUserFallback.
  ///
  /// In de, this message translates to:
  /// **'Benutzer'**
  String get homeUserFallback;

  /// No description provided for @homeLogout.
  ///
  /// In de, this message translates to:
  /// **'Abmelden'**
  String get homeLogout;

  /// No description provided for @homeWelcomeBack.
  ///
  /// In de, this message translates to:
  /// **'Willkommen zurück'**
  String get homeWelcomeBack;

  /// No description provided for @homeGreeting.
  ///
  /// In de, this message translates to:
  /// **'Hallo {name} — wählen Sie unten eine Schnellaktion.'**
  String homeGreeting(String name);

  /// No description provided for @homeGettingStarted.
  ///
  /// In de, this message translates to:
  /// **'Erste Schritte'**
  String get homeGettingStarted;

  /// No description provided for @homeRecentActivity.
  ///
  /// In de, this message translates to:
  /// **'Letzte Aktivität'**
  String get homeRecentActivity;

  /// No description provided for @homeQuickActions.
  ///
  /// In de, this message translates to:
  /// **'Schnellaktionen'**
  String get homeQuickActions;

  /// No description provided for @homeStartTest.
  ///
  /// In de, this message translates to:
  /// **'Test starten'**
  String get homeStartTest;

  /// No description provided for @homeOnlineConsultation.
  ///
  /// In de, this message translates to:
  /// **'Online Sprechstunde'**
  String get homeOnlineConsultation;

  /// No description provided for @homeMyAppointments.
  ///
  /// In de, this message translates to:
  /// **'Meine Termine'**
  String get homeMyAppointments;

  /// No description provided for @notifMarkAllRead.
  ///
  /// In de, this message translates to:
  /// **'Alle gelesen'**
  String get notifMarkAllRead;

  /// No description provided for @notifLoadError.
  ///
  /// In de, this message translates to:
  /// **'Benachrichtigungen konnten nicht geladen werden'**
  String get notifLoadError;

  /// No description provided for @notifTapHint.
  ///
  /// In de, this message translates to:
  /// **'Tippen Sie auf eine Meldung, um sie als gelesen zu markieren.'**
  String get notifTapHint;

  /// No description provided for @notifEmptyTitle.
  ///
  /// In de, this message translates to:
  /// **'Keine Benachrichtigungen'**
  String get notifEmptyTitle;

  /// No description provided for @notifEmptyMessage.
  ///
  /// In de, this message translates to:
  /// **'Sie sind auf dem neuesten Stand.'**
  String get notifEmptyMessage;

  /// No description provided for @profileSaved.
  ///
  /// In de, this message translates to:
  /// **'Profil gespeichert'**
  String get profileSaved;

  /// No description provided for @profileErrorWith.
  ///
  /// In de, this message translates to:
  /// **'Fehler: {message}'**
  String profileErrorWith(String message);

  /// No description provided for @profileLoadError.
  ///
  /// In de, this message translates to:
  /// **'Fehler beim Laden des Profils'**
  String get profileLoadError;

  /// No description provided for @profileFirstName.
  ///
  /// In de, this message translates to:
  /// **'Vorname'**
  String get profileFirstName;

  /// No description provided for @profileFirstNameRequired.
  ///
  /// In de, this message translates to:
  /// **'Vorname ist erforderlich'**
  String get profileFirstNameRequired;

  /// No description provided for @profileLastName.
  ///
  /// In de, this message translates to:
  /// **'Nachname'**
  String get profileLastName;

  /// No description provided for @profileLastNameRequired.
  ///
  /// In de, this message translates to:
  /// **'Nachname ist erforderlich'**
  String get profileLastNameRequired;

  /// No description provided for @profileEmail.
  ///
  /// In de, this message translates to:
  /// **'E-mail'**
  String get profileEmail;

  /// No description provided for @profileEmailRequired.
  ///
  /// In de, this message translates to:
  /// **'E-mail ist erforderlich'**
  String get profileEmailRequired;

  /// No description provided for @profilePhone.
  ///
  /// In de, this message translates to:
  /// **'Handynummer'**
  String get profilePhone;

  /// No description provided for @profileAddress.
  ///
  /// In de, this message translates to:
  /// **'Adresse'**
  String get profileAddress;

  /// No description provided for @profilePostcode.
  ///
  /// In de, this message translates to:
  /// **'PLZ'**
  String get profilePostcode;

  /// No description provided for @profileCity.
  ///
  /// In de, this message translates to:
  /// **'Stadt'**
  String get profileCity;

  /// No description provided for @profileCountry.
  ///
  /// In de, this message translates to:
  /// **'Land'**
  String get profileCountry;

  /// No description provided for @profileGender.
  ///
  /// In de, this message translates to:
  /// **'Geschlecht'**
  String get profileGender;

  /// No description provided for @profileGenderRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte Geschlecht auswählen'**
  String get profileGenderRequired;

  /// No description provided for @profileGenderMale.
  ///
  /// In de, this message translates to:
  /// **'Männlich'**
  String get profileGenderMale;

  /// No description provided for @profileGenderFemale.
  ///
  /// In de, this message translates to:
  /// **'Weiblich'**
  String get profileGenderFemale;

  /// No description provided for @profileGenderDivers.
  ///
  /// In de, this message translates to:
  /// **'Divers'**
  String get profileGenderDivers;

  /// No description provided for @profileSaving.
  ///
  /// In de, this message translates to:
  /// **'Speichern…'**
  String get profileSaving;

  /// No description provided for @profileSaveChanges.
  ///
  /// In de, this message translates to:
  /// **'Änderungen speichern'**
  String get profileSaveChanges;

  /// No description provided for @profileCubeSdkTitle.
  ///
  /// In de, this message translates to:
  /// **'Cube-Gerät (SDK)'**
  String get profileCubeSdkTitle;

  /// No description provided for @profileCubeSdkChecking.
  ///
  /// In de, this message translates to:
  /// **'Cube-SDK wird geprüft…'**
  String get profileCubeSdkChecking;

  /// No description provided for @profileVersion.
  ///
  /// In de, this message translates to:
  /// **'Version: {version}'**
  String profileVersion(String version);

  /// No description provided for @profileLicenseValid.
  ///
  /// In de, this message translates to:
  /// **'Bundled-Lizenz: gültig (laut SDK)'**
  String get profileLicenseValid;

  /// No description provided for @profileLicenseInvalid.
  ///
  /// In de, this message translates to:
  /// **'Bundled-Lizenz: ungültig oder abgelaufen — neue cube_license.dat vom Anbieter einspielen und App neu bauen.'**
  String get profileLicenseInvalid;

  /// No description provided for @shopTitle.
  ///
  /// In de, this message translates to:
  /// **'Shop'**
  String get shopTitle;

  /// No description provided for @shopFilterAll.
  ///
  /// In de, this message translates to:
  /// **'Alle'**
  String get shopFilterAll;

  /// No description provided for @shopFilterTestStrips.
  ///
  /// In de, this message translates to:
  /// **'Teststreifen'**
  String get shopFilterTestStrips;

  /// No description provided for @shopFilterTestDevices.
  ///
  /// In de, this message translates to:
  /// **'Testgeräte'**
  String get shopFilterTestDevices;

  /// No description provided for @shopLoadError.
  ///
  /// In de, this message translates to:
  /// **'Shop konnte nicht geladen werden'**
  String get shopLoadError;

  /// No description provided for @shopNoProducts.
  ///
  /// In de, this message translates to:
  /// **'Keine Produkte gefunden'**
  String get shopNoProducts;

  /// No description provided for @shopNoProductsMessage.
  ///
  /// In de, this message translates to:
  /// **'In dieser Kategorie sind derzeit keine Artikel verfügbar.'**
  String get shopNoProductsMessage;

  /// No description provided for @shopItemAdded.
  ///
  /// In de, this message translates to:
  /// **'{name} hinzugefügt'**
  String shopItemAdded(String name);

  /// No description provided for @shopSoldOut.
  ///
  /// In de, this message translates to:
  /// **'Ausverkauft'**
  String get shopSoldOut;

  /// No description provided for @shopCategoryTestStrip.
  ///
  /// In de, this message translates to:
  /// **'Teststreifen'**
  String get shopCategoryTestStrip;

  /// No description provided for @shopCategoryTestDevice.
  ///
  /// In de, this message translates to:
  /// **'Testgerät'**
  String get shopCategoryTestDevice;

  /// No description provided for @shopCategoryAccessory.
  ///
  /// In de, this message translates to:
  /// **'Zubehör'**
  String get shopCategoryAccessory;

  /// No description provided for @shopCategoryOther.
  ///
  /// In de, this message translates to:
  /// **'Sonstiges'**
  String get shopCategoryOther;

  /// No description provided for @shopQuantity.
  ///
  /// In de, this message translates to:
  /// **'Menge'**
  String get shopQuantity;

  /// No description provided for @shopTotalAmount.
  ///
  /// In de, this message translates to:
  /// **'Gesamt: {amount} €'**
  String shopTotalAmount(String amount);

  /// No description provided for @shopAddToCart.
  ///
  /// In de, this message translates to:
  /// **'In den Warenkorb'**
  String get shopAddToCart;

  /// No description provided for @shopUnavailable.
  ///
  /// In de, this message translates to:
  /// **'Derzeit nicht verfügbar'**
  String get shopUnavailable;

  /// No description provided for @shopAddedToCart.
  ///
  /// In de, this message translates to:
  /// **'{name} zum Warenkorb hinzugefügt'**
  String shopAddedToCart(String name);

  /// No description provided for @shopViewCart.
  ///
  /// In de, this message translates to:
  /// **'Warenkorb anzeigen'**
  String get shopViewCart;

  /// No description provided for @shopGoToShop.
  ///
  /// In de, this message translates to:
  /// **'Zum Shop'**
  String get shopGoToShop;

  /// No description provided for @cartTitle.
  ///
  /// In de, this message translates to:
  /// **'Warenkorb'**
  String get cartTitle;

  /// No description provided for @cartCheckout.
  ///
  /// In de, this message translates to:
  /// **'Zur Kasse'**
  String get cartCheckout;

  /// No description provided for @cartEmpty.
  ///
  /// In de, this message translates to:
  /// **'Ihr Warenkorb ist leer'**
  String get cartEmpty;

  /// No description provided for @cartEmptyMessage.
  ///
  /// In de, this message translates to:
  /// **'Stöbern Sie im Shop und fügen Sie Produkte hinzu.'**
  String get cartEmptyMessage;

  /// No description provided for @cartRemove.
  ///
  /// In de, this message translates to:
  /// **'Entfernen'**
  String get cartRemove;

  /// No description provided for @cartTotal.
  ///
  /// In de, this message translates to:
  /// **'Gesamt'**
  String get cartTotal;

  /// No description provided for @checkoutTitle.
  ///
  /// In de, this message translates to:
  /// **'Kasse'**
  String get checkoutTitle;

  /// No description provided for @checkoutSummary.
  ///
  /// In de, this message translates to:
  /// **'Bestellübersicht'**
  String get checkoutSummary;

  /// No description provided for @checkoutPayNow.
  ///
  /// In de, this message translates to:
  /// **'Jetzt zahlen'**
  String get checkoutPayNow;

  /// No description provided for @checkoutEmptyMessage.
  ///
  /// In de, this message translates to:
  /// **'Fügen Sie Produkte hinzu, um zur Kasse zu gehen.'**
  String get checkoutEmptyMessage;

  /// No description provided for @checkoutNotLoggedIn.
  ///
  /// In de, this message translates to:
  /// **'Benutzer nicht angemeldet.'**
  String get checkoutNotLoggedIn;

  /// No description provided for @checkoutInvalidAmount.
  ///
  /// In de, this message translates to:
  /// **'Ungültiger Betrag'**
  String get checkoutInvalidAmount;

  /// No description provided for @orderTitle.
  ///
  /// In de, this message translates to:
  /// **'Bestellung abgeschlossen'**
  String get orderTitle;

  /// No description provided for @orderSubtitle.
  ///
  /// In de, this message translates to:
  /// **'Vielen Dank. Ihre Bestellung wurde erfolgreich erfasst.'**
  String get orderSubtitle;

  /// No description provided for @orderBackToHome.
  ///
  /// In de, this message translates to:
  /// **'Zur Startseite'**
  String get orderBackToHome;

  /// No description provided for @orderTotal.
  ///
  /// In de, this message translates to:
  /// **'Gesamt: {amount} {currency}'**
  String orderTotal(String amount, String currency);

  /// No description provided for @certTitle.
  ///
  /// In de, this message translates to:
  /// **'Dokumente'**
  String get certTitle;

  /// No description provided for @certDetailTitle.
  ///
  /// In de, this message translates to:
  /// **'Dokument'**
  String get certDetailTitle;

  /// No description provided for @certTapHint.
  ///
  /// In de, this message translates to:
  /// **'Tippen Sie auf ein Dokument für Details.'**
  String get certTapHint;

  /// No description provided for @certLoadError.
  ///
  /// In de, this message translates to:
  /// **'Dokumente konnten nicht geladen werden'**
  String get certLoadError;

  /// No description provided for @certEmpty.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Dokumente'**
  String get certEmpty;

  /// No description provided for @certEmptyMessage.
  ///
  /// In de, this message translates to:
  /// **'Dokumente erscheinen hier nach einem abgeschlossenen Test.'**
  String get certEmptyMessage;

  /// No description provided for @certTest.
  ///
  /// In de, this message translates to:
  /// **'Test'**
  String get certTest;

  /// No description provided for @certStatusIssued.
  ///
  /// In de, this message translates to:
  /// **'Ausgestellt'**
  String get certStatusIssued;

  /// No description provided for @certStatusDraft.
  ///
  /// In de, this message translates to:
  /// **'Entwurf'**
  String get certStatusDraft;

  /// No description provided for @certStatusExpired.
  ///
  /// In de, this message translates to:
  /// **'Abgelaufen'**
  String get certStatusExpired;

  /// No description provided for @certStatusRevoked.
  ///
  /// In de, this message translates to:
  /// **'Widerrufen'**
  String get certStatusRevoked;

  /// No description provided for @certTypeTestResult.
  ///
  /// In de, this message translates to:
  /// **'Testergebnis'**
  String get certTypeTestResult;

  /// No description provided for @certTypeVaccination.
  ///
  /// In de, this message translates to:
  /// **'Impfung'**
  String get certTypeVaccination;

  /// No description provided for @certTypeRecovery.
  ///
  /// In de, this message translates to:
  /// **'Genesung'**
  String get certTypeRecovery;

  /// No description provided for @certTypeMedicalClearance.
  ///
  /// In de, this message translates to:
  /// **'Ärztliche Freigabe'**
  String get certTypeMedicalClearance;

  /// No description provided for @certSharePdf.
  ///
  /// In de, this message translates to:
  /// **'PDF teilen'**
  String get certSharePdf;

  /// No description provided for @certLoading.
  ///
  /// In de, this message translates to:
  /// **'Wird geladen…'**
  String get certLoading;

  /// No description provided for @certNotFound.
  ///
  /// In de, this message translates to:
  /// **'Dokument nicht gefunden'**
  String get certNotFound;

  /// No description provided for @certPdfDownload.
  ///
  /// In de, this message translates to:
  /// **'PDF-Download'**
  String get certPdfDownload;

  /// No description provided for @certPdfDownloadHint.
  ///
  /// In de, this message translates to:
  /// **'Öffnen Sie die HomeDX-App auf Ihrem Smartphone, um dieses Dokument als PDF zu teilen.'**
  String get certPdfDownloadHint;

  /// No description provided for @certPdfSaved.
  ///
  /// In de, this message translates to:
  /// **'PDF gespeichert: {path}'**
  String certPdfSaved(String path);

  /// No description provided for @certErrorWith.
  ///
  /// In de, this message translates to:
  /// **'Fehler: {error}'**
  String certErrorWith(String error);

  /// No description provided for @certResult.
  ///
  /// In de, this message translates to:
  /// **'Ergebnis'**
  String get certResult;

  /// No description provided for @certValidity.
  ///
  /// In de, this message translates to:
  /// **'Gültigkeit'**
  String get certValidity;

  /// No description provided for @certIssuedOn.
  ///
  /// In de, this message translates to:
  /// **'Ausgestellt am'**
  String get certIssuedOn;

  /// No description provided for @questTitle.
  ///
  /// In de, this message translates to:
  /// **'Fragebögen'**
  String get questTitle;

  /// No description provided for @questLoadError.
  ///
  /// In de, this message translates to:
  /// **'Fragebögen konnten nicht geladen werden'**
  String get questLoadError;

  /// No description provided for @questEmpty.
  ///
  /// In de, this message translates to:
  /// **'Keine Fragebögen verfügbar'**
  String get questEmpty;

  /// No description provided for @questEmptyMessage.
  ///
  /// In de, this message translates to:
  /// **'Sobald Fragebögen freigeschaltet sind, erscheinen sie hier.'**
  String get questEmptyMessage;

  /// No description provided for @questHubIntroDoctor.
  ///
  /// In de, this message translates to:
  /// **'Im Rahmen von RheumaCheck erfassen diese Fragebögen strukturierte Angaben aus Sicht des Rheumanetzwerks und zur Implementierbarkeit in der Praxis. Ihre Antworten unterstützen die Begleitforschung und die Weiterentwicklung von HomeDX — sie ersetzen keine Diagnose und geben keine Behandlungsempfehlungen.'**
  String get questHubIntroDoctor;

  /// No description provided for @questHubIntroPatient.
  ///
  /// In de, this message translates to:
  /// **'Im Rahmen von RheumaCheck helfen diese Fragebögen, Ihre Angaben vor dem Test und Ihr Feedback nach der Nutzung strukturiert zu erfassen. So können wir HomeDX verbessern und die Versorgung besser verstehen. Die Fragebögen ersetzen keine ärztliche Diagnose.'**
  String get questHubIntroPatient;

  /// No description provided for @questBadgeBeforeTest.
  ///
  /// In de, this message translates to:
  /// **'Vor dem Test'**
  String get questBadgeBeforeTest;

  /// No description provided for @questBadgeNetwork.
  ///
  /// In de, this message translates to:
  /// **'Rheumanetzwerk'**
  String get questBadgeNetwork;

  /// No description provided for @questBadgeAfterUse.
  ///
  /// In de, this message translates to:
  /// **'Nach Nutzung'**
  String get questBadgeAfterUse;

  /// No description provided for @questBadgePilot.
  ///
  /// In de, this message translates to:
  /// **'Pilot / Implementierung'**
  String get questBadgePilot;

  /// No description provided for @questModuleLabel.
  ///
  /// In de, this message translates to:
  /// **'Bogen {moduleId}'**
  String questModuleLabel(String moduleId);

  /// No description provided for @questResume.
  ///
  /// In de, this message translates to:
  /// **'Entwurf fortsetzen'**
  String get questResume;

  /// No description provided for @questStartNow.
  ///
  /// In de, this message translates to:
  /// **'Jetzt starten'**
  String get questStartNow;

  /// No description provided for @questDoneTitle.
  ///
  /// In de, this message translates to:
  /// **'Fragebogen abgeschlossen'**
  String get questDoneTitle;

  /// No description provided for @questThanks.
  ///
  /// In de, this message translates to:
  /// **'Vielen Dank!'**
  String get questThanks;

  /// No description provided for @questDoneMessage.
  ///
  /// In de, this message translates to:
  /// **'Bogen {moduleId} wurde erfolgreich übermittelt. Ihre Antworten wurden gespeichert.'**
  String questDoneMessage(String moduleId);

  /// No description provided for @questBackToList.
  ///
  /// In de, this message translates to:
  /// **'Zurück zu Fragebögen'**
  String get questBackToList;

  /// No description provided for @questContinue.
  ///
  /// In de, this message translates to:
  /// **'Weiter im Ablauf'**
  String get questContinue;

  /// No description provided for @questIntroPatientNotice.
  ///
  /// In de, this message translates to:
  /// **'Dieser Fragebogen ersetzt keine ärztliche Diagnose. Bei akuten oder starken Beschwerden wenden Sie sich bitte an eine Ärztin oder einen Arzt.'**
  String get questIntroPatientNotice;

  /// No description provided for @questConsentCheckbox.
  ///
  /// In de, this message translates to:
  /// **'Ich willige ein, dass meine Antworten zur Auswertung des RheumaCheck-Projekts gespeichert werden.'**
  String get questConsentCheckbox;

  /// No description provided for @questIntroResearchNotice.
  ///
  /// In de, this message translates to:
  /// **'Dieser Fragebogen dient der Forschung und Pilotierung von RheumaCheck. Es werden keine Diagnosen abgegeben.'**
  String get questIntroResearchNotice;

  /// No description provided for @questStart.
  ///
  /// In de, this message translates to:
  /// **'Fragebogen starten'**
  String get questStart;

  /// No description provided for @questStepProgress.
  ///
  /// In de, this message translates to:
  /// **'Schritt {index} von {total}'**
  String questStepProgress(String index, String total);

  /// No description provided for @questBack.
  ///
  /// In de, this message translates to:
  /// **'Zurück'**
  String get questBack;

  /// No description provided for @questNext.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get questNext;

  /// No description provided for @questSubmit.
  ///
  /// In de, this message translates to:
  /// **'Absenden'**
  String get questSubmit;

  /// No description provided for @questFallbackTitle.
  ///
  /// In de, this message translates to:
  /// **'Fragebogen {moduleId}'**
  String questFallbackTitle(String moduleId);

  /// No description provided for @questLoadFailed.
  ///
  /// In de, this message translates to:
  /// **'Fragebogen konnte nicht geladen werden'**
  String get questLoadFailed;

  /// No description provided for @questAnswerRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte beantworten Sie: {label}'**
  String questAnswerRequired(String label);

  /// No description provided for @questConsentRequired.
  ///
  /// In de, this message translates to:
  /// **'Bitte bestätigen Sie den Hinweis zur Einwilligung.'**
  String get questConsentRequired;

  /// No description provided for @questSelectHint.
  ///
  /// In de, this message translates to:
  /// **'Auswählen'**
  String get questSelectHint;

  /// No description provided for @questBadgeFollowUp.
  ///
  /// In de, this message translates to:
  /// **'Nachbefragung'**
  String get questBadgeFollowUp;

  /// No description provided for @questNotAssigned.
  ///
  /// In de, this message translates to:
  /// **'Noch nicht vorgesehen'**
  String get questNotAssigned;

  /// No description provided for @questNotAssignedMessage.
  ///
  /// In de, this message translates to:
  /// **'Dieser Fragebogen ist noch nicht vorgesehen. Er wird erst nach einer gesonderten Einladung verfügbar.'**
  String get questNotAssignedMessage;

  /// No description provided for @questRequiredMarker.
  ///
  /// In de, this message translates to:
  /// **'Pflichtfeld'**
  String get questRequiredMarker;

  /// No description provided for @questUnsupportedQuestion.
  ///
  /// In de, this message translates to:
  /// **'Diese Frage kann in dieser Version nicht angezeigt werden.'**
  String get questUnsupportedQuestion;

  /// No description provided for @questRankHint.
  ///
  /// In de, this message translates to:
  /// **'Bitte wählen Sie bis zu {maximum} Antworten in der gewünschten Reihenfolge.'**
  String questRankHint(int maximum);

  /// No description provided for @questRevisionConflict.
  ///
  /// In de, this message translates to:
  /// **'Ihr Entwurf wurde inzwischen an anderer Stelle geändert. Bitte laden Sie den Fragebogen neu.'**
  String get questRevisionConflict;

  /// No description provided for @questCheckAnswers.
  ///
  /// In de, this message translates to:
  /// **'Bitte prüfen Sie Ihre Angaben. Einige Fragen sind unvollständig oder ungültig.'**
  String get questCheckAnswers;

  /// No description provided for @questSaveFailed.
  ///
  /// In de, this message translates to:
  /// **'Speichern fehlgeschlagen. Bitte versuchen Sie es erneut.'**
  String get questSaveFailed;

  /// No description provided for @questNoQuestions.
  ///
  /// In de, this message translates to:
  /// **'Keine weiteren Fragen'**
  String get questNoQuestions;

  /// No description provided for @questNoQuestionsMessage.
  ///
  /// In de, this message translates to:
  /// **'Für Ihre bisherigen Angaben gibt es in diesem Bogen keine weiteren Fragen.'**
  String get questNoQuestionsMessage;

  /// No description provided for @questDemoBanner.
  ///
  /// In de, this message translates to:
  /// **'DEMO – nur synthetische Beispielantworten. Es wird nichts gespeichert oder übermittelt.'**
  String get questDemoBanner;

  /// No description provided for @questDemoPrefill.
  ///
  /// In de, this message translates to:
  /// **'Synthetisches Beispiel vorbefüllen'**
  String get questDemoPrefill;

  /// No description provided for @questOpenOverview.
  ///
  /// In de, this message translates to:
  /// **'Antwortübersicht'**
  String get questOpenOverview;

  /// No description provided for @questOverviewTitle.
  ///
  /// In de, this message translates to:
  /// **'Antwortübersicht'**
  String get questOverviewTitle;

  /// No description provided for @questOverviewHint.
  ///
  /// In de, this message translates to:
  /// **'Prüfen Sie Ihre Angaben. Mit „Ändern“ springen Sie direkt zum Abschnitt.'**
  String get questOverviewHint;

  /// No description provided for @questEditSection.
  ///
  /// In de, this message translates to:
  /// **'Ändern'**
  String get questEditSection;

  /// No description provided for @questNotAnswered.
  ///
  /// In de, this message translates to:
  /// **'nicht beantwortet'**
  String get questNotAnswered;

  /// No description provided for @questSendAnswers.
  ///
  /// In de, this message translates to:
  /// **'Absenden'**
  String get questSendAnswers;

  /// No description provided for @questDoneYourAnswers.
  ///
  /// In de, this message translates to:
  /// **'Ihre Angaben'**
  String get questDoneYourAnswers;

  /// No description provided for @questDoneNextStep.
  ///
  /// In de, this message translates to:
  /// **'Diese Übersicht zeigt nur, was Sie eingegeben haben. Sie ist keine Bewertung und keine Diagnose.'**
  String get questDoneNextStep;

  /// No description provided for @questOverviewUnavailable.
  ///
  /// In de, this message translates to:
  /// **'Die Übersicht Ihrer Angaben konnte nicht geladen werden.'**
  String get questOverviewUnavailable;

  /// No description provided for @webRoleAreaPatient.
  ///
  /// In de, this message translates to:
  /// **'Patientenbereich'**
  String get webRoleAreaPatient;

  /// No description provided for @webRoleAreaDoctor.
  ///
  /// In de, this message translates to:
  /// **'Ärztebereich'**
  String get webRoleAreaDoctor;

  /// No description provided for @questResumePromptTitle.
  ///
  /// In de, this message translates to:
  /// **'Gespeicherter Entwurf vorhanden'**
  String get questResumePromptTitle;

  /// No description provided for @questResumePromptBody.
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie an Ihrem gespeicherten Entwurf weiterarbeiten? Er wird erst geladen, wenn Sie das bestätigen.'**
  String get questResumePromptBody;

  /// No description provided for @questResumeConfirm.
  ///
  /// In de, this message translates to:
  /// **'Entwurf fortsetzen'**
  String get questResumeConfirm;

  /// No description provided for @questResumeBack.
  ///
  /// In de, this message translates to:
  /// **'Zurück zur Liste'**
  String get questResumeBack;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
