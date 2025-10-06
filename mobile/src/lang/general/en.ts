const shared = {
  email_address: 'Email address',
  password: 'Password'
}

const landing = {
  title: 'The digital test center',
  listitems: {
    1: 'Simply use a test kit from retail',
    2: 'Perform a test with your smartphone',
    3: 'Obtain an officially acknowledged certificate',
    4: 'Secure online payment'
  },
  btn: {
    login: 'Login',
    signup: 'Sign up'
  }
}

const login = {
  title: 'Welcome back!',
  subtitle: 'Enter your email and your password to login',
  prompt__title: 'Login failed',
  prompt__subtitle:
    'Your account data is not correct. Please check your inputs.',
  btn: {
    login: 'Log in',
    forgot_password: 'Forgot your password?'
  }
}

// const signup = {
//   title:
//     'Welcome at homeDX, the virtual rapid test center. You can sign up for participation here.',

//   prompt: {
//     error: {
//       title: 'Failure',
//       subtitle: 'Please check the following:'
//     },
//     success: {
//       title: 'Done!',
//       subtitle: 'Signup successful. Please login in.'
//     }
//   },
//   help: {
//     title: 'Tips for signing up',
//     1: 'Please make sure to create a secure password.',
//     2: 'A secure password complies with our security requirements. You can find those by tapping the "info"-icon',
//     3: 'The bar below the password field indicates your password strength.',
//     4: 'You need a green bar (very strong) to enable the login button.',
//     5: 'Please fill out all fields.'
//   },
//   hint: {
//     title: 'Please enter a secure password:',
//     password: {
//       1: 'It should have at least 8 characters',
//       2: 'Your password should incude lower-and uppercase characters',
//       3: 'Use one of these special characters:',
//       4: 'Do not use number or letter combinations that are real words.',
//       5: 'Do not use dates that could be associated with you.',
//       6: 'Do not use annals',
//       7: 'Avoid passwords like "password123" or similar',
//       8: 'Do not use repetative patterns like „ababab“ or „123456“.',
//       action: 'You are stuck?'
//     }
//   },
//   placeholder: {
//     token: 'Signup token'
//   },
//   validation: {
//     firstname: 'Please enter a first name',
//     lastname: 'Please enter a last name',
//     email_empty: 'Please enter a email',
//     email_invalid: 'Please enter a valid email',
//     exists: 'This email is already in use',
//     password: 'Please enter a password',
//     token_empty: 'Please enter a signup token',
//     token_invalid: 'Invalid signup token',
//     denied: 'The provided token is currently not allowing any new signups'
//   },
//   check: {
//     privacy:
//       'I agree that homeDX GmbH may process my personal data, in particular the data concerning my health, as described in the <1>privacy section</1>. I can revoke this consent at any time in the future *',
//     legal: 'I read the <1>terms and conditions </1> and accept *'
//   },
//   token: {
//     title: 'About the signup token',
//     text: 'Your eligibility to participate in the Berlin project will be verified during the process based on your registration address. If you are not registered in Berlin, you will not be issued a certificate.',
//     hint: {
//       coupon:
//         'If you received a coupon (QR code), you can proceed without entering a signup token'
//     },
//     checkbox: 'I have a signup token'
//   },
//   warning: {
//     subtitle: 'Are you sure you want to proceed without registration token?',
//     text: 'Proceed without registration token only if you want to <1>pay online</1> or have a <3>coupon (QR code)</3>',
//     btn: 'Continue without'
//   }
// }

const signup = {
  data: {
    title: 'Your data',
    text: 'Welcome at homeDX, the virtual rapid test center. You can sign up for participation here. In the first step, fill in your signup data'
  },
  password: {
    title: 'Set password',
    text: 'Set a safe password by either using the randomly generated one or by providing your own'
  },
  token: {
    title: 'Token & Agreement',
    text: 'If you want to use a token you can fill it in below. Otherwise we only need your agreement to our privacy and terms of service information.',
    checkbox: 'Without a token the aquisition of licences is necesarry',
    hint: {
      coupon: 'If you have a coupon (qr-code) you my proceed without a token',
      payment: 'Without a token licenses need to be bought'
    }
  },
  check: {
    privacy:
      'I agree that homeDX GmbH may process my personal data, in particular the data concerning my health, as described in the <1>privacy section</1>. I can revoke this consent at any time in the future *',
    tos: 'I read the <1>terms and conditions </1> and accept *'
  }
}

const nav = {
  home: 'Start',
  profile: 'Profile',
  certificates: 'Certificates'
}

const availableTests = {
  1: {
    name: 'SARS-CoV-2'
  },
  1.1: {
    name: 'Rapidtest',
    description: 'Test your Corona infection'
  },
  1.2: {
    name: 'PCR-Test',
    description: 'Corona PCR-Test with valid certificate incl.'
  }
}

const dashboard = {
  newest_certificate: 'Latest certificate',
  available_tests: 'Available tests'
}

const en = {
  ...shared,
  nav,
  landing,
  login,
  signup,
  dashboard,
  availableTests
}

export default en
