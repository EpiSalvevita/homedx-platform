import React, { useEffect } from 'react'
import { SafeAreaView } from 'react-native'
import { StatusBar, useColorMode } from 'native-base'

import Navigator from './src/Navigator'
import HdxProvider from './src/HdxProvider'

const App = () => {
  const isDarkMode = false // useColorScheme() === 'dark'
  const cm = useColorMode()
  cm.setColorMode(isDarkMode ? 'dark' : 'light')

  const backgroundStyle = {
    flex: 1,
    backgroundColor: isDarkMode ? 'slategray' : 'white'
  }

  return (
    <SafeAreaView style={backgroundStyle}>
      <StatusBar barStyle={isDarkMode ? 'light-content' : 'dark-content'} />
      <HdxProvider>
        <Navigator />
      </HdxProvider>
    </SafeAreaView>
  )
}

export default App
