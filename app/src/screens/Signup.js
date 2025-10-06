import React, { useState, useRef, useEffect } from 'react'
import { useHistory } from 'react-router'
import { Trans, useTranslation } from 'react-i18next'
import { useMatomo } from '@datapunt/matomo-tracker-react'
import * as Sentry from '@sentry/react'

import Prompt from 'components/Prompt'
import Button from 'components/Button'
import CloseButton from 'components/CloseButton'
import BottomSheet from 'components/BottomSheet'
import Questionnaire from 'components/Questionnaire'
import DataView from 'components/signup/DataView'
import TokenView from 'components/signup/TokenView'
import PasswordView from 'components/signup/PasswordView'
import ProgressBar from 'components/ProgressBar'

import Logo from 'assets/icons/ic_logo-alt.svg'
import WarningIcon from 'assets/icons/ic_error.svg'
import BigCheckIcon from 'assets/icons/ic_success.svg'

import { signup } from '../services/auth.service'

export default function Signup() {
  const history = useHistory()
  const { t } = useTranslation()
  const bottomsheetRef = useRef(null)
  const bottomsheetRefHelp = useRef(null)
  const bottomSheetTokenRef = useRef(null)
  const [validation, setValidation] = useState([])

  const [firstName, setFirstName] = useState('')
  const [lastName, setLastName] = useState('')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [currentIndex, setCurrentIndex] = useState(0)

  const [acceptedLegal, setAcceptedLegal] = useState(false)
  const [acceptedTerms, setAcceptedTerms] = useState(false)
  const [registrationToken, setRegistrationToken] = useState('')
  const [isLoading, setIsLoading] = useState(false)
  const [isShowSuccess, setIsShowSuccess] = useState(false)
  const [isShowError, setIsShowError] = useState(false)
  const [bottomSheetHeight, setBottomSheetHeight] = useState(0)
  const [bottomSheetHelpHeight, setBottomSheetHelpHeight] = useState(0)
  const [bottomSheetTokenHeight, setBottomSheetTokenHeight] = useState(0)
  const [isShowPasswordTips, setIsShowPasswordTips] = useState(false)
  const [isShowPasswordHelp, setIsShowPasswordHelp] = useState(false)
  const [isShowTokenTip, setIsShowTokenTip] = useState(false)
  const [isShowWarning, setIsShowWarning] = useState(false)
  const [errorMessage, setErrorMessage] = useState('')

  const { trackPageView, trackEvent } = useMatomo()

  const [showToken, setShowToken] = useState(false)

  useEffect(() => {
    const { height } = bottomsheetRef.current.getBoundingClientRect()
    setBottomSheetHeight(height)
    trackPageView({ documentTitle: 'Signup' })
    return () => {}
  }, [])

  useEffect(() => {
    const { height } = bottomsheetRefHelp.current.getBoundingClientRect()
    setBottomSheetHelpHeight(height)
    return () => {}
  }, [])

  useEffect(() => {
    const { height } = bottomSheetTokenRef.current.getBoundingClientRect()
    setBottomSheetTokenHeight(height)
    return () => {}
  }, [])

  useEffect(() => {
    !showToken && setRegistrationToken('')
    return () => {}
  }, [showToken])

  const toLogin = () => {
    history.replace('/login')
  }

  const goBack = () => {
    history.goBack()
  }

  const onSubmit = async (ignoreWarning = true) => {
    console.log('=== onSubmit called ===')
    console.log('Signup onSubmit called', { ignoreWarning, firstName, lastName, email, password, registrationToken });
    if (!ignoreWarning && registrationToken.length === 0) {
      setIsShowWarning(true)
      return
    }

    setIsLoading(true)
    trackEvent({ category: 'Signup', action: 'attempt signup' })

    try {
      const result = await signup(email, password, firstName, lastName)
      console.log('Signup result:', result);

      if (result.access_token) {
        showSuccess(email)
        trackEvent({ category: 'Signup', action: 'successful signup' })
        if (process.env.ENV === 'prod') {
          // eslint-disable-next-line no-undef
          gtag('event', 'conversion', {
            send_to: 'AW-10798735005/_GZGCPOorYcDEJ29np0o'
          })
        }
      }
    } catch (error) {
      console.error('Signup error:', error)
      console.error('Error message:', error.message)
      console.error('Error graphQLErrors:', error.graphQLErrors)
      console.error('Error networkError:', error.networkError)
      Sentry.captureException('Signup error:', error)
      let validationErrors = []
      if (!firstName) validationErrors.push('emptyFirstname')
      if (!lastName) validationErrors.push('emptyLastname')
      if (!email) validationErrors.push('emptyEmail')
      if (!password) validationErrors.push('emptyPassword')
      if (error.message.includes('Email already exists')) {
        console.log('Email already exists error detected')
        validationErrors.push('emailExists')
      }
      console.log('Validation errors:', validationErrors)
      showError(validationErrors)
      setErrorMessage(error.message || t('signup__error__general'))
    }
    setIsLoading(false)
  }

  const showSuccess = username => {
    setIsShowSuccess(true)
  }

  const showError = (validation = [], passwordValidation) => {
    let val = '<ul style="margin: 0; padding-left: 20px; text-align: left;">'

    validation.forEach(v => {
      val += '<li style="margin-bottom: 8px;">'
      v === 'emptyFirstname' && (val += t('signup__validation__firstname'))
      v === 'emptyLastname' && (val += t('signup__validation__lastname'))
      v === 'emptyEmail' && (val += t('signup__validation__email_empty'))
      v === 'invalidEmail' && (val += t('signup__validation__email_invalid'))
      v === 'emailExists' &&
        ((val += t('signup__validation__exists')),
        Sentry.captureMessage('Signup: Email exists'))
      v === 'emptyPassword' && (val += t('signup__validation__password'))
      val += '</li>'
    })

    passwordValidation?.forEach(v => {
      val += '<li style="margin-bottom: 8px;">'
      v !== 'invalidPassword' && (val += v)
      val += '</li>'
    })

    val += '</ul>'

    console.log('Validation errors:', validation, 'HTML:', val) // Debug log
    setValidation(val)
    setIsShowError(true)
  }

  const showPasswordTips = () => {
    setIsShowPasswordTips(true)
    bottomsheetRef.current.style.top = `calc(100% - ${bottomSheetHeight}px)`
  }

  const hidePasswordTips = () => {
    setIsShowPasswordTips(false)
    bottomsheetRef.current.style.top = `100vh`
  }

  const showPasswordHelp = () => {
    setIsShowPasswordHelp(true)
    bottomsheetRefHelp.current.style.top = `calc(100% - ${bottomSheetHelpHeight}px)`
  }

  const hidePasswordHelp = () => {
    setIsShowPasswordHelp(false)
    bottomsheetRefHelp.current.style.top = `100vh`
  }

  const showTokenTip = () => {
    setIsShowTokenTip(true)
    bottomSheetTokenRef.current.style.top = `calc(100% - ${bottomSheetTokenHeight}px)`
  }

  const hideTokenTip = () => {
    setIsShowTokenTip(false)
    bottomSheetTokenRef.current.style.top = `100vh`
  }

  return (
    <div className={'screen-signup'}>
      <div className="signup__header">
        <Logo />
        <CloseButton onClick={goBack} />
      </div>
      <div className="signup__content">
        <ProgressBar progress={((currentIndex + 1) / 3) * 100} />
        <Questionnaire
          style={{ flex: 1 }}
          currentIndex={currentIndex}
          questionCount={3}
          onChange={index => setCurrentIndex(index)}
          viewMode="view"
          views={[
            <DataView
              firstname={firstName}
              lastname={lastName}
              email={email}
              onFirstnameChange={setFirstName}
              onLastnameChange={setLastName}
              onEmailChange={setEmail}
              onNext={() => setCurrentIndex(idx => idx + 1)}
              showError={showError}
            />,
            <PasswordView
              firstname={firstName}
              lastname={lastName}
              email={email}
              password={password}
              setPassword={setPassword}
              showPasswordTips={showPasswordTips}
              onNext={() => setCurrentIndex(idx => idx + 1)}
            />,
            <TokenView
              showToken={showToken}
              token={registrationToken}
              onTokenChange={setRegistrationToken}
              onShowToken={setShowToken}
              onShowTip={showTokenTip}
              acceptedLegal={acceptedLegal}
              acceptedTerms={acceptedTerms}
              setAcceptedLegal={setAcceptedLegal}
              setAcceptedTerms={setAcceptedTerms}
              onNext={onSubmit}
              isLoading={isLoading}
            />
          ]}
        />
      </div>

      <div
        style={{
          pointerEvents: 'none',
          position: 'fixed',
          top: 0,
          right: 0,
          bottom: 0,
          left: 0,
          backgroundColor: `rgba(0, 0, 0, ${
            isShowSuccess || isShowError || isShowWarning ? 0.6 : 0
          })`,
          transition: 'background .3s ease'
        }}>
        <Prompt
          style={{ width: 'calc(100% - 64px)' }}
          direction={isShowSuccess ? 'center' : 'bottom'}
          icon={isShowSuccess && <BigCheckIcon />}
          title={t('signup__success__title')}
          subtitle={
            <Trans i18nKey="signup__success__subtitle">
              <strong>{{ email }}</strong>
            </Trans>
          }
          button={
            isShowSuccess && (
              <Button onClick={toLogin}>{t('btn__to_login')}</Button>
            )
          }
        />
        <Prompt
          style={{ width: 'calc(100% - 64px)' }}
          direction={isShowError ? 'center' : 'bottom'}
          icon={isShowError && <WarningIcon />}
          title={t('signup__prompt__error__subtitle')}
          text={validation}
          button={
            isShowError && (
              <Button onClick={() => setIsShowError(false)}>
                {t('btn__retry')}
              </Button>
            )
          }
        />
        <Prompt
          style={{ width: 'calc(100% - 64px)' }}
          direction={isShowWarning ? 'center' : 'bottom'}
          icon={isShowWarning && <WarningIcon />}
          title={t('signup__warning__title')}
          subtitle={t('signup__warning__subtitle')}
          button={
            isShowWarning && (
              <div className="row">
                <div className="col-6">
                  <Button
                    className="outline"
                    onClick={() => setIsShowWarning(false)}>
                    {t('btn__back')}
                  </Button>
                </div>
                <div className="col-6">
                  <Button onClick={() => onSubmit(true)}>
                    {t('btn__continue')}
                  </Button>
                </div>
              </div>
            )
          }
        />
      </div>

      <BottomSheet ref={bottomsheetRef}>
        <div className="signup__password-tips">
          <div className="row">
            <div className="col-12">
              <h2>{t('signup__password__tips__title')}</h2>
            </div>
          </div>
          <div className="row">
            <div className="col-12">
              <p>{t('signup__password__tips__subtitle')}</p>
            </div>
          </div>
          <div className="row">
            <div className="col-12">
              <Button onClick={hidePasswordTips}>{t('btn__ok')}</Button>
            </div>
          </div>
        </div>
      </BottomSheet>

      <BottomSheet ref={bottomsheetRefHelp}>
        <div className="signup__password-help">
          <div className="row">
            <div className="col-12">
              <h2>{t('signup__password__help__title')}</h2>
            </div>
          </div>
          <div className="row">
            <div className="col-12">
              <p>{t('signup__password__help__subtitle')}</p>
            </div>
          </div>
          <div className="row">
            <div className="col-12">
              <Button onClick={hidePasswordHelp}>{t('btn__ok')}</Button>
            </div>
          </div>
        </div>
      </BottomSheet>

      <BottomSheet ref={bottomSheetTokenRef}>
        <div className="signup__token-tip">
          <div className="row">
            <div className="col-12">
              <h2>{t('signup__token__tip__title')}</h2>
            </div>
          </div>
          <div className="row">
            <div className="col-12">
              <p>{t('signup__token__tip__subtitle')}</p>
            </div>
          </div>
          <div className="row">
            <div className="col-12">
              <Button onClick={hideTokenTip}>{t('btn__ok')}</Button>
            </div>
          </div>
        </div>
      </BottomSheet>
    </div>
  )
}