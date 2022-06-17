import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:rolify/presentation_logic_holders/singletons/app_state.dart';

class MyRadio extends StatelessWidget {
  final bool value, big;
  final Function(bool value)? onChanged;
  final Widget icon;

  MyRadio({
    this.value = false,
    this.onChanged,
    required this.icon,
    this.big = false,
  });

  double get size => big ? 64.0 : 40.0;

  double get iconSize => big ? 40.0 : 24.0;

  EdgeInsets get padding => EdgeInsets.all((size - iconSize) / 2);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size * heightFactor,
      width: size * heightFactor,
      child: NeumorphicRadio<bool>(
          style: NeumorphicRadioStyle(boxShape: NeumorphicBoxShape.circle()),
          padding: EdgeInsets.all((size - iconSize) / 2),
          value: true,
          groupValue: value,
          onChanged: (value) {
            if (onChanged != null) onChanged!(value ?? false);
          },
          child: icon),
    );
  }

  Color getIconColor(BuildContext context) {
    if (onChanged == null) {
      return NeumorphicTheme.currentTheme(context).disabledColor;
    }
    if (value) {
      return NeumorphicTheme.currentTheme(context).accentColor;
    }
    return NeumorphicTheme.isUsingDark(context) ? Colors.white : Colors.black;
  }
}
