import 'package:flutter/cupertino.dart';
import 'package:rolify/entities/audio.dart';

abstract class AudioEditEvent {
  final BuildContext context;
  final Audio? audio;

  AudioEditEvent(this.context, this.audio);
}

class EnableEditing extends AudioEditEvent {
  EnableEditing(BuildContext context, Audio? audio) : super(context, audio);
}

class ConfirmEditing extends AudioEditEvent {
  ConfirmEditing(BuildContext context, Audio? audio) : super(context, audio);
}

class CancelEditing extends AudioEditEvent {
  CancelEditing(BuildContext context, Audio? audio) : super(context, audio);
}

class DeleteAudio extends AudioEditEvent {
  DeleteAudio(BuildContext context, Audio? audio) : super(context, audio);
}
