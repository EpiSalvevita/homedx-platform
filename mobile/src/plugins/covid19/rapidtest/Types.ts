import { HdxTestData } from '../../../models/HdxTypes'
import { TestProps } from '../../../models/TestProps'

export interface RapidTestData extends HdxTestData {
  testDate?: number
  testDeviceUrl?: number | string
  photoUrl?: number | string
  videoUrl?: number | string
  liveToken?: number | string
  licenseCode?: string
  paymentId?: string
  agreementGiven?: CWAChoice
  testTypeId: '1.1'
  paymentMethod?: 'coupon' | 'payment'
}

export interface RapidTestContextProps extends TestProps {
  testData: RapidTestData
  setTestData: (data: Partial<RapidTestData>) => void
}

export type CWAChoice = 'with' | 'without' | 'none'
