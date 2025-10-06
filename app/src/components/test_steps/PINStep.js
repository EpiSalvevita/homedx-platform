import React, { useEffect, useRef, useState } from 'react'
import { useQuery } from '@apollo/client'
import { useMatomo } from '@datapunt/matomo-tracker-react'
import { useTranslation } from 'react-i18next'
import * as Sentry from '@sentry/react'

import Step from 'components/Step'

import { GET_LIVE_TOKEN } from 'services/graphql'

export default function PINStep({ onNext, onLoad }) {
  const { t } = useTranslation()
  const pinRef = useRef(null)
  const [pin, setPin] = useState('')
  const { trackPageView } = useMatomo()

  const { loading } = useQuery(GET_LIVE_TOKEN, {
    onCompleted: (data) => {
      if (data.liveToken) {
        pinRef.current.innerText = `${t('test__pin__pin')} ${data.liveToken}`
        setPin(data.liveToken)
      } else {
        Sentry.captureException('PIN: error')
      }
      onLoad && onLoad(false)
    },
    onError: () => {
      Sentry.captureException('PIN: error')
      onLoad && onLoad(false)
    }
  })

  useEffect(() => {
    if (loading) {
      onLoad &&
        onLoad(
          true,
          t('test__pin__loading__title'),
          t('test__pin__loading__text')
        )
    }
  }, [loading, onLoad, t])

  useEffect(() => {
    trackPageView({
      documentTitle: 'PIN'
    })
    return () => {}
  }, [trackPageView])

  return (
    <Step
      className="new-test__pin__wrapper"
      title={t('test__pin__title')}
      onNext={() => onNext(pin)}
      nextText={t('test__pin__btn')}>
      <div>
        <img
          className="pin__example"
          alt="example"
          src={`${process.env.ASSETS_PATH}/assets/Muster_Kassette_PIN.png`}
        />
        <div>
          <h2 ref={pinRef}> </h2>
        </div>

        <ul className="list">
          <li className="list__item">{t('test__pin__li1')}</li>
          <li className="list__item">{t('test__pin__li2')}</li>
          <li className="list__item">{t('test__pin__li3')}</li>
        </ul>
      </div>
    </Step>
  )
}
