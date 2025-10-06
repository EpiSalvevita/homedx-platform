import React, { useState, useEffect, useRef } from 'react'
import { useMutation } from '@apollo/client'
import { useHistory } from 'react-router-dom'
import { useMatomo } from '@datapunt/matomo-tracker-react'
import { Trans, useTranslation } from 'react-i18next'
import BarcodeScannerComponent from 'react-qr-barcode-scanner'

import Step from 'components/Step'
import Button from 'components/Button'
import LoadingView from 'components/LoadingView'
import Prompt from 'components/Prompt'

import SwapIcon from 'assets/icons/ic_swap-camera.svg'
import QRIcon from 'assets/icons/ic_my-result.svg'

import { ASSIGN_COUPON } from 'services/graphql'

export default function CouponStep({ onNext }) {
  const scannerContainerRef = useRef(null)
  const { t } = useTranslation()
  const history = useHistory()
  const { trackPageView } = useMatomo()
  const [isLoading, setIsLoading] = useState(false)
  const [isShowError, setIsShowError] = useState(false)
  const [errorType, setErrorType] = useState('coupon')
  const [isFacingEnvironment, setIsFacingEnvironment] = useState(true)

  const [assignCoupon] = useMutation(ASSIGN_COUPON, {
    onCompleted: (data) => {
      if (data.assignCoupon.success) {
        onNext && onNext(data.assignCoupon.licenseCode)
      } else {
        setErrorType('coupon')
        setIsShowError(true)
      }
      setIsLoading(false)
    },
    onError: () => {
      setErrorType('coupon')
      setIsShowError(true)
      setIsLoading(false)
    }
  })

  useEffect(() => {
    trackPageView({ documentTitle: 'Coupon' })
    return () => {}
  }, [trackPageView])

  useEffect(() => {
    const listener = () => {
      setIsLoading(true)
      setIsLoading(false)
    }
    window.addEventListener('resize', listener)
    return () => {
      window.removeEventListener('resize', listener)
    }
  }, [scannerContainerRef])

  const validateData = data => {
    return data?.match(/^(.{4}-){5}.{4}$/g).length === 1
  }

  const onScanned = async (err, res) => {
    if (validateData(res?.text)) {
      setIsLoading(true)
      assignCoupon({
        variables: {
          licenseCode: res.text
        }
      })
    }
  }

  const width = Math.min(window.innerWidth, 578)

  return (
    <div className={`payment__coupon`}>
      <Step hideButton title={t('coupon__title')}>
        <div
          style={{ position: 'relative', flex: 1 }}
          ref={scannerContainerRef}>
          {process.env.ENV !== 'prod' && (
            <Button
              className="payment__coupon__btn--skip"
              style={{ position: 'absolute', zIndex: 100 }}
              onClick={() =>
                onScanned(null, { text: '9999-9999-9999-9999-9999-9999' })
              }>
              Skip Scan (DEV)
            </Button>
          )}

          <div className="payment__coupon__scanner__container">
            <div
              style={{
                position: 'absolute',
                top: 15,
                width: 100 + '%',
                zIndex: 100
              }}>
              <small
                style={{
                  textAlign: 'center',
                  minWidth: 180,
                  maxWidth: 56 + '%',
                  margin: '0 auto'
                }}>
                <Trans i18nKey="coupon__qr__hint">
                  QR-Code des Coupons im markierten Bereich einscannen
                </Trans>
              </small>
            </div>
            {!isLoading && (
              <BarcodeScannerComponent
                className="payment__coupon__scanner"
                width={width}
                height={
                  scannerContainerRef?.current?.getBoundingClientRect()?.height
                }
                onUpdate={onScanned}
                delay={500}
                facingMode={isFacingEnvironment ? 'environment' : 'user'}
                onError={() => setIsShowError(true)}
              />
            )}
            <div className="payment__coupon__overlay">
              <QRIcon width={width * 0.35} height={width * 0.35} />
              <div style={{ position: 'absolute', bottom: 15, zIndex: 100 }}>
                <div>
                  {
                    <SwapIcon
                      className="camera__btn camera__btn--swap"
                      onClick={() => setIsFacingEnvironment(prev => !prev)}
                    />
                  }
                </div>
              </div>
            </div>
          </div>
        </div>
        {isLoading && (
          <div
            style={{
              position: 'absolute',
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              justifyContent: 'center',
              alignItems: 'center'
            }}>
            <LoadingView />
          </div>
        )}
      </Step>
      <Prompt
        direction={isShowError ? 'center' : 'right'}
        title={t('coupon__prompt__title_error')}
        text={
          errorType === 'coupon'
            ? t('coupon__prompt__text_error_invalid')
            : t('coupon__prompt__text_error_permissions')
        }
        buttonSecondary={
          <Button
            onClick={
              errorType === 'coupon'
                ? () => {
                    setIsLoading(false)
                    setIsShowError(false)
                  }
                : history.goBack
            }
            className="ghost">
            {errorType === 'coupon' ? t('btn__retry') : t('btn__back')}
          </Button>
        }
      />
    </div>
  )
}
