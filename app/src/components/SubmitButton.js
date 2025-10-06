import React from 'react'

export default function SubmitButton({ disabled, className = '', value }) {
  return (
    <input
      disabled={disabled}
      className={`btn ${disabled ? 'disabled' : ''} ${className}`}
      type={'submit'}
      value={value}
    />
  )
}
