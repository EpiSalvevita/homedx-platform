import React, { useCallback, useRef, useState } from 'react'
import { Box, Button, Heading, Image, Modal, View } from 'native-base'
import useHomedx from '../../../hooks/useHomedx'
import { Camera, PhotoFile } from 'react-native-vision-camera'
import { HdxFile } from '../../../models/HdxTypes'
import CameraView from '../../../widgets/CameraView'
import { launchImageLibrary } from 'react-native-image-picker'
import ListView from '../../../widgets/ListView'
import { TestSlideProps } from '../../../models/TestProps'
const img = require('../assets/images/Muster_Perso_Hinten.png')

export default function IDBack({ onNext }: TestSlideProps) {
  const { uploadAuthPhoto } = useHomedx()
  const cameraRef = useRef<Camera>(null)
  const [isShowCamera, setIsShowCamera] = useState<boolean>(false)

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

    setIsShowCamera(false)
    setSnapshot(s)
  }

  const upload = useCallback(async () => {
    if (!snapshot) return
    setIsUploading(true)
    const res = await uploadAuthPhoto(snapshot, 'identityCard2')
    setIsUploading(false)
    if (res?.success) {
      setIsShowSuccess(true)
    } else {
      setIsShowError(true)
    }
  }, [snapshot])

  return (
    <View flex="1">
      <Heading my="2">
        Bitte fotografieren Sie die Rückseite Ihres Personalausweises.
      </Heading>
      <ListView
        data={[
          'Achten Sie auf eine gute Internetverbindung',
          'Der Raum sollte hell genug sein',
          'Ihre Angaben müssen eindeutig zu erlennen sein'
        ]}
      />
      <Box flex="1" justifyContent={'flex-start'}>
        <Image
          style={{ aspectRatio: 1 }}
          width="100%"
          resizeMode="contain"
          source={img}
        />
      </Box>

      <>
        {!snapshot && (
          <Button
            onPress={async () => {
              if (__DEV__) {
                const res = await launchImageLibrary({
                  mediaType: 'photo',
                  maxWidth: 500,
                  maxHeight: 500
                })
                if (!res.didCancel && res.assets) {
                  setSnapshot({
                    uri: res.assets[0].uri || '',
                    name: 'photo.jpg',
                    type: 'image/jpg'
                  })
                }
              } else {
                setIsShowCamera(true)
              }
            }}>
            Rückseite fotografieren
          </Button>
        )}
        {snapshot && (
          <Box
            bg="white"
            flex="1"
            position={'absolute'}
            top="0"
            left="0"
            right="0"
            bottom="0">
            <Image
              source={{ uri: snapshot.uri }}
              flex="1"
              resizeMode="contain"
            />
            <Button onPress={upload} isDisabled={isUploading}>
              Hochladen
            </Button>
          </Box>
        )}
      </>
      <CameraView
        ref={cameraRef}
        show={isShowCamera}
        photo={true}
        overlay={
          <Box
            justifyContent={'flex-end'}
            // bg="white"
            flex="1"
            position={'absolute'}
            top="0"
            left="0"
            right="0"
            bottom="0">
            <Button onPress={takePhoto}>Foto machen</Button>
          </Box>
        }
      />

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
    </View>
  )
}
