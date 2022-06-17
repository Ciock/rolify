import 'package:rolify/entities/audio.dart';

abstract class AudioEditState {
  final Audio? audio;

  AudioEditState(this.audio);
}

class NoEditing extends AudioEditState {
  NoEditing() : super(null);
}

class AudioEditing extends AudioEditState {
  AudioEditing(Audio? audio) : super(audio);
}
