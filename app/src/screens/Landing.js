import React, { useEffect } from 'react'
import { useDispatch } from 'react-redux'
import Button from 'components/Button'

import CheckIcon from 'assets/icons/ic_check.svg'
import Logo from 'assets/icons/ic_logo.svg'
import ApplePay from 'assets/logos/applepay.png'
import GPay from 'assets/logos/googlepay.png'
import MasterCard from 'assets/logos/mastercard.png'
import Visa from 'assets/logos/visa.png'
import Sepa from 'assets/logos/sepa.png'

import { useTranslation } from 'react-i18next'

export default function Landing() {
  const dispatch = useDispatch()
  const { t } = useTranslation()

  useEffect(() => {
    dispatch({ type: 'isLoading', isLoading: false })
    
    return () => {}
  }, [dispatch])

  const handleLoginClick = () => {
    window.location.href = '/login';
  };

  const handleSignupClick = () => {
    window.location.href = '/signup';
  };

  return (
    <div className="screen-landing">
      <Logo className="landing__icon" />
      <h1>{t('landing__title')}</h1>
      
      <ul className="list">
        <li className="list__item">
          <CheckIcon /> {t('landing__subtitle1')}
        </li>
        <li className="list__item">
          <CheckIcon /> {t('landing__subtitle2')}
        </li>
        <li className="list__item">
          <CheckIcon /> {t('landing__subtitle3')}
        </li>
        <li className="list__item">
          <CheckIcon /> {t('landing__subtitle4')}
        </li>
      </ul>
      <div className="row mb-md">
        <div className="col-1"></div>
        <div className="col-2">
          <img
            src={MasterCard}
            alt="mastercard"
            className="landing__paymentmethod"
          />
        </div>
        <div className="col-2">
          <img src={Visa} alt="visa" className="landing__paymentmethod" />
        </div>
        <div className="col-2">
          <img
            src={ApplePay}
            alt="applepay"
            className="landing__paymentmethod"
          />
        </div>
        <div className="col-2">
          <img src={GPay} alt="googlepay" className="landing__paymentmethod" />
        </div>
        <div className="col-2">
          <img src={Sepa} alt="sepa" className="landing__paymentmethod" />
        </div>
        <div className="col-1"></div>
      </div>
      <div className="row">
        <div className="col-6">
          <Button 
            className="btn__login outline" 
            onClick={handleLoginClick}>
            {t('login')}
          </Button>
        </div>
        <div className="col-6">
          <Button 
            className="btn__signup" 
            onClick={handleSignupClick}>
            {t('signup')}
          </Button>
        </div>
      </div>
      <div className="landing__links">
        <div className="row">
          <a
            className="landing__link--privacy"
            href="/privacy-policy"
            target="_blank"
            rel="noopener noreferrer">
            {t('landing__privacy_policy')}
          </a>
          <span className="landing__link--seperator">{'|'}</span>
          <a
            className="landing__link--privacy"
            href="/impressum"
            target="_blank"
            rel="noopener noreferrer">
            {t('landing__impressum')}
          </a>
        </div>
      </div>
    </div>
  )
}
