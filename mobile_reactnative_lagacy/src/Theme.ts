import { extendTheme } from 'native-base'

const HdxTheme = extendTheme({
  colors: {
    primary: {
      50: '#800343',
      100: '#800343',
      200: '#800343',
      300: '#800343',
      400: '#800343',
      500: '#800343',
      600: '#800343',
      700: '#800343',
      800: '#800343',
      900: '#800343'
    }
  },
  components: {
    Button: {
      variants: {}
    }
  },
  config: {
    initialColorMode: 'light'
  },
  fontConfig: {
    Manrope: {
      100: {
        normal: 'Manrope-Regular'
      },
      200: {
        normal: 'Manrope-Regular'
      },
      300: {
        normal: 'Manrope-Regular'
      },
      400: {
        normal: 'Manrope-Regular'
      },
      500: {
        normal: 'Manrope-Regular'
      },
      600: {
        normal: 'Manrope-SemiBold'
      },
      700: {
        normal: 'Manrope-Bold'
      }
    }
  },
  fonts: {
    heading: 'Manrope',
    body: 'Manrope',
    mono: 'Manrope'
  }
})

export default HdxTheme
