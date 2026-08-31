import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Registered font families from `assets/fonts`.
abstract final class MaidKitFonts {
  static const sans = 'IBM Plex Sans';
  static const mono = 'IBM Plex Mono';
}

/// Spacing scale. Every gap in the app comes from here so vertical rhythm
/// stays consistent across 145 files instead of drifting per-page.
abstract final class MaidKitSpace {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

/// Corner radii. Deliberately restrained: this is a dense desktop tool, and
/// oversized rounding reads as a consumer app and wastes edge pixels.
abstract final class MaidKitRadius {
  static const sm = 4.0;
  static const md = 6.0;
  static const lg = 10.0;
  static const pill = 999.0;
}

/// Motion tokens.
///
/// No bounce or elastic curves anywhere: overshoot on a management tool reads
/// as dated and makes state changes feel unreliable. Everything is
/// decelerate-weighted so it looks like it settles rather than springs.
abstract final class MaidKitMotion {
  /// Hover, focus, pressed. Must feel instant.
  static const instant = Duration(milliseconds: 90);

  /// Chip selection, small reveals, status swaps.
  static const quick = Duration(milliseconds: 160);

  /// Panels, sheets, tab bodies.
  static const normal = Duration(milliseconds: 240);

  /// Full-surface transitions. Longer than this feels slow on desktop.
  static const slow = Duration(milliseconds: 340);

  /// Symmetric moves: resize, reflow, reorder.
  static const standard = Curves.easeInOutCubic;

  /// Appearing: panels in, chips selecting, content arriving.
  static const enter = Curves.easeOutCubic;

  /// Leaving. Faster than [enter] so dismissal never feels sticky.
  static const exit = Curves.easeInCubic;
}

/// Semantic colours and surfaces that Material's ColorScheme has no slot for.
///
/// A server tool lives or dies on state legibility: online, degraded, offline,
/// and connecting must be distinguishable at a glance, in both brightnesses,
/// and without relying on hue alone. These are resolved once here rather than
/// hand-picked per page.
@immutable
class MaidKitSemantics extends ThemeExtension<MaidKitSemantics> {
  const MaidKitSemantics({
    required this.online,
    required this.onlineSurface,
    required this.degraded,
    required this.degradedSurface,
    required this.offline,
    required this.offlineSurface,
    required this.connecting,
    required this.accent,
    required this.onAccent,
    required this.terminalSurface,
    required this.hairline,
    required this.hairlineStrong,
  });

  /// Healthy, reachable, running.
  final Color online;
  final Color onlineSurface;

  /// Reachable but unhappy: high load, stale metrics, partial failure.
  final Color degraded;
  final Color degradedSurface;

  /// Unreachable or stopped.
  final Color offline;
  final Color offlineSurface;

  /// In-flight: connecting, restarting, pending.
  final Color connecting;

  /// The signal colour. Used sparingly for the one thing that matters most on
  /// a surface; loses all meaning if it becomes decoration.
  final Color accent;
  final Color onAccent;

  /// Backdrop behind terminal output. Deeper than `surface` so the terminal
  /// reads as a distinct medium rather than another panel.
  final Color terminalSurface;

  /// Structural dividers. Hierarchy comes from these plus contrast, not from
  /// shadows or nested cards.
  final Color hairline;
  final Color hairlineStrong;

  @override
  MaidKitSemantics copyWith({
    Color? online,
    Color? onlineSurface,
    Color? degraded,
    Color? degradedSurface,
    Color? offline,
    Color? offlineSurface,
    Color? connecting,
    Color? accent,
    Color? onAccent,
    Color? terminalSurface,
    Color? hairline,
    Color? hairlineStrong,
  }) => MaidKitSemantics(
    online: online ?? this.online,
    onlineSurface: onlineSurface ?? this.onlineSurface,
    degraded: degraded ?? this.degraded,
    degradedSurface: degradedSurface ?? this.degradedSurface,
    offline: offline ?? this.offline,
    offlineSurface: offlineSurface ?? this.offlineSurface,
    connecting: connecting ?? this.connecting,
    accent: accent ?? this.accent,
    onAccent: onAccent ?? this.onAccent,
    terminalSurface: terminalSurface ?? this.terminalSurface,
    hairline: hairline ?? this.hairline,
    hairlineStrong: hairlineStrong ?? this.hairlineStrong,
  );

  @override
  MaidKitSemantics lerp(ThemeExtension<MaidKitSemantics>? other, double t) {
    if (other is! MaidKitSemantics) return this;
    return MaidKitSemantics(
      online: Color.lerp(online, other.online, t)!,
      onlineSurface: Color.lerp(onlineSurface, other.onlineSurface, t)!,
      degraded: Color.lerp(degraded, other.degraded, t)!,
      degradedSurface: Color.lerp(degradedSurface, other.degradedSurface, t)!,
      offline: Color.lerp(offline, other.offline, t)!,
      offlineSurface: Color.lerp(offlineSurface, other.offlineSurface, t)!,
      connecting: Color.lerp(connecting, other.connecting, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      terminalSurface: Color.lerp(
        terminalSurface,
        other.terminalSurface,
        t,
      )!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      hairlineStrong: Color.lerp(hairlineStrong, other.hairlineStrong, t)!,
    );
  }

  /// Light-mode semantics.
  ///
  /// Status hues are darkened well past their web-default equivalents so they
  /// still pass text contrast on a light surface; the pale companion surfaces
  /// carry the fill. Nothing here is pure grey — every neutral is tinted
  /// toward the slate base, which is what keeps a dense UI from looking dead.
  static const light = MaidKitSemantics(
    online: Color(0xFF047857),
    onlineSurface: Color(0xFFD5F2E3),
    degraded: Color(0xFFA25C00),
    degradedSurface: Color(0xFFFBEBCF),
    offline: Color(0xFF9F2D2D),
    offlineSurface: Color(0xFFF9DEDE),
    connecting: Color(0xFF1F6FA8),
    accent: Color(0xFFB45309),
    onAccent: Color(0xFFFFFFFF),
    terminalSurface: Color(0xFF10161C),
    hairline: Color(0x14101820),
    hairlineStrong: Color(0x2B101820),
  );

  /// Dark-mode semantics.
  ///
  /// Status hues brighten and desaturate slightly so they read on a dark
  /// surface without glowing; the companion surfaces are low-alpha tints of
  /// the same hue rather than solid fills, which avoids the chunky "status
  /// pill" look at high row density.
  static const dark = MaidKitSemantics(
    online: Color(0xFF4ADE9B),
    onlineSurface: Color(0x2610B981),
    degraded: Color(0xFFFBBF4A),
    degradedSurface: Color(0x26F59E0B),
    offline: Color(0xFFFF8A8A),
    offlineSurface: Color(0x26EF4444),
    connecting: Color(0xFF7DC4F5),
    accent: Color(0xFFFFB35C),
    onAccent: Color(0xFF231202),
    terminalSurface: Color(0xFF0B1015),
    hairline: Color(0x1AFFFFFF),
    hairlineStrong: Color(0x33FFFFFF),
  );
}

/// Convenience accessors. `context.semantics.online` beats threading a lookup
/// through every widget that needs one status colour.
extension MaidKitThemeContext on BuildContext {
  ColorScheme get scheme => Theme.of(this).colorScheme;
  TextTheme get type => Theme.of(this).textTheme;
  MaidKitSemantics get semantics =>
      Theme.of(this).extension<MaidKitSemantics>() ??
      (Theme.of(this).brightness == Brightness.dark
          ? MaidKitSemantics.dark
          : MaidKitSemantics.light);
}

/// Type scale.
///
/// Two deliberate moves. Display and headline get negative tracking, which is
/// what makes large type look drawn rather than defaulted — the single
/// cheapest way to stop a UI reading as generic. Labels get positive tracking
/// and full weight, because at 11-12px on a dense desktop surface that is what
/// keeps them legible against the row content they sit beside.
TextTheme _maidKitTextTheme(TextTheme base, String family) => base.copyWith(
  displayLarge: base.displayLarge?.copyWith(
    fontFamily: family,
    letterSpacing: -1.5,
    height: 1.05,
    fontWeight: FontWeight.w600,
  ),
  displayMedium: base.displayMedium?.copyWith(
    fontFamily: family,
    letterSpacing: -1.0,
    height: 1.08,
    fontWeight: FontWeight.w600,
  ),
  displaySmall: base.displaySmall?.copyWith(
    fontFamily: family,
    letterSpacing: -0.6,
    height: 1.12,
    fontWeight: FontWeight.w600,
  ),
  headlineLarge: base.headlineLarge?.copyWith(
    fontFamily: family,
    letterSpacing: -0.5,
    height: 1.15,
    fontWeight: FontWeight.w600,
  ),
  headlineMedium: base.headlineMedium?.copyWith(
    fontFamily: family,
    letterSpacing: -0.4,
    height: 1.18,
    fontWeight: FontWeight.w600,
  ),
  headlineSmall: base.headlineSmall?.copyWith(
    fontFamily: family,
    letterSpacing: -0.25,
    height: 1.2,
    fontWeight: FontWeight.w600,
  ),
  titleLarge: base.titleLarge?.copyWith(
    fontFamily: family,
    letterSpacing: -0.2,
    fontWeight: FontWeight.w600,
  ),
  titleMedium: base.titleMedium?.copyWith(
    fontFamily: family,
    letterSpacing: -0.1,
    fontWeight: FontWeight.w600,
  ),
  titleSmall: base.titleSmall?.copyWith(
    fontFamily: family,
    fontWeight: FontWeight.w600,
  ),
  bodyLarge: base.bodyLarge?.copyWith(fontFamily: family, height: 1.45),
  bodyMedium: base.bodyMedium?.copyWith(fontFamily: family, height: 1.45),
  bodySmall: base.bodySmall?.copyWith(fontFamily: family, height: 1.4),
  labelLarge: base.labelLarge?.copyWith(
    fontFamily: family,
    letterSpacing: 0.1,
    fontWeight: FontWeight.w600,
  ),
  labelMedium: base.labelMedium?.copyWith(
    fontFamily: family,
    letterSpacing: 0.4,
    fontWeight: FontWeight.w600,
  ),
  labelSmall: base.labelSmall?.copyWith(
    fontFamily: family,
    letterSpacing: 0.6,
    fontWeight: FontWeight.w600,
  ),
);

/// Deepens and tints the generated neutrals.
///
/// `ColorScheme.fromSeed` returns surfaces that are nearly neutral grey. On a
/// tool that is looked at for hours that reads as flat and unfinished, so the
/// dark surfaces are pushed toward a cool slate and the light ones toward a
/// warm paper. The seed still drives every accent, so a user-picked colour
/// keeps working.
ColorScheme _maidKitScheme(Color seed, Brightness brightness) {
  final base = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
  if (brightness == Brightness.dark) {
    return base.copyWith(
      surface: const Color(0xFF11161B),
      surfaceContainerLowest: const Color(0xFF0C1014),
      surfaceContainerLow: const Color(0xFF141A20),
      surfaceContainer: const Color(0xFF181F26),
      surfaceContainerHigh: const Color(0xFF1E262E),
      surfaceContainerHighest: const Color(0xFF252E37),
      outline: const Color(0xFF5C6874),
      outlineVariant: const Color(0xFF333D47),
    );
  }
  return base.copyWith(
    surface: const Color(0xFFFCFCFB),
    surfaceContainerLowest: const Color(0xFFFFFFFF),
    surfaceContainerLow: const Color(0xFFF7F7F5),
    surfaceContainer: const Color(0xFFF2F2EF),
    surfaceContainerHigh: const Color(0xFFECECE8),
    surfaceContainerHighest: const Color(0xFFE5E5E0),
    outline: const Color(0xFF767E86),
    outlineVariant: const Color(0xFFC9CDD2),
  );
}

/// The application-wide Material theme. Keep feature widgets dependent on this
/// shared foundation instead of creating local colour schemes or chrome.
///
/// Read tokens through [MaidKitSpace], [MaidKitRadius], [MaidKitMotion] and
/// `context.semantics` rather than hardcoding values in a page.
ThemeData createMaidKitTheme(
  Brightness brightness, {
  Color? seedColor,
  String? fontFamily,
}) {
  final isDark = brightness == Brightness.dark;
  final colorScheme = _maidKitScheme(
    seedColor ?? const Color(0xFF0F766E),
    brightness,
  );
  final family = fontFamily ?? MaidKitFonts.sans;
  final semantics = isDark ? MaidKitSemantics.dark : MaidKitSemantics.light;
  final base = ThemeData(brightness: brightness);

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    brightness: brightness,
    fontFamily: family,
    // Desktop-first: the default vertical density wastes rows on a machine
    // list that is meant to be scanned, not scrolled.
    visualDensity: VisualDensity.compact,
    scaffoldBackgroundColor: colorScheme.surface,
    textTheme: _maidKitTextTheme(base.textTheme, family),
    extensions: <ThemeExtension<dynamic>>[semantics],
    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: Border(bottom: BorderSide(color: semantics.hairline)),
    ),
    navigationRailTheme: NavigationRailThemeData(
      groupAlignment: -1,
      labelType: NavigationRailLabelType.all,
      backgroundColor: colorScheme.surfaceContainerLow,
      indicatorColor: colorScheme.primary.withValues(alpha: isDark ? 0.22 : 0.14),
      selectedIconTheme: IconThemeData(color: colorScheme.primary, size: 22),
      unselectedIconTheme: IconThemeData(
        color: colorScheme.onSurfaceVariant,
        size: 22,
      ),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: colorScheme.surfaceContainerLow,
      isDense: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MaidKitRadius.md),
        borderSide: BorderSide(color: semantics.hairlineStrong),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MaidKitRadius.md),
        borderSide: BorderSide(color: semantics.hairlineStrong),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MaidKitRadius.md),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: semantics.hairline,
      thickness: 1,
      space: 1,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
      },
    ),
  );
}
