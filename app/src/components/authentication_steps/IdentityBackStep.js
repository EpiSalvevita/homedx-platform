import React, { useEffect, useState, useCallback } from 'react'
import { useSelector, useDispatch } from 'react-redux'
import { useMutation } from '@apollo/client'
import * as Sentry from '@sentry/react'
import { useMatomo } from '@datapunt/matomo-tracker-react'
import { useTranslation } from 'react-i18next'

import Button from 'components/Button'
import Step from 'components/Step'
import Camera from 'components/Camera'

import { UPLOAD_ID_BACK_PHOTO } from 'services/graphql'

export default function IdentityBackStep({ onLoad, onError, onSuccess }) {
  const dispatch = useDispatch()
  const { t } = useTranslation()
  const [capturedImg, setCapturedImg] = useState(null)
  const [isShowCamera, setIsShowCamera] = useState(false)

  const { trackPageView, trackEvent } = useMatomo()

  const [uploadIdBackPhoto] = useMutation(UPLOAD_ID_BACK_PHOTO)

  useEffect(() => {
    trackPageView({
      documentTitle: 'IdentityBack'
    })
    return () => {}
  }, [])

  const uploadPhoto = useCallback(async () => {
    try {
      trackEvent({ category: 'NewTest', action: 'attempt id back photo upload' })

      onLoad && onLoad(true, t('auth__loading__title'), t('auth__loading__text'))

      const base64 = await fetch(capturedImg)
      const blob = await base64.blob()
      const file = new File([blob], 'id_back.jpg', { type: 'image/jpeg' })

      const { data } = await uploadIdBackPhoto({
        variables: { file }
      })

      if (!data.uploadIdBackPhoto.success) {
        Sentry.captureException('IdentityBack: error')
        onError && onError()
        return
      }

      trackEvent({
        category: 'NewTest',
        action: 'successful id back photo upload'
      })
      setCapturedImg(null)
      dispatch({ type: 'setIdCardBackUrl', url: data.uploadIdBackPhoto.url })
      onSuccess && onSuccess()
    } catch (error) {
      console.error('Upload ID back photo error:', error)
      Sentry.captureException('IdentityBack: error', error)
      onError && onError()
    }
  }, [trackEvent, onLoad, t, capturedImg, dispatch, onSuccess, onError, uploadIdBackPhoto])

  const onCaptureImg = img => {
    setCapturedImg(img)
  }

  const reset = () => {
    setCapturedImg(null)
  }

  const showCamera = () => {
    setIsShowCamera(true)
  }

  const closeCamera = () => {
    setIsShowCamera(false)
    reset()
  }

  return (
    <Step
      className="authentication__identity"
      title={t('auth__step__id_back__title')}
      nextText={t('auth__step__id_back__btn')}
      onNext={showCamera}
      step={3}
      stepMax={4}>
      <img
        className="identity__example"
        alt="example"
        src={`${process.env.ASSETS_PATH}/assets/Muster_Perso_Hinten.png`}
      />
      <ul className="list">
        <li className="list__item">{t('auth__step__tip8')}</li>
        <li className="list__item">{t('auth__step__tip5')}</li>
        <li className="list__item">{t('auth__step__tip6')}</li>
        <li className="list__item">{t('auth__step__tip7')}</li>
      </ul>
      {isShowCamera && (
        <div className="camera__wrapper">
          <Camera
            type="photo"
            onCaptureImg={onCaptureImg}
            onClose={closeCamera}
            onReset={reset}
          />
          <div className="camera__wrapper__footer__wrapper">
            {capturedImg !== null && (
              <Button className="btn--next" onClick={uploadPhoto}>
                {t('camera__btn__upload_photo')}
              </Button>
            )}
          </div>
        </div>
      )}
    </Step>
  )
}
