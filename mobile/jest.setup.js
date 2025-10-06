// Jest setup file for React Native testing

// Mock react-native-config
jest.mock('react-native-config', () => ({
  default: {
    API_URL: 'http://localhost:3000',
    ENV: 'test',
  },
}));

// Mock react-native modules that might cause issues in tests
jest.mock('react-native/Libraries/Animated/NativeAnimatedHelper');

// Mock AsyncStorage
jest.mock('@react-native-async-storage/async-storage', () =>
  require('@react-native-async-storage/async-storage/jest/async-storage-mock')
);

// Mock react-native-splash-screen
jest.mock('react-native-splash-screen', () => ({
  hide: jest.fn(),
  show: jest.fn(),
}));

// Mock react-native-vision-camera
jest.mock('react-native-vision-camera', () => ({
  Camera: {
    getCameraDeviceById: jest.fn(),
    getAvailableCameraDevices: jest.fn(),
  },
  useCameraDevices: jest.fn(() => ({ back: null, front: null })),
  useFrameProcessor: jest.fn(),
}));

// Mock react-native-ble-plx
jest.mock('react-native-ble-plx', () => ({
  BleManager: jest.fn(),
}));

// Mock react-native-fs
jest.mock('react-native-fs', () => ({
  DocumentDirectoryPath: '/mock/path',
  writeFile: jest.fn(),
  readFile: jest.fn(),
  exists: jest.fn(),
  mkdir: jest.fn(),
}));

// Mock react-native-image-picker
jest.mock('react-native-image-picker', () => ({
  launchImageLibrary: jest.fn(),
  launchCamera: jest.fn(),
}));

// Mock react-native-video
jest.mock('react-native-video', () => 'Video');

// Mock @react-native-community/datetimepicker
jest.mock('@react-native-community/datetimepicker', () => {
  const React = require('react');
  const { View } = require('react-native');
  return {
    __esModule: true,
    default: (props) => React.createElement(View, props),
    DateTimePickerEvent: {},
  };
});

// Mock react-native-mov-to-mp4
jest.mock('react-native-mov-to-mp4', () => ({
  convertMovToMp4: jest.fn(),
}));

// Mock react-native-localize
jest.mock('react-native-localize', () => ({
  getLocales: jest.fn(() => [{ countryCode: 'US', languageTag: 'en-US', languageCode: 'en' }]),
  getNumberFormatSettings: jest.fn(() => ({ decimalSeparator: '.', groupingSeparator: ',' })),
  getCalendar: jest.fn(() => 'gregorian'),
  getCountry: jest.fn(() => 'US'),
  getCurrencies: jest.fn(() => ['USD']),
  getTemperatureUnit: jest.fn(() => 'fahrenheit'),
  getTimeZone: jest.fn(() => 'America/New_York'),
  uses24HourClock: jest.fn(() => false),
  usesMetricSystem: jest.fn(() => false),
  addEventListener: jest.fn(),
  removeEventListener: jest.fn(),
}));

// Mock i18next
jest.mock('i18next', () => ({
  t: (key) => key,
  changeLanguage: jest.fn(),
}));

// Mock react-i18next
jest.mock('react-i18next', () => ({
  useTranslation: () => ({
    t: (key) => key,
    i18n: {
      changeLanguage: jest.fn(),
    },
  }),
}));

// Mock react-dom for Native Base compatibility
jest.mock('react-dom', () => ({
  createPortal: (node) => node,
  findDOMNode: () => null,
}));

// Mock @react-aria/utils
jest.mock('@react-aria/utils', () => ({
  useId: () => 'test-id',
  useLayoutEffect: jest.fn(),
  useEffect: jest.fn(),
  useRef: () => ({ current: null }),
  useMemo: (fn) => fn(),
  useCallback: (fn) => fn,
  useReducer: (reducer, initialState) => [initialState, jest.fn()],
  useState: (initial) => [initial, jest.fn()],
  useContext: () => ({}),
  createContext: () => ({}),
  forwardRef: (fn) => fn,
  memo: (fn) => fn,
  useImperativeHandle: jest.fn(),
  useDebugValue: jest.fn(),
  useDeferredValue: (value) => value,
  useTransition: () => [false, jest.fn()],
  useSyncExternalStore: (subscribe, getSnapshot) => getSnapshot(),
  useInsertionEffect: jest.fn(),
}));

// Silence the warning: Animated: `useNativeDriver` is not supported
jest.mock('react-native/Libraries/Animated/NativeAnimatedHelper');
