import 'package:flutter_bloc/flutter_bloc.dart';

import 'audio_list_event.dart';
import 'audio_list_state.dart';

class AudioListBloc extends Bloc<AudioListEvent, AudioListState> {
  AudioListBloc() : super(Initialized()) {
    on<AudioListUpdate>(
      (event, emit) => AudioListEdited(event.audios),
    );
  }
}
