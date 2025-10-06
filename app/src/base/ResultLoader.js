import React from 'react'

import LoadingView from 'components/LoadingView'
import { useTranslation } from 'react-i18next'

export default function ResultLoader({ title }) {
  const { t } = useTranslation()
  return (
    <div className={`loader__wrapper`}>
      <div className="loader__wrapper--inner">
        <div className="loader__content">
          <LoadingView />
          <h3>{title || t('loading__base')}</h3>
        </div>
      </div>
    </div>
  )
}
