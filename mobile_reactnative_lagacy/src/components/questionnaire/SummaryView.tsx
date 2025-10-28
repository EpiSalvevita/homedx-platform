import React from 'react'
import {
  View,
  ScrollView,
  VStack,
  Text,
  Button,
  Heading,
  Box
} from 'native-base'
import { QuestionnaireAnswer } from '../../widgets/Questionnaire'

type QuestionnaireSummaryViewProps = {
  answers: QuestionnaireAnswer[]
  finishQuestionnaire: () => void
}

export default function SummaryView({
  answers,
  finishQuestionnaire
}: QuestionnaireSummaryViewProps) {
  const renderAnswer = (data: QuestionnaireAnswer) => {
    switch (data.question.type) {
      case 'text':
      case 'select':
        return data.question?.selectOptions?.find(o => o.value === data.answer)
          ?.label
      case 'boolean':
        return data.answer ? 'Ja' : 'Nein'
      case 'date':
        return new Date(data.answer).toLocaleDateString()
      case 'check':
        let s = ''

        const vals =
          data.question?.checkOptions?.filter(
            o => o.value !== 'other' && data.answer.includes(o.value)
          ) || []

        for (const i in vals) {
          s += vals[i].label
          if (i < vals.length - 1) {
            s += ', '
          }
        }

        if (data.answer.includes('other')) {
          s += ', '
          var split = data.answer.slice(
            data.answer.findIndex(o => o.value === 'other')
          )
          s += split
        }

        return s
      default:
        return data.answer
    }
  }

  return (
    <View flex="1">
      <ScrollView overflow={'visible'}>
        <VStack space="4" py="4">
          <Heading>Sind Ihre Angaben korrekt?</Heading>
          {Object.entries(answers).map(
            ([key, data]: [string, QuestionnaireAnswer]) =>
              data.show && (
                <Box
                  key={key}
                  shadow={2}
                  bg="white"
                  px="4"
                  py="2"
                  borderRadius={4}>
                  <Text fontSize="md">{data.question.question}</Text>
                  <Text bold mt="2">
                    {renderAnswer(data)}
                  </Text>
                  <Button variant="ghost" alignSelf="flex-end">
                    Bearbeiten
                  </Button>
                </Box>
              )
          )}
        </VStack>
      </ScrollView>
      <View>
        <Button onPress={finishQuestionnaire}>Weiter</Button>
      </View>
    </View>
  )
}
