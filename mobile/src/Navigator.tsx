import React, { useContext, useEffect } from 'react'
import useHomedx from './hooks/useHomedx'

import { createNativeStackNavigator } from '@react-navigation/native-stack'

import Dashboard from './screens/Dashboard'
import MyTestResults from './screens/MyTestResults'
import Settings from './screens/Settings'
import Covid19 from './plugins/covid19/Router'
import Landing from './screens/Landing'
import Login from './screens/Login'
import Signup from './screens/Signup'
import { Button, HamburgerIcon, Icon, IconButton, useTheme } from 'native-base'
import { getFocusedRouteNameFromRoute } from '@react-navigation/native'
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs'
import { HdxContext } from './contexts/HdxContext'
import PersonalData from './screens/PersonalData'
// import CWA from './plugins/covid19/rapidtest/steps/CWA'

const Stack = createNativeStackNavigator()
const Tab = createBottomTabNavigator()

import Logo from './assets/images/logo.svg'
// import Testing from './screens/Testing'
import NavTestResultsIcon from './assets/icons/ic_certificates.svg'
import NavHomeIcon from './assets/icons/ic_home.svg'
import Authentication from './plugins/auth/Authentication'

export default function Navigator() {
  const { token } = useContext(HdxContext)
  const { colors, space } = useTheme()

  const screenStyle = {
    backgroundColor: colors.white,
    paddingHorizontal: space[4]
  }
  const { getData } = useHomedx()

  useEffect(() => {
    getData()
  }, [])

  return (
    <>
      <Stack.Navigator
        initialRouteName="Restricted"
        screenOptions={({ route }) => ({
          headerShown: route.name !== 'Restricted',
          headerTransparent: route.name === 'Landing',
          headerBackTitleVisible: false,
          headerTitle: route.name === 'Landing' ? '' : route.name,
          contentStyle: {
            ...screenStyle,
            ...{
              overflow: 'visible',
              paddingHorizontal: route.name === 'Landing' ? 0 : space[4]
            }
          }
        })}>
        {token ? (
          <>
            {/* <Stack.Screen name="CWA" component={CWA} /> */}
            <Stack.Screen
              name="Restricted"
              options={({ navigation }) => ({
                headerTitle: '',
                headerShown: true,
                headerLeft: () => <Logo />,
                headerRight: () => (
                  <IconButton
                    onPress={() => navigation.navigate('Settings')}
                    pr="0">
                    <HamburgerIcon color="primary.100" />
                  </IconButton>
                )
              })}>
              {({ navigation, route }: { navigation: any }) => (
                <Tab.Navigator
                  sceneContainerStyle={{
                    ...screenStyle,
                    paddingHorizontal: 0,
                    overflow: 'visible'
                  }}
                  screenOptions={({ route: _route }) => ({
                    headerShown: false,
                    tabBarIcon: ({ focused, color, size }) => {
                      if (_route.name === 'Dashboard') {
                        return (
                          <NavHomeIcon
                            fill={focused ? '#800343' : 'black'}
                            style={{
                              width: 20,
                              height: 20,
                              opacity: focused ? 1 : 0.6
                            }}
                          />
                        )
                      } else if (_route.name === 'MyTestResults') {
                        return (
                          <NavTestResultsIcon
                            fill={focused ? '#800343' : 'black'}
                            style={{
                              width: 20,
                              height: 20,
                              opacity: focused ? 1 : 0.6
                            }}
                          />
                        )
                      }
                    }
                  })}>
                  <Tab.Screen name="Dashboard" component={Dashboard} />
                  <Tab.Screen name="MyTestResults" component={MyTestResults} />
                </Tab.Navigator>
              )}
            </Stack.Screen>
            <Stack.Screen name="Settings" component={Settings} />
            <Stack.Screen name="PersonalData" component={PersonalData} />
            <Stack.Screen name="Covid19" component={Covid19} />
            <Stack.Screen name="Authentication" component={Authentication} />
          </>
        ) : (
          <>
            {/* <Stack.Screen name="Testing" component={Testing} /> */}
            <Stack.Screen name="Landing" component={Landing} />
            <Stack.Screen name="Login" component={Login} />
            <Stack.Screen name="Signup" component={Signup} />
          </>
        )}
      </Stack.Navigator>
    </>
  )
}
