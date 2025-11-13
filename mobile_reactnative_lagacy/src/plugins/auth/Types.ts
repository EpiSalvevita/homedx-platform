import { HdxTestData } from '../../models/HdxTypes'
import { TestProps } from '../../models/TestProps'

export interface AuthenticationData extends HdxTestData {}

export interface AuthenticationContextProps extends TestProps {
  testData?: AuthenticationData
  setTestData?: (data: AuthenticationData) => void
}
