
import 'package:rolify/entities/playlist.dart';

abstract class PlaylistListEvent {
  final List<Playlist> playlist;

  PlaylistListEvent(this.playlist);}

class PlaylistListUpdate extends PlaylistListEvent {
  PlaylistListUpdate(List<Playlist> playlist) : super(playlist);
}
