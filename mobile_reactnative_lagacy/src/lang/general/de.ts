const shared = {
  email_address: 'Email Addresse',
  password: 'Passwort'
}

const landing = {
  title: 'Das digitale Testzentrum.',
  listitems: {
    1: 'Einfach TestKit aus dem Handel nutzen',
    2: 'Test mit Smartphone durchführen',
    3: 'Qualifiziertes Zertifikat erhalten',
    4: 'Sicher online bezahlen'
  },
  btn: {
    login: 'Login',
    signup: 'Registrieren'
  }
}

const login = {
  title: 'Willkommen zurück!',
  subtitle:
    'Geben Sie hier Ihre E-Mail und Ihr Passwort ein, um sich einzuloggen',
  prompt_title: 'Login fehlgeschlagen',
  prompt_subtitle:
    'Ihre Benutzerdaten sind nicht korrekt. Bitte überprüfen Sie ihre Angaben.',
  btn: {
    login: 'Einloggen',
    forgot_password: 'Passwort vergessen'
  }
}

// const signup = {
//   title:
//     'Willkommen bei homeDX, dem virtuellen Schnelltest-Zentrum. Hier können Sie sich für die Teilnahme registrieren.',

//   prompt: {
//     error: {
//       title: 'Fehlgeschlagen',
//       subtitle: 'Bitte prüfen Sie folgendes:'
//     },
//     success: {
//       title: 'Fertig!',
//       subtitle:
//         'Sie haben sich erfolgreich registriert. Bitte loggen Sie sich ein.'
//     }
//   },
//   help: {
//     title: 'Hinweise zur Registrierung',
//     1: 'Bitte achten Sie darauf ein sicheres Passwort zu erstellen.',
//     2: 'Ein sicheres Passwort entspricht unseren Sicherheitsvorgaben. Diese finden Sie über das "Info"-Icon neben dem Passwort Feld.',
//     3: 'Der Balken unterhalb der Passworteingabe deutet auf Ihre Passwortstärke hin.',
//     4: 'Sie benötigen einen grünen Balken (sehr stark) um den Anmelde Button zu aktivieren.',
//     5: 'Bitte füllen Sie alle Felder aus.'
//   },
//   hint: {
//     title: 'Bitte sicheres Passwort vergeben:',
//     password: {
//       1: 'Es sollte mindestens 8 Zeichen lang sein.',
//       2: 'Es sollte Groß- und Kleinschreibung beinhalten.',
//       3: 'Verwenden Sie eines dieser Sonderzeichen:',
//       4: 'Nutzen Sie keine Zahlen- und Buchstaben-Abfolge, die ein reales Wort ergeben.',
//       5: 'Nutzen Sie kein Datum, welches mit Ihnen in Verbindung steht.',
//       6: 'Nutzen Sie keine Jahreszahlen.',
//       7: 'Nutzen Sie kein Passwort wie „Passwort123“ oder ähnliches.',
//       8: 'Nutzen Sie keine Wiederholung wie „ababab“ oder Abfolgen wie „123456“.',
//       action: 'Sie kommen nicht weiter?'
//     }
//   },
//   placeholder: {
//     token: 'Registrierungstoken'
//   },
//   validation: {
//     firstname: 'Bitte geben Sie einen Vornamen an',
//     lastname: 'Bitte geben Sie einen Nachnamen an',
//     email_empty: 'Bitte geben Sie eine E-Mail an',
//     email_invalid: 'Bitte geben Sie eine valide E-Mail an',
//     exists: 'Diese E-Mail wird bereits verwendet',
//     password: 'Bitte geben Sie ein Passwort an',
//     token_empty: 'Bitte geben Sie ein Registrierungscode an',
//     token_invalid: 'Der Registrierungscode ist ungültig',
//     denied:
//       'Das angegebene Registierungstoken lässt zur Zeit keine weiteren Anmeldungen zu'
//   },
//   check: {
//     privacy:
//       'Ich bin damit einverstanden, dass die homeDX GmbH meine personenbezogenen Daten, insbesondere die Daten über meine Gesundheit, wie in den <1>Datenschutzhinweisen</1> beschrieben, verarbeitet. Diese Einwilligung kann ich jederzeit für die Zukunft widerrufen *',
//     legal: 'Ich habe die <1>AGB</1> gelesen und akzeptiert.'
//   },
//   token: {
//     title: 'Über das Registrierungstoken',
//     text: 'Die Berechtigung zur Teilnahme am Berlin-Projekt wird während des Verfahrens anhand Ihrer Meldeadresse überprüft. Sollten Sie nicht in Berlin gemeldet sein, wird Ihnen kein Zertifikat erteilt.',
//     hint: {
//       coupon:
//         'Wenn Sie einen Coupon (QR-Code) haben, können Sie ohne Token mit der Registrierung fortfahren'
//     },
//     checkbox: 'Ich habe einen Registierungstoken'
//   },
//   warning: {
//     subtitle: 'Wollen Sie wirklich ohne Registierungstoken fortfahren?',
//     text: 'Fahren Sie nur ohne Registerungstoken fort wenn Sie <1>online zahlen möchten</1> oder einen <3>Coupon (QR-Code) besitzen</3>',
//     btn: 'Weiter ohne'
//   }
// }

const signup = {
  data: {
    title: 'Ihre Daten',
    text: 'Willkommen bei homeDX, dem virtuellen Schnelltest-Zentrum. Hier können Sie sich für Ihre Teilnahme registrieren. Im ersten Schritt geben Sie Ihre Daten an.'
  },
  password: {
    title: 'Passwort festlegen',
    text: 'Legen Sie ein sicheres Passwort fest, indem Sie ein zufällig generiertes Passwort nutzen oder geben Sie selbst ein Passwort ein.'
  },
  token: {
    title: 'Token & Zustimmung',
    text: 'Sie nutzen einen Token? Dann können Sie Ihn hier angeben. Andernfalls benötigen wir nur Ihre Zustimmung zu unseren Datenschutzhinweisen und den AGB.',
    checkbox: 'Ohne Token ist der Kauf von Lizenzen notwendig.',
    hint: {
      coupon:
        'Wenn Sie einen Coupon (QR-Code) haben, können Sie ohne Token mit der Registrierung fortfahren',
      payment: 'Ohne Token ist der Kauf von Lizenzen notwendig.'
    }
  },
  check: {
    privacy:
      'Ich bin damit einverstanden, dass die homeDX GmbH meine personenbezogenen Daten, insbesondere die Daten über meine Gesundheit, wie in den Datenschutzhinweisen beschrieben, verarbeitet. Diese Einwilligung kann ich jederzeit für die Zukunft widerrufen *',
    tos: 'Ich habe die AGB gelesen und akzeptiert *'
  }
}

const nav = {
  home: 'Start',
  profile: 'Profil',
  certificates: 'Zertifikate'
}

const availableTests = {
  1: {
    name: 'SARS-CoV-2'
  },
  1.1: {
    name: 'Schnelltest',
    description: 'Testen Sie Ihre Corona-Infektion'
  },
  1.2: {
    name: 'PCR-Test',
    description: 'Corona PCR-Test inkl. gültigem Zertifikat'
  },
  1.3: {
    name: 'Antikörper-Test',
    description: 'Überprüfen Sie Ihren Impfschutz'
  }
}

const dashboard = {
  newest_certificate: 'Neuestes Zertifikat',
  available_tests: 'Verfügbare Tests'
}

const de = {
  ...shared,
  nav,
  landing,
  login,
  signup,
  dashboard,
  availableTests
}
export default de
