// ignore_for_file: constant_identifier_names

library material_symbols_icons;

import 'package:flutter/widgets.dart';

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

/// Material Symbols base class with utility methods for forcing tree shaking [forceCompileTimeTreeShaking] and
/// methods for setting the default variations for each style.  These default variations are used when using
/// `VariedIcon.varied()` as alternative to the `Icon()` constructor
class MaterialSymbolsBase {
  /// Our map of font family names to font variation default information.
  static Map<String, IconVariationDefaults> globalIconVariationDefaults = {};

  /// This can be used in conjunction with the [Icon.varied] constructor to provide font variation defaults *BY FONT FAMILY* first,
  /// and then falling back on the [IconTheme]'s [IconThemeData]
  static void setIconVariationDefaultsByFontFamily(
      String fontFamily, IconVariationDefaults? variations) {
    if (variations == null) {
      globalIconVariationDefaults.remove(fontFamily);
    } else {
      globalIconVariationDefaults[fontFamily] = variations;
    }
  }

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

  /// This routine exists to FORCE TREE SHAKING of the icon fonts that may not be referenced
  /// at all within the application.  This is required because the Material Symbols Icons
  /// have 3 font varieties and it is very likely only one will be used.
  /// Tree shaking DOES NOT OCCUR for fonts that are never referenced, so having a this
  /// method FORCES a reference to the fonts - and invokes tree shaking for
  /// each of the three fonts.  In this way any unused fonts are reduced to around 2k, which
  /// the icon tree shake will report as 100.0% reduction.
  /// (Tree shaking occurs when a *const* declaration to an IconData() class occurs.)
  /// 
  /// NOTE: VERY IMPORTANT - the `@pargma('vm:entry-point')` annotation is REQUIRED
  /// and it is being used to force the dart compilation process to believe that this
  /// method is required and that it CAN NOT tree-shake this method when it never
  /// finds a call to it in the dart source code.
  @pragma('vm:entry-point')
  static void forceCompileTimeTreeShaking() {
    // these variables must be declared as var to trigger tree shaking, when declared as const
    // then the tree shaking is not triggered.  These are references to the 'check_indeterminate_small' icon in 
    // each of the fonts, which is one of the smallest glyphs.
    // ignore: unused_local_variable
    var forceOutlinedTreeShake = const IconData(0xf88a,
        fontFamily: 'MaterialSymbolsOutlined',
        fontPackage: 'material_symbols_icons');
    // ignore: unused_local_variable
    var forceRoundedTreeShake = const IconData(0xf88a,
        fontFamily: 'MaterialSymbolsRounded',
        fontPackage: 'material_symbols_icons');
    // ignore: unused_local_variable
    var forceSharpTreeShake = const IconData(0xf88a,
        fontFamily: 'MaterialSymbolsSharp',
        fontPackage: 'material_symbols_icons');
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
        size: size ??
            MaterialSymbolsBase
                .globalIconVariationDefaults[icon.fontFamily]?.size,
        fill: fill ??
            MaterialSymbolsBase
                .globalIconVariationDefaults[icon.fontFamily]?.fill,
        weight: weight ??
            MaterialSymbolsBase
                .globalIconVariationDefaults[icon.fontFamily]?.weight,
        grade: grade ??
            MaterialSymbolsBase
                .globalIconVariationDefaults[icon.fontFamily]?.grade,
        opticalSize: opticalSize ??
            MaterialSymbolsBase
                .globalIconVariationDefaults[icon.fontFamily]?.opticalSize,
        color: color ??
            MaterialSymbolsBase
                .globalIconVariationDefaults[icon.fontFamily]?.color,
        shadows: shadows ??
            MaterialSymbolsBase
                .globalIconVariationDefaults[icon.fontFamily]?.shadows,
        semanticLabel: semanticLabel,
        textDirection: textDirection ??
            MaterialSymbolsBase
                .globalIconVariationDefaults[icon.fontFamily]?.textDirection,
      );
}
