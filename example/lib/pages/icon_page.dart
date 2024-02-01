import 'package:example_using_material_symbols_icons/provider/icon_provider.dart';
import 'package:example_using_material_symbols_icons/widgets/icon_container_widget.dart';
import 'package:example_using_material_symbols_icons/widgets/search_list_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class IconPage extends StatelessWidget {
  const IconPage({super.key});

  @override
  Widget build(BuildContext context) {
    final iconProvider = context.watch<IconProvider>();

    return Column(
      children: [
        const SizedBox(height: 10),
        Center(
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
        const SizedBox(height: 15),
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width ~/ 100,
            ),
            itemCount: iconProvider.icons.length,
            itemBuilder: (BuildContext context, int index) {
              final element = iconProvider.icons.entries.elementAt(index);

              final iconName = element.key;
              final icon = element.value;

              return IconContainer(
                iconName: iconName,
                icon: icon,
                opticalSize: iconProvider.opticalSizeVariation,
              );
            },
          ),
        ),
      ],
    );
  }
}
