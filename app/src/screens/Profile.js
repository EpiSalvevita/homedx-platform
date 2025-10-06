import React, { useEffect, useState, useCallback, useMemo } from 'react'
import { useDispatch, useSelector } from 'react-redux'
import { useQuery, useLazyQuery } from '@apollo/client'
import QRCode from 'react-qr-code'
import { useMatomo } from '@datapunt/matomo-tracker-react'
import { Trans, useTranslation } from 'react-i18next'

import BottomSheet from 'components/BottomSheet'
import LoadingView from 'components/LoadingView'
import { GET_LAST_RAPID_TEST, GET_CWA_LINK } from 'services/graphql'

export default function Profile() {
  const { t } = useTranslation()
  const dispatch = useDispatch()

  const [cwaLink, setCWALink] = useState(null)
  const [isLoading, setIsLoading] = useState(true)
  const [isError, setIsError] = useState(false)
  const [showProfile, setShowProfile] = useState(false)
  
  const backendStatus = useSelector(({ base }) => base.backendStatus)
  const user = useSelector(({ base }) => base.userdata)
  const { lastRapidtest = {} } = useSelector(({ test }) => test || {})

  const { trackPageView } = useMatomo()

  const { refetch: refetchLastRapidTest } = useQuery(GET_LAST_RAPID_TEST, {
    onCompleted: (data) => {
      if (data.lastRapidTest) {
        dispatch({
          type: 'setLastRapidTest',
          lastRapidTest: data.lastRapidTest
        })
      } else {
        dispatch({ type: 'setLastRapidTest', lastRapidTest: {} })
      }
    }
  })

  const [getCWALink] = useLazyQuery(GET_CWA_LINK, {
    variables: { rapidTestId: lastRapidtest?.id },
    onCompleted: (data) => {
      if (data.cwaLink) {
        setCWALink(data.cwaLink)
      } else {
        setIsError(true)
      }
      setIsLoading(false)
    },
    onError: () => {
      setIsError(true)
      setIsLoading(false)
    }
  })

  useEffect(() => {
    trackPageView({
      documentTitle: 'Profile'
    })
    return () => {}
  }, [])

  useEffect(() => {
    lastRapidtest && setShowProfile(true)
    return () => {
      setShowProfile(false)
    }
  }, [lastRapidtest])

  useEffect(() => {
    refetchLastRapidTest()
    return () => {}
  }, [refetchLastRapidTest])

  useEffect(() => {
    if (lastRapidtest && lastRapidtest.agreementGiven) {
      getCWALink()
    }
    return () => {}
  }, [getCWALink, lastRapidtest])

  const testDate = useMemo(
    () => new Date(lastRapidtest?.testDate * 1000).toLocaleString(),
    [lastRapidtest?.testDate]
  )

  return (
    <div className="screen-profile">
      <BottomSheet
        canGoBack
        hideSpacer
        className={showProfile ? 'open' : ''}
        title={t('profile__title')}>
        {user.clientText?.length > 0 && (
          <p style={{ opacity: 0.6 }}>{user.clientText}</p>
        )}

        {lastRapidtest?.agreementGiven !== 'none' &&
          ((backendStatus.cwaLaive && lastRapidtest?.result === 'negative') ||
            backendStatus.cwa) && (
            <>
              <h3 style={{ textAlign: 'start', marginTop: 15 }}>
                <Trans i18nKey="cwa__name">Corona Warn App</Trans>
              </h3>
              {true && (
                <strong>
                  <small style={{ padding: '5px 0' }}>
                    <Trans i18nKey="cwa__last_test_date">Letzer Test:</Trans>
                    <span>{testDate?.substring(0, testDate?.length - 3)}</span>
                  </small>
                </strong>
              )}

              {!!lastRapidtest?.agreementGiven && (
                <p style={{ paddingBottom: 10, opacity: 0.6 }}>
                  <small>
                    <Trans
                      i18nKey={`cwa__agreement_given_${lastRapidtest.agreementGiven}`}>
                      Sie haben ihren Test pseudonymisiert an die Corona Warn
                      App gesendet.
                    </Trans>
                  </small>
                </p>
              )}

              {cwaLink && (
                <>
                  <div className="row">
                    <div className="col-12">
                      <div className="bottomsheet__list">
                        <div
                          style={{
                            width: 100 + '%',
                            height: 'auto',
                            padding: '10px 0'
                          }}>
                          <div
                            style={{
                              fontSize: 12,
                              marginTop: 10,
                              opacity: 0.6
                            }}>
                            <Trans i18nKey="cwa__transfer__title_qr">
                              Übertragung per QR-Code
                            </Trans>
                          </div>
                          <small style={{ marginBottom: 10 }}>
                            <Trans i18nKey="cwa__transfer__text_qr">
                              Sie sind nicht mit Ihrem Smartphone eingeloggt?
                              Dann scannen Sie den folgenden QR-Code mit Ihrem
                              Smartphone.
                            </Trans>
                          </small>
                          <div style={{ margin: '0 auto' }}>
                            {isLoading && <LoadingView />}
                            {!isLoading && !isError && (
                              <QRCode value={cwaLink} />
                            )}
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                  <div
                    className="row"
                    style={{ marginTop: 15, justifyContent: 'center' }}>
                    <div className="col-12">
                      <div
                        className="bottomsheet__list"
                        style={{ paddingTop: 10, paddingBottom: 10 }}>
                        <div
                          style={{
                            fontSize: 12,
                            marginTop: 10,
                            opacity: 0.6
                          }}>
                          <Trans i18nKey="cwa__transfer__title_link">
                            Automatische Übertragung
                          </Trans>
                        </div>
                        <div style={{ marginBottom: 10 }}>
                          <small>
                            <Trans i18nKey="cwa__transfer__text_link">
                              Sie sind mit dem Smartphone eingeloggt? Dann
                              verwenden Sie den Link.
                            </Trans>
                          </small>
                        </div>
                        {isLoading && (
                          <div style={{ margin: '0 auto' }}>
                            <LoadingView />
                          </div>
                        )}
                        {!isLoading && !isError && (
                          <a className="btn" href={cwaLink}>
                            <Trans i18nKey="cwa__transfer_link">
                              In Corona Warn App übertragen
                            </Trans>
                          </a>
                        )}
                      </div>
                    </div>
                  </div>
                </>
              )}
            </>
          )}
      </BottomSheet>
    </div>
  )
}
