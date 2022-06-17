import 'package:rolify/entities/audio.dart';

abstract class AudioListEvent {
  final List<Audio> audios;

  AudioListEvent(this.audios);}

class AudioListUpdate extends AudioListEvent {
  AudioListUpdate(List<Audio> audios) : super(audios);
}
