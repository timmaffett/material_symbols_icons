import 'dart:convert';
import 'package:chalkdart/chalkstrings.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:chalkdart/chalkstrings.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import 'icon_metadata.dart';
import 'update_metadata.dart';

/// Returns the path to the icons file.
File _iconsMetadataJsonFile() {
  return File(path.join(Directory.current.path, 'last_metadata', 'icons_metadata.json'));
}

void main() {
  String result = writeOutTheMetadataDartFile(File( 'material_symbols_metadata.dart'));
  print(result.green);
}

String writeOutTheMetadataDartFile(File outFile) {
  // read the icons metadata from the file
  final iconMetadata = readIconsMetadata();

  //dumpIconMetadata(iconMetadata);
  //writeIconMetadataAsDartCode(iconMetadata);

  StringBuffer outputStringBuffer = StringBuffer();
  writeIconMetadataDartCodeHeader(outputStringBuffer);

  writeIconMetadataAsDartCodeWithStringTables(outputStringBuffer, iconMetadata);

  // Write the stringbuffer to the output file.
  outFile.writeAsStringSync(outputStringBuffer.toString());

  return('Wrote icon metadata to ${outFile.path} - ${iconMetadata.length} icons written.');
}

Map<String, IconMetadata> readIconsMetadata() { 

  // Create a Map to hold the Icon objects, using the key from the JSON.
  Map<String, IconMetadata> iconMap = {};

  final iconsMetadataFile = _iconsMetadataJsonFile();

  if (iconsMetadataFile.existsSync()) {
    try {
      final String jsonString = iconsMetadataFile.readAsStringSync();

      // Decode the JSON string into a Map<String, dynamic>.
      Map<String, dynamic> jsonData = json.decode(jsonString);

      // Iterate through the decoded JSON data and create Icon objects.
      jsonData.forEach((key, value) {
        //  value is the inner map, e.g., the one for "ten_k" or "ten_mp"
        if (value is Map<String, dynamic>) {
          try {
            IconMetadata icon = IconMetadata.fromJson(value);
            iconMap[key] = icon;
          } catch (e) {
            print('Error creating Icon from JSON for key $key: $e');
            // Handle the error, e.g., skip this icon or use a default Icon.
          }
        } else {
          print('Unexpected data type for key $key: Expected a Map, got ${value.runtimeType}');
        }
      });

      //print('Successfully read existing icons metadata file - ${iconMap.length} icons read.');
    } catch (e) {
      print(
          'Error reading or decoding existing icons metadata file: $e.  Overwriting.');
    }
    return iconMap;
  } else {
    print('Icon metadata file does not exist. Please run `dart run update_package.dart` to create it.'.red);
    return iconMap; // Return an empty map if the file doesn't exist.
  } 
}

/* TEST
void dumpIconMetadata(Map<String, IconMetadata> iconMap) {
  // Print the created Icon objects.
  iconMap.forEach((key, icon) {
    print('Key: $key');
    print('Name: ${icon.name}');
    if(icon.renamedIconName.isNotEmpty) print('Renamed Icon Name: ${icon.renamedIconName}');
    print('Version: ${icon.version}');
    if(icon.rtlAutoMirrored) print('RTL Auto Mirrored: ${icon.rtlAutoMirrored}');
    print('Popularity: ${icon.popularity}');
    print('Codepoint: ${icon.codepoint}');
    print('Categories: ${icon.categories}');
    print('Tags: ${icon.tags}');
    print('---');
  });
}
TEST */

/* BEGIN WRITE NON STRING TABLE VERSION
void writeIconMetadataAsDartCode(Map<String, IconMetadata> iconMap) {

  print('Map<String, IconMetadata> iconMap = {');
  iconMap.forEach((key, icon) {
    print('  "$key": IconMetadata(');
    if(icon.renamedIconName.isNotEmpty) {
      print('    originalName: "${icon.name}",');
      //THIS IS THE KEY//if(icon.renamedIconName.isNotEmpty) print('    renamedIconName: "${icon.renamedIconName}",');
    }
    print('    version: ${icon.version},');
    //WE DONT NEED THISprint('    stylisticSets: ${icon.stylisticSets},');
    print('    popularity: ${icon.popularity},');
    print('    codepoint: 0x${icon.codepoint.toRadixString(16).padLeft(4, '0')},');
    print('    categories: [ ${icon.categories.map((cat) => '"$cat"').join(', ')} ],');
    print('    tags: [ ${icon.tags.map((tag) => '"$tag"').join(', ')} ],');
    if(icon.rtlAutoMirrored) print('    rtlAutoMirrored: ${icon.rtlAutoMirrored},');
    print('  ),');
  });
  print('};');

}
END WRITE NON STRING TABLE VERSION */


Map<String, int> _categoryStringTable = {};
Map<String, int> _tagStringTable = {};


int addToCategoryStringTable(String category) {
  if (!_categoryStringTable.containsKey(category)) {
    _categoryStringTable[category] = _categoryStringTable.length;
  }
  return _categoryStringTable[category]!;
}

int addToTagStringTable(String tag) {
  if (!_tagStringTable.containsKey(tag)) {
    _tagStringTable[tag] = _tagStringTable.length;
  }
  return _tagStringTable[tag]!;
}

/// Writes the icon metadata as Dart code, using string tables for categories and tags. 
void writeIconMetadataAsDartCodeWithStringTables(StringBuffer output, Map<String, IconMetadata> iconMap) {

  StringBuffer mapStringBuffer = StringBuffer();
  mapStringBuffer.writeln('/// This map contains the metadata for all Material Symbols icons.');
  mapStringBuffer.writeln("/// The keys are the icon's dart symbol name and the values are SymbolsMetadata objects that contain the metadata.");
  mapStringBuffer.writeln('/// The metadata includes the original name, popularity, codepoint, categories, tags, and whether the icon is RTL auto-mirrored.');
  mapStringBuffer.writeln('Map<String, SymbolsMetadata> iconMap = {');
  iconMap.forEach((key, icon) {
    mapStringBuffer.writeln('  "$key": SymbolsMetadata(');
    //mapStringBuffer.writeln('    name: "${icon.name}",');
    if(icon.renamedIconName.isNotEmpty) mapStringBuffer.writeln('    originalName: "${icon.name}",');
    mapStringBuffer.writeln('    popularity: ${icon.popularity},');
    mapStringBuffer.writeln('    codepoint: 0x${icon.codepoint.toRadixString(16).padLeft(4, '0')},');
    mapStringBuffer.writeln('    categories: [ ${icon.categories.map((cat) => '${addToCategoryStringTable(cat)}').join(', ')} ],');
    mapStringBuffer.writeln('    tags: [ ${icon.tags.map((tag) => '${addToTagStringTable(tag)}').join(', ')} ],');
    if(icon.rtlAutoMirrored) mapStringBuffer.writeln('    rtlAutoMirrored: ${icon.rtlAutoMirrored},');
    mapStringBuffer.writeln('  ),');
  });
  mapStringBuffer.writeln('};');

  output.writeln('/// List of all Categories - SymbolsMetadata() objects reference categories by their INDEX this table.');
  output.writeln('/// To get the category name, use `categoryMap[categoryIndexFromSymbolsMetadata]`');
  output.writeln('List<String> categoryMap = [');
  _categoryStringTable.keys.map((cat) => '  "$cat",').forEach((line) => output.writeln(line));
  output.writeln('];');  
  output.writeln();

  output.writeln('/// List of all Tags - SymbolsMetadata() objects reference tags by their INDEX this table.');
  output.writeln('/// To get the tag name, use `tagMap[tagIndexFromSymbolsMetadata]`');
  output.writeln('List<String> tagMap = [');
  _tagStringTable.keys.map((tag) => '  "$tag",').forEach((line) => output.writeln(line));
  output.writeln('];');  
  output.writeln();

  output.writeln();
  output.writeln(mapStringBuffer.toString());
  output.writeln();
}



void writeIconMetadataDartCodeHeader(StringBuffer output) {
 final fileHeaderContent = '''// GENERATED FILE. DO NOT EDIT.
//
// To edit this file modify the generator file `generator/update_package.dart` and
// re-generate.
// This file was generated ${DateTime.now()} by the dart file
// `generator/update_package.dart`.
//
// Copyright 2025. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// These data tables provide metadata for the Material Symbols icons.
///  The data was derived from the official Material Symbols metadata file
/// downloaded from `$MATERIAL_SYMBOLS_METADATA_DOWNLOAD_URL`
/// 
library symbols;

import 'dart:convert';

/// This class represents the metadata for an icon in the Material Symbols collection.
class SymbolsMetadata {
  String? originalName;  // This is set if the icon was renamed from the original name (to create a valid Dart symbol name). Otherwise it is null.
  int popularity;
  int codepoint;
  List<int> categories;
  List<int> tags;
  bool rtlAutoMirrored = false; // Default to false
  List<int> codePointsFromCodePointsFiles = [];
  
  SymbolsMetadata(
      {
      this.originalName,
      required this.popularity,
      required this.codepoint,
      required this.categories,
      required this.tags,
      this.rtlAutoMirrored = false}); // Default to false

  factory SymbolsMetadata.fromJson(Map<String, dynamic> json) {
    return SymbolsMetadata(
      originalName: (json['originalName']!=null && json['originalName']!.isNotEmpty && json['originalName']!=json['name']) ? json['originalName'] : null,
      popularity: json['popularity'] ?? 0,
      codepoint: json['codepoint'] ?? 0,
      categories:
          (json['categories'] as List<dynamic>?)?.cast<int>() ?? [],
      tags: (json['tags'] as List<dynamic>?)?.cast<int>() ?? [],
      rtlAutoMirrored: json['rtlAutoMirrored'] ?? false,
    );
  }

  String toJson() {
    return json.encode({
      if(originalName!=null && originalName.isNotEmpty) 'originalName': originalName,
      if(rtlAutoMirrored) 'rtlAutoMirrored': rtlAutoMirrored,
      'popularity': popularity,
      'codepoint': codepoint,
      'categories': categories,
      'tags': tags,
    });
  }
}
''';

  output.writeln(fileHeaderContent);
}