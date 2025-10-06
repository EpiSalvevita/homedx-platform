import React from 'react'
import ReactDOM from 'react-dom'
import { Provider } from 'react-redux'
import { PersistGate } from 'redux-persist/integration/react'
import { ApolloProvider } from '@apollo/client'
import { client } from './apollo'
import { store, persistor } from './Store'
import Router from './Router'
import './style/index.scss'

import LoadingWrapper from 'base/LoadingWrapper'
import UpdateToast from 'base/UpdateToast'
import ENVFlag from 'base/ENVFlag'
import Style from 'Style'

import * as Sentry from '@sentry/react'
import { Integrations } from '@sentry/tracing'
import { useMatomo } from '@datapunt/matomo-tracker-react'
import { MatomoProvider, createInstance } from '@datapunt/matomo-tracker-react'
import MatomoConfig from '../matomo.config'
import I18n from './I18n'

import { Elements } from '@stripe/react-stripe-js'
import { loadStripe } from '@stripe/stripe-js'

const matomoInstance =
  process.env.ENV === 'prod' ? createInstance(MatomoConfig) : null

window.VERSION = '1.8.12'
console.log('Version', window.VERSION)

// Add global click debugging
document.addEventListener('click', (e) => {
  console.log('Global click detected on:', e.target, 'at:', e.clientX, e.clientY);
});

document.addEventListener('DOMContentLoaded', () => {
  console.log('DOM fully loaded');
});

const stripePromise = process.env.STRIPE_PUBLIC_KEY 
  ? loadStripe(process.env.STRIPE_PUBLIC_KEY)
  : Promise.resolve(null);

// Set language in Apollo client context
client.defaultOptions = {
  ...client.defaultOptions,
  watchQuery: {
    ...client.defaultOptions?.watchQuery,
    context: {
      ...client.defaultOptions?.watchQuery?.context,
      headers: {
        'Accept-Language': I18n.language
      }
    }
  },
  query: {
    ...client.defaultOptions?.query,
    context: {
      ...client.defaultOptions?.query?.context,
      headers: {
        'Accept-Language': I18n.language
      }
    }
  },
  mutate: {
    ...client.defaultOptions?.mutate,
    context: {
      ...client.defaultOptions?.mutate?.context,
      headers: {
        'Accept-Language': I18n.language
      }
    }
  }
}

// if ('serviceWorker' in navigator) {
//   window.addEventListener('load', async function () {
//     navigator.serviceWorker.register('service-worker.js').then(
//       registration => {
//         console.log(
//           'ServiceWorker registration successful with scope:',
//           registration.scope
//         )
//         registration.unregister()
//         // registration.onupdatefound = () => {
//         //   const installer = registration.installing
//         //   installer.onstatechange = async () => {
//         //     if (installer.state === 'installed') {
//         //       await registration.update()
//         //       window.location.reload()
//         //       if (document.querySelector('.toast'))
//         //         document.querySelector('.toast').classList.add('show')
//         //     }
//         //   }
//         // }
//       },
//       err => {
//         console.log('ServiceWorker registration failed: ', err)
//       }
//     )
//   })
//   // navigator.serviceWorker.addEventListener('controllerchange', function () {
//   //   window.location.reload()
//   //   if (document.querySelector('.toast'))
//   //     document.querySelector('.toast').classList.add('show')
//   // })
// }

const App = function () {
  const reload = () => {
    window.location.reload()
  }

  return (
    <ApolloProvider client={client}>
      <MatomoProvider value={matomoInstance}>
        <Provider store={store}>
          <PersistGate loading={null} persistor={persistor}>
            <Wrapper>
              <LoadingWrapper>
                <Router />
              </LoadingWrapper>
            </Wrapper>
            <ENVFlag />
          </PersistGate>
        </Provider>
        <UpdateToast onClick={reload} />
      </MatomoProvider>
    </ApolloProvider>
  )
}

const Wrapper = ({ children }) => {
  const { enableLinkTracking } = useMatomo()
  enableLinkTracking()
  return <>{children}</>
}

if (process.env.ENV === 'prod') {
  Sentry.init({
    dsn: 'https://8e87b23908134f9ab34619dd27781b41@o53849.ingest.sentry.io/5733088',
    integrations: [new Integrations.BrowserTracing()],
    tracesSampleRate: 0.0
  })
  Sentry.setTag('hdx_version', window.VERSION)
}

console.log('About to render React app');
ReactDOM.render(<App />, document.getElementById('app'))
console.log('React app rendered');
