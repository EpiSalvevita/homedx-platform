import { Pressable, useWindowDimensions } from 'react-native'
import React, { useCallback, useContext, useRef, useState } from 'react'
import {
  Box,
  Button,
  Heading,
  VStack,
  Image,
  Modal,
  View,
  Text,
  Circle
} from 'native-base'
import CameraView from '../../../../widgets/CameraView'
import { Camera, PhotoFile } from 'react-native-vision-camera'

import useHomedx from '../../../../hooks/useHomedx'
import { HdxFile } from '../../../../models/HdxTypes'
import { RapidTestContext } from '../RapidTest'
import ListView from '../../../../widgets/ListView'
import { useTranslation } from 'react-i18next'
import { TestSlideProps } from '../../../../models/TestProps'
import CameraOverlay from '../../../../widgets/CameraOverlay'

export default function TestkitPhoto({ onNext }: TestSlideProps) {
  const { t } = useTranslation('covid19')
  const { width } = useWindowDimensions()
  const { uploadPhoto } = useHomedx()
  const cameraRef = useRef<Camera>(null)
  const [showCamera, setShowCamera] = useState<boolean>(false)
  const [isUploading, setIsUploading] = useState<boolean>(false)
  const [isShowSuccess, setIsShowSuccess] = useState<boolean>(false)
  const [isShowError, setIsShowError] = useState<boolean>(false)
  const { setTestData } = useContext(RapidTestContext)
  const [snapshot, setSnapshot] = useState<HdxFile | null>()

  const takePhoto = async () => {
    const photo: PhotoFile | undefined = await cameraRef.current?.takePhoto({
      flash: 'off',
      enableAutoRedEyeReduction: false,
      enableAutoStabilization: true
    })

    if (!photo) return

    try {
      setShowCamera(false)
      const s: HdxFile = {
        uri: photo.path,
        name: 'photo.jpg',
        type: 'image/jpg'
      }
      setSnapshot(s)
    } catch (e) {
      console.log(e)
    }
  }

  const upload = useCallback(async () => {
    if (!snapshot) return
    setIsUploading(true)
    const res = await uploadPhoto(snapshot)

    setIsUploading(false)
    if (res && res.success && res.objectName) {
      setTestData({ testDeviceUrl: res.objectName })
      setIsShowSuccess(true)
    } else {
      setIsShowError(true)
    }
  }, [snapshot])

  return (
    <>
      <VStack flex="1" justifyContent={'flex-end'}>
        <Heading mb="2">
          Bitte fotografieren Sie nun Ihr ungeöffnetes Corona-Testkit.
        </Heading>
        <Text>
          Ein relativ genaues Ergebnis kann nur mit einem hochwertigen
          Corona-Testkit ermittelt werden. Diese sind
          Paul-Ehrlich-Institut-gelistet und hier aufgeführt.
        </Text>
        <View my="4">
          <ListView
            data={[
              t('', {
                defaultValue:
                  'Bitte beachten Sie, dass wir nur Abstrichtests im Nasen- und/oder Rachenraum zulassen (keine Speicheltests).'
              }),
              t('', {
                defaultValue:
                  'Wir müssen den Hersteller Ihres Corona-Testkits und den ungenutzten Zustand erkennen können.'
              }),
              t('', {
                defaultValue:
                  'Bitte holen Sie das Testkit daher noch nicht aus der Verpackung.'
              }),
              t('', {
                defaultValue:
                  'Bitte achten Sie auf eine schnelle Internetverbindung.'
              })
            ]}
          />
        </View>
        <Button onPress={() => setShowCamera(true)}>
          Testkit fotografieren
        </Button>
      </VStack>
      <CameraView
        ref={cameraRef}
        show={showCamera}
        photo={true}
        overlay={<CameraOverlay onPress={takePhoto} />}
      />

      {!!snapshot && (
        <Box
          position="absolute"
          width={width}
          height={'100%'}
          bg="white"
          justifyContent="flex-end">
          <Image
            position="absolute"
            alt="testkit"
            width={width}
            height={'100%'}
            source={{ uri: snapshot.uri }}
          />
          <Button onPress={upload} isDisabled={isUploading}>
            Hochladen
          </Button>
        </Box>
      )}

      <Modal isOpen={isShowSuccess}>
        <Modal.Content>
          <Modal.Header>Erfolg!</Modal.Header>
          <Modal.Body>Ihr Foto wurde erfolgreich hochgeladen!</Modal.Body>
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
            <Button onPress={() => (setSnapshot(null), setIsShowError(false))}>
              Weiter
            </Button>
          </Modal.Footer>
        </Modal.Content>
      </Modal>
    </>
  )
}
