import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// The [AppTheme] defines light and dark themes for the app.
///
/// Theme setup for FlexColorScheme package v8.
/// Use same major flex_color_scheme package version. If you use a
/// lower minor version, some properties may not be supported.
/// In that case, remove them after copying this theme to your
/// app or upgrade the package to version 8.4.0.
///
/// Use it in a [MaterialApp] like this:
///
/// MaterialApp(
///   theme: AppTheme.light,
///   darkTheme: AppTheme.dark,
/// );
abstract final class AppTheme {
  // The FlexColorScheme defined light mode ThemeData.
  static ThemeData light = FlexThemeData.light(
    // Using FlexColorScheme built-in FlexScheme enum based colors
    scheme: FlexScheme.shadBlue,
    // Surface color adjustments.
    lightIsWhite: true,
    // Component theme configurations for light mode.
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      useM2StyleDividerInM3: true,
      adaptiveAppBarScrollUnderOff: FlexAdaptive.all(),
      defaultRadius: 10.0,
      segmentedButtonSchemeColor: SchemeColor.primary,
      segmentedButtonUnselectedSchemeColor: SchemeColor.white,
      segmentedButtonBorderSchemeColor: SchemeColor.transparent,
      inputDecoratorIsFilled: true,
      inputDecoratorIsDense: true,
      inputDecoratorBackgroundAlpha: 150,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      inputDecoratorUnfocusedHasBorder: false,
      inputDecoratorFocusedHasBorder: false,
      fabUseShape: true,
      alignedDropdown: true,
      snackBarRadius: 10,
      snackBarBackgroundSchemeColor: SchemeColor.onPrimary,
      snackBarActionSchemeColor: SchemeColor.primary,
      appBarCenterTitle: true,
      bottomNavigationBarElevation: 0.0,
      searchBarBackgroundSchemeColor: SchemeColor.onPrimary,
      searchViewBackgroundSchemeColor: SchemeColor.onPrimary,
      searchBarElevation: 1.0,
      searchViewElevation: 1.0,
      searchUseGlobalShape: true,
      navigationRailUseIndicator: true,
    ),
    // Direct ThemeData properties.
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );

  // The FlexColorScheme defined dark mode ThemeData.
  static ThemeData dark = FlexThemeData.dark(
    // Using FlexColorScheme built-in FlexScheme enum based colors.
    scheme: FlexScheme.shadBlue,
    // Component theme configurations for dark mode.
    subThemesData: const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      blendOnColors: true,
      useM2StyleDividerInM3: true,
      defaultRadius: 10.0,
      segmentedButtonSchemeColor: SchemeColor.primary,
      segmentedButtonUnselectedSchemeColor: SchemeColor.white,
      segmentedButtonBorderSchemeColor: SchemeColor.transparent,
      inputDecoratorIsFilled: true,
      inputDecoratorIsDense: true,
      inputDecoratorBorderType: FlexInputBorderType.outline,
      inputDecoratorUnfocusedHasBorder: false,
      inputDecoratorFocusedHasBorder: false,
      fabUseShape: true,
      alignedDropdown: true,
      snackBarRadius: 10,
      snackBarBackgroundSchemeColor: SchemeColor.onPrimary,
      snackBarActionSchemeColor: SchemeColor.primary,
      appBarCenterTitle: true,
      bottomNavigationBarElevation: 0.0,
      searchBarBackgroundSchemeColor: SchemeColor.onPrimary,
      searchViewBackgroundSchemeColor: SchemeColor.onPrimary,
      searchBarElevation: 1.0,
      searchViewElevation: 1.0,
      searchUseGlobalShape: true,
      navigationRailUseIndicator: true,
    ),
    // Direct ThemeData properties.
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
  );
}
