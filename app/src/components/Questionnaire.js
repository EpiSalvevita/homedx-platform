import React, { useState, useCallback } from 'react'
import Button from './Button'
import BooleanAnswer from './questionnaire/BooleanAnswer'
import TextAnswer from './questionnaire/TextAnswer'
import DateAnswer from './questionnaire/DateAnswer'
import AnswerView from './questionnaire/AnswerView'
import { Trans } from 'react-i18next'

export default function Questionnaire({
  style,
  currentQuestion = {},
  currentIndex = 0,
  questionCount = 0,
  onFinished,
  onNextQuestion,
  onEditQuestionnaire,
  onEditQuestion,
  showSummary,
  viewMode = 'simple',
  views = []
}) {
  const [answers, setAnswers] = useState({})

  const next = useCallback(
    answer => {
      const arr = answers

      const answerObj = {
        show: true,
        answer,
        label: currentQuestion.label,
        question: currentQuestion.question
      }
      arr[currentQuestion.key] = answerObj

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

  const removeFollowupQuestion = useCallback(
    key => {
      const data = answers
      if (data[key]) data[key].show = false
      setAnswers(data)
    },
    [answers]
  )

  const finishQuestionnaire = useCallback(() => {
    const data = Object.entries(answers)
      .filter(([key, answer]) => answer.show)
      .map(v => console.log(v))
    onFinished && onFinished(data)
  }, [answers, onFinished])

  return (
    <div className="questionnaire" style={style}>
      {!showSummary && (
        <>
          <div style={{ display: 'block', opacity: 0.6 }}>
            <Trans i18nKey="step">Schritt</Trans> {currentIndex + 1} /{' '}
            {questionCount}
          </div>
          <div className="answers">
            {Object.entries(answers).map(
              ([key, { label, answer, show }]) =>
                show &&
                answers[key]?.toString() && (
                  <AnswerView
                    key={key}
                    label={label}
                    answer={answer}
                    onClick={() => onEditQuestion && onEditQuestion(key)}
                  />
                )
            )}
          </div>
          {viewMode === 'simple' && currentQuestion && (
            <div style={{ flex: '0', justifyContent: 'flex-end' }}>
              <h1 style={{ wordWrap: 'break-word' }}>
                {currentQuestion?.question}
              </h1>
              <div className="action__wrapper">
                {currentQuestion?.type === 'text' && (
                  <TextAnswer
                    next={next}
                    prefill={answers[currentQuestion?.key]?.answer}
                  />
                )}
                {currentQuestion?.type === 'date' && (
                  <DateAnswer
                    next={next}
                    prefill={answers[currentQuestion?.key]?.answer}
                  />
                )}
                {currentQuestion?.type === 'boolean' && (
                  <BooleanAnswer next={next} />
                )}
              </div>
            </div>
          )}
          {viewMode === 'view' && <>{views[currentIndex]}</>}
        </>
      )}
      {showSummary && (
        <div style={{ overflow: 'hidden' }}>
          <div style={{ overflowY: 'scroll', flex: 1 }}>
            <h2 style={{ wordWrap: 'break-word' }}>
              Sind Ihre Angaben korrekt?
            </h2>
            <ul className="list" style={{ flex: 1 }}>
              {Object.entries(answers).map(([key, { question, answer }]) => (
                <li key={key} className="list__item">
                  <h4>{question}</h4>
                  <p style={{ marginBottom: 10 }}>{answer.toString()}</p>
                </li>
              ))}
            </ul>
          </div>
          <div>
            <Button onClick={finishQuestionnaire}>Weiter</Button>
            <Button onClick={onEditQuestionnaire}>Zurück</Button>
          </div>
        </div>
      )}
    </div>
  )
}
