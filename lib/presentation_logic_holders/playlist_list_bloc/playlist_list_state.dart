import 'package:rolify/entities/playlist.dart';

abstract class PlaylistListState{
  final List<Playlist> playlists;

  PlaylistListState(this.playlists);
}

class Initialized extends PlaylistListState{
  Initialized() : super([]);
}
class PlaylistListEdited extends PlaylistListState{
  PlaylistListEdited(List<Playlist> playlists) : super(playlists);
}