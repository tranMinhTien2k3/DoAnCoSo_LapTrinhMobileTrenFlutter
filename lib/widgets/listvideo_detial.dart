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
          ListTile(
            title: Text(widget.video.name),
            leading:CircleAvatar(
              radius: 20.0,
              backgroundImage: NetworkImage(widget.video.avt),
              backgroundColor: Colors.transparent,
            ),
          )
        ]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:() {
          setState(() {
            if(_controller.value.isPlaying){
              _controller.pause();
            }else{
              _controller.play();
            }
          });
        },
        child: Icon(_controller.value.isPlaying? Icons.pause:Icons.play_arrow),
      ),
    );
  }
}