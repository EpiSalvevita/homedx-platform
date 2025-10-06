import React, { useEffect } from 'react'
import { Trans, useTranslation } from 'react-i18next'
import InfoIcon from 'assets/icons/ic_info.svg'
import { useSelector } from 'react-redux'
import Checkbox from 'components/Checkbox'
import TextInput from 'components/TextInput'
import Button from 'components/Button'
import { useLocation } from 'react-router'

export default function TokenView({
  showTokenTip,
  registrationToken,
  setRegistrationToken,
  showToken,
  setShowToken,
  isLoading,
  setAcceptedLegal,
  acceptedLegal,
  setAcceptedTerms,
  acceptedTerms,
  onNext
}) {
  const { t } = useTranslation()
  const { backendStatus } = useSelector(({ base }) => base)
  const code = useLocation()

  useEffect(() => {
    setTimeout(() => {
      // wont update properly without the timeout
      if (code?.hash) {
        setShowToken(true)
        setRegistrationToken(code?.hash.replace('#', ''))
      }
    }, 0)
  }, [code?.hash, setRegistrationToken, setShowToken])

  return (
    <div style={{ flex: 1, justifyContent: 'flex-end' }}>
      <h1>
        <Trans i18nKey="signup__token__title1">Token & Zustimmung</Trans>
      </h1>
      <p>
        <Trans i18nKey="signup__token__text1">
          Sie nutzen einen Token? Dann können Sie Ihn hier angeben. Andernfalls
          benötigen wir nur Ihre Zustimmung zu unseren Datenschutzhinweisen und
          den AGB.
        </Trans>
      </p>
      <div className="row">
        <div className="col-12">
          <div className="row">
            {backendStatus.paymentIsActive && (
              <div className="col-12">
                <Checkbox
                  label={t('signup__token__checkbox')}
                  onChange={e => setShowToken(e.target.checked)}
                  value={showToken}
                />
              </div>
            )}
          </div>
          <div className="row">
            <div className="col-10">
              {((showToken || !backendStatus.paymentIsActive) && (
                <TextInput
                  showAsRequired={!backendStatus.paymentIsActive}
                  required={!backendStatus.paymentIsActive}
                  className="alt"
                  type="text"
                  placeholder={t('signup__placeholder__token')}
                  value={registrationToken}
                  onChange={val => setRegistrationToken(val)}
                />
              )) || (
                <small style={{ marginLeft: 41, opacity: 0.6 }}>
                  {!backendStatus.stripe && (
                    <Trans i18nKey="signup__token__hint_coupon">
                      Wenn Sie einen Coupon (QR-Code) haben, können Sie ohne
                      Token mit der Registrierung fortfahren
                    </Trans>
                  )}
                  {backendStatus.stripe && (
                    <Trans i18nKey="signup__token__hint_payment">
                      Ohne Token ist der Kauf von Lizenzen notwendig.
                    </Trans>
                  )}
                </small>
              )}
            </div>
            {(showToken || !backendStatus.paymentIsActive) && (
              <div className="col-2 password__show" onClick={showTokenTip}>
                <InfoIcon />
              </div>
            )}
          </div>
        </div>
      </div>
      <div className="row">
        <div className="col-12">
          <Checkbox
            id="legal"
            required
            onChange={ev => !isLoading && setAcceptedLegal(ev.target.checked)}
            label={
              <div style={{ display: 'inline' }}>
                <Trans i18nKey="signup__check_privacy">
                  Ich bin damit einverstanden, dass die homeDX GmbH meine
                  personenbezogenen Daten, insbesondere die Daten über meine
                  Gesundheit, wie in den
                  <a
                    href="/privacy-policy"
                    target="_blank"
                    rel="noopener noreferrer">
                    Datenschutzhinweisen
                  </a>
                  beschrieben, verarbeitet. <br /> Diese Einwilligung kann ich
                  jederzeit für die Zukunft widerrufen *
                </Trans>
              </div>
            }
          />
        </div>
        <div className="col-12">
          <Checkbox
            id="terms"
            required
            onChange={ev => !isLoading && setAcceptedTerms(ev.target.checked)}
            label={
              <Trans i18nKey="signup__check_legal">
                Ich habe die
                <a
                  href="/terms"
                  target="_blank"
                  rel="noopener noreferrer">
                  AGB
                </a>
                gelesen und akzeptiert *
              </Trans>
            }
          />
        </div>
      </div>
      <div className="row">
        <div className="col-12">
          <Button
            disabled={
              isLoading ||
              !acceptedTerms ||
              !acceptedLegal ||
              (showToken && registrationToken.length < 3)
            }
            onClick={onNext}>
            {(!isLoading && <Trans i18nKey="next">Weiter</Trans>) || (
              <Trans i18nKey="loading">Lädt...</Trans>
            )}
          </Button>
        </div>
      </div>
    </div>
  )
}
