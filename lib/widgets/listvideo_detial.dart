import 'package:appdemo/common/video.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
class VideoDetailPage extends StatefulWidget {
  final Video video;
  const VideoDetailPage({Key? key, required this.video}) : super(key: key);
  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  late VideoPlayerController _controller;
  late Future<void> _videoPlayerFuture;
  @override
  void initState(){
    Uri relativeUri = Uri.parse(widget.video.thumbnailUrl);
    _controller = VideoPlayerController.networkUrl(relativeUri);
    _videoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
    _controller.setVolume(1.0);
    super.initState();
  }
  void _seekVideo(double value) {
    setState(() {
      final Duration duration = _controller.value.duration;
      final newPosition = value * duration.inMilliseconds;
      _controller.seekTo(Duration(milliseconds: newPosition.toInt()));
    });
  }
  bool _isPlaying = false;
  double _currentSliderValue = 0.0;
  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 182, 218, 184),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(widget.video.title),
      ),
      body:Column( 
        children: [ 
          Stack(
            children: [
              FutureBuilder(
                future: _videoPlayerFuture,
                builder: (context, snapshot) {
                  if(snapshot.connectionState == ConnectionState.done){
                    return AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    );
                  } else {
                    return Center(child: CircularProgressIndicator(),);
                  }
                },
              ),
              Center(
                heightFactor: 3,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _isPlaying = !_isPlaying;
                      if (_isPlaying) {
                        _controller.play();
                      } else {
                        _controller.pause();
                      }
                    });
                  },
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                bottom: 1.0,
                left: 1.0,
                right: 1.0,
                child: Slider(
                  value: _currentSliderValue,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (double value) {
                    setState(() {
                      _currentSliderValue = value;
                    });
                  },
                  onChangeEnd: _seekVideo,
                ),
              )
            ],
          ),
          ListTile(
            title: Text(widget.video.name),
            leading:CircleAvatar(
              radius: 20.0,
              backgroundImage: NetworkImage(widget.video.avt),
              backgroundColor: Colors.transparent,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              'Bình luận',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: Center(
                child: Text('Placeholder for comment section'), // Thay bằng phần hiển thị bình luận thực tế
              ),
            ),
          ),
        ]
      ),
    );
  }
}