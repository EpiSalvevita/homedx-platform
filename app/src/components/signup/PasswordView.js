import React, { useState, useCallback, useEffect, useMemo } from 'react'
import PasswordInput from 'components/PasswordInput'
import { Trans, useTranslation } from 'react-i18next'
import InfoIcon from 'assets/icons/ic_info.svg'
import RefreshIcon from 'assets/icons/ic_refresh.svg'
import ClipboardIcon from 'assets/icons/ic_clipboard.svg'
import Button from 'components/Button'
import TextInput from 'components/TextInput'
import PasswordGenerator from 'PasswordGenerator'
import zxcvbn from 'zxcvbn'
import { isPasswordValid } from 'Utility'

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
      navigator.clipboard.writeText(generatedPassword)
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
    <div style={{ flex: 1, justifyContent: 'flex-end' }}>
      <h1>
        <Trans i18nKey="signup__password__title">Passwort festlegen</Trans>
      </h1>
      <p>
        <Trans i18nKey="signup__password__text">
          Legen Sie ein sicheres Passwort fest, indem Sie ein zufällig
          generiertes Passwort nutzen oder geben Sie selbst ein Passwort ein.
        </Trans>
      </p>
      <div className="row">
        <div className="col-10" style={{ position: 'relative' }}>
          <TextInput
            label={t('signup__genpw__label', {
              defaultValue: 'Generiertes Passwort'
            })}
            className="alt"
            value={generatedPassword}
          />
          <div
            onClick={copyPassword}
            style={{
              position: 'absolute',
              right: 20,
              top: '50%',
              transform: 'translateY(calc(-50% - 5px))'
            }}>
            <ClipboardIcon />
          </div>
        </div>
        <div className="col-2 password__show" onClick={genPassword}>
          <RefreshIcon />
        </div>
      </div>
      <div className="row">
        <div className="col-10">
          <PasswordInput
            showAsRequired
            required
            onChange={val => setPassword(val)}
            userInput={[firstname, lastname, email]}
            isValid={validatePassword}
          />
        </div>
        <div className="col-2 password__show" onClick={showPasswordTips}>
          <InfoIcon />
        </div>
      </div>
      <div className="row">
        <div className="col-12">
          <Button disabled={!validatePassword} onClick={onNext}>
            <Trans i18nKey="next">Weiter</Trans>
          </Button>
        </div>
      </div>
    </div>
  )
}
