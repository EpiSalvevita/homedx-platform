import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';

class MarketingStrings {
  final Locale locale;

  const MarketingStrings(this.locale);

  bool get isGerman => locale.languageCode == 'de';

  String get navHome => isGerman ? 'App' : 'App';
  String get navSignIn => isGerman ? 'Anmelden' : 'Sign in';
  String get navAbout => isGerman ? 'Über HomeDX' : 'About HomeDX';

  String get heroTitle =>
      isGerman ? 'Gesundheit beginnt\nbei Ihnen zu Hause' : 'Health starts\nat home';

  String get heroSubtitle => isGerman
      ? 'HomeDX verbindet Schnelltests mit dem Cube-Gerät, Online-Termine und sichere Video-Konsultationen — für Patienten und Ärzte.'
      : 'HomeDX connects rapid tests with the Cube device, online appointments, and secure video consultations — for patients and doctors.';

  String get patientsTitle => isGerman ? 'Für Patienten' : 'For patients';

  String get patientsSubtitle => isGerman
      ? 'Ergebnisse, Zertifikate und Nachbestellung — alles an einem Ort.'
      : 'Results, certificates, and reordering — all in one place.';

  String get patientResultsTitle =>
      isGerman ? 'Testergebnisse & Videoberatung' : 'Test results & video consultation';

  String get patientResultsBody => isGerman
      ? 'Cube-Ergebnisse einsehen und direkt per Video mit einem Facharzt besprechen — verständlich erklärt und jederzeit abrufbar.'
      : 'View your Cube results and discuss them via video with a specialist — clearly explained and available anytime.';

  String get patientShopTitle => isGerman ? 'Shop & Testkits' : 'Shop & test kits';

  String get patientShopBody => isGerman
      ? 'Testkits und Zubehör bestellen — direkt in der App.'
      : 'Order test kits and accessories — directly in the app.';

  String get patientCertificatesTitle => isGerman ? 'Zertifikate' : 'Certificates';

  String get patientCertificatesBody => isGerman
      ? 'Digitale Gesundheitszertifikate herunterladen und teilen, wenn Sie sie brauchen.'
      : 'Download and share digital health certificates when you need them.';

  String get storyTitle => isGerman ? 'Unsere Geschichte' : 'Our story';

  String get storySubtitle => isGerman
      ? 'Wir glauben, dass moderne Diagnostik zugänglich, verständlich und persönlich sein sollte.'
      : 'We believe modern diagnostics should be accessible, understandable, and personal.';

  String get storyBody => isGerman
      ? 'HomeDX wurde gegründet, um die Lücke zwischen Schnelltests zu Hause und professioneller medizinischer Betreuung zu schließen. Mit dem Cube-Gerät erhalten Patienten zuverlässige Ergebnisse in Minuten — und können direkt im Anschluss einen Arzttermin buchen und per Video beraten werden. Für Ärzte bietet HomeDX ein webbasiertes Portal zur Terminverwaltung und sicheren Videokommunikation.'
      : 'HomeDX was founded to bridge the gap between at-home rapid testing and professional medical care. With the Cube device, patients get reliable results in minutes — and can book a doctor appointment and receive video consultation right away. For doctors, HomeDX offers a web-based portal for appointment management and secure video communication.';

  String get imageComingSoon => isGerman ? 'Bild folgt in Kürze' : 'Image coming soon';

  String get productTitle => isGerman ? 'Das Produkt' : 'The product';

  String get productSubtitle => isGerman
      ? 'Eine Plattform für Tests, Termine und Nachsorge.'
      : 'One platform for tests, appointments, and follow-up care.';

  String get productCubeTitle => isGerman ? 'Cube Schnelltests' : 'Cube rapid tests';

  String get productCubeBody => isGerman
      ? 'Schnelle, zuverlässige Diagnostik mit dem HomeDX Cube — per Bluetooth verbunden und direkt in der App ausgewertet.'
      : 'Fast, reliable diagnostics with the HomeDX Cube — connected via Bluetooth and evaluated directly in the app.';

  String get productAppointmentTitle =>
      isGerman ? 'Termin buchen' : 'Book appointments';

  String get productAppointmentBody => isGerman
      ? 'Online-Konsultationen mit Fachärzten vereinbaren — flexibel und ohne Wartezeiten in der Praxis.'
      : 'Schedule online consultations with specialists — flexible and without long waits at the clinic.';

  String get productVideoTitle => isGerman ? 'Video-Konsultation' : 'Video consultation';

  String get productVideoBody => isGerman
      ? 'Sicher per Video mit Ihrem Arzt sprechen. Ärzte können Anrufe direkt im Browser starten.'
      : 'Speak securely with your doctor via video. Doctors can start calls directly in the browser.';

  String get productResultsTitle => isGerman ? 'Ergebnisse & Shop' : 'Results & shop';

  String get productResultsBody => isGerman
      ? 'Testergebnisse einsehen, verwalten und Testkits nachbestellen — alles in einer App.'
      : 'View, manage test results, and reorder test kits — all in one app.';

  String get howItWorksTitle => isGerman ? 'So funktioniert es' : 'How it works';

  String get howItWorksSubtitle => isGerman
      ? 'Drei Schritte von der Diagnose bis zur Beratung.'
      : 'Three steps from diagnosis to consultation.';

  String get step1Title => isGerman ? 'Test zu Hause' : 'Test at home';

  String get step1Body => isGerman
      ? 'Führen Sie einen Schnelltest mit dem Cube-Gerät durch und erhalten Sie Ergebnisse in Minuten.'
      : 'Run a rapid test with the Cube device and get results in minutes.';

  String get step2Title => isGerman ? 'Arzt buchen' : 'Book a doctor';

  String get step2Body => isGerman
      ? 'Wählen Sie einen Facharzt und buchen Sie einen Online-Termin.'
      : 'Choose a specialist and book an online appointment.';

  String get step3Title => isGerman ? 'Video-Beratung' : 'Video consultation';

  String get step3Body => isGerman
      ? 'Sprechen Sie sicher per Video mit Ihrem Arzt über Ihre Ergebnisse.'
      : 'Discuss your results securely via video with your doctor.';

  String get doctorsTitle => isGerman ? 'Für Ärzte' : 'For doctors';

  String get doctorsSubtitle => isGerman
      ? 'Dashboard, Verfügbarkeit und Videoanrufe im Browser.'
      : 'Dashboard, availability, and video calls in the browser.';

  String get doctorsBody => isGerman
      ? 'Melden Sie sich mit Ihrem Arztkonto an, um Termine zu verwalten, Ihre Verfügbarkeit festzulegen und Video-Konsultationen mit Patienten durchzuführen.'
      : 'Sign in with your doctor account to manage appointments, set your availability, and conduct video consultations with patients.';

  String get doctorsCta => isGerman ? 'Arzt-Login' : 'Doctor login';

  String get footerCtaTitle =>
      isGerman ? 'Bereit für HomeDX?' : 'Ready for HomeDX?';

  String get footerCtaBody => isGerman
      ? 'Registrieren Sie sich und starten Sie mit Gesundheitstests und Online-Versorgung.'
      : 'Register and start with health tests and online care.';

  String get footerCtaPrimary => isGerman ? 'Jetzt starten' : 'Get started';

  String get footerCtaSecondary => isGerman ? 'Zur App' : 'Go to app';

  String get legalPlaceholder =>
      isGerman ? 'Impressum · Datenschutz · AGB' : 'Legal notice · Privacy · Terms';

  static MarketingStrings of(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale;
    return MarketingStrings(locale);
  }
}
