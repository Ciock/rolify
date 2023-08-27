import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:launch_review/launch_review.dart';

import '../../presentation_logic_holders/audio_service_commands.dart';
import '../../presentation_logic_holders/playing_sounds_singleton.dart';
import '../../presentation_logic_holders/singletons/app_state.dart';
import '../../src/components/audio_slider.dart';
import '../../src/components/button.dart';
import '../../src/components/my_icons.dart';
import '../../src/components/radio.dart';

class GlobalControls extends StatefulWidget {
  final bool pauseAll;
  final bool playPauseEnabled;
  final Function(bool value) setPauseAll;

  const GlobalControls({
    Key? key,
    required this.pauseAll,
    required this.playPauseEnabled,
    required this.setPauseAll,
  }) : super(key: key);

  @override
  State<GlobalControls> createState() => _GlobalControlsState();
}

class _GlobalControlsState extends State<GlobalControls> {
  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      curve: Curves.ease,
      style: NeumorphicStyle(
        boxShape: NeumorphicBoxShape.roundRect(
            const BorderRadius.all(Radius.circular(12.0))),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: 16.0 * heightFactor, horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: MyButton(
                        icon: MyIcons.star,
                        onTap: _openPlayStore,
                      ),
                    ),
                  ),
                ),
                MyRadio(
                    big: true,
                    icon: widget.pauseAll
                        ? MyIcons.pauseBig(
                            color: widget.playPauseEnabled
                                ? null
                                : NeumorphicTheme.currentTheme(context)
                                    .disabledColor)
                        : MyIcons.playBig(
                            color: widget.playPauseEnabled
                                ? null
                                : NeumorphicTheme.currentTheme(context)
                                    .disabledColor),
                    value: widget.pauseAll,
                    onChanged: (value) {
                      if (!widget.playPauseEnabled) return;

                      if (value) {
                        playAllSound();
                      } else {
                        pauseAllSound();
                      }
                      widget.setPauseAll(value);
                    }),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 14 * heightFactor),
            AudioSlider(
              isActive: true,
              value: PlayingSounds().masterVolume,
              onChanged: setMasterVolume,
            )
          ],
        ),
      ),
    );
  }

  _openPlayStore() {
    LaunchReview.launch(iOSAppId: '1511308478');
  }

  void playAllSound() async {
    final pausedAudios = PlayingSounds().pausedAudios.toList();
    for (final audio in pausedAudios) {
      PlayingSounds().replayAudio(audio);
      AudioServiceCommands.play(audio);
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  void pauseAllSound() async {
    final playingAudios = PlayingSounds().playingAudios.toList();
    for (final audio in playingAudios) {
      PlayingSounds().pauseAudio(audio);
      AudioServiceCommands.stop(audio);
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  void setMasterVolume(double value) async {
    setState(() {
      PlayingSounds().masterVolume = value;
    });

    final playingAudios = PlayingSounds().playingAudios;
    for (final audio in playingAudios) {
      AudioServiceCommands.setVolume(
          audio, audio.volume * PlayingSounds().masterVolume,
          global: true);
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }
}
