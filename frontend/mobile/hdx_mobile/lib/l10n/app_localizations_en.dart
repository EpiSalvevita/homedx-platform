// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get payFailed => 'Payment failed';

  @override
  String get payCancelled => 'Payment was cancelled';

  @override
  String get cardPaymentTitle => 'Card payment';

  @override
  String get processing => 'Processing…';

  @override
  String get payButton => 'Pay';

  @override
  String get amountDue => 'Amount due:';

  @override
  String get cardStripeNotice =>
      'Card details are entered securely via Stripe. The app never processes card numbers directly.';

  @override
  String get paypalNotConfirmed => 'The PayPal payment could not be confirmed';

  @override
  String paypalWebViewError(String description) {
    return 'WebView error: $description';
  }

  @override
  String get paypalOrderFailed => 'The PayPal order could not be created';

  @override
  String get paypalTitle => 'PayPal payment';

  @override
  String get paySuccess => 'Payment successful';

  @override
  String get orderConfirmed =>
      'Your order has been confirmed. You will receive a confirmation in the app.';

  @override
  String paymentFailedWith(String error) {
    return 'Payment failed: $error';
  }

  @override
  String get paypalSuccess => 'PayPal payment successful';

  @override
  String get paypalCancelled => 'PayPal payment cancelled';

  @override
  String paypalFailedWith(String error) {
    return 'PayPal payment failed: $error';
  }

  @override
  String get sepaStarted => 'SEPA transfer started';

  @override
  String get sepaStartedSubtitle =>
      'Please transfer the amount within 3–5 business days. Your order stays reserved until then.';

  @override
  String get copiedToClipboard => 'Bank details copied to clipboard';

  @override
  String get sepaConfirmTitle => 'Confirm SEPA transfer';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get sepaTitle => 'SEPA transfer';

  @override
  String get bankDetails => 'Bank details';

  @override
  String get ibanLabel => 'IBAN:';

  @override
  String get copy => 'Copy';

  @override
  String get bicLabel => 'BIC:';

  @override
  String get accountHolderLabel => 'Account holder:';

  @override
  String get referenceLabel => 'Payment reference:';

  @override
  String get bankDetailsOptional => 'Your bank details (optional)';

  @override
  String get bankDetailsOptionalNote =>
      'These details are optional and are only stored for your reference.';

  @override
  String get ibanOptional => 'IBAN (optional)';

  @override
  String get invalidIban => 'Invalid IBAN';

  @override
  String get bicOptional => 'BIC (optional)';

  @override
  String get invalidBic => 'Invalid BIC';

  @override
  String get accountHolderOptional => 'Account holder (optional)';

  @override
  String get confirmTransfer => 'Confirm transfer';

  @override
  String get sepaConfirmBody =>
      'Please transfer the amount within 3–5 business days to the account below. Use the payment ID as the payment reference.';

  @override
  String get sepaNotice =>
      'Please transfer the amount within 3–5 business days. Use the payment ID as the payment reference so we can match your payment.';

  @override
  String get amountLabel => 'Amount:';

  @override
  String get methodCard => 'Credit card';

  @override
  String get methodBankTransfer => 'Bank transfer';

  @override
  String get methodCrypto => 'Crypto';

  @override
  String get paymentGeneric => 'Payment';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusFailed => 'Failed';

  @override
  String get statusRefunded => 'Refunded';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusUnknown => 'Unknown';

  @override
  String get paymentsTitle => 'Payments';

  @override
  String get paymentsOverview => 'Overview of your payments and orders.';

  @override
  String get paymentsLoadError => 'Payments could not be loaded';

  @override
  String get checkConnectionRetry =>
      'Please check your connection and try again.';

  @override
  String get retry => 'Try again';

  @override
  String get noPaymentsTitle => 'No payments yet';

  @override
  String get noPaymentsMessage => 'Completed payments appear here.';

  @override
  String get paymentDetailsTitle => 'Payment details';

  @override
  String get paymentLoadError => 'Payment could not be loaded';

  @override
  String get paymentMethodLabel => 'Payment method';

  @override
  String get dateLabel => 'Date';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get purchasedItems => 'Purchased items';

  @override
  String get noLineItemsNote =>
      'No item details are stored for this payment. Products from new shop purchases are shown here.';

  @override
  String get itemFallback => 'Item';

  @override
  String get backToPayments => 'Back to payments';

  @override
  String get videoStartFailed => 'The video call could not be started';

  @override
  String get videoInvalidUrl => 'Invalid video link';

  @override
  String get videoTitle => 'Video call';

  @override
  String get videoOpenFailed => 'The video call could not be opened';

  @override
  String get videoOpenedInNewTab => 'The video call was opened in a new tab.';

  @override
  String get videoOpenedHint => 'If no new tab opened, use the button below.';

  @override
  String get videoOpenAgain => 'Open again';

  @override
  String get videoBack => 'Back';

  @override
  String get videoStartCall => 'Start video call';

  @override
  String apptLoadSlotsFailed(String error) {
    return 'Could not load appointments: $error';
  }

  @override
  String get apptSelectSlotFirst => 'Please select an appointment';

  @override
  String get apptBooked => 'Appointment booked';

  @override
  String get apptBookedMessage =>
      'Your appointment has been booked successfully.';

  @override
  String get apptDoctor => 'Doctor';

  @override
  String get apptType => 'Type';

  @override
  String get apptOnlineConsultation => 'Online consultation';

  @override
  String get apptOk => 'OK';

  @override
  String get apptBookFailed => 'Could not book the appointment';

  @override
  String apptErrorWith(String error) {
    return 'Error: $error';
  }

  @override
  String get apptBookAppointment => 'Book appointment';

  @override
  String get apptBooking => 'Booking…';

  @override
  String apptAfterTest(String testName) {
    return 'Appointment after $testName';
  }

  @override
  String get apptConsultationType => 'Consultation type';

  @override
  String get apptVideoViaHomeDx => 'Video call via HomeDX';

  @override
  String get apptAvailable => 'Available appointments';

  @override
  String get apptNoSlots => 'No appointments available';

  @override
  String get apptNoSlotsRetry => 'Please try again later.';

  @override
  String get apptNotesOptional => 'Notes (optional)';

  @override
  String get apptNotesHint => 'Additional information for the doctor…';

  @override
  String get apptCancelAppointment => 'Cancel appointment';

  @override
  String get apptCancelBody =>
      'Do you really want to cancel this appointment? You can optionally send a message to the other person.';

  @override
  String get apptCancelMessage => 'Message (optional)';

  @override
  String get apptCancelReasonHint => 'Reason for cancellation…';

  @override
  String get apptCancelled => 'Appointment cancelled';

  @override
  String get apptCancelFailed => 'Cancellation failed';

  @override
  String get apptGender => 'Gender';

  @override
  String get apptPatient => 'Patient';

  @override
  String get apptDateTime => 'Appointment';

  @override
  String get apptKind => 'Type';

  @override
  String get apptOnSite => 'In-person appointment';

  @override
  String get apptRelatedTest => 'Related test';

  @override
  String get apptNotes => 'Notes';

  @override
  String get apptJoinVideoCall => 'Join video call';

  @override
  String get apptNotFound => 'Appointment not found';

  @override
  String get apptDetailsTitle => 'Appointment details';

  @override
  String get apptMyAppointments => 'My appointments';

  @override
  String get apptNewAppointment => 'New appointment';

  @override
  String get apptTapForDetails => 'Tap an entry for details.';

  @override
  String get apptLoadFailed => 'Appointments could not be loaded';

  @override
  String get apptNoAppointments => 'No appointments yet';

  @override
  String get apptBookPrompt =>
      'Book an appointment with a doctor to see it here.';

  @override
  String get apptFindDoctor => 'Find a doctor';

  @override
  String get apptUpcoming => 'Upcoming';

  @override
  String get apptPast => 'Past';

  @override
  String get docDoctorFallback => 'Doctor';

  @override
  String docWelcome(String name) {
    return 'Welcome, $name';
  }

  @override
  String get docOverview =>
      'Overview of your appointments and video consultations today.';

  @override
  String get docAvailability => 'Availability';

  @override
  String get docDashboard => 'Dashboard';

  @override
  String get docTodaysAppointments => 'Today\'s appointments';

  @override
  String get docNoAppointmentsToday => 'No appointments today';

  @override
  String get docAppointmentsTodayHint =>
      'As soon as patients book, today\'s appointments will appear here.';

  @override
  String get docRheumaCheckForms => 'RheumaCheck questionnaires';

  @override
  String get docFormB => 'Form B';

  @override
  String get docFormBSubtitle => 'Standard method & care pathway';

  @override
  String get docFormD => 'Form D';

  @override
  String get docFormDSubtitle => 'Feasibility & benefit';

  @override
  String get docAllAppointments => 'All appointments';

  @override
  String get docTapAppointmentForDetails => 'Tap an appointment for details.';

  @override
  String get docListView => 'List';

  @override
  String get docCalendarView => 'Calendar';

  @override
  String get docBookedAppointmentsHere =>
      'Booked patient appointments will appear here.';

  @override
  String get docAvailabilityIntro =>
      'Set when patients can book appointments with you. You can add several time slots per day, e.g. morning and afternoon.';

  @override
  String get docWeeklyHours => 'Weekly consulting hours';

  @override
  String get docMonday => 'Monday';

  @override
  String get docTuesday => 'Tuesday';

  @override
  String get docWednesday => 'Wednesday';

  @override
  String get docThursday => 'Thursday';

  @override
  String get docFriday => 'Friday';

  @override
  String get docFrom => 'From';

  @override
  String get docTo => 'To';

  @override
  String docInvalidRange(String day, String start, String end) {
    return 'Invalid time slot on $day: \"$start\" – \"$end\". \"To\" must be after \"From\".';
  }

  @override
  String get docAvailabilitySaved => 'Availability saved';

  @override
  String get docSaveFailed => 'Saving failed';

  @override
  String get docAvailabilityLoadFailed => 'Availability could not be loaded';

  @override
  String get docSaving => 'Saving…';

  @override
  String get docSaveChanges => 'Save changes';

  @override
  String get docRemoveSlot => 'Remove time slot';

  @override
  String get docAddSlot => 'Add time slot';

  @override
  String get docSelectDoctor => 'Choose a doctor';

  @override
  String get docSearchHint => 'Search for doctor or specialty…';

  @override
  String docRecommendedSpecialists(String specialization) {
    return 'Recommended specialists: $specialization';
  }

  @override
  String get docNoMatchingSpecialist => 'No matching specialist available';

  @override
  String docNoSpecialistFound(String testName, String specialization) {
    return 'We could not find a specialist in $specialization for $testName at the moment. Here are all available doctors.';
  }

  @override
  String docBasedOnTest(String testName, String specialization) {
    return 'Based on your positive $testName, we recommend doctors specializing in $specialization.';
  }

  @override
  String get docTestFallback => 'test';

  @override
  String get docDoctorsLoadFailed => 'Doctors could not be loaded';

  @override
  String get docNoDoctorsFound => 'No doctors found';

  @override
  String get docNoDoctorsHint => 'Try a different search or language.';

  @override
  String get docLanguage => 'Language';

  @override
  String get docAll => 'All';

  @override
  String get docWeekView => 'Week';

  @override
  String get docMonthView => 'Month';

  @override
  String get docToday => 'Today';

  @override
  String docMoreCount(String count) {
    return '+$count more';
  }

  @override
  String get docNoAppointmentsOnDay => 'No appointments on this day';

  @override
  String get docPickAnotherDay => 'Choose another day in the calendar.';

  @override
  String get authActivatingAccount => 'Your account is being activated…';

  @override
  String get authAlreadyAccountPrompt => 'Already have an account? ';

  @override
  String get authBackToSignIn => 'Back to sign-in';

  @override
  String get authBackToSignUp => 'Back to registration';

  @override
  String get authBrandConfirmationDoctorSubtitle =>
      'Confirm your email address to activate your doctor account.';

  @override
  String get authBrandConfirmationSubtitle =>
      'Almost there. Confirm your email address and you are ready to go.';

  @override
  String get authBrandConfirmationTitle => 'Practice created';

  @override
  String get authBrandDoctorLoginSubtitle =>
      'Manage appointments, availability and video consultations in your browser.';

  @override
  String get authBrandDoctorPortalTitle => 'Doctor portal';

  @override
  String get authBrandForgotDoctorSubtitle =>
      'Enter the email address of your doctor account and we will send you a link.';

  @override
  String get authBrandForgotSubtitle =>
      'We will email you a link that lets you reset your password.';

  @override
  String get authBrandLoginSubtitle =>
      'Rapid tests, doctor appointments and results, all in one place.';

  @override
  String get authBrandResetDoctorSubtitle =>
      'Choose a new password for your doctor account.';

  @override
  String get authBrandResetSubtitle =>
      'Choose a new password and then sign in again.';

  @override
  String get authBrandSignupDoctorSubtitle =>
      'Manage appointments and hold video consultations with patients.';

  @override
  String get authBrandSignupSubtitle =>
      'Get tested at home, book a doctor and receive your results online.';

  @override
  String get authBrandSignupTitle => 'Register practice';

  @override
  String get authCanSignInNow => 'You can now sign in.';

  @override
  String get authCheckInboxIntro =>
      'Check your inbox at this address and activate your account using the confirmation link:';

  @override
  String get authClinicAddressHint => 'Street, postcode, city';

  @override
  String get authClinicAddressLabel => 'Practice address';

  @override
  String get authClinicAddressRequired => 'Please enter your practice address';

  @override
  String get authConfirmPasswordLabel => 'Confirm password';

  @override
  String get authConfirmPasswordRequired => 'Please confirm your password';

  @override
  String get authConfirmationBody =>
      'Your account has been created. Please confirm your email address to continue.';

  @override
  String get authConfirmationDoctorBody =>
      'Your doctor account has been created. Please confirm your email address to continue.';

  @override
  String get authEmailInvalid => 'Invalid email address';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailRequired => 'Please enter your email address';

  @override
  String get authErrorEmailAlreadyRegistered =>
      'This email address is already registered. Please sign in or use a different email address.';

  @override
  String get authErrorEmailNotEditable =>
      'Email cannot be changed here. Please reload the page (Ctrl+Shift+R) and try again.';

  @override
  String get authErrorGenderInvalid => 'Please select a valid gender.';

  @override
  String get authErrorInvalidCredentials =>
      'Email or password is incorrect. Please check your entries and try again.';

  @override
  String get authErrorInvalidRequest =>
      'Invalid request. Please check your entries.';

  @override
  String get authErrorInvalidRequestRetry =>
      'Invalid request. Please check your entries and try again.';

  @override
  String get authErrorLoginFailed => 'Sign-in failed. Please try again.';

  @override
  String get authErrorRegistrationFailed => 'Registration failed';

  @override
  String get authErrorSessionExpired => 'Please sign in again.';

  @override
  String get authFirstNameLabel => 'First name';

  @override
  String get authFirstNameRequired => 'Please enter your first name';

  @override
  String get authForgotPasswordLink => 'Forgot password?';

  @override
  String get authForgotPasswordSubtitle =>
      'Enter your email address. We will send you a link to reset your password.';

  @override
  String get authGoToHomepage => 'Go to homepage';

  @override
  String get authGoToSignIn => 'Go to sign-in';

  @override
  String get authHidePassword => 'Hide password';

  @override
  String get authLastNameLabel => 'Last name';

  @override
  String get authLastNameRequired => 'Please enter your last name';

  @override
  String get authLoginDoctorSubtitle => 'Sign in with your doctor account.';

  @override
  String get authLoginDoctorTitle => 'Doctor sign-in';

  @override
  String get authLoginFailed => 'Sign-in failed';

  @override
  String get authLoginSubtitle => 'Enter your email address and password.';

  @override
  String get authLoginTitle => 'Sign in to your account';

  @override
  String get authNewPassword => 'New password';

  @override
  String get authNextStep => 'Next step';

  @override
  String get authNoAccountPrompt => 'No account yet? ';

  @override
  String get authOpenLinkHint =>
      'Open the link in the email to activate your account. Please also check your spam folder.';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authPasswordMinLength => 'At least 8 characters';

  @override
  String get authPasswordNeedsDigit => 'At least one number';

  @override
  String get authPasswordNeedsLowercase => 'At least one lowercase letter';

  @override
  String get authPasswordNeedsSpecial => 'At least one special character';

  @override
  String get authPasswordNeedsUppercase => 'At least one uppercase letter';

  @override
  String get authPasswordRequired => 'Please enter a password';

  @override
  String get authPasswordRequirementsTitle => 'Password requirements';

  @override
  String get authPasswordRuleDigit => 'At least one number (0–9)';

  @override
  String get authPasswordRuleLowercase => 'At least one lowercase letter (a–z)';

  @override
  String get authPasswordRuleSpecial =>
      'At least one special character (e.g. !@#\$)';

  @override
  String get authPasswordRuleUppercase => 'At least one uppercase letter (A–Z)';

  @override
  String get authPasswordsMismatch => 'Passwords do not match';

  @override
  String get authRegister => 'Register';

  @override
  String get authRegistrationSuccessTitle => 'Registration successful';

  @override
  String get authRequestNewLink => 'Request new link';

  @override
  String get authResendEmail => 'Resend email';

  @override
  String get authResetLinkInvalid =>
      'The reset link is invalid. Please request a new link.';

  @override
  String get authResetLinkInvalidError =>
      'The reset link is invalid or has expired. Please request a new link.';

  @override
  String get authResetPasswordSubtitle =>
      'Set a new password for your account.';

  @override
  String get authResetPasswordTitle => 'Reset password';

  @override
  String get authSavePassword => 'Save password';

  @override
  String get authSendLink => 'Send link';

  @override
  String get authSendingEmail => 'Sending email…';

  @override
  String get authShowPassword => 'Show password';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authSignupDoctorSubtitle => 'Enter the details of your practice.';

  @override
  String get authSignupDoctorTitle => 'Create doctor account';

  @override
  String get authSignupSubtitle =>
      'Fill in the form. It only takes a few minutes.';

  @override
  String get authSignupTitle => 'Create account';

  @override
  String get authSpecializationLabel => 'Specialty';

  @override
  String get authSpecializationRequired => 'Please select a specialty';

  @override
  String get authVerifyChecking =>
      'The confirmation link from your email is being checked.';

  @override
  String get authVerifyEmailTitle => 'Confirm email';

  @override
  String get authVerifyLinkInvalid =>
      'The confirmation link is invalid or has expired. Please request a new email.';

  @override
  String get authYourEmailAddress => 'Your email address';

  @override
  String get testTypeCrp => 'CRP (C-reactive protein)';

  @override
  String get testTypeGenericName => 'Rapid test';

  @override
  String get cubeWebStubMessage =>
      'Health tests with the Cube device are only available in the Android app (Bluetooth). Install the mobile app or use the web version for appointments and results.';

  @override
  String get btGoToHome => 'Go to home';

  @override
  String get btBack => 'Back';

  @override
  String get testStartFailed => 'The test could not be started';

  @override
  String get testPreAnamnesisTitle => 'Pre-test medical history';

  @override
  String get testAnamnesisPrompt =>
      'Would you like to complete the medical history questionnaire (form A) before the RheumaCheck test? It only takes a few minutes.';

  @override
  String get testSkip => 'Skip';

  @override
  String get testStartAnamnesis => 'Start medical history';

  @override
  String get testSelectTitle => 'Select test type';

  @override
  String get testLoadError => 'Failed to load tests';

  @override
  String get testNoneAvailable => 'No tests available';

  @override
  String get testRheumaDescriptionFallback =>
      'Rheumatoid arthritis screening test';

  @override
  String get testAgreeTermsError => 'Please agree to the terms and conditions.';

  @override
  String get testSubmitTitle => 'Complete test';

  @override
  String testCubeResult(String result) {
    return 'Cube result: $result';
  }

  @override
  String get testPhotoOptional => 'Test photo (optional)';

  @override
  String get testVideoOptional => 'Test video (optional)';

  @override
  String get testIdFront => 'ID front side';

  @override
  String get testIdBack => 'ID back side';

  @override
  String get testAgreementText =>
      'I confirm that the information I provided is correct and I accept the test terms.';

  @override
  String get testTermsLink => 'Test terms';

  @override
  String get testPrivacyLink => 'Privacy policy';

  @override
  String get testSending => 'Sending…';

  @override
  String get testSubmitButton => 'Submit test';

  @override
  String testUploadedAs(String name) {
    return 'Uploaded: $name';
  }

  @override
  String get btConnected => 'Connected';

  @override
  String get btUnknownDevice => 'Unknown device';

  @override
  String get btServices => 'Services';

  @override
  String get btRead => 'Read';

  @override
  String get btWrite => 'Write';

  @override
  String get btSubscribe => 'Subscribe';

  @override
  String get btDisconnect => 'Disconnect';

  @override
  String get btNoDeviceConnected => 'No device connected';

  @override
  String get btSearchPrompt =>
      'Search for a Bluetooth device and connect to get started';

  @override
  String get btSearchDevices => 'Search for devices';

  @override
  String get btDisconnectTitle => 'Disconnect device';

  @override
  String get btDisconnectConfirm => 'Do you really want to disconnect?';

  @override
  String get btDisconnected => 'Disconnected';

  @override
  String get btReadData => 'Data read';

  @override
  String btReadFailed(String error) {
    return 'Read failed: $error';
  }

  @override
  String get btWriteDataTitle => 'Write data';

  @override
  String get btHexInputLabel => 'Enter data (hex format)';

  @override
  String get btHexInputHint => 'e.g. 01 02 03';

  @override
  String get btWriteSuccess => 'Data written successfully';

  @override
  String btWriteFailed(String error) {
    return 'Write failed: $error';
  }

  @override
  String get btNotificationData => 'Notification data';

  @override
  String get btSubscribed => 'Notifications subscribed';

  @override
  String btSubscribeFailed(String error) {
    return 'Subscribe failed: $error';
  }

  @override
  String get btClose => 'Close';

  @override
  String get btNoFilePath =>
      'No file path available. Please choose the file via “Files” or place it in Downloads.';

  @override
  String get btCancelTestTitle => 'Cancel test?';

  @override
  String get btCancelTestBody =>
      'The ongoing measurement will be stopped and you will return to the home page.';

  @override
  String get btContinue => 'Continue';

  @override
  String get btDisconnectTestConfirm =>
      'Do you really want to disconnect? You will need to reconnect to start the test.';

  @override
  String get btCubeDisconnected => 'Cube device disconnected';

  @override
  String get btBluetoothDisabled => 'Bluetooth is turned off';

  @override
  String get btBluetoothRequired =>
      'Bluetooth must be turned on to connect to the Cube device';

  @override
  String get btTurnOnBluetooth => 'Turn on Bluetooth';

  @override
  String get btCubeConnected => 'Cube device connected';

  @override
  String btStatus(String state) {
    return 'Status: $state';
  }

  @override
  String get btReadyToStart => 'Ready to start the test';

  @override
  String btReadyBody(String testName) {
    return 'Your Cube device is connected and ready. You can now continue with the $testName test.';
  }

  @override
  String get btMeasurementConfig => 'Measurement configuration (Cube)';

  @override
  String btConfigFile(String name) {
    return 'Configuration file: $name';
  }

  @override
  String get btConfigDefault =>
      'Default: calibration via RFID from the inserted cassette. To use a `.config`/`.bin` file from the provider instead (as in the Cube sample app), tap “Choose file”.';

  @override
  String get btChooseConfigFile => 'Choose configuration file';

  @override
  String get btRfidMode => 'RFID mode (delete file)';

  @override
  String get btTestStarting => 'Starting test...';

  @override
  String get btStartTest => 'Start test';

  @override
  String get btNoCubeConnected => 'No Cube device connected';

  @override
  String btConnectPrompt(String testName) {
    return 'Please connect your Cube device to continue with the $testName test';
  }

  @override
  String get btSearchCubeDevices => 'Search for Cube devices';

  @override
  String get btPermissionRequired =>
      'Bluetooth “Devices nearby” / scan and connect permission is required. Please allow it in the app settings.';

  @override
  String get btScanStartFailed =>
      'The scan could not be started (the SDK refused to start, e.g. still connected or already scanning). Tap Refresh or restart the app.';

  @override
  String btScanError(String error) {
    return 'Scan error: $error';
  }

  @override
  String get btConnectTimeout =>
      'Connecting to the Cube took too long (60 s). Hold the Cube close to the phone, stop the search with “Stop” and tap “Connect” again. If needed, disconnect the device in the Android Bluetooth settings (don\'t just pair it).';

  @override
  String get btConnectFailed => 'Connection failed';

  @override
  String btConnectError(String error) {
    return 'Connection error: $error';
  }

  @override
  String get btEnableBluetoothPrompt =>
      'Please turn on Bluetooth to search for Cube devices';

  @override
  String get btErrorTitle => 'Error';

  @override
  String get btSearchingCubes => 'Searching for Cube devices...';

  @override
  String get btEnsureCubeOn => 'Make sure your Cube is switched on';

  @override
  String get btNoCubeFound => 'No Cube device found';

  @override
  String get btEnsureCubeInRange =>
      'Make sure your Cube is switched on and within range';

  @override
  String get btCubeDevice => 'Cube device';

  @override
  String get btSearchAgain => 'Search again';

  @override
  String get btConnect => 'Connect';

  @override
  String get testPreparing => 'Preparing measurement...';

  @override
  String get testLeaveConfirm =>
      'Do you want to leave the measurement and return to the home page?';

  @override
  String get testUnknownError => 'Unknown error';

  @override
  String get testMeasurementFailed => 'Measurement failed';

  @override
  String get testBackToStart => 'Back to start';

  @override
  String get testIncubationTime => 'Incubation time';

  @override
  String get testRemaining => 'remaining';

  @override
  String get testInsertWhiteCassette => 'Insert white cassette';

  @override
  String get testInsertTestCassette => 'Insert test cassette';

  @override
  String get testEvaluating => 'Evaluating measurement';

  @override
  String get testLoadingResults => 'Loading results';

  @override
  String get testSubmittingResults => 'Submitting results';

  @override
  String get testResultsTitle => 'Test results';

  @override
  String get testTapForDetails => 'Tap an entry for details.';

  @override
  String get testResultsLoadError => 'Results could not be loaded';

  @override
  String get testNoResultsYet => 'No test results yet';

  @override
  String get testResultsWebHint =>
      'Results will appear here after a test in the Android app.';

  @override
  String get testStartToSeeResults => 'Start a test to see results.';

  @override
  String get testResultTitle => 'Test result';

  @override
  String get testResultPending => 'The test result is not yet available.';

  @override
  String get testDetailedResults => 'Detailed results';

  @override
  String testRecommended(String specialization) {
    return 'Recommended: $specialization';
  }

  @override
  String get testUsabilityQuestionnaire => 'Usability questionnaire (form C)';

  @override
  String get testBackToResults => 'Back to results';

  @override
  String get testBookSpecialist => 'Book a specialist appointment';

  @override
  String get navHome => 'Home';

  @override
  String get navAppointments => 'Appointments';

  @override
  String get navResults => 'Results';

  @override
  String get navQuestionnaires => 'Questionnaires';

  @override
  String get navShop => 'Shop';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navPayments => 'Payment history';

  @override
  String get navProfile => 'Profile';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navAvailability => 'Availability';

  @override
  String get navVideoCall => 'Video call';

  @override
  String get navAppointment => 'Appointment';

  @override
  String get navResult => 'Result';

  @override
  String get navTests => 'Tests';

  @override
  String get navTestPrepare => 'Prepare test';

  @override
  String get navTestSubmit => 'Submit test';

  @override
  String get navTestFallback => 'Test';

  @override
  String get navDoctorFallback => 'Doctor';

  @override
  String get navCertificates => 'Documents';

  @override
  String get navApp => 'App';

  @override
  String get navSignIn => 'Sign in';

  @override
  String get navRegister => 'Register';

  @override
  String get homeUserFallback => 'User';

  @override
  String get homeLogout => 'Log out';

  @override
  String get homeWelcomeBack => 'Welcome back';

  @override
  String homeGreeting(String name) {
    return 'Hello $name — choose a quick action below.';
  }

  @override
  String get homeGettingStarted => 'Getting started';

  @override
  String get homeRecentActivity => 'Recent activity';

  @override
  String get homeQuickActions => 'Quick actions';

  @override
  String get homeStartTest => 'Start test';

  @override
  String get homeOnlineConsultation => 'Online consultation';

  @override
  String get homeMyAppointments => 'My appointments';

  @override
  String get notifMarkAllRead => 'Mark all as read';

  @override
  String get notifLoadError => 'Notifications could not be loaded';

  @override
  String get notifTapHint => 'Tap a notification to mark it as read.';

  @override
  String get notifEmptyTitle => 'No notifications';

  @override
  String get notifEmptyMessage => 'You\'re all caught up.';

  @override
  String get profileSaved => 'Profile saved';

  @override
  String profileErrorWith(String message) {
    return 'Error: $message';
  }

  @override
  String get profileLoadError => 'Error loading profile';

  @override
  String get profileFirstName => 'First name';

  @override
  String get profileFirstNameRequired => 'First name is required';

  @override
  String get profileLastName => 'Last name';

  @override
  String get profileLastNameRequired => 'Last name is required';

  @override
  String get profileEmail => 'Email';

  @override
  String get profileEmailRequired => 'Email is required';

  @override
  String get profilePhone => 'Mobile number';

  @override
  String get profileAddress => 'Address';

  @override
  String get profilePostcode => 'Postcode';

  @override
  String get profileCity => 'City';

  @override
  String get profileCountry => 'Country';

  @override
  String get profileGender => 'Gender';

  @override
  String get profileGenderRequired => 'Please select a gender';

  @override
  String get profileGenderMale => 'Male';

  @override
  String get profileGenderFemale => 'Female';

  @override
  String get profileGenderDivers => 'Diverse';

  @override
  String get profileSaving => 'Saving…';

  @override
  String get profileSaveChanges => 'Save changes';

  @override
  String get profileCubeSdkTitle => 'Cube device (SDK)';

  @override
  String get profileCubeSdkChecking => 'Checking Cube SDK…';

  @override
  String profileVersion(String version) {
    return 'Version: $version';
  }

  @override
  String get profileLicenseValid => 'Bundled license: valid (per SDK)';

  @override
  String get profileLicenseInvalid =>
      'Bundled license: invalid or expired — import a new cube_license.dat from the provider and rebuild the app.';

  @override
  String get shopTitle => 'Shop';

  @override
  String get shopFilterAll => 'All';

  @override
  String get shopFilterTestStrips => 'Test strips';

  @override
  String get shopFilterTestDevices => 'Test devices';

  @override
  String get shopLoadError => 'The shop could not be loaded';

  @override
  String get shopNoProducts => 'No products found';

  @override
  String get shopNoProductsMessage =>
      'No items are currently available in this category.';

  @override
  String shopItemAdded(String name) {
    return '$name added';
  }

  @override
  String get shopSoldOut => 'Sold out';

  @override
  String get shopCategoryTestStrip => 'Test strips';

  @override
  String get shopCategoryTestDevice => 'Test device';

  @override
  String get shopCategoryAccessory => 'Accessories';

  @override
  String get shopCategoryOther => 'Other';

  @override
  String get shopQuantity => 'Quantity';

  @override
  String shopTotalAmount(String amount) {
    return 'Total: $amount €';
  }

  @override
  String get shopAddToCart => 'Add to cart';

  @override
  String get shopUnavailable => 'Currently unavailable';

  @override
  String shopAddedToCart(String name) {
    return '$name added to cart';
  }

  @override
  String get shopViewCart => 'View cart';

  @override
  String get shopGoToShop => 'Go to shop';

  @override
  String get cartTitle => 'Cart';

  @override
  String get cartCheckout => 'Proceed to checkout';

  @override
  String get cartEmpty => 'Your cart is empty';

  @override
  String get cartEmptyMessage => 'Browse the shop and add products.';

  @override
  String get cartRemove => 'Remove';

  @override
  String get cartTotal => 'Total';

  @override
  String get checkoutTitle => 'Checkout';

  @override
  String get checkoutSummary => 'Order summary';

  @override
  String get checkoutPayNow => 'Pay now';

  @override
  String get checkoutEmptyMessage => 'Add products to proceed to checkout.';

  @override
  String get checkoutNotLoggedIn => 'You are not signed in.';

  @override
  String get checkoutInvalidAmount => 'Invalid amount';

  @override
  String get orderTitle => 'Order completed';

  @override
  String get orderSubtitle =>
      'Thank you. Your order has been placed successfully.';

  @override
  String get orderBackToHome => 'Back to home';

  @override
  String orderTotal(String amount, String currency) {
    return 'Total: $amount $currency';
  }

  @override
  String get certTitle => 'Documents';

  @override
  String get certDetailTitle => 'Document';

  @override
  String get certTapHint => 'Tap a document for details.';

  @override
  String get certLoadError => 'Documents could not be loaded';

  @override
  String get certEmpty => 'No documents yet';

  @override
  String get certEmptyMessage =>
      'Documents appear here after a completed test.';

  @override
  String get certTest => 'Test';

  @override
  String get certStatusIssued => 'Issued';

  @override
  String get certStatusDraft => 'Draft';

  @override
  String get certStatusExpired => 'Expired';

  @override
  String get certStatusRevoked => 'Revoked';

  @override
  String get certTypeTestResult => 'Test result';

  @override
  String get certTypeVaccination => 'Vaccination';

  @override
  String get certTypeRecovery => 'Recovery';

  @override
  String get certTypeMedicalClearance => 'Medical clearance';

  @override
  String get certSharePdf => 'Share PDF';

  @override
  String get certLoading => 'Loading…';

  @override
  String get certNotFound => 'Document not found';

  @override
  String get certPdfDownload => 'PDF download';

  @override
  String get certPdfDownloadHint =>
      'Open the HomeDX app on your smartphone to share this document as a PDF.';

  @override
  String certPdfSaved(String path) {
    return 'PDF saved: $path';
  }

  @override
  String certErrorWith(String error) {
    return 'Error: $error';
  }

  @override
  String get certResult => 'Result';

  @override
  String get certValidity => 'Validity';

  @override
  String get certIssuedOn => 'Issued on';

  @override
  String get questTitle => 'Questionnaires';

  @override
  String get questLoadError => 'Questionnaires could not be loaded';

  @override
  String get questEmpty => 'No questionnaires available';

  @override
  String get questEmptyMessage =>
      'Questionnaires will appear here once they are unlocked.';

  @override
  String get questHubIntroDoctor =>
      'As part of RheumaCheck, these questionnaires collect structured information from the perspective of the rheumatology network and on how well the approach can be implemented in practice. Your answers support the accompanying research and the further development of HomeDX. They do not replace a diagnosis and do not provide treatment recommendations.';

  @override
  String get questHubIntroPatient =>
      'As part of RheumaCheck, these questionnaires help us record your details before the test and your feedback after use in a structured way. This helps us improve HomeDX and better understand care. The questionnaires do not replace a medical diagnosis.';

  @override
  String get questBadgeBeforeTest => 'Before the test';

  @override
  String get questBadgeNetwork => 'Rheumatology network';

  @override
  String get questBadgeAfterUse => 'After use';

  @override
  String get questBadgePilot => 'Pilot / implementation';

  @override
  String questModuleLabel(String moduleId) {
    return 'Form $moduleId';
  }

  @override
  String get questResume => 'Continue draft';

  @override
  String get questStartNow => 'Start now';

  @override
  String get questDoneTitle => 'Questionnaire completed';

  @override
  String get questThanks => 'Thank you!';

  @override
  String questDoneMessage(String moduleId) {
    return 'Form $moduleId was submitted successfully. Your answers have been saved.';
  }

  @override
  String get questBackToList => 'Back to questionnaires';

  @override
  String get questContinue => 'Continue';

  @override
  String get questIntroPatientNotice =>
      'This questionnaire does not replace a medical diagnosis. For acute or severe symptoms, please contact a doctor.';

  @override
  String get questConsentCheckbox =>
      'I agree that my answers may be stored for the evaluation of the RheumaCheck project.';

  @override
  String get questIntroResearchNotice =>
      'This questionnaire supports the research and piloting of RheumaCheck. No diagnoses are made.';

  @override
  String get questStart => 'Start questionnaire';

  @override
  String questStepProgress(String index, String total) {
    return 'Step $index of $total';
  }

  @override
  String get questBack => 'Back';

  @override
  String get questNext => 'Next';

  @override
  String get questSubmit => 'Submit';

  @override
  String questFallbackTitle(String moduleId) {
    return 'Questionnaire $moduleId';
  }

  @override
  String get questLoadFailed => 'Questionnaire could not be loaded';

  @override
  String questAnswerRequired(String label) {
    return 'Please answer: $label';
  }

  @override
  String get questConsentRequired => 'Please confirm the consent notice.';

  @override
  String get questSelectHint => 'Select';

  @override
  String get questBadgeFollowUp => 'Follow-up';

  @override
  String get questNotAssigned => 'Not scheduled yet';

  @override
  String get questNotAssignedMessage =>
      'This questionnaire is not scheduled yet. It becomes available after a separate invitation.';

  @override
  String get questRequiredMarker => 'Required';

  @override
  String get questUnsupportedQuestion =>
      'This question cannot be shown in this version.';

  @override
  String questRankHint(int maximum) {
    return 'Choose up to $maximum answers in order of preference.';
  }

  @override
  String get questRevisionConflict =>
      'Your draft was changed elsewhere in the meantime. Please reload the questionnaire.';

  @override
  String get questCheckAnswers =>
      'Please check your answers. Some questions are incomplete or invalid.';

  @override
  String get questSaveFailed => 'Saving failed. Please try again.';

  @override
  String get questNoQuestions => 'No further questions';

  @override
  String get questNoQuestionsMessage =>
      'There are no further questions in this questionnaire for your answers so far.';

  @override
  String get questDemoBanner =>
      'DEMO – synthetic example answers only. Nothing is saved or sent.';

  @override
  String get questDemoPrefill => 'Pre-fill with synthetic example';

  @override
  String get questOpenOverview => 'Answer overview';

  @override
  String get questOverviewTitle => 'Answer overview';

  @override
  String get questOverviewHint =>
      'Check your answers. “Change” takes you straight to that section.';

  @override
  String get questEditSection => 'Change';

  @override
  String get questNotAnswered => 'not answered';

  @override
  String get questSendAnswers => 'Submit';

  @override
  String get questDoneYourAnswers => 'Your answers';

  @override
  String get questDoneNextStep =>
      'This overview only shows what you entered. It is not an assessment and not a diagnosis.';

  @override
  String get questOverviewUnavailable =>
      'Your answer overview could not be loaded.';

  @override
  String get webRoleAreaPatient => 'Patient area';

  @override
  String get webRoleAreaDoctor => 'Doctor area';

  @override
  String get questResumePromptTitle => 'Saved draft found';

  @override
  String get questResumePromptBody =>
      'Do you want to continue your saved draft? It is only loaded once you confirm.';

  @override
  String get questResumeConfirm => 'Continue draft';

  @override
  String get questResumeBack => 'Back to the list';
}
