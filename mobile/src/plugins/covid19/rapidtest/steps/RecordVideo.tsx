import React, { useCallback, useContext, useRef, useState } from 'react'
import { Box, Button, Heading, Modal, Text, VStack, View } from 'native-base'
import { Camera, VideoFile } from 'react-native-vision-camera'
import CameraView from '../../../../widgets/CameraView'
import Video from 'react-native-video'
import useHomedx from '../../../../hooks/useHomedx'
import { RapidTestContext } from '../RapidTest'
import { TestSlideProps } from '../../../../models/TestProps'
import CameraOverlay from '../../../../widgets/CameraOverlay'
import ListView from '../../../../widgets/ListView'
import { useTranslation } from 'react-i18next'

export default function RecordVideo({ onNext }: TestSlideProps) {
  const { t } = useTranslation()

  const { setTestData } = useContext(RapidTestContext)
  const cameraRef = useRef<Camera>(null)
  const [showCamera, setShowCamera] = useState<boolean>(false)
  const [isRecording, setIsRecording] = useState<boolean>(false)
  const [isUploading, setIsUploading] = useState<boolean>(false)
  const [isShowSuccess, setIsShowSuccess] = useState<boolean>(false)
  const [isShowError, setIsShowError] = useState<boolean>(false)

  const [video, setVideo] = useState<string>('')

  const { uploadVideo } = useHomedx()

  const onRecordingFinished = useCallback((_video: VideoFile) => {
    if (!_video) return
    setShowCamera(false)
    setVideo(_video.path)
  }, [])
  const onRecordingError = useCallback(error => {
    console.log(error)
  }, [])

  const startRecording = useCallback(async () => {
    await cameraRef.current?.startRecording({
      onRecordingFinished,
      onRecordingError
    })
    setIsRecording(true)
  }, [])

  const endRecording = useCallback(async () => {
    const error = await cameraRef.current?.stopRecording()
    if (error) console.log(error)
    setIsRecording(false)
  }, [])

  const upload = useCallback(async () => {
    setIsUploading(true)
    const res = await uploadVideo(video)
    setIsUploading(false)
    if (res?.success && res?.objectName) {
      setTestData({ videoUrl: res.objectName })
      setIsShowSuccess(true)
    } else {
      setIsShowError(true)
    }
  }, [video])

  return (
    <>
      <Box style={{ flex: 1 }}>
        <Heading>Video</Heading>
        <ListView
          data={[
            t(
              'Für die korrekte Bewertung des Tests mussder gesamte Vorgang vom Abstrich bis zum Ende der Entwicklungszeit von 15 Minuten im Sichtfeld der Kameraausgeführt werden. Bitte achten Sie daher auf eine geeignete Positionierung ihrer Kamera.'
            ),
            t(
              'Nutzen Sie eine sehr gute und stabile Internetverbindung (z.B. WLAN)'
            ),
            t(
              'Ihr Raum ist gut ausgeleuchtet, schalten Sie (falls nötig) Ihr Licht an'
            ),
            t(
              'Ihr Smartphone muss zur Aufnahme aufrecht stehen oder hängen, damit Sie sich freihändig während des gesamten Selbstabtrichs filmen können.'
            )
          ]}
        />

        <View flex="1"></View>
        <Button onPress={() => setShowCamera(true)}>Weiter</Button>
      </Box>
      <CameraView
        video={true}
        ref={cameraRef}
        show={showCamera}
        overlay={
          <CameraOverlay
            isVideo
            isRecording={isRecording}
            onPress={!isRecording ? startRecording : endRecording}
          />
        }
      />
      {!!video && (
        <Box
          bg="white"
          position="absolute"
          top={0}
          left={0}
          w="100%"
          h="100%"
          mx="4"
          justifyContent={'flex-end'}>
          <Heading mb="3">
            Überprüfen Sie ihr Video und laden Sie es anschließend hoch
          </Heading>
          <Video source={{ uri: video }} style={{ flex: 1 }} controls />

          <Button onPress={() => setVideo('')} isDisabled={isUploading}>
            Löschen
          </Button>
          <Button onPress={upload} isDisabled={isUploading}>
            Hochladen
          </Button>
        </Box>
      )}
      <Modal isOpen={isShowSuccess}>
        <Modal.Content>
          <Modal.Header>Erfolg!</Modal.Header>
          <Modal.Body>Ihr Video wurde erfolgreich hochgeladen!</Modal.Body>
          <Modal.Footer>
            <Button onPress={onNext}>Weiter</Button>
          </Modal.Footer>
        </Modal.Content>
      </Modal>
      <Modal isOpen={isShowError}>
        <Modal.Content>
          <Modal.Header>Fehlgeschlagen!</Modal.Header>
          <Modal.Body>Ihr Foto konnte nicht hochgeladen werden</Modal.Body>
          <Modal.Footer>
            <Button onPress={() => setIsShowError(false)}>Weiter</Button>
          </Modal.Footer>
        </Modal.Content>
      </Modal>
    </>
  )
}
