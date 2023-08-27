import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:rolify/presentation_logic_holders/audio_edit_bloc/audio_edit_bloc.dart';
import 'package:rolify/presentation_logic_holders/audio_edit_bloc/audio_edit_state.dart';
import 'package:rolify/presentation_logic_holders/singletons/app_state.dart';
import 'package:rolify/root/info_page.dart';
import 'package:rolify/root/session_sounds.dart';
import 'package:rolify/root/sound_edit.dart';
import 'package:rolify/src/components/my_icons.dart';
import 'package:rolify/src/components/radio.dart';
import 'package:rolify/src/theme/texts.dart';

import 'all_playlist.dart';
import 'all_sounds/all_sound.dart';

const titles = ['Sounds', 'Session', 'Playlists', 'Rolify', 'Edit Sound'];

class Base extends StatefulWidget {
  const Base({Key? key}) : super(key: key);

  @override
  BaseState createState() => BaseState();
}

class BaseState extends State<Base> {
  int pageSelected = 0;
  int? previousPage;

  @override
  Widget build(BuildContext context) {
    AppState().deviceHeight = MediaQuery.of(context).size.height *
        MediaQuery.of(context).devicePixelRatio;
    AppState().deviceWidth = MediaQuery.of(context).size.width *
        MediaQuery.of(context).devicePixelRatio;
    return BlocListener<AudioEditBloc, AudioEditState>(
      listener: handleAudioEditing,
      child: Scaffold(
        backgroundColor: NeumorphicTheme.currentTheme(context).baseColor,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.only(top: 24.0, left: 24.0, right: 24.0),
                child: Row(
                  children: <Widget>[
                    Expanded(child: MyText.title(titles[pageSelected])),
                    const SizedBox(width: 8.0),
                    MyRadio(
                      value: pageSelected == 0,
                      onChanged: pageSelected <= 3 ? showSoundPage : null,
                      icon: MyIcons.list(color: _getIconColor(context, 0)),
                    ),
                    const SizedBox(width: 8.0),
                    MyRadio(
                      value: pageSelected == 1,
                      onChanged:
                          pageSelected <= 3 ? showSessionSoundPage : null,
                      icon: MyIcons.play(color: _getIconColor(context, 1)),
                    ),
                    const SizedBox(width: 8.0),
                    MyRadio(
                      value: pageSelected == 2,
                      onChanged: pageSelected <= 3 ? showPlaylistPage : null,
                      icon: MyIcons.playlist(color: _getIconColor(context, 2)),
                    ),
                    const SizedBox(width: 8.0),
                    MyRadio(
                      value: pageSelected == 3,
                      onChanged: pageSelected <= 3 ? showInfoPage : null,
                      icon: MyIcons.about(color: _getIconColor(context, 3)),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 16.0,
              ),
              Expanded(
                  child: IndexedStack(
                index: pageSelected,
                children: <Widget>[
                  const AllSound(),
                  const SessionSounds(),
                  const AllPlaylist(),
                  const InfoPage(),
                  SoundEdit(),
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }

  Color? _getIconColor(BuildContext context, int pageNumber) {
    if (pageSelected > 3) {
      return NeumorphicTheme.currentTheme(context).disabledColor;
    }
    if (pageSelected == pageNumber) {
      return NeumorphicTheme.currentTheme(context).accentColor;
    }
    return null;
  }

  void handleAudioEditing(BuildContext context, state) {
    if (state is AudioEditing) {
      previousPage = pageSelected;
      changePage(4);
    }
    if (state is NoEditing && previousPage != null) {
      changePage(previousPage);
    }
  }

  showSoundPage(bool value) {
    if (value) {
      changePage(0);
    }
  }

  showSessionSoundPage(bool value) {
    if (value) {
      changePage(1);
    }
  }

  showPlaylistPage(bool value) {
    if (value) {
      changePage(2);
    }
  }

  showInfoPage(bool value) {
    if (value) {
      changePage(3);
    }
  }

  changePage(int? page) {
    if (page != null) {
      setState(() {
        pageSelected = page;
      });
    }
  }
}
