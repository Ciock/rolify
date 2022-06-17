import 'package:rolify/entities/audio.dart';

abstract class AudioListState{
  final List<Audio> audios;

  AudioListState(this.audios);
}

class Initialized extends AudioListState{
  Initialized() : super([]);
}
class AudioListEdited extends AudioListState{
  AudioListEdited(List<Audio> audios) : super(audios);
}