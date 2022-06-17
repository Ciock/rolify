import 'dart:async';

import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:rolify/entities/audio.dart';
import 'package:rolify/src/theme/texts.dart';

class AutoScrollText  extends StatefulWidget{
  final List<Audio> audios;

  const AutoScrollText({Key? key, required this.audios}) : super(key: key);
  @override
  _AutoScrollTextState createState() => _AutoScrollTextState();
}

class _AutoScrollTextState extends State<AutoScrollText> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(milliseconds: 1000), (timer) {
      if (mounted) {
        _scrollController.animateTo(_scrollController.offset + 20,
            duration: Duration(milliseconds: 1000), curve: Curves.linear);
      } else {
        timer.cancel();
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    final text = getCaptionText();
    return Container(
      height: 18,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => MyText.caption(
          text,
          fontWeight: FontWeight.w500,
          color: NeumorphicTheme.currentTheme(context)
              .disabledColor,
        ),
      ),
    );
  }

  String getCaptionText() {
    if(widget.audios == null || widget.audios.isEmpty){
      return '';
    }
    String ret = '';
    String sep = ' • ';
    for (Audio audio in widget.audios) {
      ret += audio.name + sep;
    }
    return ret.substring(0, ret.length - 3) + '   |   ';
  }
}