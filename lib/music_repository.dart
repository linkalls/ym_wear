import 'package:dart_ytmusic_api/types.dart';
import 'package:dart_ytmusic_api/yt_music.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// dart_ytmusic_apiラッパー
class MusicRepository {
  final YTMusic _ytmusic = YTMusic();
  bool _initialized = false;
  final YoutubeExplode _ytExplode = YoutubeExplode();

  Future<void> _init() async {
    if (!_initialized) {
      await _ytmusic.initialize();
      _initialized = true;
    }
  }

  Future<List<Map<String, String>>> searchMusic(String query) async {
    if (query.isEmpty) return [];
    await _init();
    try {
      final List<SongDetailed> results = await _ytmusic.searchSongs(query);
      if (results.isEmpty) return [];
      final List<Map<String, String>> tracks = [];
      for (final item in results) {
        tracks.add({
          'id': item.videoId,
          'title': item.name,
          'artist': item.artist.name,
          'album': item.album?.name ?? '',
          'duration': item.duration?.toString() ?? '',
        });
      }
      return tracks;
    } catch (e, stack) {
      print('searchMusic error: ' + e.toString());
      print(stack);
      return [];
    }
  }

  Future<Map<String, dynamic>> getMusicDetail(String id) async {
    await _init();
    try {
      final SongFull detail = await _ytmusic.getSong(id);
      final StreamManifest manifest = await _ytExplode.videos.streamsClient.getManifest(VideoId(id));
      final audioStream = manifest.audioOnly.withHighestBitrate();
      return {
        'id': detail.videoId,
        'title': detail.name,
        'artist': detail.artist.name,
        // 'album': detail.album?.name ?? '',
        'duration': detail.duration.toString(),
        'thumbnails': detail.thumbnails,
        'videoId': detail.videoId,
        'directUrl': audioStream.url.toString(),
      };
    } catch (e, stack) {
      print('getMusicDetail error: ' + e.toString());
      print(stack);
      return {
        'id': id,
        'title': '',
        'artist': '',
        'album': '',
        'duration': '',
        'thumbnails': [],
        'videoId': id,
        'directUrl': '',
      };
    }
  }

  // 他にも必要なAPIを追加

  Future<List<Map<String, String>>> getRelatedMusic(String videoId) async {
    await _init();
    try {
      final video = await _ytExplode.videos.get(VideoId(videoId));
      final relatedVideosList = await _ytExplode.videos.getRelatedVideos(video);
      if (relatedVideosList == null || relatedVideosList.isEmpty) return [];
      final List<Map<String, String>> tracks = [];
      for (final item in relatedVideosList) {
        tracks.add({
          'id': item.id.value,
          'title': item.title,
          'artist': item.author,
          'duration': item.duration?.toString() ?? '',
        });
      }
      return tracks;
    } catch (e, stack) {
      print('getRelatedMusic error: ' + e.toString());
      print(stack);
      return [];
    }
  }
}
