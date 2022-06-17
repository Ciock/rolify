import 'package:audio_service/audio_service.dart';
import 'package:rolify/entities/audio.dart';
import 'package:rolify/presentation_logic_holders/audio_service_background.dart';
import 'package:rolify/presentation_logic_holders/event_bus/stop_all_event_bus.dart';
import 'package:rolify/presentation_logic_holders/playing_sounds_singleton.dart';

class AudioServiceCommands {
  static Future<bool> startAudioService() async {
    return AudioService.start(
      backgroundTaskEntrypoint: audioPlayerTaskEntrypoint,
      androidNotificationChannelName: 'Audio Service Demo',
      androidNotificationColor: 0xFF2196f3,
      androidNotificationIcon: 'mipmap/ic_launcher',
      androidEnableQueue: true,
      androidStopForegroundOnPause: true,
    );
  }

  static play(Audio audio) async {
    PlayingSounds().playAudio(audio);
    eventBus.fire(AudioPlayed(audio.path));
    await startAudioService();
    AudioService.customAction('play', audio.toJson());
  }

  static stop(Audio audio) async {
    PlayingSounds().removeAudio(audio);
    AudioService.customAction('stop', audio.toJson());
    eventBus.fire(AudioPaused(audio.path));
  }

  static loop(bool value, Audio audio) async {
    AudioService.customAction('loop', {audio.toJson(): value});
    eventBus.fire(ToggleLoop(audio.path, value));
  }

  static Future getLoop(Audio audio) async {
    return AudioService.customAction('get_loop', audio.toJson());
  }

  static Future setVolume(Audio audio, double value) async {
    return AudioService.customAction('set_volume', {audio.toJson(): value});
  }

  static Future getVolume(Audio audio) async {
    return AudioService.customAction('get_volume', audio.toJson());
  }
}
