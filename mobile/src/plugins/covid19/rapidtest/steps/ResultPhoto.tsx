import { useWindowDimensions } from 'react-native'
import React, { useCallback, useContext, useRef, useState } from 'react'
import {
  View,
  Text,
  Box,
  Button,
  Circle,
  Heading,
  Image,
  Modal,
  Pressable,
  VStack
} from 'native-base'
import { Camera, PhotoFile, useCameraDevices } from 'react-native-vision-camera'
import CameraView from '../../../../widgets/CameraView'
import RNFS from 'react-native-fs'
import useHomedx from '../../../../hooks/useHomedx'
import { HdxFile } from '../../../../models/HdxTypes'
import { RapidTestContext } from '../RapidTest'
import { TestSlideProps } from '../../../../models/TestProps'
import CameraOverlay from '../../../../widgets/CameraOverlay'
import ListView from '../../../../widgets/ListView'
import { useTranslation } from 'react-i18next'

export default function ResultPhoto({ onNext }: TestSlideProps) {
  const { t } = useTranslation('covid19')
  const { setTestData } = useContext(RapidTestContext)
  const { width } = useWindowDimensions()
  const { uploadPhoto } = useHomedx()
  const cameraRef = useRef<Camera>(null)
  const [showCamera, setShowCamera] = useState<boolean>(false)

  const [isUploading, setIsUploading] = useState<boolean>(false)
  const [isShowSuccess, setIsShowSuccess] = useState<boolean>(false)
  const [isShowError, setIsShowError] = useState<boolean>(false)
  const [snapshot, setSnapshot] = useState<HdxFile | null>()

  const takePhoto = async () => {
    const photo: PhotoFile | undefined = await cameraRef.current?.takePhoto({
      flash: 'off',
      enableAutoRedEyeReduction: false,
      enableAutoStabilization: true
    })

    if (!photo) return

    const s: HdxFile = {
      uri: photo.path,
      name: 'photo.jpg',
      type: 'image/jpg'
    }

    setShowCamera(false)
    setSnapshot(s)
  }

  const upload = useCallback(async () => {
    if (!snapshot) return
    setIsUploading(true)
    const res = await uploadPhoto(snapshot)

    setIsUploading(false)
    if (res?.success) {
      setTestData({ photoUrl: res.objectName, testDate: Date.now() / 1000 })
      setIsShowSuccess(true)
    } else {
      setIsShowError(true)
    }
  }, [snapshot])

  return (
    <>
      <Box style={{ flex: 1 }}>
        <Heading mt="2">Bitte fotografieren Sie nun Ihr Testergebnis.</Heading>
        <View flex="1" mt="4">
          <ListView
            data={[
              t(
                'Nutzen Sie eine sehr gute und stabile Internetverbindung (z.B.WLAN).'
              ),
              t(
                'Ihr Raum ist gut ausgeleuchtet, schalten Sie (falls nötig) Licht an.'
              ),
              t(
                'Die Testkassette sollten auf einem einfarbigen Untergrund liegen und so fotografiert werden, dass die Striche auf den Feldern eindeutig zu erkennen ist.'
              )
            ]}
          />
        </View>
        <Button onPress={() => setShowCamera(true)}>Weiter</Button>
      </Box>
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
          justifyContent="flex-end">
          <Image
            position="absolute"
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
          <Modal.Body>Das Foto wurde erfolgreich hochgeladen</Modal.Body>
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
