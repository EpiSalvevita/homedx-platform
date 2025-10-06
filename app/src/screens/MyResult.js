import React, { useEffect, useState, useCallback } from 'react'
import { useSelector, useDispatch } from 'react-redux'
import { useHistory } from 'react-router'
import { useQuery, useLazyQuery } from '@apollo/client'
import { useMatomo } from '@datapunt/matomo-tracker-react'
import { useTranslation } from 'react-i18next'
import i18next from 'i18next'
import useInterval from 'useInterval'

import PlaceholderImg from 'assets/icons/ic_profile.svg'
import CaretIcon from 'assets/icons/ic_caret.svg'
import BadgeIcon from 'assets/icons/ic_badge.svg'

import ResultLoader from 'base/ResultLoader'
import PersonalDataBottomSheet from 'components/bottomsheets_myresult/PersonalDataBottomSheet'
import ExaminationBottomSheet from 'components/bottomsheets_myresult/ExaminationBottomSheet'
import CommentBottomSheet from 'components/bottomsheets_myresult/CommentBottomSheet'
import AuthenticationPrompt from 'components/AuthenticationPrompt'
import NegativeResultView from 'components/certificate/NegativeResultView'
import PositiveResultView from 'components/certificate/PositiveResultView'
import DeclinedResultView from 'components/certificate/DeclinedResultView'
import PendingResultView from 'components/certificate/PendingResultView'
import CertificateDetailMenu from 'components/certificate/CertificateDetailMenu'
import EmptyCertificateView from 'components/certificate/EmptyCertificateView'
import Toggle from 'components/LanguageToggle'
import ChangeCertificateLanguageBottomSheet from 'components/bottomsheets_myresult/ChangeCertificateLanguageBottomSheet'
import ContentHeader from 'components/ContentHeader'

import { GET_USER_DATA, GET_LAST_RAPID_TEST, GET_PROFILE_IMAGE } from 'services/graphql'

export default function MyResult() {
  const dispatch = useDispatch()
  const history = useHistory()
  const { t } = useTranslation()

  const lastRapidTest = useSelector(({ test }) => test.lastRapidtest)
  const userData = useSelector(({ base }) => base.userdata)
  const { profilePhoto, storedProfileImageLastModified } = useSelector(
    ({ auth }) => auth
  )

  const [isLoading, setIsLoading] = useState(true)
  const [showDetail, setShowDetail] = useState(false)
  const { trackPageView } = useMatomo()
  const [isShowAuthenticationAlert, setIsShowAuthenticationAlert] = useState(false)
  const [openSheet, setOpenSheet] = useState('')
  const [certificateLng, setCertificateLng] = useState('de')

  const { refetch: refetchUserData } = useQuery(GET_USER_DATA, {
    onCompleted: (data) => {
      if (data.me) {
        dispatch({ type: 'setUserdata', userdata: data.me })

        if (data.me.profileImageLastModified) {
          if (
            data.me.profileImageLastModified * 1000 >
            storedProfileImageLastModified
          ) {
            getProfilePhoto(data.me.profileImageLastModified * 1000)
          }
        }
      }
    }
  })

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

  const [getProfilePhoto] = useLazyQuery(GET_PROFILE_IMAGE, {
    onCompleted: (data) => {
      if (data.profileImage) {
        dispatch({
          type: 'setProfilePhoto',
          photo: `data:image/jpg;base64,${data.profileImage}`,
          lastModified: Date.now()
        })
      } else {
        dispatch({
          type: 'setProfilePhoto',
          photo: null,
          lastModified: Date.now()
        })
      }
    }
  })

  const reload = useCallback(async () => {
    await refetchLastRapidTest()
    await refetchUserData()
  }, [refetchLastRapidTest, refetchUserData])

  useEffect(() => {
    setCertificateLng(i18next.language)
    dispatch({ type: 'showTopbar', showTopbar: true })
    dispatch({ type: 'showBottombar', showBottombar: true })
    reload()
    return () => {}
  }, [dispatch, reload])

  useEffect(() => {
    if (!userData || !lastRapidTest) {
      dispatch({ type: 'isLoading', isLoading: true })
    }
    if (lastRapidTest && userData) {
      setIsLoading(false)
      dispatch({ type: 'isLoading', isLoading: false })
    }
    return () => {}
  }, [lastRapidTest, userData, dispatch])

  useInterval(() => {
    reload()
  }, 30000)

  useEffect(() => {
    trackPageView({
      documentTitle: 'Certificate'
    })
    return () => {}
  }, [trackPageView])

  const openDetails = open => {
    setShowDetail(open)
  }

  const setOpenSheetWithDelay = key => {
    dispatch({ type: 'showTopbar', showTopbar: key === '' })
    openDetails(false)
    setOpenSheet(key)
  }

  const getSurveySlug = useCallback(() => {
    switch (userData?.clientId) {
      case 1: // schnelltest2021homedx
      case 2: // Berlin-Mitte-Pilot-2021
      case 3: // Gastrotest
        return 'evaluationsbogen-berlin'
      case 4: // Diagnostiknet
      default:
        return null
    }
  }, [userData.clientId])

  const goBack = () => {
    history.goBack()
  }

  return (
    <div className={`screen-my-result`}>
      <ContentHeader 
        showTitle={true}
        onBack={goBack}
        title={t('my_result__title')}
      />
      
      {isLoading && <ResultLoader />}
      {!lastRapidTest ||
        (Object.keys(lastRapidTest).length === 0 && <EmptyCertificateView />)}
      {lastRapidTest && Object.keys(lastRapidTest).length > 0 && (
        <div
          className={`refresh-content ${!isLoading ? 'show' : ''}`}
          onClick={showDetail ? () => openDetails(false) : () => {}}>
          <div
            className="row"
            style={{
              position: 'relative',
              alignItems: 'center',
              justifyContent: 'center'
            }}>
            <div className="col" style={{ flex: 1, flexShrink: 1 }}></div>
            <div className="col" style={{ flex: 1, flexShrink: 1 }}>
              <div className="profile-image">
                {profilePhoto ? (
                  <img src={profilePhoto} alt="profile" />
                ) : (
                  <PlaceholderImg />
                )}
              </div>
            </div>
            <div className="col" style={{ flex: 1, flexShrink: 1 }}>
              <div className="language-toggle">
                <Toggle
                  value={certificateLng}
                  onChange={lng => {
                    setCertificateLng(lng)
                    setOpenSheetWithDelay('language')
                  }}
                />
              </div>
            </div>
          </div>

          {lastRapidTest.result === 'negative' && (
            <NegativeResultView
              lastRapidTest={lastRapidTest}
              showDetail={showDetail}
              onShowDetail={openDetails}
            />
          )}
          {lastRapidTest.result === 'positive' && (
            <PositiveResultView
              lastRapidTest={lastRapidTest}
              showDetail={showDetail}
              onShowDetail={openDetails}
            />
          )}
          {lastRapidTest.result === 'declined' && (
            <DeclinedResultView
              lastRapidTest={lastRapidTest}
              showDetail={showDetail}
              onShowDetail={openDetails}
            />
          )}
          {!lastRapidTest.result && (
            <PendingResultView
              lastRapidTest={lastRapidTest}
              showDetail={showDetail}
              onShowDetail={openDetails}
            />
          )}

          {showDetail && (
            <CertificateDetailMenu
              onOpenSheet={setOpenSheetWithDelay}
              lastRapidTest={lastRapidTest}
            />
          )}
        </div>
      )}

      <PersonalDataBottomSheet
        open={openSheet === 'personal'}
        onClose={() => setOpenSheetWithDelay('')}
      />
      <ExaminationBottomSheet
        open={openSheet === 'examination'}
        onClose={() => setOpenSheetWithDelay('')}
      />
      <CommentBottomSheet
        open={openSheet === 'comment'}
        onClose={() => setOpenSheetWithDelay('')}
      />
      <ChangeCertificateLanguageBottomSheet
        open={openSheet === 'language'}
        onClose={() => setOpenSheetWithDelay('')}
        language={certificateLng}
      />

      {isShowAuthenticationAlert && (
        <AuthenticationPrompt
          show={true}
          onClick={() => history.push('/change-account-data')}
          onClickSecondary={() => setIsShowAuthenticationAlert(false)}
        />
      )}
    </div>
  )
}
