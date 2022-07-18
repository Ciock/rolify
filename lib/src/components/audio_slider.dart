import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:rolify/src/components/slider.dart';

class AudioSlider extends StatelessWidget {
  final bool isActive;
  final double value;
  final void Function(double value)? onChanged;

  const AudioSlider(
      {Key? key, this.isActive = false, this.value = 0, this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) => MySlider(
        style: MySliderStyle(
          depth: -5.0,
          accent: isActive
              ? NeumorphicTheme.currentTheme(context).variantColor
              : NeumorphicTheme.currentTheme(context)
                  .disabledColor
                  .withOpacity(0.5),
          variant: isActive
              ? NeumorphicTheme.currentTheme(context).accentColor
              : NeumorphicTheme.currentTheme(context).disabledColor,
        ),
        min: 0.0,
        max: 1.0,
        height: 12,
        value: value,
        onChanged: onChanged,
      );
}
