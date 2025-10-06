import React from 'react'
import Button from 'components/Button'
import { useTranslation } from 'react-i18next'

export default function Step({
  className = '',
  title = '',
  text = '',
  children = [],
  onNext,
  nextText,

  hideButton,
  btnDisabled,
  buttonSecondary,
  step,
  stepMax = 0
}) {
  const { t } = useTranslation()
  return (
    <>
      <div className={`step__container ${className}`}>
        {step && (
          <span className="step__index">
            Schritt {step} / {stepMax}
          </span>
        )}

        <div className="step__content">
          {title && <h2>{title}</h2>}
          {text && <p>{text}</p>}
          {children}
        </div>
        {buttonSecondary}
        {!hideButton && (
          <Button className="btn--next" disabled={btnDisabled} onClick={onNext}>
            {nextText || t('next')}
          </Button>
        )}
      </div>
    </>
  )
}
