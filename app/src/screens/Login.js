import React, { useState } from 'react'
import { useDispatch } from 'react-redux'
import { useHistory, Link } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import * as Sentry from '@sentry/react'

import Form from 'components/Form'
import TextInput from 'components/TextInput'
import Prompt from 'components/Prompt'
import Button from 'components/Button'
import SubmitButton from 'components/SubmitButton'
import CloseButton from 'components/CloseButton'

import HideIcon from 'assets/icons/ic_password_hide.svg'
import ShowIcon from 'assets/icons/ic_password_show.svg'
import Logo from 'assets/icons/ic_logo-alt.svg'

import { login } from '../services/auth.service'

export default function Login() {
  const history = useHistory()
  const [email, setEmail] = useState('')
  const [isInvalid, setIsInvalid] = useState(false)
  const [isLoading, setIsLoading] = useState(false)
  const [password, setPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [errorMessage, setErrorMessage] = useState('')

  const dispatch = useDispatch()
  const { t } = useTranslation()

  const onSubmit = async () => {
    try {
      setIsLoading(true)
      const result = await login(email, password)
      
      if (result.access_token) {
        dispatch({ type: 'setToken', token: result.access_token })
        if (result.user) {
          dispatch({ type: 'setUserdata', userdata: result.user })
        }
        history.replace('/dashboard')
        dispatch({ type: 'isLoading', isLoading: true })
      } else {
        setErrorMessage(t('login__error__invalid_credentials'))
        setIsInvalid(true)
        setIsLoading(false)
      }
    } catch (error) {
      console.error('Login error:', error)
      Sentry.captureException('Login: error', error)
      setErrorMessage(error.message || t('login__error__general'))
      setIsInvalid(true)
      setIsLoading(false)
    }
  }

  const goBack = () => {
    history.goBack()
  }

  return (
    <div className={'screen-login'}>
      <div className="login__header">
        <CloseButton onClick={goBack} />
      </div>
      <div className="login__content">
        <div className="row">
          <div className="col-12">
            <Logo />
            <h1 className="alt">{t('login__title')}</h1>
          </div>
        </div>
        <div className="row">
          <div className="col-12">
            <p className="alt">{t('login__subtitle')}</p>
          </div>
        </div>
        <Form onSubmit={onSubmit}>
          <div className="row">
            <div className="col-12">
              <TextInput
                className="alt"
                type="email"
                placeholder={t('email')}
                onChange={val => setEmail(val)}
              />
            </div>
          </div>
          <div className="row">
            <div className="col-12" style={{ position: 'relative' }}>
              <TextInput
                className="alt"
                type={showPassword ? 'text' : 'password'}
                placeholder={t('password')}
                onChange={val => setPassword(val)}
              />
              <div
                className="login__showPassword"
                onClick={() => setShowPassword(prev => !prev)}>
                {showPassword ? <ShowIcon /> : <HideIcon />}
              </div>
            </div>
          </div>
          <div className="row">
            <div className="col-12">
              <SubmitButton
                className={'alt'}
                disabled={isLoading}
                type="submit"
                value={t('btn__login')}
              />
            </div>
          </div>
        </Form>
        <div
          className="row"
          style={{ justifyContent: 'center', marginBottom: 10 }}>
          <Link to="/forgot-password">{t('btn__forgot_password')}</Link>
        </div>
        <div
          className="row"
          style={{
            marginTop: 10,
            alignItems: 'center',
            justifyContent: 'center'
          }}>
          <a
            style={{ textAlign: 'center' }}
            href="/privacy-policy"
            target="_blank"
            rel="noopener noreferrer">
            {t('login__privacy_policy')}
          </a>
          <span style={{ marginLeft: 5, marginRight: 5 }}>{' | '}</span>
          <a
            style={{ textAlign: 'center' }}
            href="/impressum"
            target="_blank"
            rel="noopener noreferrer">
            {t('login__impressum')}
          </a>
        </div>
      </div>
      <div
        style={{
          pointerEvents: 'none',
          position: 'fixed',
          top: 0,
          right: 0,
          bottom: 0,
          left: 0,
          backgroundColor: `rgba(0, 0, 0, ${isInvalid ? 0.6 : 0})`,
          transition: 'background .3s ease'
        }}>
        <Prompt
          style={{ width: 'calc(100% - 64px)' }}
          direction={isInvalid ? 'center' : 'bottom'}
          title={t('login__prompt__title')}
          subtitle={errorMessage || t('login__prompt__subtitle')}
          button={
            <Button onClick={() => setIsInvalid(false)}>
              {t('btn__retry')}
            </Button>
          }
        />
      </div>
    </div>
  )
}
