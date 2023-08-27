import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:rolify/entities/audio.dart';
import 'package:rolify/presentation_logic_holders/audio_list_bloc/audio_list_bloc.dart';
import 'package:rolify/presentation_logic_holders/audio_list_bloc/audio_list_state.dart';
import 'package:rolify/presentation_logic_holders/event_bus/stop_all_event_bus.dart';
import 'package:rolify/presentation_logic_holders/playing_sounds_singleton.dart';
import 'package:rolify/presentation_logic_holders/singletons/app_state.dart';
import 'package:rolify/root/info_page.dart';
import 'package:rolify/src/components/player_card.dart';

import 'all_sounds/global_controls.dart';
import 'all_sounds/search_bar.dart';

class SessionSounds extends StatefulWidget {
  const SessionSounds({Key? key}) : super(key: key);

  @override
  SessionSoundsState createState() => SessionSoundsState();
}

class SessionSoundsState extends State<SessionSounds>
    with WidgetsBindingObserver {
  List<Audio> filteredAudios = [];
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
          filteredAudios = PlayingSounds().playingAudios;
          pauseAll = audioToPauseExist;
        });
      }
    });
    eventBus.on<AudioPaused>().listen((event) {
      if (mounted) {
        setState(() {
          audioToPauseExist = PlayingSounds().playingAudios.isNotEmpty;
          audioToReplayExist = PlayingSounds().pausedAudios.isNotEmpty;
          filteredAudios = PlayingSounds().playingAudios;
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
    setState(() {
      filteredAudios = PlayingSounds().playingAudios;
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
                                    key: Key('${e.path}_session'), audio: e),
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
    final allAudios = PlayingSounds().playingAudios;

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

  void navigateToInfo() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const InfoPage()));
  }
}
