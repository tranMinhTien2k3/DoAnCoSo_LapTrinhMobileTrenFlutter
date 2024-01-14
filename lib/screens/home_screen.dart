import 'package:flutter/material.dart';
import 'package:appdemo/widgets/content_card.dart';
import 'package:appdemo/screens/content_detail_screen.dart';
import 'package:appdemo/screens/schedule_detail.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Popular Content',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            
          ],
        ),
      ),
    );
  }
}
