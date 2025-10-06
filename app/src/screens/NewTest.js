import React, { useCallback, useEffect, useState } from 'react'
import { useMutation } from '@apollo/client'
import { useSelector } from 'react-redux'
import { useHistory } from 'react-router'
import { Prompt as RouterPrompt } from 'react-router-dom'
import { useMatomo } from '@datapunt/matomo-tracker-react'
import { Trans, useTranslation } from 'react-i18next'
import * as Sentry from '@sentry/react'

import Button from 'components/Button'
import Prompt from 'components/Prompt'
import ComponentStep from 'components/test_steps/ComponentStep'
import TutorialStep from 'components/test_steps/TutorialStep'
import VideoStep from 'components/test_steps/VideoStep'
import PhotoStep from 'components/test_steps/PhotoStep'
import OverviewStep from 'components/test_steps/OverviewStep'
import LicenseStep from 'components/test_steps/LicenseStep'
import CheckoutStep from 'components/test_steps/CheckoutStep'
import TestKitStep from 'components/test_steps/TestKitStep'
import PINStep from 'components/test_steps/PINStep'
import ProgressBar from 'components/ProgressBar'
import ContentHeader from 'components/ContentHeader'
import CWAStep from 'components/test_steps/CWAStep'

import ErrorIcon from 'assets/icons/ic_error.svg'
import WarningIcon from 'assets/icons/ic_warning.svg'
import CheckIcon from 'assets/icons/ic_success.svg'
import LoadingIcon from 'assets/icons/ic_loading.svg'

import { SUBMIT_TEST } from 'services/graphql'

export default function NewTest() {
  const { t } = useTranslation()

  const { capRapidTestAddWithoutLicense, testaccount } = useSelector(
    ({ base }) => base?.userdata
  )
  const { backendStatus } = useSelector(({ base }) => base)

  const {
    idCardFrontUrl,
    idCardBackUrl,
    profileImageUrl,
    paymentId,
    paymentMethod,
    licenseCode,
    identityID
  } = useSelector(({ test }) => test)

  const history = useHistory()
  const [testData, setTestData] = useState({})
  const [steps, setSteps] = useState([])
  const [loadingText, setLoadingText] = useState(t('please_wait'))
  const [loadingTitle, setLoadingTitle] = useState(t('loading'))
  const [isLoading, setIsLoading] = useState(true)
  const [currentIndex, setCurrentIndex] = useState(0)
  const [isShowMessage, setIsShowMessage] = useState(false)
  const [messageType, setMessageType] = useState('')
  const [messageTitle, setMessageTitle] = useState('')
  const [messageSubtitle, setMessageSubtitle] = useState('')
  const [messageText, setMessageText] = useState('')
  const [messageContent, setMessageContent] = useState(null)
  const { trackPageView, trackEvent } = useMatomo()

  const [submitTestMutation] = useMutation(SUBMIT_TEST, {
    onCompleted: (data) => {
      if (!data.submitTest.success) {
        Sentry.captureException('NewTest: Test submit error')
        if (data.submitTest.validation) {
          showValidationError(data.submitTest.validation)
        } else {
          showError()
        }
      } else {
        trackEvent({ category: 'NewTest', action: 'successful submitted test' })
        setTimeout(() => {
          end()
        }, 1000)
      }
      setIsLoading(false)
    },
    onError: () => {
      showError()
      setIsLoading(false)
    }
  })

  useEffect(() => {
    trackPageView({
      documentTitle: 'NewTest v' + window.VERSION
    })
    return () => {}
  }, [trackPageView])

  useEffect(() => {
    const steps = [
      'onboarding',
      'testkitphoto',
      'pin',
      'testkit',
      'tutorial',
      'video',
      'photo'
    ]

    if (!capRapidTestAddWithoutLicense && paymentMethod === 'payment') {
      steps.push('checkout')
    }
    if (backendStatus.cwa || backendStatus.cwaLaive) {
      steps.splice(1, 0, 'cwa')
    }
    setSteps(steps)
    setIsLoading(false)

    return () => {}
  }, [
    capRapidTestAddWithoutLicense,
    backendStatus,
    paymentMethod
  ])

  useEffect(() => {
    if (steps.length && currentIndex === steps.length) {
      submitTest()
    }
    return () => {}
  }, [currentIndex, steps.length, submitTest])

  const next = useCallback(
    skipReset => {
      setCurrentIndex(currentIndex + 1)
      setIsLoading(false)
      !skipReset && resetMessage()
    },
    [currentIndex, resetMessage]
  )

  const resetMessage = useCallback(() => {
    setIsShowMessage(false)
    setIsLoading(false)

    if (
      messageType === 'error' &&
      capRapidTestAddWithoutLicense &&
      steps[currentIndex] === t('test__step_license')
    ) {
      setCurrentIndex(currentIndex - 1)
    }

    setTimeout(() => {
      setMessageType('success')
      setMessageTitle(null)
      setMessageSubtitle(null)
      setMessageText(null)
      setMessageContent(null)
    }, 600)
  }, [capRapidTestAddWithoutLicense, currentIndex, messageType, steps, t])

  const end = () => {
    setMessageType('success')
    setMessageTitle(t('test__prompt__end__title'))
    setMessageSubtitle(t('test__prompt__end__text'))
    setIsShowMessage(true)
  }

  const goBack = useCallback(() => {
    history.replace('/dashboard')
    trackEvent({
      category: 'NewTest',
      action: `navigated back from: ${steps[currentIndex]}`
    })
  }, [currentIndex, history, steps, trackEvent])

  const setLoading = (load, title, text) => {
    title && setLoadingTitle(title)
    text && setLoadingText(text)
    setIsLoading(load)
  }

  const onVideoUploaded = videoData => {
    setTestData(prev => ({
      ...prev,
      videoUrl: videoData
    }))
    showInfo('video')
  }

  const onPINNext = pin => {
    setTestData(prev => ({
      ...prev,
      liveToken: pin
    }))
    next()
  }

  const onPhotoUploaded = photoData => {
    setTestData(prev => ({
      ...prev,
      photoUrl: photoData,
      testDate: Date.now() / 1000
    }))
    showInfo('photo')
  }

  const onTestKitPhotoUploaded = photoData => {
    setTestData(prev => ({
      ...prev,
      testDeviceUrl: photoData
    }))
    showInfo('photo')
  }

  const submitTest = useCallback(async () => {
    trackEvent({ category: 'NewTest', action: 'attempt submitting test' })
    setLoadingTitle(t('test__prompt__submit__title'))
    setLoadingText(t('test__prompt__submit__text'))
    setIsLoading(true)

    const variables = {
      ...testData,
      videoUrl: testData.videoUrl || "",
    }

    if (paymentId) variables.paymentId = paymentId
    if (licenseCode) variables.licenseCode = licenseCode
    if (idCardFrontUrl?.length > 0) variables.identityCard1Url = idCardFrontUrl
    if (idCardBackUrl?.length > 0) variables.identityCard2Url = idCardBackUrl
    if (profileImageUrl?.length > 0) variables.identifyUrl = profileImageUrl
    if (identityID?.length > 0) variables.identityCardId = identityID

    submitTestMutation({
      variables
    })
  }, [
    idCardBackUrl,
    idCardFrontUrl,
    licenseCode,
    paymentId,
    profileImageUrl,
    identityID,
    testData,
    submitTestMutation,
    t,
    trackEvent
  ])

  const showWarning = warning => {
    setMessageType('warning')
    switch (warning) {
      case 'begin':
        setMessageTitle(t('test__prompt__begin__title'))
        setMessageSubtitle('')
        setMessageText('')
        setMessageContent(
          <Trans i18nKey="test__prompt__begin__text">
            <br />
            <strong>Bitte beachten Sie:</strong> Der Abstrich kann pro Test nur
            einmalig durchgeführt werden!
          </Trans>
        )
        break
      default:
        break
    }
    setIsShowMessage(true)
  }

  const showInfo = info => {
    setMessageType('info')
    switch (info) {
      case 'video':
        setMessageTitle(t('test__prompt__info_video__title'))
        setMessageSubtitle(t('test__prompt__info_video__subtitle'))
        setMessageText(t('test__prompt__info_video__text'))
        break
      case 'photo':
        setMessageTitle(t('test__prompt__info_photo__title'))
        setMessageSubtitle(t('test__prompt__info_photo__subtitle'))
        setMessageText(t('test__prompt__info_photo__text'))
        break
      default:
        break
    }
    setIsShowMessage(true)
  }

  const showError = useCallback(
    err => {
      setMessageType(err || 'error')
      if (err) {
        if (err === 'bytes') {
          setMessageTitle(t('test__prompt__error__title_bytes'))
          setMessageSubtitle(t('test__prompt__error__subtitle_bytes'))
        }
        if (err === 'corrupt') {
          setMessageTitle(t('test__prompt__error__title_corrupt'))
          setMessageSubtitle(t('test__prompt__error__subtitle_corrupt'))
        }
      } else {
        setMessageTitle(t('test__prompt__error__title'))
        setMessageSubtitle(t('test__prompt__error__subtitle'))
      }
      setIsShowMessage(true)
    },
    [t]
  )

  const showValidationError = useCallback(
    validation => {
      setTimeout(() => {
        setMessageType('error')

        let val = '<ul class="list primary">'
        console.log('error validation', validation)
        validation.forEach(v => {
          console.log(
            `test__prompt__validation_${v}`,
            t(`test__prompt__validation_${v}`)
          )
          val += '<li class="list__item">'
          val += t(`test__prompt__validation_${v}`)
          val += '</li>'
        })

        val += '</ul>'

        setMessageText(val)
        setIsShowMessage(true)
      }, 600)
    },
    [t]
  )

  const getPromptButton = () => {
    switch (messageType) {
      case 'success':
        return (
          <Button onClick={goBack}>{t('test__prompt__success__btn')}</Button>
        )
      case 'info':
      case 'warning':
        return <Button onClick={next}>{t('test__prompt__warning__btn')}</Button>
      case 'back':
        return (
          <Button onClick={resetMessage}>{t('test__prompt__back__btn')}</Button>
        )
      case 'error':
      case 'bytes':
      case 'corrupt':
        return (
          <Button
            onClick={() => {
              resetMessage()
            }}>
            {t('btn__retry')}
          </Button>
        )
      default:
        return null
    }
  }

  const getSecondaryPromptButton = () => {
    switch (messageType) {
      case 'back':
        return (
          <Button className="ghost" onClick={goBack}>
            {t('test__prompt__back__btn2')}
          </Button>
        )
      case 'error':
      case 'bytes':
      case 'corrupt':
        return (
          <Button
            className="ghost"
            onClick={() => {
              history.goBack()
            }}>
            {t('test__prompt__warning__btn2')}
          </Button>
        )
      case 'warning':
        return (
          <Button
            className="ghost"
            onClick={() => {
              resetMessage()
            }}>
            {t('test__prompt__warning__btn2')}
          </Button>
        )
      case 'success':
      default:
        return null
    }
  }

  const onCWAChoiceMade = choice => {
    setTestData(prev => ({
      ...prev,
      agreementGiven: choice
    }))
    next()
  }

  return (
    <>
      <div
        className={`screen-new-test ${
          isLoading || isShowMessage ? 'hide' : ''
        }`}>
        <ContentHeader
          showTitle={currentIndex > 0}
          onBack={goBack}
          title={t('test__new')}
        />
        {currentIndex > 0 && (
          <ProgressBar progress={(currentIndex / (steps.length - 1)) * 100} />
        )}

        {steps[currentIndex] === 'onboarding' && (
          <OverviewStep onNext={next} isDone />
        )}
        {steps[currentIndex] === 'cwa' && (
          <CWAStep onCWAChoiceMade={onCWAChoiceMade} />
        )}
        {steps[currentIndex] === 'tutorial' && <TutorialStep onNext={next} />}
        {steps[currentIndex] === 'testkit' && (
          <ComponentStep onNext={() => showWarning('begin')} />
        )}
        {steps[currentIndex] === 'video' && (
          <VideoStep
            onLoad={setLoading}
            onSuccess={onVideoUploaded}
            onError={showError}
            allowShortVideo={testaccount}
          />
        )}
        {steps[currentIndex] === 'testkitphoto' && (
          <TestKitStep
            onLoad={setLoading}
            onSuccess={onTestKitPhotoUploaded}
            onError={showError}
          />
        )}
        {steps[currentIndex] === 'pin' && (
          <PINStep onNext={onPINNext} onLoad={setLoading} />
        )}
        {steps[currentIndex] === 'photo' && (
          <PhotoStep
            onLoad={setLoading}
            onSuccess={onPhotoUploaded}
            onError={showError}
          />
        )}
        {steps[currentIndex] === 'checkout' && (
          <CheckoutStep onSuccess={next} />
        )}
      </div>

      <RouterPrompt
        when={currentIndex > 0}
        message={t('test__prompt__leave__text')}
      />

      <Prompt
        direction={isShowMessage ? 'center' : 'right'}
        title={messageTitle}
        subtitle={messageSubtitle}
        text={messageText}
        content={messageContent}
        icon={
          messageType === 'success' ? (
            <CheckIcon />
          ) : messageType === 'warning' ? (
            <WarningIcon />
          ) : messageType === 'error' ||
            messageType === 'bytes' ||
            messageType === 'corrupt' ? (
            <ErrorIcon />
          ) : (
            <LoadingIcon />
          )
        }
        button={getPromptButton()}
        buttonSecondary={getSecondaryPromptButton()}
      />
    </>
  )
}
