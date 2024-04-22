import 'package:audio_service/audio_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:glass/glass.dart';
import 'package:rhythm/app/screens/pages/view/player/data/service/player_service.dart';
import 'package:rhythm/app/screens/pages/view/player/presentation/player.dart';
import 'package:rhythm/main.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return StreamBuilder(
          stream: audioHandler.mediaItem,
          builder: (context, snapshot) {
            final data = snapshot.data;

            if (snapshot.hasData) {
              return Padding(
                padding: EdgeInsets.only(left: constraints.maxWidth * 0.07),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MusicPlayer(),
                      settings: const RouteSettings(name: '/musicPlayer'),
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surface
                          .withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: data!.artUri.toString(),
                              fit: BoxFit.cover,
                              height: constraints.maxWidth * 0.125,
                              width: constraints.maxWidth * 0.125,
                            ),
                          ),
                          const Gap(12),
                          Flexible(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                const Gap(2),
                                Text(
                                  data.artist ?? 'Unknown Artist',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                const Gap(8),
                                StreamBuilder<PositionData>(
                                  stream: positionDataStream,
                                  builder: (context, snapshot) {
                                    return Flexible(
                                      child: ProgressBar(
                                        progress: snapshot.data!.position,
                                        total: snapshot.data!.duration,
                                        buffered:
                                            snapshot.data!.bufferedPosition,
                                        onSeek: (value) =>
                                            audioHandler.seek(value),
                                        timeLabelLocation:
                                            TimeLabelLocation.none,
                                        thumbRadius: 2.2,
                                        barHeight: 1,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          _musicControllers(),
                        ],
                      ),
                    ),
                  ).asGlass(
                    frosted: false,
                    clipBorderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        );
      },
    );
  }
}

Widget _musicControllers() {
  return StreamBuilder<PlaybackState?>(
    stream: audioHandler.playbackState,
    builder: (context, snapshot) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            iconSize: 40,
            onPressed: () {
              snapshot.data?.playing ?? false
                  ? audioHandler.pause()
                  : audioHandler.play();
            },
            icon: snapshot.data?.playing ?? false
                ? const Icon(Icons.pause_rounded)
                : const Icon(Icons.play_arrow_rounded),
          ),
        ],
      );
    },
  );
}
