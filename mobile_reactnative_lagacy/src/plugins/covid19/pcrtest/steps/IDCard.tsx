import { View, Text } from 'react-native'
import React, { useState } from 'react'
import { Button, Heading, Input } from 'native-base'
import { Trans, useTranslation } from 'react-i18next'

export default function IDCard({ onNext }) {
  const { t } = useTranslation('covid19')
  const [id, setId] = useState<string>('')

  return (
    <View>
      <Heading>
        <Trans i18nKey="pcrTest_identitycard_title" ns="covid19">
          Bitte geben Sie Ihre Ausweis- oder Passnummer an
        </Trans>
      </Heading>
      <Text>
        <Trans i18nKey="pcrTest_identitycard_text" ns="covid19">
          Diese Angabe ist verpflichtend um Ihre Identität nachzuweisen. Sie
          erscheint auf dem Zertifikat.
        </Trans>
      </Text>
      <Input placeholder={t('pcrTest_identitycard_idcard_placeholder')} />
      {/* !/^[A-Za-z0-9]+$/.test(id) */}
      <Button onPress={onNext} isDisabled={false}>
        Weiter
      </Button>
    </View>
  )
}
