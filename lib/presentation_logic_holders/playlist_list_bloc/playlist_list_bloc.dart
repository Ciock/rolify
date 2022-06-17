import 'package:flutter_bloc/flutter_bloc.dart';

import 'playlist_list_event.dart';
import 'playlist_list_state.dart';

class PlaylistListBloc extends Bloc<PlaylistListEvent, PlaylistListState> {
  PlaylistListBloc() : super(Initialized()) {
    on<PlaylistListUpdate>(
      (event, emit) => emit(PlaylistListEdited(event.playlist)),
    );
  }
}
