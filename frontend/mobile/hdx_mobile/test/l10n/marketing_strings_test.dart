import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hdx_mobile/l10n/marketing_strings.dart';

void main() {
  const de = MarketingStrings(Locale('de', 'DE'));
  const en = MarketingStrings(Locale('en', 'US'));

  test('German landing text is unchanged', () {
    expect(de.doctorDashboardBody, 'Heutige Termine und Patienten auf einen Blick.');
    expect(de.registerDoctor, 'Arzt registrieren');
    expect(de.heroHeadline, 'Gesundheitstests\nund Online-Versorgung');
    expect(de.footerImprint, 'Impressum');
  });

  test('English landing text is used for the English locale', () {
    expect(en.doctorDashboardBody, "Today's appointments and patients at a glance.");
    expect(en.registerDoctor, 'Register as a doctor');
    expect(en.heroHeadline, 'Health tests\nand online care');
    expect(en.footerImprint, 'Imprint');
    expect(en.navSignIn, 'Sign in');
  });

  test('every bilingual landing string differs between the two languages', () {
    final pairs = <String, (String, String)>{
      'navRegister': (de.navRegister, en.navRegister),
      'heroHeadline': (de.heroHeadline, en.heroHeadline),
      'heroLead': (de.heroLead, en.heroLead),
      'startNow': (de.startNow, en.startNow),
      'doctorsSubtitle': (de.doctorsSubtitle, en.doctorsSubtitle),
      'doctorAvailabilityBody': (de.doctorAvailabilityBody, en.doctorAvailabilityBody),
      'doctorVideoBody': (de.doctorVideoBody, en.doctorVideoBody),
      'areYouDoctor': (de.areYouDoctor, en.areYouDoctor),
      'doctorCtaBody': (de.doctorCtaBody, en.doctorCtaBody),
      'doctorLogin': (de.doctorLogin, en.doctorLogin),
      'footerPrivacy': (de.footerPrivacy, en.footerPrivacy),
      'footerTerms': (de.footerTerms, en.footerTerms),
    };
    pairs.forEach((name, pair) {
      expect(pair.$1, isNot(pair.$2), reason: name);
    });
  });
}
