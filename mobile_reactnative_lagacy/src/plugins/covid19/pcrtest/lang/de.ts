const de = {
  onboarding: {
    new: 'NEU',
    caution: 'Bevor es losgeht',
    pcrTest: 'PCR-Test',
    btn_skip: 'Überspringen',
    btn_order: 'PCR-Testkit bestellen',
    btn_next: 'Ich habe mein PCR-Testkit bereits erhalten',
    slides: {
      0: {
        title: 'PCR-Test',
        text: 'Der PCR-Test gilt als das zuverlässigste Verfahren, um einen Verdacht auf eine Infektion mit dem Coronavirus SARS-CoV-2 abzuklären.'
      },
      1: {
        title: 'Ausweis- oder Passnummer',
        text: 'Diese Angabe ist verpflichtend um Ihre Identität nachzuweisen.'
      },
      2: {
        title: 'QR-Code',
        text: 'Sie kleben den QR-Code auf das Probenröhrchen und scannen ihn mit unserer App ein. Dieser wird benötigt, um das PCR-Testergebnis klar Ihnen zuordnen zu können.'
      },
      3: {
        title: 'Gurgelprobe',
        text: 'Sie gurgeln die mitgelieferte Lösung 30 Sekunden lang und entnehmen dann eine Probe.'
      },
      4: {
        title: 'Verpacken & versenden',
        text: 'Nach der Entnahme erfolgt die Versendung. Die weiteren Versandinfomationen erhalten Sie nach der Durchführung hier in der App.'
      },
      5: {
        title: 'Testkit kaufen',
        text: 'Sie können sich Ihr PCR-Testkit ganz einfach bestellen und direkt nach Hause liefern lassen. (Kostenloser Versand)'
      }
    }
  },
  buytestkit: {
    title: 'Ihr Schnelltest bei uns war positiv?',
    text: 'Erhalten Sie mit dem Rabattcode einen kostenlosen PCR-Test',
    hint: '<1>Hinweis:</1> Der Rabattcode ist nur einmalig einlösbar.',
    btn: {
      next: 'Ich habe bereits ein PCR-Testkit'
    },
    copy: 'Rabattcode kopiert!'
  },
  identitycard: {
    title: 'Bitte geben Sie Ihre Ausweis- oder Passnummer an',
    text: 'Diese Angabe ist verpflichtend um Ihre Identität nachzuweisen. Sie erscheint auf dem Zertifikat.',
    idcard: {
      placeholder: 'Ausweis-/ Passnummer',
      prompt:
        'Sind Sie sicher dass Ihre Ausweisnummer korrekt ist? Dann können Sie fortfahren.'
    }
  },
  overview: {
    title: 'Testdurchführung',
    subtitle: "So geht's",
    text: 'Nachdem Sie Ihr PCR-Testkit bestellt & erhalten haben, können Sie mit der Testdurchführung beginnen.',
    step: {
      1: 'Testkit auf Vollständigkeit überprüfen',
      2: 'Ausweis- oder Passnummer eintragen',
      3: 'QR-Code aufkleben & scannen',
      4: 'Gurgeln & Probe nehmen',
      5: 'Probe verpacken & versenden',
      6: 'Testergebnis erhalten'
    }
  },
  tutorial: {
    title: 'Ist Ihr Testkit vollständig?',
    text: 'Bitte kontrollieren Sie Ihr PCR-Testkit, ob alle Komponenten vorhanden sind. Bitte behalten Sie die PCR-Testverpackung. Sie ist für die Rücksendung des Probenmaterials zu verwenden.',
    subtitle: 'Das sollte in Ihrem Testkit enthalten sein:',
    hint: {
      1: 'Testanleitung',
      2: 'QR-Code Sticker',
      3: 'Probenröhrchen',
      4: 'Gurgelflüssigkeit',
      5: 'Trichterröhrchen',
      6: 'Schutzbeutel',
      7: 'PCR-Testverpackung'
    }
  },
  scan: {
    title: 'Probenröhrchen scannen',
    text: 'Bitte geben Sie den 10-stelligen Code ein, der in Ihrem Testkit enthalten ist.',
    hint: 'Den Code finden Sie neben dem QR-Code.',
    code: 'Code',
    qr: {
      hint: 'QR-Code im markierten Bereich einscannen'
    },
    btn: {
      manual: 'Code manuell eingeben',
      confirm: 'Bestätigen',
      scan: 'Code scannen',
      retry: 'Erneut versuchen',
      back: 'Zurück'
    }
  },
  sample: {
    title: 'Gurgeln',
    next: 'Weiter zu Verpackung & Versand',
    gargle: {
      step: {
        1: 'Waschen Sie Ihre Hände gründlich vor dem Test.',
        2: 'Nehmen Sie Nehmen Sie die Gurgelflüssigkeit (Kochsalzlösung) in den Mund und gurgeln Sie 30 Sekunden lang.',
        3: 'Schrauben Sie den Trichter auf das Röhrchen und spucken Sie die Gurgelflüssigkeit in hinein. Nehmen Sie den Trichter ab und verschließen Sie das Röhrchen fest mit dem Deckel.'
      }
    },
    message: {
      title: {
        success: 'Fertig!',
        error: 'Fehlgeschlagen'
      },
      text: {
        success:
          'Die Durchführung des PCR-Tests ist nun abgeschlossen. Sobald Ihre Probe in unserem Labor untersucht wurde, erhalten Sie hier in der App Ihr Testergebnis als Zertifikat.',
        error:
          'Ihre Probe konnte nicht registriert werden. Bitte versuchen Sie es erneut.'
      }
    }
  },
  mailinfo: {
    btn_next: 'PCR-Test abschließen',
    title: 'Probe verpacken',
    text: 'Nehmen Sie das Probenröhrchen und überführen es in den Versandbeutel und legen Sie diesen in die Versandverpackung (entspricht Lieferverpackung).',
    infotitle: 'Versandinformationen',
    infotext:
      'Schicken Sie Ihren verpackten PCR-Test an die unten aufgeführte Adresse:',
    prompt: {
      title: 'Erfolg!',
      text: 'Ihr PCR-Test wurde erfolgreich eingereicht! Nach dem Erhalt Ihrer Probe beginnt die Auswertung. Sie werden von uns benachrichtigt.'
    }
  },
  certificate: {
    support: {
      title: 'Sie haben Fragen?',
      text: 'Unser Support hilft Ihnen weiter!'
    }
  }
}
export default de
