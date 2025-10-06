import React from 'react'
import CloseIcon from 'assets/icons/ic_close.svg'

export default function CloseButton({ onClick }) {
  return (
    <div className="btn btn--close ghost">
      <CloseIcon onClick={onClick} />
    </div>
  )
}
