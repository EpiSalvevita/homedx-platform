import React, { useContext } from 'react'
import { NativeStackScreenProps } from '@react-navigation/native-stack'
import { ScreenProps } from '../../models/ScreenProps'
import RapidTest from './rapidtest/RapidTest'
import PCRTest from './pcrtest/PCRTest'
import AntibodyTest from './antibodytest/AntibodyTest'
import { HdxContext } from '../../contexts/HdxContext'
import Authentication from '../auth/Authentication'
import { convertAbsoluteToRem } from 'native-base/lib/typescript/theme/tools'
import { useNavigation } from '@react-navigation/native'

export default function Router({
  navigation,
  route
}: NativeStackScreenProps<ScreenProps, 'Covid19'>) {
  const params = route.params
  // const navigation = useNavigation()
  const { userdata } = useContext(HdxContext)

  if (userdata.authorized !== 'accepted') {
    // return <Authentication />
    navigation.replace('Authentication')
  }

  switch (params.path) {
    case 'rapid-test':
    case '1.1':
      return <RapidTest />
    case 'pcr-test':
    case '1.2':
      return <PCRTest /> //<PCRTestRouter />
    case 'antibody':
    case '1.3':
      return <AntibodyTest />
    default:
      navigation.goBack()
      return <></>
  }
}

// export default function Covid19() {

// }
