import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class ScheduleScreen extends StatefulWidget {

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {

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
  DateTime today =DateTime.now();
  void _selectDated(DateTime day,DateTime focusedDay){
    setState(() {
      today = day;
    });
  }
  TextEditingController eventcontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _backButton(),
        title: Text("Quản lý lịch học"),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        showDialog(context: context, builder: (context){
          return AlertDialog(
            scrollable: true,
            title: Text("Event Name"),
            content: Padding(
              padding: EdgeInsets.all(20),
              child: TextField(controller: eventcontroller),
            ),

          );
        });
      },
      child: Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Text(
              "selected day: "+
              DateFormat('dd-MM-yyyy').format(today),
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            Container(
              child: TableCalendar(
                locale: "en_US",
                rowHeight: 43,
                headerStyle: HeaderStyle(formatButtonVisible: false,titleCentered: true),
                availableGestures: AvailableGestures.all,
                selectedDayPredicate: (day)=>isSameDay(day, today),
                focusedDay: today, 
                firstDay: DateTime.utc(2020,1,1), 
                lastDay: DateTime.utc(2030,1,1),
                onDaySelected: _selectDated,
                )
            ),
            
          ],
        ),
      )
    );

  }
}
