import 'package:equatable/equatable.dart';

enum LocalAudioSource { assets, file }

// ignore: must_be_immutable
class Audio extends Equatable {
  final String name, path, image;
  final LocalAudioSource audioSource;

  const Audio({
    required this.name,
    required this.path,
    this.image = 'assets/images/tavern.jpg',
    this.audioSource = LocalAudioSource.assets,
  });

  Audio.fromJson(Map json)
      : name = json['name'] ?? removeFileExtension(json['path']),
        path = json['path'],
        image = json['image'],
        audioSource = json['audio_source'] == 'assets'
            ? LocalAudioSource.assets
            : LocalAudioSource.file;

  toJson() => {
        'name': name,
        'path': path,
        'image': image,
        'audio_source':
            audioSource == LocalAudioSource.assets ? 'assets' : 'file',
      };

  Audio copyFrom({
    String? name,
    String? path,
    String? image = 'assets/images/tavern.jpg',
    LocalAudioSource? audioSource = LocalAudioSource.assets,
  }) =>
      Audio(
        name: name ?? this.name,
        path: path ?? this.path,
        image: image ?? this.image,
        audioSource: audioSource ?? this.audioSource,
      );

  @override
  List<Object> get props => [path];
}

String removeFileExtension(String path) {
  final pathSplit = path.split('.');
  return path
      .split('/')
      .last
      .replaceAll('_', ' ')
      .replaceAll('.${pathSplit.last}', '');
}
