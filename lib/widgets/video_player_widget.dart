import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    required this.color,
    required this.viewOnly,
  });

  final String videoUrl;
  final Color color;
  final bool viewOnly;

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late CachedVideoPlayerPlusController videoPlayerPlusController;
  late VideoPlayerController _controller;

  bool isPlaying = false;
  bool isLoading = true;
  double ratio = 1;

  @override
  void initState() {
    super.initState();
    videoPlayerPlusController = CachedVideoPlayerPlusController.networkUrl(
      Uri.parse(
        widget.videoUrl,
      ),
      httpHeaders: {
        'Connection': 'keep-alive',
      },
      invalidateCacheIfOlderThan: const Duration(days: 1),
    )..initialize().then((value) async {
        videoPlayerPlusController.play();
        setState(() {});
      });

    _controller = VideoPlayerController.networkUrl(Uri.parse(
      widget.videoUrl,
    ))
      ..initialize().then((_) {
        setState(() {
          ratio = _controller.value.aspectRatio;
          isLoading = false;
        });
      });
  }

  @override
  void dispose() {
    videoPlayerPlusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: ratio,
      child: Stack(
        children: [
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : CachedVideoPlayerPlus(videoPlayerPlusController),
          Center(
            child: IconButton(
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: widget.color,
              ),
              onPressed: widget.viewOnly
                  ? null
                  : () {
                      setState(() {
                        isPlaying = !isPlaying;
                        isPlaying
                            ? videoPlayerPlusController.play()
                            : videoPlayerPlusController.pause();
                      });
                    },
            ),
          ),
        ],
      ),
    );
  }
}
