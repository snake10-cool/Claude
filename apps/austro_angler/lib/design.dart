import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Aussehen der App: das bisherige („Klassisch“) oder der Look aus dem
/// Promo-Video („Neu“: Petrol, schmale Großbuchstaben-Titel, rot-weiß-roter
/// Streifen). Unabhängig davon wählt man hell, dunkel oder wie das Handy.
enum AppDesign {
  klassisch('Klassisch'),
  neu('Neu');

  const AppDesign(this.titel);
  final String titel;
}

enum Darstellung {
  system('Wie das Handy', ThemeMode.system),
  hell('Hell', ThemeMode.light),
  dunkel('Dunkel', ThemeMode.dark);

  const Darstellung(this.titel, this.modus);
  final String titel;
  final ThemeMode modus;
}

/// Lässt Widgets wissen, welches Design gerade aktiv ist.
class DesignInfo extends ThemeExtension<DesignInfo> {
  const DesignInfo({required this.neu, required this.akzent});

  final bool neu;

  /// Kräftige Akzentfarbe für große Zahlen und Ringe.
  final Color akzent;

  static DesignInfo von(BuildContext context) =>
      Theme.of(context).extension<DesignInfo>() ??
      DesignInfo(neu: false, akzent: Theme.of(context).colorScheme.primary);

  @override
  DesignInfo copyWith({bool? neu, Color? akzent}) =>
      DesignInfo(neu: neu ?? this.neu, akzent: akzent ?? this.akzent);

  @override
  DesignInfo lerp(DesignInfo? other, double t) =>
      t < 0.5 ? this : (other ?? this);
}

const _gruen = Color(0xFF1E6F5C);

ThemeData designThema(AppDesign design, Brightness helligkeit) =>
    design == AppDesign.neu ? _neu(helligkeit) : _klassisch(helligkeit);

ThemeData _klassisch(Brightness helligkeit) => ThemeData(
      colorSchemeSeed: _gruen,
      brightness: helligkeit,
      useMaterial3: true,
      // Am Handy übernimmt das System die Emojis; im Test (Store-Screenshots)
      // braucht es die Schrift ausdrücklich.
      fontFamilyFallback: const ['NotoColorEmoji'],
      // Kleinere Beschriftung, damit "Gewässer" & Co. nicht umbrechen.
      navigationBarTheme: const NavigationBarThemeData(
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 13),
      ),
      extensions: [
        DesignInfo(
          neu: false,
          akzent: helligkeit == Brightness.dark
              ? const Color(0xFF7FD6BC)
              : _gruen,
        ),
      ],
    );

/// Farben des neuen Designs.
class _Farben {
  const _Farben.dunkel()
      : grund = const Color(0xFF0B2226),
        karte = const Color(0xFF103236),
        karteHoch = const Color(0xFF16403F),
        rand = const Color(0xFF1F4A4C),
        akzent = const Color(0xFF3FD0C9),
        aufAkzent = const Color(0xFF052526),
        text = const Color(0xFFEAF4F2),
        leise = const Color(0xFF9DB8B4),
        warnung = const Color(0xFFE0A43A);

  const _Farben.hell()
      : grund = const Color(0xFFEEF4F3),
        karte = Colors.white,
        karteHoch = const Color(0xFFE2EEEC),
        rand = const Color(0xFFCADCD9),
        akzent = const Color(0xFF0F8C86),
        aufAkzent = Colors.white,
        text = const Color(0xFF0E1F21),
        leise = const Color(0xFF4F6664),
        warnung = const Color(0xFFB7741A);

  final Color grund, karte, karteHoch, rand, akzent, aufAkzent, text, leise,
      warnung;
}

ThemeData _neu(Brightness helligkeit) {
  final dunkel = helligkeit == Brightness.dark;
  final f = dunkel ? const _Farben.dunkel() : const _Farben.hell();
  final schema = ColorScheme(
    brightness: helligkeit,
    primary: f.akzent,
    onPrimary: f.aufAkzent,
    primaryContainer: dunkel ? const Color(0xFF16504F) : const Color(0xFFC9EEEA),
    onPrimaryContainer: dunkel ? const Color(0xFFD5FAF6) : const Color(0xFF053F3C),
    secondary: f.warnung,
    onSecondary: dunkel ? const Color(0xFF2B1A00) : Colors.white,
    secondaryContainer: dunkel ? const Color(0xFF3A2C12) : const Color(0xFFFBEBCF),
    onSecondaryContainer: dunkel ? const Color(0xFFFBE2B4) : const Color(0xFF3E2600),
    tertiary: dunkel ? const Color(0xFF8FD4FF) : const Color(0xFF1C6A9A),
    onTertiary: dunkel ? const Color(0xFF00324D) : Colors.white,
    tertiaryContainer: dunkel ? const Color(0xFF173C52) : const Color(0xFFD6ECFA),
    onTertiaryContainer: dunkel ? const Color(0xFFCDEBFF) : const Color(0xFF07344F),
    error: dunkel ? const Color(0xFFFF7A70) : const Color(0xFFC0392B),
    onError: Colors.white,
    errorContainer: dunkel ? const Color(0xFF4A1F1C) : const Color(0xFFFADAD6),
    onErrorContainer: dunkel ? const Color(0xFFFFDAD5) : const Color(0xFF5C120C),
    surface: f.grund,
    onSurface: f.text,
    onSurfaceVariant: f.leise,
    surfaceContainerLowest: f.grund,
    surfaceContainerLow: f.karte,
    surfaceContainer: f.karte,
    surfaceContainerHigh: f.karteHoch,
    surfaceContainerHighest: f.karteHoch,
    outline: f.rand,
    outlineVariant: f.rand,
    inverseSurface: f.text,
    onInverseSurface: f.grund,
    inversePrimary: f.akzent,
  );

  // Barlow für Text, Barlow Condensed für Labels, Bebas Neue für große Titel.
  TextStyle b(double groesse, FontWeight dicke, {double? abstand}) =>
      TextStyle(
        fontFamily: 'Barlow',
        fontSize: groesse,
        fontWeight: dicke,
        letterSpacing: abstand,
        color: f.text,
        fontFamilyFallback: const ['NotoColorEmoji'],
      );
  TextStyle c(double groesse, FontWeight dicke, {double? abstand}) =>
      TextStyle(
        fontFamily: 'BarlowCondensed',
        fontSize: groesse,
        fontWeight: dicke,
        letterSpacing: abstand,
        color: f.text,
        fontFamilyFallback: const ['NotoColorEmoji'],
      );
  TextStyle t(double groesse) => TextStyle(
        fontFamily: 'BebasNeue',
        fontSize: groesse,
        letterSpacing: 0.6,
        height: 1.05,
        color: f.text,
        fontFamilyFallback: const ['NotoColorEmoji'],
      );

  final schrift = TextTheme(
    displayLarge: t(56),
    displayMedium: t(46),
    displaySmall: t(38),
    headlineLarge: t(34),
    headlineMedium: t(30),
    headlineSmall: t(26),
    titleLarge: c(22, FontWeight.w700),
    titleMedium: c(18, FontWeight.w600, abstand: 0.2),
    titleSmall: c(16, FontWeight.w600, abstand: 0.2),
    bodyLarge: b(16, FontWeight.w400),
    bodyMedium: b(14.5, FontWeight.w400),
    bodySmall: b(12.5, FontWeight.w400).copyWith(color: f.leise),
    labelLarge: c(16, FontWeight.w600, abstand: 0.4),
    labelMedium: c(13, FontWeight.w600, abstand: 0.8),
    labelSmall: c(11.5, FontWeight.w600, abstand: 1.0),
  );

  final rund = RoundedRectangleBorder(borderRadius: BorderRadius.circular(18));
  return ThemeData(
    useMaterial3: true,
    colorScheme: schema,
    scaffoldBackgroundColor: f.grund,
    fontFamily: 'Barlow',
    fontFamilyFallback: const ['NotoColorEmoji'],
    textTheme: schrift,
    appBarTheme: AppBarTheme(
      backgroundColor: f.grund,
      foregroundColor: f.text,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: t(28),
    ),
    cardTheme: CardThemeData(
      color: f.karte,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: rund.copyWith(side: BorderSide(color: f.rand.withValues(alpha: 0.6))),
      margin: const EdgeInsets.symmetric(vertical: 5),
    ),
    listTileTheme: ListTileThemeData(
      titleTextStyle: c(17, FontWeight.w600),
      subtitleTextStyle: b(13.5, FontWeight.w400).copyWith(color: f.leise),
      iconColor: f.akzent,
    ),
    dividerTheme: DividerThemeData(color: f.rand, thickness: 1),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: f.akzent,
        foregroundColor: f.aufAkzent,
        textStyle: c(17, FontWeight.w700, abstand: 0.5),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: f.akzent,
        side: BorderSide(color: f.akzent, width: 1.4),
        textStyle: c(17, FontWeight.w700, abstand: 0.5),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: f.akzent,
        textStyle: c(16, FontWeight.w700, abstand: 0.4),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: f.karte,
      selectedColor: f.akzent.withValues(alpha: dunkel ? 0.25 : 0.18),
      side: BorderSide(color: f.rand),
      shape: const StadiumBorder(),
      labelStyle: c(14.5, FontWeight.w600),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: f.karte,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: f.rand),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: f.rand),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: f.akzent, width: 1.6),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: f.akzent,
      foregroundColor: f.aufAkzent,
      shape: const StadiumBorder(),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: f.karte,
      surfaceTintColor: Colors.transparent,
      indicatorColor: f.akzent.withValues(alpha: dunkel ? 0.18 : 0.15),
      labelTextStyle: WidgetStateProperty.resolveWith((s) => c(
            12.5,
            FontWeight.w600,
          ).copyWith(
              color: s.contains(WidgetState.selected) ? f.akzent : f.leise)),
      iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
          color: s.contains(WidgetState.selected) ? f.akzent : f.leise)),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: f.akzent,
      unselectedLabelColor: f.leise,
      indicatorColor: f.akzent,
      dividerColor: f.rand,
      labelStyle: c(15, FontWeight.w700, abstand: 0.4),
      unselectedLabelStyle: c(15, FontWeight.w600, abstand: 0.4),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: f.karteHoch,
      contentTextStyle: b(14.5, FontWeight.w500),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: f.akzent.withValues(alpha: 0.2),
        selectedForegroundColor: f.akzent,
        side: BorderSide(color: f.rand),
        textStyle: c(14.5, FontWeight.w600),
      ),
    ),
    extensions: [DesignInfo(neu: true, akzent: f.akzent)],
  );
}

/// Kleiner rot-weiß-roter Streifen (unter Überschriften im Design „Neu“).
class RotWeissRot extends StatelessWidget {
  const RotWeissRot({super.key, this.breite = 34});

  final double breite;

  @override
  Widget build(BuildContext context) {
    const rot = Color(0xFFD7262E);
    Widget balken(Color c) => Container(width: breite, height: 2.6, color: c);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [balken(rot), balken(Colors.white), balken(rot)],
    );
  }
}

/// Lizenzen der eingebauten Schriften (SIL Open Font License).
void schriftLizenzenEintragen() {
  LicenseRegistry.addLicense(() async* {
    for (final (paket, datei) in [
      (['Bebas Neue'], 'assets/schriften/OFL-BebasNeue.txt'),
      (['Barlow', 'Barlow Condensed'], 'assets/schriften/OFL-Barlow.txt'),
    ]) {
      try {
        yield LicenseEntryWithLineBreaks(paket, await rootBundle.loadString(datei));
      } catch (e) {
        debugPrint('Lizenz $datei: $e');
      }
    }
  });
}
