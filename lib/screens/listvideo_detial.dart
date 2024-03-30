import 'package:appdemo/common/toast.dart';
import 'package:appdemo/common/video.dart';
import 'package:appdemo/widgets/media.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:timeago/timeago.dart' as timeago;

class VideoDetailPage extends StatefulWidget {
  final ListVideo lvid;
  final Video video;
  final String time;

  const VideoDetailPage({
    Key? key,
    required this.video,
    required this.lvid,
    required this.time,
  }) : super(key: key);

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  late VideoPlayerController _controller;
  late Future<void> _videoPlayerFuture;
  bool _isPlaying = false;
  double _currentSliderValue = 0.0;

  @override
  void initState() {
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color.fromARGB(255, 220, 255, 231),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Video"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              FutureBuilder(
                future: _videoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
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
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.video.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.time,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            title: Text(
              widget.video.name,
              style: TextStyle(fontSize: 16),
            ),
            leading: CircleAvatar(
              radius: 20.0,
              backgroundImage: NetworkImage(widget.video.avt),
              backgroundColor: Colors.transparent,
            ),
          ),
          Divider(),
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'Danh sách: ${widget.lvid.genre}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.lvid.lVid.length,
              itemBuilder: (context, index) {
                return FutureBuilder<Map<String, dynamic>>(
                  future: getUserData(widget.lvid.lVid[index]['UserId']),
                  builder: (context, userSnapshot) {
                    DateTime dateTime =
                        widget.lvid.lVid[index]['time'].toDate();
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (userSnapshot.hasError) {
                      print(userSnapshot.error);
                      return Text('Error: ${userSnapshot.error}');
                    } else {
                      if (widget.lvid.lVid[index]['url'] !=
                          widget.video.thumbnailUrl) {
                        String userName =
                            userSnapshot.data?['fist name'] + ' ' + userSnapshot.data?['last name'];
                        String avtUrl = userSnapshot.data?['image'] ?? '';
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VideoDetailPage(
                                  video: Video(
                                    title: widget.lvid.lVid[index]['title'],
                                    thumbnailUrl: widget.lvid.lVid[index]['url'],
                                    name: userName,
                                    avt: avtUrl,
                                  ),
                                  lvid: widget.lvid,
                                  time: timeago.format(dateTime),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            height: 135,
                            padding: EdgeInsets.all(15),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: VideoWidget(
                                    videoUrl: widget.lvid.lVid[index]['url'],
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.lvid.lVid[index]['title'],
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        userName,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        timeago.format(dateTime),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return Text("");
                      }
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
