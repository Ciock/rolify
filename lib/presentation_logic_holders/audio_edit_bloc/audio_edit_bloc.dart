import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rolify/data/audios.dart';
import 'package:rolify/data/playlist.dart';
import 'package:rolify/presentation_logic_holders/audio_edit_bloc/audio_edit_event.dart';
import 'package:rolify/presentation_logic_holders/audio_edit_bloc/audio_edit_state.dart';

class AudioEditBloc extends Bloc<AudioEditEvent, AudioEditState> {
  AudioEditBloc() : super(NoEditing()) {
    on<EnableEditing>((event, emit) => AudioEditing(event.audio));
    on<ConfirmEditing>((event, emit) {
      AudioData.updateAudio(event.context, event.audio);
      return NoEditing();
    });
    on<CancelEditing>((event, emit) => NoEditing());
    on<DeleteAudio>((event, emit) {
      AudioData.getAllAudios().then((audios) {
        audios.remove(event.audio);
        PlaylistData.deleteAudioFromAllPlaylist(event.context, event.audio);
        AudioData.saveAllAudios(event.context, audios);
      });
      return NoEditing();
    });
  }
}
