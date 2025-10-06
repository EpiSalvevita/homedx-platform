import React from 'react'
import BottomSheet from 'components/BottomSheet'
import { useTranslation } from 'react-i18next'
import CheckIcon from 'assets/icons/ic_check-accent.svg'

export default function CommentBottomSheet({ data, openSheet, onClose }) {
  const { t } = useTranslation()
  return (
    <BottomSheet
      title={t('comments')}
      className={openSheet === 'comments' ? 'open' : ''}
      onClose={onClose}>
      <div className="row">
        <div className="col-12">
          <div className={`result__check`}>
            {data?.result === 'negative' && (
              <ul>
                <li
                  className={`${
                    data?.flags?.checkedIdentity ? '' : 'deactivated'
                  }`}>
                  <div className="result__check__icon">
                    <CheckIcon className="ic-check" />
                  </div>
                  <span>{t('certificate__check_identity')}</span>
                </li>
                <li
                  className={`${
                    data?.flags?.certifiedTestDevice ? '' : 'deactivated'
                  }`}>
                  <div className="result__check__icon">
                    <CheckIcon className="ic-check" />
                  </div>
                  <span>{t('certificate__check_test')}</span>
                </li>
                <li
                  className={`${
                    data?.flags?.correctUsage ? '' : 'deactivated'
                  }`}>
                  <div className="result__check__icon">
                    <CheckIcon className="ic-check" />
                  </div>
                  <span>{t('certificate__check_application')}</span>
                </li>
                <li
                  className={`${
                    data?.flags?.confirmedResult ? '' : 'deactivated'
                  }`}>
                  <div className="result__check__icon">
                    <CheckIcon className="ic-check" />
                  </div>
                  <span>{t('certificate__check_result')}</span>
                </li>
              </ul>
            )}
          </div>
        </div>
      </div>
      <div className="row">
        <div className="col-12">
          <ul className="bottomsheet__list">
            <li className="bottomsheet__list__item">
              <div className="value">{data?.comment}</div>
            </li>
          </ul>
        </div>
      </div>
    </BottomSheet>
  )
}
