import React, { useContext, useMemo } from 'react'
import { FlatList } from 'react-native'
import { Column, Heading, HStack, Row, SimpleGrid, VStack } from 'native-base'

import AvailableTest from '../components/AvailableTest'
import { HdxContextProps, HdxPlugin, HdxTest } from '../models/HdxTypes'
import { HdxContext } from '../contexts/HdxContext'
import { useNavigation } from '@react-navigation/native'
import { Trans } from 'react-i18next'

type Props = {}

export default function AvailableTests({}: Props) {
  const { availableTests }: { availableTests: HdxPlugin[] } =
    useContext<HdxContextProps>(HdxContext)

  const navigation = useNavigation()

  const tests = useMemo(
    () =>
      availableTests
        ?.map((ns: HdxPlugin) => ns?.testTypes.map((test: HdxTest) => test))
        .flat(1),
    [availableTests]
  )

  return (
    <VStack style={{ flex: 1, paddingHorizontal: 0, overflow: 'visible' }}>
      <Heading>
        <Trans i18nKey="dashboard_available_tests">Verfügbare Tests</Trans>
      </Heading>
      <SimpleGrid></SimpleGrid>
      <HStack flexWrap={'wrap'} mt="2">
        {tests.map((item, index) => (
          <Column flexShrink="0" flexBasis="50%">
            <AvailableTest
              test={item}
              index={index}
              onPress={() => navigation.navigate('Covid19', { path: item.id })}
            />
          </Column>
        ))}
      </HStack>
    </VStack>
  )
}
