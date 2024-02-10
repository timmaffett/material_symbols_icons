import 'package:example_using_material_symbols_icons/presentation/widgets/option_menu.dart';
import 'package:example_using_material_symbols_icons/provider/icon_provider.dart';
import 'package:example_using_material_symbols_icons/presentation/widgets/icon_container_widget.dart';
import 'package:example_using_material_symbols_icons/presentation/widgets/search_list_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class IconPage extends StatefulWidget {
  final String title;
  final String subtitle;

  const IconPage({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  State<IconPage> createState() => _IconPageState();
}

class _IconPageState extends State<IconPage> {
  bool optionMenuToggled = true;

  @override
  Widget build(BuildContext context) {
    final iconProvider = context.watch<IconProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
            tooltip: "Visit pub.dev",
            icon: const Icon(Symbols.open_in_new_rounded),
          ),
          const SizedBox(width: 10),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            optionMenuToggled = !optionMenuToggled;
          });
        },
        label: const Text("Options"),
        icon: Icon(
          optionMenuToggled ? Symbols.menu_open_rounded : Symbols.menu_rounded,
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SearchAnchor.bar(
                barHintText: "Search icons...",
                suggestionsBuilder: (context, controller) {
                  return iconProvider.icons.entries
                      .where((element) => element.key.toLowerCase().contains(
                            controller.text.toLowerCase(),
                          ))
                      .map(
                    (icon) {
                      return SearchListItem(
                        iconName: icon.key,
                        iconData: icon.value,
                      );
                    },
                  ).toList();
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              "Fill: ${iconProvider.fillVariation} | Weight: ${iconProvider.weightVariation} | Grade: ${iconProvider.gradeVariation} | Optical Size: ${iconProvider.opticalSizeVariation}",
            ),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width ~/
                          (optionMenuToggled ? 200 : 120),
                    ),
                    itemCount: iconProvider.icons.length,
                    itemBuilder: (BuildContext context, int index) {
                      final element =
                          iconProvider.icons.entries.elementAt(index);

                      final iconName = element.key;
                      final icon = element.value;

                      return IconContainer(
                        iconName: iconName,
                        icon: Icon(
                          icon,
                          color: getIconColor(iconName),
                          fill: iconProvider.fillVariation,
                          weight: iconProvider.weightVariation,
                          grade: iconProvider.gradeVariation,
                          opticalSize: iconProvider.opticalSizeVariation,
                          size: 50,
                        ),
                      );
                    },
                  ),
                ),
                OptionMenu(isToggled: optionMenuToggled),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color getIconColor(String iconName) {
    if (iconName.contains("rounded")) {
      return Colors.blue;
    }
    if (iconName.contains("sharp")) {
      return Colors.teal;
    }

    return Colors.red;
  }
}
