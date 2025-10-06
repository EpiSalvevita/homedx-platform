/**
 * @format
 */

import { AppRegistry, LogBox } from 'react-native'
import App from './Root'
import { name as appName } from './app.json'
import countries from 'i18n-iso-countries'
countries.registerLocale(require('i18n-iso-countries/langs/en.json'))
countries.registerLocale(require('i18n-iso-countries/langs/de.json'))
countries.registerLocale(require('i18n-iso-countries/langs/fr.json'))

LogBox.ignoreAllLogs(true)
LogBox.ignoreLogs([
  'When server rendering, you must wrap your application in an ',
  'NativeBase: The contrast ratio'
])
AppRegistry.registerComponent(appName, () => App)
