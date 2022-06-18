import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:rolify/data/audios.dart';
import 'package:rolify/data/playlist.dart';
import 'package:rolify/entities/audio.dart';
import 'package:rolify/entities/playlist.dart';
import 'package:rolify/src/components/button.dart';
import 'package:rolify/src/components/color_selection.dart';
import 'package:rolify/src/components/my_icons.dart';
import 'package:rolify/src/components/text_field.dart';
import 'package:rolify/src/theme/texts.dart';

class EditPlaylist extends StatefulWidget {
  final Playlist playlist;

  const EditPlaylist({Key? key, required this.playlist}) : super(key: key);

  @override
  EditPlaylistState createState() => EditPlaylistState();
}

class EditPlaylistState extends State<EditPlaylist> {
  final playlistNameController = TextEditingController();
  List<Audio>? audios;
  Color? color;

  @override
  void initState() {
    super.initState();
    initAudios();
    playlistNameController.text = widget.playlist.name;
    color = widget.playlist.color;
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
          padding: const EdgeInsets.all(24.0),
          child: Neumorphic(
            style: NeumorphicStyle(
              boxShape: NeumorphicBoxShape.roundRect(
                  const BorderRadius.all(Radius.circular(16.0))),
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
                      const SizedBox(height: 16.0),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: MyTextField(
                              controller: playlistNameController,
                              hintText: 'Create a new playlist...',
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          MyButton(icon: MyIcons.done, onTap: savePlaylist),
                          const SizedBox(width: 12.0),
                          MyButton(icon: MyIcons.delete, onTap: removePlaylist),
                        ],
                      ),
                    ],
                  ),
                ),
                ColorSelection(
                  onChange: (value) {
                    setState(() {
                      color = color == value ? null : value;
                    });
                  },
                  colors: <Color>[
                    Colors.redAccent[100]!,
                    Colors.deepOrangeAccent[100]!,
                    Colors.amberAccent[100]!,
                    Colors.greenAccent[100]!,
                    Colors.cyanAccent[100]!,
                    Colors.blueAccent[100]!,
                    Colors.deepPurpleAccent[100]!,
                  ],
                  groupValue: color,
                ),
                if (audios != null)
                  Expanded(
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(16.0),
                      itemCount: audios!.length,
                      itemBuilder: (context, index) => _AudioRow(
                        playlist: widget.playlist,
                        audio: audios![index],
                        onAdd: () => addSoundToPlaylist(audios![index]),
                        onRemove: () => removeSoundFromPlaylist(audios![index]),
                      ),
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(
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
      await PlaylistData.savePlaylist(
          context,
          widget.playlist
              .copyFrom(name: playlistNameController.text, color: color));
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
        const SizedBox(
          width: 16.0,
        ),
        MyButton(
          icon: playlist.audios.contains(audio)
              ? MyIcons.playlistDelete
              : MyIcons.playlistAdd,
          onTap: playlist.audios.contains(audio) ? onRemove : onAdd,
        ),
      ],
    );
  }
}
