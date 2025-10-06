import React, { useState, useCallback } from 'react'
import Step from 'components/Step'
import { Trans, useTranslation } from 'react-i18next'
import Prompt from 'components/Prompt'
import Button from 'components/Button'

export default function CWAStep({ onCWAChoiceMade }) {
  const [choice, setChoice] = useState(null)
  const [showWarning, setShowWarning] = useState(false)
  const { t } = useTranslation()

  const onChoiceMade = useCallback(() => {
    if (choice === 'without') {
      setShowWarning(true)
    } else {
      onCWAChoiceMade && onCWAChoiceMade(choice)
    }
  }, [choice, onCWAChoiceMade])

  return (
    <>
      <Step
        title="Corona Warn App"
        text="Bitte wählen Sie, ob Ihr Testergebnis an die Corona Warn App übermittelt werden soll."
        nextText={!choice ? t('please_choose') : t('next')}
        onNext={onChoiceMade}
        btnDisabled={!choice}>
        <div className="col">
          <div className="row" style={{ marginBottom: 5 }}>
            <div className="col-2">
              <input
                type="radio"
                name="cwa"
                id="none"
                onChange={() => setChoice('none')}
              />
            </div>
            <div className="col-10">
              <label htmlFor="none">
                <Trans>
                  <h4>Keine Übermittlung an Corona Warn App</h4>
                </Trans>
              </label>
            </div>
          </div>
          <div className="row" style={{ marginBottom: 5 }}>
            <div className="col-2">
              <input
                type="radio"
                name="cwa"
                id="without"
                onChange={() => setChoice('without')}
              />
            </div>
            <div className="col-10">
              <label htmlFor="without">
                <h4>
                  <Trans>
                    EINWILLIGUNG ZUR PSEUDONYMISIERTEN ÜBERMITTLUNG
                    (NICHT-NAMENTLICHE ANZEIGE)
                  </Trans>
                </h4>
                <p style={{ fontSize: 14 }}>
                  <Trans>
                    Hiermit erkläre ich mein Einverständnis zum Übermitteln
                    meines Testergebnisses und meines pseudonymen Codes an das
                    Serversystem des RKI, damit ich mein Testergebnis mit der
                    Corona-Warn-App abrufen kann. Das Testergebnis in der App
                    kann hierbei nicht als namentlicher Testnachweis verwendet
                    werden. Mir wurden Hinweise zum{' '}
                    <a
                      href="https://www.homedx.de/datenschutz-app#cwa"
                      target="_blank"
                      rel="noreferrer">
                      Datenschutz
                    </a>{' '}
                    ausgehändigt.
                  </Trans>
                </p>
              </label>
            </div>
          </div>
          <div className="row" style={{ marginBottom: 5 }}>
            <div className="col-2">
              <input
                type="radio"
                name="cwa"
                id="with"
                onChange={() => setChoice('with')}
              />
            </div>
            <div className="col-10">
              <label htmlFor="with">
                <h4>
                  <Trans>
                    EINWILLIGUNG ZUR PERSONALISIERTEN ÜBERMITTLUNG (NAMENTLICHER
                    TESTNACHWEIS)
                  </Trans>
                </h4>
                <p style={{ fontSize: 14 }}>
                  <Trans>
                    Hiermit erkläre ich mein Einverständnis zum Übermitteln des
                    Testergebnisses und meines pseudonymen Codes an das
                    Serversystem des RKI, damit ich mein Testergebnis mit der
                    Corona-Warn-App abrufen kann. Ich willige außerdem in die
                    Übermittlung meines Namens und Geburtsdatums an die App ein,
                    damit mein Testergebnis in der App als namentlicher
                    Testnachweis angezeigt werden kann. Mir wurden Hinweise zum{' '}
                    <a
                      href="https://www.homedx.de/datenschutz-app#cwa"
                      target="_blank"
                      rel="noreferrer">
                      Datenschutz
                    </a>{' '}
                    ausgehändigt.
                  </Trans>
                </p>
              </label>
            </div>
          </div>
        </div>
      </Step>
      <Prompt
        direction={showWarning ? 'center' : 'right'}
        title={t('Sind Sie sicher?')}
        text={t(
          'Bei einer Übertragung ohne persönliche Daten ist es <strong>NICHT</strong> möglich ein EU-Zertifikat zu erstellen'
        )}
        button={
          <Button onClick={() => onCWAChoiceMade('without')}>
            Verstanden, weiter
          </Button>
        }
        buttonSecondary={
          <Button className="ghost" onClick={() => setShowWarning(false)}>
            Zurück
          </Button>
        }
      />
    </>
  )
}
