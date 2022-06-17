import 'package:event_bus/event_bus.dart';

EventBus eventBus = EventBus();

class OnAppResume {}

class AudioPlayed{
  final String path;

  AudioPlayed(this.path);
}

class AudioPaused{
  final String path;

  AudioPaused(this.path);
}

class ToggleLoop{
  final String path;
  final bool value;

  ToggleLoop(this.path, this.value);
}
