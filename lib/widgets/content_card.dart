import 'package:flutter/material.dart';
class ContentCard extends StatefulWidget {
  @override
  State<ContentCard> createState() => _ContentCardState();
}

class _ContentCardState extends State<ContentCard> {
  List<bool> isSelected = [false, false, false];

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(20.0),
        color: Colors.grey,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.abc),
              SizedBox(width: 8.0),
              Text(
                " Name",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Text("content"),
          Row(
           children: [
             ToggleButtons(
               children: [
                 Icon(Icons.favorite),
                 Icon(Icons.thumb_up),
                 Icon(Icons.star),
               ],
               isSelected: isSelected,
                onPressed: (int index) {
                  
                 setState(() {
                   isSelected[index] = !isSelected[index];
                 });
          },
        ),
        SizedBox(height: 20),
        
      ],

          ),
        ],
      ),
        
    );
  }

    String getSelectedEmojis() {
    List<String> emojis = ['❤️', '👍', '⭐'];

    List<String> selectedEmojis = [];
    for (int i = 0; i < isSelected.length; i++) {
      if (isSelected[i]) {
        selectedEmojis.add(emojis[i]);
      }
    }

    return selectedEmojis.isEmpty ? 'Chưa chọn' : selectedEmojis.join(' ');
  }
}
