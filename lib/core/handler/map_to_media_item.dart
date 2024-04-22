import 'package:audio_service/audio_service.dart';

class MapToMediaItem {
  static MediaItem mapToMediaItem(Map<dynamic, dynamic> data) {
    return MediaItem(
      id: data['url'].toString().replaceAll('_96', '_320'),
      title: data['title'],
      artist: data['artist'],
      duration: Duration(seconds: int.parse(data['duration'])),
      artUri: Uri.parse(data['image']),
      extras: {
        'songId': data['id'],
      },
    );
  }

  static List<MediaItem> listToMediaItems(List<dynamic> data) {
    List<MediaItem> songs = [];

    for (var song in data) {
      songs.add(MapToMediaItem.mapToMediaItem(song));
    }

    return songs;
  }
}
