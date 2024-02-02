import 'package:example_using_material_symbols_icons/main.dart';
import 'package:example_using_material_symbols_icons/models/font_list_type_model.dart';
import 'package:example_using_material_symbols_icons/symbols_map.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class IconProvider extends ChangeNotifier {
  IconProvider() {
    setAllVariationsSettings();
    onFontListTypeChange(fontListType);
  }

  FontListType fontListType = FontListType.outlined;

  double fillVariation = 0.0;

  double weightVariation = 400.0;

  double gradeVariation = 0.0;

  double opticalSizeVariation = 48.0;

  Map<String, IconData> icons = {};

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

  void onFontListTypeChange(FontListType? value) {
    fontListType = value ?? FontListType.outlined;
    switch (fontListType) {
      case FontListType.outlined:
        icons = materialSymbolsOutlinedMap;
        break;
      case FontListType.rounded:
        icons = materialSymbolsRoundedMap;
        break;
      case FontListType.sharp:
        icons = materialSymbolsSharpMap;
        break;
      case FontListType.universal:
        icons = materialSymbolsMap;
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
