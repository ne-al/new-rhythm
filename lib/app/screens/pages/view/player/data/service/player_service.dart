import 'package:audio_service/audio_service.dart';
import 'package:rhythm/main.dart';
import 'package:rxdart/rxdart.dart';

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}

Stream<Duration> get _bufferedPositionStream => audioHandler.playbackState
    .map((state) => state.bufferedPosition)
    .distinct();
Stream<Duration?> get _durationStream =>
    audioHandler.mediaItem.map((item) => item?.duration).distinct();
Stream<PositionData> get positionDataStream =>
    Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        AudioService.position,
        _bufferedPositionStream,
        _durationStream,
        (position, bufferedPosition, duration) => PositionData(
            position, bufferedPosition, duration ?? Duration.zero));
