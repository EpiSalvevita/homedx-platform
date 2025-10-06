import React from 'react';
import { renderHook, act } from '@testing-library/react-hooks';
import useHomedx from '../src/hooks/useHomedx';
import { HdxProvider } from '../src/HdxProvider';

// Mock the Network module
jest.mock('../src/Network', () => ({
  __esModule: true,
  default: {
    get: jest.fn(),
    post: jest.fn(),
    put: jest.fn(),
    delete: jest.fn(),
  },
}));

// Mock the HdxContext
const mockContextValue = {
  token: 'test-token',
  setToken: jest.fn(),
  userData: null,
  setUserData: jest.fn(),
  testData: [],
  setTestData: jest.fn(),
  plugins: [],
  setPlugins: jest.fn(),
  backendStatus: 'online' as const,
  setBackendStatus: jest.fn(),
  authorizationStatus: 'authorized' as const,
  setAuthorizationStatus: jest.fn(),
};

const wrapper = ({ children }: { children: React.ReactNode }) => (
  <HdxProvider>{children}</HdxProvider>
);

describe('useHomedx Hook', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('initializes with correct default values', () => {
    const { result } = renderHook(() => useHomedx(), { wrapper });

    expect(result.current.isLoadingResults).toBe(true);
    expect(result.current.isLoadingTests).toBe(true);
  });

  it('provides getData function', () => {
    const { result } = renderHook(() => useHomedx(), { wrapper });

    expect(typeof result.current.getData).toBe('function');
  });

  it('provides login function', () => {
    const { result } = renderHook(() => useHomedx(), { wrapper });

    expect(typeof result.current.login).toBe('function');
  });

  it('provides signup function', () => {
    const { result } = renderHook(() => useHomedx(), { wrapper });

    expect(typeof result.current.signup).toBe('function');
  });

  it('provides logout function', () => {
    const { result } = renderHook(() => useHomedx(), { wrapper });

    expect(typeof result.current.logout).toBe('function');
  });

  it('provides updateUserData function', () => {
    const { result } = renderHook(() => useHomedx(), { wrapper });

    expect(typeof result.current.updateUserData).toBe('function');
  });

  it('provides uploadTestData function', () => {
    const { result } = renderHook(() => useHomedx(), { wrapper });

    expect(typeof result.current.uploadTestData).toBe('function');
  });

  it('provides downloadTestData function', () => {
    const { result } = renderHook(() => useHomedx(), { wrapper });

    expect(typeof result.current.downloadTestData).toBe('function');
  });

  it('provides deleteTestData function', () => {
    const { result } = renderHook(() => useHomedx(), { wrapper });

    expect(typeof result.current.deleteTestData).toBe('function');
  });

  it('provides getPlugins function', () => {
    const { result } = renderHook(() => useHomedx(), { wrapper });

    expect(typeof result.current.getPlugins).toBe('function');
  });

  it('provides getBackendStatus function', () => {
    const { result } = renderHook(() => useHomedx(), { wrapper });

    expect(typeof result.current.getBackendStatus).toBe('function');
  });

  it('provides getAuthorizationStatus function', () => {
    const { result } = renderHook(() => useHomedx(), { wrapper });

    expect(typeof result.current.getAuthorizationStatus).toBe('function');
  });

  it('provides uploadMedia function', () => {
    const { result } = renderHook(() => useHomedx(), { wrapper });

    expect(typeof result.current.uploadMedia).toBe('function');
  });

  it('provides downloadMedia function', () => {
    const { result } = renderHook(() => useHomedx(), { wrapper });

    expect(typeof result.current.downloadMedia).toBe('function');
  });

  it('provides deleteMedia function', () => {
    const { result } = renderHook(() => useHomedx(), { wrapper });

    expect(typeof result.current.deleteMedia).toBe('function');
  });

  it('provides convertMovToMp4 function', () => {
    const { result } = renderHook(() => useHomedx(), { wrapper });

    expect(typeof result.current.convertMovToMp4).toBe('function');
  });
});
