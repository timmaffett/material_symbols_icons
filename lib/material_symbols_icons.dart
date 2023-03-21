// ignore_for_file: constant_identifier_names

library material_symbols_icons;

import 'package:flutter/widgets.dart';

/// Material Symbols base class with utility methods
class MaterialSymbolsBase {
  static void setOutlinedVariationDefaults({
    double? size,
    double? fill,
    double? weight,
    double? grade,
    double? opticalSize,
    Color? color,
    List<Shadow>? shadows,
    TextDirection? textDirection,
  }) =>
      setIconVariationDefaultsByFontFamily(
          'MaterialSymbolsOutlined',
          IconVariationDefaults(size, fill, weight, grade, opticalSize, color,
              shadows, textDirection));

  static void setRoundedVariationDefaults({
    double? size,
    double? fill,
    double? weight,
    double? grade,
    double? opticalSize,
    Color? color,
    List<Shadow>? shadows,
    TextDirection? textDirection,
  }) =>
      setIconVariationDefaultsByFontFamily(
          'MaterialSymbolsRounded',
          IconVariationDefaults(size, fill, weight, grade, opticalSize, color,
              shadows, textDirection));

  static void setSharpVariationDefaults({
    double? size,
    double? fill,
    double? weight,
    double? grade,
    double? opticalSize,
    Color? color,
    List<Shadow>? shadows,
    TextDirection? textDirection,
  }) =>
      setIconVariationDefaultsByFontFamily(
          'MaterialSymbolsSharp',
          IconVariationDefaults(size, fill, weight, grade, opticalSize, color,
              shadows, textDirection));

  /// This routine exists so that we can place a call to this routine within main() to FORCE TREE SHAKING
  /// of the icon fonts that may not be referenced at all within the application.  This is required because
  /// the Material Symbols Icons have 3 font varieties and it is likely only one will be used.
  /// Tree shaking DOES NOT OCCUR for fonts that are never referenced, so having a call to this
  /// methoid FORCES a reference to the fonts - and invokes tree shaking.
  /// (Tree shaking occurs when a *const* declaration to an IconData() class occurs.)
  static void forceCompileTimeTreeShaking() {
    // ignore: unused_local_variable
    const forceOutlinedTreeShake = IconData(0xeb36,
        fontFamily: 'MaterialSymbolsOutlined',
        fontPackage: 'material_symbols_icons');
    // ignore: unused_local_variable
    const forceRoundedTreeShake = IconData(0xeb36,
        fontFamily: 'MaterialSymbolsRounded',
        fontPackage: 'material_symbols_icons');
    // ignore: unused_local_variable
    const forceSharpTreeShake = IconData(0xeb36,
        fontFamily: 'MaterialSymbolsSharp',
        fontPackage: 'material_symbols_icons');
  }
}

/// Class to store our icon variation defaults which we allow to be stored BY FONT FAMILY NAME,
/// so that there can be different defaults for different icon font families.
class IconVariationDefaults {
  double? size;
  double? fill;
  double? weight;
  double? grade;
  double? opticalSize;
  Color? color;
  List<Shadow>? shadows;
  TextDirection? textDirection;

  IconVariationDefaults(this.size, this.fill, this.weight, this.grade,
      this.opticalSize, this.color, this.shadows, this.textDirection);
}

/// Our map of font family names to font variation default information.
Map<String, IconVariationDefaults> globalIconVariationDefaults = {};

/// This can be used in conjunction with the [Icon.varied] constructor to provide font variation defaults *BY FONT FAMILY* first,
/// and then falling back on the [IconTheme]'s [IconThemeData]
void setIconVariationDefaultsByFontFamily(
    String fontFamily, IconVariationDefaults? variations) {
  if (variations == null) {
    globalIconVariationDefaults.remove(fontFamily);
  } else {
    globalIconVariationDefaults[fontFamily] = variations;
  }
}

/// Extension to [Icon] that creates icons are varied by any defaults you have set using
/// [MaterialSymbols.setRegularVariationDefaults], [MaterialSymbols.setRegularVariationDefaults] or
/// [MaterialSymbols.setRegularVariationDefaults] *first* and then using the [IconTheme]'s
/// [IconThemeData] secondarily.
/// This allows different variation defaults for regular, rounded and sharp versions of the
/// Material Symbols icons.
extension VariedIcon on Icon {
  /// Creates an icon using any default variations defined for the icon's fontFamily
  /// (If the [icon.fontFamily] is not found in the [globalIconVariationDefaults] map then the
  /// normal Icon() behavior of using the [IconTheme]'s [IconThemeData] infornation for any missing
  /// attributes.
  ///
  /// The use of [globalIconVariationDefaults] allows DIFFERENT defaults BY FONT FAMILY NAME to be used during
  /// icon creation.  (ie. different defaults for regular, rounded or sharp Material Symbols icon fonts.)
  static Icon varied(
    IconData icon, {
    Key? key,
    double? size,
    double? fill,
    double? weight,
    double? grade,
    double? opticalSize,
    Color? color,
    List<Shadow>? shadows,
    String? semanticLabel,
    TextDirection? textDirection,
  }) =>
      Icon(
        icon,
        key: key,
        size: size ?? globalIconVariationDefaults[icon.fontFamily]?.size,
        fill: fill ?? globalIconVariationDefaults[icon.fontFamily]?.fill,
        weight: weight ?? globalIconVariationDefaults[icon.fontFamily]?.weight,
        grade: grade ?? globalIconVariationDefaults[icon.fontFamily]?.grade,
        opticalSize: opticalSize ??
            globalIconVariationDefaults[icon.fontFamily]?.opticalSize,
        color: color ?? globalIconVariationDefaults[icon.fontFamily]?.color,
        shadows:
            shadows ?? globalIconVariationDefaults[icon.fontFamily]?.shadows,
        semanticLabel: semanticLabel,
        textDirection: textDirection ??
            globalIconVariationDefaults[icon.fontFamily]?.textDirection,
      );
}
