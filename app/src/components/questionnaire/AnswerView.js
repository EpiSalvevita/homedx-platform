import React from 'react'

export default function AnswerView({ label, answer, onClick }) {
  return (
    <div className="answer" onClick={onClick}>
      <div className="col-6">
        <strong className="answer__label">{label}</strong>
      </div>
      <div className="col-6" style={{ alignItems: 'flex-end' }}>
        <div className="answer__answer">{answer.toString()}</div>
      </div>
    </div>
  )
}
