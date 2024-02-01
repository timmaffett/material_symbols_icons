import 'package:example_using_material_symbols_icons/provider/icon_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class IconPage extends StatelessWidget {
  const IconPage({super.key});

  @override
  Widget build(BuildContext context) {
    final iconProvider = context.watch<IconProvider>();

    return Column(
      children: [
        Center(
          child: SearchAnchor.bar(
            barHintText: "Search icons...",
            suggestionsBuilder: (context, controller) {
              return [
                const Text("Searching..."),
              ];
            },
          ),
        ),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemCount: iconProvider.iconList.length,
            itemBuilder: (BuildContext context, int index) {
              return;
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
        //                         ? iconList[matches[index]]
        //                         : iconList[index],
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
