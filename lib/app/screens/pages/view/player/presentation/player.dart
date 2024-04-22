import 'package:audio_handler/audio_handler.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rhythm/app/screens/pages/view/player/data/service/player_service.dart';
import 'package:rhythm/app/screens/pages/view/player/presentation/queue_view.dart';
import 'package:rhythm/core/utils/error/error_utils.dart';
import 'package:rhythm/main.dart';

class MusicPlayer extends StatefulWidget {
  const MusicPlayer({super.key});

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
            ),
            backgroundColor: Theme.of(context).colorScheme.background,
            actions: [
              IconButton(
                onPressed: () {
                  ErrorUtils().featureNotAvailable(context);
                },
                icon: const Icon(Icons.more_vert_rounded),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(child: Container()),
                StreamBuilder<MediaItem?>(
                  stream: audioHandler.mediaItem,
                  builder: (context, snapshot) {
                    final mediaItem = snapshot.data;
                    if (mediaItem == null) return const SizedBox();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (mediaItem.artUri != null)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: mediaItem.artUri!.toString(),
                                width: constraints.maxWidth * 0.9,
                                height: constraints.maxWidth * 0.9,
                              ),
                            ),
                          ),
                        const Gap(24),
                        SizedBox(
                          width: constraints.maxWidth * 0.65,
                          child: Column(
                            children: [
                              Text(
                                mediaItem.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const Gap(6),
                              Text(
                                mediaItem.artist ?? 'Unknown',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ],
                          ),
                        ),
                        const Gap(22),
                      ],
                    );
                  },
                ),
                StreamBuilder<PositionData>(
                  stream: positionDataStream,
                  builder: (context, snapshot) {
                    final positionData = snapshot.data ??
                        PositionData(
                            Duration.zero, Duration.zero, Duration.zero);
                    return SizedBox(
                      width: constraints.maxWidth * 0.9,
                      child: ProgressBar(
                        progress: positionData.position,
                        buffered: positionData.bufferedPosition,
                        total: positionData.duration,
                        onSeek: (value) {
                          audioHandler.seek(value);
                        },
                        timeLabelLocation: TimeLabelLocation.sides,
                        thumbRadius: 4,
                        timeLabelType: TimeLabelType.totalTime,
                        barHeight: 2.5,
                        timeLabelTextStyle: GoogleFonts.lato(
                          fontSize: 15,
                        ),
                      ),
                    );
                  },
                ),
                const Gap(12),
                ControlButtons(audioHandler),
                const Gap(2),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      StreamBuilder<AudioServiceRepeatMode>(
                        stream: audioHandler.playbackState
                            .map((state) => state.repeatMode)
                            .distinct(),
                        builder: (context, snapshot) {
                          final repeatMode =
                              snapshot.data ?? AudioServiceRepeatMode.none;
                          const icons = [
                            Icon(Icons.repeat_rounded, color: Colors.grey),
                            Icon(Icons.repeat_rounded, color: Colors.orange),
                            Icon(Icons.repeat_one_rounded,
                                color: Colors.orange),
                          ];
                          const cycleModes = [
                            AudioServiceRepeatMode.none,
                            AudioServiceRepeatMode.all,
                            AudioServiceRepeatMode.one,
                          ];
                          final index = cycleModes.indexOf(repeatMode);
                          return IconButton(
                            icon: icons[index],
                            onPressed: () {
                              audioHandler.setRepeatMode(cycleModes[
                                  (cycleModes.indexOf(repeatMode) + 1) %
                                      cycleModes.length]);
                            },
                          );
                        },
                      ),
                      Expanded(
                        child: Text(
                          "",
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      StreamBuilder<bool>(
                        stream: audioHandler.playbackState
                            .map((state) =>
                                state.shuffleMode ==
                                AudioServiceShuffleMode.all)
                            .distinct(),
                        builder: (context, snapshot) {
                          final shuffleModeEnabled = snapshot.data ?? false;
                          return IconButton(
                            icon: shuffleModeEnabled
                                ? const Icon(Icons.shuffle,
                                    color: Colors.orange)
                                : const Icon(Icons.shuffle, color: Colors.grey),
                            onPressed: () async {
                              final enable = !shuffleModeEnabled;
                              await audioHandler.setShuffleMode(enable
                                  ? AudioServiceShuffleMode.all
                                  : AudioServiceShuffleMode.none);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Flexible(child: Container()),
                IconButton(
                  onPressed: () {
                    showQueueView(context, constraints);
                  },
                  icon: const Icon(Icons.keyboard_arrow_up_rounded),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ControlButtons extends StatelessWidget {
  final AudioPlayerHandler audioHandler;

  const ControlButtons(this.audioHandler, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          icon: const Icon(Icons.volume_up),
          onPressed: () {
            showSliderDialog(
              context: context,
              title: "Adjust volume",
              divisions: 10,
              min: 0.0,
              max: 1.0,
              value: audioHandler.volume.value,
              stream: audioHandler.volume,
              onChanged: audioHandler.setVolume,
            );
          },
        ),
        StreamBuilder<QueueState>(
          stream: audioHandler.queueState,
          builder: (context, snapshot) {
            final queueState = snapshot.data ?? QueueState.empty;
            return IconButton(
              iconSize: 40,
              icon: const Icon(Icons.skip_previous_rounded),
              onPressed:
                  queueState.hasPrevious ? audioHandler.skipToPrevious : null,
            );
          },
        ),
        StreamBuilder<PlaybackState>(
          stream: audioHandler.playbackState,
          builder: (context, snapshot) {
            final playbackState = snapshot.data;
            final processingState = playbackState?.processingState;
            final playing = playbackState?.playing;
            if (processingState == AudioProcessingState.loading ||
                processingState == AudioProcessingState.buffering) {
              return Container(
                margin: const EdgeInsets.all(8.0),
                width: 64.0,
                height: 64.0,
                child: const CircularProgressIndicator(),
              );
            } else if (playing != true) {
              return IconButton(
                icon: const Icon(Icons.play_arrow_rounded),
                iconSize: 64.0,
                onPressed: audioHandler.play,
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.pause_rounded),
                iconSize: 64.0,
                onPressed: audioHandler.pause,
              );
            }
          },
        ),
        StreamBuilder<QueueState>(
          stream: audioHandler.queueState,
          builder: (context, snapshot) {
            final queueState = snapshot.data ?? QueueState.empty;
            return IconButton(
              iconSize: 40,
              icon: const Icon(Icons.skip_next_rounded),
              onPressed: queueState.hasNext ? audioHandler.skipToNext : null,
            );
          },
        ),
        StreamBuilder<double>(
          stream: audioHandler.speed,
          builder: (context, snapshot) => IconButton(
            icon: Text("${snapshot.data?.toStringAsFixed(1)}x",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              showSliderDialog(
                context: context,
                title: "Adjust speed",
                divisions: 10,
                min: 0.5,
                max: 1.5,
                value: audioHandler.speed.value,
                stream: audioHandler.speed,
                onChanged: audioHandler.setSpeed,
              );
            },
          ),
        ),
      ],
    );
  }
}

void showSliderDialog({
  required BuildContext context,
  required String title,
  required int divisions,
  required double min,
  required double max,
  String valueSuffix = '',
  required double value,
  required Stream<double> stream,
  required ValueChanged<double> onChanged,
}) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title, textAlign: TextAlign.center),
      content: StreamBuilder<double>(
        stream: stream,
        builder: (context, snapshot) => SizedBox(
          height: 100.0,
          child: Column(
            children: [
              Text('${snapshot.data?.toStringAsFixed(1)}$valueSuffix',
                  style: const TextStyle(
                      fontFamily: 'Fixed',
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0)),
              Slider(
                divisions: divisions,
                min: min,
                max: max,
                value: snapshot.data ?? value,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
