import React, { useEffect, useState } from 'react'

import { Button, Select, VStack } from 'native-base'
import { QuestionnaireSelectOption } from '../../widgets/Questionnaire'

type QuestionnaireSelectAnswerProps = {
  next: (selected: string) => void
  prefill: string
  options: QuestionnaireSelectOption[] | undefined
}

export default function SelectAnswer({
  next,
  prefill,
  options = []
}: QuestionnaireSelectAnswerProps) {
  const [value, setValue] = useState<string>('')
  useEffect(() => {
    setValue(prefill || '')
  }, [prefill])

  return (
    <VStack space="2">
      <Select selectedValue={value} onValueChange={setValue}>
        {options.map(option => (
          <Select.Item {...option} />
        ))}
      </Select>
      <Button isDisabled={!value} onPress={() => next(value)}>
        Weiter
      </Button>
    </VStack>
  )
}
