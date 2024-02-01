import 'package:example_using_material_symbols_icons/extensions/theme_extension.dart';
import 'package:example_using_material_symbols_icons/models/font_list_type_model.dart';
import 'package:example_using_material_symbols_icons/provider/icon_provider.dart';
import 'package:example_using_material_symbols_icons/widgets/style_choice_widget.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final iconProvider = context.watch<IconProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    "Style:",
                    style: context.textTheme.titleLarge,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StyleChoiceWidget(
                            title: "Outlined",
                            color: Colors.red,
                            value: FontListType.outlined,
                            groupValue: iconProvider.fontListType,
                            onChanged: iconProvider.onFontListTypeChange,
                          ),
                          StyleChoiceWidget(
                            title: "Rounded",
                            color: Colors.blue,
                            value: FontListType.rounded,
                            groupValue: iconProvider.fontListType,
                            onChanged: iconProvider.onFontListTypeChange,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StyleChoiceWidget(
                            title: "Sharp",
                            color: Colors.teal,
                            value: FontListType.sharp,
                            groupValue: iconProvider.fontListType,
                            onChanged: iconProvider.onFontListTypeChange,
                          ),
                          StyleChoiceWidget(
                            title: "All",
                            color: context.colorScheme.onBackground,
                            value: FontListType.universal,
                            groupValue: iconProvider.fontListType,
                            onChanged: iconProvider.onFontListTypeChange,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Icon size: ${iconProvider.iconFontSize}",
                        style: context.textTheme.titleMedium,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: Slider(
                          min: 20.0,
                          max: 88.0,
                          divisions: 34,
                          value: iconProvider.iconFontSize,
                          onChanged: (value) {
                            iconProvider.iconFontSize =
                                value.round().toDouble();

                            iconProvider.setAllVariationsSettings();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 25),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        "Customize Variation Settings:",
                        style: context.textTheme.titleLarge,
                      ),
                      IconButton(
                        onPressed: () {
                          iconProvider.resetVariationSettings();
                        },
                        tooltip: "Set default",
                        icon: const Icon(Symbols.restart_alt),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: () async {
                                  await launchUrl(
                                    Uri.parse(
                                      "https://m3.material.io/styles/icons/applying-icons#ebb3ae7d-d274-4a25-9356-436e82084f1f",
                                    ),
                                  );
                                },
                                icon: const Icon(Symbols.info_rounded),
                              ),
                              const SizedBox(width: 10),
                              Text("Fill: $iconProvider.fillVariation"),
                              Slider(
                                min: 0.0,
                                max: 1.0,
                                divisions: 10,
                                value: iconProvider.fillVariation,
                                onChanged: (value) {
                                  iconProvider.fillVariation = value.toDouble();
                                  iconProvider.setAllVariationsSettings();
                                },
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () async {
                                  await launchUrl(
                                    Uri.parse(
                                      "https://m3.material.io/styles/icons/applying-icons#3ad55207-1cb0-43af-8092-fad2762f69f7",
                                    ),
                                  );
                                },
                                icon: const Icon(Symbols.info_rounded),
                              ),
                              const SizedBox(width: 10),
                              Text("Grade: ${iconProvider.gradeVariation}"),
                              Slider(
                                min: 0.0,
                                max: 2.0,
                                divisions: 2,
                                value: iconProvider.gradeSliderPos,
                                onChanged: (value) {
                                  iconProvider.gradeSliderPos =
                                      value.round().toDouble();
                                  iconProvider.gradeVariation =
                                      iconProvider.grades[
                                          iconProvider.gradeSliderPos.round()];
                                  iconProvider.setAllVariationsSettings();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: () async {
                                  await launchUrl(
                                    Uri.parse(
                                      "https://m3.material.io/styles/icons/applying-icons#d7f45762-67ac-473d-95b0-9214c791e242",
                                    ),
                                  );
                                },
                                icon: const Icon(Symbols.info_rounded),
                              ),
                              const SizedBox(width: 10),
                              Text("Weight: ${iconProvider.weightVariation}"),
                              Slider(
                                min: 100.0,
                                max: 700.0,
                                divisions: 6,
                                value: iconProvider.weightVariation,
                                onChanged: (value) {
                                  double rv = value / 100.0;
                                  value = rv.round().toDouble() * 100.0;
                                  iconProvider.weightVariation =
                                      value.round().toDouble();
                                  iconProvider.setAllVariationsSettings();
                                },
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () async {
                                  await launchUrl(
                                    Uri.parse(
                                      "https://m3.material.io/styles/icons/applying-icons#b41cbc01-9b49-4a44-a525-d153d1ea1425",
                                    ),
                                  );
                                },
                                icon: const Icon(Symbols.info_rounded),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                  "Optical Size: ${iconProvider.opticalSizeVariation}px"),
                              Slider(
                                min: 0.0,
                                max: 3.0,
                                divisions: 3,
                                value: iconProvider.opticalSliderPos.toDouble(),
                                onChanged: (value) {
                                  iconProvider.opticalSliderPos =
                                      value.round().toDouble();
                                  iconProvider.opticalSizeVariation =
                                      iconProvider.opticalSizes[iconProvider
                                          .opticalSliderPos
                                          .round()];
                                  iconProvider.setAllVariationsSettings();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
