import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:rolify/data/audios.dart';
import 'package:rolify/data/playlist.dart';
import 'package:rolify/entities/audio.dart';
import 'package:rolify/entities/playlist.dart';
import 'package:rolify/src/components/color_selection.dart';
import 'package:rolify/src/components/my_icons.dart';
import 'package:rolify/src/theme/texts.dart';

class PlaylistEditing extends StatefulWidget {
  final Playlist playlist;

  const PlaylistEditing({Key? key, required this.playlist}) : super(key: key);

  @override
  _PlaylistEditingState createState() => _PlaylistEditingState();
}

class _PlaylistEditingState extends State<PlaylistEditing> {
  TextEditingController titleController = TextEditingController();
  late List<Audio> audios;
  late Color color;

  @override
  void initState() {
    super.initState();
    audios = widget.playlist.audios;
    color = widget.playlist.color ?? Colors.redAccent[100]!;
    titleController.text = widget.playlist.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: NeumorphicTheme.baseColor(context),
        appBar: AppBar(
          backgroundColor: NeumorphicTheme.accentColor(context),
          title: Text('Playlist'),
          actions: <Widget>[
            IconButton(
              icon: MyIcons.delete,
              onPressed: () {
                PlaylistData.removePlaylist(context, widget.playlist)
                    .then((_) => Navigator.pop(context, false));
              },
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            IconButton(
              icon: MyIcons.done,
              onPressed: () {
                PlaylistData.savePlaylist(
                        context,
                        Playlist(
                            name: titleController.text,
                            audios: audios,
                            color: color))
                    .then((_) => Navigator.pop(context, true));
              },
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
          ],
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                child: TextField(
                  controller: titleController,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32),
                  decoration: InputDecoration(hintText: 'Playlist name'),
                ),
              ),
              ColorSelection(
                onChange: (value) {
                  setState(() {
                    color = value;
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
              Expanded(
                child: FutureBuilder<List<Audio>>(
                    future: AudioData.getAllAudios(),
                    builder: (context, res) => ListView.separated(
                          itemCount: res.data?.length ?? 0,
                          itemBuilder: (context, index) => GestureDetector(
                            onTap: () => addAudioToPlaylist(res.data![index]),
                            child: Container(
                              color: NeumorphicTheme.baseColor(context),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    MyText.body(res.data![index].name),
                                    if (audios.contains(res.data![index]))
                                      Container(
                                          height: 22,
                                          width: 22,
                                          child: MyIcons.done),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          separatorBuilder: (BuildContext context, int index) =>
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  child: Divider(
                                    height: 0,
                                  )),
                        )),
              )
            ],
          ),
        ));
  }

  addAudioToPlaylist(Audio data) {
    if (audios.contains(data)) {
      audios.remove(data);
    } else {
      audios.add(data);
    }
    setState(() {});
  }
}
