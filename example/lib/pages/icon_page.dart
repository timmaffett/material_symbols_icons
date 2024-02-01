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
        // Expanded(
        //   child: CustomScrollView(
        //     controller: _scrollController,
        //     slivers: [
        //       SliverGrid(
        //         delegate: SliverChildBuilderDelegate(
        //           (context, index) => Center(
        //               child: MouseRegion(
        //             cursor: SystemMouseCursors.click,
        //             child: GestureDetector(
        //               onTap: () {
        //                 final iconName =
        //                     'Symbols.${searchActive ? iconNameList[matches[index]] : iconNameList[index]}';
        //                 Clipboard.setData(ClipboardData(text: iconName))
        //                     .then((_) {
        //                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        //                       content: Text(
        //                           'Copied "$iconName" to the clipboard.')));
        //                 });
        //               },
        //               child: Tooltip(
        //                 message:
        //                     'Symbols.${searchActive ? iconNameList[matches[index]] : iconNameList[index]}',
        //                 child: Column(children: [
        //                   VariedIcon.varied(
        //                     searchActive
        //                         ? icons[matches[index]]
        //                         : icons[index],
        //                     size: _iconFontSize,
        //                   ),
        //                   if (_iconFontSize <= 64) const SizedBox(height: 5),
        //                   if (_iconFontSize <= 64)
        //                     Padding(
        //                       padding:
        //                           const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 0.0),
        //                       child: Text(
        //                         (searchActive
        //                             ? iconNameList[matches[index]]
        //                             : iconNameList[index]),
        //                         style: const TextStyle(fontSize: 8),
        //                         textAlign: TextAlign.center,
        //                       ),
        //                     )
        //                 ]),
        //               ),
        //             ),
        //           )),
        //           childCount:
        //               searchActive ? matches.length : iconNameList.length,
        //         ),
        //         gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        //           maxCrossAxisExtent: 100,
        //         ),
        //       ),
        //       SliverPadding(
        //         padding: const EdgeInsets.symmetric(),
        //         sliver: SliverToBoxAdapter(
        //           child: Card(
        //             margin: const EdgeInsets.symmetric(
        //               horizontal: 12,
        //               vertical: 12,
        //             ),
        //             child: Padding(
        //               padding: const EdgeInsets.symmetric(
        //                   horizontal: 12, vertical: 12),
        //               child: Row(
        //                 mainAxisAlignment: MainAxisAlignment.spaceAround,
        //                 children: [
        //                   Text(
        //                     'Browse Material Symbols Icons at fonts.google.com',
        //                     textAlign: TextAlign.left,
        //                     style: Theme.of(context).textTheme.bodyMedium,
        //                     maxLines: 3,
        //                   ),
        //                   SizedBox.square(
        //                     dimension: 40,
        //                     child: IconButton.outlined(
        //                       color: Colors.grey,
        //                       onPressed: () {
        //                         launchUrl(Uri.parse(
        //                             'https://fonts.google.com/icons?icon.set=Material+Symbols'));
        //                       },
        //                       icon: const Icon(Symbols.open_in_new),
        //                       style: IconButton.styleFrom(
        //                         foregroundColor: colors.onSecondaryContainer,
        //                         backgroundColor: colors.secondaryContainer,
        //                         disabledBackgroundColor:
        //                             colors.onSurface.withOpacity(0.12),
        //                         hoverColor: colors.onSecondaryContainer
        //                             .withOpacity(0.08),
        //                         focusColor: colors.onSecondaryContainer
        //                             .withOpacity(0.12),
        //                         highlightColor: colors.onSecondaryContainer
        //                             .withOpacity(0.12),
        //                       ),
        //                     ),
        //                   ),
        //                 ],
        //               ),
        //             ),
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ), //sizedbox
      ],
    );
  }
}
