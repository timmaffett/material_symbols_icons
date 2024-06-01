/// The [SymbolsGet] extension on [Symbols] adds a method to retrieve an icon based on its
/// name and desired style variation.  It also provides a [values] getter providing
/// an array of all available icon names.   Additionally it provides a [map] getter to
/// allow access to the map of icon names to code points.

import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_symbols_icons/iconname_to_unicode_map.dart';

/// Available styles when calling [get] method of the [SymbolsGet] extension.
enum SymbolStyle {
  rounded,
  sharp,
  outlined,
}

/// When using this [SymbolsGet] extension you must either turn off icon tree-shaking
/// or `include "pacakage:material_symbols_icons\symbols_map.dart` which will force
/// references to every available icon.
/// icon tree-shaking must be turned off when using the get() method!
///  build with `--no-tree-shake-icons`
///  Otherwise the tree-shaking will remove all icons as they will not appear to be accessed.
/// @nodoc
extension SymbolsGet on Symbols {
  static IconData get(String name, SymbolStyle style) {
    int codePoint = materialSymbolsIconNameToUnicodeMap[name] ??
        materialSymbolsIconNameToUnicodeMap['question_mark']!;
    switch (style) {
      case SymbolStyle.rounded:
        return IconDataRounded(codePoint);
      case SymbolStyle.sharp:
        return IconDataSharp(codePoint);
      case SymbolStyle.outlined:
        return IconDataOutlined(codePoint);
    }
  }

  // mimic a enum values method as alternate way to access the iconnames from the iconnames->codepoint map.
  static Iterable<String> get values =>
      materialSymbolsIconNameToUnicodeMap.keys;

  // easier access to the map
  static Map<String, int> get map => materialSymbolsIconNameToUnicodeMap;
}
