import 'package:flutter/material.dart';
import 'package:rolify/src/images/images.dart';

const _height = 48.0;

class DropdownImage extends StatelessWidget {
  final String value;
  final Function(String?)? onChanged;

  const DropdownImage({Key? key, required this.value, this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      hint: Container(),
      underline: Container(),
      icon: Container(),
      itemHeight: _height,
      value: value,
      onChanged: onChanged,
      selectedItemBuilder: (context) => assetImages.map((String image) {
        return DefaultTextStyle(
          style: const TextStyle(),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(4.0)),
            child: Image.asset(
              image,
              height: _height,
              width: _height,
              fit: BoxFit.cover,
            ),
          ),
        );
      }).toList(),
      items: assetImages.map((String image) {
        return DropdownMenuItem<String>(
          value: image,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(4.0)),
              child: Image.asset(
                image,
                height: _height,
                width: _height,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
