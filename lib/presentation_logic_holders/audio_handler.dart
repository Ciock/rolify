import 'dart:io';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rolify/entities/audio.dart';
import 'package:path_provider/path_provider.dart';

enum AudioCustomEvents { audioEnded, resumeAll, pauseAll }

Future<AudioHandler> initAudioService() async {
  final audioHandler = await AudioService.init(
    builder: () => MyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.rolify.app.audio',
      androidNotificationChannelName: 'Rolify',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      androidShowNotificationBadge: true,
      androidNotificationIcon: 'mipmap/ic_launcher_foreground',
      notificationColor: Color(0xFFF0F0F3),
    ),
  );
  audioHandler.setMockMediaItem('launcher_icon/512px_512px.png');

  return audioHandler;
}

class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  Map<String, AudioPlayer> audioPlayers = {};
  List<AudioPlayer> playingAudio = [];
  List<AudioPlayer> pausedAudio = [];
  bool stoppingAll = false;

  Future<void> setMockMediaItem(String path) async {
    final byteData = await rootBundle.load('assets/$path');

    final file = File('${(await getTemporaryDirectory()).path}/mock.png');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    final mockMediaItem = MediaItem(
      id: "id",
      album: "For awesome roleplayers",
      title: "Rolify",
      artUri: Uri.parse('file://${file.path}'),
    );

    mediaItem.add(mockMediaItem);
  }

  Future<AudioPlayer> getAudioPlayer(Audio audio) async {
    if (audioPlayers.containsKey(audio.path)) {
      return audioPlayers[audio.path]!;
    } else {
      final audioPlayer = AudioPlayer();
      audio.audioSource == LocalAudioSource.assets
          ? await audioPlayer.setAsset(audio.path)
          : await audioPlayer.setFilePath(audio.path);
      audioPlayer.setVolume(audio.volume);
      audioPlayer.setLoopMode(audio.loopMode);
      audioPlayers[audio.path] = audioPlayer;
      return audioPlayer;
    }
  }

  String _getAudioPath(AudioPlayer audioPlayer) {
    return audioPlayers.keys.firstWhere(
        (path) => audioPlayers[path] == audioPlayer,
        orElse: () => '');
  }

  void playAudioPlayer(AudioPlayer audioPlayer) {
    audioPlayer.play().then((_) async {
      if (audioPlayer.playing) {
        await audioPlayer.stop();
        await audioPlayer.seek(Duration.zero);
        playingAudio.remove(audioPlayer);
        customEvent.add(createAudioCustomEvent(
            AudioCustomEvents.audioEnded, _getAudioPath(audioPlayer)));
      }
    });

    playingAudio.add(audioPlayer);

    playbackState.add(PlaybackState(
      controls: [
        MediaControl.pause,
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
    customEvent.add(createAudioCustomEvent(AudioCustomEvents.resumeAll));
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
      ],
      processingState: AudioProcessingState.ready,
      playing: false,
    ));

    customEvent.add(createAudioCustomEvent(AudioCustomEvents.pauseAll));
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

  Map<String, dynamic> createAudioCustomEvent(AudioCustomEvents name,
      [String? audioPath]) {
    return {
      'name': name,
      'audioPath': audioPath,
    };
  }
}
