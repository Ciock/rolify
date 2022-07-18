import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rolify/data/audios.dart';
import 'package:rolify/entities/audio.dart';
import 'package:rolify/presentation_logic_holders/audio_edit_bloc/audio_edit_bloc.dart';
import 'package:rolify/presentation_logic_holders/audio_edit_bloc/audio_edit_event.dart';
import 'package:rolify/presentation_logic_holders/audio_handler.dart';
import 'package:rolify/presentation_logic_holders/audio_service_commands.dart';
import 'package:rolify/presentation_logic_holders/event_bus/stop_all_event_bus.dart';
import 'package:rolify/presentation_logic_holders/singletons/app_state.dart';
import 'package:rolify/src/components/audio_slider.dart';
import 'package:rolify/src/components/button.dart';
import 'package:rolify/src/components/radio.dart';
import 'package:rolify/src/components/slider.dart';
import 'package:rolify/src/theme/texts.dart';

import '../../presentation_logic_holders/playing_sounds_singleton.dart';
import 'dropdown_image.dart';
import 'my_icons.dart';

class PlayerWidget extends StatefulWidget {
  final Audio audio;

  const PlayerWidget({Key? key, required this.audio}) : super(key: key);

  @override
  PlayerWidgetState createState() => PlayerWidgetState();
}

class PlayerWidgetState extends State<PlayerWidget> {
  final _volumeController = StreamController<double>();
  late String audioImage;
  bool loopAudio = true, isPlaying = false;

  @override
  void initState() {
    super.initState();
    eventBus.on<OnAppResume>().listen((event) {
      checkIfIsPlaying();
    });
    eventBus.on<AudioPlayed>().listen((event) {
      if (event.path == widget.audio.path && mounted) {
        setState(() {
          isPlaying = true;
        });
      }
    });
    eventBus.on<AudioPaused>().listen((event) {
      if (event.path == widget.audio.path && mounted) {
        setState(() {
          isPlaying = false;
        });
      }
    });
    eventBus.on<ToggleLoop>().listen((event) {
      if (event.path == widget.audio.path && mounted) {
        setState(() {
          loopAudio = event.value;
        });
      }
    });
    AppState().audioHandler.customEvent.listen((event) {
      if (event['name'] == AudioCustomEvents.pauseAll ||
          (event['name'] == AudioCustomEvents.audioEnded &&
              event['audioPath'] == widget.audio.path)) {
        setState(() {
          isPlaying = false;
        });
      }
    });

    loopAudio = widget.audio.loopMode == LoopMode.one;
    _volumeController.add(widget.audio.volume);
    audioImage = widget.audio.image;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.symmetric(
            vertical: 16.0 * heightFactor, horizontal: 8.0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                DropdownImage(
                  value: audioImage,
                  onChanged: (String? value) {
                    if (value == null) return;
                    setState(() {
                      audioImage = value;
                    });
                    AudioData.updateAudio(
                        context, widget.audio.copyFrom(image: value),
                        refresh: false);
                  },
                ),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: MyText.body(
                            widget.audio.name,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      MyRadio(
                        icon: MyIcons.loop(
                            color: loopAudio
                                ? NeumorphicTheme.currentTheme(context)
                                    .accentColor
                                : null),
                        value: loopAudio,
                        onChanged: toggleLoop,
                      ),
                      const SizedBox(width: 8.0),
                      MyRadio(
                        icon: isPlaying ? MyIcons.pause : MyIcons.play,
                        value: isPlaying,
                        onChanged: (_) {
                          if (isPlaying) {
                            stop();
                          } else {
                            play();
                          }
                        },
                      ),
                      const SizedBox(width: 8.0),
                      MyButton(
                        icon: MyIcons.edit,
                        onTap: () => BlocProvider.of<AudioEditBloc>(context)
                            .add(EnableEditing(context, widget.audio)),
                      )
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            StreamBuilder<double>(
              stream: _volumeController.stream,
              builder: (context, snapshot) => AudioSlider(
                isActive: isPlaying,
                value: snapshot.data ?? 0,
                onChanged: (value) {
                  setVolume(context, value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void setVolume(BuildContext context, double value) {
    _volumeController.add(value);
    AudioServiceCommands.setVolume(
        widget.audio, value * PlayingSounds().masterVolume);
        
    final updatedAudio = widget.audio.copyFrom(volume: value);
    PlayingSounds().updateAudio(updatedAudio);
    AudioData.updateAudio(context, updatedAudio, refresh: false);
  }

  toggleLoop(value) {
    setState(() {
      loopAudio = value;
    });
    AudioServiceCommands.setLoop(value, widget.audio);
    AudioData.updateAudio(context,
        widget.audio.copyFrom(loopMode: value ? LoopMode.one : LoopMode.off),
        refresh: false);
  }

  Future<void> checkIfIsPlaying() async {
    bool newValue;
    try {
      newValue = await AudioServiceCommands.getPlaying(widget.audio);
    } catch (e) {
      newValue = false;
    }
    if (newValue != isPlaying) {
      isPlaying = newValue;
      if (mounted) setState(() {});
    }
  }

  Future<void> checkVolume() async {
    double volume = await AudioServiceCommands.getVolume(widget.audio);
    _volumeController.add(volume);
  }

  Future<void> checkLoop() async {
    bool isLoop = await AudioServiceCommands.getLoop(widget.audio);
    loopAudio = isLoop;
    if (mounted) {
      setState(() {});
    }
  }

  void stop() {
    AudioServiceCommands.stop(widget.audio);
  }

  Future<void> play() async {
    AudioServiceCommands.play(widget.audio);
  }
}
