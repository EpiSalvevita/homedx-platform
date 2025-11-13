import { HdxTestData } from '../../../models/HdxTypes'
import { TestProps } from '../../../models/TestProps'

export interface PCRTestData extends HdxTestData {
  testTypeId: '1.2'
}
export interface PCRTestContextProps extends TestProps {
  testData?: PCRTestData
  setTestData?: (data: PCRTestData) => void
}
