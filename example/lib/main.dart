import 'package:example_using_material_symbols_icons/presentation/pages/icon_page.dart';
import 'package:example_using_material_symbols_icons/provider/icon_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';

import 'symbols_map.dart';

import 'package:device_preview/device_preview.dart'; // required when useDevicePreview==true

/// Set [useDevicePreview] to allow testing layouts on virtual device screens
const useDevicePreview = true;

const outlinedColor = Colors.red;
const roundedColor = Colors.blue;
const sharpColor = Colors.teal;

Map<String, IconData> materialSymbolsOutlinedMap = {};
Map<String, IconData> materialSymbolsRoundedMap = {};
Map<String, IconData> materialSymbolsSharpMap = {};

const String materialSymbolsIconsSourceFontVersionNumber =
    '2.718'; // must update for each new font update
const String materialSymbolsIconsSourceReleaseDate =
    'Jan. 25, 2024'; // must update for each new font update
int totalMaterialSymbolsIcons = 0;

void makeSymbolsByStyleMaps() {
  for (final key in materialSymbolsMap.keys.toList()) {
    if (key.endsWith('_rounded')) {
      materialSymbolsRoundedMap[key] = materialSymbolsMap[key]!;
    } else if (key.endsWith('_sharp')) {
      materialSymbolsSharpMap[key] = materialSymbolsMap[key]!;
    } else {
      materialSymbolsOutlinedMap[key] = materialSymbolsMap[key]!;
    }
  }
}

void main() {
  // prevent engine from removing query url parameters
  usePathUrlStrategy();

  // create separate iconname->icon map for each style
  makeSymbolsByStyleMaps();

  totalMaterialSymbolsIcons = (materialSymbolsMap.length / 3).floor();

  if (useDevicePreview) {
    //TEST various on various device screens//
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => IconProvider(),
          ),
        ],
        child: DevicePreview(
          enabled: true,
          builder: (context) => const MyApp(), // Wrap your app
        ),
      ),
    );
  } else {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => IconProvider(),
          ),
        ],
        child: const MyApp(),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    /*
      Set default IconThemeData() for ALL icons
    */
    return MaterialApp(
      title: 'Material Symbols Icons For Flutter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green[300]!,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      routes: {
        '/': (context) => IconPage(
              title: 'Material Symbols Icons For Flutter',
              subtitle:
                  '(v$materialSymbolsIconsSourceFontVersionNumber fonts, released $materialSymbolsIconsSourceReleaseDate w/ $totalMaterialSymbolsIcons icons)',
            ),
      },
      initialRoute: '/',
    );
  }
}
