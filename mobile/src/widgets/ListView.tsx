import React, { ReactNode } from 'react'
import { VStack, Text, Row, Circle, Box } from 'native-base'

export default function ListView({
  data = [],
  withIndex,
  icon
}: {
  data: string[]
  withIndex?: boolean
  icon?: ReactNode
}) {
  return (
    <VStack space="2">
      {data.map((text, index) => (
        <Row alignItems="flex-start">
          {withIndex ? (
            <Box
              rounded={'md'}
              borderWidth="1"
              borderColor="primary.500"
              width={8}
              height={8}
              alignItems="center"
              justifyContent="center">
              <Text
                textAlign={'center'}
                fontSize="lg"
                verticalAlign={'middle'}
                color="primary.500">
                {index}
              </Text>
            </Box>
          ) : (
            icon || <Circle bg="primary.500" width="2" height="2" mt="2" />
          )}
          <Text fontSize="md" ml="2" flex="1">
            {text}
          </Text>
        </Row>
      ))}
    </VStack>
  )
}
