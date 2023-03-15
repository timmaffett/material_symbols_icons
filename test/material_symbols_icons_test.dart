// ignore_for_file: unused_local_variable

import 'package:flutter_test/flutter_test.dart';

import 'package:material_symbols_icons/universal.dart' as universal;
import 'package:material_symbols_icons/outlined.dart' as outlined;
import 'package:material_symbols_icons/rounded.dart' as rounded;
import 'package:material_symbols_icons/sharp.dart' as sharp;
import 'package:material_symbols_icons/outlined_suffix.dart';
import 'package:material_symbols_icons/rounded_suffix.dart';
import 'package:material_symbols_icons/sharp_suffix.dart';

void main() {
  // We just try to reference a example IconData from each of the classes which should
  // have been generated.
  const materialUnivOutlined = universal.MaterialSymbols.abc_outlined;
  const materialUnivRounded = universal.MaterialSymbols.abc_rounded;
  const materialUnivSharp = universal.MaterialSymbols.abc_sharp;
  const materialOutlined = outlined.MaterialSymbols.abc;
  const materialRounded = rounded.MaterialSymbols.abc;
  const materialSharp = sharp.MaterialSymbols.abc;
  const materialOutlinedSuffix = MaterialSymbolsOutlined.abc;
  const materialRoundedSuffix = MaterialSymbolsRounded.abc;
  const materialSharpSuffix = MaterialSymbolsSharp.abc;
  test('adds one to input values', () {});
}
