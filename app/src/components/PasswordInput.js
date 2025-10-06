import React, { useEffect, useState } from 'react'
import zxcvbn from 'zxcvbn'
import TextInput from './TextInput'

import HideIcon from 'assets/icons/ic_password_hide.svg'
import ShowIcon from 'assets/icons/ic_password_show.svg'
import { useTranslation } from 'react-i18next'

export default function PasswordInput({
  onChange,
  userInput,
  required,
  showAsRequired,
  isValid
}) {
  const [password, setPassword] = useState('')
  const [score, setScore] = useState(0)
  const [showPassword, setShowPassword] = useState(false)
  const { t } = useTranslation()

  useEffect(() => {
    let { score } = zxcvbn(password, userInput)
    if (!isValid && score > 3) score = 3
    setScore(score)
    return () => {}
  }, [password, userInput, isValid])

  const getColor = score => {
    if (score === 0 || score === 1) {
      return ''
    }
    if (score === 2) {
      return 'normal'
    }
    if (score === 3) {
      return 'mid'
    }
    if (score === 4 && isValid) {
      return 'strong'
    }
  }

  return (
    <div>
      <div className="password__wrapper">
        <TextInput
          showAsRequired={showAsRequired}
          required={required}
          className="password alt"
          type={showPassword ? 'text' : 'password'}
          placeholder={t('password')}
          onChange={val => {
            setPassword(val)
            onChange && onChange(val)
          }}
        />
        <div
          className="password__info"
          onClick={() => setShowPassword(!showPassword)}>
          <div className={`password__strength`}>
            {score < 4 ? t('password__too_weak') : t('password__very_strong')}
          </div>
          <div className="password__hint">
            {!showPassword ? <HideIcon /> : <ShowIcon />}
          </div>
        </div>
        <div className="password__strength__indicator">
          <div
            style={{ width: `${(score / 4) * 100}%` }}
            className={`password__strength__indicator--inner ${getColor(
              score
            )}`}></div>
        </div>
      </div>
    </div>
  )
}
