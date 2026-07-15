import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// HomeDX brand palette (hex without #).
class AppTheme {
  static const Color navy = Color(0xFF142543);
  static const Color surface = Color(0xFFF5F5F5);
  static const Color primaryBlue = Color(0xFF3652A5);
  static const Color accentBlue = Color(0xFF80A2F9);
  static const Color accentMint = Color(0xFF8DD2CF);
  static const Color accentCoral = Color(0xFFF8A39E);

  /// Light fill for icon chips and highlights (harmonized with [accentBlue]).
  static const Color primaryLight = Color(0xFFE4E9FB);
  /// Slightly recessed fill for inverted inset info cards (reads clearly on web).
  static const Color insetWellFill = Color(0xFFEBEBEB);

  static const Color background = surface;
  static const Color cardColor = Colors.white;
  /// Default text color for headings, body, buttons on light surfaces (#142543).
  static const Color textColor = navy;
  /// Muted supporting text (labels, hints, captions).
  /// Darkened from the original #5C6980 (~5.5:1 on white) to ~7.8:1 on white,
  /// clearing WCAG AAA for normal text — important for older/low-vision users
  /// reading body copy, not just AA (4.5:1).
  static const Color textColorSecondary = Color(0xFF45536B);
  static const Color errorColor = accentCoral;
  static const Color successColor = accentMint;
  static const Color fieldBackground = Colors.white;

  static const Color primaryColor = primaryBlue;
  static const Color baseColor = background;
  static const Color darkShadow = Color(0xFFC9CED8);
  static const Color secondaryColor = accentBlue;

  /// Strong text/icons on [accentMint] or light backgrounds.
  static const Color onMint = Color(0xFF142543);

  /// Minimum interactive target (WCAG 2.5.5 / Material). Kept at 48 for dense
  /// secondary controls (icon buttons, chips).
  static const double minTouchTarget = 48.0;

  /// Preferred target size for primary actions and elderly-first tap surfaces.
  /// Larger than [minTouchTarget] so buttons/cards are easy to hit with
  /// reduced fine-motor control.
  static const double largeTouchTarget = 56.0;

  /// Visible keyboard/hover focus ring for web accessibility.
  /// Drawn as a foreground border so it never shifts layout.
  static const Color focusRing = primaryBlue;
  static const double focusRingWidth = 2.5;

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: primaryBlue.withValues(alpha: 0.08),
          offset: const Offset(0, 4),
          blurRadius: 20,
        ),
      ];

  /// Deprecated for input fields — use [NeumorphicInsetSurface] (true inset paint).
  /// Kept for non-field surfaces that still use outer neumorphic styling.
  static List<BoxShadow> get neumorphicInset => const [
        BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 4),
        BoxShadow(color: Color(0x4D99A6CE), offset: Offset(4, 4), blurRadius: 10),
      ];

  /// Figma Large button (hover) drop shadows — dark first, then light highlight.
  static List<BoxShadow> get neumorphicRaised => const [
        BoxShadow(
          color: Color(0x4D99A6CE),
          offset: Offset(4, 4),
          blurRadius: 10,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.white,
          offset: Offset(-4, -4),
          blurRadius: 10,
          spreadRadius: 0,
        ),
      ];

  /// Figma Large primary button: height 59.
  static const double buttonHeightLarge = 59;
  /// No vertical inset: the button label is already vertically centered by
  /// [NeumorphicPillButton] within the full (caller-provided) button height.
  /// Adding vertical padding here shrinks the box the label is centered in,
  /// which clips icon/label content whenever a caller sets a `height` smaller
  /// than `buttonPaddingLarge`'s insets would allow (e.g. height: 48).
  static const EdgeInsets buttonPaddingLarge = EdgeInsets.zero;

  static const double screenHorizontalPadding = 24;
  /// Figma pill input (`Search Box` / profile fields): 392×72, radius 100, padding 26.
  static const double fieldHeight = 72;
  static const double pillRadius = 100;
  static const EdgeInsets fieldPadding = EdgeInsets.symmetric(horizontal: 26);
  /// Horizontal gap between prefix icon and text inside a field.
  static const double fieldContentGap = 25;
  /// Vertical spacing between stacked profile/login fields.
  static const double fieldSpacing = 25;

  /// Profile form: same scale as auth [NeumorphicInsetField] (elderly-first).
  static const double profileFieldHeight = fieldHeight;
  static const EdgeInsets profileFieldPadding = fieldPadding;
  static const double profileFieldFontSize = 17;
  static const double profileFieldLabelFontSize = 15;
  static const double profileFieldIconSize = 22;
  static const double profileFieldContentGap = fieldContentGap;
  static const double profileFieldLabelOffsetLeft = 38;
  static const double profileFieldLabelOffsetTop = -10;
  /// Vertical gap between profile field rows (matches auth field spacing).
  static const double profileFieldRowSpacing = fieldSpacing;
  /// Profile page: minimum space above the name; content centers vertically when viewport allows.
  static const double profilePageTopPadding = 48;
  static const double profilePageBottomPadding = 32;

  /// Figma home quick-action cards (`50:587` etc.): 186×138, 20px grid gap.
  static const double quickActionCardAspectRatio = 186 / 138;
  static const double quickActionGridSpacing = 20;
  static const double quickActionCardRadius = 16;
  /// Doctor picker tiles: same width logic as quick actions, slightly taller for text.
  static const double doctorSelectionCardAspectRatio = 186 / 200;

  /// Figma home activity rows (`50:628`): 392×105, radius 14, padding 22×12.
  static const double activityCardHeight = 105;
  static const double activityCardRadius = 14;
  static const EdgeInsets activityCardPadding = EdgeInsets.fromLTRB(22, 12, 22, 12);
  static const double activityCardSpacing = 24;

  /// Figma welcome card (`50:651`): 392×128, same radius/shadows as activity rows.
  static const double welcomeCardHeight = 128;
  static const EdgeInsets welcomeCardPadding = EdgeInsets.fromLTRB(22, 20, 22, 26);

  /// Figma info banner (`50:709`): 392×44, radius 14.
  static const double infoBannerHeight = 44;
  static const double infoInsetCardHeight = 72;
  static const EdgeInsets infoInsetCardPadding = EdgeInsets.symmetric(horizontal: 22, vertical: 14);
  static const double infoBannerHorizontalPadding = 22;
  static const double infoInsetCardSpacing = 12;

  /// Figma test result cards (`50:661`): 392×136, radius 14, raised shadows only.
  static const double testResultCardHeight = 136;
  static const EdgeInsets testResultCardPadding = EdgeInsets.all(22);
  static const double testResultCardSpacing = 20;

  /// Figma test type cards (`50:725`): 392×116, radius 14, raised shadows only.
  static const double testTypeCardHeight = 116;
  static const EdgeInsets testTypeCardPadding = EdgeInsets.all(22);
  static const double testTypeCardSpacing = 20;

  /// Figma result badge (`50:670` Negativ): hug ~81×23, radius 6, padding 14×4.
  static const EdgeInsets resultBadgePadding = EdgeInsets.fromLTRB(14, 4, 14, 4);
  static const double resultBadgeRadius = 6;
  /// Figma `50:674` Positiv badge fill.
  static const Color resultBadgePositive = Color(0xFFFF6D60);
  /// Figma `50:670` Negativ badge fill.
  static const Color resultBadgeNegative = accentBlue;

  /// Figma home top bar (`50:617`): 440×118, Clear Sky fill, single drop shadow.
  static const double homeHeaderHeight = 118;
  static List<BoxShadow> get homeHeaderShadow => const [
        BoxShadow(
          color: Color(0x4D99A6CE),
          offset: Offset(4, 4),
          blurRadius: 10,
          spreadRadius: 0,
        ),
      ];

  static const TextTheme _baseTextTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textColor),
    displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
    displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
    headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: textColor),
    headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textColor),
    headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor),
    titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor),
    titleSmall: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: textColor),
    // Body sizes bumped up one step (elderly-first readability). Material-driven
    // text (dialogs, snackbars, tooltips, list tiles) inherits these.
    bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.normal, color: textColor),
    bodyMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.normal, color: textColor),
    bodySmall: TextStyle(fontSize: 15, fontWeight: FontWeight.normal, color: textColorSecondary),
    labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
    labelMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: textColor),
    labelSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColorSecondary),
  );

  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.rubikTextTheme(_baseTextTheme);

    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.rubik().fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light,
        surface: background,
        primary: primaryBlue,
        onSurface: textColor,
        onSurfaceVariant: textColorSecondary,
      ),
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(size: 24, color: Colors.white),
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(minTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        labelStyle: textTheme.bodyMedium?.copyWith(color: textColorSecondary),
        hintStyle: textTheme.bodyMedium?.copyWith(color: textColorSecondary),
        prefixIconColor: textColorSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(minTouchTarget, minTouchTarget),
          iconSize: 24,
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minLeadingWidth: 40,
        titleTextStyle: textTheme.titleMedium,
        subtitleTextStyle: textTheme.bodyMedium?.copyWith(color: textColorSecondary),
      ),
      dialogTheme: DialogThemeData(
        titleTextStyle: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        contentTextStyle: textTheme.bodyLarge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      chipTheme: ChipThemeData(
        selectedColor: primaryBlue,
        backgroundColor: Colors.white,
        labelStyle: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: primaryBlue.withValues(alpha: 0.3)),
        ),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      dividerTheme: DividerThemeData(color: navy.withValues(alpha: 0.12), thickness: 1),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      ),
      scrollbarTheme: const ScrollbarThemeData(
        thumbVisibility: WidgetStatePropertyAll(false),
        trackVisibility: WidgetStatePropertyAll(false),
      ),
    );
  }
}
