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

class IconInfo {
  final String originalIconName;
  final String iconName;
  final String codePoint;

  IconInfo(this.originalIconName, this.iconName, this.codePoint);
}

class MaterialSymbolsVariableFont {
  final String flavor;
  final String iconDataClass;
  final String familyNameToUse;
  final String codepointFileUrl;
  final String ttfFontFileUrl;
  late final String filename;
  final List<IconInfo> iconInfoList = [];

  MaterialSymbolsVariableFont(this.flavor, this.iconDataClass, this.familyNameToUse,
      this.codepointFileUrl, this.ttfFontFileUrl) {
    final urlfilename = path.basename(ttfFontFileUrl);
    filename = Uri.decodeFull(urlfilename);
  }
}

List<MaterialSymbolsVariableFont> variableFontFlavors = [
  MaterialSymbolsVariableFont(
      'outlined',
      'IconDataOutlined',
      'MaterialSymbolsOutlined',
      'https://github.com/google/material-design-icons/raw/master/variablefont/MaterialSymbolsOutlined%5BFILL%2CGRAD%2Copsz%2Cwght%5D.codepoints',
      'https://github.com/google/material-design-icons/raw/master/variablefont/MaterialSymbolsOutlined%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf'),
  MaterialSymbolsVariableFont(
      'rounded',
      'IconDataRounded',
      'MaterialSymbolsRounded',
      'https://github.com/google/material-design-icons/raw/master/variablefont/MaterialSymbolsRounded%5BFILL%2CGRAD%2Copsz%2Cwght%5D.codepoints',
      'https://github.com/google/material-design-icons/raw/master/variablefont/MaterialSymbolsRounded%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf'),
  MaterialSymbolsVariableFont(
      'sharp',
      'IconDataSharp',
      'MaterialSymbolsSharp',
      'https://github.com/google/material-design-icons/raw/master/variablefont/MaterialSymbolsSharp%5BFILL%2CGRAD%2Copsz%2Cwght%5D.codepoints',
      'https://github.com/google/material-design-icons/raw/master/variablefont/MaterialSymbolsSharp%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf'),
];

/* NOT CURRENTLY USED
const Map<String, List<String>> _platformAdaptiveIdentifiers =
    <String, List<String>>{
  // Mapping of Flutter IDs to an Android/agnostic ID and an iOS ID.
  // Flutter IDs can be anything, but should be chosen to be agnostic.
  'arrow_back': <String>['arrow_back', 'arrow_back_ios'],
  'arrow_forward': <String>['arrow_forward', 'arrow_forward_ios'],
  'flip_camera': <String>['flip_camera_android', 'flip_camera_ios'],
  'more': <String>['more_vert', 'more_horiz'],
  'share': <String>['share', 'ios_share'],
};
*/

// Rewrite certain Flutter IDs (numbers) using prefix matching.
const Map<String, String> _identifierPrefixRewrites = <String, String>{
  '3d_rotation': 'threed_rotation',
  '123': 'onetwothree',
  '360': 'threesixty',
  '10': 'ten_',
  '11': 'eleven_',
  '12': 'twelve_',
  '13': 'thirteen_',
  '14': 'fourteen_',
  '15': 'fifteen_',
  '16': 'sixteen_',
  '17': 'seventeen_',
  '18': 'eighteen_',
  '19': 'nineteen_',
  '20': 'twenty_',
  '21': 'twenty_one_',
  '22': 'twenty_two_',
  '23': 'twenty_three_',
  '24': 'twenty_four_',
  '30': 'thirty_',
  '60': 'sixty_',
  '2d': 'twod',
  '3d': 'threed',
  '1': 'one_',
  '2': 'two_',
  '3': 'three_',
  '4': 'four_',
  '5': 'five_',
  '6': 'six_',
  '7': 'seven_',
  '8': 'eight_',
  '9': 'nine_',
};

// Rewrite certain Flutter IDs (reserved keywords) using exact matching.
const Map<String, String> _identifierExactRewrites = <String, String>{
  'class': 'class_',
  'new': 'new_',
  'switch': 'switch_',
  'try': 'try_sms_star',
  'door_back': 'door_back_door',
  'door_front': 'door_front_door',
  'power_rounded': 'power_rounded_power',
  'error_circle_rounded': 'error_circle_rounded_error',
};

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
String pathToWriteDateMarkedIconUnicodeFiles = '${pathToWriteTTFFiles}LAST_VERSION/';

/// Path to write the dart source files to
const pathToWriteDartFiles = '../lib/';

/// Path to write example dart source files to
const pathToWriteExampleDartFiles = '../example/lib/';

/// Flag to fake the dart docs and use @nodoc flags on all the constants in the Symbols class
bool fakeDartDocsFlag = true;

/// Flag if we want to output a
bool writeUnicodeCodepoints = false;

// '@nodoc ' for NO DOCS to prevent HUGE doc files
String noDocUsage = '';

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
      'fake_dart_docs',
      abbr: 'f',
      negatable: true,
      defaultsTo: true,
      help:
          'Adds @nodocs to Symbols class constants and instead adds `fake` dart docs settings. Reduces doc size by 8gigs!',
    )
    ..addFlag(
      'downloadfonts',
      abbr: 'd',
      negatable: false,
      help:
          'The TTF font files will be downloaded to the $pathToWriteTTFFiles directory if this flag is passed.',
    )
    ..addFlag(
      'legacy_suffix_icon_names',
      abbr: 'l',
      negatable: false,
      help:
          'Add `_outlined`, `_rounded` or `_sharp` suffixes to every icon name in corresponding MaterialSymbols, MaterialSymbolsOutlined, MaterialSymbolsRounded and MaterialSymbolsSharp classes.',
    )
    ..addFlag(
      'write_unicode_codepoints',
      abbr: 'u',
      negatable: false,
      help:
          'Writes out a `$pathToWriteTTFFiles/icon_unicodes.txt` file with all icon unicodes, one per line, for use by `pyftsubset` to trim font.',
    )
    ..addFlag(
      'combined_symbols',
      abbr: 'c',
      negatable: true,
      defaultsTo: true,
      help:
          'If this flag is supplied a `symbols.dart` will be created with all 3 flavors combined into a single class.'
          'The outline version has no suffix and the `sharp` and `rounded` versions have `_sharp` and `_rounded` suffixes appended',
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
  final combinedFutureSymbolsSupportCompatible =
      results['combined_symbols'] as bool;
  final legacySuffixIconNames = results['legacy_suffix_icon_names'] as bool;
  fakeDartDocsFlag = results['fake_dart_docs'] as bool;
  writeUnicodeCodepoints = results['write_unicode_codepoints'] as bool;

  if (fakeDartDocsFlag) {
    noDocUsage = '@nodoc ';
  }

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
    final iconInfoList = fontFlavor.iconInfoList;

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
            final orginalName = parts[0];
            final codePoint = parts[1];
            var iconName = orginalName;
            if (_identifierExactRewrites.keys.contains(iconName) ||
                iconName.startsWith(RegExp(r'[0-9]'))) {
              iconName = _generateFlutterId(iconName);
              renamedIconNames.add('$orginalName => $iconName');
            }

            iconInfoList.add(IconInfo(orginalName, iconName, codePoint));
          }
        },
      );
      print(
        'Read ${iconInfoList.length} codepoints from `${fontFlavor.codepointFileUrl}`',
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
    print('Renamed icon names $renamedIconNames');
  }

  if (legacySuffixIconNames) {
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
          suffixVersion: true, suffixIconNames: legacySuffixIconNames);

      final suffixExampleSourceFilename =
          '$pathToWriteExampleDartFiles${fontFlavor.flavor}_suffix_map.dart';
      writeExampleSourceFile(
          fontFlavor, suffixExampleSourceFilename, suffixSourceFilename,
          suffixVersion: true, suffixIconNames: legacySuffixIconNames);
    }
  }

  if (combinedFutureSymbolsSupportCompatible) {
    // write all flavors together with suffixed symbol names
    const combinedSourceFilename = '${pathToWriteDartFiles}symbols.dart';
    writeCombinedSourceFile(variableFontFlavors, combinedSourceFilename,
        suffixVersion: true);

    const combinedExampleSourceFilename =
        '${pathToWriteExampleDartFiles}symbols_map.dart';
    writeCombinedExampleSourceFile(variableFontFlavors,
        combinedExampleSourceFilename, combinedSourceFilename,
        suffixVersion: true);
  }



  final unicodeMapSourceFileContent = StringBuffer('''// GENERATED FILE. DO NOT EDIT.
//
// To edit this file modify the generator file `generator/update_package.dart` and
// re-generate.
// This file was generated using the Material Symbols codepoint files
// localed at ${variableFontFlavors[0].codepointFileUrl},
// ${variableFontFlavors[1].codepointFileUrl} and
// ${variableFontFlavors[2].codepointFileUrl}.
// All three fonts were check and are guaranteed to contains the exact same code points.
// These codepoints correspond to symbols within the corresponding variable font.
// The fonts were downloaded from
// ${variableFontFlavors[0].ttfFontFileUrl},
// ${variableFontFlavors[1].ttfFontFileUrl}, and
// ${variableFontFlavors[2].ttfFontFileUrl}
// and added to this package.
// This file was generated ${DateTime.now()} by the dart file
// `generator/update_package.dart`.
//
// Copyright 2023 . All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// BEGIN GENERATED static array
/// NOTE:  The 'outlined', 'rounded' and 'sharp' versions of the Material Symbols Icon fonts all share
///   the same codepoints for each named icon.  Within the Symbols.XXXX map the 'rounded' and 'sharp'
///   versions of each icon share these SAME NAMES, but with the word '_rounded' or '_sharp' appended.
///   Only the base name is included in the following map.
Map<String, int> materialSymbolsIconNameToUnicodeMap = {
''');


  if (writeUnicodeCodepoints || combinedFutureSymbolsSupportCompatible) {
    // write all flavors together with suffixed symbol names
    const iconUnicodesFilename = '${pathToWriteTTFFiles}icon_unicodes.txt';
    final now = DateTime.now();
    String year = now.year.toString().substring(2).padLeft(2,'0');
    String month = now.month.toString().padLeft(2,'0');
    String day = now.day.toString().padLeft(2,'0');
    String dateStampedLastVersionIconUnicodesFilename = '${pathToWriteDateMarkedIconUnicodeFiles}icon_unicodes_${month}_${day}_$year.txt';
    List<String> unicodes = [];
    bool first = true;
    final unicodeBuffer = StringBuffer();

    for (final fontFlavor in variableFontFlavors) {
      final iconInfoList = fontFlavor.iconInfoList;
      for (var info in iconInfoList) {
        if (first) {
          unicodes.add(info.codePoint);
          unicodeBuffer.writeln('${info.codePoint}  # ${info.iconName}');

          unicodeMapSourceFileContent.writeln("  '${info.iconName}': 0x${info.codePoint},");   
        } else {
          if (!unicodes.contains(info.codePoint)) {
            throw ('Unicode ${info.codePoint} was missing from first fonts list and found in ${fontFlavor.flavor}');
          }
        }
      }
      first = false;
    }
    unicodeMapSourceFileContent.writeln('};');   

    const unicodeMapSourceFilename = '${pathToWriteDartFiles}iconname_to_unicode_map.dart';
    File(unicodeMapSourceFilename).writeAsStringSync(unicodeMapSourceFileContent.toString());

    File(iconUnicodesFilename).writeAsStringSync(unicodeBuffer.toString());
    File(dateStampedLastVersionIconUnicodesFilename).writeAsStringSync(unicodeBuffer.toString());
    print(
        'Wrote ${unicodes.length} icon unicode codepoints to $iconUnicodesFilename');
    print(
        'ALSO Wrote ${unicodes.length} icon unicode codepoints to $dateStampedLastVersionIconUnicodesFilename');
    print(
        'Wrote $unicodeMapSourceFilename iconname to unicode map with ${unicodes.length} iconname -> unicode codepoints.');
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

/// Write a combined version of the `Symbols` class with outlined, rounded and sharp versions of
/// each icon.  The outline version has no suffix and each rounded and sharp icon name has a
/// corresponding suffix (`_rounded` and `_sharp`).
void writeCombinedSourceFile(
    List<MaterialSymbolsVariableFont> fontinfoList, String sourceFilename,
    {bool suffixVersion = true}) {
  StringBuffer getFakeDartDocsForIconNames() {
    final fakeDartDocs = StringBuffer();

    fakeDartDocs.writeln(
        '/// NOTE: IMPORTANT - Because of the current gross inefficiencies of dart doc ALL icon member names');
    fakeDartDocs.writeln(
        '/// have to be marked with `@ nodoc` because it generates 12gigs of redundant data.  (This is caused');
    fakeDartDocs.writeln(
        '/// by dart doc including a repeated sidebar of all class members within every class members file).');
    fakeDartDocs.writeln('///');
    fakeDartDocs
        .writeln('/// The icons and corresponding symbols names follow:');
    fakeDartDocs.writeln('///');

    // all font flavors should have same number of codepoints
    int? lastCount;
    for (final fontinfo in fontinfoList) {
      if (lastCount != null) {
        assert(fontinfo.iconInfoList.length == lastCount);
      }
      lastCount = fontinfo.iconInfoList.length;
    }

    for (int i = 0; i < lastCount!; i++) {
      for (final fontinfo in fontinfoList) {
        final iconInfo = fontinfo.iconInfoList[i];
        var iconname = iconInfo.iconName;

        if (suffixVersion && fontinfo.flavor != 'outlined') {
          iconname = '${iconname}_${fontinfo.flavor}';
        }
        fakeDartDocs.writeln('///');
        fakeDartDocs.writeln(
            '/// <span class="material-symbols-${fontinfo.flavor}">${iconInfo.originalIconName}</span> Symbols.$iconname');
      }
    }
    return fakeDartDocs;
  }

  final fakeDartDocs = fakeDartDocsFlag ? getFakeDartDocsForIconNames() : '';

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

/// All three Material Symbols icon styles within [Symbols] - The outline versions have no suffix and the sharp and rounded versions of each icon
/// have the style as a suffix to the icon name.
/// The outlined style versions are accessed via `Symbols.iconname`.
/// The sharp and rounded styles are accessed via `Symbols.iconname_style`, for example `Symbols.circle_sharp` or
/// `Symbols.circle_rounded`.<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Rounded:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" /><link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Sharp:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
///
/// `import 'package:material_symbols_icons/symbols.dart';`
///
/// {@category Symbols}
library symbols;

import 'package:flutter/widgets.dart';
export 'material_symbols_icons.dart';
import 'src/icon_data.dart';
export 'src/icon_data.dart';

// ignore_for_file: constant_identifier_names
// ignore_for_file: non_constant_identifier_names

/// Access icons using `Symbols.iconname` for the outlined version, or `Symbols.iconname_style` for the rounded and sharp versions of
/// each icon (with _style appended to the identifiers).
///
/// This is intended to be compatible with the future Flutter implementation as defined in [here](https://docs.google.com/document/d/1UHRKDl8-lzl_hW_K2AHnpMwvdPo0vGPbDI7mqACWXJY/edit).
/// Once flutter natively supports the Material Symbols icons all that should be needed is removal of the import statement for this package.
///
/// Explore available icons at [Google Font's Material Symbols Explorer](https://fonts.google.com/icons?selected=Material+Symbols).
/// <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Rounded:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" /><link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Sharp:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" /><style>span.material-symbols-outlined, span.material-symbols-rounded, span.material-symbols-sharp { font-size:48px; color: teal; }</style>
///
/// All icons share the same name they had in the Material Icons [Icons] class.
/// All icon names that start with a number (like '360' or '9mp') but have their icon name changed so that the number is written out and may have
/// added '_' separating numbers.  For example '3d_rotation' becomes 'threed_rotation', '123' becomes 'onetwothree', '360' becomes 'threesixty',
/// '9mp' becomes 'nine_mp', '10' becomes 'ten_', '2d' becomes 'twod', '3d' becomes 'threed'.
/// This is done to generate valid dart class member names.
/// For example if you want to access the icon with the name '360' you use `Symbols.threesixty` instead.
///
/// Additionally the iconnames 'class', 'switch', and 'try' have also been renamed with a trailing '_' ('class_', 'switch_' and 'try_') as these are dart language
/// reserved words.  'door_back' and 'door_front' have also been renamed 'door_back_door' and 'door_front_door' respectively.
/// 'power_rounded' becomes 'power_rounded_power' (and therefor 'power_rounded_power_rounded' for the rounded version and
/// 'power_rounded_power_sharp' for the sharp version.
/// (likewise 'error_circle_rounded' becomes 'error_circle_rounded_error').
///
/// Use with the [Icon] class to show specific icons. Icons are identified by
/// their name FOLLOWED by the desired style as a suffix, as listed below, e.g. [Symbols.airplanemode_active_rounded].
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
///       Symbols.pedal_bike,
///       color: Colors.pink,
///       size: 24.0,
///       semanticLabel: 'Text to announce in accessibility modes',
///     ),
///     Icon(
///       Symbols.sunny_rounded,
///       color: Colors.green,
///       size: 30.0,
///     ),
///     Icon(
///       Symbols.beach_access_sharp,
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
$fakeDartDocs
@staticIconProvider
class Symbols {
  // This class is not meant to be instantiated or extended; this constructor
  // prevents instantiation and extension.
  Symbols._();

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

  // BEGIN GENERATED ICONS
''');

  // all font flavors should have same number of codepoints
  int? lastCount;
  for (final fontinfo in fontinfoList) {
    if (lastCount != null) {
      assert(fontinfo.iconInfoList.length == lastCount);
    }
    lastCount = fontinfo.iconInfoList.length;

/*OBSOLETE
    // write constant names
    sourceFileContent.writeln(
        "  static const _family_${fontinfo.flavor} = '${fontinfo.familyNameToUse}';");
OBSOLETE*/

  }

/*OBSOLETE
  sourceFileContent
      .writeln("  static const _package = 'material_symbols_icons';");
OBSOLETE*/

  var iconCount = 0;

  for (int i = 0; i < lastCount!; i++) {
    for (final fontinfo in fontinfoList) {
      final iconInfo = fontinfo.iconInfoList[i];
      var iconname = iconInfo.iconName;
      final codepoint = iconInfo.codePoint;
      final iconDataClass = fontinfo.iconDataClass;

      if (suffixVersion && fontinfo.flavor != 'outlined') {
        iconname = '${iconname}_${fontinfo.flavor}';
      }
      sourceFileContent.writeln();
      sourceFileContent.writeln(
          //ALL OUTLINE  '  /// <span class="material-symbols-outlined">$iconnameNoLeadingPrefix</span> material symbol named "$iconname".');
          '  /// $noDocUsage<span class="material-symbols-${fontinfo.flavor}">${iconInfo.originalIconName}</span> material symbol named "$iconname".');
      String proposedSingleLine = "  static const IconData $iconname = $iconDataClass(0x$codepoint);";
      if(proposedSingleLine.length>80) {
        //split to two lines
        sourceFileContent.writeln("  static const IconData $iconname =");
        sourceFileContent.writeln("      $iconDataClass(0x$codepoint);");
      } else {
        // one line
        sourceFileContent.writeln(proposedSingleLine);
      }
      iconCount++;
    }
  }
  sourceFileContent.writeln('  // END GENERATED ICONS');
  sourceFileContent.writeln('}');

  File(sourceFilename).writeAsStringSync(sourceFileContent.toString());

  print('Wrote $iconCount COMBINED icons to $sourceFilename');
}

/// Write a combined version of the `Symbols` class with outlined, rounded and sharp versions of
/// each icon.  The outlined version has no suffix and each rounded and sharp icon name has a
/// corresponding suffix (`_rounded` and `_sharp`).
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
Map<String, IconData> materialSymbolsMap = {
''');

  // all font flavors should have same number of codepoints
  int? lastCount;
  for (final fontinfo in fontinfoList) {
    if (lastCount != null) {
      assert(fontinfo.iconInfoList.length == lastCount);
    }
    lastCount = fontinfo.iconInfoList.length;
  }

  var iconCount = 0;

  for (int i = 0; i < lastCount!; i++) {
    for (final fontinfo in fontinfoList) {
      var iconInfo = fontinfo.iconInfoList[i];
      var iconname = iconInfo.iconName;

      if (suffixVersion && fontinfo.flavor != 'outlined') {
        iconname = '${iconname}_${fontinfo.flavor}';
      }
      final lineStr = "  '$iconname': Symbols.$iconname,";
      if (lineStr.length <= 80) {
        sourceFileContent.writeln(lineStr);
      } else {
        // SPLIT THE LINE
        sourceFileContent.writeln("  '$iconname':");
        sourceFileContent.writeln("      Symbols.$iconname,");
      }
      iconCount++;
    }
  }
  sourceFileContent.writeln('};');
  sourceFileContent.writeln('// END GENERATED ICONS');

  File(exampleSourceFilename).writeAsStringSync(sourceFileContent.toString());

  print('Wrote $iconCount COMBINED icons to $exampleSourceFilename');
}

/// This mimics the flutter icon renaming in flutter engine \dev\tools\update_icons.dart
/// and it essentially copied from there, but needlessly a little faster
String _generateFlutterId(String id) {
  String flutterId = id;
  bool fixApplied = false;
  // Exact identifier rewrites.
  for (final MapEntry<String, String> rewritePair
      in _identifierExactRewrites.entries) {
    if (id == rewritePair.key) {
      flutterId = id.replaceFirst(
        rewritePair.key,
        _identifierExactRewrites[rewritePair.key]!,
      );
      fixApplied = true;
      break; // done we got exact match and replaced
    }
  }
  // Prefix identifier rewrites. [_identifierPrefixRewrites] is sorted longest to shortest, so once we find a prefix match
  // we can break.
  if (!fixApplied) {
    for (final MapEntry<String, String> rewritePair
        in _identifierPrefixRewrites.entries) {
      if (id.startsWith(rewritePair.key)) {
        flutterId = id.replaceFirst(
          rewritePair.key,
          _identifierPrefixRewrites[rewritePair.key]!,
        );
        fixApplied = true;
        break; // done we got the longest prefix match we will encounter
      }
    }
  }

  if (!fixApplied) {
    throw ('Iconname $id which needed a fix applied but none were found.');
  }

  // Prevent double underscores.
  flutterId = flutterId.replaceAll('__', '_');

  return flutterId;
}

/*
 * 
 * OBSOLETE CODE follows - this is no longer used when generating this class and is included only for legacy reasons
 * 
 */

void writeSourceFile(
    MaterialSymbolsVariableFont fontinfo,
    List<MaterialSymbolsVariableFont> allFlavorFontInfoList,
    String sourceFilename,
    {bool suffixVersion = false,
    bool suffixIconNames = false}) {
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

    fakeDartDocs.writeln(
        '/// NOTE: IMPORTANT - Because of the current gross inefficiencies of dart doc ALL icon member names');
    fakeDartDocs.writeln(
        '/// have to be marked with `@ nodoc` because it generates 12gigs of redundant data.  (This is caused');
    fakeDartDocs.writeln(
        '/// by dart doc including a repeated sidebar of all class members within every class members file).');
    fakeDartDocs.writeln('///');
    fakeDartDocs
        .writeln('/// The icons and corresponding symbols names follow:');
    fakeDartDocs.writeln('///');

    final iconInfoList = fontinfo.iconInfoList;
    for (int i = 0; i < iconInfoList.length; i++) {
      var iconInfo = iconInfoList[i];
      var iconname = iconInfo.iconName;

      if (suffixIconNames) {
        iconname = '${iconname}_${fontinfo.flavor}';
      }
      fakeDartDocs.writeln('///');
      fakeDartDocs.writeln(
          '/// <span class="material-symbols-${fontinfo.flavor}">${iconInfo.originalIconName}</span> MaterialSymbols$classFlavor.$iconname');
    }
    return fakeDartDocs;
  }

  final fakeDartDocs = fakeDartDocsFlag ? getFakeDartDocsForIconNames() : '';

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
/// 
/// All icons share the same name they had in the Material Icons [Icons] class.
/// All icon names that start with a number (like '360' or '9mp') but have their icon name changed so that the number is written out and may have
/// added '_' separating numbers.  For example '3d_rotation' becomes 'threed_rotation', '123' becomes 'onetwothree', '360' becomes 'threesixty',
/// '9mp' becomes 'nine_mp', '10' becomes 'ten_', '2d' becomes 'twod', '3d' becomes 'threed'. 
/// This is done to generate valid dart class member names.
/// For example if you want to access the icon with the name '360' you use `MaterialSymbols$classFlavor.threesixty` instead.
///
/// Additionally the iconnames 'class', 'switch', and 'try' have also been renamed with a trailing '_' ('class_', 'switch_' and 'try_') as these are dart language
/// reserved words.  'door_back' and 'door_front' have also been renamed 'door_back_door' and 'door_front_door' respectively.
/// 
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
$fakeDartDocs//pub.dev does not like @staticIconProvider but this is how web icon font tree shaking works in mater channel //@staticIconProvider
class MaterialSymbols$classFlavor extends MaterialSymbolsBase {
  // This class is not meant to be instantiated or extended; this constructor
  // prevents instantiation and extension.
  MaterialSymbols$classFlavor._();

  // BEGIN GENERATED ICONS
  static const _family = '${fontinfo.familyNameToUse}';
  static const _package = 'material_symbols_icons';
''');

  var iconCount = 0;
  final iconInfoList = fontinfo.iconInfoList;
  for (int i = 0; i < iconInfoList.length; i++) {
    final iconInfo = iconInfoList[i];
    var iconname = iconInfo.iconName;
    final codepoint = iconInfo.codePoint;

    if (suffixIconNames) {
      iconname = '${iconname}_${fontinfo.flavor}';
    }
    sourceFileContent.writeln();
    sourceFileContent.writeln(
        //ALL OUTLINE'  /// <span class="material-symbols-outlined">$iconnameNoLeadingPrefix</span> material symbol named "$iconname".');
        '  /// $noDocUsage<span class="material-symbols-${fontinfo.flavor}">${iconInfo.originalIconName}</span> material symbol named "$iconname".');
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

void writeExampleSourceFile(MaterialSymbolsVariableFont fontinfo,
    String exampleSourceFilename, String sourceFilename,
    {bool suffixVersion = false, bool suffixIconNames = false}) {
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
  final iconInfoList = fontinfo.iconInfoList;
  for (int i = 0; i < iconInfoList.length; i++) {
    final iconInfo = iconInfoList[i];
    var iconname = iconInfo.iconName;

    if (suffixIconNames) {
      iconname = '${iconname}_${fontinfo.flavor}';
    }
    final testStr = "  '$iconname': MaterialSymbols$classFlavor.$iconname,";
    if (testStr.length <= 80) {
      sourceFileContent.writeln(testStr);
    } else {
      // SPLIT THE LINE
      sourceFileContent.writeln("  '$iconname':");
      sourceFileContent.writeln("      MaterialSymbols$classFlavor.$iconname,");
    }
    iconCount++;
  }

  sourceFileContent.writeln('};');
  sourceFileContent.writeln('// END GENERATED ICONS');

  File(exampleSourceFilename).writeAsStringSync(sourceFileContent.toString());

  print('Wrote $iconCount icons to $exampleSourceFilename');
}
