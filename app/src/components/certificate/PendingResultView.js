import i18next from 'i18next'
import React from 'react'
import { useTranslation } from 'react-i18next'

export default function PendingResultView({ status, displayLng }) {
  const { t: clientLng } = useTranslation()
  const dynamicLng = i18next.getFixedT(displayLng)
  const t = displayLng !== i18next.language ? dynamicLng : clientLng
  return (
    <>
      <h2 className="result__result">
        {status === 'untested' || status === 'video_queued'
          ? t('untested')
          : t('in_progress')}
      </h2>

      <p>{t('certificate__pending__message')}</p>
    </>
  )
}
