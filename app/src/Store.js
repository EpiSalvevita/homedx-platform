import { createStore, combineReducers } from 'redux'
import { persistStore, persistReducer } from 'redux-persist'
import storage from 'redux-persist/lib/storage'

import AuthReducer from './reducers/AuthReducer'
import BaseReducer from './reducers/BaseReducer'
import LicensesReducer from './reducers/LicensesReducer'
import TestReducer from './reducers/TestReducer'

const reducers = combineReducers({
  auth: AuthReducer,
  base: BaseReducer,
  licenses: LicensesReducer,
  test: TestReducer
})

const persistedReducer = persistReducer(
  { key: 'homeDX', storage, whitelist: ['auth'] },
  reducers
)
export const store = createStore(persistedReducer)
export const persistor = persistStore(store)

export const logout = () => {
  // Store.dispatch({ type: 'setToken', token: false })
  // Store.dispatch({
  //   type: 'setProfilePhoto',
  //   profilePhoto: '',
  //   storedProfileImageLastModified: 0
  // })
  // caches.delete('homeDX')
  persistor.purge()
  store.dispatch({ type: 'isLoading', isLoading: false })
}

export default store
