import 'package:rolify/entities/audio.dart';

class PlayingSounds {
  static final PlayingSounds _singleton = PlayingSounds._internal();
  List<Audio> playingAudios = [];
  List<Audio> pausedAudios = [];
  double masterVolume = 1.0;

  factory PlayingSounds() {
    return _singleton;
  }

  PlayingSounds._internal();

  updateAudio(Audio audio) {
    final playingIndex = playingAudios.indexOf(audio);
    if (playingIndex >= 0) {
      playingAudios[playingIndex] = audio;
    }

    final pausedIndex = pausedAudios.indexOf(audio);
    if (pausedIndex >= 0) {
      pausedAudios[pausedIndex] = audio;
    }
  }

  removeAudio(Audio audio) {
    playingAudios.remove(audio);
  }

  playAudio(Audio audio) {
    pausedAudios = [];
    playingAudios.add(audio);
  }

  pauseAudio(Audio audio) {
    pausedAudios.add(audio);
  }

  replayAudio(Audio audio) {
    pausedAudios.remove(audio);
  }
}
