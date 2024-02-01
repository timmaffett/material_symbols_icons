import 'package:example_using_material_symbols_icons/models/font_list_type_model.dart';
import 'package:example_using_material_symbols_icons/pages/navigation_page.dart';
import 'package:example_using_material_symbols_icons/pages/settings_page.dart';
import 'package:example_using_material_symbols_icons/provider/icon_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: depend_on_referenced_packages
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:universal_html/html.dart' show window;

import 'symbols_map.dart';

import 'package:device_preview/device_preview.dart'; // required when useDevicePreview==true

/// Set [useDevicePreview] to allow testing layouts on virtual device screens
const useDevicePreview = false;

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
  setUrlStrategy(PathUrlStrategy());

  // create separate iconname->icon map for each style
  makeSymbolsByStyleMaps();

  /*
    Here we can set default Icon VARATIONS which can be specific to Outlined, Rounded or Sharp icons,
    each with their own settings.  These will take PRIORITY over IconThemeData()
    This is totally optional and IconThemeData() can just be used if you do not need to
    have different variation settings for different icons from different font families.
  */
  MaterialSymbolsBase.setOutlinedVariationDefaults(
    color: outlinedColor,
    fill: 0.0,
  );
  MaterialSymbolsBase.setRoundedVariationDefaults(
    color: roundedColor,
    fill: 0.0,
  );
  MaterialSymbolsBase.setSharpVariationDefaults(
    color: sharpColor,
    fill: 0.0,
  );

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
          seedColor: Colors.red,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      home: NavigationPage(
        title: 'Material Symbols Icons For Flutter',
        subtitle:
            '(v$materialSymbolsIconsSourceFontVersionNumber fonts, released $materialSymbolsIconsSourceReleaseDate w/ $totalMaterialSymbolsIcons icons)',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Widget> pages = [
    const SettingsPage(),
  ];

  final ScrollController _scrollController = ScrollController();

  List<IconData> iconList = [];
  List<String> iconNameList = [];

  String _iconSearchText = '';

  FontListType _fontListType = FontListType.outlined;

  /// icon font size
  double _iconFontSize = 48.0;

  /// possible fill values
  final List<double> _fillValues = [0.0, 1.0];

  /// default fill variation
  double _fillVariation = 0.0;

  /// possible weight values
  final List<double> _weightValues = [
    100.0,
    200.0,
    300.0,
    400.0,
    500.0,
    600.0,
    700.0
  ];

  /// default weight variation
  double _weightVariation = 400.0;

  /// possible grade values
  final List<double> _grades = [0.25, 0.0, 200.0];

  // default grade
  double _gradeVariation = 0.0;
  double _gradeSliderPos = 1;

  /// possible optical size values
  final List<double> _opticalSizes = [20.0, 24.0, 40.0, 48.0];

  // default optical size
  double _opticalSizeVariation = 48.0;
  double _opticalSliderPos = 3;

  void setQueryParametersToMatchState() {
    var uri = Uri.parse(window.location.href);

    uri = uri.replace(queryParameters: {
      'iconSearchText': _iconSearchText,
      'iconSize': _iconFontSize.toString(),
      'fontType': _fontListType.toString().replaceAll('FontListType.', ''),
      'fill': _fillVariation.toString(),
      'weight': _weightVariation.toString(),
      'grade': _gradeVariation.toString(),
      'opticalSize': _opticalSizeVariation.toString(),
    });
    String uriString = uri.toString();
    window.history.pushState(
      {'path': uriString},
      '',
      uriString,
    ); //window.location.href = uri.toString();
  }

  void grabInitialStateFromUrl() {
    // Get the query parameters from the URL (if we are a web app)
    final queryParms = Uri.base.queryParameters;
    _iconSearchText = queryParms['iconSearchText'] ?? '';
    if (queryParms['iconSize'] != null) {
      final iconSizeParse = double.tryParse(queryParms['iconSize']!);
      if (iconSizeParse != null) {
        if (iconSizeParse >= 22.0 && iconSizeParse <= 88.0) {
          _iconFontSize = iconSizeParse;
        }
      }
    }
    if (queryParms['fontType'] != null) {
      switch (queryParms['fontType']!.toLowerCase()) {
        case 'outlined':
          _fontListType = FontListType.outlined;
          break;
        case 'rounded':
          _fontListType = FontListType.rounded;
          break;
        case 'sharp':
          _fontListType = FontListType.sharp;
          break;
        case 'universal':
        default:
          _fontListType = FontListType.universal;
          break;
      }
    }
    if (queryParms['fill'] != null) {
      final fillParse = double.tryParse(queryParms['fill']!);
      if (fillParse != null) {
        if (_fillValues.contains(fillParse)) {
          _fillVariation = fillParse;
        }
      }
    }
    if (queryParms['weight'] != null) {
      final weightParse = double.tryParse(queryParms['weight']!);
      if (weightParse != null) {
        if (_weightValues.contains(weightParse)) {
          _weightVariation = weightParse;
        }
      }
    }
    if (queryParms['grade'] != null) {
      final gradeParse = double.tryParse(queryParms['grade']!);
      if (gradeParse != null) {
        if (_grades.contains(gradeParse)) {
          _gradeVariation = gradeParse;
          _gradeSliderPos = _grades.indexOf(_gradeVariation).toDouble();
        }
      }
    }
    if (queryParms['opticalSize'] != null) {
      final opticalParse = double.tryParse(queryParms['opticalSize']!);
      if (opticalParse != null) {
        if (_opticalSizes.contains(opticalParse)) {
          _opticalSizeVariation = opticalParse;
          _opticalSliderPos =
              _opticalSizes.indexOf(_opticalSizeVariation).toDouble();
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _onFontListTypeChange(_fontListType);

    // Fill in all possible state information from anything present in the URL
    grabInitialStateFromUrl();

    // set variation defaults to match state
    setAllVariationsSettings();

    // set the font lists to match [_fontListType] state
    _onFontListTypeChange(_fontListType);
  }

  void resetVariationSettings() {
    _fillVariation = 0.0;
    _weightVariation = 400.0;
    _gradeVariation = 0.0;
    _gradeSliderPos = _grades.indexOf(_gradeVariation).toDouble();
    _opticalSizeVariation = 48.0;
    _opticalSliderPos = _opticalSizes.indexOf(_opticalSizeVariation).toDouble();
    setAllVariationsSettings();
  }

  void setAllVariationsSettings() {
    MaterialSymbolsBase.setOutlinedVariationDefaults(
        color: outlinedColor,
        fill: _fillVariation,
        weight: _weightVariation,
        grade: _gradeVariation,
        opticalSize: _opticalSizeVariation);
    MaterialSymbolsBase.setRoundedVariationDefaults(
        color: roundedColor,
        fill: _fillVariation,
        weight: _weightVariation,
        grade: _gradeVariation,
        opticalSize: _opticalSizeVariation);
    MaterialSymbolsBase.setSharpVariationDefaults(
        color: sharpColor,
        fill: _fillVariation,
        weight: _weightVariation,
        grade: _gradeVariation,
        opticalSize: _opticalSizeVariation);
    // the the URL match the current state
    setQueryParametersToMatchState();
  }

  void _onFontListTypeChange(FontListType? val) {
    setState(() {
      _fontListType = val ?? FontListType.outlined;
      switch (_fontListType) {
        case FontListType.outlined:
          iconList = materialSymbolsOutlinedMap.values.toList();
          iconNameList = materialSymbolsOutlinedMap.keys.toList();
          break;
        case FontListType.rounded:
          iconList = materialSymbolsRoundedMap.values.toList();
          iconNameList = materialSymbolsRoundedMap.keys.toList();
          break;
        case FontListType.sharp:
          iconList = materialSymbolsSharpMap.values.toList();
          iconNameList = materialSymbolsSharpMap.keys.toList();
          break;
        case FontListType.universal:
          iconList = materialSymbolsMap.values.toList();
          iconNameList = materialSymbolsMap.keys.toList();
          break;
      }
    });
    setQueryParametersToMatchState();
  }

  bool? configPanelExpanded;

  List<int> searchIconNameList(String searchString) {
    List<int> matchIndices = [];
    searchString = searchString.toLowerCase();
    for (int i = 0; i < iconNameList.length; i++) {
      if (iconNameList[i].toLowerCase().contains(searchString)) {
        matchIndices.add(i);
      }
    }
    return matchIndices;
  }

  void setNewSearchText(String newSearchText) {
    setState(() {
      newSearchText = newSearchText.trim();

      _iconSearchText = newSearchText;

      setQueryParametersToMatchState();
    });
  }

  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final colors = Theme.of(context).colorScheme;
    List<int> matches = [];
    bool searchActive = false;
    if (_iconSearchText.isNotEmpty) {
      searchActive = true;
      matches = searchIconNameList(_iconSearchText);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Material Symbols Icons for Flutter"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () async {
            await launchUrl(
              Uri.parse(
                'https://github.com/google/material-design-icons/tree/master/variablefont',
              ),
            );
          },
          tooltip: widget.subtitle,
          icon: const Icon(Symbols.info_rounded),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await launchUrl(
                Uri.parse(
                  'https://pub.dev/packages/material_symbols_icons',
                ),
              );
            },
            icon: const Icon(Symbols.open_in_new_rounded),
          ),
          const SizedBox(width: 10),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
            icon: Icon(Symbols.recommend_rounded),
            label: 'Icons',
          ),
          NavigationDestination(
            icon: Icon(Symbols.settings),
            label: 'Settings',
          ),
        ],
        selectedIndex: currentPage,
        onDestinationSelected: (value) {
          setState(() {
            currentPage = value;
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        },
        tooltip: 'Scroll to top',
        child: const Icon(Symbols.arrow_upward),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text(
            'Material Symbols Icons (using above settings):',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: screenWidth > 500 ? 400 : screenWidth * 0.8,
              ),
              child: IconSearchStringInput(
                initialSearchText: _iconSearchText,
                onSearchTextChanged: setNewSearchText,
              ),
            ),
          ]),
          Expanded(
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Center(
                        child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          final iconName =
                              'Symbols.${searchActive ? iconNameList[matches[index]] : iconNameList[index]}';
                          Clipboard.setData(ClipboardData(text: iconName))
                              .then((_) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    'Copied "$iconName" to the clipboard.')));
                          });
                        },
                        child: Tooltip(
                          message:
                              'Symbols.${searchActive ? iconNameList[matches[index]] : iconNameList[index]}',
                          child: Column(children: [
                            VariedIcon.varied(
                              searchActive
                                  ? iconList[matches[index]]
                                  : iconList[index],
                              size: _iconFontSize,
                            ),
                            if (_iconFontSize <= 64) const SizedBox(height: 5),
                            if (_iconFontSize <= 64)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    4.0, 0.0, 4.0, 0.0),
                                child: Text(
                                  (searchActive
                                      ? iconNameList[matches[index]]
                                      : iconNameList[index]),
                                  style: const TextStyle(fontSize: 8),
                                  textAlign: TextAlign.center,
                                ),
                              )
                          ]),
                        ),
                      ),
                    )),
                    childCount:
                        searchActive ? matches.length : iconNameList.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 100,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(),
                  sliver: SliverToBoxAdapter(
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              'Browse Material Symbols Icons at fonts.google.com',
                              textAlign: TextAlign.left,
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 3,
                            ),
                            SizedBox.square(
                              dimension: 40,
                              child: IconButton.outlined(
                                color: Colors.grey,
                                onPressed: () {
                                  launchUrl(Uri.parse(
                                      'https://fonts.google.com/icons?icon.set=Material+Symbols'));
                                },
                                icon: const Icon(Symbols.open_in_new),
                                style: IconButton.styleFrom(
                                  foregroundColor: colors.onSecondaryContainer,
                                  backgroundColor: colors.secondaryContainer,
                                  disabledBackgroundColor:
                                      colors.onSurface.withOpacity(0.12),
                                  hoverColor: colors.onSecondaryContainer
                                      .withOpacity(0.08),
                                  focusColor: colors.onSecondaryContainer
                                      .withOpacity(0.12),
                                  highlightColor: colors.onSecondaryContainer
                                      .withOpacity(0.12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ), //sizedbox
        ],
      ),
    );
  }
}

class IconSearchStringInput extends StatefulWidget {
  const IconSearchStringInput(
      {super.key,
      this.initialSearchText = '',
      required this.onSearchTextChanged});

  final String initialSearchText;
  final ValueChanged<String> onSearchTextChanged;

  @override
  IconSearchStringInputState createState() => IconSearchStringInputState();
}

class IconSearchStringInputState extends State<IconSearchStringInput> {
  bool _isSearchFocused = false;
  late final TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController(text: widget.initialSearchText);
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      child: Focus(
        onFocusChange: (focus) {
          setState(() {
            _isSearchFocused = focus;
          });
        },
        child: TextFormField(
          controller: searchController,
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Symbols.search,
            ),
            label: const Text(
              'Search Material Symbol Icons',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            suffixIcon: _isSearchFocused
                ? IconButton(
                    icon: const Icon(Symbols.cancel),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      searchController.clear();
                      widget.onSearchTextChanged('');
                    },
                  )
                : null,
            hintText: 'Enter text to search for in icon names',
            hintStyle: const TextStyle(fontSize: 14.0),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
          ),
          onChanged: widget.onSearchTextChanged,
        ),
      ),
    );
  }
}
