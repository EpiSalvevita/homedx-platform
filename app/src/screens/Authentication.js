import React, { useState, useEffect, useCallback } from 'react'

import IdentityFrontStep from 'components/authentication_steps/IdentityFrontStep'
import IdentityBackStep from 'components/authentication_steps/IdentityBackStep'
import ProfilePictureStep from 'components/authentication_steps/ProfilePictureStep'
import OverviewStep from 'components/test_steps/OverviewStep'

import Prompt from 'components/Prompt'
import Button from 'components/Button'
import ProgressBar from 'components/ProgressBar'
import ContentHeader from 'components/ContentHeader'

import WarningIcon from 'assets/icons/ic_error.svg'
import ProfileIcon from 'assets/icons/ic_profile_prompt.svg'
import CheckIcon from 'assets/icons/ic_success.svg'
import LoadingIcon from 'assets/icons/ic_loading.svg'

import { useHistory } from 'react-router'
import { useDispatch, useSelector } from 'react-redux'
import AuthenticationPrompt from 'components/AuthenticationPrompt'
import { useTranslation } from 'react-i18next'
import IdentityIDStep from 'components/authentication_steps/IdentityIDStep'

export default function Authentication() {
  const dispatch = useDispatch()
  const { t } = useTranslation()
  const history = useHistory()

  const userdata = useSelector(({ base }) => base.userdata)
  const [currentIndex, setCurrentIndex] = useState(0)
  const [steps, setSteps] = useState([])

  const [loadingText, setLoadingText] = useState(t('please_wait'))
  const [loadingTitle, setLoadingTitle] = useState(t('loading'))
  const [isLoading, setIsLoading] = useState(false)

  const [isShowMessage, setIsShowMessage] = useState(false)
  const [messageType, setMessageType] = useState('info')
  const [messageTitle, setMessageTitle] = useState(
    t('auth__require_auth__title')
  )
  const [messageSubtitle, setMessageSubtitle] = useState('')
  const [messageText, setMessageText] = useState(t('auth__require_auth__text'))

  useEffect(() => {
    if (userdata.authorized === 'accepted')
      dispatch({ type: 'setIsAuthenticated', isAuthenticated: true })
    const steps = ['onboarding', '_id', 'id_front', 'id_back', 'id_photo']
    setSteps(steps)
    return () => {}
  }, [dispatch, userdata.authorized])

  const goBack = () => {
    history.goBack()
  }

  const next = useCallback(() => {
    if (currentIndex < steps.length - 1) {
      setCurrentIndex(currentIndex + 1)
    }
    resetMessage()
    setIsLoading(false)
  }, [currentIndex, steps])

  const start = useCallback(() => {
    resetMessage()
    setIsLoading(false)
  }, [])

  const toTest = () => {
    dispatch({ type: 'setIsAuthenticated', isAuthenticated: true })
    history.replace('/new-test')
  }

  const end = () => {
    setMessageType('end')
    setMessageTitle(t('auth__prompt__end__title'))
    setMessageSubtitle('')
    setMessageText(t('auth__prompt__end__text'))
    setIsShowMessage(true)
  }

  const showSuccess = () => {
    setMessageType('success')
    setMessageTitle(t('auth__prompt__success__title'))
    setMessageSubtitle('')
    setMessageText(t('auth__prompt__success__text'))
    setIsShowMessage(true)
  }

  const showError = () => {
    setMessageType('error')
    setMessageTitle(t('auth__prompt__error__title'))
    setMessageSubtitle(t('auth__prompt__error__text'))
    setMessageText('')
    setIsShowMessage(true)
  }

  const resetMessage = () => {
    setIsShowMessage(false)
    setIsLoading(false)
    setTimeout(() => {
      setMessageType('success')
      setMessageTitle(null)
      setMessageSubtitle(null)
      setMessageText(null)
    }, 1000)
  }

  const setLoading = (load, title, text) => {
    title && setLoadingTitle(title)
    text && setLoadingText(text)
    setIsLoading(load)
  }

  const getPromptButton = () => {
    switch (messageType) {
      case 'success':
        return <Button onClick={next}>{t('auth__prompt__success__btn')}</Button>
      case 'end':
        return <Button onClick={toTest}>{t('auth__prompt__end__btn')}</Button>
      case 'info':
        return <Button onClick={start}>{t('auth__prompt__info__btn')}</Button>
      default:
        return null
    }
  }

  const getSecondaryPromptButton = () => {
    switch (messageType) {
      case 'info':
        return (
          <Button className="ghost" onClick={goBack}>
            {t('auth__prompt__info__btn2')}
          </Button>
        )
      case 'error':
        return (
          <Button
            className="ghost"
            onClick={() => {
              resetMessage()
            }}>
            {t('auth__prompt__error__btn2')}
          </Button>
        )
      case 'success':
      default:
        return null
    }
  }

  return (
    <>
      {!userdata.additonalUserDataSubmitted && (
        <>
          <AuthenticationPrompt
            show={true}
            onClick={() => history.push('/change-account-data')}
            onClickSecondary={() => history.goBack()}
          />
        </>
      )}
      {userdata.additonalUserDataSubmitted && (
        <>
          <div
            className={`screen-authentication ${
              isLoading || isShowMessage ? 'hide' : ''
            }`}>
            <ContentHeader
              showTitle={currentIndex > 0}
              onBack={goBack}
              title={t('authentication')}
            />

            {currentIndex > 0 && (
              <ProgressBar
                progress={(currentIndex / (steps.length - 1)) * 100}
              />
            )}
            {steps[currentIndex] === 'onboarding' && (
              <OverviewStep onNext={next} />
            )}
            {steps[currentIndex] === 'id_front' && (
              <IdentityFrontStep
                onLoad={setLoading}
                onSuccess={showSuccess}
                onError={showError}
              />
            )}
            {steps[currentIndex] === 'id_back' && (
              <IdentityBackStep
                onLoad={setLoading}
                onSuccess={showSuccess}
                onError={showError}
              />
            )}
            {steps[currentIndex] === '_id' && <IdentityIDStep onNext={next} />}
            {steps[currentIndex] === 'id_photo' && (
              <ProfilePictureStep
                onLoad={setLoading}
                onSuccess={end}
                onError={showError}
              />
            )}
          </div>
          <Prompt
            direction={`${isShowMessage ? 'center' : 'right'}`}
            icon={
              messageType === 'end' || messageType === 'success' ? (
                <CheckIcon />
              ) : messageType === 'info' ? (
                <ProfileIcon />
              ) : (
                <WarningIcon />
              )
            }
            title={messageTitle}
            subtitle={messageSubtitle}
            text={messageText}
            button={getPromptButton()}
            buttonSecondary={getSecondaryPromptButton()}
          />
          <div className={`loading__wrapper ${isLoading ? 'show' : ''}`}>
            <div className="loading__wrapper--inner">
              <div className="loading__content">
                <div className="loader__icon">
                  <LoadingIcon />
                </div>

                <>
                  <h3>{loadingTitle}</h3>
                  <p>{loadingText}</p>
                </>
              </div>
            </div>
          </div>
        </>
      )}
    </>
  )
}
