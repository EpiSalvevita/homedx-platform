import React from 'react'

export default function UpdateToast({ onClick }) {
  return (
    <div onClick={onClick} className="toast toast--update">
      <div>Es ist ein Update verfügbar</div>
      <div className="toast__btn">neu laden</div>
    </div>
  )
}
