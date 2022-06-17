import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rolify/entities/audio.dart';
import 'package:rolify/entities/playlist.dart';
import 'package:rolify/presentation_logic_holders/playlist_list_bloc/playlist_list_bloc.dart';
import 'package:rolify/presentation_logic_holders/playlist_list_bloc/playlist_list_event.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlaylistData {
  static Future<List<Playlist>> getAllPlaylist() async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey('playlist')) {
      List savedPlaylist = jsonDecode(preferences.getString('playlist')!);
      return savedPlaylist
          .map((playlist) => Playlist.fromJson(playlist))
          .toList();
    } else {
      return [];
    }
  }

  static Future savePlaylist(BuildContext context, Playlist playlist) async {
    final allPlaylist = await getAllPlaylist();
    if (allPlaylist.contains(playlist)) {
      allPlaylist[allPlaylist.indexOf(playlist)] = playlist;
    } else {
      allPlaylist.add(playlist);
    }

    await saveAllPlaylist(context, allPlaylist);
  }

  static Future removePlaylist(BuildContext context, Playlist playlist) async {
    final allPlaylist = await getAllPlaylist();
    if (allPlaylist.contains(playlist)) {
      allPlaylist.remove(playlist);
      await saveAllPlaylist(context, allPlaylist);
    }
  }

  static Future saveAllPlaylist(
      BuildContext context, List<Playlist> allPlaylist) async {
    final preferences = await SharedPreferences.getInstance();
    final encodedAudios = allPlaylist.map((play) => play.toJson()).toList();
    preferences.setString('playlist', jsonEncode(encodedAudios));
    BlocProvider.of<PlaylistListBloc>(context)
        .add(PlaylistListUpdate(allPlaylist));
  }

  static Future<List<Playlist>> deleteAudioFromAllPlaylist(
      BuildContext context, Audio? audio) async {
    final playlists = await getAllPlaylist();
    if (audio != null) {
      for (int i = 0; i < playlists.length; i++) {
        playlists[i].audios.remove(audio);
      }
      saveAllPlaylist(context, playlists);
    }
    return playlists;
  }
}
