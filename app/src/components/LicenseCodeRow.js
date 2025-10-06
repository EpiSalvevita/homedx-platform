import React from 'react'

export default function LicenseCodeRow({ code, active, onClick }) {
  return (
    <div onClick={onClick} className={`licensecode ${active ? 'active' : ''}`}>
      <span className="licensecode__max">
        {code.maxUses > 0 ? `${code.maxUses}er` : '∞'} Lizenz
      </span>
      <span className="licensecode__code">{code.licenseKey}</span>
      {code.maxUses > 0 && (
        <div className="licensecode__badge">
          <span>{code.maxUses - code.usesCount}</span>
        </div>
      )}
    </div>
  )
}
