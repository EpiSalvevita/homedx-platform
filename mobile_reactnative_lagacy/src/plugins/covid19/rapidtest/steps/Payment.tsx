import { View, Text } from 'react-native'
import React from 'react'
import { Button } from 'native-base'
import { TestSlideProps } from '../../../../models/TestProps'

export default function Payment({ onNext }: TestSlideProps) {
  return (
    <View>
      <Text>Payment</Text>
      <Button onPress={onNext}>Weiter</Button>
    </View>
  )
}
