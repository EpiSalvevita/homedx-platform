import React, { useCallback, useContext, useState } from 'react'
import {
  Alert,
  Button,
  FormControl,
  Heading,
  HStack,
  Input,
  Modal,
  Row,
  ScrollView,
  Select,
  Text,
  View,
  VStack
} from 'native-base'
import DateTimePicker, {
  DateTimePickerEvent
} from '@react-native-community/datetimepicker'
import { HdxContext } from '../contexts/HdxContext'
import countries from 'i18n-iso-countries'
import { HdxUserData, HdxUserDataChangables } from '../models/HdxTypes'
import useHomedx from '../hooks/useHomedx'
import { useNavigation } from '@react-navigation/native'

const saveFields = {
  firstname: true,
  lastname: true,
  address1: true,
  address2: true,
  city: true,
  company: true,
  country: true,
  dob: true,
  email: true,
  gender: true,
  phone: true,
  postcode: true,
  title: true,
  identityCardId: true,
  identityCardExpirationDate: true
}

export default function PersonalData() {
  const navigation = useNavigation()
  const { userdata } = useContext(HdxContext)
  const { changeUserData } = useHomedx()
  const [isLoading, setIsLoading] = useState<boolean>(false)
  const [isShowSuccess, setIsShowSuccess] = useState<boolean>(false)
  const [isShowError, setIsShowError] = useState<boolean>(false)
  const [isShowDobCalendar, setIsShowDobCalendar] = useState<boolean>(false)
  const [isShowIdCalendar, setIsShowIdCalendar] = useState<boolean>(false)

  const [changedData, setChangedData] = useState<HdxUserDataChangables>({})

  const updateUserData = useCallback(async () => {
    const d: HdxUserData = {}

    for (let key in saveFields) {
      d[key] = changedData[key] || userdata[key]
    }

    d.first_name = d.firstname
    d.last_name = d.lastname
    delete d.firstname
    delete d.lastname

    d.identity_card_id = d.identityCardId
    delete d.identityCardId

    d.identity_card_expiration_date =
      d.identityCardExpirationDate?.date.substring(0, 10)

    d.dob = new Date(d.dob * 1000).toISOString().substring(0, 10)

    d.address_1 = d.address1
    d.address_2 = d.address2
    delete d.address1
    delete d.address2

    setIsLoading(true)

    const res = await changeUserData(d)
    console.log(res)
    if (res.success) {
      setIsShowSuccess(true)
    } else {
      setIsShowError(true)
    }
    setIsLoading(false)
  }, [userdata, changedData])

  return (
    <ScrollView>
      <Heading mt="2">Meine Daten</Heading>
      <Text my="2">
        Im Rahmen der Identitätsprüfung benötigen wir die folgenden Angaben von
        Ihnen.
      </Text>

      <Heading>Kontodaten</Heading>
      {/* <Text my="2">
        Diese Daten dienen zur Identifikation und können nicht mehr verändert
        werden.
      </Text> */}
      <VStack my="2">
        <Row>
          <Text fontWeight="semibold" flex="1">
            Vorname
          </Text>
          <Text flex="2">{userdata.firstname}</Text>
        </Row>
        <Row>
          <Text fontWeight="semibold" flex="1">
            Nachname
          </Text>
          <Text flex="2">{userdata.lastname}</Text>
        </Row>
        <Row>
          <Text fontWeight="semibold" flex="1">
            E-Mail
          </Text>
          <Text flex="2">{userdata.email}</Text>
        </Row>
      </VStack>

      <Heading mt="4">Persönliche Angaben</Heading>
      <Text mb="2" opacity={0.8} fontSize="xs">
        Alle Felder sind Pflichtfelder, wenn nicht anders vermerkt.
      </Text>
      <VStack space="4">
        <FormControl>
          <FormControl.Label>Vorname</FormControl.Label>
          <Input
            placeholer="Vorname"
            value={
              changedData.firstname !== undefined
                ? changedData.firstname
                : userdata.firstname
            }
            onChangeText={val =>
              setChangedData(prev => ({ ...prev, firstname: val }))
            }
          />
        </FormControl>
        <FormControl>
          <FormControl.Label>Nachname</FormControl.Label>
          <Input
            placeholer="Nachname"
            value={
              changedData.lastname !== undefined
                ? changedData.lastname
                : userdata.lastname
            }
            onChangeText={val =>
              setChangedData(prev => ({ ...prev, lastname: val }))
            }
          />
        </FormControl>
        <FormControl>
          <FormControl.Label>Telefon</FormControl.Label>
          <Input
            type="tel"
            placeholer="Telefon"
            value={
              changedData.phone !== undefined
                ? changedData.phone
                : userdata.phone
            }
            onChangeText={val =>
              setChangedData(prev => ({ ...prev, phone: val }))
            }
          />
        </FormControl>
        <FormControl>
          <FormControl.Label>Geschlecht</FormControl.Label>
          <Select
            selectedValue={
              changedData.gender !== undefined
                ? changedData.gender
                : userdata.gender
            }
            onValueChange={val =>
              setChangedData(prev => ({ ...prev, gender: val }))
            }
            accessibilityLabel="Geschlecht"
            placeholder="Geschlecht">
            <Select.Item value="female" label="weiblich" />
            <Select.Item value="male" label="männlich" />
            <Select.Item value="diverse" label="divers" />
          </Select>
        </FormControl>
        <FormControl isDisabled>
          <FormControl.Label>Geburtsdatum</FormControl.Label>
          <Input
            type="date"
            placeholer="Geburtsdatum"
            value={
              changedData.dob !== undefined
                ? new Date(changedData.dob * 1000).toLocaleDateString()
                : new Date(userdata.dob * 1000).toLocaleDateString()
            }
            onPressOut={() => setIsShowDobCalendar(true)}
          />
        </FormControl>
        <FormControl>
          <FormControl.Label>Straße</FormControl.Label>
          <Input
            type="location"
            placeholder="Straße"
            value={
              changedData.address1 !== undefined
                ? changedData.address1
                : userdata.address1
            }
            onChangeText={val =>
              setChangedData(prev => ({ ...prev, address1: val }))
            }
          />
        </FormControl>
        <FormControl>
          <FormControl.Label>Zusatz (optional)</FormControl.Label>
          <Input
            type="location"
            placeholder="Zusatz (optional)"
            value={
              changedData.address2 !== undefined
                ? changedData.address2
                : userdata.address2
            }
            onChangeText={val =>
              setChangedData(prev => ({ ...prev, address2: val }))
            }
          />
        </FormControl>
        <FormControl>
          <FormControl.Label>PLZ</FormControl.Label>
          <Input
            type="number"
            placeholder="PLZ"
            value={
              changedData.postcode !== undefined
                ? changedData.postcode
                : userdata.postcode
            }
            onChangeText={val =>
              setChangedData(prev => ({ ...prev, postcode: val }))
            }
          />
        </FormControl>
        <FormControl>
          <FormControl.Label>Ort / Stadt</FormControl.Label>
          <Input
            type="location"
            placeholder="Ort /Stadt"
            value={
              changedData.city !== undefined ? changedData.city : userdata.city
            }
            onChangeText={val =>
              setChangedData(prev => ({ ...prev, city: val }))
            }
          />
        </FormControl>

        <FormControl>
          <FormControl.Label>Land</FormControl.Label>
          <Select
            selectedValue={
              changedData.country !== undefined
                ? changedData.country
                : userdata.country
            }
            onValueChange={val =>
              setChangedData(prev => ({ ...prev, country: val }))
            }
            accessibilityLabel="Land"
            placeholder="Land">
            {Object.entries(
              countries.getNames('de', { select: 'official' })
            ).map(([code, name]: [code: string, name: string]) => (
              <Select.Item value={code} label={name} />
            ))}
          </Select>
        </FormControl>
        <FormControl>
          <FormControl.Label>Ausweisnummer</FormControl.Label>
          <Input
            type="text"
            placeholder="Ausweisnummer"
            value={
              changedData.identityCardId !== undefined
                ? changedData.identityCardId
                : userdata.identityCardId
            }
            onChangeText={val =>
              setChangedData(prev => ({ ...prev, identityCardId: val }))
            }
          />
        </FormControl>
        <FormControl isDisabled>
          <FormControl.Label>Ausweis gültig bis</FormControl.Label>
          <Input
            type="date"
            placeholer="Gültigkeitsdatum"
            value={
              (changedData.identityCardExpirationDate !== undefined
                ? new Date(
                    changedData.identityCardExpirationDate?.date
                  ).toLocaleDateString()
                : new Date(
                    userdata?.identityCardExpirationDate?.date.substring(0, 10)
                  ).toLocaleDateString()) ||
              new Date(Date.now()).toLocaleDateString()
            }
            onPressOut={() => setIsShowIdCalendar(true)}
          />
        </FormControl>

        {userdata.authorized === 'accepted' && (
          <Alert status={'warning'} flexDirection={'row'}>
            <HStack space={2} flex="1">
              <Alert.Icon mt="1" />

              <Text flex="1" wordBreak={'break-all'}>
                Das Ändern der persönlichen Daten erfordert eine erneute
                Authentifizierung. Sie werden dazu aufgefordert Ihren
                Personalausweis erneut überprüfen zu lassen.
              </Text>
            </HStack>
          </Alert>
        )}
        {userdata.authorized === 'in_progress' && (
          <Alert status={'info'} flexDirection={'row'}>
            <HStack space={2} flex="1">
              <Alert.Icon mt="1" />

              <Text wordBreak={'break-all'} flex="1">
                Ihre Authentifizierung ist bereits in Prüfung. Sie können keine
                Änderungen vornehmen bevor die Prüfung beendet ist.
              </Text>
            </HStack>
          </Alert>
        )}
        {userdata.authorized === 'requested' && (
          <Alert status={'info'} flexDirection={'row'}>
            <HStack space={2} flex="1">
              <Alert.Icon mt="1" />
              <Text wordBreak={'break-all'} flex="1">
                Änderungen die Sie jetzt vornehmen überschreiben die von Ihnen
                zur Prüfung eingereichten Informationen.
              </Text>
            </HStack>
          </Alert>
        )}
        <Button
          isDisabled={isLoading || Object.entries(changedData).length === 0}
          onPress={updateUserData}>
          Daten speichern
        </Button>
      </VStack>
      <Modal
        isOpen={isShowIdCalendar}
        onClose={() => setIsShowIdCalendar(false)}>
        <Modal.Content>
          <Modal.CloseButton />
          <Modal.Header>Ausweisgültigkeit</Modal.Header>
          <Modal.Body>
            <DateTimePicker
              display="spinner"
              mode="date"
              minimumDate={new Date(Date.now())}
              value={
                new Date(
                  changedData.identityCardExpirationDate !== undefined
                    ? changedData.identityCardExpirationDate.date.substring(
                        0,
                        10
                      )
                    : userdata.identityCardExpirationDate?.date.substring(0, 10)
                )
              }
              onChange={(event: DateTimePickerEvent, date?: Date) =>
                setChangedData(prev => ({
                  ...prev,
                  identityCardExpirationDate: {
                    date: date?.toISOString().substring(0, 10)
                  }
                }))
              }
            />
          </Modal.Body>
          <Modal.Footer>
            <Button.Group>
              <Button
                variant="ghost"
                onPress={() =>
                  setChangedData(prev => ({
                    ...prev,
                    identityCardExpirationDate: {
                      date: userdata.identityCardExpirationDate?.date.substring(
                        0,
                        10
                      )
                    }
                  }))
                }>
                Zurücksetzen
              </Button>
              <Button onPress={() => setIsShowIdCalendar(false)}>
                Speichern
              </Button>
            </Button.Group>
          </Modal.Footer>
        </Modal.Content>
      </Modal>
      <Modal
        isOpen={isShowDobCalendar}
        onClose={() => setIsShowDobCalendar(false)}>
        <Modal.Content>
          <Modal.CloseButton />
          <Modal.Header>Geburtsdatum wählen</Modal.Header>
          <Modal.Body>
            <DateTimePicker
              display="spinner"
              mode="date"
              maximumDate={new Date(Date.now())}
              value={
                new Date(
                  changedData.dob !== undefined
                    ? changedData.dob * 1000
                    : userdata.dob * 1000
                )
              }
              onChange={(event: DateTimePickerEvent, date?: Date) =>
                setChangedData(prev => ({
                  ...prev,
                  dob: (date?.getTime() || 0) / 1000
                }))
              }
            />
          </Modal.Body>
          <Modal.Footer>
            <Button.Group>
              <Button
                variant="ghost"
                onPress={() =>
                  setChangedData(prev => ({
                    ...prev,
                    dob: userdata.dob
                  }))
                }>
                Zurücksetzen
              </Button>
              <Button onPress={() => setIsShowDobCalendar(false)}>
                Speichern
              </Button>
            </Button.Group>
          </Modal.Footer>
        </Modal.Content>
      </Modal>

      <Modal isOpen={isShowSuccess}>
        <Modal.Content>
          <Modal.Header>Erfolg!</Modal.Header>
          <Modal.Body>
            <VStack>
              <Text>Ihre Daten wurden erfolgreich geändert.</Text>
              <Text bold>
                Bevor Sie den nächsten Test starten können, müssen Sie sich
                erneut authentifizieren.
              </Text>
            </VStack>
          </Modal.Body>
          <Modal.Footer>
            <Button
              onPress={() => {
                setIsShowSuccess(false)
                navigation.popToTop()
                navigation.push('Authentication')
              }}>
              Weiter
            </Button>
          </Modal.Footer>
        </Modal.Content>
      </Modal>
      <Modal isOpen={isShowError}>
        <Modal.Content>
          <Modal.Header>Fehlgeschlagen!</Modal.Header>
          <Modal.Body>
            Bitte versuchen Sie es erneut. Sollten Sie keinen Erfolg haben,
            brechen Sie ab und melden dies bitte dem Support.
          </Modal.Body>
          <Modal.Footer>
            <Button.Group>
              <Button onPress={updateUserData}>Erneut versuchen</Button>
              <Button onPress={() => setIsShowError(false)}>Abbrechen</Button>
            </Button.Group>
          </Modal.Footer>
        </Modal.Content>
      </Modal>
    </ScrollView>
  )
}
