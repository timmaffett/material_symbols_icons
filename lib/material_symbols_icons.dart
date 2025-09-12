// ignore_for_file: constant_identifier_names
/// Material Symbols Icons library base class which contains method to force proper icon tree-shaking,
/// and utility methods providing alternate method of icon variation defaults to be defined
/// by icon style (implemented using font family names to differentiate icon styles).
///
/// {@category BaseClass}
library;

import 'package:flutter/widgets.dart';
export 'symbols.dart';

/// Class to store our icon variation defaults which we allow to be stored by _font family name_,
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

/// The `Symbols` class derivces from this class and contains references to all of the symbols.
///
/// This [MaterialSymbolsBase] class contains a method for forcing icon tree-shaking to properly take place on all three styles
/// of material symbols icon fonts.  The method is [forceCompileTimeTreeShaking] and is annotated with a ` @pragma('vm:entry-point')`
/// annotation so that method itself is not tree-shaken.  This method referes to all three material symbols icon fonts so that the
/// build tools know to tree-shake each of these icon fonts.  (Otherwise unreferenced icon fonts would be included in their entirety
/// into the built application).
///
/// [MaterialSymbolsBase] class with methods for setting the default variations for each style.  These default variations are
/// used when using `VariedIcon.varied()` as alternative to the `Icon()` constructor.
///
/// (LEGACY versions of the material_symbols_icons class:  This no longer is true once this was changed to be future compatible
/// with the Flutter `Symbols` implementation. (https://docs.google.com/document/d/1UHRKDl8-lzl_hW_K2AHnpMwvdPo0vGPbDI7mqACWXJY/edit)
/// All classes providing access to material symbols icons derive from this class [MaterialSymbols] (outlined, rounded, sharp
/// or universal versions of this class), as well as [MaterialSymbolsOutlined], [MaterialSymbolsRounded] and [MaterialSymbolsSharp].
/// The user of this package chooses the method they prefer to access the desired icons, and imports the corresponding
/// dart file into their files.)
///

class MaterialSymbolsBase {
  /// Our map of font family names to font variation default information.
  static Map<String, IconVariationDefaults> globalIconVariationDefaults = {};

  /// This can be used in conjunction with the [VariedIcon.varied] constructor to provide font variation defaults *BY FONT FAMILY* first,
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
    // then the tree shaking is not triggered.  These are references to the 'check_indeterminate_small'
    // icon in each of the fonts (one of the smallest glyphs we can include).
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
/// [MaterialSymbolsBase.setOutlinedVariationDefaults], [MaterialSymbolsBase.setRoundedVariationDefaults] or
/// [MaterialSymbolsBase.setSharpVariationDefaults] *first* and then using the [IconTheme]'s
/// [IconThemeData] secondarily.
/// This allows different variation defaults for regular, rounded and sharp versions of the
/// Material Symbols icons.
extension VariedIcon on Icon {
  /// Creates an icon using any default variations defined for the icon's fontFamily
  /// (If the [icon]'s [IconData.fontFamily] is not found in the [MaterialSymbolsBase.globalIconVariationDefaults] map then the
  /// normal Icon() behavior of using the [IconTheme]'s [IconThemeData] infornation for any missing
  /// attributes.
  ///
  /// The use of [MaterialSymbolsBase.globalIconVariationDefaults] allows DIFFERENT defaults BY FONT FAMILY NAME to be used during
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

/// TwoToneVariation - Note: having a fill property=1.0 will reverse this
enum TwoToneVariation { filled_first, outline_first }   

/// This extension creates a two-tone icon using a stack of two icons, each with different colors and fill variations.
extension TwoToneIcon on Icon {
  /// Creates an two-toneicon using a stack of two icons, each with different colors and fill variations.
  /// The [fill] parameter is used to determine which icon is the "filled" version (fill=1.0) and which is the "outlined" version (fill=0.0). 
  static Stack varied(
    IconData icon, {
    Key? key,
    TwoToneVariation twoToneVariation = TwoToneVariation.filled_first, // 1=filled first, 2=outlined first
    double? size,
    double? fill,
    double? weight,
    double? grade,
    double? opticalSize,
    Color? color,
    Color? color2,
    List<Shadow>? shadows,
    String? semanticLabel,
    TextDirection? textDirection,
  }) =>
    Stack(
      children: [
        Icon(
            icon,
            key: key,
            size: size ??
                MaterialSymbolsBase
                    .globalIconVariationDefaults[icon.fontFamily]?.size,
            fill: (fill ??
                MaterialSymbolsBase
                    .globalIconVariationDefaults[icon.fontFamily]?.fill)
                    == (twoToneVariation == TwoToneVariation.filled_first ? 0.0 : 1.0)
                ? 1.0
                : 0.0,
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
        ),
        Icon(
        icon,
        key: key,
        size: size ??
            MaterialSymbolsBase
                .globalIconVariationDefaults[icon.fontFamily]?.size,
        fill: (fill ??
            MaterialSymbolsBase
                .globalIconVariationDefaults[icon.fontFamily]?.fill) ==
            (twoToneVariation == TwoToneVariation.filled_first ? 0.0 : 1.0)
            ? 0.0
            : 1.0,
        weight: weight ??
            MaterialSymbolsBase
                .globalIconVariationDefaults[icon.fontFamily]?.weight,
        grade: grade ??
            MaterialSymbolsBase
                .globalIconVariationDefaults[icon.fontFamily]?.grade,
        opticalSize: opticalSize ??
            MaterialSymbolsBase
                .globalIconVariationDefaults[icon.fontFamily]?.opticalSize,
        color: color2 ??
            MaterialSymbolsBase
                .globalIconVariationDefaults[icon.fontFamily]?.color,
        shadows: shadows ??
            MaterialSymbolsBase
                .globalIconVariationDefaults[icon.fontFamily]?.shadows,
        semanticLabel: semanticLabel,
        textDirection: textDirection ??
            MaterialSymbolsBase
                .globalIconVariationDefaults[icon.fontFamily]?.textDirection,
      )
      ] 
    );
}
