import { PURGE } from 'redux-persist'

const defaultState = {
  token: '',
  profilePhoto: '',
  storedProfileImageLastModified: 0
}

const Reducer = (state = defaultState, action) => {
  switch (action.type) {
    case 'setToken':
      return { ...state, token: action.token }
    case 'setProfilePhoto':
      return {
        ...state,
        profilePhoto: action.photo,
        storedProfileImageLastModified: action.lastModified
      }
    case PURGE: {
      return defaultState
    }
    default:
      return state
  }
}

export default Reducer
