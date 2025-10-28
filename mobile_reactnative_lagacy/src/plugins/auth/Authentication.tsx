import React, { createContext, useState } from 'react'
import steps from './steps'
import { NativeStackScreenProps } from '@react-navigation/native-stack'
import { ScreenProps } from '../../models/ScreenProps'
import TestView from '../../widgets/TestView'
import { AuthenticationContextProps, AuthenticationData } from './Types'
import { useNavigation } from '@react-navigation/native'

export const AuthContext = createContext<AuthenticationContextProps>({})
export default function Authentication({}: NativeStackScreenProps<
  ScreenProps,
  'Authentication'
>) {
  const navigation = useNavigation()
  const [state, _setState] = useState<AuthenticationContextProps>({
    currentIndex: 0,
    testData: { testTypeId: '' },
    setState: (data: AuthenticationContextProps) =>
      _setState(prev => ({ ...prev, ...data })),
    setTestData: (data: AuthenticationData) =>
      _setState(prev => ({ ...prev, testData: { ...prev.testData, ...data } })),
    onReachedEnd: () => navigation.goBack()
  })

  return (
    <TestView steps={steps} state={state} provider={AuthContext.Provider} />
  )
}
