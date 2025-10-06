import { PURGE } from 'redux-persist'

const defaultState = {
  licenses: {}
}

const Reducer = (state = defaultState, action) => {
  switch (action.type) {
    case 'setLicenses':
      return { ...state, licenses: action.licenses }
    case PURGE: {
      return defaultState
    }
    default:
      return state
  }
}

export default Reducer
