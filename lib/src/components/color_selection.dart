import 'package:flutter/material.dart';

class ColorSelection extends StatelessWidget {
  final Color groupValue;
  final List<Color> colors;
  final Function(Color) onChange;

  const ColorSelection(
      {Key? key,
      required this.groupValue,
      required this.colors,
      required this.onChange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: colors
          .map((color) => GestureDetector(
                onTap: () => onChange(color),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    border: color == groupValue ? Border.all() : null,
                    color: color,
                  ),
                ),
              ))
          .toList(),
    );
  }
}
