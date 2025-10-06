import React from 'react'

import BadgeIcon from 'assets/icons/ic_badge.svg'
import CaretIcon from 'assets/icons/ic_caret.svg'
import { useTranslation } from 'react-i18next'

export default function CertificateDetailMenu({
  lastRapidTest,
  showDetail,
  clickListener
}) {
  const { t } = useTranslation()

  return (
    <div className={`result__detail ${showDetail ? 'show' : ''}`}>
      <ul>
        <li onClick={() => clickListener('personal')}>
          <div>
            <span>{t('personal_data')}</span>
            <CaretIcon className="ic__caret" />
          </div>
        </li>

        <li onClick={() => clickListener('exam')}>
          <div>
            <span>{t('qrcode')}</span>
            <CaretIcon className="ic__caret" />
          </div>
        </li>

        {lastRapidTest?.comment && (
          <li onClick={() => clickListener('comments')}>
            <div>
              <span>{t('comments')}</span>
              <BadgeIcon className="ic__badge" />
              <CaretIcon className="ic__caret" />
            </div>
          </li>
        )}
      </ul>
    </div>
  )
}
