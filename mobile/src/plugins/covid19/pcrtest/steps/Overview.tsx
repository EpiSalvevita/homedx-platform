import { View } from 'react-native'
import React from 'react'
import { Button, Heading, Text, VStack } from 'native-base'
import { Trans } from 'react-i18next'

export default function Overview({ onNext }) {
  return (
    <View>
      <Heading>
        <Trans i18nKey="pcrTest_overview_title" ns="covid19">
          Testdurchführung
        </Trans>
      </Heading>

      <Text>
        <Trans i18nKey="pcrTest_overview_text" ns="covid19">
          Nachdem Sie Ihr PCR-Testkit bestellt & erhalten haben, können Sie mit
          der Testdurchführung beginnen.
        </Trans>
      </Text>

      <Heading>
        <Trans i18nKey="pcrTest_overview_subtitle" ns="covid19">
          So geht's
        </Trans>
      </Heading>

      <VStack>
        <Text>
          <Trans i18nKey="pcrTest_overview_step_1" ns="covid19">
            Testkit auf Vollständigkeit überprüfen
          </Trans>
        </Text>
        <Text>
          <Trans i18nKey="pcrTest_overview_step_2" ns="covid19">
            Ausweis- oder Passnummer eintragen
          </Trans>
        </Text>
        <Text>
          <Trans i18nKey="pcrTest_overview_step_3" ns="covid19">
            QR-Code aufkleben & scannen
          </Trans>
        </Text>
        <Text>
          <Trans i18nKey="pcrTest_overview_step_4" ns="covid19">
            Gurgeln & Probe nehmen
          </Trans>
        </Text>
        <Text>
          <Trans i18nKey="pcrTest_overview_step_5" ns="covid19">
            Probe verpacken & versenden
          </Trans>
        </Text>
        <Text>
          <Trans i18nKey="pcrTest_overview_step_6" ns="covid19">
            Testergebnis erhalten
          </Trans>
        </Text>
      </VStack>

      <Button onPress={onNext}>Weiter</Button>
    </View>
  )
}
