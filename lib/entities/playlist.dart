import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'audio.dart';

final colorTranslation = {
  'red': Colors.redAccent[100],
  'orange': Colors.deepOrangeAccent[100],
  'amber': Colors.amberAccent[100],
  'green': Colors.greenAccent[100],
  'cyan': Colors.cyanAccent[100],
  'blue': Colors.blueAccent[100],
  'purple': Colors.deepPurpleAccent[100],
};

final colorTranslationReverse = {
  Colors.redAccent[100]: 'red',
  Colors.deepOrangeAccent[100]: 'orange',
  Colors.amberAccent[100]: 'amber',
  Colors.greenAccent[100]: 'green',
  Colors.cyanAccent[100]: 'cyan',
  Colors.blueAccent[100]: 'blue',
  Colors.deepPurpleAccent[100]: 'purple',
};

// ignore: must_be_immutable
class Playlist extends Equatable {
  late String name;
  late List<Audio> audios;
  Color? color;

  Playlist({
    required this.name,
    required this.audios,
    this.color,
  });

  Playlist.fromJson(Map json) {
    name = json['name'] ?? 'New Playlist';
    audios = json['audios'] != null
        ? (jsonDecode(json['audios']) as List)
            .map((audio) => Audio.fromJson(audio))
            .toList()
        : [];
    color = json['color'] != null ? colorTranslation[json['color']] : null;
  }

  toJson() => {
        'name': name,
        'audios': audios.isNotEmpty
            ? jsonEncode(audios.map((audio) => audio.toJson()).toList())
            : jsonEncode([]),
        'color': colorTranslationReverse[color]
      };

  @override
  List<Object> get props => [name];
}
