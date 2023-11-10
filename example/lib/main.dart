import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:splittable_flexible_row/splittable_flexible_row.dart';
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

const String materialSymbolsIconsSourceFontVersionNumber = '2.709';  // must update for each new font update
int totalMaterialSymbolsIcons=0;

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
      color: outlinedColor, fill: 0.0);
  MaterialSymbolsBase.setRoundedVariationDefaults(
      color: roundedColor, fill: 0.0);
  MaterialSymbolsBase.setSharpVariationDefaults(color: sharpColor, fill: 0.0);

  totalMaterialSymbolsIcons = (materialSymbolsMap.length / 3).floor();

  if (useDevicePreview) {
    //TEST various on various device screens//
    runApp(DevicePreview(
      builder: (context) => const MyApp(), // Wrap your app
      enabled: true,
    ));
  } else {
    runApp(const MyApp());
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
        primarySwatch: Colors.teal,
        useMaterial3: true,
        fontFamily: 'Roboto',
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      home: MyHomePage(title: 'Material Symbols Icons For Flutter', subtitle:'(v$materialSymbolsIconsSourceFontVersionNumber fonts w/ $totalMaterialSymbolsIcons icons)'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title,  required this.subtitle});

  final String title;
  final String subtitle;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

enum FontListType { outlined, rounded, sharp, universal }

class _MyHomePageState extends State<MyHomePage> {
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
    window.history.pushState({'path': uriString}, '',
        uriString); //window.location.href = uri.toString();
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

  List<Widget> buildFlexibleOptionsCustomizationPanel(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    Splittable.splitWidth = 400;
    var willSplitRows = Splittable.willSplitRows(context);
    final bool useExpandPanel = willSplitRows || (size.height < 500);
    // if we are going to use the expand panel because short then FORCE split
    if (useExpandPanel && !willSplitRows) willSplitRows = true;

    // we set the initial value of configPanelExpanded depending on
    // how we initially have to render it.  If we don't initially have
    // to split the rows then we will init it to 'expanded', that way if the
    // window shrinks and we are forced to use it it will already be expanded,
    // (as it is when it is NOT rendered in a panel)
    configPanelExpanded ??= !useExpandPanel;

    final mainAxisAlignment =
        willSplitRows ? MainAxisAlignment.start : MainAxisAlignment.center;
    final controlPanelItems = <Widget>[
      ...Splittable.flexibleRow(
        context: context,
        forceSplit: screenWidth <= 600,
        splitAtIndicesByWidth: {
          300: [0, 2, 4, 6],
          600: [0, 4],
        },
        splitWidgetBehavior: SplitWidgetBehavior.includeInThisRow,
        mainAxisAlignment: mainAxisAlignment,
        children: <Widget>[
          const Text(
            'Style :',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          Radio<FontListType>(
            value: FontListType.outlined,
            groupValue: _fontListType,
            onChanged: _onFontListTypeChange,
          ),
          const Text(
            'Outlined',
            style: TextStyle(fontSize: 16.0, color: outlinedColor),
          ),
          Radio<FontListType>(
            value: FontListType.rounded,
            groupValue: _fontListType,
            onChanged: _onFontListTypeChange,
          ),
          const Text(
            'Rounded',
            style: TextStyle(fontSize: 16.0, color: roundedColor),
          ),
          Radio<FontListType>(
            value: FontListType.sharp,
            groupValue: _fontListType,
            onChanged: _onFontListTypeChange,
          ),
          const Text(
            'Sharp',
            style: TextStyle(fontSize: 16.0, color: sharpColor),
          ),
          Radio<FontListType>(
            value: FontListType.universal,
            groupValue: _fontListType,
            onChanged: _onFontListTypeChange,
          ),
          Text(
            screenWidth > 400
                ? 'Universal set (all 3 w/suffixes)'
                : 'Universal set',
            style: const TextStyle(
              fontSize: 16.0,
            ),
          ),
        ],
      ),
      ...Splittable.flexibleRow(
        context: context,
        splitAtIndicesByWidth: {
          300: [0, 1],
        },
        forceSplit: screenWidth < 600,
        splitWidgetBehavior: SplitWidgetBehavior.includeInNextRow,
        mainAxisAlignment: mainAxisAlignment,
        children: <Widget>[
          Text(
            screenWidth > 400 ? 'Icon size: ${_iconFontSize}px' : 'Icon size:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          Slider(
            min: 20.0,
            max: 88.0,
            divisions: 34,
            value: _iconFontSize,
            onChanged: (value) {
              setState(() {
                _iconFontSize = value.round().toDouble();
                setAllVariationsSettings();
              });
            },
          ),
        ],
      ),
      ...Splittable.flexibleRow(
        context: context,
        splitEveryN: 1,
        forceSplit: screenWidth < 300,
        splitWidgetBehavior: SplitWidgetBehavior.includeInNextRow,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          const Text(
            'Customize Variation Settings:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          SizedBox.square(
            dimension: 40,
            child: IconButton(
              onPressed: () {
                setState(() {
                  resetVariationSettings();
                });
              },
              //icon: const Icon(Icons.feed),
              icon: const Icon(Symbols.restart_alt),
              style: IconButton.styleFrom(
                foregroundColor: colors.onSecondaryContainer,
                disabledBackgroundColor: colors.onSurface.withOpacity(0.12),
                hoverColor: colors.onSecondaryContainer.withOpacity(0.08),
                focusColor: colors.onSecondaryContainer.withOpacity(0.12),
                highlightColor: colors.onSecondaryContainer.withOpacity(0.12),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      ...Splittable.flexibleRow(
        context: context,
        splitAtIndicesByWidth: {
          500: [1, 3, 5, 7],
          700: [2, 4],
        },
        splitWidgetBehavior: SplitWidgetBehavior.includeInThisRow,
        mainAxisAlignment: mainAxisAlignment,
        children: <Widget>[
          Text(
            screenWidth > 400 ? 'Fill: $_fillVariation' : 'Fill:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          Slider(
            min: 0.0,
            max: 1.0,
            divisions: 1,
            value: _fillVariation,
            onChanged: (value) {
              setState(() {
                _fillVariation = value.round().toDouble();
                setAllVariationsSettings();
              });
            },
          ),
          Text(
            screenWidth > 400 ? 'Weight: $_weightVariation' : 'Weight:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          Slider(
            min: 100.0,
            max: 700.0,
            divisions: 6,
            value: _weightVariation,
            onChanged: (value) {
              setState(() {
                double rv = value / 100.0;
                value = rv.round().toDouble() * 100.0;
                _weightVariation = value.round().toDouble();
                setAllVariationsSettings();
              });
            },
          ),
        ],
      ),
      ...Splittable.flexibleRow(
        context: context,
        splitAtIndicesByWidth: {
          500: [1, 3, 5, 7],
          700: [2, 4],
        },
        splitWidgetBehavior: SplitWidgetBehavior.includeInThisRow,
        mainAxisAlignment: mainAxisAlignment,
        children: <Widget>[
          Text(
            screenWidth > 400 ? 'Grade: $_gradeVariation' : 'Grade:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          Slider(
            min: 0.0,
            max: 2.0,
            divisions: 2,
            value: _gradeSliderPos,
            onChanged: (value) {
              setState(() {
                _gradeSliderPos = value.round().toDouble();
                _gradeVariation = _grades[_gradeSliderPos.round()];
                setAllVariationsSettings();
              });
            },
          ),
          Text(
            screenWidth > 400
                ? 'Optical Size: ${_opticalSizeVariation}px'
                : 'OpticalSize:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          Slider(
            min: 0.0,
            max: 3.0,
            divisions: 3,
            value: _opticalSliderPos.toDouble(),
            onChanged: (value) {
              setState(() {
                _opticalSliderPos = value.round().toDouble();
                _opticalSizeVariation =
                    _opticalSizes[_opticalSliderPos.round()];
                setAllVariationsSettings();
              });
            },
          ),
        ],
      ),
      Center(
          child: Text(
              'Fill: $_fillVariation Weight: $_weightVariation Grade: $_gradeVariation Optical Size: $_opticalSizeVariation ',
              style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16))),
      const SizedBox(width: 30),
      if (!willSplitRows)
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(height: 2, color: Colors.black),
        ),
    ];

    final controlPanelColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        ...controlPanelItems,
      ],
    );

    // Return either the control panel widgets directly or place them in a
    // ExpansionPanelList/ExpansionPanel.
    return [
      if (!useExpandPanel) ...[
        const SizedBox(height: 12),
        const Text(
          'Style & Variation settings : ',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
          ),
        ),
        const SizedBox(height: 12),
      ],
      !useExpandPanel
          ? controlPanelColumn
          : ExpansionPanelList(
              animationDuration: const Duration(milliseconds: 500),
              expandIconColor: Colors.green,
              expandedHeaderPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              elevation: 1,
              children: [
                ExpansionPanel(
                  backgroundColor: const Color.fromARGB(255, 220, 220, 220),
                  body: Container(
                    padding: const EdgeInsets.fromLTRB(20, 8, 10, 0),
                    child: controlPanelColumn,
                  ),
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return Container(
                      color: Colors.teal,
                      padding: const EdgeInsets.fromLTRB(20.0, 14.0, 6.0, 0),
                      child: const Text(
                        'Style & Variation settings : ',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                        ),
                      ),
                    );
                  },
                  isExpanded: configPanelExpanded!,
                  canTapOnHeader: true,
                ),
              ],
              expansionCallback: (int item, bool status) {
                setState(() {
                  configPanelExpanded = !configPanelExpanded!;
                });
              },
            ),
      const SizedBox(height: 12),
    ];
  }

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
        toolbarHeight: 22,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            RichText(
              text: TextSpan( text: widget.title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
                children: [ TextSpan(text: '   ${widget.subtitle}', style: const TextStyle(color: Colors.blue, fontSize: 12)) ], 
              )
            ),
            SizedBox.square(
              dimension: 40,
              child: IconButton(
                color: Colors.blue,
                onPressed: () {
                  launchUrl(Uri.parse(
                      'https://pub.dev/packages/material_symbols_icons'));
                },
                icon: const Icon(Symbols.open_in_new),
              ),
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: viewportConstraints.maxHeight,
          ),
          child: IntrinsicHeight(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 5.0, 12.0, 5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ...buildFlexibleOptionsCustomizationPanel(context),
                  const Text(
                    'Material Symbols Icons (using above settings):',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth:
                                screenWidth > 500 ? 400 : screenWidth * 0.8,
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
                                    Clipboard.setData(
                                            ClipboardData(text: iconName))
                                        .then((_) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
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
                                      if (_iconFontSize <= 64)
                                        const SizedBox(height: 5),
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
                              childCount: searchActive
                                  ? matches.length
                                  : iconNameList.length,
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 100,
                            )),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      'Browse Material Symbols Icons at fonts.google.com',
                                      textAlign: TextAlign.left,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
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
                                          foregroundColor:
                                              colors.onSecondaryContainer,
                                          backgroundColor:
                                              colors.secondaryContainer,
                                          disabledBackgroundColor: colors
                                              .onSurface
                                              .withOpacity(0.12),
                                          hoverColor: colors
                                              .onSecondaryContainer
                                              .withOpacity(0.08),
                                          focusColor: colors
                                              .onSecondaryContainer
                                              .withOpacity(0.12),
                                          highlightColor: colors
                                              .onSecondaryContainer
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
            ),
          ),
        );
      }),
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
