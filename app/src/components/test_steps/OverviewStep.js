import React, { useEffect } from 'react'

import CheckIcon from 'assets/icons/ic_check_prompt.svg'
import Button from 'components/Button'
import { useMatomo } from '@datapunt/matomo-tracker-react'
import { useTranslation } from 'react-i18next'

export default function OverviewStep({ onNext, isDone }) {
  const { t } = useTranslation()

  const auth = [
    t('test__overview__auth4'),
    t('test__overview__auth1'),
    t('test__overview__auth2'),
    t('test__overview__auth3')
  ]
  const test = [
    t('test__overview__test1'),
    t('test__overview__test2'),
    t('test__overview__test3'),
    t('test__overview__test4')
  ]

  const { trackPageView } = useMatomo()

  useEffect(() => {
    trackPageView({
      documentTitle: `Overview - ${isDone ? 'Auth' : 'Not Auth'}`
    })
    return () => {}
  }, [isDone])

  return (
    <div style={{ flex: 1, overflowY: 'auto' }}>
      <div
        style={{
          flex: 1,

          justifyContent: 'flex-end',
          marginBottom: 15
        }}>
        <h1>{t('test__overview__title')}</h1>
        <p style={{ marginBottom: 10 }}>{t('test__overview__text')}</p>
        <h3>{t('test__overview__subtitle_auth')}</h3>
        {auth.map((title, index) => (
          <div key={`a-${index}`} className={`step ${isDone ? 'done' : ''}`}>
            <span className="step__cardinal">{index + 1}</span>
            <span className="step__title">{title}</span>
            {isDone && (
              <div className="step__check">
                <CheckIcon />
              </div>
            )}
          </div>
        ))}
        <h3>{t('test__overview__subtitle_test')}</h3>
        {test.map((title, index) => (
          <div className="step" key={`s-${index}`}>
            <span className="step__cardinal">{index + 1}</span>
            <span className="step__title">{title}</span>
          </div>
        ))}
      </div>
      <Button onClick={onNext}>{t('test__overview__btn')}</Button>
    </div>
  )
}
