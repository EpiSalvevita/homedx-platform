import React from 'react'

export default function RecordButton({ className, isRecording, onClick }) {
  return (
    <div
      onClick={onClick}
      className={`btn__record ${className} ${isRecording ? 'stop' : ''}`}>
      <div className="btn__record__icon">
        <span>{!isRecording ? 'START' : 'STOP'}</span>
      </div>
    </div>
  )
}
