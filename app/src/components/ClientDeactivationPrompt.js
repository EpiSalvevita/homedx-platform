import React, { useState, useMemo } from 'react'
import WarningIcon from 'assets/icons/ic_warning.svg'
import Button from 'components/Button'
import Prompt from 'components/Prompt'

import Checkbox from './Checkbox'
import { Trans, useTranslation } from 'react-i18next'
import { useSelector } from 'react-redux'

export default function ClientDeactivationPrompt({ show, onClick }) {
  const { t } = useTranslation()
  const [checked, setChecked] = useState(false)
  const { email } = useSelector(({ base }) => base.userdata)

  const render = useMemo(() => {
    const raw = window.localStorage.getItem('_hdx:clientdeactivation') || '{}'
    const data = JSON.parse(raw)
    return !data[email]
  }, [email])

  const preClick = () => {
    if (!checked) return
    try {
      const raw = window.localStorage.getItem('_hdx:clientdeactivation') || '{}'
      const data = JSON.parse(raw)
      data[email] = checked
      window.localStorage.setItem(
        '_hdx:clientdeactivation',
        JSON.stringify(data)
      )
    } catch (e) {
      console.error(e)
    }
  }

  return render ? (
    <Prompt
      shadow
      icon={<WarningIcon />}
      direction={show ? 'center' : 'right'}
      title={'Bevorstehende Deaktivierung'}
      subtitle={
        'Das Registierungstoken Ihrer Anmeldung wird am 01.09.2021 deaktiviert.'
      }
      content={
        <>
          <p style={{ textAlign: 'start' }}>
            <Trans>
              <strong>
                Eine erneute Registierung mit einer anderen Email-Addresse ist
                möglich. Melden Sie sich dazu ohne Token Angabe an.
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
          className="ghost"
          onClick={() => {
            preClick()
            onClick && onClick()
          }}>
          <Trans i18nKey="">Schließen</Trans>
        </Button>
      }
    />
  ) : (
    <></>
  )
}
