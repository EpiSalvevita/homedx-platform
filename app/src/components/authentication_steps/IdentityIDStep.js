import React, { useEffect, useState, useCallback } from 'react'
import { useDispatch } from 'react-redux'

import Button from 'components/Button'
import Step from 'components/Step'

import { useMatomo } from '@datapunt/matomo-tracker-react'
import { Trans, useTranslation } from 'react-i18next'
import TextInput from 'components/TextInput'
import Prompt from 'components/Prompt'

export default function IdentityIDStep({ onNext }) {
  const { t } = useTranslation()
  const dispatch = useDispatch()

  const [id, setId] = useState('')
  const [isShowConfirm, setIsShowConfirm] = useState(false)

  const { trackPageView } = useMatomo()

  useEffect(() => {
    trackPageView({
      documentTitle: 'IdentityID'
    })
    return () => {}
  }, [])

  const next = useCallback(() => {
    dispatch({ type: 'setIdentityID', identityID: id })
    onNext && onNext()
  }, [dispatch, id, onNext])

  const showConfirm = () => {
    setIsShowConfirm(true)
  }

  const skip = () => {
    onNext && onNext()
  }

  return (
    <Step onNext={skip} nextText={t('skip')} step={1} stepMax={4}>
      <h2>
        <Trans i18nKey="auth__step__id_id__title">
          Bitte geben Sie Ihre Ausweis- oder Passnummer an
        </Trans>
      </h2>
      <p>
        <Trans i18nKey="auth__step__id_id__text">
          Diese Angabe ist optional. Wenn sie die Nummer hinterlegen, wird Sie
          auf dem Testzertifikat ausgegeben. Dies ist auf Reisen oftmals
          Pflicht.
        </Trans>
      </p>
      <img
        style={{ marginBottom: 15 }}
        className={`step__image`}
        alt="result"
        src={`${process.env.ASSETS_PATH}/assets/Muster_Perso_Vorne_Markiert.png`}
      />
      <TextInput
        style={{ flexShrink: 0 }}
        className="alt"
        label={t('idcard__id')}
        placeholder={t('idcard__id')}
        value={id}
        onChange={text => setId(text)}
      />
      <div style={{ flex: 1 }}></div>
      <Button style={{ marginBottom: 15 }} onClick={showConfirm}>
        <Trans i18nKey="next">Weiter</Trans>
      </Button>
      <Prompt
        direction={isShowConfirm ? 'center' : 'right'}
        title={t('confirm')}
        subtitle={id}
        text={t('idcard__id_id__prompt__text')}
        button={
          <Button onClick={next}>
            <Trans i18nKey="next">Weiter</Trans>
          </Button>
        }
        buttonSecondary={
          <Button onClick={() => setIsShowConfirm(false)} className="ghost">
            <Trans i18nKey="edit">Korrigieren</Trans>
          </Button>
        }
      />
    </Step>
  )
}
