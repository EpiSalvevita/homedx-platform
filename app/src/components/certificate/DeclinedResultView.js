import React from 'react'
import WarningIcon from 'assets/icons/ic_warning_alt.svg'
import { useTranslation } from 'react-i18next'
import i18next from 'i18next'

export default function DeclinedResultView({ lastRapidTest, displayLng }) {
  const { t: clientLng } = useTranslation()
  const dynamicLng = i18next.getFixedT(displayLng)
  const t = displayLng !== i18next.language ? dynamicLng : clientLng
  const translateValidation = val => {
    if (val !== 'negativeImageMatching')
      return t(`certificate__declined__${val}`)
    else if (!lastRapidTest.validFastCheck)
      return t(`certificate__declined__${val}`)
    else return t(`certificate__declined__${val}_auth`)
  }

  return (
    <>
      <h2 className="result__result">{t('declined')}</h2>

      <div className="result__sticker result__warning">
        <WarningIcon />
      </div>

      <div className={`result__check`}>
        <>
          <h4 className="result__check--declined__title">
            {t('certificate__declined__title')}
          </h4>
          <ul className="result__check--declined">
            {lastRapidTest.validation?.map((val, index) => (
              <li key={`reason-${index}`}>
                <div className="result__check__cardinal">
                  <span>{index + 1}</span>
                </div>
                <span>{translateValidation(val)}</span>
              </li>
            ))}
            {Object.entries(lastRapidTest?.flags).map(
              ([key, flag], index) =>
                key !== 'checkedIdentity' &&
                !flag && (
                  <li key={`reason-${index + 5}`}>
                    <div className="result__check__cardinal">
                      <span>
                        {index +
                          (!lastRapidTest?.flags?.checkedIdentity
                            ? lastRapidTest.validation?.length - 1
                            : 0)}
                      </span>
                    </div>
                    <span>{translateValidation(key)}</span>
                  </li>
                )
            )}
          </ul>
        </>
      </div>
    </>
  )
}
