import React, { useEffect, useCallback } from 'react'
import { useSelector, useDispatch } from 'react-redux'
import {
  BrowserRouter as Router,
  Switch,
  Route,
  Redirect,
  useLocation
} from 'react-router-dom'
import { useQuery } from '@apollo/client'

import TopBar from 'components/TopBar'
import BottomBar from 'components/BottomBar'

// auth routes
import Dashboard from 'screens/Dashboard'
import NewTest from 'screens/NewTest'
import MyLicenses from 'screens/MyLicenses'
import Profile from 'screens/Profile'
import MyAccount from 'screens/MyAccount'
import MyResult from 'screens/MyResult'
import Authentication from 'screens/Authentication'
import Payment from 'screens/Payment'
import ChangeAccountData from 'screens/ChangeAccountData'

// public routes
import Landing from 'screens/Landing'
import Login from 'screens/Login'
import Signup from 'screens/Signup'
import Content from 'screens/Content'

import useInterval from 'useInterval'
import ChangeLanguage from 'screens/ChangeLanguage'
import ContentPage from 'components/ContentPage'
import { GET_USER_DATA } from 'services/graphql'
import PrivacyPolicy from 'screens/PrivacyPolicy'
import Terms from 'screens/Terms'
import FAQ from 'screens/FAQ'
import Impressum from 'screens/Impressum'
import VideoTutorial from 'screens/VideoTutorial'

// eslint-disable-next-line import/no-anonymous-default-export
export default function () {
  return (
    <Router>
      <Wrapper />
    </Router>
  )
}

function Wrapper() {
  const location = useLocation()
  const dispatch = useDispatch()
  const { token } = useSelector(({ auth }) => auth)
  const { userdata } = useSelector(({ base }) => base)

  const { loading, error, data, refetch } = useQuery(GET_USER_DATA, {
    skip: !token, // Skip if no token
    errorPolicy: 'ignore' // Don't break the app on errors
  })

  useEffect(() => {
    if (data?.me) {
      dispatch({ type: 'setUserdata', userdata: data.me })
    }
  }, [data, dispatch])

  useInterval(() => {
    if (token) {
      refetch().catch(err => {
        console.error('Failed to refetch user data:', err);
        // Don't break the app on refetch errors
      });
    }
  }, 60000) // Refresh every minute

  const isAuthRoute = useCallback(
    path => {
      const authRoutes = [
        '/dashboard',
        '/new-test',
        '/my-licenses',
        '/profile',
        '/my-account',
        '/my-result',
        '/authentication',
        '/payment',
        '/change-account-data'
      ]
      return authRoutes.some(route => path.startsWith(route))
    },
    []
  )

  if (loading) {
    return null // Or a loading spinner
  }

  // Only handle errors if we have a token and it's a real authentication error
  if (error && token && error.message?.includes('Unauthorized')) {
    // Handle authentication error, maybe logout user
    dispatch({ type: 'logout' })
    return <Redirect to="/login" />
  }

  return (
    <>
      <TopBar />
      <Switch>
        <Route exact path="/" component={Landing} />
        <Route exact path="/login" component={Login} />
        <Route exact path="/signup" component={Signup} />
        <Route exact path="/content" component={Content} />
        <Route exact path="/change-language" component={ChangeLanguage} />
        <Route exact path="/content/:slug" component={ContentPage} />
        <Route exact path="/privacy-policy" component={PrivacyPolicy} />
        <Route exact path="/terms" component={Terms} />
        <Route exact path="/faq" component={FAQ} />
        <Route exact path="/impressum" component={Impressum} />
        <Route exact path="/video-tutorial" component={VideoTutorial} />

        {/* Additional routes for complete feature parity */}
        <Route
          exact
          path="/forgot-password"
          render={() => (
            <ContentPage
              src={`${process.env.REACT_APP_WP_API_URL || 'https://www.homedx.com'}/wp-login.php?action=lostpassword`}
            />
          )}
        />
        <Route
          exact
          path="/tech-support"
          render={() =>
            token ? (
              <ContentPage
                src={`https://www.homedx.com/technisches-support-formular/?email=${userdata?.email || ''}&clientId=${userdata?.clientId || ''}&clientText=${userdata?.clientText || ''}&userid=${userdata?.id || ''}`}
              />
            ) : (
              <Redirect to={{ pathname: '/login' }} />
            )
          }
        />

        {/* Protected Routes */}
        <Route
          path="/dashboard"
          render={() =>
            token ? <Dashboard /> : <Redirect to={{ pathname: '/login' }} />
          }
        />
        <Route
          path="/new-test"
          render={() =>
            token ? <NewTest /> : <Redirect to={{ pathname: '/login' }} />
          }
        />
        <Route
          path="/my-licenses"
          render={() =>
            token ? <MyLicenses /> : <Redirect to={{ pathname: '/login' }} />
          }
        />
        <Route
          path="/profile"
          render={() =>
            token ? <Profile /> : <Redirect to={{ pathname: '/login' }} />
          }
        />
        <Route
          path="/my-account"
          render={() =>
            token ? <MyAccount /> : <Redirect to={{ pathname: '/login' }} />
          }
        />
        <Route
          path="/my-result"
          render={() =>
            token ? <MyResult /> : <Redirect to={{ pathname: '/login' }} />
          }
        />
        <Route
          path="/authentication"
          render={() =>
            token ? <Authentication /> : <Redirect to={{ pathname: '/login' }} />
          }
        />
        <Route
          path="/payment"
          render={() =>
            token ? <Payment /> : <Redirect to={{ pathname: '/login' }} />
          }
        />
        <Route
          path="/change-account-data"
          render={() =>
            token ? (
              <ChangeAccountData />
            ) : (
              <Redirect to={{ pathname: '/login' }} />
            )
          }
        />
      </Switch>
      {!isAuthRoute(location.pathname) && <BottomBar />}
    </>
  )
}
