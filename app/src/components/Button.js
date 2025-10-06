import React from 'react'

export default function Button({
  children,
  disabled,
  onClick,
  className = '',
  style
}) {
  const handleClick = (e) => {
    e.preventDefault();
    e.stopPropagation();
    if (!disabled && onClick) {
      onClick(e);
    }
  };

  const handleDivClick = (e) => {
    handleClick(e);
  };

  return (
    <div
      style={style}
      className={`btn ${className} ${disabled ? 'disabled' : ''}`}
      onClick={handleDivClick}>
      {children}
    </div>
  )
}
