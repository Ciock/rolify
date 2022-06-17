import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rolify/entities/audio.dart';

MediaControl playControl = const MediaControl(
  androidIcon: 'drawable/ic_action_play_arrow',
  label: 'Play',
  action: MediaAction.play,
);
MediaControl pauseControl = const MediaControl(
  androidIcon: 'drawable/ic_action_pause',
  label: 'Pause',
  action: MediaAction.pause,
);
MediaControl skipToNextControl = const MediaControl(
  androidIcon: 'drawable/ic_action_skip_next',
  label: 'Next',
  action: MediaAction.skipToNext,
);
MediaControl skipToPreviousControl = const MediaControl(
  androidIcon: 'drawable/ic_action_skip_previous',
  label: 'Previous',
  action: MediaAction.skipToPrevious,
);
MediaControl stopControl = const MediaControl(
  androidIcon: 'drawable/ic_action_stop',
  label: 'Stop',
  action: MediaAction.stop,
);

void audioPlayerTaskEntrypoint() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

class AudioPlayerTask extends BackgroundAudioTask {
  Map<String, Map<String, dynamic>> audioPlayers = {};
  List<AudioPlayer> playingAudio = [];
  List<AudioPlayer> pausedAudio = [];
  bool stoppingAll = false;
  Completer completer = Completer();

  bool get _playing => playingAudio.isNotEmpty;
  final mediaItem = const MediaItem(
    id: "id",
    album: "For awesome roleplayers",
    title: "Rolify",
  );

  // @override
  // Future<void> onStart(Map<String, dynamic> map) async => await _completer.future;

  Future<AudioPlayer> getAudioPlayer(Audio audio) async {
    if (audioPlayers.containsKey(audio.path)) {
      return audioPlayers[audio.path]!['audio_player'];
    } else {
      final audioPlayer = AudioPlayer();
      audio.audioSource == LocalAudioSource.assets
          ? await audioPlayer.setAsset(audio.path)
          : await audioPlayer.setFilePath(audio.path);
      audioPlayer.setVolume(0.5);
      audioPlayers[audio.path] = {'audio_player': audioPlayer, 'loop': true};
      return audioPlayer;
    }
  }

  void playPause() {
    if (AudioServiceBackground.state.playing) {
      onPause();
    } else {
      onPlay();
    }
  }

  void play(AudioPlayer audioPlayer) {
    AudioServiceBackground.setMediaItem(mediaItem);
    audioPlayer.play().then((_) async {
      // print('state: ${audioPlayer.playbackState}');

      bool loopAudio = true;
      for (String key in audioPlayers.keys) {
        if (audioPlayers[key]!['audio_player'] == audioPlayer) {
          loopAudio = audioPlayers[key]!['loop'];
          break;
        }
      }
      if (audioPlayer.playing ||
          audioPlayer.processingState == ProcessingState.completed) {
        await audioPlayer.stop();
        if (loopAudio && stoppingAll == false) {
          play(audioPlayer);
        } else {
          // TODO: Notify UI audio stopped
        }
      } else {
        final audioDuration = await audioPlayer.durationFuture;
        if (audioDuration != null &&
            (audioDuration.inMilliseconds -
                        audioPlayer.playbackEvent.updatePosition.inMilliseconds)
                    .abs() <=
                1000) {
          if (loopAudio && stoppingAll == false) {
            play(audioPlayer);
          } else {
            // TODO: Notify UI audio stopped
          }
        }
      }
    });

    playingAudio.add(audioPlayer);
    AudioServiceBackground.setState(
      controls: getControls(),
      playing: true,
      processingState: AudioProcessingState.ready,
    );
  }

  @override
  Future<void> onPlay() async {
    for (final audioPlayer in pausedAudio) {
      play(audioPlayer);
      playingAudio.add(audioPlayer);
    }
    pausedAudio = [];
    AudioServiceBackground.sendCustomEvent('just played');
  }

  @override
  Future<void> onPause() async {
    for (final audioPlayer in playingAudio) {
      await audioPlayer.stop();
      pausedAudio.add(audioPlayer);
    }
    playingAudio = [];
    AudioServiceBackground.setState(
      controls: getControls(),
      playing: false,
      processingState: AudioProcessingState.ready,
    );
    AudioServiceBackground.sendCustomEvent('just paused');
  }

  @override
  Future<void> onClick(MediaButton? button) {
    playPause();
    return super.onClick(button);
  }

  @override
  Future<void> onStop() async {
    for (final key in audioPlayers.keys) {
      await audioPlayers[key]!['audio_player'].stop();
    }
    playingAudio = [];
    completer.complete();
    await super.onStop();
  }

  @override
  Future<void> onTaskRemoved() {
    onStop();
    return super.onTaskRemoved();
  }

  @override
  Future onCustomAction(String name, arguments) async {
    if (arguments != null) {
      if (arguments is List) {
        if (name == 'set_volume') {
          final audio = Audio.fromJson(arguments[0]);
          final audioPlayer = await getAudioPlayer(audio);
          audioPlayer.setVolume(arguments[1]);
        }
        if (name == 'loop') {
          final audio = Audio.fromJson(arguments[0]);
          await getAudioPlayer(audio);
          audioPlayers[audio.path]!['loop'] = arguments[1];
        }
      } else {
        final audio = Audio.fromJson(arguments);
        final audioPlayer = await getAudioPlayer(audio);
        if (name == 'play') {
          play(audioPlayer);
        } else if (name == 'stop') {
          audioPlayer.stop();
          playingAudio.remove(audioPlayer);
        } else if (name == 'is_playing') {
          return audioPlayer.playing;
        } else if (name == 'get_volume') {
          return audioPlayer.volume;
        } else if (name == 'get_loop') {
          return audioPlayers[audio.path]!['loop'];
        }
      }
    } else if (name == 'stop_all') {
      await onStop();
      return null;
    }
    return super.onCustomAction(name, arguments);
  }

  List<MediaControl> getControls() {
    if (_playing) {
      return [
        pauseControl,
        stopControl,
      ];
    } else {
      return [
        playControl,
        stopControl,
      ];
    }
  }
}
