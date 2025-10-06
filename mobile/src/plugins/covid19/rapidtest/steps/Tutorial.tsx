import React from 'react'
import { Box, Button, Heading, View, Text, VStack } from 'native-base'
import { TestSlideProps } from '../../../../models/TestProps'

export default function Tutorial({ onNext }: TestSlideProps) {
  return (
    <Box flex="1">
      <Heading mt="2">Wichtige Hinweise</Heading>
      <Text>
        Um eine maximale Sensitivität zu erzielen empfehlen wir dringend wie
        hier beschrieben, einen Kombinationsabstrich im Mund- und Nasenraum
        durchzuführen. Sie erhalten aber auch bei korrekter Durchführung eines
        Einzelabstriches im Mund- oder Nasenraum ein gültiges Zertifikat.
      </Text>
      <Heading my="4">Beacheten Sie:</Heading>
      <Text>
        Um eine maximale Sensitivität zu erzielenempfehlen wir dringend wie hier
        beschrieben, einen Kombinationsabstrich im Mund- und Nasenraum
        durchzuführen. Sie erhalten aber auch bei korrekter Durchführung eines
        Einzelabstriches im Mund- oder Nasenraum ein gültiges Zertifikat.
      </Text>
      <View flex="1"></View>
      <VStack space="2">
        <Button variant={'outline'} onPress={onNext}>
          Zum Video-Tutorial
        </Button>
        <Button onPress={onNext}>Weiter</Button>
      </VStack>
    </Box>
  )
}
