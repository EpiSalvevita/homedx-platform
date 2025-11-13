import React, { useContext } from 'react'

import { NativeStackScreenProps } from '@react-navigation/native-stack'
import { ScreenProps } from '../models/ScreenProps'
import { ScrollView, VStack } from 'native-base'
import AvailableTests from '../widgets/AvailableTests'
import LatestTest from '../widgets/LatestTest'

export default function Dashboard({
  navigation
}: NativeStackScreenProps<ScreenProps, 'Dashboard'>) {
  return (
    <ScrollView>
      <VStack style={{ flex: 1 }} space="4">
        <LatestTest />
        <AvailableTests />
      </VStack>
    </ScrollView>
  )
}
