import 'package:jiosaavn_handler/jiosaavn_handler.dart';

class PlaylistService {
  Future<Map<dynamic, dynamic>?> getSongsData(String id, String type) async {
    if (type == "playlist") {
      return await Api().fetchPlaylistSongs(id);
    } else if (type == "album") {
      return await Api().fetchAlbumSongs(id);
    } else if (type == "song") {
      return await Api().fetchSongDetails(id);
    } else if (type == "mix") {
      return await Api().getSongFromToken(id, type); // unused
    } else {
      return null;
    }
  }
}
