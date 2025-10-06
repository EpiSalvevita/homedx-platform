import React, { useEffect } from 'react'
import { useSelector, useDispatch } from 'react-redux'
import { useHistory } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { useMatomo } from '@datapunt/matomo-tracker-react'

import Button from 'components/Button'
import ContentHeader from 'components/ContentHeader'

// Import available icons
import TestIcon from 'assets/icons/ic_new.svg'
import ProfileIcon from 'assets/icons/ic_profile.svg'
import AccountIcon from 'assets/icons/ic_account.svg'
import ResultIcon from 'assets/icons/ic_my-result.svg'
import BadgeIcon from 'assets/icons/ic_badge.svg'
import InfoIcon from 'assets/icons/ic_info.svg'
import SuccessIcon from 'assets/icons/ic_success.svg'
import CheckIcon from 'assets/icons/ic_check.svg'

export default function Dashboard() {
  const { t } = useTranslation()
  const history = useHistory()
  const dispatch = useDispatch()
  const { trackPageView } = useMatomo()
  
  const userdata = useSelector(({ base }) => base.userdata)

  useEffect(() => {
    dispatch({ type: 'showTopbar', showTopbar: true })
    dispatch({ type: 'showBottombar', showBottombar: true })
    dispatch({ type: 'isLoading', isLoading: false })
    
    trackPageView({
      documentTitle: 'Dashboard'
    })
    
    return () => {}
  }, [dispatch, trackPageView])

  const navigateTo = (path) => {
    history.push(path)
  }

  const goBack = () => {
    history.goBack()
  }

  const dashboardItems = [
    {
      key: 'new-test',
      title: t('dashboard__new_test'),
      subtitle: t('dashboard__new_test_subtitle'),
      icon: TestIcon,
      path: '/new-test',
      className: 'primary'
    },
    {
      key: 'my-result',
      title: t('dashboard__my_result'),
      subtitle: t('dashboard__my_result_subtitle'),
      icon: ResultIcon,
      path: '/my-result'
    },
    {
      key: 'my-licenses',
      title: t('dashboard__my_licenses'),
      subtitle: t('dashboard__my_licenses_subtitle'),
      icon: BadgeIcon,
      path: '/my-licenses'
    },
    {
      key: 'authentication',
      title: t('dashboard__authentication'),
      subtitle: t('dashboard__authentication_subtitle'),
      icon: SuccessIcon,
      path: '/authentication'
    },
    {
      key: 'payment',
      title: t('dashboard__payment'),
      subtitle: t('dashboard__payment_subtitle'),
      icon: CheckIcon,
      path: '/payment'
    },
    {
      key: 'profile',
      title: t('dashboard__profile'),
      subtitle: t('dashboard__profile_subtitle'),
      icon: ProfileIcon,
      path: '/profile'
    },
    {
      key: 'my-account',
      title: t('dashboard__my_account'),
      subtitle: t('dashboard__my_account_subtitle'),
      icon: AccountIcon,
      path: '/my-account'
    }
  ]

  return (
    <div className="screen-dashboard">
      <ContentHeader 
        showTitle={true}
        onBack={goBack}
        title={t('dashboard__title')}
        subtitle={t('dashboard__welcome', { name: userdata?.firstName || '' })}
      />
      
      <div className="dashboard__content">
        <div className="dashboard__grid">
          {dashboardItems.map((item) => (
            <div key={item.key} className="dashboard__item">
              <Button
                className={`dashboard__button ${item.className || ''}`}
                onClick={() => navigateTo(item.path)}
              >
                <div className="dashboard__button-content">
                  {item.icon && <item.icon className="dashboard__icon" />}
                  <div className="dashboard__text">
                    <h3 className="dashboard__button-title">{item.title}</h3>
                    <p className="dashboard__button-subtitle">{item.subtitle}</p>
                  </div>
                </div>
              </Button>
            </div>
          ))}
        </div>
        
        <div className="dashboard__quick-actions">
          <h3>{t('dashboard__quick_actions')}</h3>
          <div className="dashboard__actions-grid">
            <Button 
              className="dashboard__action outline"
              onClick={() => navigateTo('/change-language')}
            >
              {t('change_language__title')}
            </Button>
            <Button 
              className="dashboard__action outline"
              onClick={() => navigateTo('/faq')}
            >
              {t('faq__title')}
            </Button>
          </div>
        </div>
      </div>
    </div>
  )
} 