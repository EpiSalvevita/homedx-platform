import React, { useState, useEffect } from 'react'

import { useTranslation } from 'react-i18next'

import Questionnaire from '../widgets/Questionnaire'
import DataView from '../components/signup/DataView'
import TokenView from '../components/signup/TokenView'
import PasswordView from '../components/signup/PasswordView'
import { Button, Heading, Modal, Text, View } from 'native-base'
import Logo from '../assets/images/logo.svg'
// import ProgressBar from 'components/ProgressBar'
import { useNavigation } from '@react-navigation/native'
import useHomedx from '../hooks/useHomedx'
import { HdxSignupData } from '../models/HdxTypes'

export default function Signup() {
  const { t } = useTranslation()
  const navigation = useNavigation()
  const { registerAccount } = useHomedx()
  // const bottomsheetRef = useRef(null)
  // const bottomsheetRefHelp = useRef(null)
  // const bottomSheetTokenRef = useRef(null)
  const [validation, setValidation] = useState<string>()

  const [firstname, setFirstname] = useState('')
  const [lastname, setLastname] = useState('')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [currentIndex, setCurrentIndex] = useState(0)

  const [acceptedLegal, setAcceptedLegal] = useState(false)
  const [acceptedTerms, setAcceptedTerms] = useState(false)
  const [registrationToken, setRegistrationToken] = useState('')
  const [isLoading, setIsLoading] = useState(false)
  const [isShowSuccess, setIsShowSuccess] = useState(false)
  const [isShowError, setIsShowError] = useState(false)
  // const [bottomSheetHeight, setBottomSheetHeight] = useState(0)
  // const [bottomSheetHelpHeight, setBottomSheetHelpHeight] = useState(0)
  // const [bottomSheetTokenHeight, setBottomSheetTokenHeight] = useState(0)
  const [isShowPasswordTips, setIsShowPasswordTips] = useState(false)
  const [isShowPasswordHelp, setIsShowPasswordHelp] = useState(false)
  const [isShowTokenTip, setIsShowTokenTip] = useState(false)
  const [isShowWarning, setIsShowWarning] = useState(false)

  // const { trackPageView, trackEvent } = useMatomo()

  const [showToken, setShowToken] = useState(false)

  // useEffect(() => {
  //   const { height } = bottomsheetRef.current.getBoundingClientRect()
  //   setBottomSheetHeight(height)
  //   // trackPageView({ documentTitle: 'Signup' })
  //   return () => {}
  // }, [])
  // useEffect(() => {
  //   const { height } = bottomsheetRefHelp.current.getBoundingClientRect()
  //   setBottomSheetHelpHeight(height)
  //   return () => {}
  // }, [])
  // useEffect(() => {
  //   const { height } = bottomSheetTokenRef.current.getBoundingClientRect()
  //   setBottomSheetTokenHeight(height)
  //   return () => {}
  // }, [])

  const onSubmit = async (ignoreWarning = true) => {
    if (!ignoreWarning && registrationToken.length === 0) {
      setIsShowWarning(true)
      return
    }

    setIsLoading(true)
    // trackEvent({ category: 'Signup', action: 'attempt signup' })

    const data: HdxSignupData = {
      firstname,
      lastname,
      email,
      password
    }
    if (registrationToken.length > 0) data.registrationToken = registrationToken

    const res = await registerAccount(data)

    if (res.success) {
      if (res.username) {
        showSuccess()
        // trackEvent({ category: 'Signup', action: 'successful signup' })
        if (process.env.ENV === 'prod') {
          // eslint-disable-next-line no-undef
          // gtag('event', 'conversion', {
          //   send_to: 'AW-10798735005/_GZGCPOorYcDEJ29np0o'
          // })
        }
      }
    } else {
      showError(res.validation || [], res.passwordFeedback || [])
    }
    setIsLoading(false)
  }

  const showSuccess = () => {
    setIsShowSuccess(true)
  }
  const showError = (validation: string[], passwordValidation: string[]) => {
    let val = '<ul class="list primary">'

    validation.forEach(v => {
      val += '<li class="list__item">'
      v === 'emptyFirstname' && (val += t('signup__validation__firstname'))
      v === 'emptyLastname' && (val += t('signup__validation__lastname'))
      v === 'emptyEmail' && (val += t('signup__validation__email_empty'))
      v === 'invalidEmail' && (val += t('signup__validation__email_invalid'))
      v === 'emailExists' && (val += t('signup__validation__exists'))
      // ,
      // Sentry.captureMessage('Signup: Email exists'))
      v === 'emptyPassword' && (val += t('signup__validation__password'))
      v === 'emptyRegistrationToken' &&
        (val += t('signup__validation__token_empty'))
      v === 'invalidRegistrationToken' &&
        (val += t('signup__validation__token_invalid'))
      // ,
      // Sentry.captureMessage('Signup: Invalid Token'))
      ;(v === 'contingentConsumed' || v === 'clientDeactivated') &&
        (val += t('signup__validation__denied'))

      v === 'invalidDiscount' &&
        (val += t('signup__validation__discount_invalid'))
      v === 'expiredDiscount' &&
        (val += t('signup__validation__discount_expired'))

      val += '</li>'
    })

    passwordValidation?.forEach(v => {
      val += '<li class="list__item">'
      v !== 'invalidPassword' && (val += v)
      val += '</li>'
    })

    val += '</ul>'

    setValidation(val)
    setIsShowError(true)
  }

  const showPasswordTips = () => {
    setIsShowPasswordTips(true)
    // bottomsheetRef.current.style.top = `calc(100% - ${bottomSheetHeight}px)`
  }
  const hidePasswordTips = () => {
    setIsShowPasswordTips(false)
    // bottomsheetRef.current.style.top = `100vh`
  }

  const showPasswordHelp = () => {
    setIsShowPasswordHelp(true)
    // bottomsheetRefHelp.current.style.top = `calc(100% - ${bottomSheetHelpHeight}px)`
  }
  const hidePasswordHelp = () => {
    setIsShowPasswordHelp(false)
    // bottomsheetRefHelp.current.style.top = `100vh`
  }
  const showTokenTip = () => {
    setIsShowTokenTip(true)
    // bottomSheetTokenRef.current.style.top = `calc(100% - ${bottomSheetTokenHeight}px)`
  }
  const hideTokenTip = () => {
    setIsShowTokenTip(false)
    // bottomSheetTokenRef.current.style.top = `100vh`
  }

  useEffect(() => {
    !showToken && setRegistrationToken('')
    return () => {}
  }, [showToken])

  return (
    <View flex="1" justifyContent="flex-end">
      {/* <Logo /> */}

      {/* <ProgressBar progress={((currentIndex + 1) / 3) * 100} /> */}
      <Questionnaire
        style={{ flex: 1 }}
        currentIndex={currentIndex}
        viewMode="view"
        questionCount={3}
        views={[
          <DataView
            firstname={firstname}
            lastname={lastname}
            email={email}
            setFirstname={setFirstname}
            setLastname={setLastname}
            setEmail={setEmail}
            onNext={() => setCurrentIndex(prev => prev + 1)}
            showError={showError}
          />,
          <PasswordView
            firstname={firstname}
            lastname={lastname}
            email={email}
            showPasswordTips={showPasswordTips}
            setPassword={setPassword}
            password={password}
            onNext={() => setCurrentIndex(prev => prev + 1)}
          />,
          <TokenView
            showTokenTip={showTokenTip}
            registrationToken={registrationToken}
            setRegistrationToken={setRegistrationToken}
            showToken={showToken}
            setShowToken={setShowToken}
            isLoading={isLoading}
            acceptedLegal={acceptedLegal}
            acceptedTerms={acceptedTerms}
            setAcceptedLegal={setAcceptedLegal}
            setAcceptedTerms={setAcceptedTerms}
            onNext={onSubmit}
          />
        ]}
      />

      <Modal isOpen={isShowSuccess} onClose={() => setIsShowSuccess(false)}>
        <Modal.Content>
          <Modal.Header>
            {t('signup__prompt__success__title')}
            <Modal.CloseButton />
          </Modal.Header>
          <Modal.Body>
            <Text>{t('signup__prompt__success__subtitle')}</Text>
          </Modal.Body>
          <Modal.Footer>
            <Button
              variant={'ghost'}
              onPress={() => (
                setIsShowSuccess(false), navigation.navigate('Login')
              )}>
              {t('btn__nav__login')}
            </Button>
          </Modal.Footer>
        </Modal.Content>
      </Modal>
      <Modal isOpen={isShowError} onClose={() => setIsShowError(false)}>
        <Modal.Content>
          <Modal.Header>
            {t('signup__prompt__error__title')}
            <Modal.CloseButton />
          </Modal.Header>
          <Modal.Body>
            <Heading>{t('signup__prompt__error__subtitle')}</Heading>
            <Text>{validation}</Text>
          </Modal.Body>
          <Modal.Footer>
            <Button variant={'ghost'} onPress={() => setIsShowError(false)}>
              {t('btn__back')}
            </Button>
          </Modal.Footer>
        </Modal.Content>
      </Modal>
    </View>
  )
}
