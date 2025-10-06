import React from 'react'

import WarningIcon from 'assets/icons/ic_warning_alt.svg'
import { useTranslation } from 'react-i18next'
import i18next from 'i18next'
export default function PositiveResultView({ displayLng }) {
  const { t: clientLng } = useTranslation()
  const dynamicLng = i18next.getFixedT(displayLng)
  const t = displayLng !== i18next.language ? dynamicLng : clientLng

  return (
    <>
      <h2 className="result__result">{t('positive')}</h2>

      <div className="result__sticker result__warning">
        <WarningIcon />
      </div>

      <div className="result__check">
        <ul className="result__check--positive">
          <li>
            <div className="result__check__cardinal">
              <span>1</span>
            </div>
            <span>{t('certificate__positive__step1')}</span>
          </li>
          <li>
            <div className="result__check__cardinal">
              <span>2</span>
            </div>
            <span>{t('certificate__positive__step2')}</span>
          </li>
          <li>
            <div className="result__check__cardinal">
              <span>3</span>
            </div>
            <span>
              {t('certificate__positive__step3')}{' '}
              <strong>
                <a href="tel:030-21780220">030-21780220</a>
              </strong>
            </span>
          </li>
        </ul>
      </div>
    </>
  )
}
