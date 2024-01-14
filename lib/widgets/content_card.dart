import 'package:flutter/material.dart';
import 'package:appdemo/models/content.dart';

class ContentCard extends StatelessWidget {
  final Content content;

  // Constructor để nhận dữ liệu Content
  ContentCard({required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              content.description,
              style: TextStyle(fontSize: 16),
            ),
            // Bạn có thể thêm các thành phần khác tùy thuộc vào yêu cầu cụ thể
          ],
        ),
      ),
    );
  }
}
