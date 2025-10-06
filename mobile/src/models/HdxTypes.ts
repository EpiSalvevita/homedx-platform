export type HdxResponse = {
  success: boolean
  error?: string
  validation?: string[]
}

export type HdxPlugin = {
  testTypes: HdxTest[]
}

export type HdxAuthorizationStatus =
  | 'requested'
  | 'not_available'
  | 'in_progress'
  | 'declined'
  | 'accepted'
  | 'expired'

export type HdxSignupData = {
  firstname: string
  lastname: string
  email: string
  password: string
  registrationToken?: string
}
export interface HdxSignupResponse extends HdxResponse {
  username?: string
  passwordFeedback?: string[]
}

export interface HdxUserData extends HdxUserDataChangables {
  id?: number
  dobDatetimeUtc?: Date
  firstname?: string
  lastname?: string
  capRapidTestAddWithoutLicense?: boolean
  testaccount?: boolean
  authorized?: HdxAuthorizationStatus
  clientId?: number
  clientText?: string
  clientContingentConsumed?: boolean
  profileImageLastModified?: number
  additonalUserDataSubmitted?: boolean
  identityCardIdInfo?: boolean
  identityCardId?: string
  identityCardExpirationDate?: {
    date?: string
    timezone?: string
    timezone_type?: number
  }
}

export interface HdxUserDataChangables {
  first_name?: string
  last_name?: string
  dob?: number
  gender?: 'male' | 'female' | 'diverse' | string
  title?: string
  company?: string
  address1?: string
  address2?: string
  postcode?: string
  city?: string
  country?: string
  email?: string
  phone?: string
  identity_card_id?: string
  identity_card_expiration_date?: {
    date: string
    timezone: string
    timezone_type: number
  }
}

export interface HdxBackendStatus extends HdxResponse {
  cwa?: boolean
  cwaLaive?: boolean
}
export type HdxContextProps = {
  availableTests: HdxPlugin[]
  testResults: HdxResultWrapper[]
  userdata: HdxUserData | Partial<HdxUserData>
  backendStatus: HdxBackendStatus
  token: string
  _setToken: (token: string) => void
  _setAvailableTests: (tests: HdxPlugin[]) => void
  _setTestResults: (results: HdxResultWrapper[]) => void
  _setBackendStatus: (status: HdxBackendStatus) => void
  _setUserData: (data: React.SetStateAction<HdxUserData>) => void
}

export type HdxTest = {
  name: string
  id: string
}

export type HdxTestData = {
  testTypeId: string
}

export interface HdxResultWrapper extends HdxResponse {
  lastTest: HdxResult
}
export interface HdxResult extends HdxResponse {
  result: string
  testDate: number
}

export type HdxFile = {
  name: string
  uri: string
  type: string
}

export interface HdxMediaResponse extends HdxResponse {
  objectName?: string
}
export interface HdxLiveTokenResponse extends HdxResponse {
  liveToken?: string
}
