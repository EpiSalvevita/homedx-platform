import React, { useContext, useState } from 'react'
import { NativeStackScreenProps } from '@react-navigation/native-stack'
import { ScreenProps } from '../models/ScreenProps'
import {
  Modal,
  Button,
  Text,
  ChevronRightIcon,
  VStack,
  Row,
  Heading,
  HStack,
  Avatar,
  ScrollView,
  Divider
} from 'native-base'
import { HdxContext } from '../contexts/HdxContext'
import { Pressable, TouchableOpacity } from 'react-native'
import useHomedx from '../hooks/useHomedx'
import { Trans } from 'react-i18next'

export default function Settings({
  navigation
}: NativeStackScreenProps<ScreenProps, 'Settings'>) {
  const { _setToken, userdata } = useContext(HdxContext)
  const { getAuthColor, unsetAuth } = useHomedx()
  const [isShowWarning, setIsShowWarning] = useState<boolean>(false)
  const [isShowUnsetSuccess, setIsShowUnsetSuccess] = useState<boolean>(false)
  const [isShowUnsetError, setIsShowUnsetError] = useState<boolean>(false)

  const unset = async () => {
    setIsShowWarning(false)
    const res = await unsetAuth()

    if (res.success) {
      setIsShowUnsetSuccess(true)
    } else {
      setIsShowUnsetError(true)
    }
  }

  return (
    <>
      <ScrollView>
        <Pressable onPress={() => navigation.push('PersonalData')}>
          <HStack alignItems="flex-start" mt="4">
            <Avatar size="lg" />
            <VStack ml="4" flex="1">
              <Heading>Christian Roeszies</Heading>
              <Text fontSize="md">
                Identität bestätigt:
                <Text color={getAuthColor(userdata.authorized)}>
                  {' '}
                  <Trans i18nKey={`status_${userdata.authorized}`} ns="auth">
                    {userdata.authorized}
                  </Trans>
                </Text>
              </Text>
              <Button
                alignSelf={'flex-end'}
                variant="ghost"
                mt="2"
                pr="0"
                onPress={() => navigation.push('PersonalData')}>
                Kontodaten ändern
              </Button>
            </VStack>
          </HStack>
        </Pressable>
        <Divider mt="4" mb="2" />
        <VStack>
          {/* <Item>Sprache ändern (wollen wir das Native?)</Item> */}
          <Item onPress={() => setIsShowWarning(true)}>
            Identifikation zurücksetzen
          </Item>
          <Item>Corona Warn App zurücksetzen</Item>
          <Heading size={'sm'} mt="8" mb="2" fontWeight={'semibold'}>
            Informationen
          </Heading>
          <Item>Hilfe</Item>
          <Item>Kundensupport</Item>
          <Item>Datenschutz</Item>
          <Item>Impressum</Item>

          <TouchableOpacity
            onPress={async () => {
              _setToken('')
            }}>
            <Row style={{ paddingVertical: 8 }} mt="8">
              <Text color="red.500" flex="1" fontSize="md">
                Ausloggen
              </Text>
            </Row>
          </TouchableOpacity>
        </VStack>
      </ScrollView>
      <Modal isOpen={isShowWarning} onClose={() => setIsShowWarning(false)}>
        <Modal.Content>
          <Modal.Header>
            Wirklich zurücksetzen?
            <Modal.CloseButton />
          </Modal.Header>
          <Modal.Body>
            Wenn Sie Ihre Identifikation zurücksetzen müssen Sie vor Ihrem
            nächsten Test neue Bilder von Ihren Ausweis sowie ein Abgleichbild
            einreichen.
          </Modal.Body>
          <Modal.Footer>
            <Button.Group>
              <Button onPress={() => setIsShowWarning(false)}>Abbrechen</Button>
              <Button onPress={unset} variant="ghost">
                Zurücksetzen
              </Button>
            </Button.Group>
          </Modal.Footer>
        </Modal.Content>
      </Modal>
      <Modal
        isOpen={isShowUnsetSuccess}
        onClose={() => setIsShowUnsetSuccess(false)}>
        <Modal.Content>
          <Modal.Header>
            Erfolg!
            <Modal.CloseButton />
          </Modal.Header>
          <Modal.Body>
            Ihre Identifikation wurde erfolgreich zurückgesetzt
          </Modal.Body>
          <Modal.Footer>
            <Button.Group>
              <Button onPress={() => setIsShowUnsetSuccess(false)}>Ok</Button>
            </Button.Group>
          </Modal.Footer>
        </Modal.Content>
      </Modal>
      <Modal
        isOpen={isShowUnsetError}
        onClose={() => setIsShowUnsetError(false)}>
        <Modal.Content>
          <Modal.Header>
            Fehlgeschlagen!
            <Modal.CloseButton />
          </Modal.Header>
          <Modal.Body>
            Ihre Identifikation konnte nicht zurückgesetzt werden
          </Modal.Body>
          <Modal.Footer>
            <Button.Group>
              <Button onPress={() => setIsShowUnsetError(false)}>Ok</Button>
            </Button.Group>
          </Modal.Footer>
        </Modal.Content>
      </Modal>
    </>
  )
}

const Item = ({ children, onPress }) => {
  return (
    <TouchableOpacity onPress={onPress}>
      <Row style={{ paddingVertical: 8 }}>
        <Text flex="1">{children}</Text>
        <ChevronRightIcon size="sm" color="primary.500" />
      </Row>
    </TouchableOpacity>
  )
}
