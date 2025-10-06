import React, { useState, useEffect, useRef, useCallback } from 'react'
import Webcam from 'react-webcam'

import RecordButton from 'components/RecordButton'

import SwapIcon from 'assets/icons/ic_swap-camera.svg'
import TrashIcon from 'assets/icons/ic_trash.svg'
import CloseIcon from 'assets/icons/ic_close.svg'

import { secondsToTimerString } from 'Utility'
import useInterval from 'useInterval'

import * as Sentry from '@sentry/react'
import { useTranslation } from 'react-i18next'
import { useMatomo } from '@datapunt/matomo-tracker-react'

const RECORD_TIME_WARNING_IN_SEK = 3300 // 55min
const MAX_RECORD_TIME_IN_SEK = 3600 // 60min
const MIN_CAPTURE_TIME = 1 // 1 second for dev
export default function Camera({
  type = 'photo',
  onCaptureImg,
  onVideoRecordStart,
  onCaptureVideo,
  onVideoRecordEnd,
  onMimeTypeChanged,
  onCodecChanged,
  onReset,
  onClose,
  startFace,
  onShowWarning,
  allowShortVideo
}) {
  const { trackEvent } = useMatomo()
  const { t } = useTranslation()
  const webcamRef = useRef(null)
  const mediaRecorderRef = useRef(null)
  const callbackRef = useRef(null)
  // video states
  const [mimeType, setMimeType] = useState('video/mp4')
  const [isInit, setIsInit] = useState(false)
  const [isRecording, setIsRecording] = useState(false)
  const [recordTime, setRecordTime] = useState(0)
  const [recordedChunks, setRecordedChunks] = useState([])
  // photo states
  const [capturedImg, setCapturedImg] = useState(null)
  const [isCaptured, setIsCaptured] = useState(false)
  // general states
  const [cameraFaceFront, setCameraFaceFront] = useState(false)
  const [wrapperConstraints, setWrapperConstraints] = useState({
    width: '720',
    height: '1280'
  })
  const [constraints, setConstraints] = useState({
    facingMode: 'environment',
    frameRate: {
      ideal: 30,
      min: 30,
      max: 30
    }
  })

  useEffect(() => {
    if (startFace) {
      setCameraFaceFront(startFace !== 'environment')
    }
    return () => {}
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  /**
   * Figure out device aspect ratio and try to fit camera
   */
  useEffect(() => {
    const set = () => {
      const w = window.innerWidth
      const h = window.innerHeight
      const largeSide = w < h ? 720 : 1280
      const smallSide = h > w ? 1280 : 720

      setConstraints(prev => ({
        ...prev,
        width: (w > h ? largeSide : smallSide) / 2,
        height: (h > w ? largeSide : smallSide) / 2
      }))
      setWrapperConstraints(prev => ({
        ...prev,
        width: `${w > h ? largeSide : smallSide}`,
        height: `${h > w ? largeSide : smallSide}`
      }))
    }

    let listener
    if (isInit) {
      listener = set
      window.addEventListener('resize', listener)
      set()
    }

    return () => {
      listener && window.removeEventListener('resize', listener)
    }
  }, [type, isInit])

  /**
   * Change camera used
   */
  useEffect(() => {
    setConstraints(prev => ({
      ...prev,
      facingMode: cameraFaceFront ? 'user' : 'environment'
    }))
    return () => {}
  }, [cameraFaceFront])

  /**
   * Shoot a photo
   */
  const shootPhoto = useCallback(async () => {
    if (webcamRef.current) {
      const img = webcamRef.current.getScreenshot()
      ;(onCaptureImg && onCaptureImg(img)) || setCapturedImg(img)

      setIsCaptured(true)
    }
  }, [onCaptureImg])

  /**
   * Close the Camera, if available trigger callback
   */
  const closeCamera = useCallback(() => {
    reset()
    onClose && onClose()
  }, [onClose, reset])

  /**
   * Reset all relevant camera state data
   */
  const reset = useCallback(() => {
    (onCaptureImg && onCaptureImg(null)) || setCapturedImg(null)
    ;(onReset && onReset(null)) || setRecordedChunks([])
    setRecordTime(0)
    setIsCaptured(false)
  }, [onCaptureImg, onReset])

  /**
   * Start video capture.
   * Set mimeType and if available trigger callback
   * This is used specifically if the mime type is important to uploads
   */
  const startVideoCapture = useCallback(() => {
    const options = {
      videoBitsPerSecond: 2500000 / 10
    }

    try {
      options.mimeType = 'video/webm; codecs=vp8'
      // onCodecChanged && onCodecChanged('vp8')
      ;(onMimeTypeChanged && onMimeTypeChanged('webm')) || setMimeType('webm')
      mediaRecorderRef.current = new MediaRecorder(
        webcamRef.current.stream,
        options
      )
    } catch (e) {
      options.mimeType = 'video/mp4'
      // onCodecChanged && onCodecChanged('mp4')
      ;(onMimeTypeChanged && onMimeTypeChanged('mp4')) || setMimeType('mp4')
      try {
        mediaRecorderRef.current = new MediaRecorder(
          webcamRef.current.stream,
          options
        )
      } catch (e) {
        console.error(e.message)
        Sentry.captureException('Camera: could not be started')
        alert(t('camera__exception'))
        return
      }
    }

    trackEvent({
      category: 'NewTest',
      action: `start video recording - ${mediaRecorderRef.current.mimeType}`
    })

    setIsRecording(true)
    onVideoRecordStart && onVideoRecordStart()
    mediaRecorderRef.current.ondataavailable = chunkRecorderData
    mediaRecorderRef.current.start(100)
  }, [onVideoRecordStart, chunkRecorderData, onMimeTypeChanged, t])

  /**
   * Callback used to save recorded video chunks
   */
  const chunkRecorderData = useCallback(
    ({ data }) => {
      if (data.size > 0) {
        try {
          (onCaptureVideo && onCaptureVideo(data)) ||
            setRecordedChunks(prev => prev.concat(data))
        } catch (e) {
          Sentry.captureException(
            'Camera: Cannot concatenate data to recorded chunks'
          )
        }
      }
    },
    [onCaptureVideo]
  )

  /**
   * Stop the video capture
   */
  const stopVideoCapture = useCallback(() => {
    // if record time is less that 15 minutes prompt user
    // to finish testing and give opportunity to leave anyway

    if (!allowShortVideo && recordTime < MIN_CAPTURE_TIME) {
      onShowWarning &&
        onShowWarning(() => {
          mediaRecorderRef.current.stop()
          setIsRecording(false)
          reset()
          // onVideoRecordEnd && onVideoRecordEnd(recordTime)
        })
      return
    }

    mediaRecorderRef.current.stop()
    setIsRecording(false)
    setIsCaptured(true)
    onVideoRecordEnd && onVideoRecordEnd(recordTime)
    // reset()
  }, [allowShortVideo, onShowWarning, onVideoRecordEnd, recordTime, reset])

  /**
   * Tick the inverval for (visual)  video feedback
   */
  useInterval(
    () => {
      setRecordTime(recordTime + 1)
    },
    isRecording ? 1000 : null
  )

  useEffect(() => {
    // 1 = 1 sec => 3600 = 60min
    if (recordTime > MAX_RECORD_TIME_IN_SEK) {
      console.log('too long!')
      stopVideoCapture()
    }
    return () => {}
  }, [recordTime, stopVideoCapture])

  return (
    <div className="camera__wrapper--inner">
      <CloseIcon
        className="camera__btn camera__btn--close"
        onClick={closeCamera}
      />
      {isRecording && (
        <span className="camera__timer">
          {secondsToTimerString(recordTime)}
        </span>
      )}
      {isRecording && recordTime > RECORD_TIME_WARNING_IN_SEK && (
        <span class="camera__timer__warning">max 60:00</span>
      )}
      {!isCaptured && (
        <Webcam
          className="camera"
          audio={false}
          height={wrapperConstraints.height}
          width={wrapperConstraints.width}
          ref={webcamRef}
          screenshotFormat="image/jpeg"
          videoConstraints={constraints}
          onUserMedia={() => setIsInit(true)}
        />
      )}
      {type === 'photo' && isCaptured && capturedImg && (
        <img src={`${capturedImg}`} alt="result" />
      )}
      {type === 'video' && isCaptured && (
        <div
          style={{
            width: 100 + '%',
            height: 100 + '%',
            backgroundColor: 'rgba(0, 0, 0, .4)',
            display: 'flex',
            justifyContent: 'center',
            alignItems: 'center'
          }}>
          <span style={{ color: 'white' }}>{t('camera__upload_ready')}</span>
        </div>
      )}
      {isInit && (
        <div className="camera__footer">
          <div>
            {isCaptured && (
              <TrashIcon
                className="camera__btn camera__btn--trash"
                onClick={reset}
              />
            )}
          </div>
          <div>
            {!isCaptured && (
              <RecordButton
                isRecording={isRecording}
                className="camera__btn camera__btn--record"
                onClick={
                  (type === 'photo' && shootPhoto) ||
                  (!isRecording ? startVideoCapture : stopVideoCapture)
                }
              />
            )}
          </div>
          <div>
            {!isCaptured && !isRecording && (
              <SwapIcon
                className="camera__btn camera__btn--swap"
                onClick={() => setCameraFaceFront(!cameraFaceFront)}
              />
            )}
          </div>
        </div>
      )}
    </div>
  )
}
