import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:rolify/presentation_logic_holders/singletons/app_state.dart';

class MyButton extends StatelessWidget {
  final bool big;
  final Function()? onTap;
  final Widget? icon;

  const MyButton({Key? key, this.onTap, this.icon, this.big = false})
      : super(key: key);

  double get size => big ? 64.0 : 40.0;
  double get iconSize => big ? 40.0 : 24.0;
  EdgeInsets get padding => EdgeInsets.all((size - iconSize) / 2);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size * heightFactor,
      width: size * heightFactor,
      child: Center(
        child: NeumorphicButton(
          padding: padding,
          onPressed: onTap,
          style: NeumorphicStyle(
            boxShape: const NeumorphicBoxShape.circle(),
            shadowLightColor: Colors.white.withOpacity(0.7),
          ),
          child: icon,
          //onPressed: stopAll,
        ),
      ),
    );
  }
}
