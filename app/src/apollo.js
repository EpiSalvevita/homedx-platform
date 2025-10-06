import { ApolloClient, InMemoryCache, from, HttpLink } from '@apollo/client';
import { setContext } from '@apollo/client/link/context';
import { onError } from '@apollo/client/link/error';
import { RetryLink } from '@apollo/client/link/retry';

// Create the http link
const httpLink = new HttpLink({
  uri: process.env.GRAPHQL_URL || 'http://localhost:4000/graphql',
});

// Create the auth link
const authLink = setContext((_, { headers }) => {
  // get the authentication token from local storage if it exists
  const token = localStorage.getItem('auth_token');
  // return the headers to the context so httpLink can read them
  return {
    headers: {
      ...headers,
      authorization: token ? `Bearer ${token}` : "",
    }
  }
});

// Create the error handling link
const errorLink = onError(({ graphQLErrors, networkError, operation, forward }) => {
  if (graphQLErrors) {
    graphQLErrors.forEach(({ message, locations, path }) => {
      console.error(
        `[GraphQL error]: Message: ${message}, Location: ${locations}, Path: ${path}`
      );
    });
  }

  if (networkError) {
    console.error(`[Network error]: ${networkError}`);
    // Don't redirect on network errors - just log them
    // This prevents the app from breaking when backend is not available
  }

  // Let the error propagate to the component
  return forward(operation);
});

// Create the retry link
const retryLink = new RetryLink({
  delay: {
    initial: 300, // First retry after 300ms
    max: 3000,    // Maximum delay between retries
    jitter: true  // Add randomness to the delay
  },
  attempts: {
    max: 3,       // Maximum number of retries
    retryIf: (error, _operation) => {
      // Retry on network errors and 5xx server errors
      return !!error && (error.statusCode >= 500 || error.statusCode === 0);
    }
  }
});

// Create the Apollo Client instance
export const client = new ApolloClient({
  link: from([retryLink, errorLink, authLink, httpLink]),
  cache: new InMemoryCache({
    typePolicies: {
      Query: {
        fields: {
          // Add field policies here if needed
        }
      }
    }
  }),
  defaultOptions: {
    watchQuery: {
      fetchPolicy: 'cache-and-network',
      errorPolicy: 'ignore',
    },
    query: {
      fetchPolicy: 'network-only',
      errorPolicy: 'ignore',
    },
    mutate: {
      errorPolicy: 'ignore',
    },
  },
}); 