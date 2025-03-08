import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:async';

class VideoCacheManager {
  static final VideoCacheManager _instance = VideoCacheManager._internal();
  factory VideoCacheManager() => _instance;
  VideoCacheManager._internal();

  final Map<String, String> _cachedVideos = {};
  late final Directory _cacheDir;
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      _cacheDir = await getTemporaryDirectory();
      _initialized = true;
    }
  }

  String _generateCacheKey(String url) {
    final bytes = utf8.encode(url);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<String?> getCachedVideoPath(String url) async {
    await _ensureInitialized();

    if (_cachedVideos.containsKey(url)) {
      final filePath = _cachedVideos[url]!;
      if (await File(filePath).exists()) {
        return filePath;
      }
    }

    final cacheKey = _generateCacheKey(url);
    final cachedFile = File('${_cacheDir.path}/video_$cacheKey.mp4');

    if (await cachedFile.exists()) {
      _cachedVideos[url] = cachedFile.path;
      return cachedFile.path;
    }

    return null;
  }

  Future<String?> precacheVideo(String url) async {
    await _ensureInitialized();

    final cachedPath = await getCachedVideoPath(url);
    if (cachedPath != null) {
      return cachedPath;
    }

    try {
      final cacheKey = _generateCacheKey(url);
      final cachedFile = File('${_cacheDir.path}/video_$cacheKey.mp4');

      final client = http.Client();
      try {
        final request = http.Request('GET', Uri.parse(url));
        final response = await client.send(request).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw TimeoutException('Video download timed out');
          },
        );

        if (response.statusCode == 200) {
          final bytes = await response.stream.toBytes();
          await cachedFile.writeAsBytes(bytes);
          _cachedVideos[url] = cachedFile.path;
          return cachedFile.path;
        }
      } finally {
        client.close();
      }
    } catch (e) {
      print('Error caching video: $e');
    }

    return null;
  }

  Future<void> clearCache() async {
    await _ensureInitialized();

    try {
      final files = _cacheDir.listSync();
      for (final file in files) {
        if (file is File && file.path.contains('video_')) {
          await file.delete();
        }
      }
      _cachedVideos.clear();
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
}
