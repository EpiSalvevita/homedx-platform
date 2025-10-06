import React, { useRef } from 'react'

import { Button, View } from 'native-base'

type QuestionnaireRangeAnswerProps = {
  next: any
  prefill: any
}

export default function RangeAnswer({
  next,
  prefill
}: QuestionnaireRangeAnswerProps) {
  return (
    <View>
      <View>
        <Button onPress={() => next(true)}>JA</Button>
      </View>
      <View>
        <Button onPress={() => next(false)}>NEIN</Button>
      </View>
    </View>
  )
}
