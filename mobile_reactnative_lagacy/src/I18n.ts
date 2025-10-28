import i18n from 'i18next'
import { initReactI18next } from 'react-i18next'
import { getLocales } from 'react-native-localize'

import resources from './lang'
const NAMESPACES = ['general', 'auth', 'covid19']

i18n.use(initReactI18next).init({
  // react: { useSuspense: false },
  // initImmediate: false,
  lng: getLocales()[0].languageCode,
  // we init with resources
  cache: null,
  resources,
  fallbackLng: 'de',
  debug: false,
  // have a common namespace used around the full app
  ns: NAMESPACES,
  defaultNS: 'general',
  keySeparator: '_'
})

export default i18n
