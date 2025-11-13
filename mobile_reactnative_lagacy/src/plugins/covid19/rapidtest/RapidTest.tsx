import React, {
  createContext,
  useContext,
  useEffect,
  useMemo,
  useState
} from 'react'
import { RapidTestContextProps, RapidTestData } from './Types'
import steps from './steps'
import TestView from '../../../widgets/TestView'
import CWA from './steps/CWA'
import Checkout from './steps/Checkout'
import { useNavigation } from '@react-navigation/native'
import { HdxContext } from '../../../contexts/HdxContext'

export const RapidTestContext = createContext<RapidTestContextProps>({
  testData: { testTypeId: '1.1' },
  setTestData: () => null
})

// if (
//   !capRapidTestAddWithoutLicense &&
//   testData.paymentMethod === 'payment'
// ) {
//   steps.push('checkout')
// }
// if (backendStatus.cwa || backendStatus.cwaLaive) {
//   steps.splice(1, 0, 'cwa')
// }

export default function RapidTest() {
  const navigation = useNavigation()
  const { backendStatus, userdata } = useContext(HdxContext)

  const [state, _setState] = useState<RapidTestContextProps>({
    currentIndex: 0,
    testData: {
      testTypeId: '1.1'
    },
    setState: (data: Partial<RapidTestContextProps>) =>
      _setState((prev: RapidTestContextProps) => ({ ...prev, ...data })),
    setTestData: (data: Partial<RapidTestData>) =>
      _setState((prev: RapidTestContextProps) => ({
        ...prev,
        testData: { ...prev.testData, ...data }
      })),
    onReachedEnd: () => navigation.goBack()
  })

  const alteredSteps: any[] = useMemo(() => {
    const as = [...steps]

    if (
      !userdata.capRapidTestAddWithoutLicense ||
      state.testData?.paymentMethod === 'payment'
    ) {
      as.push(Checkout)
    }

    if (backendStatus.cwa || backendStatus.cwaLaive) {
      as.splice(1, 0, CWA)
    }
    return as
  }, [
    steps,
    backendStatus,
    state.testData,
    userdata.capRapidTestAddWithoutLicense
  ])

  return (
    <TestView
      provider={RapidTestContext.Provider}
      steps={alteredSteps}
      state={state}
    />
  )
}
