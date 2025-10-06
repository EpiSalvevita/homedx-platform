const en = {
  onboarding: {
    new: 'NEW',
    caution: 'Before you start',
    pcrTest: 'PCR-test',
    btn_skip: 'Skip',
    btn_order: 'Order PCR-testkit',
    btn_next: 'I already have a PCR-testkit',
    slides: {
      0: {
        title: 'PCR-Test',
        text: 'The PCR test is considered the most reliable method to clarify a suspected infection with the SARS-CoV-2 coronavirus. The PCR test is considered the most reliable method to clarify a suspected infection with the SARS-CoV-2 coronavirus.'
      },
      1: {
        title: 'ID card or passport number',
        text: 'This information is mandatory to prove your identity.'
      },
      2: {
        title: 'QR-Code',
        text: 'You stick the QR code on the sample tube and scan it with our app. This is needed to clearly assign the PCR test result to you.'
      },
      3: {
        title: 'Gargle sample',
        text: 'You gargle the provided solution for 30 seconds and then take a sample.'
      },
      4: {
        title: 'Pack & ship',
        text: 'After the preparing the sample, the shipment takes place. You will receive the further shipping information here in the app after the execution.'
      },
      5: {
        title: 'Buy a testkit',
        text: 'You can easily order your PCR test kit and have it delivered directly to your home. (Free shipping)'
      }
    }
  },
  buytestkit: {
    title: 'Your rapid test with us was positive?',
    text1: 'Get a free PCR test by using the dicount code when ordering one',
    hint: '<1>Hint:</1> The discount is usable once per person.',
    btn: {
      next: 'I already have a PCR testkit'
    },
    copy: 'Copied discount code!'
  },
  identitycard: {
    title: 'Please enter your ID card or passport number',
    text: 'This information is mandatory to prove your identity. It appears on the certificate.',
    idcard: {
      placeholder: 'ID card / passport number',
      prompt: 'Are you sure that your ID is correct? Then you can proceed.'
    }
  },
  tutorial: {
    title: 'Is your test kit complete?',
    text: 'Please check your PCR test kit to make sure that all components are present. Please keep the PCR test packaging. It is to be used for returning the sample material.',
    subtitle: 'This should be included in your test kit:',
    hint: {
      1: 'Test instruction',
      2: 'QR code sticker',
      3: 'Test tube',
      4: 'Gargle liquid',
      5: 'Funnel tube',
      6: 'Protective bag',
      7: 'Outer packaging'
    }
  },
  scan: {
    title: 'Scan tube code',
    text: 'Please enter the 10-digit code included in your test kit.',
    hint: 'You can find the code next to the QR code.',
    code: 'Code',
    qr: {
      hint: 'Scan QR code in the highlighted area'
    },
    btn: {
      manual: 'Enter code manually',
      confirm: 'Confirm',
      scan: 'Scan code',
      retry: 'Try again',
      back: 'Back'
    }
  },
  overview: {
    title: 'Test execution',
    subtitle: "That's how",
    text: 'After you have ordered and received your PCR test kit, you can start performing the test.',
    step: {
      1: 'Check test kit for completeness',
      2: 'Enter ID card or passport number',
      3: 'Stick & scan QR code',
      4: 'Gargle & sample',
      5: 'Pack & ship sample',
      6: 'Receive test result'
    }
  },
  sample: {
    title: 'Gargle',
    next: 'Proceed to packing & shipping',
    gargle: {
      step: {
        1: 'Wash your hands thoroughly before testing.',
        2: 'Take the gargle (saline solution) in your mouth and gargle for 30 seconds.',
        3: 'Screw the funnel onto the sample tube and spit the gargling liquid into the tube. Remove the funnel and close the test tube tightly with the lid.'
      }
    },
    message: {
      title: {
        success: 'Success!',
        error: 'Failure!'
      },
      text: {
        success:
          'The PCR test has now been completed. As soon as your sample has been tested in our laboratory, you will receive your test result as a certificate here in the app.',
        error: 'Your sample could not be registered. Please try again.'
      }
    }
  },
  mailinfo: {
    btn_next: 'Complete PCR test',
    title: 'Pack sample',
    text: 'Take the sample tube and transfer it to the shipping bag and place it in the shipping packaging (corresponds to delivery packaging).',
    infotitle: 'Shipping information',
    infotext: 'Send your packaged PCR test to the address listed below:',
    prompt: {
      title: 'Success!',
      text: 'Your PCR test has been successfully submitted! After receipt of your sample, the evaluation will start. You will be notified by us.'
    }
  },
  certificate: {
    support: {
      title: 'Do you have any questions?',
      text: 'Our support will help you!'
    }
  }
}
export default en
