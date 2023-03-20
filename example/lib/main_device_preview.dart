import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart'; // required when useDevicePreview==true
import 'package:material_symbols_icons/material_symbols_icons.dart';

import 'main.dart';

/// Set [useDevicePreview] to allow testing layouts on virtual device screens
const useDevicePreview = true;

const outlinedColor = Colors.red;
const roundedColor = Colors.blue;
const sharpColor = Colors.teal;

void main() {
  /*
    This called forces a reference to each of the 3 possible Material Symbols Icon fonts
    so that tree shaking can take place and unused fonts will be removed.  If 
    this is NOT done then any un-referenced fonts (such as rounded and sharp if you were
    using outlined) will NOT BE SHOOK from the tree and your executable will include
    these!
    (Strictly speaking in this example, where we reference every icon in every font style, 
    this is not needed, but in real world this is ALWAYS needed, so it is included here.
  */
  MaterialSymbolsBase.forceCompileTimeTreeShaking();

  /*
    Here we can set default Icon VARATIONS which can be specific to Outlined, Rounded or Sharp icons,
    each with their own settings.  These will take PRIORITY over IconThemeData()
    This is totally optional and IconThemeData() can just be used if you do not need to
    have different variation settings for different icons from different font families.
  */
  MaterialSymbolsBase.setOutlinedVariationDefaults(
      color: outlinedColor, fill: 0.0);
  MaterialSymbolsBase.setRoundedVariationDefaults(
      color: roundedColor, fill: 0.0);
  MaterialSymbolsBase.setSharpVariationDefaults(color: sharpColor, fill: 0.0);

  if (useDevicePreview) {
    //TEST various on various device screens//
    runApp(DevicePreview(
      builder: (context) => const MyApp(), // Wrap your app
      enabled: false,
    ));
  } else {
    runApp(const MyApp());
  }
}
