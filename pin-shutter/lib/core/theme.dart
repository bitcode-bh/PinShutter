import 'package:flutter/material.dart';

import 'design/palette.dart';
import 'design/text_styles.dart';
import 'design/tokens.dart';

/// The single dark theme for the app. The camera surface never inverts with the
/// platform setting, so only a dark theme is provided.
class AppTheme {
  AppTheme._();

  static ThemeData dark() {
    const accent = Palette.accentMuted;
    const panel = RoundedSuperellipseBorder(
      borderRadius: BorderRadius.all(Radius.circular(Corners.lg)),
    );
    const chip = RoundedSuperellipseBorder(
      borderRadius: BorderRadius.all(Radius.circular(Corners.sm)),
    );
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: Brightness.dark,
      surface: Palette.ink,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Palette.ink,
      colorScheme: scheme.copyWith(
        primary: accent,
        secondary: accent,
        onPrimary: Palette.onBrand,
        onSecondary: Palette.onBrand,
        onSurface: Palette.textHi,
        onSurfaceVariant: Palette.textMid,
        surface: Palette.ink,
      ),
      splashFactory: InkRipple.splashFactory,
      switchTheme: SwitchThemeData(
        materialTapTargetSize: MaterialTapTargetSize.padded,
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Palette.onBrand
              : Palette.textMid,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Palette.accentYellow
              : Palette.ink2,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.transparent
              : Palette.strokeSolid,
        ),
        overlayColor: WidgetStatePropertyAll(accent.withValues(alpha: .12)),
      ),
      textTheme: const TextTheme(
        displaySmall: AppText.display,
        headlineSmall: AppText.h1,
        titleLarge: AppText.h2,
        titleMedium: AppText.title,
        titleSmall: AppText.bodyHi,
        bodyLarge: AppText.bodyHi,
        bodyMedium: AppText.body,
        bodySmall: AppText.label,
        labelLarge: AppText.label,
        labelMedium: AppText.label,
        labelSmall: AppText.caption,
      ),
      appBarTheme: const AppBarTheme(
        titleTextStyle: AppText.h1,
        backgroundColor: Palette.ink,
        foregroundColor: Palette.textHi,
        surfaceTintColor: Colors.transparent,
      ),
      iconButtonTheme: const IconButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll(Size(48, 48)),
          shape: WidgetStatePropertyAll(chip),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Palette.surfaceSolid,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: Colors.black54,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(Corners.lg)),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      listTileTheme: const ListTileThemeData(titleTextStyle: AppText.bodyHi),
      chipTheme: ChipThemeData(shape: chip, labelStyle: AppText.label),
      popupMenuTheme: const PopupMenuThemeData(
        shape: panel,
        textStyle: AppText.bodyHi,
      ),
      filledButtonTheme: const FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll(Size(48, 48)),
          shape: WidgetStatePropertyAll(chip),
          textStyle: WidgetStatePropertyAll(AppText.label),
        ),
      ),
      outlinedButtonTheme: const OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll(Size(48, 48)),
          shape: WidgetStatePropertyAll(chip),
          textStyle: WidgetStatePropertyAll(AppText.label),
        ),
      ),
      dialogTheme: const DialogThemeData(
        shape: panel,
        backgroundColor: Palette.surfaceSolid,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppText.title,
        contentTextStyle: AppText.body,
      ),
      textButtonTheme: const TextButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll(Size(48, 48)),
          shape: WidgetStatePropertyAll(chip),
          textStyle: WidgetStatePropertyAll(AppText.label),
        ),
      ),
      tooltipTheme: const TooltipThemeData(
        decoration: ShapeDecoration(color: Palette.ink2, shape: chip),
        textStyle: TextStyle(color: Palette.textHi),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: chip,
        elevation: 0,
        backgroundColor: Palette.surfaceSolid,
        contentTextStyle: AppText.bodyHi,
        insetPadding: EdgeInsets.fromLTRB(16, 0, 16, 24),
      ),
    );
  }
}
