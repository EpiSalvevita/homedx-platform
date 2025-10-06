import React, { useCallback, useEffect, useState } from 'react'
import zxcvbn from 'zxcvbn'

import { useTranslation } from 'react-i18next'
import { Box, Input, Text, View } from 'native-base'

export default function PasswordInput({ onChange, userInput, isValid }) {
  const [password, setPassword] = useState('')
  const [score, setScore] = useState(0)
  const [showPassword, setShowPassword] = useState(false)
  const { t } = useTranslation()

  useEffect(() => {
    let { score } = zxcvbn(password, userInput)
    if (!isValid && score > 3) score = 3
    setScore(score)
    return () => {}
  }, [password, userInput, isValid])

  const getColor = useCallback(() => {
    if (score === 0 || score === 1) {
      return 'red.500'
    }
    if (score === 2) {
      return 'red.500' // normal
    }
    if (score === 3) {
      return 'orange.500' // mid
    }
    console.log(isValid)
    if (score === 4 && isValid) {
      return 'green.500' // strong
    }
  }, [score, isValid])

  return (
    <View>
      <Input
        type={showPassword || 'password'}
        onChangeText={val => {
          setPassword(val)
          onChange(val)
        }}
      />
      <View
        style={{}}
        h="2"
        w={`${(score / 4) * 100}%`}
        background={getColor()}></View>
    </View>
  )
}
