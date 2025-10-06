import React from 'react'
import BottomSheet from 'components/BottomSheet'
import { Trans, useTranslation } from 'react-i18next'
import { AVAILABLE_LANGUAGES } from 'hdx-config'

export default function ChangeCertificateLanguageBottomSheet({
  setCertificateLng,
  openSheet,
  onClose
}) {
  const { t } = useTranslation()

  const setLanguage = lng => {
    setCertificateLng(lng)
    onClose && onClose()
  }

  return (
    <BottomSheet
      title={t('change_language__title')}
      className={`bottomsheet__language ${openSheet === 'i18n' ? 'open' : ''}`}
      onClose={onClose}>
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
  )
}
