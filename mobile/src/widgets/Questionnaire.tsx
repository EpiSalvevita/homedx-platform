import React, { useState, useCallback, ReactNode, useMemo } from 'react'
import { View, Text, Heading } from 'native-base'

import BooleanAnswer from '../components/questionnaire/BooleanAnswer'
import TextAnswer from '../components/questionnaire/TextAnswer'
import DateAnswer from '../components/questionnaire/DateAnswer'
import AnswerView from '../components/questionnaire/AnswerView'
import SelectAnswer from '../components/questionnaire/SelectAnswer'
import RangeAnswer from '../components/questionnaire/RangeAnswer'
import CheckAnswer from '../components/questionnaire/CheckAnswer'
import SummaryView from '../components/questionnaire/SummaryView'

export type QuestionnaireProps = {
  style?: any
  currentQuestion?: QuestionnaireQuestion
  currentIndex?: number
  subIndex?: number
  questionCount?: number
  onFinished?: (data: any[]) => void
  onNextQuestion?: (
    answer: QuestionnaireAnswer,
    removeFollowupQuestion?: (key: any) => void
  ) => void
  onEditQuestionnaire?: () => void
  onEditQuestion?: (key: string) => void
  showSummary?: boolean
  viewMode?: 'simple' | 'view'
  views?: ReactNode[]
  showAnswerView?: boolean
}

export type QuestionnaireAnswer = {
  answer?: string | number | boolean
  show?: boolean
  key?: string
  label?: string
  question?: QuestionnaireQuestion
}

export type QuestionnaireQuestion = {
  key: string
  label?: string
  question?: string
  type: 'text' | 'number' | 'date' | 'boolean' | 'select' | 'range' | 'check'
  followup?: {
    [key: number | string | symbol]: QuestionnaireQuestion[]
  }
  selectOptions?: QuestionnaireSelectOptions
  selectData?: QuestionnaireSelectItem[]
  rangeOptions?: QuestionnaireRangeOptions
  checkOptions?: QuestionnaireCheckOptions
  checkData?: QuestionnaireCheckItem[]
}

export type QuestionnaireSelectItem = {
  label: string
  value: string | 'other'
}

export type QuestionnaireSelectOptions = {}
export type QuestionnaireCheckOptions = {
  mapped?: boolean
  showExtraTextField?: boolean
  extraTextFieldLabel?: string
}
export type QuestionnaireCheckItem = {
  label: string
  value: string | 'other'
}

export type QuestionnaireRangeOptions = {
  min: number
  max: number
}

const NO_SUBINDEX = -1
export default function Questionnaire({
  style,
  currentQuestion = { type: 'text', key: '' },
  currentIndex = 0,
  subIndex = NO_SUBINDEX,
  questionCount = 0,
  onFinished,
  onNextQuestion,
  onEditQuestionnaire,
  onEditQuestion,
  showSummary,
  viewMode = 'simple',
  views = [],
  showAnswerView = false
}: QuestionnaireProps) {
  const [answers, setAnswers] = useState<{ [key: string]: any }>({})

  const removeFollowupQuestion = useCallback(
    key => {
      const data: { [key: string]: any } = answers
      if (data[key]) data[key].show = false
      setAnswers(data)
    },
    [answers]
  )

  const next = useCallback(
    answer => {
      const arr: { [key: string]: any } = answers
      const answerObj: QuestionnaireAnswer = {
        show: true,
        answer,
        question: subQuestion || currentQuestion
      }
      arr[subQuestion?.key || currentQuestion.key] = answerObj

      setAnswers(arr)
      onNextQuestion && onNextQuestion(answer, removeFollowupQuestion)
    },
    [
      answers,
      currentQuestion?.key,
      currentQuestion?.label,
      currentQuestion?.question,
      onNextQuestion,
      removeFollowupQuestion
    ]
  )

  const subQuestion = useMemo(() => {
    if (!currentQuestion) return null
    if (currentQuestion.followup && answers[currentQuestion.key])
      return currentQuestion?.followup[answers[currentQuestion.key].answer][
        subIndex
      ]
    else return null
  }, [currentQuestion, answers, subIndex])

  const computedQuestion = useMemo(
    () => subQuestion || currentQuestion,
    [subQuestion, currentQuestion]
  )

  const currentType = useMemo(() => computedQuestion?.type, [computedQuestion])

  const finishQuestionnaire = useCallback(() => {
    const data = Object.entries(answers)
      .filter(([key, answer]: [string, QuestionnaireAnswer]) => answer.show)
      .map(v => console.log(v))
    onFinished && onFinished(data)
  }, [answers, onFinished])

  return (
    <>
      {!showSummary && (
        <View style={style}>
          {showAnswerView && (
            <View>
              {Object.entries(answers).map(
                ([key, { label, answer, show }]: [
                  string,
                  QuestionnaireAnswer
                ]) =>
                  show &&
                  answers[key]?.toString() && (
                    <AnswerView
                      key={key}
                      label={label}
                      answer={answer}
                      onPress={() => onEditQuestion && onEditQuestion(key)}
                    />
                  )
              )}
            </View>
          )}
          <View flex="1" justifyContent={'flex-end'}>
            <Text>
              Schritt {currentIndex + 1} / {questionCount}
            </Text>
            {viewMode === 'simple' && currentQuestion && (
              <View>
                {subQuestion && (
                  <Text opacity={0.64} fontSize="sm" numberOfLines={1}>
                    {currentQuestion?.question}
                  </Text>
                )}
                <Heading>
                  {subQuestion?.question || currentQuestion.question}
                </Heading>
                <View>
                  {currentType === 'text' && (
                    <TextAnswer
                      next={next}
                      prefill={answers[computedQuestion?.key]?.answer}
                    />
                  )}
                  {currentType === 'date' && (
                    <DateAnswer
                      next={next}
                      prefill={answers[computedQuestion?.key]?.answer}
                    />
                  )}
                  {currentType === 'boolean' && <BooleanAnswer next={next} />}
                  {currentType === 'select' && (
                    <SelectAnswer
                      next={next}
                      prefill={answers[computedQuestion?.key]?.answer}
                      options={computedQuestion.selectOptions}
                    />
                  )}
                  {currentType === 'range' && (
                    <RangeAnswer
                      next={next}
                      prefill={answers[computedQuestion?.key]?.answer}
                    />
                  )}
                  {currentType === 'check' && (
                    <CheckAnswer
                      next={next}
                      choices={computedQuestion?.checkData}
                      options={computedQuestion?.checkOptions}
                      prefill={answers[computedQuestion?.key]?.answer}
                    />
                  )}
                </View>
              </View>
            )}
            {viewMode === 'view' && <>{views[currentIndex]}</>}
          </View>
        </View>
      )}
      {showSummary && (
        <SummaryView
          answers={answers}
          finishQuestionnaire={finishQuestionnaire}
        />
      )}
    </>
  )
}
