import 'dart:convert';
import 'package:chalkdart/chalkstrings.dart';

/*
  This class represents the metadata for an icon in the Material Symbols collection. It can hold all of the data that is
  available in the metadata file. The metadata file is a JSON file that contains information about each icon, including its name, version, popularity, and other attributes.

  The metadata file is located at the following URL:
    const String _METADATA_URL = "http://fonts.google.com/metadata/icons?incomplete=1&key=material_symbols";


  We AUGMENT this metadata with the following fields:
     renamedIconName: The name of the icon that we will use in the code. This is the name that we will use to refer to the icon in Flutter as it needs to be a valid symbol name.
     rtlAutoMirrored:  We derive this data in `update_metadata.dart` by reading an example android XML file for each symbol and looking for the RegExp(r'android:autoMirrored\s*=\s*"true"');
                       Unfortunately there is no easier way to get this information currently, as the https://github.com/google/material-design-icons repo does not contain this information
                       and the metadata file also does not contain this information.
                       So we will CREATE our own augmented version of the metadata file that holds all this information.
                       Google needs to add this information to the metadata file in the future!
*/

class IconMetadata {
  String name;
  String renamedIconName = "";
  int version;
  Set<String> stylisticSets;
  int popularity;
  int codepoint;
  List<String> categories;
  List<String> tags;
  bool rtlAutoMirrored = false; // Default to false
  List<int> codePointsFromCodePointsFiles = [];

  IconMetadata(
      {required this.name,
      this.renamedIconName = '',
      required this.version,
      required this.stylisticSets,
      required this.popularity,
      required this.codepoint,
      required this.categories,
      required this.tags,
      this.rtlAutoMirrored = false}); // Default to false

  factory IconMetadata.fromJson(Map<String, dynamic> json) {
    return IconMetadata(
      name: (json['originalName'] != null &&
              json['originalName']!.isNotEmpty &&
              json['originalName'] != json['name'])
          ? json['originalName']
          : json['name'],
      renamedIconName: (json['originalName'] != null &&
              json['originalName']!.isNotEmpty &&
              json['originalName'] != json['name'])
          ? json['name']
          : '',
      version: json['version'] ?? 0,
      stylisticSets:
          (json['stylisticSets'] as List<dynamic>?)?.cast<String>().toSet() ??
              {}, // Handle null or missing lists
      popularity: json['popularity'] ?? 0,
      codepoint: json['codepoint'] ?? 0,
      categories: (json['categories'] as List<dynamic>?)?.cast<String>() ?? [],
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      rtlAutoMirrored: json['rtlAutoMirrored'] ?? false,
    );
  }

  String toJson() {
    if (categories.length > 1) {
      print(
          'FOUND ICON WITH MULTIPLE CATEGORIES: $name   categories=$categories'
              .orange);
    }
    return json.encode({
      'name': (renamedIconName.isNotEmpty && renamedIconName != name)
          ? renamedIconName
          : name,
      'version': version,
      if (renamedIconName.isNotEmpty && renamedIconName != name)
        'originalName': name,
      if (rtlAutoMirrored) 'rtlAutoMirrored': rtlAutoMirrored,
      //DONT WRITE THIS - WE DONT NEED//'stylisticSets': stylisticSets.toList(),
      'popularity': popularity,
      'codepoint': codepoint,
      'categories': categories,
      'tags': tags,
    });
  }
}
