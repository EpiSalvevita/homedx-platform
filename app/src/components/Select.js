import React from 'react'

export default function Select({
  className,
  options = [],
  onChange,
  value,
  label,
  placeholder,
  required,
  showAsRequired,
  disabled
}) {
  return (
    <div className="input__wrapper">
      {(label || placeholder) && (
        <label>
          {label || placeholder}
          {showAsRequired ? ' *' : ''}
        </label>
      )}
      <select
        className={className}
        value={value}
        onChange={onChange}
        required={required}
        disabled={disabled}>
        {options && options.map(opt => (
          <option key={opt.label} value={opt.value}>
            {opt.label}
          </option>
        ))}
      </select>
    </div>
  )
}
