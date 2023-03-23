// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
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

late final bool verboseFlag;

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

/// Path to write the downloaded TTF files to `../rawFontsUnfixed`
/// KLUDGE - currently we have to patch the fonts with the correct metrics to get them to render correctly in flutter.
/// This is done using the `../rawFontsUnfixed/fixFontMetricsAndUpdateLibFonts.sh` script.  This script patches the
/// fonts and then copies them to `../lib/fonts`.  This script requires python and the fonttools package to be
/// installed on the machine.
///
/// Once the fonts have been corrected in their github repository this step will not be required.
///
/// THIS IS NON-IDEAL (obvisouly!!) - and we have submitted a issue to the material symbols github repo
/// If this is not done then Flutter renders the icons lower in the text box then they should be
/// (ie. *not centered*).
const pathToWriteTTFFiles = '../rawFontsUnfixed/';

/// Path to write the dart source files to
const pathToWriteDartFiles = '../lib/';

/// Path to write example dart source files to
const pathToWriteExampleDartFiles = '../example/lib/';

Future<void> downloadURLASBinaryFile(
    HttpClient client, String url, String filename) async {
  final request = await client.getUrl(Uri.parse(url));
  final response = await request.close();
  if (response.statusCode == HttpStatus.ok) {
    if (verboseFlag) {
      print('Got OK response for URL $url - copying to $filename');
    }
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
          'Add `_outlined`, `_rounded` or `_sharp` suffixes to every icon name in corresponding MaterialSymbols, MaterialSymbolsOutlined, MaterialSymbolsRounded and MaterialSymbolsSharp classes.',
    )
    ..addFlag(
      'combined_universal',
      abbr: 'c',
      negatable: false,
      defaultsTo: true,
      help:
          'If this flag is supplied a `universal.dart` will be created with all 3 flavors combined into a single class.',
    );
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
  verboseFlag = results['verbose'] as bool;
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
        'Read ${iconNameList.length} codepoints from `${fontFlavor.codepointFileUrl}`',
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
      print('SKIPPED downloading ${fontFlavor.ttfFontFileUrl}');
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
    '''Usage:

This program will download the latest Material Symbol Icon fonts and codepoint files and
generate the relevant source files for this package.

The --downloadfonts flag should be used if you also need to download the font files.

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
  late final String libraryFlavor;
  late final String categoryFlavor;
  late final String extraMessage;
  if (suffixVersion) {
    classFlavor =
        '${fontinfo.flavor[0].toUpperCase()}${fontinfo.flavor.substring(1).toLowerCase()}';
    categoryFlavor = '${classFlavor}_Suffix';
    libraryFlavor = '${fontinfo.flavor.toLowerCase()}_suffix';
    extraMessage = ' (with style as suffix appended to the class name)';
  } else {
    classFlavor = '';
    categoryFlavor =
        '${fontinfo.flavor[0].toUpperCase()}${fontinfo.flavor.substring(1).toLowerCase()}';
    libraryFlavor = fontinfo.flavor.toLowerCase();
    extraMessage = '';
  }

  StringBuffer getFakeDartDocsForIconNames() {
    final fakeDartDocs = StringBuffer();
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
      fakeDartDocs.writeln('///');
      fakeDartDocs.writeln(
          '/// <span class="material-symbols-${fontinfo.flavor}">$iconnameNoLeadingPrefix</span> MaterialSymbols$classFlavor.$iconname');
    }
    return fakeDartDocs;
  }

  final fakeDartDocs = getFakeDartDocsForIconNames();

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
// Copyright 2023 . All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// ${libraryFlavor[0].toUpperCase()}${libraryFlavor.substring(1).toLowerCase()} style version of icons.  Accessed via [MaterialSymbols$classFlavor]$extraMessage<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Rounded:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" /><link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Sharp:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
/// by using the icon name`MaterialSymbols$classFlavor.iconname`, for example `MaterialSymbols$classFlavor.circle` or `MaterialSymbols$classFlavor.square`.
///
/// `import 'package:material_symbols_icons/$libraryFlavor.dart';`
///
/// {@category $categoryFlavor}
library $libraryFlavor;

import 'package:flutter/widgets.dart';
import 'material_symbols_icons.dart';

// ignore_for_file: constant_identifier_names
// ignore_for_file: non_constant_identifier_names

/// Access icons using `MaterialSymbols$classFlavor.iconname` with icon names as identifiers. Explore available icons at [Google Font's Material Symbols Explorer](https://fonts.google.com/icons?selected=Material+Symbols).
/// <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Rounded:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" /><link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Sharp:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" /><style>span.material-symbols-outlined, span.material-symbols-rounded, span.material-symbols-sharp { font-size:48px; color: teal; }</style>
/// All icon names that start with a number (like `360` or `9M`) but have their icon names prefixed with a `\$` to make the names valid dart class member names.
/// For example if you want to access the icon with the name `360` you use `MaterialSymbols$classFlavor.\$360` instead.
///
/// Additionally the iconnames `class`, `switch` and `try` have also been renamed with a leading `\$` (`\$class`, `\$switch` and `\$try`) as these are dart language
/// reserved words.
///
/// Use with the [Icon] class to show specific icons. Icons are identified by
/// their name as listed below, e.g. [MaterialSymbols$classFlavor.airplanemode_active].
///
/// Search and find the perfect icon on the [Google Font's Material Symbols Explorer](https://fonts.google.com/icons?selected=Material+Symbols) website.
///
///
/// This example shows how to create a [Row] of [Icon]s in different colors and
/// sizes. The first [Icon] uses a [Icon.semanticLabel] to announce in accessibility
/// modes like TalkBack and VoiceOver.
///
/// ![The following code snippet would generate a row of icons consisting of a pink bike, a green sun, and a blue beach umbrella, each progressively bigger than the last.](https://github.com/timmaffett/material_symbols_icons/raw/master/media/${libraryFlavor}_example.png)
///
/// ```dart
/// const Row(
///   mainAxisAlignment: MainAxisAlignment.spaceAround,
///   children: <Widget>[
///     Icon(
///       MaterialSymbols$classFlavor.pedal_bike,
///       color: Colors.pink,
///       size: 24.0,
///       semanticLabel: 'Text to announce in accessibility modes',
///     ),
///     Icon(
///       MaterialSymbols$classFlavor.sunny,
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
///
/// See also:
///
///  * [Icon]
///  * [IconButton]
///  * <https://fonts.google.com/icons?selected=Material+Symbols>
///
/// NOTE: IMPORTANT - Because of the gross inefficiencies of dart doc ALL icon member names
/// have to be marked with `@ nodoc` because it generates 12gigs of redundant data.
/// The icons and corresponding symbols names follow:
///
$fakeDartDocs//pub.dev does not like//@staticIconProvider
class MaterialSymbols$classFlavor extends MaterialSymbolsBase {
  // This class is not meant to be instantiated or extended; this constructor
  // prevents instantiation and extension.
  MaterialSymbols$classFlavor._();

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
        //ALL OUTLINE'  /// <span class="material-symbols-outlined">$iconnameNoLeadingPrefix</span> material symbol named "$iconname".');
        '  /// @nodoc <span class="material-symbols-${fontinfo.flavor}">$iconnameNoLeadingPrefix</span> material symbol named "$iconname".');
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
  StringBuffer getFakeDartDocsForIconNames() {
    final fakeDartDocs = StringBuffer();
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
        fakeDartDocs.writeln('///');
        fakeDartDocs.writeln(
            '/// <span class="material-symbols-${fontinfo.flavor}">$iconnameNoLeadingPrefix</span> MaterialSymbols.$iconname');
      }
    }
    return fakeDartDocs;
  }

  final fakeDartDocs = getFakeDartDocsForIconNames();

  final sourceFileContent = StringBuffer('''// GENERATED FILE. DO NOT EDIT.
//
// To edit this file modify the generator file `generator/update_package.dart` and
// re-generate.
// This file was generated using the Material Symbols codepoint files
// localed at ${fontinfoList[0].codepointFileUrl},
// ${fontinfoList[1].codepointFileUrl} and
// ${fontinfoList[2].codepointFileUrl}.
// These codepoints correspond to symbols within the corresponding variable font.
// The fonts were downloaded from
// ${fontinfoList[0].ttfFontFileUrl},
// ${fontinfoList[1].ttfFontFileUrl}, and
// ${fontinfoList[2].ttfFontFileUrl}
// and added to this package.
// This file was generated ${DateTime.now()} by the dart file
// `generator/update_package.dart`.
//
// Copyright 2023 . All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Combined verions of all three styles within [MaterialSymbols] - all icon names have the style as a suffix to the icon name.
/// Accessed via `MaterialSymbols.iconname_style`, for example `MaterialSymbols.circle_outlined` or
/// `MaterialSymbols.circle_sharp`.<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Rounded:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" /><link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Sharp:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
///
/// `import 'package:material_symbols_icons/universal.dart';`
///
/// {@category CombinedUniversal}
library combined_universal;

import 'package:flutter/widgets.dart';
import 'material_symbols_icons.dart';

// ignore_for_file: constant_identifier_names
// ignore_for_file: non_constant_identifier_names

/// Access icons using `MaterialSymbols.iconname_style` with iconname_style as identifiers. Explore available icons at [Google Font's Material Symbols Explorer](https://fonts.google.com/icons?selected=Material+Symbols).
/// <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Rounded:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" /><link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Sharp:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" /><style>span.material-symbols-outlined, span.material-symbols-rounded, span.material-symbols-sharp { font-size:48px; color: teal; }</style>
/// All icon names that start with a number (like `360` or `9M`) but have their icon names prefixed with a `\$` to make the names valid dart class member names.
/// For example if you want to access the icon with the name `360` you use `MaterialSymbols.\$360` instead.
///
/// Additionally the iconnames `class`, `switch` and `try` have also been renamed with a leading `\$` (`\$class`, `\$switch` and `\$try`) as these are dart language
/// reserved words.
///
/// Use with the [Icon] class to show specific icons. Icons are identified by
/// their name FOLLOWED by the desired style as a suffix, as listed below, e.g. [MaterialSymbols.airplanemode_active_rounded].
///
/// Search and find the perfect icon on the [Google Fonts](https://fonts.google.com/icons?selected=Material+Symbols) website.
///
///
/// This example shows how to create a [Row] of [Icon]s in different colors and
/// sizes. The first [Icon] uses a [Icon.semanticLabel] to announce in accessibility
/// modes like TalkBack and VoiceOver.
///
/// ![The following code snippet would generate a row of icons consisting of a pink bike (outlined style), a green sun (rounded style), and a blue beach umbrella (sharp style), each progressively bigger than the last.](https://github.com/timmaffett/material_symbols_icons/raw/master/media/universal_example.png)
///
/// ```dart
/// const Row(
///   mainAxisAlignment: MainAxisAlignment.spaceAround,
///   children: <Widget>[
///     Icon(
///       MaterialSymbols.pedal_bike_outlined,
///       color: Colors.pink,
///       size: 24.0,
///       semanticLabel: 'Text to announce in accessibility modes',
///     ),
///     Icon(
///       MaterialSymbols.sunny_rounded,
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
///
/// See also:
///
///  * [Icon]
///  * [IconButton]
///  * <https://fonts.google.com/icons?selected=Material+Symbols>
///
/// NOTE: IMPORTANT - Because of the gross inefficiencies of dart doc ALL icon member names
/// have to be marked with `@ nodoc` because it generates 12gigs of redundant data.
/// The icons and corresponding symbols names follow:
///
$fakeDartDocs//pub.dev does not like//@staticIconProvider
class MaterialSymbols extends MaterialSymbolsBase {
  // This class is not meant to be instantiated or extended; this constructor
  // prevents instantiation and extension.
  MaterialSymbols._();

  // BEGIN GENERATED ICONS
''');

  // all font flavors should have same number of codepoints
  int? lastCount;
  for (final fontinfo in fontinfoList) {
    assert(fontinfo.iconNameList.length == fontinfo.codePointList.length);
    if (lastCount != null) {
      assert(fontinfo.iconNameList.length == lastCount);
    }
    lastCount = fontinfo.iconNameList.length;

    // write constant names
    sourceFileContent.writeln(
        "  static const _family_${fontinfo.flavor} = '${fontinfo.familyNameToUse}';");
  }
  sourceFileContent
      .writeln("  static const _package = 'material_symbols_icons';");

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
          //ALL OUTLINE  '  /// <span class="material-symbols-outlined">$iconnameNoLeadingPrefix</span> material symbol named "$iconname".');
          '  /// @nodoc<span class="material-symbols-${fontinfo.flavor}">$iconnameNoLeadingPrefix</span> material symbol named "$iconname".');
      sourceFileContent.writeln("  static const IconData $iconname =");
      sourceFileContent.writeln(
          "      IconData(0x$codepoint, fontFamily: _family_${fontinfo.flavor}, fontPackage: _package);");
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
// Copyright 2023 . All rights reserved.
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
  sourceFilename = path.basename(sourceFilename);

  final sourceFileContent = StringBuffer('''// GENERATED FILE. DO NOT EDIT.
//
// To edit this file modify the generator file `generator/update_package.dart` and
// re-generate.
// This file was generated using the Material Symbols codepoint files
// localed at ${fontinfoList[0].codepointFileUrl},
// ${fontinfoList[1].codepointFileUrl} and
// ${fontinfoList[2].codepointFileUrl}.
// These codepoints correspond to symbols within the corresponding variable font.
// The fonts were downloaded from
// ${fontinfoList[0].ttfFontFileUrl},
// ${fontinfoList[1].ttfFontFileUrl}, and
// ${fontinfoList[2].ttfFontFileUrl}
// and added to this package.
// This file was generated ${DateTime.now()} by the dart file
// `generator/update_package.dart`.
//
// Copyright 2023 . All rights reserved.
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
