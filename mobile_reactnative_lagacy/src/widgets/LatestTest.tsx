import {
  Badge,
  Box,
  Button,
  Divider,
  Heading,
  Row,
  Text,
  VStack
} from 'native-base'
import React, { useContext, useMemo } from 'react'
import { Trans, useTranslation } from 'react-i18next'
import { View } from 'react-native'
import { HdxContext } from '../contexts/HdxContext'
import { HdxResult, HdxResultWrapper } from '../models/HdxTypes'

export default function LatestTest() {
  const { t } = useTranslation()
  const { testResults } = useContext(HdxContext)

  const test: HdxResult = useMemo<HdxResult>(() => {
    if (!testResults || testResults.length == 0) {
      const res: HdxResult = { result: '', testDate: 0 }
      return res
    }

    var data: [string, HdxResultWrapper][] = Object.entries(testResults).filter(
      (_: [string, HdxResultWrapper]) => _[1].lastTest !== null
    )
    if (data.length == 0) {
      const res: HdxResult = { result: '', testDate: 0 }
      return res
    }
    const newest: [string, HdxResultWrapper] = data.reduce(
      (prev, cur) =>
        cur[1].lastTest?.testDate > prev[1].lastTest?.testDate ? cur : prev,
      data[0]
    )
    newest[1].lastTest.testId = newest[0]
    const latest: HdxResult = newest[1].lastTest
    return latest
  }, [testResults])

  const testResult = useMemo(
    () =>
      test.status === 'in_progress' || test.status === 'video_queue'
        ? test.status
        : test.result,
    [test.result]
  )

  return (
    <Box mt="2">
      <Row>
        <Heading flex="1">
          <Trans i18nKey={'dashboard_newest_certificate'}>
            Neuestes Zertifikat
          </Trans>
        </Heading>
        <Button variant="ghost" pr="0">
          Detailansicht
        </Button>
      </Row>
      <Row alignItems={'center'} my="2">
        <Badge
          alignSelf="flex-start"
          rounded="full"
          variant="solid"
          bg="gray.100">
          <Text fontSize={'xs'}>
            {t(`availableTests_${test?.testId?.charAt(0)}_name`)}
          </Text>
        </Badge>
        <Text fontWeight={'semibold'} ml="2">
          {t(`availableTests_${test?.testId}_name`)}
        </Text>
      </Row>
      <Row alignItems={'flex-end'} justifyContent="space-between">
        <VStack>
          <Text fontSize={'xs'}>Ergebnis</Text>
          <Text fontSize={'xs'}>
            {t(`rapidTest_result_${testResult}`, { ns: 'covid19' })}
          </Text>
        </VStack>
        <VStack>
          <Text fontSize={'xs'}>Ausgestellt am</Text>
          <Text fontSize={'xs'} alignSelf="flex-end">
            {new Date(Date.now()).toLocaleDateString()}
          </Text>
        </VStack>
      </Row>
      <Divider mt="4" />
    </Box>
  )
}
