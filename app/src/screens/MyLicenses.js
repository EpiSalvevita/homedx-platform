import React from 'react'
import { useQuery } from '@apollo/client'
import { useTranslation } from 'react-i18next'

import BottomSheet from 'components/BottomSheet'
import LoadingView from 'components/LoadingView'

import { GET_LICENSES } from 'services/graphql'

export default function MyLicenses() {
  const { t } = useTranslation()
  const { data: { licenses } = {}, loading, error } = useQuery(GET_LICENSES)

  const availableLicenses = licenses ? Object.entries(licenses).filter(
    ([id, license]) => license.usesCount < license.maxUses
  ) : []

  return (
    <div className="screen-mylicenses">
      <BottomSheet
        title={t('licenses__title')}
        className="open no-bottombar"
        canGoBack>
        <div className="row">
          <div className="col-12">
            {loading && <LoadingView />}
            
            {!loading && error && (
              <div className="licenses__error">
                <p>{t('licenses__error_text', 'Error loading licenses')}</p>
              </div>
            )}
            
            {!loading && !error && availableLicenses.length > 0 && (
              <>
                <h3 className="licenses__subtitle">{t('licenses__available')}</h3>
                {availableLicenses.map(([id, license]) => (
                  <div className="my-licenses__row" key={id}>
                    <div className="license__info">
                      <span className="code">{license.licenseKey}</span>
                      <span className="status">{license.status}</span>
                    </div>
                    <div className="license__usage">
                      <span className="charges">
                        {license.maxUses - license.usesCount}x {t('licenses__remaining')}
                      </span>
                      <span className="used">
                        {license.usesCount}x {t('licenses__used')}
                      </span>
                    </div>
                  </div>
                ))}
              </>
            )}
            
            {!loading && !error && availableLicenses.length === 0 && (
              <div className="licenses__empty">
                <h3>{t('licenses__empty_title')}</h3>
                <p>{t('licenses__empty_text')}</p>
                <div className="licenses__empty_actions">
                  <p className="licenses__empty_hint">
                    {t('licenses__empty_hint', 'Contact your administrator or purchase a license to get started.')}
                  </p>
                </div>
              </div>
            )}
          </div>
        </div>
      </BottomSheet>
    </div>
  )
}
