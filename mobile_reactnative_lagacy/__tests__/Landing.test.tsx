import React from 'react';
import { render, fireEvent } from '@testing-library/react-native';
import { NativeBaseProvider } from 'native-base';
import { NavigationContainer } from '@react-navigation/native';
import Landing from '../src/screens/Landing';

// Mock navigation
const mockNavigate = jest.fn();
const mockNavigation = {
  navigate: mockNavigate,
};

// Mock the screen props
const mockRoute = {
  key: 'Landing',
  name: 'Landing',
  params: undefined,
};

const renderWithProviders = (component: React.ReactElement) => {
  return render(
    <NativeBaseProvider>
      <NavigationContainer>
        {component}
      </NavigationContainer>
    </NativeBaseProvider>
  );
};

describe('Landing Screen', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders correctly', () => {
    const { getByText } = renderWithProviders(
      <Landing navigation={mockNavigation as any} route={mockRoute as any} />
    );
    
    expect(getByText('landing_title')).toBeTruthy();
    expect(getByText('landing_btn_login')).toBeTruthy();
    expect(getByText('landing_btn_signup')).toBeTruthy();
  });

  it('navigates to Login when login button is pressed', () => {
    const { getByText } = renderWithProviders(
      <Landing navigation={mockNavigation as any} route={mockRoute as any} />
    );
    
    const loginButton = getByText('landing_btn_login');
    fireEvent.press(loginButton);
    
    expect(mockNavigate).toHaveBeenCalledWith('Login');
  });

  it('navigates to Signup when signup button is pressed', () => {
    const { getByText } = renderWithProviders(
      <Landing navigation={mockNavigation as any} route={mockRoute as any} />
    );
    
    const signupButton = getByText('landing_btn_signup');
    fireEvent.press(signupButton);
    
    expect(mockNavigate).toHaveBeenCalledWith('Signup');
  });

  it('displays landing list items', () => {
    const { getByText } = renderWithProviders(
      <Landing navigation={mockNavigation as any} route={mockRoute as any} />
    );
    
    expect(getByText('landing_listitems_1')).toBeTruthy();
    expect(getByText('landing_listitems_2')).toBeTruthy();
    expect(getByText('landing_listitems_3')).toBeTruthy();
    expect(getByText('landing_listitems_4')).toBeTruthy();
  });
});
