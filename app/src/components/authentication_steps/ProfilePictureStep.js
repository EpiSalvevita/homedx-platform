import React, { useState, useRef, useEffect, useCallback } from 'react'
import { useSelector, useDispatch } from 'react-redux'
import * as Sentry from '@sentry/react'
import { gql, useMutation } from '@apollo/client'
import { useMatomo } from '@datapunt/matomo-tracker-react'
import { useTranslation } from 'react-i18next'

import Step from 'components/Step'
import Button from 'components/Button'

import ProfileIcon from 'assets/icons/ic_profile.b64.svg'

const UPLOAD_PROFILE_PHOTO = gql`
  mutation UploadProfilePhoto($file: Upload!) {
    uploadProfilePhoto(file: $file) {
      url
      success
    }
  }
`

export default function ProfilePictureStep({ onLoad, onError, onSuccess }) {
  const { t } = useTranslation()
  const dispatch = useDispatch()
  const { trackPageView, trackEvent } = useMatomo()

  const sheetRef = useRef(null)
  const hiddenInputRef = useRef(null)
  const [inputFile, setInputFile] = useState(null)
  const [isShowPicker, setIsShowPicker] = useState(false)

  const [uploadProfilePhoto] = useMutation(UPLOAD_PROFILE_PHOTO)

  useEffect(() => {
    trackPageView({
      documentTitle: 'ProfilePicture'
    })
    return () => {}
  }, [])

  useEffect(() => {
    const ref = hiddenInputRef.current
    const listener = () => {
      const reader = new FileReader()
      reader.onload = res => {
        setInputFile(res.target.result)
      }
      reader.readAsDataURL(hiddenInputRef.current.files[0])
    }

    ref.addEventListener('change', listener)
    return () => {
      ref.removeEventListener('change', listener)
    }
  }, [])

  useEffect(() => {
    const { height } = sheetRef?.current?.getBoundingClientRect()
    document.querySelector('ul.list .spacer').style.height = `${height}px`
    return () => {}
  }, [])

  const uploadPhoto = useCallback(async () => {
    trackEvent({
      category: 'NewTest',
      action: 'attempt profile photo photo upload'
    })
    onLoad && onLoad(true, t('auth__loading__title'), t('auth__loading__text'))

    try {
      const base64 = await fetch(inputFile)
      const blob = await base64.blob()
      const file = new File([blob], 'profile.jpg', { type: 'image/jpeg' })

      const { data } = await uploadProfilePhoto({
        variables: { file }
      })

      if (!data.uploadProfilePhoto.success) {
        Sentry.captureException('IdentityProfilePicture: error')
        onError && onError()
        return
      }

      dispatch({ type: 'setProfileImageUrl', url: data.uploadProfilePhoto.url })
      onSuccess && onSuccess()
      trackEvent({
        category: 'NewTest',
        action: 'successful id front photo upload'
      })
    } catch (error) {
      console.error('Profile photo upload error:', error)
      Sentry.captureException('IdentityProfilePicture: error', error)
      onError && onError()
    }
  }, [trackEvent, onLoad, t, inputFile, dispatch, onSuccess, onError, uploadProfilePhoto])

  const showGallery = () => {
    hiddenInputRef.current.click()
  }

  return (
    <Step
      className="authentication__identity"
      title={t('auth__step__profilephoto__title')}
      step={4}
      stepMax={4}
      onNext={() => setIsShowPicker(true)}
      btnText={t('auth__step__profilephoto__btn')}>
      <img
        className={`step__image ${isShowPicker ? 'hide' : ''}`}
        alt="profilphoto"
        src={`${process.env.ASSETS_PATH}/assets/Muster_Zertifikat_Profilbild.png`}
      />

      <ul className="list">
        <li className="list__item">{t('auth__step__tip1')}</li>
        <li className="list__item">{t('auth__step__tip2')}</li>
        <li className="list__item">{t('auth__step__tip3')}</li>
        <li className="list__item">{t('auth__step__tip4')}</li>
        <div className="spacer"></div>
      </ul>
      <div
        ref={sheetRef}
        className={`authentication__identity__profilepicture__wrapper ${
          isShowPicker ? '' : 'hide'
        }`}>
        <div className="row">
          <div className="col-9">
            <h2>{t('auth__step__profilephoto__upload__title')}</h2>
          </div>
          <div className="col-3">
            <div className="authentication__identity__profilepicture">
              <img
                className={!inputFile ? 'empty' : ''}
                src={inputFile || ProfileIcon}
                alt="profilepicture"
              />
            </div>
          </div>
        </div>

        <input type="file" accept="image/png,image/jpeg" ref={hiddenInputRef} />
        <div className="authentication__identity__profilepicture__buttons">
          <Button
            className="outline auth__step__profilephoto__upload__btn_take"
            onClick={showGallery}>
            {t('auth__step__profilephoto__upload__btn_take')}
          </Button>
          <Button
            className="auth__step__profilephoto__upload__btn_save"
            disabled={!inputFile}
            onClick={uploadPhoto}>
            {t('auth__step__profilephoto__upload__btn_save')}
          </Button>
        </div>
      </div>
    </Step>
  )
}
