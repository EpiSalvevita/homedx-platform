import React from 'react'
import { Box, Button, Heading, Text, View } from 'native-base'
import { TestSlideProps } from '../../../../models/TestProps'

export default function Components({ onNext }: TestSlideProps) {
  return (
    <Box flex="1" justifyContent={'flex-start'}>
      <Heading mt="2">Alles vollständig?</Heading>
      <Text>
        Prüfen Sie Ihr Testkit auf dessen Vollständigkeit. Diese Komponenten
        werden benötigt:
      </Text>
      <Heading my="4">Achtung:</Heading>
      <Text>
        Bitte beachten Sie, dass Packungsinhalte und Durchführung Ihres Tests
        geringfügig abweichen können. Lesen Sie deshalb ebenfalls die
        Gebrauchsanweisung Ihres Testkits.
      </Text>
      <View flex="1"></View>
      <Button onPress={onNext}>Weiter</Button>
    </Box>
  )
}
