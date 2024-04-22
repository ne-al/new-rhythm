import 'package:audio_handler/audio_handler.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rhythm/app/components/miniplayer/miniplayer.dart';
import 'package:rhythm/app/screens/pages/home/presentation/home.dart';
import 'package:rhythm/app/screens/pages/view/player/presentation/player.dart';

late AudioPlayerHandler audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandlerImpl(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.neal.music_rhythm.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    ),
  );

  await FlutterDisplayMode.setHighRefreshRate();

  runApp(
    const ProviderScope(
      child: RhythmApp(),
    ),
  );
}

class RhythmApp extends StatelessWidget {
  const RhythmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ).copyWith(
          background: Colors.black,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
      builder: (context, child) {
        return Scaffold(
          floatingActionButton:
              _shouldShowMiniPlayer(context) ? const MiniPlayer() : null,
          body: child,
        );
      },
      routes: {
        '/musicPlayer': (context) => const MusicPlayer(),
        // Add more routes as needed
      },
    );
  }

  static bool _shouldShowMiniPlayer(BuildContext context) {
    // Get the current route
    final route = ModalRoute.of(context);

    // Check if the route is not null
    if (route != null) {
      // Determine if MiniPlayer should be shown based on the route
      return !(route is MaterialPageRoute &&
          route.settings.name == '/musicPlayer');
    }

    // Default to showing MiniPlayer if route information is not available
    return true;
  }
}
