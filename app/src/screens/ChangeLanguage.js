import React, { useEffect, useState } from 'react'
import { useMutation } from '@apollo/client'
import { useHistory } from 'react-router-dom'
import i18n from 'i18next'
import { Trans, useTranslation } from 'react-i18next'
import { useMatomo } from '@datapunt/matomo-tracker-react'

import BottomSheet from 'components/BottomSheet'
import { SET_LANGUAGE } from 'services/graphql'
import { AVAILABLE_LANGUAGES } from 'hdx-config'

export default function ChangeLanguage() {
  const { t } = useTranslation()
  const history = useHistory()
  const { trackPageView } = useMatomo()
  const [showLanguages, setShowLanguages] = useState(false)

  const [setUserLanguage] = useMutation(SET_LANGUAGE)

  useEffect(() => {
    trackPageView({
      documentTitle: 'ChangeLanguage'
    })
    setShowLanguages(true)
    return () => {
      setShowLanguages(false)
    }
  }, [])

  const setLanguage = async (lng) => {
    try {
      await setUserLanguage({
        variables: { language: lng }
      })
      i18n.changeLanguage(lng, history.goBack)
    } catch (error) {
      console.error('Error setting language:', error)
    }
  }

  return (
    <div className="screen-language">
      <BottomSheet
        canGoBack
        hideSpacer
        className={`no-bottombar ${showLanguages ? 'open' : ''}`}
        title={t('change_language__title')}>
        <h4>
          <Trans i18nKey="change_language__subtitle">
            Wählen Sie eine Sprache
          </Trans>
        </h4>
        <ul className="list">
          {AVAILABLE_LANGUAGES.map(([id, name]) => (
            <li className="list__item" key={id} onClick={() => setLanguage(id)}>
              {name}
            </li>
          ))}
        </ul>
      </BottomSheet>
    </div>
  )
}
