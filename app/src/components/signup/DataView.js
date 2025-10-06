import React, { useCallback, useState } from 'react'
import { Trans, useTranslation } from 'react-i18next'
import { useMutation } from '@apollo/client'
import * as Sentry from '@sentry/react'

import Button from 'components/Button'
import TextInput from '../TextInput'

import { CHECK_EMAIL } from 'services/graphql'

export default function DataView({
  firstname,
  lastname,
  email,
  onFirstnameChange,
  onLastnameChange,
  onEmailChange,
  onNext,
  showError
}) {
  const { t } = useTranslation()
  const [isLoading, setIsLoading] = useState(false)

  const [checkEmailMutation] = useMutation(CHECK_EMAIL)

  const checkEmail = useCallback(async () => {
    try {
      setIsLoading(true)
      const { data } = await checkEmailMutation({
        variables: { email }
      })

      if (data.checkEmail.exists) {
        Sentry.captureMessage('Signup: Email exists')
        showError(['emailExists'])
      } else if (!data.checkEmail.valid) {
        showError(['invalidEmail'])
      } else {
        onNext && onNext()
      }
    } catch (error) {
      console.error('Check email error:', error)
      showError(['invalidEmail'])
    } finally {
      setIsLoading(false)
    }
  }, [email, onNext, showError, checkEmailMutation])

  return (
    <div className="signup__data">
      <div className="row">
        <div className="col-12">
          <h2>{t('signup__data__title')}</h2>
        </div>
      </div>
      <div className="row">
        <div className="col-12">
          <p>{t('signup__data__subtitle')}</p>
        </div>
      </div>
      <div className="row">
        <div className="col-12">
          <TextInput
            type="text"
            placeholder={t('firstname')}
            value={firstname}
            onChange={onFirstnameChange}
          />
        </div>
      </div>
      <div className="row">
        <div className="col-12">
          <TextInput
            type="text"
            placeholder={t('lastname')}
            value={lastname}
            onChange={onLastnameChange}
          />
        </div>
      </div>
      <div className="row">
        <div className="col-12">
          <TextInput
            type="email"
            placeholder={t('email')}
            value={email}
            onChange={onEmailChange}
          />
        </div>
      </div>
      <div className="row">
        <div className="col-12">
          <Button
            className="signup__data__btn"
            disabled={isLoading || !firstname || !lastname || !email}
            onClick={checkEmail}>
            {t('btn__next')}
          </Button>
        </div>
      </div>
    </div>
  )
}
