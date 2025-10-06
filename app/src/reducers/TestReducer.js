import { PURGE } from 'redux-persist'

const defaultState = {
  lastRapidtest: null,
  idCardFrontUrl: '',
  idCardBackUrl: '',
  identityID: '',
  profileImageUrl: '',
  paymentMethod: '',
  isAuthenticated: false,
  paymentId: '',
  licenseCode: '',
  qrdata: '',
  isPayedFor: false,
  liveToken: ''
}

const Reducer = (state = defaultState, action) => {
  switch (action.type) {
    case 'setLastRapidTest':
      return { ...state, lastRapidtest: action.lastRapidTest }
    case 'setIdCardFrontUrl':
      return { ...state, idCardFrontUrl: action.url }
    case 'setIdCardBackUrl':
      return { ...state, idCardBackUrl: action.url }
    case 'setProfileImageUrl':
      return { ...state, profileImageUrl: action.url }
    case 'setIdentityID':
      return { ...state, identityID: action.identityID }
    case 'setPaymentId':
      return { ...state, paymentId: action.paymentId }
    case 'setQRData':
      return { ...state, qrdata: action.qrdata }
    case 'setLiveToken':
      return { ...state, liveToken: action.liveToken }
    case 'setIsAuthenticated':
      return { ...state, isAuthenticated: action.isAuthenticated }
    case 'setPaymentMethod':
      return { ...state, paymentMethod: action.paymentMethod }
    case 'setIsPayedFor':
      return { ...state, isPayedFor: action.isPayedFor }
    case 'setLicenseCode':
      return { ...state, licenseCode: action.licenseCode }
    case 'resetCurrentTestSession':
      return defaultState
    case PURGE: {
      return defaultState
    }
    default:
      return state
  }
}

export default Reducer
