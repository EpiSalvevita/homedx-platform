import React, { ReactChild, useState } from 'react'
import { HdxContext } from './contexts/HdxContext'
import {
  HdxBackendStatus,
  HdxPlugin,
  HdxResultWrapper,
  HdxUserData
} from './models/HdxTypes'

export default function HdxProvider({ children }: { children: ReactChild }) {
  const [token, _setToken] = useState<string>('')
  const [availableTests, _setAvailableTests] = useState<HdxPlugin[]>([])
  const [testResults, _setTestResults] = useState<HdxResultWrapper[]>([])
  const [userdata, _setUserData] = useState<HdxUserData>({})
  const [backendStatus, _setBackendStatus] = useState<HdxBackendStatus>({
    success: false
  })

  return (
    <HdxContext.Provider
      value={{
        availableTests,
        testResults,
        token,
        userdata,
        backendStatus,
        _setToken,
        _setAvailableTests,
        _setTestResults,
        _setUserData,
        _setBackendStatus
      }}>
      {children}
    </HdxContext.Provider>
  )
}
