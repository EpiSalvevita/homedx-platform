/// Bundled image paths under [assets/images/].
class AppAssets {
  static const String logo = 'assets/images/brand/logo.png';

  static const String doctorClipboard =
      'assets/images/illustrations/doctor-no-neck-standing-clipboard.png';
  static const String doctorExplaining =
      'assets/images/illustrations/doctor-no-neck-explaining.png';
  static const String doctorRelaxed =
      'assets/images/illustrations/doctor-no-neck-relaxed-standing.png';
  static const String doctorSeated =
      'assets/images/illustrations/doctor-no-neck-seated-consult.png';

  /// Head-cropped avatar variants (circle-friendly). Full-body assets stay
  /// on empty states / auth; these are only for doctor tiles.
  static const String doctorAvatarClipboard =
      'assets/images/illustrations/doctor-avatar-clipboard.png';
  static const String doctorAvatarExplaining =
      'assets/images/illustrations/doctor-avatar-explaining.png';
  static const String doctorAvatarRelaxed =
      'assets/images/illustrations/doctor-avatar-relaxed.png';
  static const String doctorAvatarSeated =
      'assets/images/illustrations/doctor-avatar-seated.png';

  static const List<String> doctorAvatarsFemale = [
    doctorAvatarClipboard,
    doctorAvatarExplaining,
  ];
  static const List<String> doctorAvatarsMale = [
    doctorAvatarRelaxed,
    doctorAvatarSeated,
  ];
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

  /// Same doctor always maps to the same face. Women get the two woman
  /// illustrations, men the two men — not a blind hash over all four.
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
  static const String patientOlder =
      'assets/images/illustrations/patient-no-neck-older-standing.png';
  static const String patientWomanPhone =
      'assets/images/illustrations/patient-no-neck-woman-phone.png';
  static const String patientManHome =
      'assets/images/illustrations/patient-no-neck-man-home.png';

  /// Original doctor illustration (`Doc.png`) — the style source for the set.
  static const String doctorOriginal = 'assets/images/illustrations/Doc.png';

  /// Doctor-auth illustration (clipboard variant).
  static const String loginDoctor = doctorClipboard;
  static const String iconDna = 'assets/images/icons/DNA.png';
  static const String iconHeartbeat = 'assets/images/icons/Heartbeat.png';
  static const String iconFirstAid = 'assets/images/icons/Box.png';

  /// Home quick-action icons (Figma frame `50:554`).
  static const String iconHomeHeart = 'assets/images/icons/heart.png';
  static const String iconHomeCalendar = 'assets/images/icons/calendar.png';
  static const String iconHomeBag = 'assets/images/icons/bag.png';

  /// Bluetooth screens (Phosphor duotone).
  static const String iconBluetooth = 'assets/images/icons/ph_bluetooth-duotone.png';
  static const String iconBluetoothSlash = 'assets/images/icons/ph_bluetooth-slash-duotone.png';

  /// Figma login hero logo (`50:1560`): 189.04×40.43, color #142543.
  static const double logoLoginWidth = 189.04;
  static const double logoLoginHeight = 40.43;

  /// Figma home header logo (`50:623`): 139×23.
  static const double logoHeaderWidth = 139;
  static const double logoHeaderHeight = 23;

  /// Marketing page placeholders — replace with final assets in assets/images/marketing/.
  static const String marketingCubeProduct =
      'assets/images/marketing/cube-product.png';
  static const String marketingSchnelltestProduct =
      'assets/images/marketing/schnelltest-product.jpg';
  static const String marketingStoryTeam =
      'assets/images/marketing/story-team.png';
  static const String marketingLifestyleHome =
      'assets/images/marketing/lifestyle-home.png';
  static const String marketingVideoConsultation =
      'assets/images/marketing/video-consultation.jpg';
  static const String marketingTerminBuchen =
      'assets/images/marketing/termin-buchen.jpg';
}
