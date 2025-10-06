import React, { useState, useEffect, useCallback } from 'react'
import { useQuery } from '@apollo/client'
import { useSelector } from 'react-redux'
import { useHistory } from 'react-router-dom'
import { Trans, useTranslation } from 'react-i18next'

import Step from 'components/Step'
import Prompt from 'components/Prompt'
import Button from 'components/Button'

import { GET_PAYMENT_AMOUNT } from 'services/graphql'

export default function PaymentStep({
  onSelectedCoupon,
  onSelectedPayment,
  setLoading
}) {
  const history = useHistory()
  const { t } = useTranslation()
  const { backendStatus } = useSelector(({ base }) => base)
  const [showPrompt, setShowPrompt] = useState(false)

  const { data: amountData, loading } = useQuery(GET_PAYMENT_AMOUNT, {
    skip: !backendStatus.stripe,
    onCompleted: () => {
      setLoading && setLoading(false)
      setShowPrompt(true)
    }
  })

  useEffect(() => {
    if (!backendStatus.stripe) {
      setLoading && setLoading(false)
      setShowPrompt(true)
    }
    return () => {}
  }, [backendStatus.stripe, setLoading])

  const next = cb => {
    setShowPrompt(false)
    setTimeout(cb, 300)
  }

  const getCalculatedAmountString = useCallback(() => {
    if (!amountData?.paymentAmount) return '0,00'

    const amount = amountData.paymentAmount
    if (amount.discountType) {
      if (amount.discountType === 'cent') {
        return `${toPrice(
          (amount.reducedAmount || amount.amount - amount.discount) / 100
        )}€`
      } else {
        return `${toPrice(
          (amount.reducedAmount || amount.amount - amount.discount) / 100
        )}€`
      }
    }

    return `${toPrice((amount.reducedAmount || amount.amount) / 100)}€`
  }, [amountData])

  const toPrice = p => p.toFixed(2).replace('.', ',')

  useEffect(() => {
    if (backendStatus.stripe && !loading) {
      const amountElement = document.querySelector('span.payment__amount')
      if (amountElement) {
        amountElement.innerHTML = getCalculatedAmountString()
      }
    }
    return () => {}
  }, [amountData, backendStatus.stripe, getCalculatedAmountString, loading])

  return (
    <>
      <Step hideButton>
        <Prompt
          direction={showPrompt ? 'center' : 'right'}
          title={t('payment__step__title')}
          content={
            backendStatus.stripe ? (
              <Trans i18nKey="payment__step__text__payment">
                Sollten Sie einen Coupon haben können Sie diesen im nächsten
                Schritt einlösen. Besitzen Sie jedoch keinen Coupon, können Sie
                am Ende des Tests online bezahlen.
                <strong>
                  Ein Testdurchlauf kostet{' '}
                  <span className="payment__amount">{getCalculatedAmountString()}</span>
                  (inkl. MwSt.)
                </strong>
              </Trans>
            ) : (
              <Trans i18nKey="payment__step__text__coupon">
                Sollten Sie einen Coupon haben können Sie diesen im nächsten
                Schritt einlösen. Besitzen Sie jedoch keinen Coupon, können Sie
                diesen an der Rezeption Ihres Hotels anfragen
              </Trans>
            )
          }
          button={
            <Button onClick={() => next(onSelectedCoupon)}>
              <Trans i18nKey="payment__step__btn__coupon">
                Zur Couponeinlösung
              </Trans>
            </Button>
          }
          buttonSecondary={
            <Button
              className="ghost"
              onClick={
                backendStatus.stripe
                  ? () => next(onSelectedPayment)
                  : () => history.goBack()
              }>
              {backendStatus.stripe ? (
                <Trans i18nKey="payment__step__btn_no_coupon">
                  Weiter ohne Coupon
                </Trans>
              ) : (
                <Trans i18nKey="btn__back">Zurück</Trans>
              )}
            </Button>
          }
        />
      </Step>
    </>
  )
}
