import React from 'react'

export default function Switch({
  label,
  isActive,
  onClick,
  wrapperStyle,
  disabled
}) {
  return (
    <div
      className={`switch__wrapper row ${(disabled && 'disabled') || ''}`}
      style={wrapperStyle}>
      <label className="col-9">{label}</label>
      <div className="col-3">
        <div
          style={{ alignSelf: 'flex-end' }}
          onClick={(!disabled && onClick) || null}
          className={`switch ${isActive ? 'active' : ''}`}></div>
      </div>
    </div>
  )
}
