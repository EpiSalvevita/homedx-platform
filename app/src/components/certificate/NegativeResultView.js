import React, { useEffect, useState, useCallback, useRef } from 'react'
import { useDispatch, useSelector } from 'react-redux'
import { useQuery } from '@apollo/client'
import { toTimerString, EXPIRE_TIME } from 'Utility'
import { isExpired as calcIsExpired } from 'Utility'
import useInterval from 'useInterval'
import LoadingView from 'components/LoadingView'
import { useTranslation } from 'react-i18next'
import i18next from 'i18next'
import Button from 'components/Button'
import { useHistory } from 'react-router-dom'
import { GET_QR_CODE } from 'services/graphql'

export default function NegativeResultView({
  lastRapidTest,
  onQRCodeClicked,
  displayLng
}) {
  const dispatch = useDispatch()
  const history = useHistory()
  const { t: clientLng } = useTranslation()
  const dynamicLng = i18next.getFixedT(displayLng)
  const t = displayLng !== i18next.language ? dynamicLng : clientLng

  const [expireTime, setExpireTime] = useState('--:--')
  const qrcodeRef = useRef(null)
  const [allowClick, setAllowClick] = useState(false)

  const testDate = lastRapidTest?.testDate * 1000 || 0
  const isExpired = calcIsExpired(testDate)

  const { loading: isLoading, data } = useQuery(GET_QR_CODE, {
    skip: isExpired,
    onCompleted: (data) => {
      if (data?.qrCode) {
        dispatch({ type: 'setQRData', qrdata: data.qrCode })
      } else {
        dispatch({ type: 'setQRData', qrdata: '' })
      }
    }
  })

  const qrCode = data?.qrCode ? `data:image/png;format=baercodev1;base64,${data.qrCode}` : false

  useInterval(
    () => {
      const expireTime = toTimerString(Date.now(), testDate + EXPIRE_TIME)
      setExpireTime(expireTime)
    },
    testDate && !isExpired ? 1000 : null
  )

  const showCode = useCallback(() => {
    if (!allowClick) return
    onQRCodeClicked && onQRCodeClicked()
    qrcodeRef.current && qrcodeRef.current.classList.remove('tease')
  }, [allowClick, onQRCodeClicked])

  useEffect(() => {
    setTimeout(() => {
      qrcodeRef.current && qrcodeRef.current.classList.add('tease')
      setAllowClick(true)
    }, 3000)
    return () => {}
  }, [])

  const toCWA = useCallback(() => {
    history.push('/profile')
  }, [history])

  return (
    <>
      <h2 className="result__result">{t('negative')}</h2>

      {!isExpired && (
        <>
          <div className="result__sticker result__qr">
            <>
              {isLoading && <LoadingView />}

              {!isLoading && !!qrCode && (
                <>
                  <h4>BärCODE</h4>
                  <img
                    ref={qrcodeRef}
                    src={qrCode}
                    alt="qrcode"
                    onClick={showCode}
                  />
                </>
              )}
              {!isLoading && !qrCode && <span>{t('no_qrcode')}</span>}
            </>
          </div>
          {lastRapidTest.agreementGiven !== 'none' && (
            <div className="result__sticker result__cwa">
              <Button onClick={toCWA}>
                {t('cwa__transfer_link', {
                  defaultValue: 'In Corona Warn App übertragen'
                })}
              </Button>
            </div>
          )}
        </>
      )}

      <div className="result__validity">
        {!isExpired &&
          lastRapidTest?.result !== 'unevaluated' &&
          lastRapidTest?.result !== 'declined' && (
            <>
              <div className="alt result__validity__title">
                {t('certificate__valid_until')}
              </div>
              <div className="result__validity__time">
                <span>{t('certificate__timer__hours')}</span>
                <h1 className="result__validity__time__timer">{expireTime}</h1>
                <span>{t('certificate__timer__minutes')}</span>
              </div>
            </>
          )}
        {isExpired && (
          <h1 className="result__validity__time__timer">{t('expired')}</h1>
        )}
      </div>
    </>
  )
}
