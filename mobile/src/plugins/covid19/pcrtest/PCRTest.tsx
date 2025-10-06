import { useNavigation } from '@react-navigation/native'
import React, { createContext, useState } from 'react'
import TestView from '../../../widgets/TestView'
import steps from './steps'
import { PCRTestContextProps, PCRTestData } from './Types'

export const PCRTestContext = createContext<PCRTestContextProps>({})
export default function PCRTest() {
  const navigation = useNavigation()

  const [state, _setState] = useState<PCRTestContextProps>({
    currentIndex: 0,
    testData: {
      testTypeId: '1.2'
    },
    setState: (data: PCRTestContextProps) =>
      _setState(prev => ({ ...prev, ...data })),
    setTestData: (data: PCRTestData) =>
      _setState(prev => ({ ...prev, testData: { ...prev.testData, ...data } })),
    onReachedEnd: () => navigation.goBack()
  })

  return (
    <TestView provider={PCRTestContext.Provider} steps={steps} state={state} />
  )
}
