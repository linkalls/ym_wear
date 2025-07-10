import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:ym_wear/music_repository.dart';

class MusicPlayerPage extends StatefulWidget {
  final String? musicId;
  final String? title;

  const MusicPlayerPage({super.key, this.musicId, this.title});

  @override
  State<MusicPlayerPage> createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  Map<String, dynamic>? _musicDetails;
  bool _isLoading = true;
  late AudioPlayer _audioPlayer;
  bool _navigated = false; // 追加

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.playerStateStream.listen((state) async {
      if (state.processingState == ProcessingState.completed && !_navigated) {
        _navigated = true; // 1回だけ遷移
        if (widget.musicId != null && mounted) {
          final repo = MusicRepository();
          final related = await repo.getRelatedMusic(widget.musicId!);
          if (related.isNotEmpty && related[0]['id'] != null) {
            final nextId = related[0]['id']!;
            final nextTitle = related[0]['title'] ?? '';
            if (mounted) {
              GoRouter.of(context).go('/player/$nextId', extra: nextTitle);
            }
          }
        }
      }
    });
    _fetchMusicDetails();
  }

  Future<void> _fetchMusicDetails() async {
    if (widget.musicId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    try {
      final repo = MusicRepository();
      final details = await repo.getMusicDetail(widget.musicId!);
      setState(() {
        _musicDetails = details;
        _isLoading = false;
      });
      if (_musicDetails != null && _musicDetails!['directUrl'] != null) {
        await _audioPlayer.setUrl(_musicDetails!['directUrl']);
        _audioPlayer.play();
      }
    } catch (e) {
      print('Error fetching music details: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigitMinutes}:${twoDigitSeconds}';
  }

  Widget _buildPlayerBody() {
    if (_isLoading) {
      return const CircularProgressIndicator();
    } else if (_musicDetails != null && _musicDetails!['directUrl'] != null) {
      return Column(
        children: [
          const SizedBox(height: 20),
          StreamBuilder<Duration?>(
            stream: _audioPlayer.durationStream,
            builder: (context, snapshot) {
              final duration = snapshot.data ?? Duration.zero;
              return StreamBuilder<Duration>(
                stream: _audioPlayer.positionStream,
                builder: (context, posSnapshot) {
                  final position = posSnapshot.data ?? Duration.zero;
                  return Column(
                    children: [
                      Slider(
                        value: position.inMilliseconds.toDouble().clamp(
                          0,
                          duration.inMilliseconds.toDouble(),
                        ),
                        min: 0,
                        max: duration.inMilliseconds.toDouble() > 0
                            ? duration.inMilliseconds.toDouble()
                            : 1,
                        onChanged: (v) {
                          _audioPlayer.seek(Duration(milliseconds: v.toInt()));
                        },
                        activeColor: Colors.white,
                        inactiveColor: Colors.white24,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(position),
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _formatDuration(duration),
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.replay_10, color: Colors.white),
                  iconSize: 32,
                  tooltip: '10秒戻す',
                  onPressed: () async {
                    final pos = await _audioPlayer.position;
                    _audioPlayer.seek(pos - Duration(seconds: 10));
                  },
                ),
                const SizedBox(width: 4),
                StreamBuilder<PlayerState>(
                  stream: _audioPlayer.playerStateStream,
                  builder: (context, snapshot) {
                    final playerState = snapshot.data;
                    final processingState = playerState?.processingState;
                    final playing = playerState?.playing;
                    if (processingState == ProcessingState.loading ||
                        processingState == ProcessingState.buffering) {
                      return const SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(),
                      );
                    } else if (playing != true) {
                      return IconButton(
                        icon: const Icon(Icons.play_arrow, color: Colors.white),
                        iconSize: 48.0,
                        onPressed: _audioPlayer.play,
                      );
                    } else if (processingState != ProcessingState.completed) {
                      return IconButton(
                        icon: const Icon(Icons.pause, color: Colors.white),
                        iconSize: 48.0,
                        onPressed: _audioPlayer.pause,
                      );
                    } else {
                      return IconButton(
                        icon: const Icon(Icons.replay, color: Colors.white),
                        iconSize: 48.0,
                        onPressed: () => _audioPlayer.seek(Duration.zero),
                      );
                    }
                  },
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(Icons.forward_10, color: Colors.white),
                  iconSize: 32,
                  tooltip: '10秒進める',
                  onPressed: () async {
                    final pos = await _audioPlayer.position;
                    final dur = await _audioPlayer.duration ?? Duration.zero;
                    _audioPlayer.seek(
                      (pos + Duration(seconds: 10)) < dur
                          ? pos + Duration(seconds: 10)
                          : dur,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return const Text(
        'Direct URL not available.',
        style: TextStyle(fontSize: 14, color: Colors.white54),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? 'Music Player')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Now Playing: ${widget.title ?? 'Unknown'}',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              if (widget.musicId != null)
                Text(
                  'Music ID: ${widget.musicId}',
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              const SizedBox(height: 20),
              _buildPlayerBody(),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
