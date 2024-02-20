import 'package:flutter/material.dart';

class SingleNotification extends StatelessWidget {
  final String name;
  final String post;
  final String time;
  const SingleNotification({Key? key,
    required this.name,
    required this.post, 
    required this.time,
    }): super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      subtitle: Text( 
        post ,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(time),
    );
  }
}