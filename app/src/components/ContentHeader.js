import React from 'react'
import CloseButton from 'components/CloseButton'
import { useTranslation } from 'react-i18next'

export default function ContentHeader({ showTitle, onBack, title }) {
  const { t } = useTranslation()
  return (
    <div className="content-header">
      <h3 className="content-header__title">{showTitle && title}</h3>
      <CloseButton onClick={onBack} />
    </div>
  )
}
