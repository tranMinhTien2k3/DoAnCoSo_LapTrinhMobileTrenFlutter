import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class ContentCard extends StatefulWidget {
  @override
  State<ContentCard> createState() => _ContentCardState();
}

class _ContentCardState extends State<ContentCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 100,
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _postHeader(),
            Spacer(),
              ElevatedButton(
                onPressed: () {
                  _showCommentDialog(context);
                },
                child: Text('Comment'),
              ),
          ],
        ),
    );
  }
}
Future<void> _showCommentDialog(BuildContext context) async {
    TextEditingController commentController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Comment'),
          content: Column(
            children: [
              // Text field for user to enter a comment
              TextField(
                controller: commentController,
                decoration: InputDecoration(labelText: 'Enter your comment'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Add your logic to handle the comment submission
                String userComment = commentController.text;
                print('Comment Submitted: $userComment');
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Submit'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
  
class _postHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.account_circle),
        const SizedBox(width: 8.0),
        Column(
          children: [
            Text("Name"),
          ],
        )
      ],
      
    );
  }
  
}