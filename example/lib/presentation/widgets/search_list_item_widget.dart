import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchListItem extends StatelessWidget {
  final String iconName;
  final IconData iconData;

  const SearchListItem({
    super.key,
    required this.iconName,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: InkWell(
        onTap: () {
          Clipboard.setData(
            ClipboardData(text: "Symbols.$iconName"),
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Copied "Symbols.$iconName" to the clipboard.',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(iconData),
              const SizedBox(width: 10),
              Text(iconName),
            ],
          ),
        ),
      ),
    );
  }
}
