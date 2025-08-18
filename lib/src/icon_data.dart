library font_awesome_flutter;

import 'package:flutter/widgets.dart';

/// [IconData] for a material symbols outlined icon from a supplied codepoint
///
class IconDataOutlined extends IconData {
  const IconDataOutlined(super.codePoint, {super.matchTextDirection})
      : super(
          fontFamily: 'MaterialSymbolsOutlined',
          fontPackage: 'material_symbols_icons',
        );
}

/// [IconData] for a material symbols sharp icon from a supplied codepoint
///
class IconDataSharp extends IconData {
  const IconDataSharp(super.codePoint, {super.matchTextDirection})
      : super(
          fontFamily: 'MaterialSymbolsSharp',
          fontPackage: 'material_symbols_icons',
        );
}

/// [IconData] for a material symbols rounded icon from a supplied codepoint
///
class IconDataRounded extends IconData {
  const IconDataRounded(super.codePoint, {super.matchTextDirection})
      : super(
          fontFamily: 'MaterialSymbolsRounded',
          fontPackage: 'material_symbols_icons',
        );
}
