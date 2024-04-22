import 'package:audio_handler/audio_handler.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:rhythm/app/components/listtile/song_listtile.dart';
import 'package:rhythm/main.dart';

Future showQueueView(BuildContext context, BoxConstraints constraints) {
  return showMaterialModalBottomSheet(
    context: context,
    enableDrag: true,
    isDismissible: true,
    builder: (context) => SizedBox(
      height: constraints.maxHeight * 0.45,
      child: StreamBuilder<QueueState>(
        stream: audioHandler.queueState,
        builder: (context, snapshot) {
          final queueState = snapshot.data ?? QueueState.empty;
          final queue = queueState.queue;
          return ReorderableListView(
            onReorder: (int oldIndex, int newIndex) {
              if (oldIndex < newIndex) newIndex--;
              audioHandler.moveQueueItem(oldIndex, newIndex);
            },
            children: [
              for (var i = 0; i < queue.length; i++)
                Dismissible(
                  key: ValueKey(queue[i].id),
                  background: Container(
                    color: Colors.redAccent,
                    alignment: Alignment.centerRight,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                  ),
                  onDismissed: (dismissDirection) {
                    audioHandler.removeQueueItemAt(i);
                  },
                  child: Material(
                    color: i == queueState.queueIndex
                        ? Theme.of(context).colorScheme.onSecondary
                        : null,
                    child: SongListTile(
                      data: queue[i],
                      constraints: constraints,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    ),
  );
}
