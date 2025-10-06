import React from 'react'
import EmptyImage from 'assets/icons/ic_empty.svg'
import { useTranslation } from 'react-i18next'
import { useHistory } from 'react-router-dom'
import Button from 'components/Button'

export default function EmptyCertificateView() {
  const { t } = useTranslation()
  const history = useHistory()
  return (
    <div className="emptyview">
      <div className="emptyview__icon__wrapper">
        <EmptyImage />
      </div>
      <div className="emptyview__content">
        <Button
          className="emptyview__cta"
          style={{ fontSize: 28, padding: '16px 32px', marginBottom: 16 }}
          onClick={() => history.push('/new-test')}
        >
          {t('certificate__empty__title')}
        </Button>
        <p>{t('certificate__empty__text')}</p>
      </div>
    </div>
  )
}
