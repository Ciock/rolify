import 'package:rolify/entities/audio.dart';

class PlayingSounds {
  static final PlayingSounds _singleton = PlayingSounds._internal();
  List<Audio> playingAudios = [];
  List<Audio> pausedAudios = [];

  factory PlayingSounds() {
    return _singleton;
  }

  PlayingSounds._internal();

  removeAudio(Audio audio){
    playingAudios.remove(audio);
  }

  playAudio(Audio audio){
    pausedAudios = [];
    playingAudios.add(audio);
  }

  pauseAudio(Audio audio){
    pausedAudios.add(audio);
  }

  replayAudio(Audio audio){
    pausedAudios.remove(audio);
  }
}