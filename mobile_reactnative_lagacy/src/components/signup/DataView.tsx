import React, { useCallback, useState } from 'react'
import { Trans, useTranslation } from 'react-i18next'

import {
  Heading,
  View,
  Text,
  Input,
  Button,
  VStack,
  Box,
  Alert
} from 'native-base'

import useHomedx from '../../hooks/useHomedx'

export default function DataView({
  firstname,
  lastname,
  email,
  setFirstname,
  setLastname,
  setEmail,
  onNext,
  showError
}) {
  const { t } = useTranslation()
  const { registerAccount } = useHomedx()
  const [isLoading, setIsLoading] = useState(false)

  const checkEmail = useCallback(async () => {
    setIsLoading(true)

    const res = await registerAccount({ email })

    if (!res.success) {
      if (res.validation.includes('emailExists')) {
        showError(['emailExists'])
      } else if (
        res.validation.includes('invalidEmail') ||
        res.validation.includes('emptyEmail')
      ) {
        showError(['invalidEmail'])
      } else {
        onNext && onNext()
      }
    }

    setIsLoading(false)
  }, [email, onNext, showError])

  return (
    <Box justifyContent="flex-end">
      <Heading>
        <Trans i18nKey="signup_data_title">Ihre Daten</Trans>
      </Heading>
      <Text>
        <Trans i18nKey="signup_data_text">
          Willkommen bei homeDX, dem virtuellen Schnelltest-Zentrum. Hier können
          Sie sich für Ihre Teilnahme registrieren. Im ersten Schritt geben Sie
          Ihre Daten an.
        </Trans>
      </Text>
      <VStack space="2" justifyContent={'flex-end'}>
        <View>
          <Input
            type="text"
            placeholder={t('firstname')}
            onChangeText={setFirstname}
          />
        </View>
        <View>
          <Input
            type="text"
            placeholder={t('lastname')}
            onChangeText={setLastname}
          />
        </View>
        <View>
          <Input
            type="email"
            placeholder={t('email')}
            onChangeText={setEmail}
          />
        </View>

        <View>
          <Button
            isDisabled={
              isLoading ||
              firstname.length < 3 ||
              lastname.length < 3 ||
              email.length < 3
            }
            onPress={checkEmail}>
            <Text>
              {(!isLoading && <Trans i18nKey="next">Weiter</Trans>) || (
                <Trans i18nKey="loading">Lädt...</Trans>
              )}
            </Text>
          </Button>
        </View>
      </VStack>
    </Box>
  )
}
