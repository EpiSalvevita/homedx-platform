import React from 'react';
import { render } from '@testing-library/react-native';
import { NativeBaseProvider } from 'native-base';
import { NavigationContainer } from '@react-navigation/native';
import Navigator from '../src/Navigator';
import { HdxProvider } from '../src/HdxProvider';

// Mock the useHomedx hook
jest.mock('../src/hooks/useHomedx', () => ({
  __esModule: true,
  default: () => ({
    getData: jest.fn(),
  }),
}));

const renderWithProviders = (component: React.ReactElement) => {
  return render(
    <NativeBaseProvider>
      <NavigationContainer>
        <HdxProvider>
          {component}
        </HdxProvider>
      </NavigationContainer>
    </NativeBaseProvider>
  );
};

describe('Navigator', () => {
  it('renders without crashing', () => {
    const { getByTestId } = renderWithProviders(<Navigator />);
    // The navigator should render without throwing an error
    expect(getByTestId).toBeDefined();
  });

  it('shows authentication screens when no token', () => {
    // Mock the context to return no token
    jest.doMock('../src/contexts/HdxContext', () => ({
      HdxContext: {
        Provider: ({ children }: { children: React.ReactNode }) => children,
        Consumer: ({ children }: { children: (value: any) => React.ReactNode }) => 
          children({ token: null }),
      },
    }));

    const { getByText } = renderWithProviders(<Navigator />);
    
    // Should show landing screen content
    expect(getByText('landing_title')).toBeTruthy();
  });
});
