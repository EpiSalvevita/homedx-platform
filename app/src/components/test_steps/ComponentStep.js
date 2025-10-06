import React, { useEffect } from 'react'
import Step from 'components/Step'

import KitIcon from 'assets/icons/ic_kit.svg'
import StickIcon from 'assets/icons/ic_stick.svg'
import SolutionIcon from 'assets/icons/ic_solution.svg'
import CapIcon from 'assets/icons/ic_cap.svg'

import { useMatomo } from '@datapunt/matomo-tracker-react'
import { useTranslation } from 'react-i18next'

export default function ComponentStep({ onNext }) {
  const { t } = useTranslation()
  const { trackPageView } = useMatomo()

  useEffect(() => {
    trackPageView({ documentTitle: 'Components' })
    return () => {}
  }, [])

  return (
    <Step
      className="new-test__components"
      title={t('test__components__title')}
      text={t('test__components__text')}
      onNext={onNext}
      nextText={t('test__components__btn')}>
      <h3>{t('test__components__content__title')}</h3>
      <p>{t('test__components__content__text')}</p>
      <div className="new-test__components__grid__wrapper">
        <div className="new-test__components__grid">
          <div className="new-test__components__grid__cell">
            <div className="new-test__components__grid__cell__icon">
              <KitIcon />
            </div>
            <div className="new-test__components__grid__cell__label">
              {t('testdevice')}
            </div>
          </div>
          <div className="new-test__components__grid__cell">
            <div className="new-test__components__grid__cell__icon">
              <StickIcon />
            </div>
            <div className="new-test__components__grid__cell__label">
              {t('sterileswab')}
            </div>
          </div>
          <div className="new-test__components__grid__cell">
            <div className="new-test__components__grid__cell__icon">
              <SolutionIcon />
            </div>
            <div className="new-test__components__grid__cell__label">
              {t('extractionbuffer')}
            </div>
          </div>
          <div className="new-test__components__grid__cell">
            <div className="new-test__components__grid__cell__icon">
              <CapIcon />
            </div>
            <div className="new-test__components__grid__cell__label">
              {t('nozzlecap')}
            </div>
          </div>
        </div>
      </div>
    </Step>
  )
}
