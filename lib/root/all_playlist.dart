import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rolify/data/playlist.dart';
import 'package:rolify/entities/playlist.dart';
import 'package:rolify/presentation_logic_holders/playlist_list_bloc/playlist_list_bloc.dart';
import 'package:rolify/presentation_logic_holders/playlist_list_bloc/playlist_list_state.dart';
import 'package:rolify/src/components/button.dart';
import 'package:rolify/src/components/my_icons.dart';
import 'package:rolify/src/components/playlist_card.dart';

import 'edit_playlist.dart';

class AllPlaylist extends StatefulWidget {
  const AllPlaylist({Key? key}) : super(key: key);

  @override
  AllPlaylistState createState() => AllPlaylistState();
}

class AllPlaylistState extends State<AllPlaylist> {
  List<Playlist> playlists = [];

  @override
  void initState() {
    super.initState();
    initPlaylists();
  }

  void initPlaylists() {
    PlaylistData.getAllPlaylist().then((value) {
      if (mounted) {
        value.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        setState(() {
          playlists = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlaylistListBloc, PlaylistListState>(
      listener: (BuildContext context, PlaylistListState state) {
        if (state is PlaylistListEdited) initPlaylists();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Wrap(
            alignment: WrapAlignment.center,
            runSpacing: 16.0,
            spacing: 16.0,
            children: getPlaylistList(),
          ),
        ],
      ),
    );
  }

  List<Widget> getPlaylistList() {
    List<Widget> list = [];

    list.addAll(
        playlists.map((playlist) => PlaylistCard(playlist: playlist)).toList());

    list.add(Align(
      alignment: Alignment.center,
      child: MyButton(
          icon: MyIcons.add,
          onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditPlaylist(
                    playlist: Playlist.fromJson(const {}),
                  ),
                ),
              )),
    ));
    return list;
  }
}
