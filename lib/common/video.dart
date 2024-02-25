class Video {
  final String title;
  final String thumbnailUrl;
  final String name;
  final String avt;
  Video({
    required this.title,
    required this.thumbnailUrl,
    required this.avt,
    required this.name
  });
}

class ListVideo{
  final List lVid;
  final String genre;

  ListVideo({required this.lVid, required this.genre});
}


