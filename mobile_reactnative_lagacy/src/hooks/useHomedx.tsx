import { useCallback, useContext, useEffect, useState } from 'react'
import { Platform } from 'react-native'
import {
  HdxAuthorizationStatus,
  HdxBackendStatus,
  HdxFile,
  HdxLiveTokenResponse,
  HdxMediaResponse,
  HdxPlugin,
  HdxResponse,
  HdxResultWrapper,
  HdxSignupData,
  HdxSignupResponse,
  HdxTestData,
  HdxUserData,
  HdxUserDataChangables
} from '../models/HdxTypes'

import Network from '../Network'
import { HdxContext } from '../contexts/HdxContext'
import SplashScreen from 'react-native-splash-screen'

import MovToMp4 from 'react-native-mov-to-mp4'

export default function useHomedx() {
  const [isLoadingResults, setIsLoadingResults] = useState<boolean>(true)
  const [isLoadingTests, setIsLoadingTests] = useState<boolean>(true)

  // const [_token, setToken] = useState<string>('')
  const {
    token,
    _setToken,
    _setAvailableTests,
    _setTestResults,
    _setUserData,
    _setBackendStatus
  } = useContext(HdxContext)

  useEffect(() => {
    token && update(token)
  }, [token])

  const update = useCallback(
    async (_token?: string) => {
      await getBackendStatus()
      ;(_token || token) && (await getUserData(_token || token))
    },
    [token]
  )

  const getData = useCallback(async (_token?: string | undefined) => {
    await update()
    if (_token) {
      _setToken(_token)
      await getAvailableTests()
      await getTestResults(_token)
    } else {
      setIsLoadingTests(false)
      setIsLoadingResults(false)
    }
    SplashScreen.hide()
  }, [])

  const getAvailableTests = useCallback(async () => {
    const res: any = await handlePost('/get-test-type-list', null, null)
    if (res.success) {
      const tests: HdxPlugin[] = res.testTypes
      _setAvailableTests(tests)
    }
    setIsLoadingTests(false)
  }, [])

  const getTestResults = async (_token: string) => {
    const res: any = await handlePost('/get-last-test', null, _token)
    if (res.success) {
      const tests: HdxResultWrapper[] = res.lastTests
      _setTestResults(tests)
    }
    setIsLoadingResults(false)
  }

  const login = async (email: string, password: string) => {
    const res: any = await handlePost(
      '/login',
      { user: email, pw: password },
      null
    )

    if (res.success) {
      if (res.token) {
        // await Persistor.saveToken(res.token)
        await getData(res.token)
        return res.token
      }
    }
  }
  const requestAuth = async () => {
    const res: any = await handlePost('/init-authentication', null, token)
    return res
  }
  const unsetAuth = async () => {
    const res: any = await handlePost('/unset-authentication', null, token)
    if (res.success) {
      _setUserData(prev => ({ ...prev, authorized: 'expired' }))
    }
    return res
  }

  const getUserData = async (_token: string) => {
    const res: any = await handlePost('/get-user-data', null, _token || token)
    if (res.success) {
      const data: HdxUserData = res.userdata
      _setUserData(data)
    }
  }
  const getBackendStatus = async (_token?: string | null | undefined) => {
    const res: any = await handlePost(
      '/get-be-status-flags',
      null,
      _token || token
    )

    if (res.success) {
      const status: HdxBackendStatus = { ...res }
      _setBackendStatus(status)
    }
  }

  const uploadVideo = async (vidPath: string) => {
    if (Platform.OS === 'ios') {
      try {
        vidPath = await MovToMp4.convertMovToMp4(vidPath, 'video.mp4')
      } catch (e) {
        console.log(e)
      }
    }
    let res: HdxMediaResponse = { success: false }

    const data: HdxFile = {
      type: 'video/mp4',
      uri: vidPath,
      name: 'video.mp4'
    }

    const fData = new FormData()
    fData.append('fileExtension', 'mp4')
    fData.append('media', data)

    try {
      res = await handlePostFormData('/add-rapid-test-video', fData, token)
    } catch (e) {
      console.log(e)
    } finally {
      return res
    }
  }
  const uploadPhoto = async (data: HdxFile) => {
    const fData = new FormData()

    fData.append('media', data)
    fData.append('fileExtension', 'jpeg')
    let res: HdxMediaResponse = { success: false }

    try {
      res = await handlePostFormData('/add-rapid-test-photo', fData, token)
    } catch (e) {
      console.log(e)
    } finally {
      return res
    }
  }

  const uploadAuthPhoto = async (
    data: HdxFile,
    type: 'identityCard1' | 'identityCard2' | 'identify'
  ) => {
    const fData = new FormData()

    fData.append('media', data)
    fData.append('fileExtension', 'jpeg')
    fData.append('type', type)
    let res: HdxMediaResponse = { success: false }

    try {
      res = await handlePostFormData('/add-identification-photo', fData, token)
    } catch (e) {
      console.log(e)
    } finally {
      return res
    }
  }

  const getLiveToken = async () => {
    let response: HdxLiveTokenResponse = { success: false }
    try {
      response = await handlePost('/get-live-token', null, token)
    } catch (e) {
      console.log(e)
    } finally {
      return response
    }
  }

  const submitTest = async (data: HdxTestData) => {
    let res: HdxResponse = { success: false }
    try {
      res = await handlePost('/add-test', data, token)
    } catch (e) {
      console.log(e)
    } finally {
      return res
    }
  }

  const changeUserData = async (data: HdxUserDataChangables) => {
    let res: HdxResponse = { success: false }
    try {
      res = await handlePost('/update-user-data', data, token)
    } catch (e) {
      console.log(e)
    } finally {
      return res
    }
  }

  const registerAccount = async (data: HdxSignupData) => {
    let response: HdxSignupResponse = { success: false }
    try {
      response = await handlePost('/register-account', data, null)
    } catch (e) {
      console.log(e)
    } finally {
      return response
    }
  }

  const handlePost = async (
    path: string,
    params: any | null,
    _token: string | null
  ) => {
    let response: HdxResponse = {
      success: false
    }
    try {
      const res: Response = await Network.post(path, params, _token)
      if (res) {
        if (res.status === 401) {
          // await Persistor.clearToken()
          _setToken('')
        }
        let data: HdxResponse = await res.json()
        if (!data || !data.success) {
          response.error = data.error || 'error'
        } else {
          response = data
        }
      }
    } catch (e) {
    } finally {
      return response
    }
  }

  const handlePostFormData = async (
    path: string,
    formData: FormData,
    _token: string | null
  ) => {
    let response: HdxMediaResponse = { success: false }

    try {
      const res: Response = await Network.postFormData(
        path,
        formData,
        _token || token
      )
      if (res) {
        if (res.status === 401) {
          // await Persistor.clearToken()
          _setToken('')
        }
        const data: HdxResponse = await res.json()
        if (!data || !data.success) {
          response.error = data.error || 'error'
        } else {
          response = data
        }
      }
    } catch (e) {
      console.log(e)
    } finally {
      return response
    }
  }

  const getAuthColor = (status: HdxAuthorizationStatus) => {
    switch (status) {
      case 'accepted':
        return 'green.500'
      case 'expired':
      case 'declined':
        return 'red.500'
      case 'in_progress':
      case 'requested':
        return 'orange.500'
      case 'not_available':
        return 'blue.500'
      default:
        return 'black'
    }
  }

  return {
    getData,
    login,
    token,
    isLoadingResults,
    isLoadingTests,
    uploadPhoto,
    uploadVideo,
    getLiveToken,
    submitTest,
    changeUserData,
    registerAccount,
    uploadAuthPhoto,
    requestAuth,
    unsetAuth,
    getAuthColor
  }
}
