import React, { useCallback, useContext, useEffect, useState } from 'react'
import { Box, Button, Heading, VStack, Text, View } from 'native-base'
import useHomedx from '../../../../hooks/useHomedx'
import { RapidTestContext } from '../RapidTest'
import { TestSlideProps } from '../../../../models/TestProps'
import ListView from '../../../../widgets/ListView'
import { useTranslation } from 'react-i18next'

export default function PIN({ onNext }: TestSlideProps) {
  const { t } = useTranslation('covid19')

  const { setTestData } = useContext(RapidTestContext)
  const { getLiveToken } = useHomedx()
  const [pin, setPin] = useState<string>('')

  const getPin = useCallback(async () => {
    const res = await getLiveToken()
    if (res.success && res.liveToken) {
      setPin(res.liveToken)
      setTestData({ liveToken: res.liveToken })
    }
  }, [])

  useEffect(() => {
    getPin()
  }, [])

  return (
    <Box flex="1" justifyContent={'flex-end'}>
      <Heading mt="2">
        Beschriften Sie nun Ihre Corona-Testkassette mit Ihrer Sicherheits-PIN.
      </Heading>
      <View mt="4">
        <ListView
          data={[
            t(
              'Ihre PIN dient zu Ihrer Sicherheit. Damit soll Ihr Ergebnis eindeutig Ihnen zugeordnet werden können.'
            ),
            t('Holen Sie nun das Testkit aus der Verpackung.'),
            t(
              'Beschriften Sie nun Ihre Corona-Testkassette wie auf dem Foto dargestellt etwa mit einem Kugelschreiber.'
            )
          ]}
        />
      </View>
      <View flex="1"></View>

      <Heading mb="4">Ihre PIN lautet: {pin}</Heading>

      <Button onPress={onNext} isDisabled={!pin}>
        Weiter
      </Button>
    </Box>
  )
}
