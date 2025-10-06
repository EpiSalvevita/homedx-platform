import React, { useState, useEffect, useCallback, useMemo } from 'react'
import { useMutation, useQuery } from '@apollo/client'
import {
  CardElement,
  IbanElement,
  PaymentRequestButtonElement,
  useStripe,
  useElements
} from '@stripe/react-stripe-js'
import { useDispatch, useSelector } from 'react-redux'
import { useTranslation, Trans } from 'react-i18next'

import Step from 'components/Step'
import Prompt from 'components/Prompt'
import Button from 'components/Button'
import PaymentMethodSwitcher from 'components/PaymentMethodSwitcher'
import LoadingView from 'components/LoadingView'
import TextInput from 'components/TextInput'

import ErrorIcon from 'assets/icons/ic_error.svg'
import SuccessIcon from 'assets/icons/ic_success.svg'

import { GET_PAYMENT_AMOUNT, CREATE_PAYMENT_INTENT } from 'services/graphql'

export default function CheckoutStep({ onSuccess }) {
  const dispatch = useDispatch()
  const { t } = useTranslation()
  const stripe = useStripe()
  const elements = useElements()

  const [isLoading, setIsLoading] = useState(false)
  const [paymentMethod, setPaymentMethod] = useState(null)
  const [showMessage, setShowMessage] = useState(false)
  const [isSuccess, setIsSuccess] = useState(false)
  const [paymentRequest, setPaymentRequest] = useState(null)
  const [paymentId, setPaymentId] = useState(null)
  const [canMakePayment, setCanMakePayment] = useState(false)
  const [isComplete, setIsComplete] = useState(false)
  const [clientSecret, setClientSecret] = useState('')
  const [name, setName] = useState('')
  const [email, setEmail] = useState('')

  const { userdata } = useSelector(({ base }) => base)

  const { data: amountData } = useQuery(GET_PAYMENT_AMOUNT)

  const [createPaymentIntent] = useMutation(CREATE_PAYMENT_INTENT, {
    onCompleted: (data) => {
      if (data.createPaymentIntent.success) {
        setClientSecret(data.createPaymentIntent.secret)
        return data.createPaymentIntent.secret
      }
      return false
    }
  })

  useEffect(() => {
    setName(`${userdata.firstname} ${userdata.lastname}`)
    setEmail(userdata.email)
    return () => {}
  }, [userdata])

  useEffect(() => {
    if (!amountData?.paymentAmount) return

    const amount = amountData.paymentAmount
    const paymentRequest = stripe.paymentRequest({
      country: 'DE',
      currency: 'eur',
      total: {
        label: 'SARS CoV-2 Online-Test',
        amount: amount?.reducedAmount || amount?.amount
      }
    })
    setPaymentRequest(paymentRequest)
    paymentRequest
      .canMakePayment()
      .then(result => {
        if (result) {
          setCanMakePayment(true)
        }
      })
      .catch(e => console.log(e))
    return () => {}
  }, [amountData, stripe])

  useEffect(() => {
    const listener = async ev => {
      const { data } = await createPaymentIntent()
      const secret = data?.createPaymentIntent?.secret

      const { paymentIntent, error: confirmError } =
        await stripe.confirmCardPayment(
          secret,
          { payment_method: ev.paymentMethod.id },
          { handleActions: false }
        )
      setIsLoading(true)
      if (confirmError) {
        ev.complete('fail')
        setIsSuccess(false)
        setShowMessage(true)
        console.log(confirmError)
      } else {
        ev.complete('success')
        if (paymentIntent.status === 'requires_action') {
          const { error } = await stripe.confirmCardPayment(clientSecret)
          if (error) {
            setIsSuccess(false)
            setShowMessage(true)
            console.log(error)
          } else {
            setPaymentId(paymentIntent.id)
            setIsSuccess(true)
            setShowMessage(true)
            trackConversion()
          }
        } else {
          setPaymentId(paymentIntent.id)
          setIsSuccess(true)
          setShowMessage(true)
          trackConversion()
        }
      }
      setIsLoading(false)
    }

    if (paymentRequest) {
      paymentRequest.on('paymentmethod', listener)
    }
    return () => {
      if (paymentRequest) {
        paymentRequest.off('paymentmethod', listener)
      }
    }
  }, [stripe, paymentRequest, clientSecret, createPaymentIntent, trackConversion])

  useEffect(() => {
    setIsComplete(false)

    const element =
      elements.getElement(IbanElement) || elements.getElement(CardElement)
    if (!element) {
      console.error('stripe: no payment option?')
      return
    }

    element.on('change', data => {
      setIsComplete(data.complete)
    })
    return () => {}
  }, [elements, paymentMethod])

  const pay = async () => {
    paymentMethod === 'sepa_debit' && paySEPA()
    paymentMethod === 'card' && payCard()
  }

  const payCard = useCallback(async () => {
    const { data } = await createPaymentIntent()
    const secret = data?.createPaymentIntent?.secret

    if (secret) {
      setIsLoading(true)
      stripe
        .confirmCardPayment(secret, {
          payment_method: {
            card: elements.getElement(CardElement)
          }
        })
        .then(function (result) {
          if (result.error) {
            setIsSuccess(false)
            setShowMessage(true)
            console.log(result.error.message)
          } else {
            setPaymentId(result.paymentIntent.id)
            setIsSuccess(true)
            setShowMessage(true)
            trackConversion()
          }
          setIsLoading(false)
        })
    }
  }, [createPaymentIntent, elements, stripe, trackConversion])

  const paySEPA = useCallback(async () => {
    const { data } = await createPaymentIntent()
    const secret = data?.createPaymentIntent?.secret

    if (secret) {
      setIsLoading(true)
      stripe
        .confirmSepaDebitPayment(secret, {
          payment_method: {
            sepa_debit: elements.getElement(IbanElement),
            billing_details: {
              email: email,
              name: name
            }
          }
        })
        .then(function (result) {
          if (result.error) {
            setIsSuccess(false)
            setShowMessage(true)
            console.log(result.error.message)
          } else {
            setPaymentId(result.paymentIntent.id)
            setIsSuccess(true)
            setShowMessage(true)
            trackConversion()
          }
          setIsLoading(false)
        })
    }
  }, [createPaymentIntent, elements, stripe, trackConversion, name, email])

  const next = () => {
    dispatch({ type: 'setPaymentId', paymentId })
    onSuccess && onSuccess()
  }

  const trackConversion = useCallback(() => {
    if (process.env.ENV === 'prod') {
      // eslint-disable-next-line no-undef
      gtag('event', 'conversion', {
        send_to: 'AW-10798735005/_e9UCN3G7IogDEJ29np0o'
      })
    }
  }, [])

  const isTrackable = useMemo(
    () =>
      !userdata?.capRapidTestAddWithoutLicense && userdata.clientId !== null,
    [userdata?.capRapidTestAddWithoutLicense, userdata.clientId]
  )

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

  return (
    <>
      <Step
        text={
          <Trans i18nKey="test__buy__text">
            Bitte bezahlen Sie den Testvorgang bevor Sie die Leistung in
            Anspruch nehmen können. Geben Sie dazu entweder Ihre Bezahldaten an
            oder nutzen Sie einen der verfügbaren Bezahl-Dienstleister.
          </Trans>
        }
        nextText={
          isComplete
            ? `${t('test__buy__btn')} (${getCalculatedAmountString()})`
            : isLoading
            ? t('loading')
            : paymentMethod === 'sepa_debit'
            ? t('test__buy__invalid_sepa_debit')
            : t('test__buy__invalid_card')
        }
        onNext={amountData?.paymentAmount && pay}
        btnDisabled={
          isLoading ||
          !isComplete ||
          !paymentRequest ||
          name.length === 0 ||
          email.length === 0
        }>
        {!amountData?.paymentAmount && (
          <div
            style={{
              display: 'flex',
              justifyContent: 'center',
              alignItems: 'center',
              flex: 1
            }}>
            <LoadingView />
          </div>
        )}
        {amountData?.paymentAmount && (
          <div>
            <p>
              <strong>
                <Trans ns="covid" i18nKey="test__buy__content__text">
                  Die Kosten für die Anspruchnahme eines einzelnen Testablaufs
                  sind <span>{getCalculatedAmountString()}</span> (inkl.
                  MwSt.)
                </Trans>
              </strong>
            </p>
            <PaymentMethodSwitcher
              methods={[
                {
                  label: t('payment__method__card'),
                  value: 'card'
                }
              ]}
              onSwitched={method => {
                setPaymentMethod(method)
              }}
            />
            <div
              className={`pmswitcher__wrapper ${
                paymentMethod !== 'card' ? 'rounded' : ''
              }`}>
              {paymentMethod === 'card' && (
                <div style={{ padding: 15 }}>
                  <CardElement
                    options={{
                      style: {
                        base: {
                          iconColor: 'white',
                          fontSize: '16px',
                          color: 'white',
                          '::placeholder': {
                            color: 'white'
                          },
                          padding: '16px'
                        },
                        invalid: {
                          color: 'white',
                          iconColor: 'white'
                        }
                      }
                    }}
                  />
                </div>
              )}

              {paymentMethod === 'sepa_debit' && (
                <div style={{ padding: 15 }}>
                  <TextInput
                    className="alt"
                    placeholder="Name"
                    value={name}
                    onChange={name => setName(name)}
                  />
                  <TextInput
                    className="alt"
                    placeholder="Email"
                    value={email}
                    onChange={email => setEmail(email)}
                  />
                  <div
                    style={{
                      padding: 15,
                      backgroundColor: 'rgba(255,255,255,.2)',
                      borderRadius: 10,
                      border: 'solid 1px white'
                    }}>
                    <IbanElement
                      options={{
                        supportedCountries: ['SEPA'],
                        iconStyle: 'solid',
                        style: {
                          base: {
                            fontSize: '16px',
                            color: 'white',
                            '::placeholder': {
                              color: 'white'
                            },
                            iconColor: 'white'
                          },
                          invalid: {
                            color: 'white',
                            iconColor: 'white'
                          }
                        }
                      }}
                    />
                  </div>
                </div>
              )}
            </div>

            {canMakePayment && (
              <h3 style={{ marginTop: 15, marginBottom: 15 }}>
                {t('payment__method__additional')}
              </h3>
            )}

            {paymentRequest && canMakePayment && (
              <PaymentRequestButtonElement
                onReady={() => {}}
                options={{
                  paymentRequest,
                  style: {
                    paymentRequestButton: {
                      theme: 'light'
                    }
                  }
                }}
              />
            )}
          </div>
        )}
      </Step>
      <Prompt
        direction={showMessage ? 'center' : 'right'}
        title={
          isSuccess
            ? t('payment__prompt__title_success')
            : t('payment__prompt__title_error')
        }
        text={
          isSuccess
            ? t('payment__prompt__text_success')
            : t('payment__prompt__text_error')
        }
        icon={isSuccess ? <SuccessIcon /> : <ErrorIcon />}
        button={
          isSuccess ? (
            <Button onClick={next}>{t('btn__continue')}</Button>
          ) : (
            <Button onClick={() => setShowMessage(false)}>
              {t('btn__retry')}
            </Button>
          )
        }
      />
    </>
  )
}
