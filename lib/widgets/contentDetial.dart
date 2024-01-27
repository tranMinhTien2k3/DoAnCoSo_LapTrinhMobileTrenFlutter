import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  final String userName;
  final String time;
  final String mainContent;
  final List<dynamic> imageURL;
  final String avt;

  CustomContainer({
    required this.userName,
    required this.time,
    required this.mainContent,
    required this.imageURL,
    required this.avt,
  }){
    // Loại bỏ các URL không hợp lệ hoặc trống khỏi danh sách imageURL
    imageURL.removeWhere((url) => url.isEmpty || !Uri.parse(url).isAbsolute);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.grey[200],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                      radius: 30.0,
                      backgroundImage: new NetworkImage(avt),
                      backgroundColor: Colors.transparent,
                    ),
                  SizedBox(width: 8.0),
                  Text(userName),
                ],
              ),
              Text(time),
            ],
          ),
          SizedBox(height: 12.0),
          Text(
            mainContent,
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.0),
          SizedBox(
  height: 150,
  child: ListView.builder (
    scrollDirection: Axis.horizontal,
    itemCount: imageURL.length,
    itemBuilder: (context, index) {
      return SizedBox(
        width: 200,
        height: 150,
        child: new Image.network(
          imageURL[index],
          fit: BoxFit.cover,
        ),
      );
    },
  ),
),

          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  // Xử lý khi người dùng nhấn nút like
                },
                icon: Icon(Icons.thumb_up),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/comment');
                },
                icon: Icon(Icons.comment),
              ),
            ],
          ),
          Container(
      height: 12,
      color: Color.fromARGB(255, 182, 218, 184),
    ),
        ],
      ),
    
    );
  }
}
