import React, { useState, useEffect } from 'react'
import { Button, Input, Row, ChevronRightIcon } from 'native-base'

type QuestionnaireTextAnswerProps = {
  multiline?: boolean
  prefill?: string
  next: (data: string) => void
}

export default function TextAnswer({
  next,
  prefill,
  multiline
}: QuestionnaireTextAnswerProps) {
  const [value, setValue] = useState('')

  useEffect(() => {
    setValue('')
  }, [])

  useEffect(() => {
    setValue(prefill || '')
  }, [prefill])

  return (
    <Row>
      <Input
        flex="1"
        value={value}
        onChangeText={setValue}
        multiline={multiline}
      />
      <Button
        isDisabled={value?.length < 3}
        onPress={() => (next(value), setValue(''))}>
        <ChevronRightIcon />
      </Button>
    </Row>
  )
}
