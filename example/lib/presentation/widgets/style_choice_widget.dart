import 'package:example_using_material_symbols_icons/models/font_list_type_model.dart';
import 'package:flutter/material.dart';

class StyleChoiceWidget extends StatelessWidget {
  final String title;
  final FontListType value;
  final FontListType groupValue;
  final void Function(FontListType?)? onChanged;
  final Color color;

  const StyleChoiceWidget({
    super.key,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Row(
        children: [
          Radio(
            fillColor: MaterialStatePropertyAll(color),
            overlayColor: MaterialStatePropertyAll(color.withOpacity(0.1)),
            value: value,
            groupValue: groupValue,
            onChanged: onChanged,
          ),
          Text(title),
        ],
      ),
    );
  }
}
