import i18n from 'i18next'
import LanguageDetector from 'i18next-browser-languagedetector'
import { initReactI18next } from 'react-i18next'
import { AVAILABLE_LANGUAGES } from 'hdx-config'

const resources = {}

AVAILABLE_LANGUAGES.forEach(([id, name]) => {
  try {
    const data = require(`./i18n/${id}`)
    resources[id] = { homeDX: { ...data.default } }
  } catch (e) {
    console.error('I18n: language not found', id, e)
  }
})

i18n
  .use(LanguageDetector)
  .use(initReactI18next)
  .init({
    // we init with resources
    cache: null,
    resources,
    fallbackLng: 'en',
    debug: false,

    // have a common namespace used around the full app
    ns: ['homeDX'],
    defaultNS: 'homeDX',

    keySeparator: false, // we use content as keys

    interpolation: {
      escapeValue: false
    },

    detection: {
      order: [
        'localStorage',
        'navigator',
        'cookie',
        'sessionStorage',
        'localStorage',
        'htmlTag',
        'querystring',
        'subdomain',
        'path'
      ]
    }
  })

if (i18n.options?.react) {
  i18n.options.react.transKeepBasicHtmlNodesFor = ['br', 'strong', 'i', 'p']
}

export default i18n
