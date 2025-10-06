import React from 'react'
import Button from './Button'
import Prompt from './Prompt'

import WarningIcon from 'assets/icons/ic_warning.svg'
import { useTranslation } from 'react-i18next'

export default function AuthenticationPrompt({
  onClick,
  onClickSecondary,
  show
}) {
  const { t } = useTranslation()
  return (
    <Prompt
      icon={<WarningIcon />}
      direction={show ? 'center' : 'right'}
      title={t('prompt__data__title')}
      text={t('prompt__data__text')}
      button={<Button onClick={onClick}>{t('prompt__data__btn')}</Button>}
      buttonSecondary={
        <Button className="ghost" onClick={onClickSecondary}>
          {t('later')}
        </Button>
      }
    />
  )
}
