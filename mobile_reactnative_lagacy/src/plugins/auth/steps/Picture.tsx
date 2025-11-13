import React, { useCallback, useState } from 'react'
import { Button, Heading, VStack, View, Text, Modal, Image } from 'native-base'
import { launchCamera, launchImageLibrary } from 'react-native-image-picker'
import useHomedx from '../../../hooks/useHomedx'
import { HdxFile } from '../../../models/HdxTypes'
import ListView from '../../../widgets/ListView'
import { TestSlideProps } from '../../../models/TestProps'
const img = require('../assets/images/Muster_Zertifikat_Profilbild.png')

export default function Picture({ onNext }: TestSlideProps) {
  const [preview, setPreview] = useState<HdxFile | null>(null)

  const { requestAuth, uploadAuthPhoto } = useHomedx()

  const [isUploading, setIsUploading] = useState<boolean>(false)
  const [isShowSuccess, setIsShowSuccess] = useState<boolean>(false)
  const [isShowError, setIsShowError] = useState<boolean>(false)
  const [isShowErrorReset, setIsShowErrorReset] = useState<boolean>(false)

  const upload = useCallback(async () => {
    if (!preview) return
    const s: HdxFile = preview

    setIsUploading(true)
    const res = await uploadAuthPhoto(s, 'identify')
    if (res?.success) {
      requestAuthentication()
    } else {
      setIsShowError(true)
    }
  }, [preview])

  const requestAuthentication = async () => {
    const res = await requestAuth()
    setIsUploading(false)
    if (res?.success) {
      setIsShowSuccess(true)
    } else {
      setIsShowError(true)
    }
  }

  return (
    <>
      <View flex="1">
        <Heading my="2">
          Bitte laden Sie ein Profilbild zum Abgleich mit Ihren Zertifikaten
          hoch
        </Heading>
        <ListView
          data={[
            'Das Profilbild dient zu Ihrer Identifikation (etwa in Restaurants oder Geschäften)',
            'Wir vergleichen Ihr Profilbild mit ihrem Personalausweis'
          ]}
        />
        <View flex="1">
          {preview && (
            <Image
              mt="4"
              bg="gray.300"
              rounded={'full'}
              style={{ width: 100 + '%', aspectRatio: 1 }}
              source={preview}
            />
          )}
        </View>
        {!preview && (
          <VStack space="2">
            <Button
              onPress={async () => {
                const res = await launchCamera({
                  mediaType: 'photo',
                  maxWidth: 500,
                  maxHeight: 500,
                  cameraType: 'front'
                })

                if (!res.didCancel && res.assets) {
                  setPreview({
                    uri: res.assets[0].uri || '',
                    type: 'image/png',
                    name: 'photo.png'
                  })
                }
              }}>
              Foto machen
            </Button>
            <Button
              onPress={async () => {
                const res = await launchImageLibrary({
                  mediaType: 'photo',
                  maxWidth: 500,
                  maxHeight: 500
                })

                if (!res.didCancel && res.assets) {
                  setPreview({
                    uri: res.assets[0].uri || '',
                    type: 'image/png',
                    name: 'photo.png'
                  })
                }
              }}>
              Foto aus Gallerie wählen
            </Button>
          </VStack>
        )}
        {!!preview && (
          <VStack space="2">
            <Button isDisabled={isUploading} onPress={() => setPreview(null)}>
              Erneut versuchen
            </Button>
            <Button isDisabled={isUploading} onPress={upload}>
              Weiter
            </Button>
          </VStack>
        )}
      </View>
      <Modal isOpen={isShowSuccess}>
        <Modal.Content>
          <Modal.Header>Erfolg!</Modal.Header>
          <Modal.Body>
            <Text>
              Ihre Identifikationsprüfung wurde erfolgreich eingereicht!
            </Text>
          </Modal.Body>
          <Modal.Footer>
            <Button onPress={onNext}>Weiter</Button>
          </Modal.Footer>
        </Modal.Content>
      </Modal>
      <Modal isOpen={isShowError} onClose={() => setIsShowError(false)}>
        <Modal.Content>
          <Modal.Header>
            <Modal.CloseButton />
            Fehlgeschlagen!
          </Modal.Header>
          <Modal.Body>Ihr Foto konnte nicht hochgeladen werden</Modal.Body>
          <Modal.Footer>
            <Button onPress={() => (setPreview(null), setIsShowError(false))}>
              Weiter
            </Button>
          </Modal.Footer>
        </Modal.Content>
      </Modal>
      <Modal
        isOpen={isShowErrorReset}
        onClose={() => setIsShowErrorReset(false)}>
        <Modal.Content>
          <Modal.Header>
            <Modal.CloseButton />
            Fehlgeschlagen!
          </Modal.Header>
          <Modal.Body>
            Ihre Authentifizierung konnte nicht abgeschlossen werden.
          </Modal.Body>
          <Modal.Footer>
            <Button variant="ghost" onPress={() => setIsShowErrorReset(false)}>
              Erneut versuchen
            </Button>
            <Button onPress={() => setIsShowErrorReset(false)}>Zurück</Button>
          </Modal.Footer>
        </Modal.Content>
      </Modal>
    </>
  )
}
