import React from 'react'

export default function TextInput({
  style,
  className = '',
  onChange,
  placeholder,
  label,
  type = 'text',
  readOnly,
  value,
  required,
  showAsRequired,
  disabled
}) {
  return (
    <div className="input__wrapper" style={{ ...style }}>
      {(label || placeholder) && (
        <label>
          {label || placeholder}
          {showAsRequired ? ' *' : ''}
        </label>
      )}
      <input
        required={required}
        readOnly={readOnly}
        placeholder={placeholder}
        disabled={disabled}
        className={className}
        type={type}
        value={value}
        onChange={({ target: { value } }) => onChange && onChange(value)}
      />
    </div>
  )
}
