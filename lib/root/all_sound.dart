import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:launch_review/launch_review.dart';
import 'package:rolify/data/audios.dart';
import 'package:rolify/data/event_trackers/firebase_analytics.dart';
import 'package:rolify/entities/audio.dart';
import 'package:rolify/presentation_logic_holders/audio_list_bloc/audio_list_bloc.dart';
import 'package:rolify/presentation_logic_holders/audio_list_bloc/audio_list_state.dart';
import 'package:rolify/presentation_logic_holders/audio_service_commands.dart';
import 'package:rolify/presentation_logic_holders/event_bus/stop_all_event_bus.dart';
import 'package:rolify/presentation_logic_holders/playing_sounds_singleton.dart';
import 'package:rolify/presentation_logic_holders/singletons/app_state.dart';
import 'package:rolify/root/info_page.dart';
import 'package:rolify/src/components/button.dart';
import 'package:rolify/src/components/my_icons.dart';
import 'package:rolify/src/components/player_card.dart';
import 'package:rolify/src/components/radio.dart';
import 'package:rolify/src/theme/texts.dart';
import 'package:url_launcher/url_launcher.dart';

class AllSound extends StatefulWidget {
  @override
  _AllSoundState createState() => _AllSoundState();
}

class _AllSoundState extends State<AllSound> with WidgetsBindingObserver {
  List<Audio> audios = [], filteredAudios = [];
  TextEditingController filterController = TextEditingController();
  FocusNode focusNode = FocusNode();
  bool pauseAll = true, audioToPauseExist = false, audioToReplayExist = false;

  bool get playPauseEnabled =>
      (pauseAll && audioToPauseExist) ||
      (pauseAll == false && audioToReplayExist);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    eventBus.on<AudioPlayed>().listen((event) {
      if (mounted)
        setState(() {
          audioToPauseExist = PlayingSounds().playingAudios.isNotEmpty;
          audioToReplayExist = PlayingSounds().pausedAudios.isNotEmpty;
          pauseAll = audioToPauseExist;
        });
    });
    eventBus.on<AudioPaused>().listen((event) {
      if (mounted)
        setState(() {
          audioToPauseExist = PlayingSounds().playingAudios.isNotEmpty;
          audioToReplayExist = PlayingSounds().pausedAudios.isNotEmpty;
          pauseAll = audioToPauseExist;
        });
    });
    initAudios();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      eventBus.fire(OnAppResume());
    }
  }

  @override
  dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> initAudios() async {
    await AudioData.addNewAssetsAudios(context);
    final allAudios = await AudioData.getAllAudios();
    allAudios
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    setState(() {
      audios = allAudios;
      filteredAudios = allAudios;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AudioListBloc, AudioListState>(
      listener: (BuildContext context, state) {
        if (state is AudioListEdited) initAudios();
      },
      child: Stack(
        children: <Widget>[
          Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0),
              child: Column(
                children: <Widget>[
                  Container(
                    height: 56 * heightFactor,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Neumorphic(
                              style: NeumorphicStyle(
                                depth: -5.0,
                                boxShape: NeumorphicBoxShape.roundRect(
                                    BorderRadius.all(Radius.circular(20.0))),
                              ),
                              padding: EdgeInsets.only(left: 16.0, right: 16.0),
                              child: Container(
                                height: 40 * heightFactor,
                                child: Row(
                                  children: <Widget>[
                                    filterController.text != ''
                                        ? GestureDetector(
                                            onTap: () =>
                                                resetTextFilter(context),
                                            child: MyIcons.close(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary),
                                          )
                                        : GestureDetector(
                                            onTap: () {
                                              focusNode.requestFocus();
                                              setState(() {});
                                            },
                                            child: MyIcons.search(
                                              color: focusNode.hasFocus
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .secondary
                                                  : NeumorphicTheme
                                                          .currentTheme(context)
                                                      .disabledColor,
                                            )),
                                    SizedBox(
                                      width: 8.0,
                                    ),
                                    Expanded(
                                      child: TextField(
                                        controller: filterController,
                                        focusNode: focusNode,
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: 'Search a sound...',
                                            hintStyle: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16 * heightFactor,
                                                fontFamily: 'Inter-Regular',
                                                color: NeumorphicTheme
                                                        .currentTheme(context)
                                                    .disabledColor)),
                                        onChanged: (text) {
                                          if (text == '') {
                                            resetTextFilter(context);
                                          } else {
                                            filterAudios(context);
                                          }
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 16.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.0),
                          MyButton(
                            icon: MyIcons.add,
                            onTap: () => _openFileExplorer(context),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.only(bottom: 148),
                      physics: BouncingScrollPhysics(),
                      children: [
                        Wrap(
                          children: filteredAudios
                              .map(
                                (e) => PlayerWidget(key: Key(e.path), audio: e),
                              )
                              .toList(),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: 16.0 * heightFactor, horizontal: 16.0),
              child: Container(
                height: 133 * heightFactor,
                child: Neumorphic(
                  curve: Curves.ease,
                  style: NeumorphicStyle(
                    boxShape: NeumorphicBoxShape.roundRect(
                        BorderRadius.all(Radius.circular(12.0))),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: 16.0 * heightFactor, horizontal: 16.0),
                    child: Column(
                      children: <Widget>[
                        MyText.body(
                          'Manage all the sounds',
                          textType: TextType.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                        SizedBox(height: 14 * heightFactor),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
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
                                icon: pauseAll
                                    ? MyIcons.pauseBig(
                                        color: playPauseEnabled
                                            ? null
                                            : NeumorphicTheme.currentTheme(
                                                    context)
                                                .disabledColor)
                                    : MyIcons.playBig(
                                        color: playPauseEnabled
                                            ? null
                                            : NeumorphicTheme.currentTheme(
                                                    context)
                                                .disabledColor),
                                value: pauseAll,
                                onChanged: (value) {
                                  if (!playPauseEnabled) return;

                                  if (value) {
                                    playAllSound();
                                  } else {
                                    pauseAllSound();
                                  }
                                  setState(() {
                                    pauseAll = value;
                                  });
                                }),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: AppState().isDonationEnabled
                                      ? MyButton(
                                          icon: MyIcons.love,
                                          onTap: _goToTipeee,
                                        )
                                      : Container(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void resetTextFilter(BuildContext context) {
    focusNode.unfocus();
    filterController.clear();
    filterAudios(context);
  }

  filterAudios(BuildContext context) async {
    final allAudios = await AudioData.getAllAudios();

    List<Audio> newFilteredAudios = allAudios;
    if (filterController.text != '') {
      newFilteredAudios =
          filterAudiosByText(newFilteredAudios, filterController.text);
    }
    newFilteredAudios
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    setState(() {
      filteredAudios = newFilteredAudios;
    });
  }

  filterAudiosByText(List<Audio> audios, String text) {
    return audios
        .where((audio) => audio.name.toLowerCase().contains(text.toLowerCase()))
        .toList();
  }

  void _openFileExplorer(BuildContext context) async {
    FirebaseEventHandler.sendEvent('audio_add_click');
    List<PlatformFile>? _paths;
    try {
      final result =
          await FilePicker.platform.pickFiles(type: FileType.audio);
      _paths = result?.files;
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    }
    if (!mounted || _paths == null) return;
    FirebaseEventHandler.sendEvent(
        'audios_added', {'number_of_audios': _paths.length});
    final allAudios = await AudioData.getAllAudios();
    _paths.forEach((file) {
      final name = file.name.replaceAll('_', ' ').replaceAll('.mp3', '');
      final audio = Audio(
          name: name,
          path: file.path ?? '',
          audioSource: LocalAudioSource.file);
      if (allAudios.contains(audio) == false) {
        allAudios.add(audio);
      }
    });
    AudioData.saveAllAudios(context, allAudios).then((value) {
      resetTextFilter(context);
    });
  }

  void navigateToInfo() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => InfoPage()));
  }

  void playAllSound() async {
    final pausedAudios = PlayingSounds().pausedAudios.toList();
    for (final audio in pausedAudios) {
      PlayingSounds().replayAudio(audio);
      AudioServiceCommands.play(audio);
      await Future.delayed(Duration(milliseconds: 100));
    }
  }

  void pauseAllSound() async {
    final playingAudios = PlayingSounds().playingAudios.toList();
    for (final audio in playingAudios) {
      PlayingSounds().pauseAudio(audio);
      AudioServiceCommands.stop(audio);
      await Future.delayed(Duration(milliseconds: 100));
    }
  }

  _goToTipeee() async {
    const url = 'https://en.tipeee.com/luca-oropallo/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _openPlayStore() {
    LaunchReview.launch(iOSAppId: '1511308478');
  }
}
