import 'package:example_using_material_symbols_icons/main.dart';
import 'package:example_using_material_symbols_icons/models/font_list_type_model.dart';
import 'package:example_using_material_symbols_icons/symbols_map.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class IconProvider extends ChangeNotifier {
  FontListType _fontListType = FontListType.outlined;
  FontListType get fontListType => _fontListType;

  double iconFontSize = 48.0;

  double fillVariation = 0.0;

  double weightVariation = 400.0;

  double gradeVariation = 0.0;

  double opticalSizeVariation = 48.0;

  // List<IconData> iconList = [];
  // List<String> iconNameList = [];
  Map<String, IconData> iconList = {};

  // default grade
  double gradeSliderPos = 1;

  // default optical size
  double opticalSliderPos = 3;

  /// possible grade values
  final List<double> grades = [0.25, 0.0, 200.0];

  /// possible optical size values
  final List<double> opticalSizes = [20.0, 24.0, 40.0, 48.0];

  void setAllVariationsSettings() {
    MaterialSymbolsBase.setOutlinedVariationDefaults(
      color: outlinedColor,
      fill: fillVariation,
      weight: weightVariation,
      grade: gradeVariation,
      opticalSize: opticalSizeVariation,
    );
    MaterialSymbolsBase.setRoundedVariationDefaults(
      color: roundedColor,
      fill: fillVariation,
      weight: weightVariation,
      grade: gradeVariation,
      opticalSize: opticalSizeVariation,
    );
    MaterialSymbolsBase.setSharpVariationDefaults(
      color: sharpColor,
      fill: fillVariation,
      weight: weightVariation,
      grade: gradeVariation,
      opticalSize: opticalSizeVariation,
    );

    notifyListeners();
  }

  void onFontListTypeChange(FontListType? val) {
    _fontListType = val ?? FontListType.outlined;
    switch (_fontListType) {
      case FontListType.outlined:
        iconList = materialSymbolsOutlinedMap;
        break;
      case FontListType.rounded:
        iconList = materialSymbolsRoundedMap;
        break;
      case FontListType.sharp:
        iconList = materialSymbolsSharpMap;
        break;
      case FontListType.universal:
        iconList = materialSymbolsMap;
        break;
    }

    notifyListeners();
  }

  void resetVariationSettings() {
    fillVariation = 0.0;
    weightVariation = 400.0;
    gradeVariation = 0.0;
    gradeSliderPos = grades.indexOf(gradeVariation).toDouble();
    opticalSizeVariation = 48.0;
    opticalSliderPos = opticalSizes.indexOf(opticalSizeVariation).toDouble();

    setAllVariationsSettings(); // This does call notifyListeners()
  }
}
