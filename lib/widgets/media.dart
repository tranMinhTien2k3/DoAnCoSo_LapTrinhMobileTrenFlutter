import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';


class MediaScreen extends StatelessWidget {
  final List<dynamic> mediaUrls;

  const MediaScreen({Key? key, required this.mediaUrls}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: mediaUrls.length,
        itemBuilder: (context, index) {
          final url = mediaUrls[index];
          bool _isVideoUrl(String url) {
            return url.contains("/video");
          }
          if (_isVideoUrl(url)) {
            return VideoWidget(videoUrl: url);
          } else {
            return ImageWidget(imageUrl: url);
          }

        },
      ),
    );
  }
}

class VideoWidget extends StatefulWidget {
  final String videoUrl;

  const VideoWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _controller;
  Duration? _videoDuration;
  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    Uri relativeUri = Uri.parse(widget.videoUrl);
    _controller = VideoPlayerController.networkUrl(
      relativeUri,
    )..initialize().then((_) {
      setState(() {
        _videoDuration = _controller.value.duration;
      });
    });
  }



  @override
  Widget build(BuildContext context) {
    return Center(
      child: _controller.value.isInitialized? 
      Stack(
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller) 
          ),
          if (_videoDuration != null) 
          Positioned(
            width: 70,
            height:30,
            right: 1.0,
            bottom: 1.0,
            child: Text(
              '${_videoDuration!.toString().split('.').first}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                backgroundColor: Colors.black,
              ),
            ),
            ),
        ],
      )
        : Container(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}


class ImageWidget extends StatelessWidget {
  final String imageUrl;

  const ImageWidget({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.network(imageUrl);
  }
}
