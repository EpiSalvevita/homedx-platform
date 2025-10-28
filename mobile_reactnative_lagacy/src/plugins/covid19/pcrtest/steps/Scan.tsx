import { View, Text } from 'react-native'
import React from 'react'
import { Button } from 'native-base'

export default function Scan({ onNext }) {
  return (
    <View>
      <Text>Scan</Text>
      <Button onPress={onNext}>Weiter</Button>
    </View>
  )
}
