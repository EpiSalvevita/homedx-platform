import React, { useState, useEffect, useCallback, useMemo } from 'react'
import { useHistory } from 'react-router'
import { useDispatch, useSelector } from 'react-redux'
import { useQuery } from '@apollo/client'
import { Trans, useTranslation } from 'react-i18next'

import ErrorIcon from 'assets/icons/ic_error.svg'
import CloseButton from 'components/CloseButton'
import Prompt from 'components/Prompt'
import LoadingView from 'components/LoadingView'
import AuthenticationPrompt from 'components/AuthenticationPrompt'
import PaymentStep from 'components/test_steps/PaymentStep'
import CouponStep from 'components/test_steps/CouponStep'
import Button from 'components/Button'

import { GET_LICENSES } from 'services/graphql'
import { CREATE_PAYMENT } from 'services/graphql'

export default function Payment() {
  const dispatch = useDispatch()
  const { t } = useTranslation()
  const history = useHistory()
  const [isLoading, setIsLoading] = useState(true)
  const [showCoupon, setShowCoupon] = useState(false)
  const userdata = useSelector(({ base }) => base.userdata)
  const backendStatus = useSelector(({ base }) => base.backendStatus)

  const getAvailableLicense = useMemo(
    () => licenses => {
      return Object.values(licenses).filter(c => c.maxUses - c.usesCount > 0)[0]?.licenseKey
    },
    []
  )

  const { data: licensesData } = useQuery(GET_LICENSES, {
    skip: userdata.capRapidTestAddWithoutLicense,
    onCompleted: (data) => {
      if (userdata.capRapidTestAddWithoutLicense) {
        next()
        return
      }

      const licenseCode = getAvailableLicense(data.licenses)

      if (licenseCode) {
        dispatch({ type: 'setLicenseCode', licenseCode })
        next()
        return
      }
      setIsLoading(false)
    }
  })

  const next = useCallback(() => {
    dispatch({ type: 'setIsPayedFor', isPayedFor: true })
    history.replace('/new-test')
  }, [dispatch, history])

  const goBack = () => {
    history.goBack()
  }

  const addPaymentMethod = paymentMethod => {
    dispatch({ type: 'setPaymentMethod', paymentMethod })
    paymentMethod !== 'coupon' ? next() : setShowCoupon(true)
  }

  const declineTest = useMemo(() => {
    let declineTest = false

    console.log('Payment declineTest check:', {
      hasClientId: !!userdata.clientId,
      clientActive: userdata.clientActive,
      clientContigentConsumed: userdata.clientContigentConsumed,
      paymentIsActive: backendStatus.paymentIsActive,
      backendStatus
    });

    if (!!userdata.clientId) {
      declineTest = userdata.clientContigentConsumed || !userdata.clientActive
    } else {
      declineTest = !backendStatus.paymentIsActive
    }

    console.log('Payment declineTest result:', declineTest);
    return declineTest
  }, [
    backendStatus,
    userdata.clientActive,
    userdata.clientContigentConsumed,
    userdata.clientId
  ])

  return (
    <>
      {!isLoading && (
        <>
          {declineTest && (
            <>
              <Prompt
                icon={<ErrorIcon />}
                direction={'center'}
                title={t('client__locked__prompt__title')}
                text={t('client__locked__prompt__message')}
                button={
                  <Button className="ghost" onClick={() => history.goBack()}>
                    <Trans i18nKey="btn__back">Zurück</Trans>
                  </Button>
                }
              />
            </>
          )}
          {!declineTest && !userdata.additonalUserDataSubmitted && (
            <>
              <AuthenticationPrompt
                show={true}
                onClick={() => history.push('/change-account-data')}
                onClickSecondary={() => history.goBack()}
              />
            </>
          )}
          {!declineTest &&
            userdata.additonalUserDataSubmitted &&
            !userdata.capRapidTestAddWithoutLicense && (
              <>
                <div className={`screen-payment ${''}`}>
                  <div className="payment__header">
                    <h3 className="payment__header__title">
                      <Trans i18nKey="payment__title">
                        Zahlungsmethode festlegen
                      </Trans>
                    </h3>
                    <CloseButton onClick={goBack} />
                  </div>

                  {!showCoupon && (
                    <PaymentStep
                      onSelectedCoupon={() => addPaymentMethod('coupon')}
                      onSelectedPayment={() => addPaymentMethod('payment')}
                    />
                  )}
                  {showCoupon && (
                    <CouponStep
                      onNext={licenseCode => {
                        dispatch({ type: 'setLicenseCode', licenseCode })
                        next()
                      }}
                    />
                  )}
                </div>
              </>
            )}
        </>
      )}
      {isLoading && (
        <div
          style={{
            position: 'absolute',
            top: 0,
            right: 0,
            bottom: 0,
            left: 0,
            justifyContent: 'center',
            alignItems: 'center'
          }}>
          <LoadingView />
        </div>
      )}
    </>
  )
}
