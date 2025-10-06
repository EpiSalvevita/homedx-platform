import React, { useEffect, useState, useCallback, useMemo } from 'react'
import { useDispatch, useSelector } from 'react-redux'
import { useQuery, useMutation, useLazyQuery } from '@apollo/client'
import { useHistory } from 'react-router'
import * as Sentry from '@sentry/react'
import { useMatomo } from '@datapunt/matomo-tracker-react'
import { useTranslation } from 'react-i18next'
import i18next from 'i18next'

import BottomSheet from 'components/BottomSheet'
import Form from 'components/Form'
import Button from 'components/Button'
import TextInput from 'components/TextInput'
import Select from 'components/Select'
import Prompt from 'components/Prompt'
import SubmitButton from 'components/SubmitButton'

import WarningIcon from 'assets/icons/ic_warning.svg'
import ErrorIcon from 'assets/icons/ic_error.svg'

import { GET_USER_DATA, UPDATE_USER_DATA, GET_COUNTRY_CODES } from 'services/graphql'

export default function ChangeAccountData() {
  const { t } = useTranslation()
  const history = useHistory()
  const dispatch = useDispatch()
  const userdata = useSelector(({ base }) => base.userdata)
  const [showForm, setShowForm] = useState(false)
  const [validations, setValidations] = useState([])
  const [messageType, setMessageType] = useState('')
  const [isShowMessage, setIsShowMessage] = useState(false)

  const [isLoading, setIsLoading] = useState(false)
  const [formData, setFormData] = useState({})
  const [isChanged, setIsChanged] = useState(false)
  const { trackPageView, trackEvent } = useMatomo()

  const [countries, setCountries] = useState([])

  const regionNames = useMemo(() => {
    if (Intl.DisplayNames) {
      return new Intl.DisplayNames([i18next.language.substring(0, 2)], {
        type: 'region'
      })
    } else {
      return []
    }
  }, [])

  const { refetch: refetchUserData } = useQuery(GET_USER_DATA, {
    onCompleted: (data) => {
      if (data.me) {
        dispatch({ type: 'setUserdata', userdata: data.me })
      }
    }
  })

  const [getCountryCodes] = useLazyQuery(GET_COUNTRY_CODES, {
    onCompleted: (data) => {
      if (data.countryCodes) {
        const countries = data.countryCodes.map(country => ({
          value: country,
          label: (regionNames?.of && regionNames?.of(country)) || country
        }))

        countries.sort((foo, bar) => foo.label > bar.label)
        setCountries(countries)
      } else {
        setCountries([])
      }
      setIsLoading(false)
    }
  })

  const [updateUserData] = useMutation(UPDATE_USER_DATA, {
    onCompleted: (data) => {
      console.log('updateUserData completed:', data)
      if (data.updateUser) {
        dispatch({ type: 'setUserdata', userdata: data.updateUser })
        setMessageType('success')
        trackEvent({
          category: 'NewTest',
          action: 'successful change account data'
        })
        setIsShowMessage(true)
      }
      setIsLoading(false)
    },
    onError: (error) => {
      console.log('updateUserData error:', error)
      if (error.graphQLErrors?.[0]?.extensions?.validation) {
        setMessageType('error')
        setValidations(error.graphQLErrors[0].extensions.validation)
        setIsShowMessage(true)
      } else {
        console.error('No validation errors provided:', error)
        Sentry.captureException('ChangeAccountData: error but no validation provided')
      }
      setIsLoading(false)
    }
  })

  const getCountries = useCallback(async () => {
    if (countries.length) return
    setIsLoading(true)
    getCountryCodes()
  }, [countries.length, getCountryCodes])

  const changeData = useCallback(async () => {
    console.log('changeData called with formData:', formData)
    console.log('userdata.id:', userdata.id)
    
    setIsLoading(true)
    trackEvent({ category: 'NewTest', action: 'attempt change account data' })
    
    // Map frontend field names to backend field names
    const genderMapping = {
      'm': 'male',
      'f': 'female', 
      'd': 'other',
      '': 'prefer_not_to_say'
    }

    const variables = {
      id: userdata.id,
      input: {
        dateOfBirth: formData.dob ? new Date(formData.dob).toISOString() : null,
        gender: genderMapping[formData.gender] || 'prefer_not_to_say',
        title: formData.title,
        address1: formData.address1,
        address2: formData.address2,
        postcode: formData.postcode,
        city: formData.city,
        country: formData.country || '',
        phone: formData.phone,
        firstName: formData.firstname,
        lastName: formData.lastname
      }
    }

    console.log('Sending mutation variables:', variables)

    updateUserData({ variables })
  }, [
    formData.address1,
    formData.address2,
    formData.city,
    formData.country,
    formData.dob,
    formData.firstname,
    formData.gender,
    formData.lastname,
    formData.phone,
    formData.postcode,
    formData.title,
    trackEvent,
    updateUserData
  ])

  const showWarning = () => {
    console.log('showWarning called - no changes detected')
    setMessageType('warning')
    setIsShowMessage(true)
  }

  useEffect(() => {
    if (!Object.keys(userdata).length) {
      refetchUserData()
      return
    }

    const data = {
      ...userdata
    }

    // Map backend dateOfBirth to frontend dob field
    if (data?.dateOfBirth) {
      data.dob = getDateFromTimestamp(new Date(data.dateOfBirth).getTime())
    }

    // Map backend postalCode to frontend postcode field  
    if (data?.postalCode) {
      data.postcode = data.postalCode
    }

    // For now, put the single address in address1, address2 can be empty
    if (data?.address) {
      data.address1 = data.address
      data.address2 = ''
    }

    // Map backend field names to frontend field names
    if (data?.firstName) {
      data.firstname = data.firstName
    }
    if (data?.lastName) {
      data.lastname = data.lastName
    }

    // Map backend gender values to frontend values
    const backendToFrontendGender = {
      'male': 'm',
      'female': 'f', 
      'other': 'd',
      'prefer_not_to_say': ''
    }
    if (data?.gender) {
      data.gender = backendToFrontendGender[data.gender] || ''
    }

    if (!data?.country) {
      data.country = 'DE'
    }

    setFormData(data)
    getCountries()
    setShowForm(true)
    return () => {
      setShowForm(false)
    }
  }, [userdata, refetchUserData, getCountries, getDateFromTimestamp])

  useEffect(() => {
    trackPageView({
      documentTitle: 'ChangeAccountData'
    })
    return () => {}
  }, [trackPageView])

  const getDateFromTimestamp = useCallback(timeStamp => {
    if (!timeStamp) return null
    let date = new Date(timeStamp).toLocaleDateString('en-US').split('/')
    date =
      date[2].padStart(4, '0') +
      '-' +
      date[0].padStart(2, '0') +
      '-' +
      date[1].padStart(2, '0')

    return date
  }, [])

  const validationText = (validation = []) => {
    let val = '<ul class="list primary">'

    validation.forEach(v => {
      val += '<li class="list__item">'
      v === 'dob' && (val += t('changedata__validation_dob'))
      v === 'gender' && (val += t('changedata__validation_gender'))
      v === 'address_1' && (val += t('changedata__validation_address1'))
      v === 'address_2' && (val += t('changedata__validation_address2'))
      v === 'city' && (val += t('changedata__validation_city'))
      v === 'country' && (val += t('changedata__validation_country'))
      v === 'phone' && (val += t('changedata__validation_phone'))
      v === 'postcode' && (val += t('changedata__validation_postcode'))
      v === 'unevaluatedTests' &&
        (val += t('changedata__validation_unevaluatedTests'))
      val += '</li>'
    })

    val += '</ul>'
    return val
  }

  return (
    <div className="screen-change-account-data">
      <BottomSheet
        canGoBack
        hideSpacer
        className={`no-bottombar ${showForm ? 'open' : ''}`}
        title={t('changedata__title')}>
        {showForm && (
          <Form>
            <div className="row">
              <div className="col-12">
                <div className="form-group">
                  <TextInput
                    label={t('changedata__firstname')}
                    value={formData.firstname}
                    onChange={value => {
                      setFormData({ ...formData, firstname: value })
                      setIsChanged(true)
                    }}
                  />
                </div>
              </div>
            </div>
            <div className="row">
              <div className="col-12">
                <div className="form-group">
                  <TextInput
                    label={t('changedata__lastname')}
                    value={formData.lastname}
                    onChange={value => {
                      setFormData({ ...formData, lastname: value })
                      setIsChanged(true)
                    }}
                  />
                </div>
              </div>
            </div>
            <div className="row">
              <div className="col-12">
                <div className="form-group">
                  <TextInput
                    label={t('changedata__dob')}
                    type="date"
                    value={formData.dob}
                    onChange={value => {
                      setFormData({ ...formData, dob: value })
                      setIsChanged(true)
                    }}
                  />
                </div>
              </div>
            </div>
            <div className="row">
              <div className="col-12">
                <div className="form-group">
                  <Select
                    label={t('changedata__gender')}
                    value={formData.gender}
                    options={[
                      { value: "", label: t('changedata__gender__select') },
                      { value: "m", label: t('changedata__gender__m') },
                      { value: "f", label: t('changedata__gender__f') },
                      { value: "d", label: t('changedata__gender__d') }
                    ]}
                    onChange={e => {
                      setFormData({ ...formData, gender: e.target.value })
                      setIsChanged(true)
                    }}
                  />
                </div>
              </div>
            </div>
            <div className="row">
              <div className="col-12">
                <div className="form-group">
                  <TextInput
                    label={t('changedata__address1')}
                    value={formData.address1}
                    onChange={value => {
                      setFormData({ ...formData, address1: value })
                      setIsChanged(true)
                    }}
                  />
                </div>
              </div>
            </div>
            <div className="row">
              <div className="col-12">
                <div className="form-group">
                  <TextInput
                    label={t('changedata__address2')}
                    value={formData.address2}
                    onChange={value => {
                      setFormData({ ...formData, address2: value })
                      setIsChanged(true)
                    }}
                  />
                </div>
              </div>
            </div>
            <div className="row">
              <div className="col-12">
                <div className="form-group">
                  <TextInput
                    label={t('changedata__postcode')}
                    value={formData.postcode}
                    onChange={value => {
                      setFormData({ ...formData, postcode: value })
                      setIsChanged(true)
                    }}
                  />
                </div>
              </div>
            </div>
            <div className="row">
              <div className="col-12">
                <div className="form-group">
                  <TextInput
                    label={t('changedata__city')}
                    value={formData.city}
                    onChange={value => {
                      setFormData({ ...formData, city: value })
                      setIsChanged(true)
                    }}
                  />
                </div>
              </div>
            </div>
            <div className="row">
              <div className="col-12">
                <div className="form-group">
                  <Select
                    label={t('changedata__country')}
                    value={formData.country}
                    options={countries}
                    onChange={e => {
                      setFormData({ ...formData, country: e.target.value })
                      setIsChanged(true)
                    }}
                  />
                </div>
              </div>
            </div>
            <div className="row">
              <div className="col-12">
                <div className="form-group">
                  <TextInput
                    label={t('changedata__phone')}
                    value={formData.phone}
                    onChange={value => {
                      setFormData({ ...formData, phone: value })
                      setIsChanged(true)
                    }}
                  />
                </div>
              </div>
            </div>
            <div className="row">
              <div className="col-12">
                <div className="form-group">
                  <Button
                    disabled={isLoading}
                    onClick={() => {
                      console.log('Button clicked! isChanged:', isChanged, 'isLoading:', isLoading)
                      if (isChanged) {
                        changeData()
                      } else {
                        showWarning()
                      }
                    }}>
                    {t('changedata__btn__save')}
                  </Button>
                </div>
              </div>
            </div>
          </Form>
        )}
      </BottomSheet>
      {isShowMessage && messageType === 'success' && (
        <Prompt
          icon={<WarningIcon />}
          direction={'center'}
          title={t('changedata__success__title')}
          text={t('changedata__success__text')}
          button={
            <Button className="ghost" onClick={() => history.goBack()}>
              {t('btn__back')}
            </Button>
          }
        />
      )}
      {isShowMessage && messageType === 'error' && (
        <Prompt
          icon={<ErrorIcon />}
          direction={'center'}
          title={t('changedata__error__title')}
          text={validationText(validations)}
          button={
            <Button className="ghost" onClick={() => setIsShowMessage(false)}>
              {t('btn__back')}
            </Button>
          }
        />
      )}
      {isShowMessage && messageType === 'warning' && (
        <Prompt
          icon={<WarningIcon />}
          direction={'center'}
          title={t('changedata__warning__title')}
          text={t('changedata__warning__text')}
          button={
            <Button className="ghost" onClick={() => setIsShowMessage(false)}>
              {t('btn__back')}
            </Button>
          }
        />
      )}
    </div>
  )
}
