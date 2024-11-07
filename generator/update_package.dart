// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
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

/// Flag to include inline SVG previews of the icons in dart docs comments as markup
bool svgDartDocsFlag = false;

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
  final String woff2FontUrlForDartDocSVG;
  final String svgFontFamily;
  late final String filename;
  final List<IconInfo> iconInfoList = [];

  MaterialSymbolsVariableFont(
      this.flavor,
      this.iconDataClass,
      this.familyNameToUse,
      this.codepointFileUrl,
      this.ttfFontFileUrl,
      this.woff2FontUrlForDartDocSVG,
      this.svgFontFamily) {
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
    'https://github.com/google/material-design-icons/raw/master/variablefont/MaterialSymbolsOutlined%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf',
    fixupStringForDataURIThatVSCodeWillAccept(
        "url(https://fonts.gstatic.com/s/materialsymbolsoutlined/v190/kJEhBvYX7BgnkSrUwT8OhrdQw4oELdPIeeII9v6oFsI.woff2) format('woff2')"),
    fixupStringForDataURIThatVSCodeWillAccept('Material Symbols Outlined'),
  ),
  MaterialSymbolsVariableFont(
    'rounded',
    'IconDataRounded',
    'MaterialSymbolsRounded',
    'https://github.com/google/material-design-icons/raw/master/variablefont/MaterialSymbolsRounded%5BFILL%2CGRAD%2Copsz%2Cwght%5D.codepoints',
    'https://github.com/google/material-design-icons/raw/master/variablefont/MaterialSymbolsRounded%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf',
    fixupStringForDataURIThatVSCodeWillAccept(
        "url(https://fonts.gstatic.com/s/materialsymbolsrounded/v188/sykg-zNym6YjUruM-QrEh7-nyTnjDwKNJ_190Fjzag.woff2) format('woff2')"),
    fixupStringForDataURIThatVSCodeWillAccept('Material Symbols Rounded'),
  ),
  MaterialSymbolsVariableFont(
    'sharp',
    'IconDataSharp',
    'MaterialSymbolsSharp',
    'https://github.com/google/material-design-icons/raw/master/variablefont/MaterialSymbolsSharp%5BFILL%2CGRAD%2Copsz%2Cwght%5D.codepoints',
    'https://github.com/google/material-design-icons/raw/master/variablefont/MaterialSymbolsSharp%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf',
    fixupStringForDataURIThatVSCodeWillAccept(
        "url(https://fonts.gstatic.com/s/materialsymbolssharp/v186/gNMVW2J8Roq16WD5tFNRaeLQk6-SHQ_R00k4aWE.woff2) format('woff2')"),
    fixupStringForDataURIThatVSCodeWillAccept('Material Symbols Sharp'),
  ),
];

String fixupStringForDataURIThatVSCodeWillAccept(String unencoded) {
  return unencoded
      .replaceAll('"', "'")
      .replaceAll(' ', '%20')
      .replaceAll('<', '%3C')
      .replaceAll('>', '%3E')
      .replaceAll('(', '%28')
      .replaceAll(')', '%29');
}

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
  //NO IT IS DUPPED WITH SAME codepoint 'expension_panels': 'expansion_panels',  // SPELLING ERROR
};

Map<String, String> renamedSymbolsToAugmentMap = {};

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
String pathToWriteDateMarkedIconUnicodeFiles =
    '${pathToWriteTTFFiles}LAST_VERSION/';

/// Path to write the dart source files to
const pathToWriteDartFiles = '../lib/';

/// Flag if we want to output a
bool writeUnicodeCodepoints = true;

/// Here is template to create INLINE svg images of the icons using SVG file and google fonts links to fonts
/// $1 is fontfamily, $2 is the font src url, $3 is the codepoint
//const svgIconTemplateRaw = r'''data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32"><defs><style type="text/css">@font-face { font-family: "$1"; src: $2; font-weight:400;} text {font-family:"$1"; font-size: 32px; text-anchor: middle; dominant-baseline: text-bottom; fill: grey;}</style></defs><text xmlns="http://www.w3.org/2000/svg" x="50%" y="100%">&%23x$3;</text></svg>''';
const svgIconTemplateRaw =
    r'''data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32"><defs><style type="text/css">@font-face { font-family: "$1"; src: $2;} text {font-family:"$1"; font-size: 32px; text-anchor: middle; dominant-baseline: text-bottom; fill: grey;}</style></defs><text xmlns="http://www.w3.org/2000/svg" x="50%" y="100%">&%23x$3;</text></svg>''';
String? svgIconTemplate;

String getSVGDateUriFor(
    MaterialSymbolsVariableFont fontinfo, String codepoint) {
  // This replaces the characters double quote " (to single '), and < and > with %3C and %3E
  // This is the only way to encode the SVG that I found worked in vscode.
  // Neither base64 or encodeURIComponent() encoding worked.
  svgIconTemplate ??= svgIconTemplateRaw
      .replaceAll('"', "'")
      .replaceAll(' ', '%20')
      .replaceAll('<', '%3C')
      .replaceAll('>', '%3E')
      .replaceAll('(', '%28')
      .replaceAll(')', '%29');

  String dataUri = svgIconTemplate!
      .replaceAll(r'$1', fontinfo.svgFontFamily)
      .replaceFirst(r'$2', fontinfo.woff2FontUrlForDartDocSVG)
      .replaceFirst(r'$3', codepoint);

  return dataUri;
}

/// <span style="font-family: 'Material Symbols Outlined';color: red;font-size:32px;">&#xe53d;&#xf4af;&#xF4AF;</span>
Future<void> downloadURLASBinaryFile(
    HttpClient client, String url, String filename) async {
  final request = await client.getUrl(Uri.parse(url));
  final response = await request.close();
  if (response.statusCode == HttpStatus.ok) {
    if (verboseFlag) {
      print('Received OK response for URL $url - copying to $filename');
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
      'svg_icon_in_dart_docs',
      abbr: 's',
      defaultsTo: false,
      negatable: true,
      help: 'Include inline SVG icon in dart docs markup.',
    )
    ..addFlag(
      'downloadfonts',
      abbr: 'd',
      negatable: false,
      help:
          'The TTF font files will be downloaded to the $pathToWriteTTFFiles directory if this flag is passed.',
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
  svgDartDocsFlag = results['svg_icon_in_dart_docs'] as bool;
  verboseFlag = results['verbose'] as bool;

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
            final originalName = parts[0];
            final codePoint = parts[1];
            var iconName = originalName;
            if (_identifierExactRewrites.keys.contains(iconName) ||
                iconName.startsWith(RegExp(r'[0-9]'))) {
              iconName = _generateFlutterId(iconName);
              renamedIconNames.add('$originalName => $iconName');
              // Keep track of the renamed symbols so we can augment the symbols name map with the original names
              renamedSymbolsToAugmentMap[originalName] = iconName;
            }

            iconInfoList.add(IconInfo(originalName, iconName, codePoint));
          }
        },
      );
      print(
        'Read ${iconInfoList.length} codepoints from `${fontFlavor.codepointFileUrl}`',
      );
    }
    // Now Grab the latest font file
    String filenameWithPath = '$pathToWriteTTFFiles${fontFlavor.filename}';
    if (downloadFontsFlag) {
      print(
          'Downloading ${fontFlavor.ttfFontFileUrl} to local file `$filenameWithPath}`');
      await downloadURLASBinaryFile(
          client, fontFlavor.ttfFontFileUrl, filenameWithPath);
    } else {
      print('SKIPPED downloading font from ${fontFlavor.ttfFontFileUrl}');
    }
  }

  if (verboseFlag) {
    print('Renamed icon names $renamedIconNames');
  }

  // write all flavors together with suffixed symbol names
  const combinedSourceFilename = '${pathToWriteDartFiles}symbols.dart';
  writeCombinedSourceFile(variableFontFlavors, combinedSourceFilename,
      suffixVersion: true);

  // write map file of all icon names to IconData objects - used by example
  // program (or any other program) which needs to include EVERY icon in the
  // build output program.
  const combinedFullMapSourceFilename =
      '${pathToWriteDartFiles}symbols_map.dart';
  writeCombinedFullSymbolsMapSourceFile(variableFontFlavors,
      combinedFullMapSourceFilename, combinedSourceFilename,
      suffixVersion: true);

  final unicodeMapSourceFileContent =
      StringBuffer('''// GENERATED FILE. DO NOT EDIT.
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
// Copyright 2024. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// BEGIN GENERATED static array
/// NOTE:  The 'outlined', 'rounded' and 'sharp' versions of the Material Symbols Icon fonts all share
///   the same codepoints for each named icon.  Within the Symbols.XXXX map the 'rounded' and 'sharp'
///   versions of each icon share these SAME NAMES, but with the word '_rounded' or '_sharp' appended.
///   versions of each icon share these SAME NAMES, but with the word '_rounded' or '_sharp' appended.
///   Only the base name is included in the following map.
Map<String, int> materialSymbolsIconNameToUnicodeMap = {
''');

  // write all flavors together with suffixed symbol names
  const iconUnicodesFilename = '${pathToWriteTTFFiles}icon_unicodes.txt';
  final now = DateTime.now();
  String year = now.year.toString().substring(2).padLeft(2, '0');
  String month = now.month.toString().padLeft(2, '0');
  String day = now.day.toString().padLeft(2, '0');
  String dateStampedLastVersionIconUnicodesFilename =
      '${pathToWriteDateMarkedIconUnicodeFiles}icon_unicodes_${year}_${month}_${day}.txt';
  List<String> unicodes = [];
  bool first = true;
  final unicodeBuffer = StringBuffer();
  int numberOfRenamedIconsFound = 0;

  for (final fontFlavor in variableFontFlavors) {
    final iconInfoList = fontFlavor.iconInfoList;
    for (var info in iconInfoList) {
      if (first) {
        unicodes.add(info.codePoint);
        unicodeBuffer.writeln('${info.codePoint}  # ${info.iconName}');

        unicodeMapSourceFileContent
            .writeln("  '${info.iconName}': 0x${info.codePoint},");
        // Check for renamed icons and add the original name to the map also
        if (info.originalIconName != info.iconName) {
          unicodeMapSourceFileContent
              .writeln("  '${info.originalIconName}': 0x${info.codePoint},");
          numberOfRenamedIconsFound++;
        }
      } else {
        if (!unicodes.contains(info.codePoint)) {
          throw ('Unicode ${info.codePoint} was missing from first fonts list and found in ${fontFlavor.flavor}');
        }
      }
    }
    first = false;
  }
  unicodeMapSourceFileContent.writeln('};');

  const unicodeMapSourceFilename =
      '${pathToWriteDartFiles}iconname_to_unicode_map.dart';
  File(unicodeMapSourceFilename)
      .writeAsStringSync(unicodeMapSourceFileContent.toString());

  File(iconUnicodesFilename).writeAsStringSync(unicodeBuffer.toString());
  File(dateStampedLastVersionIconUnicodesFilename)
      .writeAsStringSync(unicodeBuffer.toString());
  print(
      'Wrote ${unicodes.length} icon unicode codepoints to $iconUnicodesFilename');
  print(
      'ALSO Wrote ${unicodes.length} icon unicode codepoints to $dateStampedLastVersionIconUnicodesFilename');
  print(
      'Wrote $unicodeMapSourceFilename iconname to unicode map with ${unicodes.length} iconname -> unicode codepoints.');
  print(
      'Augmented unicode map with $numberOfRenamedIconsFound entries containing original names (for icons that had to be renamed)');

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
/*OBSOLETE - dart doc is FIXED!!!!
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
OBSOLETE */
  //OBSOLETEfinal fakeDartDocs = fakeDartDocsFlag ? getFakeDartDocsForIconNames() : '';

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
// Copyright 2024. All rights reserved.
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
  }

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
      if (svgDartDocsFlag) {
        final svgDataUUri = getSVGDateUriFor(fontinfo, codepoint);
        sourceFileContent.writeln(
            '  /// \![$iconname]($svgDataUUri|width=32,height=32)  material symbols icon named "$iconname" (${fontinfo.flavor} variation).');
      } else {
        sourceFileContent.writeln(
            '  /// <span class="material-symbols-${fontinfo.flavor}" data-variation="${fontinfo.flavor}" data-fontfamily="${fontinfo.familyNameToUse}" data-codepoint="$codepoint">${iconInfo.originalIconName}</span> material symbols icon named "$iconname" (${fontinfo.flavor} variation).');
      }
      String proposedSingleLine =
          "  static const IconData $iconname = $iconDataClass(0x$codepoint);";
      if (proposedSingleLine.length > 80) {
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
void writeCombinedFullSymbolsMapSourceFile(
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
// Copyright 2024. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/$sourceFilename';

// ignore_for_file: constant_identifier_names
// ignore_for_file: non_constant_identifier_names

// WARNING! Including this file in your project will FORCE a reference to every
// material symbols icon and PREVENT ALL TREE SHAKING of the material icons symbols fonts.

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
  var renamedMapEntries = 0;

  for (int i = 0; i < lastCount!; i++) {
    for (final fontinfo in fontinfoList) {
      var iconInfo = fontinfo.iconInfoList[i];
      var iconname = iconInfo.iconName;
      var originalMaterialName = iconInfo.originalIconName;
      bool iconWasRenamed = false;
      if (iconname != originalMaterialName) {
        iconWasRenamed = true;
      }
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
      if (iconWasRenamed) {
        // WE NEED TO WRITE THE ORIGINAL NAME info the map also...
        if (suffixVersion && fontinfo.flavor != 'outlined') {
          originalMaterialName = '${originalMaterialName}_${fontinfo.flavor}';
        }
        final lineStr = "  '$originalMaterialName': Symbols.$iconname,";
        if (lineStr.length <= 80) {
          sourceFileContent.writeln(lineStr);
        } else {
          // SPLIT THE LINE
          sourceFileContent.writeln("  '$originalMaterialName':");
          sourceFileContent.writeln("      Symbols.$iconname,");
        }
        renamedMapEntries++;
      }
    }
  }
  sourceFileContent.writeln('};');
  sourceFileContent.writeln('// END GENERATED ICONS');

  File(exampleSourceFilename).writeAsStringSync(sourceFileContent.toString());

  print('Wrote $iconCount COMBINED icons to $exampleSourceFilename');
  print(
      'Augmented map with entries for $renamedMapEntries icons that were renamed from the original material names (which could not be used because they were invalid Dart symbol names).');
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
