import React, { useState, useCallback, useEffect, useMemo } from 'react'

import { Trans, useTranslation } from 'react-i18next'

import PasswordGenerator from '../../PasswordGenerator'
import zxcvbn from 'zxcvbn'
import { isPasswordValid } from '../../Utility'
import { Button, Heading, Input, Text, View } from 'native-base'
import PasswordInput from '../PasswordInput'

export default function PasswordView({
  firstname,
  lastname,
  email,
  showPasswordTips,
  setPassword,
  password,
  onNext
}) {
  const { t } = useTranslation()

  const [generatedPassword, setGeneratedPassword] = useState('')

  useEffect(() => {
    setGeneratedPassword(PasswordGenerator.next().value)
  }, [])

  const genPassword = () => {
    setGeneratedPassword(PasswordGenerator.next().value)
  }

  const copyPassword = useCallback(() => {
    try {
      // navigator.clipboard.writeText(generatedPassword)
    } catch (e) {}
  }, [generatedPassword])

  // const validatePassword = useMemo(() => {
  //   let res = true
  //   ;(!password || password.length < 8) && (res = false)
  //   console.log('1', res, password)
  //   !password?.match(/([A-Z])/) && (res = false)
  //   console.log('2', res, password)
  //   !password?.match(/([a-z])/) && (res = false)
  //   console.log('3', res, password)
  //   !password?.match(/([0-9])/) && (res = false)
  //   console.log('4', res, password)
  //   !password?.match(/([!|@|.|$|%|^|&|*|-|_])/) && (res = false)
  //   console.log('5', res, password)
  //   return res
  // }, [password])

  const validatePassword = useMemo(() => {
    let { score } = zxcvbn(password, [firstname, lastname, email])

    return isPasswordValid(password) && score > 3
  }, [email, firstname, lastname, password])

  return (
    <View flex="1" justifyContent={'flex-end'}>
      <Heading>
        <Trans i18nKey="signup__password__title">Passwort festlegen</Trans>
      </Heading>
      <Text>
        <Trans i18nKey="signup__password__text">
          Legen Sie ein sicheres Passwort fest, indem Sie ein zufällig
          generiertes Passwort nutzen oder geben Sie selbst ein Passwort ein.
        </Trans>
      </Text>

      <View>
        <Input
          placeholder={t('signup__genpw__label', {
            defaultValue: 'Generiertes Passwort'
          })}
          value={generatedPassword}
        />
        {/* <View
            onPress={copyPassword}
            style={{
              position: 'absolute',
              right: 20,
              top: '50%',
              transform: 'translateY(calc(-50% - 5px))'
            }}>
            <ClipboardIcon />
          </View> */}

        {/* <View className="col-2 password__show" onPress={genPassword}>
          <RefreshIcon />
        </View> */}
      </View>
      <View>
        <PasswordInput
          onChange={val => setPassword(val)}
          userInput={[firstname, lastname, email]}
          isValid={validatePassword}
        />

        {/* <View className="col-2 password__show" onPress={showPasswordTips}>
          <InfoIcon />
        </View> */}
      </View>

      <View>
        <Button isDisabled={!validatePassword} onPress={onNext}>
          <Text>
            <Trans i18nKey="next">Weiter</Trans>
          </Text>
        </Button>
      </View>
    </View>
  )
}
