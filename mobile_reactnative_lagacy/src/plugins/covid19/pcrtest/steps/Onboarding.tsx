import { View, Text } from 'react-native'
import React from 'react'
import { Button } from 'native-base'

export default function Onboarding({ onNext }) {
  return (
    <View>
      <Text>Onboarding</Text>
      <Button onPress={onNext}>Weiter</Button>
    </View>
  )
}
