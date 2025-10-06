import React, { useCallback, useEffect, useState } from 'react'
import Questionnaire, {
  QuestionnaireQuestion
} from '../../../widgets/Questionnaire'
import Questions from './questions'

const NO_SUBINDEX = -1

export default function AntibodyTest() {
  const [questions, setQuestions] = useState<QuestionnaireQuestion[]>(Questions)
  const [currentQuestion, setCurrentQuestion] = useState<QuestionnaireQuestion>(
    { key: 'null', type: 'text' }
  )
  const [currentIndex, setCurrentIndex] = useState<number>(0)
  const [subIndex, setSubIndex] = useState<number>(NO_SUBINDEX)
  const [showSummary, setShowSummary] = useState<boolean>(false)

  useEffect(() => {
    if (Questions?.length > 0) setCurrentQuestion(Questions[0])
  }, [])

  /**
   * Executed before questionnaire renders new question
   * @return integer next index to use
   */
  const onNextQuestion = useCallback(
    (answer, removeFollowupQuestionCallback) => {
      const next = () => {
        if (currentIndex + 1 < qs.length) {
          setQuestions(qs)
          setCurrentIndex(currentIndex + 1)

          setCurrentQuestion(qs[currentIndex + 1])
        } else {
          setShowSummary(true)
        }
      }

      const qs = [...questions]
      if (currentQuestion.followup && currentQuestion.followup[answer]) {
        let sb = subIndex
        sb = subIndex >= 0 ? sb + 1 : 0

        setSubIndex(sb)

        if (sb < currentQuestion.followup[answer].length) {
          addFollowupQuestion(
            qs,
            currentIndex,
            subIndex,
            currentQuestion.followup[answer][subIndex]
          )
        } else {
          next()
        }
      } else {
        setSubIndex(NO_SUBINDEX)
        next()
      }
    },
    [
      currentIndex,
      currentQuestion?.followup,
      currentQuestion?.type,
      questions,
      subIndex
    ]
  )

  const addFollowupQuestion = (
    questions: QuestionnaireQuestion[],
    currentQuestionIndex: number,
    currentQuestionSubIndex: number,
    data: QuestionnaireQuestion
  ) => {
    questions.splice(
      currentQuestionIndex + 1 + currentQuestionSubIndex,
      0,
      data
    )
  }

  const editQuestion = useCallback(
    key => {
      const i = questions.findIndex(q => q.key === key)
      setCurrentIndex(i)
      setCurrentQuestion(questions[i])
    },
    [questions]
  )

  return (
    <Questionnaire
      style={{ flex: 1 }}
      currentQuestion={currentQuestion}
      onNextQuestion={onNextQuestion}
      showSummary={showSummary}
      onEditQuestion={editQuestion}
      onEditQuestionnaire={() => setShowSummary(false)}
      // onFinished={onNext}
      currentIndex={currentIndex}
      subIndex={subIndex}
      questionCount={questions.length}
    />
  )
}
