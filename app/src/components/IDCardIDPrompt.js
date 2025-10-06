import React, { useState, useMemo } from 'react'
import WarningIcon from 'assets/icons/ic_warning.svg'
import Button from 'components/Button'
import Prompt from 'components/Prompt'

import Checkbox from './Checkbox'
import { Trans, useTranslation } from 'react-i18next'
import { useSelector } from 'react-redux'

export default function IDCardIDPrompt({ show, onClick, onClickBack }) {
  const { t } = useTranslation()
  const [checked, setChecked] = useState(false)
  const { email } = useSelector(({ base }) => base.userdata)

  const render = useMemo(() => {
    const raw = window.localStorage.getItem('_hdx:idcardprompt') || '{}'
    const data = JSON.parse(raw)
    return !data[email]
  }, [email])

  const preClick = () => {
    if (!checked) return
    try {
      const raw = window.localStorage.getItem('_hdx:idcardprompt') || '{}'
      const data = JSON.parse(raw)
      data[email] = checked
      window.localStorage.setItem('_hdx:idcardprompt', JSON.stringify(data))
    } catch (e) {
      console.error(e)
    }
  }

  return render ? (
    <Prompt
      shadow
      icon={<WarningIcon />}
      direction={show ? 'center' : 'right'}
      title={t('auth__prompt__idcardid__title')}
      subtitle={t('auth__prompt__idcardid__subtitle')}
      content={
        <>
          <p style={{ textAlign: 'start' }}>
            <Trans i18nKey="auth__prompt__idcardid__text">
              homeDX bietet nun die Möglichkeit eine Ausweis- oder Passnummer zu
              hinterlegen, um Ihnen die Reise ins Ausland noch einfacher zu
              gestalten.{' '}
              <strong>
                Um Ihre Nummer hinzuzufügen müssen Sie eine neue
                Authentifizierung (inkl. Test) starten.
              </strong>
            </Trans>
          </p>
          <Checkbox
            className="list__item"
            wrapperClassName="alt"
            label={t('auth__prompt__idcardid__checkbox')}
            onChange={ev => setChecked(ev.target.checked)}
          />
        </>
      }
      button={
        <Button
          onClick={() => {
            preClick()
            onClick && onClick()
          }}>
          <Trans i18nKey="auth__prompt__idcardid__btn_auth">
            Zur Authentifizierung
          </Trans>
        </Button>
      }
      buttonSecondary={
        <Button
          className="ghost"
          onClick={() => {
            preClick()
            onClickBack && onClickBack()
          }}>
          <Trans i18nKey="auth__prompt__idcardid__btn_skip">Überspringen</Trans>
        </Button>
      }
    />
  ) : (
    <></>
  )
}
