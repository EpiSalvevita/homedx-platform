import React, { useContext, useEffect, useState } from 'react'
import {
  Box,
  Button,
  Column,
  Radio,
  Row,
  ScrollView,
  Text,
  View
} from 'native-base'
import { RapidTestContext } from '../RapidTest'
import { TestSlideProps } from '../../../../models/TestProps'
import { CWAChoice } from '../Types'

export default function CWA({ onNext }: TestSlideProps) {
  const [choice, setChoice] = useState<CWAChoice | undefined>()
  const { setTestData } = useContext(RapidTestContext)
  useEffect(() => {
    if (choice !== undefined) return
    setTestData({ agreementGiven: choice })
  }, [choice])

  return (
    <Box flex="1">
      <ScrollView>
        <Radio.Group
          name="cwa"
          value={choice}
          onChange={val => {
            if (val === 'with' || val === 'without' || val === 'none')
              setChoice(val)
          }}>
          <Radio my="2" value="none">
            Keine Übermittlung an Corona Warn App
          </Radio>

          <Radio mt="2" mb="1" value="without">
            EINWILLIGUNG ZUR PSEUDONYMISIERTEN ÜBERMITTLUNG (NICHT-NAMENTLICHE
            ANZEIGE)
          </Radio>

          <Text ml="8" opacity={0.8}>
            Hiermit erkläre ich mein Einverständnis zum Übermitteln meines
            Testergebnisses und meines pseudonymen Codes an das Serversystem des
            RKI, damit ich mein Testergebnis mit der Corona-Warn-App abrufen
            kann. Das Testergebnis in der App kann hierbei nicht als
            namentlicher Testnachweis verwendet werden. Mir wurden Hinweise zum
            Datenschutz ausgehändigt.
          </Text>

          <Radio mt="2" mb="1" value="with">
            EINWILLIGUNG ZUR PERSONALISIERTEN ÜBERMITTLUNG (NAMENTLICHER
            TESTNACHWEIS)
          </Radio>

          <Text ml="8" opacity={0.8}>
            Hiermit erkläre ich mein Einverständnis zum Übermitteln des
            Testergebnisses und meines pseudonymen Codes an das Serversystem des
            RKI, damit ich mein Testergebnis mit der Corona-Warn-App abrufen
            kann. Ich willige außerdem in die Übermittlung meines Namens und
            Geburtsdatums an die App ein, damit mein Testergebnis in der App als
            namentlicher Testnachweis angezeigt werden kann. Mir wurden Hinweise
            zum Datenschutz ausgehändigt.
          </Text>
        </Radio.Group>
      </ScrollView>
      <Button onPress={onNext} isDisabled={choice === undefined}>
        Weiter
      </Button>
    </Box>
  )
}
