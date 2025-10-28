import React, { useContext, useEffect } from 'react'
import { Box, FlatList, Text } from 'native-base'
import { View } from 'react-native'

import TestResult from '../components/TestResult'
import { HdxContext } from '../contexts/HdxContext'
import useHomedx from '../hooks/useHomedx'

type Props = {}

export default function MyTestResults({}: Props) {
  const { testResults } = useContext(HdxContext)

  return (
    <Box>
      <FlatList
        data={Object.entries(testResults).map(([id, { lastTest }]) => lastTest)}
        renderItem={TestResult}
      />
    </Box>
  )
}
