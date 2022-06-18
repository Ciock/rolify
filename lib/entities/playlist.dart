import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'audio.dart';

final colors = [
  Colors.redAccent[100]!,
  Colors.deepOrangeAccent[100]!,
  Colors.amberAccent[100]!,
  Colors.greenAccent[100]!,
  Colors.cyanAccent[100]!,
  Colors.blueAccent[100]!,
  Colors.deepPurpleAccent[100]!,
];

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

class Playlist extends Equatable {
  final String name;
  final List<Audio> audios;
  final Color? color;

  const Playlist({
    required this.name,
    required this.audios,
    this.color,
  });

  Playlist.fromJson(Map json)
      : name = json['name'] ?? 'New Playlist',
        audios = json['audios'] != null
            ? (jsonDecode(json['audios']) as List)
                .map((audio) => Audio.fromJson(audio))
                .toList()
            : [],
        color = json['color'] != null ? colorTranslation[json['color']] : null;

  toJson() => {
        'name': name,
        'audios': audios.isNotEmpty
            ? jsonEncode(audios.map((audio) => audio.toJson()).toList())
            : jsonEncode([]),
        'color': colorTranslationReverse[color]
      };

  Playlist copyFrom({
    String? name,
    List<Audio>? audios,
    Color? color,
  }) =>
      Playlist(
          name: name ?? this.name,
          audios: audios ?? this.audios,
          color: color ?? this.color);

  @override
  List<Object> get props => [name];
}
