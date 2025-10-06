import { gql } from '@apollo/client';

// User related operations
export const GET_USER_DATA = gql`
  query GetUserData {
    me {
      id
      email
      firstName
      lastName
      phone
      dateOfBirth
      address
      city
      postalCode
      country
      profileImageUrl
    }
  }
`;

export const UPDATE_USER_DATA = gql`
  mutation UpdateUserData($id: String!, $input: UpdateUserInput!) {
    updateUser(id: $id, input: $input) {
      id
      email
      firstName
      lastName
      phone
      dateOfBirth
      address
      city
      postalCode
      country
      profileImageUrl
    }
  }
`;

export const CHECK_EMAIL = gql`
  mutation CheckEmail($email: String!) {
    checkEmail(email: $email) {
      exists
      valid
    }
  }
`;

export const SET_LANGUAGE = gql`
  mutation SetLanguage($language: String!) {
    setLanguage(language: $language) {
      success
    }
  }
`;

// Test related operations
export const GET_TEST_STATUS = gql`
  query GetTestStatus {
    testStatus {
      id
      status
      result
      createdAt
      updatedAt
    }
  }
`;

export const START_NEW_TEST = gql`
  mutation StartNewTest($input: StartTestInput!) {
    startTest(input: $input) {
      id
      status
      result
    }
  }
`;

export const UPLOAD_TEST_PHOTO = gql`
  mutation UploadTestPhoto($file: Upload!, $fileExtension: String!) {
    uploadTestPhoto(file: $file, fileExtension: $fileExtension) {
      success
      objectName
    }
  }
`;

export const UPLOAD_TEST_VIDEO = gql`
  mutation UploadTestVideo(
    $file: Upload!
    $fileExtension: String!
    $head: String
    $headpre: String
  ) {
    uploadTestVideo(
      file: $file
      fileExtension: $fileExtension
      head: $head
      headpre: $headpre
    ) {
      success
      objectName
      validation
    }
  }
`;

export const GET_LAST_RAPID_TEST = gql`
  query GetLastRapidTest {
    lastRapidTest {
      id
      testDate
      result
      status
      createdAt
      updatedAt
    }
  }
`;

export const GET_CWA_LINK = gql`
  query GetCWALink($rapidTestId: ID!) {
    cwaLink(rapidTestId: $rapidTestId)
  }
`;

export const SUBMIT_TEST = gql`
  mutation SubmitTest(
    $videoUrl: String!
    $photoUrl: String!
    $testDeviceUrl: String!
    $testDate: Float!
    $liveToken: String!
    $agreementGiven: Boolean
    $paymentId: String
    $licenseCode: String
    $identityCard1Url: String
    $identityCard2Url: String
    $identifyUrl: String
    $identityCardId: String
  ) {
    submitTest(
      videoUrl: $videoUrl
      photoUrl: $photoUrl
      testDeviceUrl: $testDeviceUrl
      testDate: $testDate
      liveToken: $liveToken
      agreementGiven: $agreementGiven
      paymentId: $paymentId
      licenseCode: $licenseCode
      identityCard1Url: $identityCard1Url
      identityCard2Url: $identityCard2Url
      identifyUrl: $identifyUrl
      identityCardId: $identityCardId
    ) {
      success
      validation
    }
  }
`;

export const GET_LIVE_TOKEN = gql`
  query GetLiveToken {
    liveToken
  }
`;

// License related operations
export const GET_LICENSES = gql`
  query GetLicenses {
    licenses {
      id
      licenseKey
      status
      expiresAt
      maxUses
      usesCount
      userId
      user {
        id
        email
        firstName
        lastName
      }
    }
  }
`;

export const GET_LICENSE = gql`
  query GetLicense($id: String!) {
    license(id: $id) {
      id
      licenseKey
      status
      expiresAt
      maxUses
      usesCount
      userId
      user {
        id
        email
        firstName
        lastName
      }
    }
  }
`;

export const GET_USER_LICENSES = gql`
  query GetUserLicenses($userId: String!) {
    userLicenses(userId: $userId) {
      id
      licenseKey
      status
      expiresAt
      maxUses
      usesCount
      userId
      user {
        id
        email
        firstName
        lastName
      }
    }
  }
`;

export const CREATE_LICENSE = gql`
  mutation CreateLicense($userId: String!, $licenseKey: String!, $status: String!, $maxUses: Float!) {
    createLicense(userId: $userId, licenseKey: $licenseKey, status: $status, maxUses: $maxUses) {
      id
      licenseKey
      status
      expiresAt
      maxUses
      usesCount
      userId
      user {
        id
        email
        firstName
        lastName
      }
    }
  }
`;

export const UPDATE_LICENSE = gql`
  mutation UpdateLicense($id: String!, $maxUses: Float, $status: String) {
    updateLicense(id: $id, maxUses: $maxUses, status: $status) {
      id
      licenseKey
      status
      expiresAt
      maxUses
      usesCount
      userId
      user {
        id
        email
        firstName
        lastName
      }
    }
  }
`;

export const REMOVE_LICENSE = gql`
  mutation RemoveLicense($id: String!) {
    removeLicense(id: $id) {
      id
      licenseKey
      status
      expiresAt
      maxUses
      usesCount
      userId
      user {
        id
        email
        firstName
        lastName
      }
    }
  }
`;

export const INCREMENT_LICENSE_USES = gql`
  mutation IncrementLicenseUses($id: String!) {
    incrementLicenseUses(id: $id) {
      id
      licenseKey
      status
      expiresAt
      maxUses
      usesCount
      userId
      user {
        id
        email
        firstName
        lastName
      }
    }
  }
`;

export const ACTIVATE_LICENSE = gql`
  mutation ActivateLicense($code: String!) {
    activateLicense(code: $code) {
      success
      message
      license {
        id
        licenseKey
        status
        expiresAt
        maxUses
        usesCount
        userId
        user {
          id
          email
          firstName
          lastName
        }
      }
    }
  }
`;

export const ASSIGN_COUPON = gql`
  mutation AssignCoupon($licenseCode: String!) {
    assignCoupon(licenseCode: $licenseCode) {
      success
      message
      licenseCode
    }
  }
`;

// Payment related operations
export const CREATE_PAYMENT = gql`
  mutation CreatePayment($input: CreatePaymentInput!) {
    createPayment(input: $input) {
      id
      status
      amount
      currency
      clientSecret
    }
  }
`;

export const GET_PAYMENT_AMOUNT = gql`
  query GetPaymentAmount {
    paymentAmount {
      amount
      reducedAmount
      discount
      discountType
    }
  }
`;

export const CREATE_PAYMENT_INTENT = gql`
  mutation CreatePaymentIntent {
    createPaymentIntent {
      success
      secret
    }
  }
`;

// System status operations
export const GET_BACKEND_STATUS = gql`
  query GetBackendStatus {
    backendStatus {
      maintenance
      version
      paymentIsActive
      stripe
      cwa
      cwaLaive
      certificatePdf
      flags {
        key
        value
      }
    }
  }
`;

// Certificate related operations
export const GET_CERTIFICATE = gql`
  query GetCertificate($testId: ID!) {
    certificate(testId: $testId) {
      id
      status
      result
      issuedAt
      validUntil
      pdf {
        url
        language
      }
    }
  }
`;

export const UPDATE_CERTIFICATE_LANGUAGE = gql`
  mutation UpdateCertificateLanguage($testId: ID!, $language: String!) {
    updateCertificateLanguage(testId: $testId, language: $language) {
      success
      certificate {
        id
        pdf {
          url
          language
        }
      }
    }
  }
`;

export const DOWNLOAD_CERTIFICATE_PDF = gql`
  mutation DownloadCertificatePdf {
    downloadCertificatePdf {
      success
      pdf
    }
  }
`;

// System related operations
export const GET_COUNTRY_CODES = gql`
  query GetCountryCodes {
    countryCodes
  }
`;

// User related operations
export const RESET_AUTHENTICATION = gql`
  mutation ResetAuthentication {
    resetAuthentication {
      success
    }
  }
`;

export const RESET_CWA_LINK = gql`
  mutation ResetCWALink {
    resetCWALink {
      success
    }
  }
`;

export const GET_PROFILE_IMAGE = gql`
  query GetProfileImage {
    profileImage
  }
`;

export const GET_QR_CODE = gql`
  query GetQRCode {
    qrCode
  }
`;

// Identity card related operations
export const UPLOAD_ID_FRONT_PHOTO = gql`
  mutation UploadIdFrontPhoto($file: Upload!, $fileExtension: String!) {
    uploadIdFrontPhoto(file: $file, fileExtension: $fileExtension) {
      success
      objectName
    }
  }
`;

export const UPLOAD_ID_BACK_PHOTO = gql`
  mutation UploadIdBackPhoto($file: Upload!, $fileExtension: String!) {
    uploadIdBackPhoto(file: $file, fileExtension: $fileExtension) {
      success
      objectName
    }
  }
`;

// Legal pages operations
export const GET_LEGAL_PAGES = gql`
  query GetLegalPages($input: GetLegalPagesInput) {
    getLegalPages(input: $input) {
      pages {
        id
        type
        title
        content
        language
        version
        isActive
        createdAt
        updatedAt
      }
      total
    }
  }
`;

export const GET_LEGAL_PAGE = gql`
  query GetLegalPage($input: GetLegalPageInput!) {
    getLegalPage(input: $input) {
      id
      type
      title
      content
      language
      version
      isActive
      createdAt
      updatedAt
    }
  }
`;

export const GET_PRIVACY_POLICY = gql`
  query GetPrivacyPolicy($language: String = "de") {
    getPrivacyPolicy(language: $language) {
      id
      type
      title
      content
      language
      version
      isActive
      createdAt
      updatedAt
    }
  }
`;

export const GET_IMPRESSUM = gql`
  query GetImpressum($language: String = "de") {
    getImpressum(language: $language) {
      id
      type
      title
      content
      language
      version
      isActive
      createdAt
      updatedAt
    }
  }
`;

export const GET_TERMS_AND_CONDITIONS = gql`
  query GetTermsAndConditions($language: String = "de") {
    getTermsAndConditions(language: $language) {
      id
      type
      title
      content
      language
      version
      isActive
      createdAt
      updatedAt
    }
  }
`; 