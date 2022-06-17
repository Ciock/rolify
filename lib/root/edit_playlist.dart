import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:rolify/data/audios.dart';
import 'package:rolify/data/playlist.dart';
import 'package:rolify/entities/audio.dart';
import 'package:rolify/entities/playlist.dart';
import 'package:rolify/src/components/button.dart';
import 'package:rolify/src/components/my_icons.dart';
import 'package:rolify/src/components/text_field.dart';
import 'package:rolify/src/theme/texts.dart';

class EditPlaylist extends StatefulWidget {
  final Playlist playlist;

  const EditPlaylist({Key? key, required this.playlist}) : super(key: key);

  @override
  _EditPlaylistState createState() => _EditPlaylistState();
}

class _EditPlaylistState extends State<EditPlaylist> {
  final playlistNameController = TextEditingController();
  List<Audio>? audios;

  @override
  void initState() {
    super.initState();
    initAudios();
    playlistNameController.text = widget.playlist.name;
  }

  initAudios() {
    AudioData.getAllAudios().then((value) {
      setState(() {
        audios = value;
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
                          Expanded(child: MyText.title('Edit playlist')),
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
                              controller: playlistNameController,
                              hintText: 'Create a new playlist...',
                            ),
                          ),
                          SizedBox(width: 12.0),
                          MyButton(icon: MyIcons.done, onTap: savePlaylist),
                          SizedBox(width: 12.0),
                          MyButton(icon: MyIcons.delete, onTap: removePlaylist),
                        ],
                      ),
                    ],
                  ),
                ),
                if (audios != null)
                  Expanded(
                    child: ListView.separated(
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.all(16.0),
                      itemCount: audios!.length,
                      itemBuilder: (context, index) => _AudioRow(
                        playlist: widget.playlist,
                        audio: audios![index],
                        onAdd: () => addSoundToPlaylist(audios![index]),
                        onRemove: () => removeSoundFromPlaylist(audios![index]),
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

  savePlaylist() async {
    await PlaylistData.removePlaylist(context, widget.playlist);
    if (widget.playlist.audios.isNotEmpty) {
      widget.playlist.name = playlistNameController.text;
      await PlaylistData.savePlaylist(context, widget.playlist);
    }
    Navigator.pop(context);
  }

  removePlaylist() {
    PlaylistData.removePlaylist(context, widget.playlist);
    Navigator.pop(context);
  }

  addSoundToPlaylist(Audio audio) {
    widget.playlist.audios.add(audio);

    PlaylistData.savePlaylist(context, widget.playlist).then((_) {
      initAudios();
    });
  }

  removeSoundFromPlaylist(Audio audio) {
    widget.playlist.audios.remove(audio);

    if (widget.playlist.audios.isEmpty) {
      removePlaylist();
    } else {
      PlaylistData.savePlaylist(context, widget.playlist).then((_) {
        initAudios();
      });
    }
  }
}

class _AudioRow extends StatelessWidget {
  const _AudioRow({
    Key? key,
    required this.playlist,
    required this.audio,
    required this.onAdd,
    required this.onRemove,
  }) : super(key: key);

  final Playlist playlist;
  final Audio audio;
  final Function() onAdd, onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: MyText.body(
            audio.name,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(
          width: 16.0,
        ),
        MyButton(
          icon: playlist.audios.contains(audio)
              ? MyIcons.playlist_delete
              : MyIcons.playlist_add,
          onTap: playlist.audios.contains(audio) ? onRemove : onAdd,
        ),
      ],
    );
  }
}
