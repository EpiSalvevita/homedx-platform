import React, { useState, useRef, useEffect } from 'react'
import BottomSheet from 'components/BottomSheet'

import { useMatomo } from '@datapunt/matomo-tracker-react'

import Step from 'components/Step'
import MouthIcon from 'assets/icons/ic_mouth.svg'
import NoseIcon from 'assets/icons/ic_nose.svg'
import SwapBufferIcon from 'assets/icons/ic_swapbuffer.svg'
import CassetteIcon from 'assets/icons/ic_cassette.svg'
import { Trans, useTranslation } from 'react-i18next'

const Cell = ({ icon, title, centered, onClick, offset }) => (
  <div
    onClick={onClick}
    className={`new-test__components__grid__cell ${centered ? 'centered' : ''}`}
    style={{ bottom: `${offset}px` }}>
    <div className="new-test__components__grid__cell__icon">{icon}</div>
    <div className="new-test__components__grid__cell__label">{title}</div>
  </div>
)

export default function TutorialStep({ onNext }) {
  const { t } = useTranslation()
  const [centered, setCentered] = useState(0)
  const bottomsheetRef = useRef(null)
  const [bottomSheetHeight, setBottomSheetHeight] = useState(0)

  const { trackPageView } = useMatomo()

  useEffect(() => {
    trackPageView({
      documentTitle: `Tutorial`
    })
    return () => {}
  }, [])

  useEffect(() => {
    const { height } = bottomsheetRef.current.getBoundingClientRect()
    setBottomSheetHeight(height)

    if (centered > 0)
      bottomsheetRef.current.style.top = `calc(100% - ${height}px)`
    else bottomsheetRef.current.style.top = `100vh`
    return () => {}
  }, [centered])

  return (
    <Step
      className="new-test__tutorial"
      title={t('test__tutorial__title')}
      onNext={onNext}
      buttonSecondary={
        <div
          style={{
            width: 100 + '%',
            display: 'flex',
            justifyContent: 'center',
            alignItems: 'center',
            marginTop: 15,
            marginBottom: 15
          }}>
          <a
            className="btn outline--alt "
            style={{
              paddingTop: 15,
              paddingBottom: 15,
              paddingLeft: 0,
              paddingRight: 0,
              boxSizing: 'border-box',
              width: 100 + '%',
              color: '#fff'
            }}
            href="/video-tutorial"
            target="_blank"
            rel="noopener noreferrer">
            {t('test__tutorial__btn2')}
          </a>
        </div>
      }>
      <p>{t('test__tutorial__content__text_intro')}</p>
      <h3>{t('test__tutorial__content__title')}</h3>
      <p>
        <Trans i18nKey="test__tutorial__content__text">
          Um eine maximale Sensitivität zu erzielen
          <strong>empfehlen wir dringend</strong> wie hier beschrieben, einen
          Kombinationsabstrich im Mund- und Nasenraum durchzuführen. Sie
          erhalten aber auch bei korrekter Durchführung eines Einzelabstriches
          im Mund- oder Nasenraum ein gültiges Zertifikat
        </Trans>
      </p>
      <div className="new-test__components__grid__wrapper">
        <div className="new-test__components__grid">
          <Cell
            onClick={() => setCentered(1)}
            centered={centered === 1}
            icon={<MouthIcon />}
            title={t('test__tutorial__cell__throat__title')}
            offset={bottomSheetHeight}
          />
          <Cell
            onClick={() => setCentered(2)}
            centered={centered === 2}
            icon={<NoseIcon />}
            title={t('test__tutorial__cell__nose__title')}
            offset={bottomSheetHeight}
          />
          <Cell
            onClick={() => setCentered(3)}
            centered={centered === 3}
            icon={<SwapBufferIcon />}
            title={t('test__tutorial__cell__swab__title')}
            offset={bottomSheetHeight}
          />
          <Cell
            onClick={() => setCentered(4)}
            centered={centered === 4}
            icon={<CassetteIcon />}
            title={t('test__tutorial__cell__cassette__title')}
            offset={bottomSheetHeight}
          />
        </div>
      </div>
      <BottomSheet
        peek
        ref={bottomsheetRef}
        title={
          centered === 1
            ? t('test__tutorial__cell__throat__title')
            : centered === 2
            ? t('test__tutorial__cell__nose__title')
            : centered === 3
            ? t('test__tutorial__cell__swab__title')
            : centered === 4
            ? t('test__tutorial__cell__cassette__title')
            : ''
        }
        backType="close"
        onClose={() => setCentered(0)}
        style={{ height: bottomSheetHeight }}
        className={`no-bottombar ${centered > 0 ? 'open' : ''}`}>
        {centered === 1 && (
          <ul className="list">
            <li className="list__item">
              {t('test__tutorial__cell__throat__li1')}
            </li>
            <li className="list__item">
              {t('test__tutorial__cell__throat__li2')}
            </li>
            <li className="list__item">
              {t('test__tutorial__cell__throat__li3')}
            </li>
            <li className="list__item">
              {t('test__tutorial__cell__throat__li4')}
            </li>
          </ul>
        )}
        {centered === 2 && (
          <ul className="list">
            <li className="list__item">
              {t('test__tutorial__cell__nose__li1')}
            </li>
            <li className="list__item">
              <Trans i18nKey="test__tutorial__cell__nose__li2">
                Führen Sie den Tupfer entlang des unteren, mittleren Teils der
                Nasenmuschel gerade bis zur hinteren Rachenwand.
                <strong>
                  Verwenden Sie beim Kombinationsabstrich denselben Tupfer wie
                  für den Rachenabstrich.
                </strong>
              </Trans>
            </li>
            <li className="list__item">
              {t('test__tutorial__cell__nose__li3')}
            </li>
          </ul>
        )}

        {centered === 3 && (
          <ul className="list">
            <li className="list__item">
              {t('test__tutorial__cell__swab__li1')}
            </li>
            <li className="list__item">
              {t('test__tutorial__cell__swab__li2')}
            </li>

            <li className="list__item">
              {t('test__tutorial__cell__swab__li3')}
            </li>
          </ul>
        )}
        {centered === 4 && (
          <ul className="list">
            <li className="list__item">
              {t('test__tutorial__cell__cassette__li1')}
            </li>
            <li className="list__item">
              {t('test__tutorial__cell__cassette__li2')}
            </li>
            <li className="list__item">
              {t('test__tutorial__cell__cassette__li3')}
            </li>
            <li className="list__item">
              {t('test__tutorial__cell__cassette__li4')}
            </li>
          </ul>
        )}
      </BottomSheet>
    </Step>
  )
}
