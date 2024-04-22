import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:jiosaavn_handler/jiosaavn_handler.dart';
import 'package:rhythm/app/screens/pages/view/player/presentation/player.dart';
import 'package:rhythm/core/handler/map_to_media_item.dart';
import 'package:rhythm/main.dart';

class SongListTile extends StatelessWidget {
  final MediaItem data;
  final BoxConstraints constraints;
  const SongListTile({
    super.key,
    required this.data,
    required this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: data.artUri.toString(),
          width: constraints.maxWidth * 0.12,
          height: constraints.maxWidth * 0.2,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(
        data.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        data.artist ?? 'Unknown',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () async {
        if (audioHandler.queue.value.contains(data) &&
            audioHandler.queue.value.length == 1) {
          return;
        }

        if (audioHandler.queue.value.contains(data) &&
            audioHandler.queue.value.length > 1) {
          await audioHandler.skipToQueueItem(
            audioHandler.queue.value.indexOf(data),
          );

          if (!audioHandler.playbackState.value.playing) {
            audioHandler.play();
          }

          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MusicPlayer(),
            settings: const RouteSettings(name: '/musicPlayer'),
          ),
        );

        await audioHandler.updateQueue([data]);
        audioHandler.play();
        _getSongReco();
      },
    );
  }

  Future<void> _getSongReco() async {
    List response = await Api().getReco(data.extras!['songId']);

    List<MediaItem> songs = MapToMediaItem.listToMediaItems(response);

    await audioHandler.addQueueItems(songs);
  }
}
