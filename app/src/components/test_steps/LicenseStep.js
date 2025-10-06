import React, { useState, useRef, useEffect } from 'react'
import { useQuery } from '@apollo/client'
import { useSelector } from 'react-redux'
import { useMatomo } from '@datapunt/matomo-tracker-react'
import { useTranslation } from 'react-i18next'

import Step from 'components/Step'
import LicenseCodeRow from 'components/LicenseCodeRow'
import LoadingView from 'components/LoadingView'

import { GET_LICENSES } from 'services/graphql'

export default function LicenseStep({ onNext }) {
  const { t } = useTranslation()
  const { capRapidTestAddWithoutLicense } = useSelector(
    ({ base }) => base?.userdata
  )

  const { data: { licenses } = {}, loading } = useQuery(GET_LICENSES)
  const inputRef = useRef(null)
  const [selectedCode, setSelectedCode] = useState('')

  const { trackPageView } = useMatomo()

  const selectLicenseCode = () => {
    onNext && onNext(selectedCode)
  }

  useEffect(() => {
    if (capRapidTestAddWithoutLicense) {
      onNext && onNext('')
    } else if (licenses) {
      const firstLicense = Object.values(licenses)[0]
      onNext && onNext(firstLicense?.licenseKey || '')
    }
    return () => {}
  }, [capRapidTestAddWithoutLicense, licenses, onNext])

  useEffect(() => {
    trackPageView({ documentTitle: 'License' })
    return () => {}
  }, [trackPageView])

  useEffect(() => {
    !capRapidTestAddWithoutLicense && inputRef.current && (inputRef.current.value = selectedCode)
    return () => {}
  }, [selectedCode, capRapidTestAddWithoutLicense])

  if (loading) {
    return <LoadingView />
  }

  const availableLicenses = licenses ? Object.entries(licenses).filter(
    ([key, code]) => code.maxUses === 0 || code.maxUses - code.usesCount > 0
  ) : []

  return (
    <>
      {!capRapidTestAddWithoutLicense && (
        <Step
          className="new-test__license"
          title={t('test__license__title')}
          text={t('test__license__text')}
          onNext={selectLicenseCode}
          nextText={t('test__license__btn')}
          btnDisabled={selectedCode.length === 0}>
          <div className="new-test__license__input__wrapper">
            <span className="new-test__license__input__title">
              {t('test__license__label')}
            </span>
            <input
              readOnly
              ref={inputRef}
              className="new-test__license__input"
              placeholder="XXXX-XXXX-XXXX-XXXX-XXXX-XXXX"
              value={selectedCode}
            />
          </div>
          <h2>{t('test__license__subtitle')}</h2>
          <div className="new-test__license__list">
            <div className="new-test__license__list__spacer"></div>
            {availableLicenses.map(([key, code]) => (
              <LicenseCodeRow
                key={code.licenseKey}
                onClick={() => setSelectedCode(code.licenseKey)}
                code={code}
                active={code.licenseKey === selectedCode}
              />
            ))}
            <div className="new-test__license__list__spacer"></div>
          </div>
        </Step>
      )}
    </>
  )
}
