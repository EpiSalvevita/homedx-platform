import { gql } from '@apollo/client';
import { client } from '../apollo';

const LOGIN_MUTATION = gql`
  mutation Login($input: LoginInput!) {
    login(input: $input) {
      access_token
      user {
        id
        email
        firstName
        lastName
      }
    }
  }
`;

const SIGNUP_MUTATION = gql`
  mutation Signup($input: SignupInput!) {
    signup(input: $input) {
      access_token
      user {
        id
        email
        firstName
        lastName
      }
    }
  }
`;

export const login = async (email, password) => {
  try {
    const { data } = await client.mutate({
      mutation: LOGIN_MUTATION,
      variables: {
        input: { email, password }
      }
    });
    
    if (data.login.access_token) {
      localStorage.setItem('auth_token', data.login.access_token);
      localStorage.setItem('user', JSON.stringify(data.login.user));
    }
    
    return data.login;
  } catch (error) {
    console.error('Login error:', error);
    throw error;
  }
};

export const signup = async (email, password, firstName, lastName) => {
  try {
    const { data } = await client.mutate({
      mutation: SIGNUP_MUTATION,
      variables: {
        input: { email, password, firstName, lastName }
      }
    });
    
    if (data.signup.access_token) {
      localStorage.setItem('auth_token', data.signup.access_token);
      localStorage.setItem('user', JSON.stringify(data.signup.user));
    }
    
    return data.signup;
  } catch (error) {
    console.error('Signup error:', error);
    throw error;
  }
};

export const logout = () => {
  localStorage.removeItem('auth_token');
  localStorage.removeItem('user');
  client.resetStore();
}; 