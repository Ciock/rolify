import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final Function(String text)? onChanged;

  const MyTextField(
      {Key? key,
      this.controller,
      this.focusNode,
      this.hintText,
      this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      style: NeumorphicStyle(
        depth: -5.0,
        boxShape: NeumorphicBoxShape.roundRect(
            BorderRadius.all(Radius.circular(20.0))),
      ),
      padding: EdgeInsets.only(left: 16.0, right: 16.0),
      child: Container(
        height: 40,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter-Regular',
                  color: NeumorphicTheme.currentTheme(context).disabledColor)),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
