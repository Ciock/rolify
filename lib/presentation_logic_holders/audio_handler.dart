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

Future<AudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.rolify.app.audio',
      androidNotificationChannelName: 'Rolify',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}

class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  Map<String, AudioPlayer> audioPlayers = {};
  List<AudioPlayer> playingAudio = [];
  List<AudioPlayer> pausedAudio = [];
  bool stoppingAll = false;

  final mockMediaItem = const MediaItem(
    id: "id",
    album: "For awesome roleplayers",
    title: "Rolify",
  );

  Future<AudioPlayer> getAudioPlayer(Audio audio) async {
    if (audioPlayers.containsKey(audio.path)) {
      return audioPlayers[audio.path]!;
    } else {
      final audioPlayer = AudioPlayer();
      audio.audioSource == LocalAudioSource.assets
          ? await audioPlayer.setAsset(audio.path)
          : await audioPlayer.setFilePath(audio.path);
      audioPlayer.setVolume(0.5);
      audioPlayers[audio.path] = audioPlayer;
      audioPlayer.setLoopMode(LoopMode.one);
      return audioPlayer;
    }
  }

  void playAudioPlayer(AudioPlayer audioPlayer) {
    mediaItem.add(mockMediaItem);

    audioPlayer.play().then((_) async {
      if (audioPlayer.playing) {
        await audioPlayer.stop();
        await audioPlayer.seek(Duration.zero);
      }
    });

    playingAudio.add(audioPlayer);

    playbackState.add(PlaybackState(
      controls: [
        MediaControl.pause,
        MediaControl.stop,
      ],
      processingState: AudioProcessingState.ready,
      playing: true,
    ));
  }

  @override
  Future<void> play() async {
    for (final audioPlayer in pausedAudio) {
      playAudioPlayer(audioPlayer);
      playingAudio.add(audioPlayer);
    }
    pausedAudio = [];
    customEvent.add('just played');
  }

  @override
  Future<void> pause() async {
    for (final audioPlayer in playingAudio) {
      await audioPlayer.stop();
      pausedAudio.add(audioPlayer);
    }
    playingAudio = [];

    playbackState.add(PlaybackState(
      controls: [
        MediaControl.play,
        MediaControl.stop,
      ],
      processingState: AudioProcessingState.ready,
      playing: true,
    ));

    customEvent.add('just paused');
  }

  @override
  Future<void> stop() async {
    for (final key in audioPlayers.keys) {
      await audioPlayers[key]!.stop();
    }
    playingAudio = [];
  }

  @override
  Future<void> onTaskRemoved() {
    stop();
    return super.onTaskRemoved();
  }

  ///
  /// Expect extras as:
  /// {
  ///   "audio": value,
  ///   "param": value
  /// }
  @override
  Future customAction(String name, [Map<String, dynamic>? extras]) async {
    if (extras != null) {
      final audio = Audio.fromJson(extras["audio"]);
      final audioPlayer = await getAudioPlayer(audio);
      if (extras["param"] != null) {
        final dynamic param = extras["param"];

        if (name == 'set_volume') {
          audioPlayer.setVolume(param);
        }
        if (name == 'loop') {
          audioPlayer.setLoopMode(param ? LoopMode.one : LoopMode.off);
        }
      } else {
        if (name == 'play') {
          playAudioPlayer(audioPlayer);
        }
        if (name == 'stop') {
          audioPlayer.stop();
          playingAudio.remove(audioPlayer);
        }
        if (name == 'is_playing') {
          return audioPlayer.playing;
        }
        if (name == 'get_volume') {
          return audioPlayer.volume;
        }
        if (name == 'get_loop') {
          return audioPlayers[audio.path]!.loopMode == LoopMode.one;
        }
      }
    }
    if (name == 'stop_all') {
      await stop();
      return null;
    }
    return super.customAction(name, extras);
  }
}
