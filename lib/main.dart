import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tiktok_style_app/utils/memory_manager.dart';
import 'data/models/audio_model/audio_model.dart';
import 'data/models/local_video_model/local_video_model.dart';
import 'di/injection.dart';
import 'presentation/app.dart';

void main() async {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('Flutter error caught: ${details.exception}');
  };

  WidgetsFlutterBinding.ensureInitialized();

  SystemChannels.system.setMessageHandler((msg) async {
    if (msg == 'memoryPressure') {
      MemoryManager().triggerMemoryCleanup();
    }
    return null;
  });

  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);

  Hive.registerAdapter(LocalVideoModelAdapter());
  Hive.registerAdapter(AudioModelAdapter());

  final videosBox = await Hive.openBox<LocalVideoModel>('videos');
  final audiosBox = await Hive.openBox<AudioModel>('audios');

  print(
      'Initialized Hive boxes: videos (${videosBox.length} items), audios (${audiosBox.length} items)');

  await configureDependencies();

  runApp(
    const ProviderScope(
      child: TikTokCloneApp(),
    ),
  );
}
