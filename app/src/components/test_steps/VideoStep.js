import React, { useState, useCallback, useEffect, useRef } from 'react'
import { useMatomo } from '@datapunt/matomo-tracker-react'
import { Trans, useTranslation } from 'react-i18next'
import * as Sentry from '@sentry/react'

import Step from 'components/Step'
import Button from 'components/Button'
import Camera from 'components/Camera'
import Prompt from 'components/Prompt'
import useInterval from 'useInterval'

import WarningIcon from 'assets/icons/ic_warning.svg'

import { uploadTestVideo } from 'services/upload.service'

export default function VideoStep({
  onLoad,
  onSuccess,
  onError,
  allowShortVideo
}) {
  const { t } = useTranslation()
  const callbackRef = useRef(null)
  const [isShowCamera, setIsShowCamera] = useState(false)
  const [recordedChunks, setRecordedChunks] = useState([])
  const [mimeType, setMimeType] = useState('webm')
  const [isCaptured, setIsCaptured] = useState(false)
  const [duration, setDuration] = useState(null)
  const [promptText, setPromptText] = useState(null)
  const [promptType, setPromptType] = useState('warning')
  const [showPrompt, setShowPrompt] = useState(false)
  const [isLoading, setIsLoading] = useState(false)
  const [videoStartInfo, setVideoStartInfo] = useState(null)
  const [hasSentVideoError, setHasSentVideoError] = useState(false)
  const [retries, setRetries] = useState(0)
  const { trackPageView, trackEvent } = useMatomo()

  useEffect(() => {
    trackPageView({
      documentTitle: 'RecordVideo'
    })
    return () => {}
  }, [trackPageView])

  useInterval(
    () => {
      if (
        duration !== videoStartInfo?.duration ||
        recordedChunks.size / 1000000 !== videoStartInfo.size
      ) {
        if (!hasSentVideoError) {
          process.env.DEBUG === 'true' && console.log(videoStartInfo)
          setHasSentVideoError(true)
          Sentry.captureException('Upload video: Error - Video data changed!')
        }
      }
    },
    isLoading && !!videoStartInfo?.duration && !!videoStartInfo?.size
      ? 150
      : null
  )

  const uploadVideo = useCallback(async () => {
    process.env.DEBUG === 'true' && console.log(videoStartInfo)
    setIsLoading(true)
    onLoad &&
      onLoad(
        true,
        t('test__video__loading__title'),
        t('test__video__loading__text')
      )

    let data
    let headpre
    const isMp4 = mimeType === 'mp4'
    const fileExtension = isMp4 ? 'mp4' : 'webm'
    if (retries === 0) {
      try {
        headpre = await getBase64String(new Blob(recordedChunks).slice(0, 100))
        const blob = new Blob(recordedChunks, {
          type: isMp4 ? 'video/mp4' : 'video/webm; codecs=vp8'
        })
        data = new File(
          [blob],
          'test-video.' + fileExtension,
          { type: isMp4 ? 'video/mp4' : 'video/webm' }
        )
        setRecordedChunks(blob)
      } catch (e) {
        data = []
        console.error('SBLOB', e)
      }
    } else {
      data = recordedChunks
    }
    if (data && data.size === 0) {
      reset()
      closeCamera()
      Sentry.captureException('Upload video: Error - Video is 0 bytes!')
      setIsLoading(false)
      onError && onError('bytes')
      return
    }

    setVideoStartInfo({
      duration: duration,
      size: data.size / 1000000
    })

    trackEvent({
      category: 'NewTest',
      action: 'attempt test video upload',
      value: data.size / 1000000 + 'mb'
    })

    const head = await getBase64String(data.slice(0, 100))
    const ok = await checkVideoCorruption(head || '')

    if (!ok) {
      const str = head
        .replace('data:application/octet-stream;base64,', '')
        .substring(0, 4)
      Sentry.captureException('Upload video: Video head invalid ' + str)

      trackEvent({
        category: 'NewTest',
        action: 'Video head invalid ' + str
      })
      onError && onError('corrupt')
      setIsLoading(false)
      closeCamera()
      reset()
      return
    }

    try {
      const result = await uploadTestVideo(
        data, 
        mimeType || 'mp4', 
        head ? head.substring(0, 100) : '', 
        headpre ? headpre.substring(0, 100) : ''
      )
      
      if (!result.success) {
        if (result.validation && result.validation.length === 1 && result.validation[0] === 'headComparisonFailed') {
          Sentry.captureException('Upload video: error - md5')
          showMD5Error()
        } else {
          Sentry.captureException('Upload video: error')
          onError && onError()
        }
        return
      }

      trackEvent({ category: 'NewTest', action: 'successful test video upload' })
      setIsShowCamera(false)
      onSuccess && onSuccess(result.objectName)
      setIsLoading(false)
    } catch (error) {
      console.error('Upload video error:', error)
      Sentry.captureException('Upload video: error')
      onError && onError()
      setIsLoading(false)
    }
    
    setRetries(prev => prev + 1)
  }, [
    videoStartInfo,
    onLoad,
    t,
    duration,
    mimeType,
    onSuccess,
    recordedChunks,
    reset,
    closeCamera,
    onError,
    showMD5Error,
    retries,
    trackEvent
  ])

  const checkVideoCorruption = str =>
    new Promise((resolve, reject) => {
      if (str && str.length > 4) {
        const sub = str
          .replace('data:application/octet-stream;base64,', '')
          .substring(0, 4)
        resolve(sub === 'GkXf' || sub === 'AAAA' || sub === 'Gg==')
      } else {
        trackEvent()
        resolve(false)
      }
    })

  const getBase64String = data =>
    new Promise((resolve, reject) => {
      try {
        const reader = new FileReader()

        reader.onload = ev => {
          const str = ev.target.result
          if (str.length !== null) {
            resolve(str)
          }
        }

        reader.readAsDataURL(data)
      } catch (e) {
        console.error(e)
        resolve('')
      }
    })

  const showCamera = useCallback(() => {
    setShowPrompt(false)
    setIsShowCamera(true)
  }, [])

  const closeCamera = useCallback(() => {
    setIsShowCamera(false)
  }, [])

  const reset = useCallback(() => {
    console.log('reset data')
    setIsCaptured(false)
    setRecordedChunks([])
  }, [])

  const showMD5Error = () => {
    onLoad && onLoad(false)

    setPromptType('md5')
    setPromptText(
      <Trans i18nKey="test__video__prompt__md5__text">
        Ihr Video wurde konnte nicht hochgeladen werden. Bitte überprüfen Sie
        Ihre Internetverbindung.
      </Trans>
    )
    setShowPrompt(true)
  }

  const showWarning = () => {
    setPromptType('warning')
    setPromptText(
      <Trans i18nKey="test__video__prompt__warning__text">
        Bitte achten Sie beim Filmen auf 3 wichtige Punkte:
        <ul className="list primary">
          <li className="list__item">
            Abstrichentnahme, Lösen und Auftropfen müssen im Bild sein!
          </li>
          <li className="list__item">
            Für die Inkubationszeit muss nur die Kassette im Bild sein!
          </li>
          <li className="list__item">
            Halten Sie final das Testergebnis mit Sicherheits-PIN in die Kamera!
          </li>
        </ul>
      </Trans>
    )
    setShowPrompt(true)
  }

  const showWarning2 = () => {
    setShowPrompt(false)
    setTimeout(() => {
      setPromptType('warning2')
      setPromptText(
        <Trans i18nKey="test__video__prompt__warning2__text">
          Bitte verwenden Sie während der Aufnahme Ihr Gerät nicht anderweitig
        </Trans>
      )
      setShowPrompt(true)
    }, 500)
  }

  const showDurationWarning = () => {
    setPromptType('duration')
    setShowPrompt(true)
    setPromptText(
      <Trans i18nKey="test__video__prompt__duration__text">
        Ihr Video entspricht nicht den von uns vorgegebenen Richtlinien für
        einen Schnelltest. Bitte filmen Sie die
        <strong>15 Minuten Entwicklungszeit</strong> bis zum Ergebnis des Tests
        mit. Sollten Sie jetzt abbrechen, wird Ihr Test ungültig.
      </Trans>
    )
  }

  return (
    <>
      <Step
        className="new-test__video"
        title={t('test__video__title')}
        onNext={showWarning}
        nextText={t('test__video__btn')}>
        <img
          className="video__example"
          alt="example"
          src={`${process.env.ASSETS_PATH}/assets/Muster_Smartphone_Stand.png`}
        />

        <ul className="list">
          <li className="list__item">
            <Trans i18nKey="test__video__tip1">
              Für die korrekte Bewertung des Tests muss
              <strong>
                der gesamte Vorgang vom Abstrich bis zum Ende der
                Entwicklungszeit von 15 Minuten im Sichtfeld der Kamera
              </strong>
              ausgeführt werden. Bitte achten Sie daher auf eine geeignete
              Positionierung ihrer Kamera.
            </Trans>
          </li>
          <li className="list__item">{t('test__video__tip2')}</li>
          <li className="list__item">{t('test__video__tip3')}</li>
          <li className="list__item">{t('test__video__tip4')}</li>
        </ul>
        {isShowCamera && (
          <div className="camera__wrapper">
            <Camera
              type="video"
              onShowWarning={callback => {
                callbackRef.current = callback
                showDurationWarning()
              }}
              onVideoRecordStart={() => setIsCaptured(false)}
              onVideoRecordEnd={dur => {
                setIsCaptured(true)
                setDuration(dur)
              }}
              onCaptureVideo={data =>
                setRecordedChunks(prev => prev.concat(data))
              }
              onMimeTypeChanged={type => setMimeType(type)}
              onClose={closeCamera}
              onReset={reset}
              allowShortVideo={allowShortVideo}
            />
            <div className="camera__wrapper__footer__wrapper">
              {isCaptured && (
                <Button
                  className="btn--next"
                  disabled={isLoading}
                  onClick={uploadVideo}>
                  {t('test__upload_video')}
                </Button>
              )}
            </div>
          </div>
        )}
      </Step>
      <Prompt
        icon={<WarningIcon />}
        direction={showPrompt ? 'center' : 'right'}
        title={
          promptType === 'md5' ? 'Fehler!' : t('test__video__prompt__title')
        }
        content={promptText}
        subtitle={
          promptType === 'duration' &&
          t('test__video__prompt__duration__subtitle')
        }
        button={
          promptType === 'warning' ? (
            <Button onClick={showWarning2}>
              {t('test__video__prompt__btn_warning')}
            </Button>
          ) : promptType === 'warning2' ? (
            <Button onClick={showCamera}>
              <Trans i18nKey="test__video__prompt__btn_warning">
                Verstanden, weiter!
              </Trans>
            </Button>
          ) : promptType === 'md5' ? (
            <Button onClick={showCamera}>Erneut versuchen</Button>
          ) : (
            <Button onClick={() => setShowPrompt(false)}>
              {t('test__video__prompt__btn')}
            </Button>
          )
        }
        buttonSecondary={
          promptType === 'duration' && (
            <Button
              className="ghost"
              onClick={() => {
                setShowPrompt(false)
                callbackRef.current && callbackRef.current()
              }}>
              {t('test__video__prompt__btn2_duration')}
            </Button>
          )
        }
      />
    </>
  )
}
