import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tiktok_style_app/core/app.dart';

import 'data/models/local_video/local_video_model.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);

  // Register Hive adapters
  Hive.registerAdapter(LocalVideoModelAdapter());

  // Open Hive boxes
  await Hive.openBox<LocalVideoModel>('videos');

  runApp(
    const ProviderScope(
      child: TiktokStyleApp(),
    ),
  );
}
