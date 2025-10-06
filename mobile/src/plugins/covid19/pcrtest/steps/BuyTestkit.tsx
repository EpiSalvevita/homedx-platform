import { View, Text } from 'react-native'
import React from 'react'
import { Button } from 'native-base'

export default function BuyTestkit({ onNext }) {
  return (
    <View>
      <Text>BuyTestkit</Text>
      <Button onPress={onNext}>Weiter</Button>
    </View>
  )
}
