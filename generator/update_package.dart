// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: avoid_print, unnecessary_type_check

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart' as path;

import 'package:chalkdart/chalkstrings.dart';

import 'icon_metadata.dart';
import 'write_metadata_dartfile.dart';

///  This program goes to the https://github.com/google/material-design-icons repository and retrieves the variable fonts and codepoint information
/// for the Material Symbols Icon fonts
///
/// https://github.com/google/material-design-icons/raw/master/variablefont/MaterialSymbolsOutlined%5BFILL%2CGRAD%2Copsz%2Cwght%5D.codepoints
/// https://github.com/google/material-design-icons/raw/master/variablefont/MaterialSymbolsRounded%5BFILL%2CGRAD%2Copsz%2Cwght%5D.codepoints
/// https://github.com/google/material-design-icons/raw/master/variablefont/MaterialSymbolsSharp%5BFILL%2CGRAD%2Copsz%2Cwght%5D.codepoints

late final bool verboseFlag;

bool addCategoryAndTagsComments = false;

/// Flag to include inline SVG previews of the icons in dart docs comments as markup
bool svgDartDocsFlag = false;

class IconInfo {
  final String originalIconName;
  final String iconName;
  final String codePoint;

  IconInfo(this.originalIconName, this.iconName, this.codePoint);
}

// The google repository's action has been broken for over 3 months https://github.com/google/material-design-icons/issues/1902
// I have submitted a PR to fix it ( https://github.com/google/material-design-icons/pull/1922 )
//  but until it's fixed get the fonts from my repo...
const bool useMyRepository = true;

class MaterialSymbolsVariableFont {
  final String flavor;
  final String iconDataClass;
  final String familyNameToUse;
  /*final*/ String _codepointFileUrl;
  /*final*/ String _ttfFontFileUrl;
  final String woff2FontUrlForDartDocSVG;
  final String svgFontFamily;
  late final String filename;
  final List<IconInfo> iconInfoList = [];

  // Until google fixes their action to generate the codepoints/fonts correctly...
  // use my repository
  String get codepointFileUrl {
    if (useMyRepository && _codepointFileUrl.startsWith("https://github.com/google/")) {
      _codepointFileUrl = _codepointFileUrl.replaceFirst(
          'github.com/google/','github.com/timmaffett/');
    }

    return _codepointFileUrl;
  }

  // Until google fixes their action to generate the codepoints/fonts correctly...
  // use my repository
  String get ttfFontFileUrl {
    if (useMyRepository && _ttfFontFileUrl.startsWith("https://github.com/google/")) {
      _ttfFontFileUrl = _ttfFontFileUrl.replaceFirst(
          'github.com/google/','github.com/timmaffett/');
    }
    return _ttfFontFileUrl;
  }

  MaterialSymbolsVariableFont(
      this.flavor,
      this.iconDataClass,
      this.familyNameToUse,
      this._codepointFileUrl,
      this._ttfFontFileUrl,
      this.woff2FontUrlForDartDocSVG,
      this.svgFontFamily) {
    final urlfilename = path.basename(ttfFontFileUrl);
    filename = Uri.decodeFull(urlfilename);

    print("Set filename for symbols font to $filename");
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
const Map<String, String> identifierPrefixRewrites = <String, String>{
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
const Map<String, String> identifierExactRewrites = <String, String>{
  'class': 'class_',
  'new': 'new_',
  'switch': 'switch_',
  'try': 'try_sms_star',

  //NO LONGER NEEDED//'door_back': 'door_back_door',
  //NO LONGER NEEDED//'door_front': 'door_front_door',
  //NOW EXCLUDED//'power_rounded': 'power_rounded_duplicate_of_power_settings_new',  // NEEDED because of 'power' icon creates 'power_rounded' so this is DUP otherwise
  //NEVER WAS NEEDED//'error_circle_rounded': 'error_circle_rounded_error',
};

// Icon names which are DUPLICATES and we should EXCLUDE
const List<String> identifierExcludeNames = <String>[
  'power_rounded', // THis is a DUPLICATE icon of 'power_settings_new' and if we included it it would create 'power_rounded' which would collide with 'power' 's 'power_rounded'
  'expension_panels', // spelling error in Google's 2.791 version of codepoint files
];

Map<String, String> renamedSymbolsToAugmentMap = {};

/// Path to write the downloaded TTF files to `../rawFontsUnfixed`
/// KLUDGE - currently we have to patch the fonts with the correct metrics to get them to render correctly in flutter.
/// This is done using the `../rawFontsUnfixed/fixFontMetricsAndUpdateLibFonts.sh` script.  This script patches the
/// fonts and then copies them to `../lib/fonts`.  This script requires python and the fonttools package to be
/// installed on the machine.
///
/// Once the fonts have been corrected in their github repository this step will not be required.
///
/// THIS IS NON-IDEAL (obviously!!) - and we have submitted a issue to the material symbols github repo
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
//WITH src - but the sandbox removes this//const svgIconTemplateRaw =
// so there this is just wasted bytes    //    r'''data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32"><defs><style type="text/css">@font-face { font-family: "$1"; src: $2;} text {font-family:"$1"; font-size: 32px; text-anchor: middle; dominant-baseline: text-bottom; fill: grey;}</style></defs><text xmlns="http://www.w3.org/2000/svg" x="50%" y="100%">&%23x$3;</text></svg>''';
const svgIconTemplateRaw =
    r'''data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32"><defs><style type="text/css">@font-face{font-family:"$1";}text{font-family:"$1";font-size:32px;text-anchor:middle;dominant-baseline:text-bottom;fill:grey;}</style></defs><text xmlns="http://www.w3.org/2000/svg" x="50%" y="100%">&%23x$3;</text></svg>''';
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
      //NO LONGER BOTHER - sandbox removes - local fonts are required//.replaceFirst(r'$2', fontinfo.woff2FontUrlForDartDocSVG)
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

/// Hold metadata for each icon in the Material Symbols collection.  This (most importantly) includes the RTL auto-mirrored flag for icons which need to have this set via IconData( matchTextDirection: ) parameter
Map<String, IconMetadata> iconMetadataMap = {};

/// Creates a set from the keys of a map.
///
/// This function takes a map and returns a set containing all the keys
/// from the map.
///
/// Parameters:
///   map: The map whose keys will be used to create the set.
///
/// Returns:
///   A set containing the keys of the map.  Returns an empty set if the
///   input map is null or empty.
Set<K> getKeysAsSet<K, V>(Map<K, V>? map) {
  if (map == null || map.isEmpty) {
    return <K>{}; // Return an empty set of the appropriate type
  }
  return map.keys.toSet();
}

Set<int> codepointMetadata = <int>{};
/// Extracts the codepoints from a Map<String, Icon> and returns them as a Set<int>.
///
/// This function iterates through the values of the input map (which are assumed to be Icon objects)
/// and adds the codepoint of each icon to a set.
///
/// Parameters:
///   iconMap: A map where the keys are strings and the values are Icon objects.
///
/// Returns:
///   A set containing the codepoints of all icons in the map.  Returns an empty set
///   if the input map is null or empty.
Set<int> getCodepointsFromIconMap(Map<String, IconMetadata>? iconMap) {
  if (iconMap == null || iconMap.isEmpty) {
    return <int>{};
  }
  Set<int> codepoints = {};
  iconMap.forEach((key, icon) {
    codepoints.add(icon.codepoint);
    if(codepointToMetadataMap[icon.codepoint]!=null) {
      print('CODEPOINT ${icon.codepoint} already exists!'.red);
    }
    codepointToMetadataMap[icon.codepoint] = icon;
  });
  return codepoints;
}



void findMetadataWithDifferentCodepointsFromName(List<MaterialSymbolsVariableFont> fontinfoList) {
  int? lastCount;
  for (final fontinfo in fontinfoList) {
    if (lastCount != null) {
      assert(fontinfo.iconInfoList.length == lastCount);
      if(fontinfo.iconInfoList.length != lastCount) {
        print('ERROR: style ${fontinfo.flavor} has different number of codepoints ${fontinfo.iconInfoList.length} vs. $lastCount'.red);
      }
    }
    lastCount = fontinfo.iconInfoList.length;
  }

  var iconCount = 0;
  final fontinfo = fontinfoList[0];

  for (int i = 0; i < lastCount!; i++) {
    final iconInfo = fontinfo.iconInfoList[i];
    var iconname = iconInfo.iconName;
    final codepoint = iconInfo.codePoint;
    final int codePointValue = int.tryParse('0x$codepoint') ?? 0;

    final iconDataClass = fontinfo.iconDataClass;
    final iconMetadata = iconMetadataMap[iconname];// ?? codepointToMetadataMap[codePointValue];
    if(iconMetadata!=null) {
      if(iconMetadata.codepoint != codePointValue) {
        if(iconMetadata.codePointsFromCodePointsFiles.contains(codePointValue)) {
          print('  Icon $iconname has entry in codePointsFromCodePointsFiles[] for  $codePointValue ALREADY'.brightRed.blink);
        } else {
          iconMetadata.codePointsFromCodePointsFiles.add(codePointValue);
          // MISS MATCH OF CODEPOINTS!!
          print('Icon $iconname has a different codepoint in metadata "0x${iconMetadata.codepoint.toRadixString(16).toUpperCase()}" vs "0x${codePointValue.toRadixString(16).toUpperCase()}"'.red);


          codepointToMetadataMap[codePointValue] = iconMetadata;
          //print('  Icon $iconname has a different codepoint in metadata "0x${iconMetadata.codepoint.toRadixString(16).toUpperCase()}" vs "0x${codePointValue.toRadixString(16).toUpperCase()}"'.red);

        }
      }
    } else {
      print('DID not find $iconname in the metadata');
    }
  }

}


Map<int,IconMetadata> codepointToMetadataMap = {};

Set<String> missingMetadata = <String>{}; 
Set<String> unusedMetaData = <String>{};
Set<String> usedRTLMetadata = <String>{};
Set<String> expectedRTL = <String>{ "threesixty", "add_to_home_screen", "airplane_ticket", "airport_shuttle", "align_horizontal_left", "align_horizontal_right",
"alt_route", "arrow_back", "arrow_back_ios", "arrow_circle_left", "arrow_circle_right", "arrow_forward", "arrow_forward_ios",
"arrow_left", "arrow_left_alt", "arrow_menu_close", "arrow_menu_open", "arrow_outward", "arrow_right", "arrow_right_alt",
"arrow_split", "article", "assignment", "assignment_return", "assist_walker", "assistant_direction", "backspace", "battery_unknown",
"bike_lane", "block", "brand_awareness", "branding_watermark", "bubble", "business_messages", "call_made", "call_merge", "call_missed",
"call_missed_outgoing", "call_received", "call_split", "chat", "chat_add_on", "chat_info", "chat_paste_go", "chat_paste_go_2", "checkbook",
"chevron_backward", "chevron_forward", "chevron_left", "chevron_right", "chrome_reader_mode", "clarify", "comment", "compare_arrows",
"contact_support", "content_copy", "content_cut", "contextual_token", "contextual_token_add", "contrast", "desktop_landscape", "desktop_landscape_add",
"desktop_portrait", "devices_other", "diagonal_line", "directions", "directions_alt", "directions_bike", "directions_run", "directions_walk",
"docs", "double_arrow", "draft", "drive_export", "drive_file_move", "dvr", "electric_bike", "electric_moped", "electric_rickshaw", "electric_scooter",
"event_note", "event_upcoming", "exit_to_app", "expand_circle_right", "featured_play_list", "featured_video", "filter_arrow_right", "fire_truck",
"flag", "flight_land", "flight_takeoff", "flights_and_hotels", "float_landscape_2", "float_portrait_2", "follow_the_signs", "format_align_left",
"format_align_right", "format_indent_decrease", "format_indent_increase", "format_list_bulleted", "format_list_bulleted_add", "forward",
"forward_to_inbox", "funicular", "gondola_lift", "grading", "handheld_controller", "help", "help_center", "highlight_mouse_cursor", "hotel",
"hotel_class", "ink_highlighter_move", "input", "keyboard_arrow_left", "keyboard_arrow_right", "keyboard_backspace", "keyboard_double_arrow_left",
"keyboard_double_arrow_right", "keyboard_return", "keyboard_tab", "keyboard_tab_rtl", "label", "label_important", "last_page", "library_books", "light_group",
"line_curve", "list", "list_alt", "lists", "live_help", "local_shipping", "login", "logout", "lyrics", "manage_search", "menu_book", "menu_open", "merge_type",
"missed_video_call", "mobile_screen_share", "monitoring", "moped", "more", "move_item", "move_location", "moving", "moving_ministry", "multiline_chart",
"news", "newsmode", "next_plan", "next_week", "no_sound", "not_listed_location", "note_add", "notes", "offline_share", "open_in_new", "outbox_alt", "pedal_bike",
"phone_callback", "phone_forwarded", "phone_missed", "picture_in_picture", "picture_in_picture_alt", "picture_in_picture_large", "picture_in_picture_medium",
"picture_in_picture_mobile", "picture_in_picture_small", "position_top_right", "prompt_suggestion", "queue_music", "read_more", "receipt_long", "redo",
"replace_audio", "replace_image", "replace_video", "reply", "reply_all", "reset_image", "rotate_left", "rotate_right", "rtt", "run_circle", "schedule_send", "scooter",
"screen_share", "segment", "send", "send_and_archive", "send_money", "send_to_mobile", "settings_backup_restore", "shield_question", "short_text", "show_chart",
"side_navigation", "snowmobile", "sort", "speaker_notes", "stairs", "stairs_2", "star_half", "sticky_note", "sticky_note_2", "stop_screen_share", "subject",
"switch_access_2", "switch_access_3", "text_ad", "text_compare", "text_snippet", "text_to_speech", "thermostat", "toc", "tooltip_2", "transition_push",
"transition_slide", "travel", "trending_down", "trending_flat", "trending_up", "tv_next", "two_wheeler", "undo", "video_camera_back_add", "videocam",
"view_list", "view_quilt", "view_sidebar", "volume_down", "volume_down_alt", "volume_mute", "volume_off", "volume_up", "watch_arrow", "wrap_text", "wysiwyg" };

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
      'category_and_tag_comments',
      abbr: 'c',
      defaultsTo: false,
      negatable: true,
      help: 'Include category and tag metadata comments for each icon.',
    )
    ..addFlag(
      'downloadfonts',
      abbr: 'd',
      negatable: false,
      help:
          'The TTF font files will be downloaded to the $pathToWriteTTFFiles directory if this flag is passed.',
    );
  late final ArgResults parseArgs;

  try {
    parseArgs = parser.parse(args);
  } catch (e) {
    printUsage(parser);
    exit(0);
  }

  if (parseArgs['help'] as bool) {
    printUsage(parser);
    exit(0);
  }


  // Read the icon metadata so we have this info to write out categories and tags in comments and to set the `matchTextDirection` parameter of our IconData() constructors
  iconMetadataMap = await readIconsMetadata();
  print('READ metadata for ${iconMetadataMap.length} icons'.brightYellow);
  codepointMetadata = getCodepointsFromIconMap(iconMetadataMap);
  print('READ metadata for ${codepointMetadata.length} codepoints'.orange);
  //print('    codepints [ ${codepointMetadata} ]'.orange);
  print('    codepointToMetadataMap ${codepointToMetadataMap.length} entries '.orangeRed);
  unusedMetaData = getKeysAsSet(iconMetadataMap);



  final downloadFontsFlag = parseArgs['downloadfonts'] as bool;
  svgDartDocsFlag = parseArgs['svg_icon_in_dart_docs'] as bool;
  verboseFlag = parseArgs['verbose'] as bool;
  addCategoryAndTagsComments = parseArgs['category_and_tag_comments'] as bool;

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
            if (!identifierExcludeNames.contains(iconName)) {
              if (identifierExactRewrites.keys.contains(iconName) ||
                  iconName.startsWith(RegExp(r'[0-9]'))) {
                iconName = _generateFlutterId(iconName);
                renamedIconNames.add('$originalName => $iconName');
                // Keep track of the renamed symbols so we can augment the symbols name map with the original names
                renamedSymbolsToAugmentMap[originalName] = iconName;
              }
              iconInfoList.add(IconInfo(originalName, iconName, codePoint));
            }
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

  // Now see where the iconname entries in the metadata have codepoints THAT ARE DIFFERENT than the codepoints file
  findMetadataWithDifferentCodepointsFromName( variableFontFlavors );

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

  // Write out the metadata dart file
  const dartMetadataSourceFilename =
      '${pathToWriteDartFiles}material_symbols_metadata.dart';
  print('Writing metadata dart file to $dartMetadataSourceFilename'.brightBlue);
  final metadataResult = writeOutTheMetadataDartFile(File(dartMetadataSourceFilename));
  print(metadataResult.brightCyan );

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

/// Joins a list of strings into a comma-separated string,
/// splitting the string into multiple lines if necessary to keep
/// the line length under 80 characters.
String createTagCommentLines(List<String> strings) {
  if (strings.isEmpty) return '';

  String result = '';
  const String commentStart = '  /// Tags: ';
  String currentLine = commentStart;

  for (String str in strings) {
    if (currentLine==commentStart) {
      currentLine += str;
    } else if (currentLine.length + str.length + 2 <=
        80) { // +2 for ", "
      currentLine += ', $str';
    } else {
      result += '$currentLine,\n';
      currentLine = '  ///       $str';
    }
  }
  result += currentLine;
  return result;
}

/// Removes all elements that are present in both sets from both sets.
///
/// This function modifies the original sets.
///
/// Parameters:
///   set1: The first set.
///   set2: The second set.
void removeIntersectingElements<T>(Set<T> set1, Set<T> set2) {
  // Create a copy of the intersection to avoid modifying the sets while iterating.
  final intersection = set1.intersection(set2).toSet();

  // Remove the intersecting elements from both sets.
  set1.removeAll(intersection);
  set2.removeAll(intersection);
}

/// Write a combined version of the `Symbols` class with outlined, rounded and sharp versions of
/// each icon.  The outline version has no suffix and each rounded and sharp icon name has a
/// corresponding suffix (`_rounded` and `_sharp`).
void writeCombinedSourceFile(
    List<MaterialSymbolsVariableFont> fontinfoList, String sourceFilename,
    {bool suffixVersion = true}) {
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
      if(fontinfo.iconInfoList.length != lastCount) {
        print('ERROR: style ${fontinfo.flavor} has different number of codepoints ${fontinfo.iconInfoList.length} vs. $lastCount'.red);
      }
    }
    lastCount = fontinfo.iconInfoList.length;
  }

  var iconCount = 0;

  for (int i = 0; i < lastCount!; i++) {
    for (final fontinfo in fontinfoList) {
      final iconInfo = fontinfo.iconInfoList[i];
      var iconname = iconInfo.iconName;
      final codepoint = iconInfo.codePoint;
      final int codePointValue = int.tryParse('0x$codepoint') ?? 0;

      final iconDataClass = fontinfo.iconDataClass;
      final iconMetadata = iconMetadataMap[iconname] ?? codepointToMetadataMap[codePointValue];

      // if we can't get metadata by iconame OR codepoint then it is missing...
      if(iconMetadata==null) {
        missingMetadata.add(iconname);
      }

      final rtlMatchTextDirection = iconMetadata?.rtlAutoMirrored ?? false;
      final categories = iconMetadata?.categories ?? <String>[];
      final tags = iconMetadata?.tags ?? <String>[];

      if(rtlMatchTextDirection && !usedRTLMetadata.contains(iconname)) {
        usedRTLMetadata.add(iconname);
      }
      if(fontinfo.flavor == 'outlined' && iconMetadataMap[iconname]!=null) {
        // any time we use a metadata entry removeit from our 'unusedMetaData' set
        unusedMetaData.remove(iconname);
      }

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
      if(addCategoryAndTagsComments && (categories.isNotEmpty || tags.isNotEmpty)) {
        sourceFileContent.writeln('  /// Category: ${categories.join(', ')}');
        final tagLines = createTagCommentLines(tags);
        sourceFileContent.writeln(tagLines);
      }
      String proposedSingleLine =
          "  static const IconData $iconname = $iconDataClass(0x$codepoint${rtlMatchTextDirection?', matchTextDirection:true':''});";
      if (proposedSingleLine.length > 80) {
        //split to two lines
        sourceFileContent.writeln("  static const IconData $iconname =");
        sourceFileContent.writeln("      $iconDataClass(0x$codepoint${rtlMatchTextDirection?', matchTextDirection:true':''});");
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

  /// CHECK RTL metadata usage:
  removeIntersectingElements( usedRTLMetadata, expectedRTL );

  print('INTERSECTION of expected and usedRTLmetadata:'.orange);
  print('usedRTLMetadata: $usedRTLMetadata'.orange);
  print('expectedRTL: $expectedRTL'.orange);
  print('unusedMetaData LEFTOVERS: ${unusedMetaData.length} entries left'.brightCyan);
  print('unusedMetaData: ${unusedMetaData}'.brightCyan);
  print('Icons that were MISSING from metadata: ${missingMetadata.length} icons  (There could be duplicate names for the same codepoint here, so fewer actual missing metadatas)'.red);
  print('     MISSING metadata: ${missingMetadata}'.red);
  
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

  final renamedIconsContent = StringBuffer('''
// Map of Material Symbols Icon names that were renamed to
// valid Dart variable/symbol names. (ie. not starting with numbers
// and not being a Dart reserved word).
// To lookup the IconData Symbol.XXX object using a original icon name
// use `materialSymbolsMap[materialSymbolsMap[originalName]]`
//
// BEGIN GENERATED static array
Map<String, String> renamedMaterialSymbolsMap = {
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
      var originalIconName = iconInfo.originalIconName;
      bool iconWasRenamed = false;
      if (iconname != originalIconName) {
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
          originalIconName = '${originalIconName}_${fontinfo.flavor}';
        }
        final lineStr = "  '$originalIconName': '$iconname',";
        if (lineStr.length <= 80) {
          renamedIconsContent.writeln(lineStr);
        } else {
          // SPLIT THE LINE
          renamedIconsContent.writeln("  '$originalIconName':");
          renamedIconsContent.writeln("      '$iconname',");
        }
        renamedMapEntries++;
      }
    }
  }
  sourceFileContent.writeln('};');
  // write the additional renamed icons info
  sourceFileContent.write(renamedIconsContent);
  sourceFileContent.writeln('};');
  sourceFileContent.writeln('// END GENERATED ICONS');

  File(exampleSourceFilename).writeAsStringSync(sourceFileContent.toString());

  print('Wrote $iconCount COMBINED icons to $exampleSourceFilename');
  print(
      'Augmented map with entries for $renamedMapEntries icons that were renamed from the original material names (which could not be used because they were invalid Dart symbol names).');

  // Write out the metadata dart file
  const dartMetadataSourceFilename =
      '${pathToWriteDartFiles}material_symbols_metadata.dart';
  print('Writing metadata dart file to $dartMetadataSourceFilename'.brightBlue);
  final metadataResult = writeOutTheMetadataDartFile(File(dartMetadataSourceFilename));
  print(metadataResult.brightCyan );
}

/// This mimics the flutter icon renaming in flutter engine \dev\tools\update_icons.dart
/// and it essentially copied from there, but needlessly a little faster
String _generateFlutterId(String id) {
  String flutterId = id;
  bool fixApplied = false;
  if (identifierExcludeNames.contains(id)) {
    throw ('_generateFlutterId() encounted "$id" which is an excluded icon name and should have been pruned from lists.');
  }

  // Exact identifier rewrites.
  for (final MapEntry<String, String> rewritePair
      in identifierExactRewrites.entries) {
    if (id == rewritePair.key) {
      flutterId = id.replaceFirst(
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
      if (id.startsWith(rewritePair.key)) {
        flutterId = id.replaceFirst(
          rewritePair.key,
          identifierPrefixRewrites[rewritePair.key]!,
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
