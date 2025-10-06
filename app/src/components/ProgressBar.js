import React from 'react'

export default function ProgressBar({ progress = 0 }) {
  return (
    <div className={`progressbar`}>
      <div
        className={`progressbar__progress`}
        style={{ width: `${progress}%` }}></div>
    </div>
  )
}
