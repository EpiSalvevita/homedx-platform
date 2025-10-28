import React from 'react'
import { HdxContextProps } from '../models/HdxTypes'

export const HdxContext = React.createContext<HdxContextProps>({
  availableTests: [],
  testResults: [],
  token: '',
  backendStatus: { success: false },
  userdata: {},
  _setToken: () => null,
  _setAvailableTests: () => null,
  _setTestResults: () => null,
  _setBackendStatus: () => null,
  _setUserData: () => null
})
