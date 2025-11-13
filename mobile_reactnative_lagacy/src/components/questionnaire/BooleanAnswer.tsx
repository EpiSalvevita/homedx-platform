import React from 'react'

import { Button, View, Text, VStack } from 'native-base'
import { Trans, useTranslation } from 'react-i18next'

type QuestionnaireBooleanAnswerProps = {
  next: (choice: boolean) => void
}

export default function BooleanAnswer({
  next
}: QuestionnaireBooleanAnswerProps) {
  const { t } = useTranslation()
  return (
    <VStack space="2">
      <Button onPress={() => next(true)}>
        {t('questionnaire_answer_yes', { defaultValue: 'JA' })}
      </Button>

      <Button onPress={() => next(false)}>
        {t('questionnaire_answer_no', { defaultValue: 'NEIN' })}
      </Button>
    </VStack>
  )
}
