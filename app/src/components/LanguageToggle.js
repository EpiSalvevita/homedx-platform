import React from 'react'
import CaretIcon from 'assets/icons/ic_caret.svg'
export default function LanguageToggle({ certificateLng, openCertificateLng }) {
  return (
    <div className="lngtoggle" onClick={openCertificateLng}>
      <small>{certificateLng?.substring(0, 2).toUpperCase()}</small>
      <CaretIcon width={16} />
    </div>
  )
}
