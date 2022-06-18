import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:rolify/presentation_logic_holders/singletons/app_state.dart';

enum TextType { primary, secondary, disabled }

class MyText extends StatelessWidget {
  final String text;
  final String? path2, fontFamily;
  final TextType textType;
  final double? height, fontSize;
  final Color? color;
  final FontWeight fontWeight;
  final TextOverflow? textOverflow;
  final TextAlign? textAlign;
  final TextDecoration? textDecoration;

  const MyText(
    this.text, {
    Key? key,
    this.path2,
    this.textType = TextType.primary,
    this.fontFamily,
    this.height,
    this.fontSize,
    this.color,
    this.fontWeight = FontWeight.normal,
    this.textOverflow,
    this.textAlign,
    this.textDecoration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      overflow: textOverflow,
      textAlign: textAlign,
      style: TextStyle(
        height: height,
        fontSize: fontSize,
        fontFamily: fontFamily,
        fontWeight: fontWeight,
        decoration: textDecoration,
        color: color ?? getTextColor(context, textType),
      ),
    );
  }

  Color getTextColor(BuildContext context, TextType textType) {
    if (NeumorphicTheme.of(context)!.isUsingDark) {
      return textType == TextType.primary
          ? Colors.white
          : NeumorphicTheme.currentTheme(context).disabledColor;
    } else {
      return textType == TextType.primary
          ? Colors.black
          : NeumorphicTheme.currentTheme(context).disabledColor;
    }
  }

  factory MyText.title(
    text, {
    Key? key,
    String? path2,
    TextType textType = TextType.primary,
    TextAlign? textAlign,
  }) {
    return MyText(
      text,
      path2: path2,
      textType: textType,
      height: 40 / 32,
      fontFamily: 'Inter-Regular',
      fontSize: 32 * heightFactor,
      textAlign: textAlign,
      fontWeight: FontWeight.bold,
    );
  }

  factory MyText.subtitle(
    text, {
    Key? key,
    String? path2,
    TextType textType = TextType.primary,
    TextOverflow? textOverflow,
  }) {
    return MyText(
      text,
      path2: path2,
      textType: textType,
      height: 1.58,
      fontFamily: 'Inter-Regular',
      fontSize: 24 * heightFactor,
      fontWeight: FontWeight.bold,
      textOverflow: textOverflow,
    );
  }

  factory MyText.button(
    text, {
    Key? key,
    String? path2,
    TextType textType = TextType.primary,
    Color? color,
    TextOverflow? textOverflow,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return MyText(
      text,
      path2: path2,
      textType: textType,
      color: color,
      height: 1.56,
      fontFamily: 'Inter-Regular',
      fontSize: 18 * heightFactor,
      textOverflow: textOverflow,
      fontWeight: fontWeight,
    );
  }

  factory MyText.input(
    text, {
    Key? key,
    String? path2,
    TextType textType = TextType.primary,
    Color? color,
  }) {
    return MyText(
      text,
      path2: path2,
      textType: textType,
      height: 24 / 18,
      fontFamily: 'Rubik',
      fontSize: 18 * heightFactor,
      color: color,
    );
  }

  factory MyText.body(
    text, {
    Key? key,
    String? path2,
    TextType textType = TextType.primary,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    TextAlign? textAlign,
    TextDecoration? textDecoration,
    TextOverflow? textOverflow,
  }) {
    return MyText(
      text,
      path2: path2,
      textType: textType,
      height: 1.38,
      fontFamily: 'Rubik',
      fontSize: 16 * heightFactor,
      fontWeight: fontWeight,
      color: color,
      textAlign: textAlign,
      textDecoration: textDecoration,
      textOverflow: textOverflow,
    );
  }

  factory MyText.caption(
    text, {
    Key? key,
    String? path2,
    TextType textType = TextType.primary,
    Color? color,
    FontWeight fontWeight = FontWeight.normal,
    TextOverflow? textOverflow,
    TextDecoration? textDecoration,
  }) {
    return MyText(
      text,
      path2: path2,
      textType: textType,
      height: 18 / 14,
      fontFamily: 'Rubik',
      fontSize: 14 * heightFactor,
      fontWeight: fontWeight,
      color: color,
      textDecoration: textDecoration,
      textOverflow: textOverflow,
    );
  }

  factory MyText.small(text,
      {Key? key,
      String? path2,
      TextType textType = TextType.primary,
      FontWeight fontWeight = FontWeight.normal,
      Color? color,
      TextDecoration? textDecoration}) {
    return MyText(
      text,
      path2: path2,
      textType: textType,
      height: 1.33,
      fontFamily: 'Rubik',
      fontSize: 12 * heightFactor,
      fontWeight: fontWeight,
      color: color,
      textDecoration: textDecoration,
    );
  }
}
