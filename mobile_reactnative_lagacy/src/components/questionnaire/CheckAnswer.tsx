import React, { ReactNode, useEffect, useMemo, useState } from 'react'

import { Button, Circle, Input, Row, Text, VStack } from 'native-base'
import {
  QuestionnaireCheckItem,
  QuestionnaireCheckOptions
} from '../../widgets/Questionnaire'
import { TouchableOpacity } from 'react-native'

type QuestionnaireCheckAnswerProps = {
  next: (data: string[]) => void
  choices: QuestionnaireCheckItem[] | undefined
  options: QuestionnaireCheckOptions | undefined
  prefill: { [key: string]: boolean }
}

export default function CheckAnswer({
  next,
  prefill,
  choices = [],
  options = {}
}: QuestionnaireCheckAnswerProps) {
  const [value, setValue] = useState<{ [key: string]: boolean }>({})
  const [otherValue, setOtherValue] = useState<string>('')

  useEffect(() => {
    setValue(prefill || {})
  }, [prefill])

  const selected: string[] = useMemo(() => {
    const arr = Object.keys(value).filter(key => value[key])
    console.log({ otherValue })
    otherValue && arr.push(otherValue)
    return arr
  }, [value, otherValue])

  return (
    <VStack>
      <VStack space="2" mb="4">
        {choices.map((choice, index) => (
          <Item
            key={`$choice_${index}`}
            onSelected={(val: boolean) => {
              setValue(prev => ({
                ...prev,
                [choice.value]: val
              }))
            }}>
            {choice.label}
          </Item>
        ))}
        {selected.includes('other') && (
          <Input value={otherValue} onChangeText={setOtherValue} />
        )}
      </VStack>
      <Button isDisabled={!selected.length} onPress={() => next(selected)}>
        Weiter
      </Button>
    </VStack>
  )
}

type ItemProps = {
  children: ReactNode | ReactNode[]
  onSelected: (selected: boolean) => void
}

const Item = ({ children, onSelected }: ItemProps) => {
  const [selected, setSelected] = useState<boolean>(false)

  return (
    <TouchableOpacity
      onPress={() => {
        setSelected(prev => !prev)
        onSelected && onSelected(!selected)
      }}>
      <Row alignItems="center">
        <Circle size={3} bg={selected ? 'primary.500' : 'gray.300'} />
        <Text ml="2" fontSize={18}>
          {children}
        </Text>
      </Row>
    </TouchableOpacity>
  )
}
