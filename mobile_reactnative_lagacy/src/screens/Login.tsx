import React, { useContext, useState } from 'react'
import {
  Button,
  FormControl,
  Heading,
  Input,
  KeyboardAvoidingView,
  ScrollView,
  Text,
  View,
  VStack
} from 'native-base'
import Logo from '../assets/images/logo.svg'

import useHomedx from '../hooks/useHomedx'
import { HdxContext } from '../contexts/HdxContext'

import DateTimePicker from '@react-native-community/datetimepicker'
import { Trans, useTranslation } from 'react-i18next'
import { Platform } from 'react-native'

type Props = {}

export default function Login({}: Props) {
  const { t } = useTranslation()

  const [email, setEmail] = useState<string>('')
  const [password, setPassword] = useState<string>('')

  const { login } = useHomedx()
  const { _setToken } = useContext(HdxContext)

  const _login = async () => {
    const tok = await login(email, password)
    _setToken(tok)
  }

  const quickLogin = async () => {
    const tok = await login('croeszies+110@giftgruen.com', 'giftGruen0420!')
    _setToken(tok)
  }

  return (
    <ScrollView
      contentContainerStyle={{ flexGrow: 1, justifyContent: 'flex-end' }}>
      <KeyboardAvoidingView behavior="padding">
        <VStack space={4} justifyContent="flex-end" flex="1">
          <Logo />
          <View>
            <Heading>
              <Trans i18nKey="login_title">Willkommen zurück!</Trans>
            </Heading>
            <Text>
              <Trans i18nKey="login_subtitle">
                Geben Sie hier Ihre E-Mail und Ihr Passwort ein, um sich
                einzuloggen.
              </Trans>
            </Text>
          </View>
          <VStack space={2} justifyItems="flex-end">
            <FormControl isRequired>
              <FormControl.Label>{t('email_address')}</FormControl.Label>
              <Input
                type="email"
                placeholer={t('email_address')}
                value={email}
                onChangeText={setEmail}
              />
            </FormControl>
            <FormControl isRequired>
              <FormControl.Label>{t('password')}</FormControl.Label>
              <Input
                type="password"
                placeholer={t('password')}
                value={password}
                onChangeText={setPassword}
              />
            </FormControl>

            <Button onPress={_login}>{t('login_btn_login')}</Button>
            <Button onPress={quickLogin}>Schnell-Login</Button>

            <Button variant={'link'} onPress={_login}>
              {t('login_btn_forgot_password')}
            </Button>
          </VStack>
        </VStack>
      </KeyboardAvoidingView>
    </ScrollView>
  )
}
