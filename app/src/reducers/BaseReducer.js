import { PURGE } from 'redux-persist'

const defaultState = {
  isLoading: false,
  showTopbar: false,
  showBottombar: false,
  userdata: {},
  hasShownIDCardIDAlert: false,
  hasShownAuthenticationAlert: false,
  pathname: '',
  backendStatus: {
    maintenance: false,
    version: '1.0.0',
    paymentIsActive: true, // Default to true to allow payments until backend status is loaded
    stripe: true,
    cwa: false,
    cwaLaive: false,
    certificatePdf: true,
    flags: []
  }
}

const Reducer = (state = defaultState, action) => {
  switch (action.type) {
    case 'isLoading':
      return { ...state, isLoading: action.isLoading }
    case 'showTopbar':
      return { ...state, showTopbar: action.showTopbar }
    case 'showBottombar':
      return { ...state, showBottombar: action.showBottombar }
    case 'setUserdata':
      // Compute additonalUserDataSubmitted based on required fields
      const userdata = { ...action.userdata }
      
      // Check if required additional data fields are present
      const hasRequiredFields = !!(
        userdata.dateOfBirth &&
        userdata.city &&
        userdata.country &&
        userdata.address &&
        userdata.postalCode
      )
      
      userdata.additonalUserDataSubmitted = hasRequiredFields
      
      console.log('BaseReducer setUserdata:', {
        userdata,
        hasRequiredFields,
        checks: {
          dateOfBirth: !!userdata.dateOfBirth,
          city: !!userdata.city,
          country: !!userdata.country,
          address: !!userdata.address,
          postalCode: !!userdata.postalCode
        }
      })
      
      return { ...state, userdata }
    case 'setBackendStatus':
      return { ...state, backendStatus: action.backendStatus }
    case 'setHasShownAuthenticationAlert':
      return {
        ...state,
        hasShownAuthenticationAlert: action.hasShownAuthenticationAlert
      }
    case 'setHasShownIDCardIDAlert':
      return {
        ...state,
        hasShownIDCardIDAlert: action.hasShownIDCardIDAlert
      }
    case 'setPathname':
      return { ...state, pathname: action.pathname }
    case PURGE: {
      return defaultState
    }
    default:
      return state
  }
}

export default Reducer
