import 'dart:async';

import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:rolify/entities/playlist.dart';
import 'package:rolify/presentation_logic_holders/audio_service_commands.dart';
import 'package:rolify/presentation_logic_holders/singletons/app_state.dart';
import 'package:rolify/root/edit_playlist.dart';
import 'package:rolify/src/components/button.dart';
import 'package:rolify/src/components/player_card.dart';
import 'package:rolify/src/components/radio.dart';
import 'package:rolify/src/theme/texts.dart';

import 'auto_scroll_text.dart';
import 'my_icons.dart';

class PlaylistCard extends StatefulWidget {
  final Playlist playlist;

  const PlaylistCard({Key? key, required this.playlist}) : super(key: key);

  @override
  _PlaylistCardState createState() => _PlaylistCardState();
}

class _PlaylistCardState extends State<PlaylistCard> {
  final duration = Duration(milliseconds: 500);
  bool isPlaying = false, expanded = false, showAudioList = false;

  double get maxHeight =>
      MediaQuery.of(context).size.height -
      MediaQuery.of(context).padding.top -
      160;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 500),
      child: AnimatedContainer(
        duration: duration,
        curve: Curves.ease,
        height: expanded ? maxHeight : 170,
        child: Neumorphic(
          style: NeumorphicStyle(
            boxShape: NeumorphicBoxShape.roundRect(
              BorderRadius.all(
                Radius.circular(16.0),
              ),
            ),
          ),
          padding: const EdgeInsets.only(
              top: 16.0, left: 16.0, right: 16.0, bottom: 8.0),
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            MyText.body(
                              widget.playlist.name,
                              fontWeight: FontWeight.w500,
                            ),
                            AutoScrollText(
                              audios: widget.playlist.audios,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.0),
                      MyButton(
                        icon: MyIcons.edit,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    EditPlaylist(playlist: widget.playlist))),
                      ),
                    ],
                  ),
                  if (showAudioList)
                    Expanded(
                      child: ListView(
                        physics: BouncingScrollPhysics(),
                        padding: EdgeInsets.only(bottom: 100),
                        children: widget.playlist.audios
                            .map(
                                (e) => PlayerWidget(key: Key(e.path), audio: e))
                            .toList(),
                      ),
                    ),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 96 * heightFactor,
                  child: Neumorphic(
                    duration: duration,
                    curve: Curves.ease,
                    style: NeumorphicStyle(
                      disableDepth: !expanded,
                      boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.all(Radius.circular(12.0))),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(child: Container()),
                          MyRadio(
                            big: true,
                            icon: isPlaying
                                ? MyIcons.pauseBig()
                                : MyIcons.playBig(),
                            value: isPlaying,
                            onChanged: (value) {
                              if (value) {
                                playAllSoundInPlaylist();
                              } else {
                                stopAllSoundInPlaylist();
                              }
                              setState(() {
                                isPlaying = value;
                              });
                            },
                          ),
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: MyRadio(
                                icon: MyIcons.playlistList(
                                    color: expanded
                                        ? NeumorphicTheme.currentTheme(context)
                                            .accentColor
                                        : null),
                                value: expanded,
                                onChanged: (bool value) {
                                  if (value) {
                                    setState(() {
                                      expanded = true;
                                      showAudioList = true;
                                    });
                                  } else {
                                    setState(() {
                                      expanded = false;
                                    });

                                    Future.delayed(duration).then((_) {
                                      setState(() {
                                        showAudioList = false;
                                      });
                                    });
                                  }
                                },
                              ),
                            ),
                          ))
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void playAllSoundInPlaylist() async {
    for (final audio in widget.playlist.audios) {
      AudioServiceCommands.play(audio);
      await Future.delayed(Duration(milliseconds: 100));
    }
  }

  void stopAllSoundInPlaylist() async {
    for (final audio in widget.playlist.audios) {
      AudioServiceCommands.stop(audio);
      await Future.delayed(Duration(milliseconds: 100));
    }
  }
}
