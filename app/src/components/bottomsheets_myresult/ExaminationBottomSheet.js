import React, { useMemo } from 'react'
import { useMutation } from '@apollo/client'
import { useSelector } from 'react-redux'
import { Trans, useTranslation } from 'react-i18next'

import BottomSheet from 'components/BottomSheet'
import Button from 'components/Button'

import { isExpired } from 'Utility'
import { DOWNLOAD_CERTIFICATE_PDF } from 'services/graphql'

export default function ExaminationBottomSheet({ data, openSheet, onClose }) {
  const { t } = useTranslation()
  const { qrdata } = useSelector(({ test }) => test)
  const { backendStatus } = useSelector(({ base }) => base)

  const [downloadCertificatePdf] = useMutation(DOWNLOAD_CERTIFICATE_PDF, {
    onCompleted: (data) => {
      try {
        if (data.downloadCertificatePdf.pdf) {
          const url = window.URL.createObjectURL(data.downloadCertificatePdf.pdf)
          const a = document.createElement('a')
          a.href = url
          a.download = 'zertifikat.pdf'
          document.body.appendChild(a)
          a.click()
          a.remove()
        } else {
          console.error('no pdf found')
        }
      } catch (e) {
        console.error(e)
      }
    }
  })

  const testDate = useMemo(() => data?.testDate * 1000 || 0, [data?.testDate])

  const showPDF = useMemo(
    () =>
      backendStatus.certificatePdf &&
      !isExpired(testDate) &&
      (data?.result === 'negative' || data?.result === 'positive'),
    [backendStatus.certificatePdf, data?.result, testDate]
  )

  return (
    <>
      <BottomSheet
        title={t('examination')}
        className={openSheet === 'exam' ? 'open' : ''}
        onClose={onClose}>
        <div className="row">
          <div className="col-12">
            <ul className="bottomsheet__list no-seperators examination ">
              {data?.licenseCode && (
                <li className="bottomsheet__list__item">
                  <span className="label">{t('examinationcode')}</span>
                  <div className="value">{data?.licenseCode}</div>
                </li>
              )}
              <li className="exam__qr__wrapper bottomsheet__list__item">
                <span className="label">BärCODE</span>
                <div className="value">{t('scan_baercode')}</div>
                <div className="value">
                  {!!qrdata && data?.result === 'negative' && (
                    <div style={{ width: 100 + '%', height: 'auto' }}>
                      <img
                        src={`data:image/png;format=baercodev1;base64,${qrdata}`}
                        alt="qrcode"
                      />
                    </div>
                  )}
                  {!qrdata && <div>{t('no_baercode')}</div>}
                </div>
                {/* {!!qrdata && (
                  <div className="value">
                    <a
                      target="_blank"
                      className="btn"
                      href={`https://app.luca-app.de/webapp/testresult/#${qrdata}`}
                      rel="noreferrer">
                      {t('import_luca')}
                    </a>
                  </div>
                )} */}

                {showPDF && (
                  <div className="value">
                    <Button className="btn ghost" onClick={() => downloadCertificatePdf()}>
                      <Trans i18nKey="download__pdf">PDF herunterladen</Trans>
                    </Button>
                  </div>
                )}
              </li>
            </ul>
          </div>
        </div>
      </BottomSheet>
    </>
  )
}
