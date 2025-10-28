import React from 'react'
import { Button, Heading, Text, VStack, View, List, Square } from 'native-base'
import ListView from '../../../widgets/ListView'
import { TestSlideProps } from '../../../models/TestProps'

export default function Overview({ onNext }: TestSlideProps) {
  return (
    <View justifyContent="flex-end" flex="1">
      <Heading>So geht's</Heading>
      <Text mt="2" mb="4">
        Für eine erfolgreiche Online-Zertifizierung werden Sie nun die folgenden
        Schritte durchführen. Der Prozess dauert etwa 5 Minuten.
      </Text>
      <Heading>Identifikation (einmalig)</Heading>
      <View mt="2" mb="4">
        <ListView
          withIndex
          data={[
            'Foto Vorderseite Personalausweis',
            'Foto Rückseite Personalausweis',
            'Profilbild zum Abgleich'
          ]}
        />
      </View>
      <Button onPress={onNext}>Identifikation starten</Button>
    </View>
  )
}
