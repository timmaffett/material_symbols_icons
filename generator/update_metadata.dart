import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:chalkdart/chalkstrings.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
//import 'package:archive/archive.dart'; // For zip file handling
//import 'package:woff2/woff2.dart' as woff2; //dart doesn't have woff2 package.

// IMPORT our update_package.dart so we can get all of the icon renaming information
import 'icon_metadata.dart';
import 'update_package.dart'
    show
        identifierPrefixRewrites,
        identifierExactRewrites,
        identifierExcludeNames;

const DEBUG = false;
const writeFetchedFilesToDisk =
    false; // WE DO NOT WRITE the XML files to disk - we just get the autoMirrored info from them.

// Define constants for URLs and headers.
const String MATERIAL_SYMBOLS_METADATA_DOWNLOAD_URL =
    "http://fonts.google.com/metadata/icons?incomplete=1&key=material_symbols";
const Map<String, String> _HEADERS = {
  'User-Agent':
      'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36',
};

typedef Asset = ({String srcUrlPattern, String destDirPattern});
typedef Fetch = ({String iconName, String srcUrl, String destFile});

Map<String, String> renamedIconNames = {};
Set<String> autoMirroredIconNames = Set<String>();
Set<String> fromExistingJsonMetaData_AutoMirroredIconNames = Set<String>();

// Define asset lists.
List<Asset> _ICON_ASSETS = [
  //NO SVGS//(
  //NO SVGS//  srcUrlPattern:
  //NO SVGS//      "https://{host}/s/i/short-term/release/{stylisticSetSnake}/{iconName}/{style}/{sizePx}px.svg",
  //NO SVGS//  destDirPattern:
  //NO SVGS//      "symbols/web/{iconName}/{stylisticSetSnake}/{iconName}{styleSuffix}_{sizePx}px.svg",
  //NO SVGS//),
  (
    srcUrlPattern:
        "https://{host}/s/i/short-term/release/{stylisticSetSnake}/{iconName}/{style}/{sizePx}px.xml",
    destDirPattern:
        //"symbols/android/{iconName}/{stylisticSetSnake}/{iconName}{styleSuffix}_{sizePx}px.xml",
        Platform.isWindows ? "icons\\{iconName}.xml" : "icons/{iconName}.xml",
  ),
  // Removed the extra entry.  It was a duplicate of the first _ICON_ASSETS entry
];

const List<Asset> _ICON_IOS_ASSETS = [
  (
    srcUrlPattern:
        "https://{host}/s/i/short-term/release/{stylisticSetSnake}/{iconName}/{style}/{iconName}{styleSuffix}_symbol.svg",
    destDirPattern:
        "symbols/ios/{iconName}/{stylisticSetSnake}/{iconName}{styleSuffix}_symbol.svg",
  ),
];

const List<Asset> _SET_ASSETS = [
  (
    srcUrlPattern:
        "https://fonts.googleapis.com/css2?family={stylisticSetUrl}:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200",
    destDirPattern: "variablefont/{stylisticSetFont}.css",
  ),
];

// Define the format extension method for String
extension StringFormat on String {
  String format({Map<String, String>? namedArguments}) {
    var result = this;
    namedArguments?.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }
}

//Helper Functions

List<String> convertToStringList(List<dynamic>? list) {
  if (list == null) {
    return [];
  }
  List<String> result = [];
  for (var element in list) {
    if (element is String) {
      result.add(element);
    } else if (element == null) {
      //result.add("null");
    } else {
      result.add(element.toString());
    }
  }
  return result;
}

// Version of our file from update_package.dart
String _generateFlutterId(String iconName) {
  String flutterIconName = iconName;
  bool fixApplied = false;
  if (identifierExcludeNames.contains(iconName)) {
    throw ('_generateFlutterId() encounted "$iconName" which is an excluded icon name and should have been pruned from lists.');
  }

  // Exact identifier rewrites.
  for (final MapEntry<String, String> rewritePair
      in identifierExactRewrites.entries) {
    if (iconName == rewritePair.key) {
      flutterIconName = iconName.replaceFirst(
        rewritePair.key,
        identifierExactRewrites[rewritePair.key]!,
      );
      fixApplied = true;
      break; // done we got exact match and replaced
    }
  }
  // Prefix identifier rewrites. [_identifierPrefixRewrites] is sorted longest to shortest, so once we find a prefix match
  // we can break.
  if (!fixApplied) {
    for (final MapEntry<String, String> rewritePair
        in identifierPrefixRewrites.entries) {
      if (iconName.startsWith(rewritePair.key)) {
        flutterIconName = iconName.replaceFirst(
          rewritePair.key,
          identifierPrefixRewrites[rewritePair.key]!,
        );
        fixApplied = true;
        break; // done we got the longest prefix match we will encounter
      }
    }
  }

  if (!fixApplied) {
    throw ('Iconname $iconName which needed a fix applied but none were found.');
  }

  // Prevent double underscores.
  flutterIconName = flutterIconName.replaceAll('__', '_');

  return flutterIconName;
}

String possiblyRenameThisIcon(String iconName) {
  String? renamedIconName;
  if (!identifierExcludeNames.contains(iconName)) {
    if (identifierExactRewrites.keys.contains(iconName) ||
        iconName.startsWith(RegExp(r'[0-9]'))) {
      renamedIconName = _generateFlutterId(iconName);
    }
  }
  return renamedIconName ?? iconName;
}

/// Fetches the latest metadata from the Google Fonts API.
Future<Map<String, dynamic>> _latestMetadata() async {
  final response =
      await http.get(Uri.parse(MATERIAL_SYMBOLS_METADATA_DOWNLOAD_URL));
  if (response.statusCode != 200) {
    throw Exception(
        'Failed to fetch metadata: ${response.statusCode}'); // More specific error
  }
  final rawJson = response.body.substring(5);
  return json.decode(rawJson);
}

/// Returns the path to the current versions file.
File _currentVersionsFile() {
  //Simulate Pathlib
  //OLDWAY//return File(path.join(Directory.current.path, 'current_versions.json'));
  return File(path.join(
      Directory.current.path, 'last_metadata', 'current_versions.json'));
}

/// Returns the path to the icons file.
File _iconsMetadataFile() {
  return File(path.join(
      Directory.current.path, 'last_metadata', 'icons_metadata.json'));
}

/// Generates a version key for an icon.
String _versionKey(IconMetadata icon) => "symbols::${icon.name}";

/// Extracts the symbol families from the metadata.
Set<String> _symbolFamilies(Map<String, dynamic> metadata) {
  final families = Set<String>.from(metadata["families"]);
  return families.where((s) => s.contains("Symbols")).toSet();
}

/// Extracts icon information from the metadata.
Iterable<IconMetadata> _icons(Map<String, dynamic> metadata) sync* {
  final allSets = _symbolFamilies(metadata);
  for (final rawIcon in metadata["icons"]) {
    final unsupported =
        Set<String>.from(rawIcon["unsupported_families"]); // Ensure it's a Set

    String iconName = rawIcon["name"];
    String renamedIconName = "";
    if (!identifierExcludeNames.contains(iconName)) {
      if (identifierExactRewrites.keys.contains(iconName) ||
          iconName.startsWith(RegExp(r'[0-9]'))) {
        renamedIconName = _generateFlutterId(iconName);
        // Keep track of the renamed symbols so we can augment the symbols name map with the original names
        renamedIconNames[iconName] = renamedIconName;
      }
    }

    yield IconMetadata(
      name: iconName,
      renamedIconName: renamedIconName,
      version: rawIcon["version"],
      stylisticSets: allSets.difference(unsupported),
      popularity: rawIcon["popularity"],
      codepoint: rawIcon["codepoint"],
      categories: convertToStringList(rawIcon["categories"]),
      tags: convertToStringList(rawIcon["tags"]),
    );
  }
}

/// Creates a Fetch object from an asset and arguments.
Fetch _createFetch(Asset asset, Map<String, String> args) {
  final srcUrl = asset.srcUrlPattern.format(namedArguments: args);
  //Simulate Pathlib
  final destFile = File(path.join(
      Directory.current.path,
      "last_metadata", // DO NOT GO UP "../..",
      asset.destDirPattern.format(namedArguments: args)));
  return (iconName: args["iconName"]!, srcUrl: srcUrl, destFile: destFile.path);
}

/// Searches a Uint8List for the presence of a regular expression.
///
/// Converts the Uint8List to a string using utf-8 encoding, and then
/// searches the string for the given regular expression.  The regular
/// expression is modified to be tolerant of whitespace around the '='
/// sign in the 'android:autoMirrored="true"' pattern.
///
/// Returns:
///   True if the regular expression is found, false otherwise.  Returns
///   false if the Uint8List is null.
// Define the regular expression for 'autoMirrored="true"'
final autoMirroredTrueRegex = RegExp(r'android:autoMirrored\s*=\s*"true"');

///
bool containsAutoMirrored(Uint8List data) {
  try {
    // Convert the Uint8List to a string using utf-8 encoding.
    final content = utf8.decode(data);

    // Search for the regular expression in the string.
    return autoMirroredTrueRegex.hasMatch(content);
  } catch (e) {
    // Handle any exceptions that might occur during decoding or regex matching.
    print('Error during search: $e');
    return false; // Return false on error.
  }
}

/// Performs a single fetch operation.
Future<void> _doFetch(String iconName, String srcUrl, String destFile) async {
  try {
    final response = await http.get(Uri.parse(srcUrl), headers: _HEADERS);
    //NOT DART//response.raiseForStatus(); // Improved error handling

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch $srcUrl: ${response.statusCode}');
    }

    if (DEBUG) {
      if(writeFetchedFilesToDisk) {
        print('Fetching $srcUrl and going to write to $destFile');
      } else {
        print('Fetching $srcUrl but not writing to disk');
      }
    }

    bool rtlAutoMirrored = containsAutoMirrored(response.bodyBytes);
    if (rtlAutoMirrored) {
      print('RTL auto-mirroring detected for `${iconName.yellow}`'.brightCyan);
      autoMirroredIconNames.add(iconName);
    } else {
      if (DEBUG) print('No RTL auto-mirroring detected for $srcUrl');
    }

    if (writeFetchedFilesToDisk) {
      final file = File(destFile);
      await file.parent
          .create(recursive: true); // Dart's equivalent of `parents=True`
      await file.writeAsBytes(response.bodyBytes);
    }
  } catch (e) {
    print('Error fetching $srcUrl to $destFile: $e'); // Include URL in error
  }
}

/// Performs multiple fetch operations.
Future<void> _doFetches(List<Fetch> fetches) async {
  print('Starting ${fetches.length} fetches');
  final total = fetches.length;
  var completed = 0;

  // Use a simple loop for sequential fetching in Dart (Parallel is more complex)
  for (final fetch in fetches) {
    await _doFetch(fetch.iconName, fetch.srcUrl, fetch.destFile);
    completed++;
    if (completed % 10 == 0 || completed == total) {
      // update progress every 10 fetches or at the end.
      print('$completed/$total complete');
    }
  }
  print('$total/$total complete');
}

/* NO FONT STUFF AT ALL

/// Decompresses a WOFF2 file (if woff2 package was available).
void decompressWoff2(String inputPath, String outputPath) {
  final inputFile = File(inputPath);
  final outputFile = File(outputPath);
  if (!inputFile.existsSync()) {
    print("Input file does not exist");
    return;
  }

  final inputBytes = inputFile.readAsBytesSync();
  // final decompressedBytes = woff2.decode(inputBytes); // Removed woff2
  // outputFile.writeAsBytesSync(decompressedBytes);
  print('Decompression of woff2 is not supported in this version.');
}

/// Fetches font files.
Future<void> _fetchFonts(List<String> cssFiles) async {

  print('Skipping font fetches for now. $cssFiles');
  return;
  
  for (final cssFile in cssFiles) {
    final file = File(cssFile);
    final css = await file.readAsString();
    final match =
        RegExp(r"src:\s+url\(([^)]+)\)").firstMatch(css); // Use firstMatch
    if (match == null) {
      print("No URL found in CSS file: $cssFile");
      continue;
    }
    final url = match.group(1)!; // Use null assertion since we checked for null
    if (!url.endsWith(".woff2")) {
      print("URL in CSS file does not end with .woff2: $cssFile");
      continue;
    }
    final woff2File =
        path.join(file.parent.path, 'last_metadata', path.basename(file.path).replaceAll(".css", ".woff2"));
    final ttfFile =
        path.join(file.parent.path, 'last_metadata', path.basename(file.path).replaceAll(".css", ".ttf"));

    await _doFetch(url, woff2File);
    // decompressWoff2(woff2File, ttfFile); // Removed woff2
    await file.delete();

    final codepointsFile = File(ttfFile.replaceAll(".ttf", ".codepoints"));
    final codepoints = <String, String>{}; // Map to store codepoints

    //  //Removed icons.enumerate
    // for (final record in icons.enumerate(ttfFile)) {
    //   final name = record.name;
    //   final codepoint = record.codepoint.toRadixString(16).padLeft(4, '0');
    //   codepoints[name] = codepoint;
    // }

    final buffer = StringBuffer();
    codepoints.forEach((name, codepoint) {
      buffer.writeln('$name $codepoint');
    });
    await codepointsFile.writeAsString(buffer.toString());
  }
}

NO FONT STUFF AT ALL */

/// Filters a list of Fetch objects based on a predicate.
List<String> _files(List<Fetch> fetches, bool Function(String) predicate) {
  return fetches
      .where((fetch) => predicate(fetch.destFile))
      .map((f) => f.destFile)
      .toList();
}

/// Checks if a fetch should be skipped.
bool _shouldSkip(String destFile, bool overwrite) {
  return !overwrite && File(destFile).existsSync();
}

/// Generates arguments for URL patterns.
Map<String, String> _patternArgs(
    Map<String, dynamic> metadata, String stylisticSet) {
  return {
    "host": metadata["host"],
    "stylisticSetSnake": stylisticSet.replaceAll(" ", "").toLowerCase(),
    "stylisticSetUrl": stylisticSet.replaceAll(" ", "+"),
    "stylisticSetFont":
        stylisticSet.replaceAll(" ", "") + "[FILL,GRAD,opsz,wght]",
  };
}

void _createFetches(
    String style,
    int opsz,
    Map<String, String> patternArgs,
    List<Fetch> fetches,
    List<Fetch> skips,
    List<Asset> assets,
    bool overwrite) {
  patternArgs["style"] = style.isNotEmpty ? style : "default";
  patternArgs["styleSuffix"] = style.isNotEmpty ? "_$style" : "";
  patternArgs["sizePx"] = opsz.toString();

  for (final asset in assets) {
    final fetch = _createFetch(asset, patternArgs);
    if (_shouldSkip(fetch.destFile, overwrite)) {
      skips.add(fetch);
    } else {
      fetches.add(fetch);
    }
  }
}

Future<void> main(List<String> args) async {
  // Parse command-line flags. 
  bool fetchFlag = true;
  bool overwriteFlag = false;
  int iconLimit = 0;

  for (final arg in args) {
    if (arg == '--no-fetch') {
      fetchFlag = false;
    } else if (arg == '--overwrite') {
      overwriteFlag = true;
    } else if (arg.startsWith('--icon-limit=')) {
      try {
        iconLimit = int.parse(arg.split('=')[1]);
      } catch (e) {
        print('Invalid icon limit: $arg');
        exit(1);
      }
    }
  }
  final currentVersionsFile = _currentVersionsFile();
  // Create the directory if it does not exist
  if (!currentVersionsFile.parent.existsSync()) {
    currentVersionsFile.parent.createSync(recursive: true);
  }

  Map<String, dynamic> currentVersions = {};
  if (currentVersionsFile.existsSync()) {
    currentVersions = json.decode(await currentVersionsFile.readAsString());
  } else {
    print('No current versions file found. Creating a new one.');
  }
  if (DEBUG) print('Current versions: $currentVersions');

  final metadata = await _latestMetadata();
  final stylisticSets = _symbolFamilies(metadata);

  if (DEBUG)
    print('Found ${stylisticSets.length} stylistic sets: $stylisticSets');
  if (stylisticSets.isEmpty) {
    print('No stylistic sets found. Exiting.');
    return;
  }

  final List<Fetch> fetches = [];
  final List<Fetch> skips = [];
  var numChanged = 0;
  var icons =
      _icons(metadata).toList(); // Convert to list for easier manipulation.

  print(
      'Found metadata fir ${icons.length} icons. (including legacy Material Icons)');

  icons.removeWhere((icon) =>
      icon.stylisticSets.isEmpty); // Remove icons with empty stylistic sets

  print(
      'Pruned icons to only include ${icons.length} icons from Material Symbols.');

  if (iconLimit > 0) {
    icons = icons.take(iconLimit).toList();
    print('LIMITED icon LIST to icon limit: ${icons.length} icons.');
  }

  for (final icon in icons) {
    final verKey = _versionKey(icon);
    //DEBUGGING//final name = icon.name;
    //DEBUGGING//if(!name.startsWith("chevron")) {
    //DEBUGGING//  // TEMPORARY SKIP non-chevron icons for testing
    //DEBUGGING//  //print("Skipping non-chevron icon $name for testing.");
    //DEBUGGING//  continue;
    //DEBUGGING//}
    if (!overwriteFlag && icon.version <= (currentVersions[verKey] ?? 0)) {
      print("icon version for ${icon.name} is up to date. Skipping.");
      continue;
    }
    currentVersions[verKey] = icon.version;
    numChanged++;

    int setsExamined = 0;
    for (final stylisticSet in stylisticSets) {
      if (setsExamined > 0)
        break; // Only process the first stylistic set for each icon
      if (!icon.stylisticSets.contains(stylisticSet)) {
        print(
            'Icon ${icon.name} does not support stylistic set $stylisticSet. Skipping.');
        continue;
      }
      final patternArgs = _patternArgs(metadata, stylisticSet);
      patternArgs["iconName"] = icon.name; // Corrected variable name

      //We just need to get a SINGLE XML file for each icon.  We don't need to download all the styles and sizes.
      // We just need to get the autoMirrored info from the XML file.

      int opsz = 20; // Default value for opsz

      //for (final opsz in [20]) {   //NOT ALL [20, 24, 40, 48]) {
      //  for (final fill in [""]) {    //NOT ALL ["", "fill1"]) {
      //    for (final grad in [""]) {  //NOT ALL ["gradN25", "", "grad200"]) {
      //NO IOS //_createFetches(
      //NO IOS //    grad + fill, opsz, patternArgs, fetches, skips, _ICON_IOS_ASSETS, overwriteFlag);
      /* NO WEIGHTS
            for (final wght in [
              "wght100",
              "wght200",
              "wght300",
              "",
              "wght500",
              "wght600",
              "wght700"
            ]) {NO WEIGHTS */

      final fill = ""; //NO FILL
      final grad = ""; //NO GRAD
      final wght = ""; //NO WEIGHTS
      _createFetches(wght + grad + fill, opsz, patternArgs, fetches, skips,
          _ICON_ASSETS, overwriteFlag);
      /*NO WEIGHTS 
            }
            NO WEIGHTS */
      //    }
      //  }
      //}
      setsExamined++;
    }
  }

  /* DONT DOWNLOAD CSS FILES

  for (final stylisticSet in stylisticSets) {
    for (final asset in _SET_ASSETS) {
      final patternArgs = _patternArgs(metadata, stylisticSet);
      final fetch = _createFetch(asset, patternArgs);
      fetches.add(fetch);
    }
  }
  DONT DOWNLOAD CSS FILES */

  print('$numChanged/${icons.length} icons have changed');
  if (skips.isNotEmpty) {
    print('${skips.length} fetches skipped because assets exist');
  }

  if (fetches.isNotEmpty) {
    if (fetchFlag) {
      await _doFetches(fetches);
    } else {
      print('fetch disabled; not fetching ${fetches.length} assets');
    }
  }

  print(
      '${autoMirroredIconNames.length} Auto-mirrored icon${(autoMirroredIconNames.length > 1) ? 's' : ''}.'
          .orange);
  if (autoMirroredIconNames.isNotEmpty) {
    print(
        'Auto-mirrored icon name${(autoMirroredIconNames.length > 1) ? 's' : ''}: ${autoMirroredIconNames.join(", ").purple}'
            .orange);
  } else {
    print('No auto-mirrored icon names found.'.brightRed);
    print("There has to be mirrored icons in the set.  Exiting.  RE-RUN with --overwrite flag so that all SVG XML files are re-retrieved and examined".brightRed);
    exit(1);
  }


  /*now write this list to a file so we STORE THE LAST LIST */
  final autoMirroredFile = File(path.join(
      Directory.current.path,
      "last_metadata", // DO NOT GO UP "../..",
      "auto_mirrored_icon_names.txt"));

  // Also create a dated backup copy with zero-padded date format
  final now = DateTime.now();
  final dateSuffix = '${now.year}_${now.month.toString().padLeft(2, '0')}_${now.day.toString().padLeft(2, '0')}';
  final autoMirroredFileDated = File(path.join(
      Directory.current.path,
      "last_metadata",
      "automirrored_$dateSuffix.txt"));

  /* first read in the LAST file and compare */
  await autoMirroredFile.readAsLines().then((lines) {
    final previousSet = Set<String>.from(lines);
    final currentSet = autoMirroredIconNames;

    final added = currentSet.difference(previousSet);
    final removed = previousSet.difference(currentSet);

    if (added.isNotEmpty) {
      print(
          'New auto-mirrored icons added since last run: ${added.join(", ").purple}'
              .brightGreen);
    }
    if (removed.isNotEmpty) {
      print(
          'Auto-mirrored icons removed since last run: ${removed.join(", ").purple}'
              .brightRed);
    }
    if (added.isEmpty && removed.isEmpty) {
      print('No changes in auto-mirrored icons since last run.'.gray);
    }
  }).catchError((e) {
    print(
        'No previous auto-mirrored icon names file found or error reading it: $e'
            .brightRed);
    print("This tool must be run with the --overwrite flag for the first time so that this file is CREATED!!!."
        .yellow);
    // EXIT
    exit(1);
  });

  await autoMirroredFile.writeAsString(autoMirroredIconNames.join("\n"));

  // Also write the dated backup copy
  await autoMirroredFileDated.writeAsString(autoMirroredIconNames.join("\n"));

  /*
    Now augment the icons with the RTL (right-to-left) autoMirrored info
    And convert the icons list to a MAP of icon names to Icon objects.
  */
  Map<String, IconMetadata> iconsMap =
      {}; //Map<String, Icon>.fromIterable(icons, key: (icon) => icon.name, value: (icon) => icon);
  int rtlAutoMirroredFoundCount = 0;
  for (final icon in icons) {
    if (autoMirroredIconNames.contains(icon.name)) {
      icon.rtlAutoMirrored = true;
      rtlAutoMirroredFoundCount++;
    } else {
      icon.rtlAutoMirrored = false;
    }
    iconsMap[
        (icon.renamedIconName.isNotEmpty && icon.renamedIconName != icon.name)
            ? icon.renamedIconName
            : icon.name] = icon; // Update the map with the icon object
  }

  print('Found ${autoMirroredIconNames.length} RTL auto-mirrored icons.'.brightGreen);
  print(
      'Paired Info with $rtlAutoMirroredFoundCount icons with RTL auto-mirroring.'
          .brightGreen);
  if (autoMirroredIconNames.length != rtlAutoMirroredFoundCount) {
    print(
        'WARNING: RTL auto-mirrored icon names do not match the number of icons with RTL auto-mirroring.'
            .brightRed);
  } else {
    print(
        'RTL auto-mirrored icon names match the number of icons with RTL auto-mirroring.'
            .brightGreen);
  }

  /* DO NOT GET ANY FONTS
  final cssFiles = _files(fetches, (file) => file.endsWith(".css"));
  await _fetchFonts(cssFiles);
  DO NOT GET ANY FONTS */

  // Write the icon version info to our JSON file
  await currentVersionsFile.writeAsString(json.encode(currentVersions));

  // Write the icons METADATA map to a JSON file - now AUGMENTED with the RTL (right-to-left) autoMirrored info

  // Read in the existing icons metadata file, if it exists.
  final iconsMetadataFile = _iconsMetadataFile();
  Map<String, IconMetadata> existingIconsMapTyped = {};
  Map<String, dynamic> existingIconsMap = {};
  if (iconsMetadataFile.existsSync()) {
    try {
      final String existingJson = await iconsMetadataFile.readAsString();

      existingIconsMap = json.decode(existingJson);

      /* Read in to structure
      Map<String, dynamic> existingIconsMapRaw = json.decode(existingJson);

      // Iterate through the decoded JSON data and create Icon objects.
      existingIconsMapRaw.forEach((key, value) {
        //  value is the inner map, e.g., the one for "ten_k" or "ten_mp"
        if (value is Map<String, dynamic>) {
          try {
            Icon icon = Icon.fromJson(value);
            existingIconsMap[key] = icon;
          } catch (e) {
            print('Error creating existingIconsMap from JSON for key $key: $e');
            // Handle the error, e.g., skip this icon or use a default Icon.
          }
        } else {
          print('Unexpected data type for key $key: Expected a Map, got ${value.runtimeType}');
        }
      });
    */

      print('Successfully read existing icons metadata file.');
    } catch (e) {
      print(
          'Error reading or decoding existing icons metadata file: $e.  Overwriting.');
      existingIconsMap =
          {}; // Reset to an empty map on error to avoid corrupting data.
    }
  } else {
    print('No existing icons metadata file found. Creating a new one.');
  }


  // Look through existingIconsMap to find any existing autoMirrored icon names
  fromExistingJsonMetaData_AutoMirroredIconNames.clear();
  // Update the existing map with the new icon data.
  iconsMap.forEach((key, newIcon) {
    if(DEBUG) {
      print("KEY=  "+ key.toString() );
      print("NEWICON = "+ newIcon.toString() );
      if( existingIconsMap[key] != null) {
        print("EXISTING ICONS MAP FOR KEY "+ key.toString() + " = "+ existingIconsMap[key].toString() );
      } else {
        print("EXISTING ICONS MAP FOR KEY "+ key.toString() + " is NULL   EXITING - UNEXPECTED!!!".brightRed);
        exit(1);
      }
      if(newIcon.rtlAutoMirrored) {
        print("  NEW ICON IS RTL AUTOMIRRORED".brightGreen);
      } else {
        //print("  NEW ICON IS NOT RTL AUTOMIRRORED".gray);
      }
    }
    bool existingRtlAutoMirrored = false;
    if(existingIconsMap[key] != null) {
      existingRtlAutoMirrored = existingIconsMap[key]['rtlAutoMirrored'] ?? false;
      if(existingRtlAutoMirrored) {
        print("  EXISTING ICON IS RTL AUTOMIRRORED".brightGreen);
        fromExistingJsonMetaData_AutoMirroredIconNames.add(key);
      }

      //if(existingRtlAutoMirrored == newIcon.rtlAutoMirrored) {
      //  print("  EXISTING ICON IS RTL AUTOMIRRORED MATCHES THE EXISTING".brightGreen);
      //} else {
      //  print("  EXISTING ICON DID NOT MATCH RTL AUTOMIRRORED".yellow);
      //}
    } else {
      print("EXISTING ICONS MAP FOR KEY "+ key.toString() + " WAS NOT FOUND IN EXISTING JSON - Only correcting new icon!!!".orange);
    }


    // COMPLETELY REPLACE the existing icon entry with the new icon data
    existingIconsMap[key] = 
        json.decode(newIcon
            .toJson()); // Decode and re-encode to ensure the format is consistent.

    // Make SURE WE bring any autoMirrored info forward
    final secondCheckExistingRtlAutoMirrored = existingIconsMap[key]['rtlAutoMirrored'] ?? false;
    if(secondCheckExistingRtlAutoMirrored != existingRtlAutoMirrored) {
      print("  SECOND CHECK FOUND DIFFERENT RTL AUTOMIRRORED VALUE!!!".brightRed);
    }
    var finalAutoMirrored = existingIconsMap[key]['rtlAutoMirrored'] = existingRtlAutoMirrored || newIcon.rtlAutoMirrored;

    if( finalAutoMirrored && !fromExistingJsonMetaData_AutoMirroredIconNames.contains(key) ) {
      print("  $key ICON IS RTL AUTOMIRRORED - and was not in the fromExistingJsonMetaData_AutoMirroredIconNames list!!! ".brightGreen);
    }
  });

  /* Now we need to make sure that the lists for AutoMirrored icon names match */
 if (autoMirroredIconNames.length != fromExistingJsonMetaData_AutoMirroredIconNames.length) {
    print(
        'WARNING: Mismatch between autoMirroredIconNames (${autoMirroredIconNames.length}) and fromExistingJsonMetaData_AutoMirroredIconNames (${fromExistingJsonMetaData_AutoMirroredIconNames.length})'
            .brightRed);
  } else {
    print(
        'autoMirroredIconNames and fromExistingJsonMetaData_AutoMirroredIconNames lengths match.'
            .brightGreen);
  }

  if(!compareTwoSets(autoMirroredIconNames, fromExistingJsonMetaData_AutoMirroredIconNames)) {
    print(
        'WARNING: Mismatch between autoMirroredIconNames and fromExistingJsonMetaData_AutoMirroredIconNames sets.'
            .brightRed);
  } else {
    print(
        'autoMirroredIconNames and fromExistingJsonMetaData_AutoMirroredIconNames sets match.'
            .brightGreen);
  } 


  final iconsFile = _iconsMetadataFile();
  String prettyJson = JsonEncoder.withIndent('  ')
      .convert(existingIconsMap); // Use 2 space indentation
  await iconsFile.writeAsString(prettyJson);

  print('Done.');
}


bool
compareTwoSets( Set<String> previousSet, Set<String> currentSet) {
    final added = currentSet.difference(previousSet);
    final removed = previousSet.difference(currentSet);

    if (added.isNotEmpty) {
      print(
          'New auto-mirrored icons added since last run: ${added.join(", ").purple}'
              .brightGreen);
    }
    if (removed.isNotEmpty) {
      print(
          'Auto-mirrored icons removed since last run: ${removed.join(", ").purple}'
              .brightRed);
    }
    if (added.isEmpty && removed.isEmpty) {
      print('No changes in auto-mirrored icons since last run.'.gray);
    }
    return added.isEmpty && removed.isEmpty;
}


