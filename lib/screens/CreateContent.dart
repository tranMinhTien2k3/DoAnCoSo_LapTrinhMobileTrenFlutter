import 'package:flutter/material.dart';

class CreateContent extends StatefulWidget {
  const CreateContent({super.key});

  @override
  State<CreateContent> createState() => _CreateContent();
}

class _CreateContent extends State<CreateContent>{
   Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.keyboard_arrow_left, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    
     return Scaffold(
      
      appBar: AppBar(
        leading: _backButton(),
        title: Text("Đăng tin"),
      ),
     );
  }
}