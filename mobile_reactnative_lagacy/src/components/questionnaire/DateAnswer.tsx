import React, { useEffect, useState } from 'react'
import { Button, View, Modal, Input, VStack } from 'native-base'

import DateTimePicker, {
  DateTimePickerEvent
} from '@react-native-community/datetimepicker'

type QuestionnaireDateAnswerProps = {
  next: (data: number) => void
  prefill?: number
  minimumDate?: Date
  maximumDate?: Date
}

export default function DateAnswer({
  next,
  prefill,
  minimumDate,
  maximumDate
}: QuestionnaireDateAnswerProps) {
  const [value, setValue] = useState<number>(0)
  const [showCalendar, setShowCalendar] = useState<boolean>()

  useEffect(() => {
    setValue(prefill || Date.now())
  }, [prefill])

  return (
    <>
      <VStack space="2">
        <Input
          isDisabled
          value={new Date(value).toLocaleDateString()}
          onPressOut={() => setShowCalendar(true)}
        />
        <Button isDisabled={!value} onPress={() => next(value)}>
          {/* <Caret /> */}
          Weiter
        </Button>
      </VStack>
      <Modal isOpen={showCalendar} onClose={() => setShowCalendar(false)}>
        <Modal.Content>
          <Modal.CloseButton />
          <Modal.Header>Geburtsdatum wählen</Modal.Header>
          <Modal.Body>
            <DateTimePicker
              display="spinner"
              mode="date"
              maximumDate={maximumDate || new Date(Date.now())}
              value={new Date(value)}
              onChange={(event: DateTimePickerEvent, date?: Date) =>
                setValue(date?.getTime() || 0)
              }
            />
          </Modal.Body>
          <Modal.Footer>
            <Button.Group>
              <Button
                variant="ghost"
                onPress={() => setValue(new Date().getTime() || 0)}>
                Zurücksetzen
              </Button>
              <Button onPress={() => setShowCalendar(false)}>Wählen</Button>
            </Button.Group>
          </Modal.Footer>
        </Modal.Content>
      </Modal>
    </>
  )
}
