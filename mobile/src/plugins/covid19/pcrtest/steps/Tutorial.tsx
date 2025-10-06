import { View } from 'react-native'
import React from 'react'
import { Button, Heading, Text, VStack } from 'native-base'
import { Trans } from 'react-i18next'

export default function Tutorial({ onNext }) {
  return (
    <View>
      <Heading>
        <Trans i18nKey="pcrTest_tutorial_title" ns="covid19">
          Ist Ihr Testkit vollständig?
        </Trans>
      </Heading>
      <Text>
        <Trans i18nKey="pcrTest_tutorial_text" ns="covid19">
          Bitte kontrollieren Sie Ihr PCR-Testkit, ob alle Komponenten vorhanden
          sind. Bitte behalten Sie die PCR-Testverpackung. Sie ist für die
          Rücksendung des Probenmaterials zu verwenden.
        </Trans>
      </Text>
      <Heading>
        <Trans i18nKey="pcrTest_tutorial_subtitle" ns="covid19">
          Das sollte in Ihrem Testkit enthalten sein
        </Trans>
      </Heading>
      <VStack>
        <Text>
          <Trans i18nKey="pcrTest_tutorial_hint_1" ns="covid19">
            Testanleitung
          </Trans>
        </Text>
        <Text>
          <Trans i18nKey="pcrTest_tutorial_hint_2" ns="covid19">
            QR-Code Sticker
          </Trans>
        </Text>
        <Text>
          <Trans i18nKey="pcrTest_tutorial_hint_3" ns="covid19">
            Probenröhrchen
          </Trans>
        </Text>
        <Text>
          <Trans i18nKey="pcrTest_tutorial_hint_4" ns="covid19">
            Gurgelflüssigkeit
          </Trans>
        </Text>
        <Text>
          <Trans i18nKey="pcrTest_tutorial_hint_5" ns="covid19">
            Trichterröhrchen
          </Trans>
        </Text>
        <Text>
          <Trans i18nKey="pcrTest_tutorial_hint_6" ns="covid19">
            Schutzbeutel
          </Trans>
        </Text>
        <Text>
          <Trans i18nKey="pcrTest_tutorial_hint_7" ns="covid19">
            PCR-Testverpackung
          </Trans>
        </Text>
      </VStack>
      <Button onPress={onNext}>Weiter</Button>
    </View>
  )
}
