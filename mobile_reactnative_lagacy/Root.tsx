import React from 'react'

import { Colors } from 'react-native/Libraries/NewAppScreen'

import { NativeBaseProvider } from 'native-base'
import {
  NavigationContainer,
  DefaultTheme,
  DarkTheme
} from '@react-navigation/native'
import App from './App'
import HdxTheme from './src/Theme'

import I18n from './src/I18n'
import { I18nextProvider } from 'react-i18next'

const HdxNavTheme = {
  ...DefaultTheme,
  colors: {
    ...DefaultTheme.colors,
    primary: '#800343'
  }
}

const AppWrapper = () => {
  const isDarkMode = false // useColorScheme() === 'dark'

  return (
    <I18nextProvider i18n={I18n}>
      <NativeBaseProvider theme={HdxTheme}>
        <NavigationContainer theme={isDarkMode ? DarkTheme : HdxNavTheme}>
          <App />
        </NavigationContainer>
      </NativeBaseProvider>
    </I18nextProvider>
  )
}
export default AppWrapper
