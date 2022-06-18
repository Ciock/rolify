import 'package:audio_service/audio_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:rolify/data/audios.dart';
import 'package:rolify/entities/audio.dart';
import 'package:rolify/presentation_logic_holders/audio_edit_bloc/audio_edit_bloc.dart';
import 'package:rolify/presentation_logic_holders/audio_edit_bloc/audio_edit_event.dart';
import 'package:rolify/presentation_logic_holders/audio_handler.dart';
import 'package:rolify/presentation_logic_holders/audio_service_commands.dart';
import 'package:rolify/presentation_logic_holders/event_bus/stop_all_event_bus.dart';
import 'package:rolify/presentation_logic_holders/singletons/app_state.dart';
import 'package:rolify/src/components/button.dart';
import 'package:rolify/src/components/radio.dart';
import 'package:rolify/src/components/slider.dart';
import 'package:rolify/src/theme/texts.dart';
import 'package:rxdart/rxdart.dart';

import 'dropdown_image.dart';
import 'my_icons.dart';

class PlayerWidget extends StatefulWidget {
  final Audio audio;

  const PlayerWidget({Key? key, required this.audio}) : super(key: key);

  @override
  PlayerWidgetState createState() => PlayerWidgetState();
}

class PlayerWidgetState extends State<PlayerWidget> {
  final _volumeSubject = BehaviorSubject.seeded(0.5);
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

    audioImage = widget.audio.image;
    checkIfIsPlaying();
    checkVolume();
    checkLoop();
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
                    widget.audio.image = value;
                    AudioData.updateAudio(context, widget.audio);
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
              stream: _volumeSubject.stream,
              builder: (context, snapshot) => MySlider(
                style: MySliderStyle(
                  depth: -5.0,
                  accent: isPlaying
                      ? NeumorphicTheme.currentTheme(context).variantColor
                      : NeumorphicTheme.currentTheme(context)
                          .disabledColor
                          .withOpacity(0.5),
                  variant: isPlaying
                      ? NeumorphicTheme.currentTheme(context).accentColor
                      : NeumorphicTheme.currentTheme(context).disabledColor,
                ),
                min: 0.0,
                max: 1.0,
                height: 12,
                value: snapshot.data ?? 1.0,
                onChanged: (value) {
                  _volumeSubject.add(value);

                  AudioServiceCommands.setVolume(widget.audio, value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  toggleLoop(value) {
    setState(() {
      loopAudio = value;
    });
    AudioServiceCommands.setLoop(value, widget.audio);
  }

  Future<void> checkIfIsPlaying() async {
    bool newValue;
    try {
      newValue =
          await AudioService.customAction('is_playing', widget.audio.toJson());
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
    _volumeSubject.add(volume);
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
