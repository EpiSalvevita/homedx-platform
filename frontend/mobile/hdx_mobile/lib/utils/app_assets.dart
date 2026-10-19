/// Bundled image paths under [assets/images/].
///
/// Brand files come from `work/brand/style-guide/` (official logos + illustrations).
class AppAssets {
  /// Official horizontal lockup: cube + homeDX (Main / ICON + TYPE).
  static const String logo = 'assets/images/brand/logo-full.png';
  static const String logoFull = logo;
  static const String logoOnDark = 'assets/images/brand/logo-full-white.png';
  static const String logoIcon = 'assets/images/brand/logo-icon.png';
  static const String logoStacked = 'assets/images/brand/logo-stacked.png';
  static const String logoWordmark = 'assets/images/brand/logo.png';

  static const String digitalDoctor =
      'assets/images/illustrations/digital-doctor.png';
  static const String healthcareApp =
      'assets/images/illustrations/healthcare-app.png';
  static const String doctorAppointment =
      'assets/images/illustrations/doctor-appointment.png';
  static const String healthMonitoring =
      'assets/images/illustrations/health-monitoring.png';
  static const String medicationReminder =
      'assets/images/illustrations/medication-reminder.png';
  static const String bloodPressureCheck =
      'assets/images/illustrations/blood-pressure-check.png';
  static const String relaxedRecovery =
      'assets/images/illustrations/relaxed-recovery.png';
  static const String firstAidBag =
      'assets/images/illustrations/first-aid-bag.png';
  static const String pharmacyBag =
      'assets/images/illustrations/pharmacy-bag.png';
  static const String pills = 'assets/images/illustrations/pills.png';
  static const String microscope = 'assets/images/illustrations/microscope.png';
  static const String virus = 'assets/images/illustrations/virus.png';
  static const String notifications =
      'assets/images/illustrations/notifications.png';
  static const String certificates =
      'assets/images/illustrations/certificates.png';

  /// Head crops from the official doctor characters (circle-friendly).
  static const String doctorAvatarFemale =
      'assets/images/illustrations/doctor-avatar-female.png';
  static const String doctorAvatarMale =
      'assets/images/illustrations/doctor-avatar-male.png';

  static const List<String> doctorAvatarsFemale = [doctorAvatarFemale];
  static const List<String> doctorAvatarsMale = [doctorAvatarMale];
  static const List<String> doctorPortraits = [
    ...doctorAvatarsFemale,
    ...doctorAvatarsMale,
  ];

  /// Demo / seed given names used to pick a matching illustration.
  /// Real portraits should come from the API (`imageUrl`); this is a UI hint.
  static const Set<String> _femaleGivenNames = {
    'sarah',
    'anna',
    'julia',
    'maria',
    'lea',
    'claudia',
    'laura',
    'lisa',
    'katrin',
    'sophie',
    'emma',
    'mia',
    'hanna',
    'lena',
  };
  static const Set<String> _maleGivenNames = {
    'michael',
    'klaus',
    'jonas',
    'tobias',
    'thomas',
    'andreas',
    'peter',
    'stefan',
    'martin',
    'jan',
    'lukas',
    'max',
    'paul',
  };

  static int _stableHash(String value) {
    var hash = 0;
    for (final code in value.codeUnits) {
      hash = (hash * 31 + code) & 0x7fffffff;
    }
    return hash;
  }

  static String givenNameFromDisplayName(String name) {
    var rest = name.trim();
    final title = RegExp(r'^(dr\.?|prof\.?)\s+', caseSensitive: false);
    while (title.hasMatch(rest)) {
      rest = rest.replaceFirst(title, '');
    }
    if (rest.isEmpty) return '';
    return rest.split(RegExp(r'\s+')).first.toLowerCase();
  }

  /// Same doctor always maps to the same face. Women get the female
  /// illustration, men the male one — not a blind hash over both.
  static String doctorPortraitFor(String doctorId, {String? doctorName}) {
    final given = doctorName == null ? '' : givenNameFromDisplayName(doctorName);
    final List<String> pool;
    if (_femaleGivenNames.contains(given)) {
      pool = doctorAvatarsFemale;
    } else if (_maleGivenNames.contains(given)) {
      pool = doctorAvatarsMale;
    } else {
      pool = doctorPortraits;
    }
    return pool[_stableHash(doctorId) % pool.length];
  }

  static const String loginDoctor = digitalDoctor;
  static const String doctorExplaining = digitalDoctor;
  static const String doctorRelaxed = doctorAppointment;
  static const String patientWomanPhone = healthcareApp;
  static const String patientOlder = healthMonitoring;
  static const String patientManHome = relaxedRecovery;

  static const String iconDna = microscope;
  static const String iconFirstAid = firstAidBag;

  /// Home quick-action icons (Figma frame `50:554`).
  static const String iconHomeHeart = 'assets/images/icons/heart.png';
  static const String iconHomeCalendar = 'assets/images/icons/calendar.png';
  static const String iconHomeBag = pharmacyBag;

  /// Bluetooth screens (Phosphor duotone).
  static const String iconBluetooth = 'assets/images/icons/ph_bluetooth-duotone.png';
  static const String iconBluetoothSlash = 'assets/images/icons/ph_bluetooth-slash-duotone.png';

  /// Official lockup aspect is 1226×200.
  static const double logoLoginWidth = 270;
  static const double logoLoginHeight = 44;

  static const double logoHeaderWidth = 196;
  static const double logoHeaderHeight = 32;

  static const String marketingCubeProduct = microscope;
  static const String marketingSchnelltestProduct = microscope;
  static const String marketingStoryTeam = healthcareApp;
  static const String marketingLifestyleHome = relaxedRecovery;
  static const String marketingVideoConsultation = digitalDoctor;
  static const String marketingTerminBuchen = doctorAppointment;
}
