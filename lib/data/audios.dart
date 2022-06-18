import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rolify/entities/audio.dart';
import 'package:rolify/presentation_logic_holders/audio_list_bloc/audio_list_bloc.dart';
import 'package:rolify/presentation_logic_holders/audio_list_bloc/audio_list_event.dart';
import 'package:rolify/src/audios/audios.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioData {
  static Future<List<Audio>> getAllAudios() async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey('audios')) {
      List savedAudios = jsonDecode(preferences.getString('audios')!);
      return savedAudios.map((audio) => Audio.fromJson(audio)).toList();
    } else {
      return assetsAudios.map((audio) => Audio.fromJson(audio)).toList();
    }
  }

  static Future saveAllAudios(BuildContext context, List<Audio> audios,
      {bool refresh = true}) async {
    final preferences = await SharedPreferences.getInstance();
    final encodedAudios = audios.map((audio) => audio.toJson()).toList();
    preferences.setString('audios', jsonEncode(encodedAudios));
    BlocProvider.of<AudioListBloc>(context).add(AudioListUpdate(audios));
  }

  static Future updateAudio(BuildContext context, Audio? audio,
      {bool refresh = true}) async {
    if (audio == null) return;
    final allAudios = await getAllAudios();
    allAudios[allAudios.indexOf(audio)] = audio;
    await saveAllAudios(context, allAudios, refresh: refresh);
  }

  static Future addNewAssetsAudios(BuildContext context) async {
    final allAudios = await getAllAudios();
    List<Audio> audiosToAdd = [];
    final preferences = await SharedPreferences.getInstance();
    for (int i = 0; i < versionNumberWithAudioUpdates.length; i++) {
      final vn = versionNumberWithAudioUpdates[i];
      if (preferences.containsKey(vn.toString()) == false) {
        audiosToAdd.addAll(assetsAudios
            .where((element) => element['version_number'] == vn)
            .map((e) => Audio.fromJson(e))
            .toList()
            .where((element) => allAudios.contains(element) == false)
            .toList());
        preferences.setBool(vn.toString(), true);
      }
    }
    if (audiosToAdd.isNotEmpty) {
      audiosToAdd.addAll(allAudios);
      await saveAllAudios(context, audiosToAdd);
    }
  }
}
