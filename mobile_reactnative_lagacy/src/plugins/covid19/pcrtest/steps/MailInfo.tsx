import { GestureResponderEvent, View } from 'react-native'
import React from 'react'
import { Button, Heading, Text } from 'native-base'
import { Trans } from 'react-i18next'

export default function MailInfo({ onNext }) {
  return (
    <View>
      <Heading>
        <Trans i18nKey="pcrTest_mailinfo_title" ns="covid19">
          Probe verpacken
        </Trans>
      </Heading>
      <Text>
        <Trans i18nKey="pcrTest_mailinfo_text" ns="covid19">
          Nehmen Sie das Probenröhrchen und überführen es in den Versandbeutel
          und legen Sie diesen in die Versandverpackung (entspricht
          Lieferverpackung).
        </Trans>
      </Text>
      <Button onPress={onNext}>Weiter</Button>
    </View>
  )
}
