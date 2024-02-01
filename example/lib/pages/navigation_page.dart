import 'package:example_using_material_symbols_icons/pages/icon_page.dart';
import 'package:example_using_material_symbols_icons/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

class NavigationPage extends StatefulWidget {
  final String title;
  final String subtitle;

  const NavigationPage({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int currentPage = 0;
  List<Widget> pages = const [
    IconPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
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
      body: pages[currentPage],
    );
  }
}
