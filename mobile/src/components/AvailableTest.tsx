import React from 'react'
import {
  Badge,
  Box,
  Button,
  ChevronRightIcon,
  HStack,
  SimpleGrid,
  Text
} from 'native-base'

import { HdxTest } from '../models/HdxTypes'
import {
  GestureResponderEvent,
  Pressable,
  TouchableOpacity
} from 'react-native'
import { t } from 'i18next'
import { useTranslation } from 'react-i18next'

type Props = {
  test: HdxTest
  onPress: (event: GestureResponderEvent) => void
  index: number
}

export default function AvailableTest({ test, onPress, index }: Props) {
  const { t } = useTranslation()

  return (
    <Box shadow={'3'} backgroundColor="white" rounded={6} p="2" mb="4" mx="1">
      <Badge
        alignSelf="flex-start"
        rounded="full"
        variant="solid"
        bg="gray.100">
        <Text fontSize={'xs'}>
          {t(`availableTests_${test.id.charAt(0)}_name`)}
        </Text>
      </Badge>
      <Text my="2" fontWeight={'semibold'}>
        {t(`availableTests_${test.id}_name`)}
      </Text>
      <Text opacity={0.8}>{t(`availableTests_${test.id}_description`)}</Text>
      <Pressable onPress={onPress}>
        <HStack alignItems="center" py="2" flex="1">
          <Text flex="1" variant="unstyled" pl="0" px="0" mx="0" ml="0">
            Jetzt starten
          </Text>
          <ChevronRightIcon size="sm" color="#800343" />
        </HStack>
      </Pressable>
    </Box>
  )
}
