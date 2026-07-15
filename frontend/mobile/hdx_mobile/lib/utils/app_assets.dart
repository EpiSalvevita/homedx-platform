/// Bundled image paths under [assets/images/].
class AppAssets {
  static const String logo = 'assets/images/brand/logo.png';
  static const String loginDoctor = 'assets/images/illustrations/Doc.png';
  /// TEMPORARY: AI-generated preview asset for comparison on the landing
  /// page hero — not a final decision, remove or promote after review.
  static const String elderlyPatientPreview = 'assets/images/illustrations/elderly-patient-preview.png';
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
  static const String marketingStoryTeam =
      'assets/images/marketing/story-team.png';
  static const String marketingLifestyleHome =
      'assets/images/marketing/lifestyle-home.png';
}
