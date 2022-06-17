import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:rolify/presentation_logic_holders/audio_edit_bloc/audio_edit_bloc.dart';
import 'package:rolify/presentation_logic_holders/audio_edit_bloc/audio_edit_state.dart';
import 'package:rolify/presentation_logic_holders/singletons/app_state.dart';
import 'package:rolify/root/info_page.dart';
import 'package:rolify/root/sound_edit.dart';
import 'package:rolify/src/components/my_icons.dart';
import 'package:rolify/src/components/radio.dart';
import 'package:rolify/src/theme/texts.dart';

import 'all_playlist.dart';
import 'all_sound.dart';

const Title = ['Sounds', 'Playlists', 'Rolify', 'Edit Sound'];

class Base extends StatefulWidget {
  @override
  _BaseState createState() => _BaseState();
}

class _BaseState extends State<Base> {
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
                    Expanded(child: MyText.title(Title[pageSelected])),
                    SizedBox(width: 8.0),
                    MyRadio(
                      value: pageSelected == 0,
                      onChanged: pageSelected <= 2 ? showSoundPage : null,
                      icon: MyIcons.list(color: _getIconColor(context, 0)),
                    ),
                    SizedBox(width: 8.0),
                    MyRadio(
                      value: pageSelected == 1,
                      onChanged: pageSelected <= 2 ? showPlaylistPage : null,
                      icon: MyIcons.playlist(color: _getIconColor(context, 1)),
                    ),
                    SizedBox(width: 8.0),
                    MyRadio(
                      value: pageSelected == 2,
                      onChanged: pageSelected <= 2 ? showInfoPage : null,
                      icon: MyIcons.about(color: _getIconColor(context, 2)),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 16.0,
              ),
              Expanded(
                  child: IndexedStack(
                index: pageSelected,
                children: <Widget>[
                  AllSound(),
                  AllPlaylist(),
                  InfoPage(),
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
    if (pageSelected > 2)
      return NeumorphicTheme.currentTheme(context).disabledColor;
    if (pageSelected == pageNumber)
      return NeumorphicTheme.currentTheme(context).accentColor;
    return null;
  }

  void handleAudioEditing(BuildContext context, state) {
    if (state is AudioEditing) {
      previousPage = pageSelected;
      changePage(3);
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

  showPlaylistPage(bool value) {
    if (value) {
      changePage(1);
    }
  }

  showInfoPage(bool value) {
    if (value) {
      changePage(2);
    }
  }

  changePage(int? page) {
    if (page != null)
      setState(() {
        pageSelected = page;
      });
  }
}
