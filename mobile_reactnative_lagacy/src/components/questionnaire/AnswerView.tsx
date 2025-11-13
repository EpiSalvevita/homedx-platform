import { Text, View } from 'native-base'
import React from 'react'
import { GestureResponderEvent, TouchableOpacity } from 'react-native'

export type AnswerViewProps = {
  label?: string
  answer?: any
  onPress?: (event: GestureResponderEvent) => void
}

export default function AnswerView({
  label,
  answer,
  onPress
}: AnswerViewProps) {
  return (
    <TouchableOpacity onPress={onPress}>
      <View>
        <View>
          <Text bold>{label}</Text>
        </View>
        <View>
          <Text>{answer.toString()}</Text>
        </View>
      </View>
    </TouchableOpacity>
  )
}
