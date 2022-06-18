import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:rolify/data/playlist.dart';
import 'package:rolify/entities/audio.dart';
import 'package:rolify/entities/playlist.dart';
import 'package:rolify/src/components/auto_scroll_text.dart';
import 'package:rolify/src/components/button.dart';
import 'package:rolify/src/components/my_icons.dart';
import 'package:rolify/src/components/text_field.dart';
import 'package:rolify/src/theme/texts.dart';

class AddSoundToPlaylist extends StatefulWidget {
  final Audio audio;

  const AddSoundToPlaylist({Key? key, required this.audio}) : super(key: key);

  @override
  _AddSoundToPlaylistState createState() => _AddSoundToPlaylistState();
}

class _AddSoundToPlaylistState extends State<AddSoundToPlaylist> {
  final newPlaylistNameController = TextEditingController();
  List<Playlist>? playlists;

  @override
  void initState() {
    super.initState();
    initPlaylist();
  }

  void initPlaylist() {
    PlaylistData.getAllPlaylist().then((value) {
      setState(() {
        playlists = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeumorphicTheme.currentTheme(context).baseColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Neumorphic(
            style: NeumorphicStyle(
              boxShape: NeumorphicBoxShape.roundRect(
                  BorderRadius.all(Radius.circular(16.0))),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(child: MyText.title('Add to playlist')),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: MyIcons.close(),
                          )
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: MyTextField(
                              controller: newPlaylistNameController,
                              hintText: 'Create a new playlist...',
                            ),
                          ),
                          SizedBox(width: 12.0),
                          MyButton(icon: MyIcons.done, onTap: savePlaylist),
                        ],
                      ),
                    ],
                  ),
                ),
                if (playlists != null)
                  Expanded(
                    child: ListView.separated(
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.all(16.0),
                      itemCount: playlists!.length,
                      itemBuilder: (context, index) => _PlaylistRow(
                        playlist: playlists![index],
                        currentAudio: widget.audio,
                        onAdd: () => addSoundToPlaylist(playlists![index]),
                        onRemove: () =>
                            removeSoundFromPlaylist(playlists![index]),
                      ),
                      separatorBuilder: (BuildContext context, int index) =>
                          SizedBox(
                        height: 16.0,
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  savePlaylist() {
    PlaylistData.savePlaylist(
        context,
        Playlist(
          name: newPlaylistNameController.text,
          audios: [widget.audio],
        )).then((_) {
      initPlaylist();
      newPlaylistNameController.clear();
    });
  }

  addSoundToPlaylist(Playlist playlist) {
    playlist.audios.add(widget.audio);

    PlaylistData.savePlaylist(context, playlist).then((_) {
      initPlaylist();
    });
  }

  removeSoundFromPlaylist(Playlist playlist) {
    playlist.audios.remove(widget.audio);

    PlaylistData.savePlaylist(context, playlist).then((_) {
      initPlaylist();
    });
  }
}

class _PlaylistRow extends StatelessWidget {
  const _PlaylistRow({
    Key? key,
    required this.playlist,
    required this.currentAudio,
    required this.onAdd,
    required this.onRemove,
  }) : super(key: key);

  final Playlist playlist;
  final Audio currentAudio;
  final Function() onAdd, onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MyText.body(
                playlist.name,
                fontWeight: FontWeight.w500,
              ),
              ScrollText(
                audios: playlist.audios,
              ),
            ],
          ),
        ),
        SizedBox(
          width: 16.0,
        ),
        MyButton(
          icon: playlist.audios.contains(currentAudio)
              ? MyIcons.playlist_delete
              : MyIcons.playlist_add,
          onTap: playlist.audios.contains(currentAudio) ? onRemove : onAdd,
        ),
      ],
    );
  }
}
