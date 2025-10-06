import React, { useState, useCallback, useEffect } from 'react'
import { useMatomo } from '@datapunt/matomo-tracker-react'
import { useTranslation } from 'react-i18next'
import * as Sentry from '@sentry/react'

import Step from 'components/Step'
import Button from 'components/Button'
import Camera from 'components/Camera'

import { uploadTestPhoto } from 'services/upload.service'

export default function TestKitStep({ onLoad, onSuccess, onError }) {
  const { t } = useTranslation()
  const [capturedImg, setCapturedImg] = useState(null)
  const [isShowCamera, setIsShowCamera] = useState(false)
  const [isLoading, setIsLoading] = useState(false)
  const { trackPageView, trackEvent } = useMatomo()

  useEffect(() => {
    trackPageView({
      documentTitle: `TestKit`
    })
    return () => {}
  }, [trackPageView])

  const uploadPhoto = useCallback(async () => {
    trackEvent({
      category: 'NewTest',
      action: 'attempt testkit photo upload'
    })
    setIsLoading(true)
    onLoad && onLoad(true, t('test__loading__title'), t('test__loading__text'))

    try {
      const base64 = await fetch(capturedImg)
      const data = await base64.blob()

      const result = await uploadTestPhoto(data, 'jpeg')
      
      if (!result.success) {
        Sentry.captureException('Testkit photo: error')
        onError && onError()
        return
      }
      
      setCapturedImg(null)
      trackEvent({
        category: 'NewTest',
        action: 'successful testkit photo upload'
      })
      onSuccess && onSuccess(result.objectName)
    } catch (error) {
      console.error('Upload error:', error)
      Sentry.captureException('Testkit photo: error')
      onError && onError()
    } finally {
      setIsLoading(false)
    }
  }, [trackEvent, onLoad, t, capturedImg, onSuccess, onError])

  const onCapture = img => {
    setCapturedImg(img)
  }

  const showCamera = () => {
    setIsShowCamera(true)
  }

  const closeCamera = () => {
    setIsShowCamera(false)
  }

  return (
    <Step
      className="new-test__testkit"
      title={t('test__testkit__title')}
      text={t('test__testkit__text')}
      onNext={showCamera}
      nextText={t('test__start_camera')}>
      <img
        className="testkit__example"
        alt="example"
        src={`${process.env.ASSETS_PATH}/assets/Muster_Ungeoeffnetes_Testkit.png`}
      />
      <ul className="list">
        <li className="list__item">{t('test__step__tip1')}</li>
        <li className="list__item">{t('test__step__tip2')}</li>
        <li className="list__item">{t('test__step__tip3')}</li>
      </ul>
      {isShowCamera && (
        <div className="camera__wrapper">
          <Camera
            type="photo"
            onCaptureImg={onCapture}
            onReset={() => setCapturedImg(null)}
            onClose={closeCamera}
          />
          <div className="camera__wrapper__footer__wrapper">
            {capturedImg !== null && (
              <Button
                className="btn--next"
                onClick={uploadPhoto}
                disabled={isLoading}>
                {t('test__upload_photo')}
              </Button>
            )}
          </div>
        </div>
      )}
    </Step>
  )
}
