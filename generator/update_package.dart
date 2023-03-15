// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: avoid_print, unnecessary_type_check

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as path;

///  This program goes to the https://github.com/google/material-design-icons repository and retreives the variable fonts and codepoint information
/// for the Material Symbols Icon fonts
///
/// https://github.com/google/material-design-icons/raw/master/variablefont/MaterialSymbolsOutlined%5BFILL%2CGRAD%2Copsz%2Cwght%5D.codepoints
/// https://github.com/google/material-design-icons/raw/master/variablefont/MaterialSymbolsRounded%5BFILL%2CGRAD%2Copsz%2Cwght%5D.codepoints
/// https://github.com/google/material-design-icons/raw/master/variablefont/MaterialSymbolsSharp%5BFILL%2CGRAD%2Copsz%2Cwght%5D.codepoints

class MaterialSymbolsVariableFont {
  final String flavor;
  final String familyNameToUse;
  final String codepointFileUrl;
  final String ttfFontFileUrl;
  late final String filename;
  final List<String> iconNameList = [];
  final List<String> codePointList = [];

  MaterialSymbolsVariableFont(this.flavor, this.familyNameToUse,
      this.codepointFileUrl, this.ttfFontFileUrl) {
    final urlfilename = path.basename(ttfFontFileUrl);
    filename = Uri.decodeFull(urlfilename);
  }
}

List<MaterialSymbolsVariableFont> variableFontFlavors = [
  MaterialSymbolsVariableFont(
      'outlined',
      'MaterialSymbolsOutlined',
      'https://github.com/google/material-design-icons/raw/master/variablefont/MaterialSymbolsOutlined%5BFILL%2CGRAD%2Copsz%2Cwght%5D.codepoints',
      'https://github.com/google/material-design-icons/raw/master/variablefont/MaterialSymbolsOutlined%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf'),
  MaterialSymbolsVariableFont(
      'rounded',
      'MaterialSymbolsRounded',
      'https://github.com/google/material-design-icons/raw/master/variablefont/MaterialSymbolsRounded%5BFILL%2CGRAD%2Copsz%2Cwght%5D.codepoints',
      'https://github.com/google/material-design-icons/raw/master/variablefont/MaterialSymbolsRounded%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf'),
  MaterialSymbolsVariableFont(
      'sharp',
      'MaterialSymbolsSharp',
      'https://github.com/google/material-design-icons/raw/master/variablefont/MaterialSymbolsSharp%5BFILL%2CGRAD%2Copsz%2Cwght%5D.codepoints',
      'https://github.com/google/material-design-icons/raw/master/variablefont/MaterialSymbolsSharp%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf'),
];

final dartReservedWords = [
  'class',
  'switch',
  'try',
];

/// This is the prefix that we will place before iconnames which are not valid class member names because they are numbers or reserved words.
const prefixForReservedWordsAndNumbers = '\$';

/// Path to write the downloaded TTF files to
/// KLUDGE - currently we have to open the fonts and RE-CALC metrics to get them to render correctly in flutter.
/// We recalc metrics using FontForge??? -
const pathToWriteTTFFiles = '../rawFontsUnfixed/';

/// Path to write the dart source files to
const pathToWriteDartFiles = '../lib/';

/// Path to write example dart source files to
const pathToWriteExampleDartFiles = '../example/lib/';

Future<void> downloadURLASBinaryFile(
    HttpClient client, String url, String filename) async {
  print('downloadURLASBinaryFile $client $url $filename');
  final request = await client.getUrl(Uri.parse(url));
  final response = await request.close();
  if (response.statusCode == HttpStatus.ok) {
    print('Got OK response for URL $url');
    await response.pipe(File('./$filename').openWrite());
  } else {
    print('ERROR reading the url $url');
    throw Exception(
        'File not downloaded destination filename $filename from url $url');
  }
}

// ignore: long-method
Future<void> main(List<String> args) async {
  final parser = ArgParser()
        ..addFlag(
          'help',
          abbr: 'h',
          negatable: false,
          help: 'Print help text and exit.',
        )
        ..addFlag(
          'verbose',
          abbr: 'v',
          negatable: false,
          help: 'Print extra info during processing.',
        )
        ..addFlag(
          'downloadfonts',
          abbr: 'd',
          negatable: false,
          help:
              'The TTF font files will be downloaded to the $pathToWriteTTFFiles directory if this flag is passed.',
        )
        ..addFlag(
          'suffix_icon_names',
          abbr: 's',
          negatable: false,
          help:
              'Add `_outlined`, `_rounded` or `_sharp` suffixes to every icon name in corresponding MaterialSymbolsXXXXX classes.',
        )
        ..addFlag(
          'combined_universal',
          abbr: 'c',
          negatable: false,
          help:
              'If this flag is supplied a `universal.dart` will be created with all 3 flavors combined into a single class. This is however is not performant.',
        )
      /*
    ..addOption(
      'inputjsonfile',
      abbr: 'i',
      defaultsTo: 'missing',
      help:
          'This argument should be followed by the path to the local file containing the google fonts api output json.',
    )
    */
      ;
  late final ArgResults results;

  try {
    results = parser.parse(args);
  } catch (e) {
    printUsage(parser);
    exit(0);
  }

  if (results['help'] as bool) {
    printUsage(parser);
    exit(0);
  }

  final downloadFontsFlag = results['downloadfonts'] as bool;
  final verboseFlag = results['verbose'] as bool;
  final combinedUniversal = results['combined_universal'] as bool;
  final suffixIconNames = results['suffix_icon_names'] as bool;

  /*
   The codepoint files are in the form:
      ```
      10k e951
      10mp e952
      11mp e953
      123 eb8d
      12mp e954
      ...
      ```
    On each line the icon name comes first followed by the hex string of the codepoint, with a separating space
  */
  final List<String> renamedIconNames = [];

  final client = HttpClient();
  for (final fontFlavor in variableFontFlavors) {
    final iconNameList = fontFlavor.iconNameList;
    final codePointList = fontFlavor.codePointList;

    print(
      'Attempting to retrieve codepoint file from `${fontFlavor.codepointFileUrl}`',
    );

    final request = await client.getUrl(Uri.parse(fontFlavor.codepointFileUrl));
    final response = await request.close();

    if (response.statusCode != HttpStatus.ok) {
      // Unexpected status returned.
      print(
        'Request to retrieve font codepoints from ${fontFlavor.codepointFileUrl} returned UNEXPECTED status code ${response.statusCode}',
      );
    } else {
      String rawCodepointListData =
          await response.transform(utf8.decoder).join();

      if (verboseFlag) {
        print(
          'Font codepoints retrieved :\n$rawCodepointListData',
        );
      }

      LineSplitter.split(rawCodepointListData).forEach(
        (line) {
          final iconnameCodePointPair = line.trim();
          if (iconnameCodePointPair.isNotEmpty) {
            final parts = iconnameCodePointPair.split(' ');
            assert(parts.length == 2,
                'Expected 2 parts on the line `$iconnameCodePointPair`');
            var iconname = parts[0];
            final codepoint = parts[1];
            if (dartReservedWords.contains(iconname) ||
                iconname.startsWith(RegExp(r'[0-9]'))) {
              renamedIconNames.add(iconname);
              iconname = '$prefixForReservedWordsAndNumbers$iconname';
            }

            iconNameList.add(iconname);
            codePointList.add(codepoint);
          }
        },
      );
      print(
        'Read ${iconNameList.length} fonts from `${fontFlavor.codepointFileUrl}`',
      );
    }

    // Generate the source files needed for this flavor

    // Now Grab the latest font file
    String filenameWithPath = '$pathToWriteTTFFiles${fontFlavor.filename}';
    if (downloadFontsFlag) {
      print(
          'Downloading ${fontFlavor.ttfFontFileUrl} to local file `$filenameWithPath}`');
      await downloadURLASBinaryFile(
          client, fontFlavor.ttfFontFileUrl, filenameWithPath);
    } else {
      print(
          'Skipped downloading ${fontFlavor.ttfFontFileUrl} to local file `$filenameWithPath}`');
    }
  }

  if (verboseFlag) {
    print('Renamed icon names which had _ added as prefix $renamedIconNames');
  }

  // Now we have loaded up [variableFontFlavors] with the downloaded code point info.
  // We are ready to write the source files.
  for (final fontFlavor in variableFontFlavors) {
    final sourceFilename = '$pathToWriteDartFiles${fontFlavor.flavor}.dart';
    final exampleSourceFilename =
        '$pathToWriteExampleDartFiles${fontFlavor.flavor}_map.dart';

    writeSourceFile(fontFlavor, variableFontFlavors, sourceFilename);

    writeExampleSourceFile(fontFlavor, exampleSourceFilename, sourceFilename);

    final suffixSourceFilename =
        '$pathToWriteDartFiles${fontFlavor.flavor}_suffix.dart';
    writeSourceFile(fontFlavor, variableFontFlavors, suffixSourceFilename,
        suffixVersion: true, suffixIconNames: suffixIconNames);

    final suffixExampleSourceFilename =
        '$pathToWriteExampleDartFiles${fontFlavor.flavor}_suffix_map.dart';
    writeExampleSourceFile(
        fontFlavor, suffixExampleSourceFilename, suffixSourceFilename,
        suffixVersion: true, suffixIconNames: suffixIconNames);
  }

  if (combinedUniversal) {
    // write all flavors together with suffixed symbol names
    const combinedSourceFilename = '${pathToWriteDartFiles}universal.dart';
    writeCombinedSourceFile(variableFontFlavors, combinedSourceFilename,
        suffixVersion: true);

    const combinedExampleSourceFilename =
        '${pathToWriteExampleDartFiles}universal_map.dart';
    writeCombinedExampleSourceFile(variableFontFlavors,
        combinedExampleSourceFilename, combinedSourceFilename,
        suffixVersion: true);
  }

  exit(0);
}

void printUsage(ArgParser parser) {
  print(
    '''Usage: update_constants.dart [[--googlefontslist | -g] filenamecontaininglist.txt] [[--inputjsonfile | -i] api_output.json] | [[--apikey | -a] YOUR_SECRET_GOOGLE_FONT_API_KEY]

The list of fonts included in the current GoogleFonts package should be generated using the 
`display_googlefonts_fontlist.dart` program included within the `examples` subdirectory.
(GoogleFonts is a flutter package so the list cannot be automatically generated here).
Run the `display_googlefonts_fontlist.dart` program and copy the list of fonts provided and
save them into a local file within this directory.
This file is then supplied on the command line using the --googlefontslist (or -g) directive.
If the font list is NOT supplied then all fonts include within the googlefonts API Json will be
included within the output constants.dart (including those not available from the
current googlefonts package).

The google fonts API JSON can be supplied one of two ways:

1) Using a local file that contains the output of the google fonts api generated at
https://developers.google.com/fonts/docs/developer_api and saved in a local file.
The --inputjsonfile (or -i) and flag is then used with the name of the local file containing
the output from clicking the 'EXECUTE' button on the google fonts developer page above.

2) The second method is to supply your private (secret) google fonts api key on the
command line using the --apikey (or -a) argument followed by your secret key.  This method
directly queries the google fonts API and retreives the JSON file.

${parser.usage}
''',
  );
}

void writeSourceFile(
    MaterialSymbolsVariableFont fontinfo,
    List<MaterialSymbolsVariableFont> allFlavorFontInfoList,
    String sourceFilename,
    {bool suffixVersion = false,
    bool suffixIconNames = false}) {
  assert(fontinfo.iconNameList.length == fontinfo.codePointList.length);
  late final String classFlavor;
  if (suffixVersion) {
    classFlavor =
        '${fontinfo.flavor[0].toUpperCase()}${fontinfo.flavor.substring(1).toLowerCase()}';
  } else {
    classFlavor = '';
  }
  final sourceFileContent = StringBuffer('''// GENERATED FILE. DO NOT EDIT.
//
// To edit this file modify the generator file `generator/update_package.dart` and
// re-generate.
// This file was generated using the Material Symbols codepoint file
// localed at ${fontinfo.codepointFileUrl}.
// These codepoints correspond to symbols within the corresponding variable font.
// The font was downloaded from ${fontinfo.ttfFontFileUrl} and added to this package.
// This file was generated ${DateTime.now()} by the dart file
// `generator/update_package.dart`.
//
// Copyright 2022 . All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library material_symbols_icons;

import 'package:flutter/widgets.dart';

import 'material_symbols_icons.dart';

// ignore_for_file: constant_identifier_names
// ignore_for_file: non_constant_identifier_names

/// Identifiers for the supported [Material Symbols](https://fonts.google.com/icons?selected=Material+Symbols).
///
/// Use with the [Icon] class to show specific icons. Icons are identified by
/// their name as listed below, e.g. [MaterialSymbols$classFlavor.airplanemode_on].
///
/// Search and find the perfect icon on the [Google Fonts](https://fonts.google.com/icons?selected=Material+Symbols) website.
///
///
/// {@tool snippet}
/// This example shows how to create a [Row] of [Icon]s in different colors and
/// sizes. The first [Icon] uses a [semanticLabel] to announce in accessibility
/// modes like TalkBack and VoiceOver.
///
/// ![The following code snippet would generate a row of icons consisting of a pink heart, a green musical note, and a blue umbrella, each progressively bigger than the last.](https://timmaffett.github.io/assets-for-api-docs/assets/widgets/icon.png)
///
/// ```dart
/// const Row(
///   mainAxisAlignment: MainAxisAlignment.spaceAround,
///   children: <Widget>[
///     Icon(
///       MaterialSymbols$classFlavor.favorite,
///       color: Colors.pink,
///       size: 24.0,
///       semanticLabel: 'Text to announce in accessibility modes',
///     ),
///     Icon(
///       MaterialSymbols$classFlavor.audiotrack,
///       color: Colors.green,
///       size: 30.0,
///     ),
///     Icon(
///       MaterialSymbols$classFlavor.beach_access,
///       color: Colors.blue,
///       size: 36.0,
///     ),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [Icon]
///  * [IconButton]
///  * <https://fonts.google.com/icons?selected=Material+Symbols>

@staticIconProvider
class MaterialSymbols$classFlavor extends MaterialSymbolsBase {
  // BEGIN GENERATED ICONS
  static const _family = '${fontinfo.familyNameToUse}';
  static const _package = 'material_symbols_icons';
''');

  var iconCount = 0;
  final iconNameList = fontinfo.iconNameList;
  final codePointList = fontinfo.codePointList;
  for (int i = 0; i < iconNameList.length; i++) {
    var iconname = iconNameList[i];
    final codepoint = codePointList[i];

    // if we added a _ because it started with a number the remove it for html
    final iconnameNoLeadingPrefix =
        iconname.startsWith(prefixForReservedWordsAndNumbers)
            ? iconname.substring(prefixForReservedWordsAndNumbers.length)
            : iconname;
    if (suffixIconNames) {
      iconname = '${iconname}_${fontinfo.flavor}';
    }
    sourceFileContent.writeln();
    sourceFileContent.writeln(
        '  /// <span class="material-symbols-${fontinfo.flavor}">$iconnameNoLeadingPrefix</span> &#x$codepoint; material symbol named "$iconname".');
    sourceFileContent.writeln("  static const IconData $iconname =");
    sourceFileContent.writeln(
        "      IconData(0x$codepoint, fontFamily: _family, fontPackage: _package);");
    iconCount++;
  }

  sourceFileContent.writeln();
  sourceFileContent.writeln('  // END GENERATED ICONS');
  sourceFileContent.writeln('}');

  File(sourceFilename).writeAsStringSync(sourceFileContent.toString());

  print('Wrote $iconCount icons to $sourceFilename');
}

/// Write a combined version of the MaterialSymbols class with outlined, rounded and sharp versions of
/// each icon.  Each icon name has a corresponding suffix (`_outlined`, `_rounded` and `_sharp`).
void writeCombinedSourceFile(
    List<MaterialSymbolsVariableFont> fontinfoList, String sourceFilename,
    {bool suffixVersion = true}) {
  final fontinfo = fontinfoList[0];

  final sourceFileContent = StringBuffer('''// GENERATED FILE. DO NOT EDIT.
//
// To edit this file modify the generator file `generator/update_package.dart` and
// re-generate.
// This file was generated using the Material Symbols codepoint file
// localed at ${fontinfo.codepointFileUrl}.
// These codepoints correspond to symbols within the corresponding variable font.
// The font was downloaded from ${fontinfo.ttfFontFileUrl} and added to this package.
// This file was generated ${DateTime.now()} by the dart file
// `generator/update_package.dart`.
//
// Copyright 2022 . All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

library material_symbols_icons;

import 'package:flutter/widgets.dart';

import 'material_symbols_icons.dart';

// ignore_for_file: constant_identifier_names
// ignore_for_file: non_constant_identifier_names

/// Identifiers for the supported [Material Symbols](https://fonts.google.com/icons?selected=Material+Symbols).
///
/// Use with the [Icon] class to show specific icons. Icons are identified by
/// their name as listed below, e.g. [MaterialSymbols.airplanemode_on].
///
/// Search and find the perfect icon on the [Google Fonts](https://fonts.google.com/icons?selected=Material+Symbols) website.
///
///
/// {@tool snippet}
/// This example shows how to create a [Row] of [Icon]s in different colors and
/// sizes. The first [Icon] uses a [MaterialSymbols.semanticLabel] to announce in accessibility
/// modes like TalkBack and VoiceOver.
///
/// ![The following code snippet would generate a row of icons consisting of a pink heart, a green musical note, and a blue umbrella, each progressively bigger than the last.](https://timmaffett.github.io/assets-for-api-docs/assets/widgets/icon.png)
///
/// ```dart
/// const Row(
///   mainAxisAlignment: MainAxisAlignment.spaceAround,
///   children: <Widget>[
///     Icon(
///       MaterialSymbols.favorite_outlined,
///       color: Colors.pink,
///       size: 24.0,
///       semanticLabel: 'Text to announce in accessibility modes',
///     ),
///     Icon(
///       MaterialSymbols.audiotrack_rounded,
///       color: Colors.green,
///       size: 30.0,
///     ),
///     Icon(
///       MaterialSymbols.beach_access_sharp,
///       color: Colors.blue,
///       size: 36.0,
///     ),
///   ],
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [Icon]
///  * [IconButton]
///  * <https://fonts.google.com/icons?selected=Material+Symbols>

@staticIconProvider
class MaterialSymbols extends MaterialSymbolsBase {
  // BEGIN GENERATED ICONS
  static const _family = '${fontinfo.familyNameToUse}';
  static const _package = 'material_symbols_icons';
''');

  // all font flavors should have same number of codepoints
  int? lastCount;
  for (final fontinfo in fontinfoList) {
    assert(fontinfo.iconNameList.length == fontinfo.codePointList.length);
    if (lastCount != null) {
      assert(fontinfo.iconNameList.length == lastCount);
    }
    lastCount = fontinfo.iconNameList.length;
  }

  var iconCount = 0;

  for (int i = 0; i < lastCount!; i++) {
    for (final fontinfo in fontinfoList) {
      var iconname = fontinfo.iconNameList[i];
      final codepoint = fontinfo.codePointList[i];

      // if we added a _ because it started with a number the remove it for html
      final iconnameNoLeadingPrefix =
          iconname.startsWith(prefixForReservedWordsAndNumbers)
              ? iconname.substring(prefixForReservedWordsAndNumbers.length)
              : iconname;
      if (suffixVersion) {
        iconname = '${iconname}_${fontinfo.flavor}';
      }
      sourceFileContent.writeln();
      sourceFileContent.writeln(
          '  /// <span class="material-symbols-${fontinfo.flavor}">$iconnameNoLeadingPrefix</span> &#x$codepoint; material symbol named "${iconname}_${fontinfo.flavor}".');
      sourceFileContent.writeln("  static const IconData $iconname =");
      sourceFileContent.writeln(
          "      IconData(0x$codepoint, fontFamily: _family, fontPackage: _package);");
      iconCount++;
    }
  }
  sourceFileContent.writeln('  // END GENERATED ICONS');
  sourceFileContent.writeln('}');

  File(sourceFilename).writeAsStringSync(sourceFileContent.toString());

  print('Wrote $iconCount COMBINED icons to $sourceFilename');
}

void writeExampleSourceFile(MaterialSymbolsVariableFont fontinfo,
    String exampleSourceFilename, String sourceFilename,
    {bool suffixVersion = false, bool suffixIconNames = false}) {
  assert(fontinfo.iconNameList.length == fontinfo.codePointList.length);
  late final String classFlavor;
  if (suffixVersion) {
    classFlavor =
        '${fontinfo.flavor[0].toUpperCase()}${fontinfo.flavor.substring(1).toLowerCase()}';
  } else {
    classFlavor = '';
  }

  sourceFilename = path.basename(sourceFilename);

  final sourceFileContent = StringBuffer('''// GENERATED FILE. DO NOT EDIT.
//
// To edit this file modify the generator file `generator/update_package.dart` and
// re-generate.
// This file was generated using the Material Symbols codepoint file
// localed at ${fontinfo.codepointFileUrl}.
// These codepoints correspond to symbols within the corresponding variable font.
// The font was downloaded from ${fontinfo.ttfFontFileUrl} and added to this package.
// This file was generated ${DateTime.now()} by the dart file
// `generator/update_package.dart`.
//
// Copyright 2022 . All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/$sourceFilename';

// ignore_for_file: constant_identifier_names
// ignore_for_file: non_constant_identifier_names

// BEGIN GENERATED static array
Map<String, IconData> materialSymbols${classFlavor}Map = {
''');

  var iconCount = 0;
  final iconNameList = fontinfo.iconNameList;
  for (int i = 0; i < iconNameList.length; i++) {
    var iconname = iconNameList[i];

    if (suffixIconNames) {
      iconname = '${iconname}_${fontinfo.flavor}';
    }
    final testStr =
        "  '${iconname.replaceAll('\$', '\\\$')}': MaterialSymbols$classFlavor.$iconname,";
    if (testStr.length <= 80) {
      sourceFileContent.writeln(testStr);
    } else {
      // SPLIT THE LINE
      sourceFileContent.writeln("  '${iconname.replaceAll('\$', '\\\$')}':");
      sourceFileContent.writeln("      MaterialSymbols$classFlavor.$iconname,");
    }
    iconCount++;
  }

  sourceFileContent.writeln('};');
  sourceFileContent.writeln('// END GENERATED ICONS');

  File(exampleSourceFilename).writeAsStringSync(sourceFileContent.toString());

  print('Wrote $iconCount icons to $exampleSourceFilename');
}

/// Write a combined version of the MaterialSymbols class with outlined, rounded and sharp versions of
/// each icon.  Each icon name has a corresponding suffix (`_outlined`, `_rounded` and `_sharp`).
void writeCombinedExampleSourceFile(
    List<MaterialSymbolsVariableFont> fontinfoList,
    String exampleSourceFilename,
    String sourceFilename,
    {bool suffixVersion = true}) {
  final fontinfo = fontinfoList[0];
  sourceFilename = path.basename(sourceFilename);

  final sourceFileContent = StringBuffer('''// GENERATED FILE. DO NOT EDIT.
//
// To edit this file modify the generator file `generator/update_package.dart` and
// re-generate.
// This file was generated using the Material Symbols codepoint file
// localed at ${fontinfo.codepointFileUrl}.
// These codepoints correspond to symbols within the corresponding variable font.
// The font was downloaded from ${fontinfo.ttfFontFileUrl} and added to this package.
// This file was generated ${DateTime.now()} by the dart file
// `generator/update_package.dart`.
//
// Copyright 2022 . All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/$sourceFilename';

// ignore_for_file: constant_identifier_names
// ignore_for_file: non_constant_identifier_names

// BEGIN GENERATED static array
Map<String, IconData> materialSymbolsUniversalMap = {
''');

  // all font flavors should have same number of codepoints
  int? lastCount;
  for (final fontinfo in fontinfoList) {
    assert(fontinfo.iconNameList.length == fontinfo.codePointList.length);
    if (lastCount != null) {
      assert(fontinfo.iconNameList.length == lastCount);
    }
    lastCount = fontinfo.iconNameList.length;
  }

  var iconCount = 0;

  for (int i = 0; i < lastCount!; i++) {
    for (final fontinfo in fontinfoList) {
      var iconname = fontinfo.iconNameList[i];

      if (suffixVersion) {
        iconname = '${iconname}_${fontinfo.flavor}';
      }
      final lineStr =
          "  '${iconname.replaceAll('\$', '\\\$')}': MaterialSymbols.$iconname,";
      if (lineStr.length <= 80) {
        sourceFileContent.writeln(lineStr);
      } else {
        // SPLIT THE LINE
        sourceFileContent.writeln("  '${iconname.replaceAll('\$', '\\\$')}':");
        sourceFileContent.writeln("      MaterialSymbols.$iconname,");
      }
      iconCount++;
    }
  }
  sourceFileContent.writeln('};');
  sourceFileContent.writeln('// END GENERATED ICONS');

  File(exampleSourceFilename).writeAsStringSync(sourceFileContent.toString());

  print('Wrote $iconCount COMBINED icons to $exampleSourceFilename');
}
