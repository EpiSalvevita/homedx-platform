import React from 'react'
import { Link } from 'react-router-dom'

export default function LinkButton({ to, disabled, className = '', children }) {
  return (
    <Link to={to} className={`btn ${className} ${disabled ? 'disabled' : ''}`}>
      {children}
    </Link>
  )
}
