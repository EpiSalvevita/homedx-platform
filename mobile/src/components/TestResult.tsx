import { Box, Text } from 'native-base'
import React from 'react'
import { ListRenderItem } from 'react-native'
import { HdxResult } from '../models/HdxTypes'

export default function TestResult({ item: test }: { item: HdxResult }) {
  return (
    <Box>
      <Text>{test.result}</Text>
    </Box>
  )
}
