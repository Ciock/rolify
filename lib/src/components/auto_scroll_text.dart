import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:rolify/entities/audio.dart';
import 'package:rolify/src/theme/texts.dart';

class ScrollText extends StatelessWidget {
  final List<Audio> audios;

  const ScrollText({super.key, required this.audios});

  @override
  Widget build(BuildContext context) {
    final text = getCaptionText();
    return SizedBox(
      height: 18,
      child: ListView(
        padding: const EdgeInsets.only(right: 48),
        scrollDirection: Axis.horizontal,
        children: [
          MyText.caption(
            text,
            fontWeight: FontWeight.w500,
            color: NeumorphicTheme.currentTheme(context).disabledColor,
          ),
        ],
      ),
    );
  }

  String getCaptionText() {
    if (audios.isEmpty) {
      return '';
    }
    String ret = '';
    String sep = ' • ';
    for (Audio audio in audios) {
      ret += audio.name + sep;
    }
    return ret.substring(0, ret.length - 3);
  }
}
