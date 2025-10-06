import { View, Text } from 'react-native'
import React from 'react'
import { Button, Heading, VStack } from 'native-base'
import { Trans } from 'react-i18next'

export default function Sample({ onNext }) {
  return (
    <View>
      <Heading>
        <Trans i18nKey="pcrTest_sample_title" ns="covid19">
          Gurgeln
        </Trans>
      </Heading>
      <VStack>
        <Text>
          <Trans i18nKey="pcrTest_sample_gargle_step_1" ns="covid19">
            Waschen Sie Ihre Hände gründlich vor dem Test.
          </Trans>
        </Text>
        <Text>
          <Trans i18nKey="pcrTest_sample_gargle_step_2" ns="covid19">
            Nehmen Sie Nehmen Sie die Gurgelflüssigkeit (Kochsalzlösung) in den
            Mund und gurgeln Sie 30 Sekunden lang.
          </Trans>
        </Text>
        <Text>
          <Trans i18nKey="pcrTest_sample_gargle_step_3" ns="covid19">
            Schrauben Sie den Trichter auf das Röhrchen und spucken Sie die
            Gurgelflüssigkeit in hinein. Nehmen Sie den Trichter ab und
            verschließen Sie das Röhrchen fest mit dem Deckel.
          </Trans>
        </Text>
      </VStack>
      <Button onPress={onNext}>Weiter</Button>
    </View>
  )
}
