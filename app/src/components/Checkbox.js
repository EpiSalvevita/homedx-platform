import React from 'react'

export default function Checkbox({
  label = '',
  className = '',
  wrapperClassName = '',
  onChange,
  name = 'checkbox',
  id = 'checkbox',
  required,
  value
}) {
  return (
    <div className={`checkbox__wrapper ${wrapperClassName}`}>
      <input
        id={id}
        name={name}
        className={`checkbox ${className}`}
        type="checkbox"
        onChange={onChange}
        required={required}
        checked={value}
      />
      <label htmlFor={id}>{label}</label>
    </div>
  )
}
