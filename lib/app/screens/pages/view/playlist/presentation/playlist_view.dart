import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:rhythm/app/components/listtile/song_listtile.dart';
import 'package:rhythm/app/screens/pages/view/player/presentation/player.dart';
import 'package:rhythm/app/screens/pages/view/playlist/data/services/playlist_service.dart';
import 'package:rhythm/core/handler/map_to_media_item.dart';
import 'package:rhythm/core/utils/error/error_utils.dart';
import 'package:rhythm/main.dart';

class PlaylistView extends StatefulWidget {
  final String id;
  final String type;
  final String thumbnailUrl;
  final String title;
  const PlaylistView({
    super.key,
    required this.id,
    required this.type,
    required this.thumbnailUrl,
    required this.title,
  });

  @override
  State<PlaylistView> createState() => _PlaylistViewState();
}

class _PlaylistViewState extends State<PlaylistView> {
  late Map<dynamic, dynamic>? _data;
  final List<MediaItem> _songs = [];
  String songCount = '0';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() {
      isLoading = true;
    });
    _data = await PlaylistService().getSongsData(widget.id, widget.type);

    if (widget.type == "song") {
      _songs.add(MapToMediaItem.mapToMediaItem(_data!));
      songCount = _songs.length.toString();

      setState(() {
        isLoading = false;
      });

      return;
    }

    for (var song in _data!['songs']) {
      _songs.add(MapToMediaItem.mapToMediaItem(song));
    }

    songCount = _songs.length.toString();

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Theme.of(context).colorScheme.background,
                  expandedHeight: constraints.maxHeight * 0.25,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Flexible(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  width: constraints.maxWidth * 0.36,
                                  height: constraints.maxWidth * 0.36,
                                  child: CachedNetworkImage(
                                    imageUrl: widget.thumbnailUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const Gap(16),
                            Flexible(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Gap(6),
                                  Text(
                                    'Songs: $songCount',
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Gap(12),
                                  Row(
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const MusicPlayer(),
                                            ),
                                          );

                                          audioHandler.updateQueue(_songs);
                                          audioHandler.play();
                                        },
                                        icon: const Icon(
                                            Icons.play_arrow_rounded),
                                        label: const Text('Play All'),
                                      ),
                                      const Gap(8),
                                      SizedBox(
                                        width: constraints.maxWidth * 0.16,
                                        child: IconButton.outlined(
                                          onPressed: () {
                                            ErrorUtils()
                                                .featureNotAvailable(context);
                                          },
                                          icon:
                                              const Icon(Icons.repeat_rounded),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(
                          left: 16,
                        ),
                        child: Text(
                          'Songs',
                          style: TextStyle(
                            fontSize: 24,
                            letterSpacing: 1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Gap(12),
                      !isLoading
                          ? CustomScrollView(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              slivers: [
                                SliverList.builder(
                                  itemCount: _songs.length,
                                  itemBuilder: (context, index) {
                                    return SongListTile(
                                      data: _songs[index],
                                      constraints: constraints,
                                    );
                                  },
                                )
                              ],
                            )
                          : const LinearProgressIndicator(),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
