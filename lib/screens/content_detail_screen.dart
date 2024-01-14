import 'package:flutter/material.dart';
import 'package:appdemo/models/content.dart';

class ContentDetailScreen extends StatelessWidget {
  final Content content;

  // Constructor để nhận dữ liệu Content
  ContentDetailScreen({required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Content Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              content.description,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            // Add additional widgets or components based on the content type (image, video, etc.)
          ],
        ),
      ),
    );
  }
}
