import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:rolify/data/audios.dart';
import 'package:rolify/entities/audio.dart';
import 'package:rolify/presentation_logic_holders/audio_list_bloc/audio_list_bloc.dart';
import 'package:rolify/presentation_logic_holders/audio_list_bloc/audio_list_state.dart';
import 'package:rolify/presentation_logic_holders/event_bus/stop_all_event_bus.dart';
import 'package:rolify/presentation_logic_holders/playing_sounds_singleton.dart';
import 'package:rolify/presentation_logic_holders/singletons/app_state.dart';
import 'package:rolify/root/info_page.dart';
import 'package:rolify/src/components/button.dart';
import 'package:rolify/src/components/my_icons.dart';
import 'package:rolify/src/components/player_card.dart';

import 'search_bar.dart';
import 'global_controls.dart';

class AllSound extends StatefulWidget {
  const AllSound({Key? key}) : super(key: key);

  @override
  AllSoundState createState() => AllSoundState();
}

class AllSoundState extends State<AllSound> with WidgetsBindingObserver {
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
      if (mounted) {
        setState(() {
          audioToPauseExist = PlayingSounds().playingAudios.isNotEmpty;
          audioToReplayExist = PlayingSounds().pausedAudios.isNotEmpty;
          pauseAll = audioToPauseExist;
        });
      }
    });
    eventBus.on<AudioPaused>().listen((event) {
      if (mounted) {
        setState(() {
          audioToPauseExist = PlayingSounds().playingAudios.isNotEmpty;
          audioToReplayExist = PlayingSounds().pausedAudios.isNotEmpty;
          pauseAll = audioToPauseExist;
        });
      }
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
                  SizedBox(
                    height: 56 * heightFactor,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Row(
                        children: <Widget>[
                          MySearchBar(
                            filterController: filterController,
                            focusNode: focusNode,
                            filterAudios: filterAudios,
                            resetTextFilter: resetTextFilter,
                          ),
                          const SizedBox(width: 8.0),
                          MyButton(
                            icon: MyIcons.add,
                            onTap: () => _openFileExplorer(context),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 148),
                        physics: const BouncingScrollPhysics(),
                        child: Wrap(
                          children: filteredAudios
                              .map(
                                (e) => PlayerWidget(
                                    key: Key('${e.path}_all_sounds'), audio: e),
                              )
                              .toList(),
                        )),
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
              child: GlobalControls(
                  pauseAll: pauseAll,
                  playPauseEnabled: playPauseEnabled,
                  setPauseAll: (value) {
                    setState(() {
                      pauseAll = value;
                    });
                  }),
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
    List<PlatformFile>? paths;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: Theme.of(context).platform == TargetPlatform.android
            ? FileType.audio
            : FileType.any,
        allowMultiple: true,
      );
      paths = result?.files;
    } on PlatformException catch (e) {
      debugPrint("Unsupported operation $e");
    }
    if (!mounted || paths == null) return;
    final allAudios = await AudioData.getAllAudios();
    for (var file in paths) {
      final name = file.name.replaceAll('_', ' ').replaceAll('.mp3', '');
      final audio = Audio(
        name: name,
        path: file.path ?? '',
        audioSource: LocalAudioSource.file,
      );
      if (allAudios.contains(audio) == false) {
        allAudios.add(audio);
      }
    }
    AudioData.saveAllAudios(context, allAudios).then((value) {
      resetTextFilter(context);
    });
  }

  void navigateToInfo() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const InfoPage()));
  }
}
