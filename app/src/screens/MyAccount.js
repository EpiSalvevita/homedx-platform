import React, { useEffect, useState } from 'react'
import { useHistory } from 'react-router'
import { useDispatch } from 'react-redux'
import { useMutation } from '@apollo/client'
import { useMatomo } from '@datapunt/matomo-tracker-react'
import { useTranslation, Trans } from 'react-i18next'

import BottomSheet from 'components/BottomSheet'
import Button from 'components/Button'
import Prompt from 'components/Prompt'

import CaretIcon from 'assets/icons/ic_caret.svg'
import WarningIcon from 'assets/icons/ic_warning.svg'
import SuccessIcon from 'assets/icons/ic_success.svg'

import { logout } from 'Store'
import { RESET_AUTHENTICATION, RESET_CWA_LINK } from 'services/graphql'
import {
  GET_USER_DATA,
  GET_PROFILE_IMAGE,
  UPDATE_USER_DATA
} from 'services/graphql'

export default function MyAccount() {
  const { t } = useTranslation()
  const history = useHistory()
  const [showAccount, setShowAccount] = useState(false)
  const [showMessage, setShowMessage] = useState(false)
  const { trackPageView, trackEvent } = useMatomo()
  const [messageType, setMessageType] = useState('warning')
  const dispatch = useDispatch()

  const [resetAuthMutation] = useMutation(RESET_AUTHENTICATION, {
    onCompleted: (data) => {
      if (data.resetAuthentication.success) {
        dispatch({
          type: 'setProfilePhoto',
          photo: null,
          lastModified: Date.now() / 1000
        })
        setMessageType('success')
        setShowMessage(true)
      }
    },
    onError: (error) => {
      console.error('Reset authentication error:', error)
    }
  })

  const [resetCWAMutation] = useMutation(RESET_CWA_LINK, {
    onCompleted: (data) => {
      if (data.resetCWALink.success) {
        setMessageType('cwa')
        setShowMessage(true)
      }
    },
    onError: (error) => {
      setMessageType('cwa_error')
      setShowMessage(true)
      console.error('Reset CWA link error:', error)
    }
  })

  useEffect(() => {
    trackPageView({
      documentTitle: 'MyAccount'
    })
    setShowAccount(true)
    return () => {
      setShowAccount(false)
    }
  }, [trackPageView])

  const resetAuth = () => {
    setShowMessage(false)
    setTimeout(() => {
      resetAuthMutation()
    })
  }

  const resetCWA = () => {
    setShowMessage(false)
    setTimeout(() => {
      resetCWAMutation()
    })
  }

  return (
    <>
      <div className="screen-my-account">
        <BottomSheet
          canGoBack
          hideSpacer
          className={`no-bottombar ${showAccount ? 'open' : ''}`}
          title={t('account__title')}>
          <div className="row">
            <ul className="bottomsheet__list">
              <li onClick={() => history.push('/change-account-data')}>
                <div>
                  <span>{t('account__change_data')}</span>
                  <CaretIcon />
                </div>
              </li>
              <li
                onClick={() => {
                  setMessageType('warning')
                  setShowMessage(true)
                }}>
                <div>
                  <span>
                    <Trans i18nKey="account__reset_auth">
                      Authentifizierung zurücksetzen
                    </Trans>
                  </span>
                  <CaretIcon />
                </div>
              </li>
              <li onClick={() => resetCWA()}>
                <div>
                  <span>
                    <Trans i18nKey="account__reset_cwa">
                      CWA Link zurücksetzen
                    </Trans>
                  </span>
                  <CaretIcon />
                </div>
              </li>
              <li className="bottomsheet__list__item">
                <div>
                  <span>
                    <a
                      href="/privacy-policy"
                      target="_blank"
                      rel="noopener noreferrer">
                      <Trans i18nKey="privacy">Datenschutz</Trans>
                    </a>
                  </span>
                  <CaretIcon />
                </div>
              </li>

              <li className="bottomsheet__list__item">
                <div>
                  <span>
                    <a
                      href="/faq"
                      target="_blank"
                      rel="noopener noreferrer">
                      <Trans i18nKey="help">Hilfe</Trans>
                    </a>
                  </span>
                  <CaretIcon />
                </div>
              </li>
              <li onClick={() => history.push('/tech-support')}>
                <div>
                  <span>{t('account__tech_support')}</span>
                  <CaretIcon />
                </div>
              </li>
              <li onClick={() => history.push('/change-language')}>
                <div>
                  <span>{t('change_language__title')}</span>
                  <CaretIcon />
                </div>
              </li>
              <li className="bottomsheet__list__item">
                <div>
                  <span>
                    <a
                      href="/impressum"
                      target="_blank"
                      rel="noopener noreferrer">
                      <Trans i18nKey="imprint">Impressum</Trans>
                    </a>
                  </span>
                  <CaretIcon />
                </div>
              </li>
              <li
                className="bottomsheet__list__item"
                onClick={() => {
                  trackEvent({ category: 'Account', action: 'logout' })
                  logout()
                }}>
                <div>
                  <span>
                    <Trans i18nKey="signout">Ausloggen</Trans>
                  </span>
                  <CaretIcon />
                </div>
              </li>
            </ul>
          </div>
          <div style={{ flex: 1 }}></div>
          <span style={{ textAlign: 'center', opacity: 0.4 }}>
            Version {window.VERSION || ''}
          </span>
        </BottomSheet>
      </div>
      <Prompt
        shadow
        icon={
          messageType === 'warning' ? (
            <WarningIcon />
          ) : messageType === 'success' ? (
            <SuccessIcon />
          ) : null
        }
        direction={showMessage ? 'center' : 'right'}
        title={
          messageType === 'warning'
            ? t('account__reset_auth__warning__title')
            : messageType === 'success'
            ? t('account__reset_auth__success__title')
            : messageType === 'cwa'
            ? t('account__reset_cwa__success__title')
            : t('account__reset_cwa__error__title')
        }
        text={
          messageType === 'warning'
            ? t('account__reset_auth__warning__text')
            : messageType === 'success'
            ? t('account__reset_auth__success__text')
            : messageType === 'cwa'
            ? t('account__reset_cwa__success__text')
            : t('account__reset_cwa__error__text')
        }
        button={
          messageType === 'warning' ? (
            <Button onClick={resetAuth}>
              {t('account__reset_auth__warning__btn')}
            </Button>
          ) : (
            <Button onClick={() => setShowMessage(false)}>
              {t('btn__close')}
            </Button>
          )
        }
        buttonSecondary={
          messageType === 'warning' ? (
            <Button className="ghost" onClick={() => setShowMessage(false)}>
              {t('btn__cancel')}
            </Button>
          ) : null
        }
      />
    </>
  )
}
