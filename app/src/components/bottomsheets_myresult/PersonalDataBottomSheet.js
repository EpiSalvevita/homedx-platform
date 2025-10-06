import React from 'react'
import BottomSheet from 'components/BottomSheet'
import { useSelector } from 'react-redux'
import PlaceholderImg from 'assets/icons/ic_profile.svg'
import { useTranslation } from 'react-i18next'

export default function PersonalDataBottomSheet({ data, openSheet, onClose }) {
  const { t } = useTranslation()
  const { profilePhoto } = useSelector(({ auth }) => auth)

  const getDateString = time => {
    return new Date(time * 1000).toLocaleDateString()
  }

  return (
    <BottomSheet
      title={t('personal_data')}
      className={openSheet === 'personal' ? 'open' : ''}
      onClose={onClose}>
      <div className="row">
        <div className="col-12">
          <ul className="bottomsheet__list no-seperators">
            <div className="bottomsheet__avatar">
              {!profilePhoto && <PlaceholderImg className="result__image" />}
              {profilePhoto && (
                <img
                  className="result__image"
                  src={profilePhoto}
                  alt="profilephoto"
                />
              )}
            </div>
            {(data?.firstname || data?.lastname) && (
              <li className="bottomsheet__list__item">
                <span className="label">
                  {t('firstname')}, {t('lastname')}
                </span>
                <div className="value">
                  {data?.firstname} {data?.lastname}
                </div>
              </li>
            )}
            {data?.gender && (
              <li className="bottomsheet__list__item">
                <span className="label">{t('gender')}</span>
                <div className="value">
                  {data?.gender === 'female'
                    ? 'weiblich'
                    : data?.gender === 'male'
                    ? 'männlich'
                    : 'divers'}
                </div>
              </li>
            )}
            {data?.dob && (
              <li className="bottomsheet__list__item">
                <span className="label">{t('dob')}</span>
                <div className="value">{getDateString(data?.dob)}</div>
              </li>
            )}
            {data?.address1 && (
              <li className="bottomsheet__list__item">
                <span className="label">
                  {t('street')}, {t('house_num')}.
                </span>
                <div className="value">{data?.address1}</div>
              </li>
            )}
            {data?.postcode && (
              <li className="bottomsheet__list__item">
                <span className="label">
                  {t('zip')}, {t('city')}
                </span>
                <div className="value">
                  {data?.postcode} {data?.city}
                </div>
              </li>
            )}
            {data?.country && (
              <li className="bottomsheet__list__item">
                <span className="label">{t('country')}</span>
                <div className="value">{data?.country}</div>
              </li>
            )}
            {data?.phone && (
              <li className="bottomsheet__list__item">
                <span className="label">{t('phone')}</span>
                <div className="value">{data?.phone}</div>
              </li>
            )}
            {data?.email && (
              <li className="bottomsheet__list__item">
                <span className="label">{t('email')}</span>
                <div className="value">{data?.email}</div>
              </li>
            )}
          </ul>
        </div>
      </div>
    </BottomSheet>
  )
}
