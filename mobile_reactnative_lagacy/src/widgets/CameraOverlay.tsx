import { Box, Circle, Pressable, View } from 'native-base'
import React, { useMemo } from 'react'

export default function CameraOverlay({
  onPress,
  isRecording,
  isVideo = false
}: {
  onPress: () => void
  isRecording?: boolean
  isVideo?: boolean
}) {
  const borderRadius = useMemo(
    () => (!isVideo ? 2 : isRecording ? 2 : 9),
    [isVideo, isRecording]
  )

  return (
    <View flex="1" justifyContent={'flex-end'} pb="4">
      <Pressable onPress={onPress}>
        <Circle
          minW="18px"
          minH="18px"
          p="4"
          bg="#00000055"
          alignSelf={'center'}>
          <Box
            w="18px"
            h="18px"
            bg="primary.100"
            borderRadius={borderRadius}></Box>
        </Circle>
      </Pressable>
    </View>
  )
}
