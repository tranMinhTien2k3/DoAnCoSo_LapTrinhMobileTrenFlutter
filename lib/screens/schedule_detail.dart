import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScheduleScreen extends StatefulWidget {
  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  CollectionReference users = FirebaseFirestore.instance.collection("Users");
  final user = FirebaseAuth.instance.currentUser;
  late String userId = "";
  bool _isLoggedIn() {
    if(user != null){
      userId = user!.uid;
      return true;
    }else return false;
  }
  List<Event> events = [];
  TextEditingController eventcontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getEventsFromFirestore(); // Fetch events when the screen loads
  }

  Future<void> _getEventsFromFirestore() async {
    if (_isLoggedIn()) {
      try {
        QuerySnapshot querySnapshot = await users.doc(userId).collection('events').get();
        setState(() {
          events = querySnapshot.docs.map((doc) => Event(
            uid: doc.id,
            eventName: doc['eventName'],
            date: (doc['date'] as Timestamp).toDate(),
          )).toList();
        });
      } catch (e) {
        print("Error fetching events: $e");
      }
    }
  }

  void _addEvent(String eventName, DateTime date) {
    if (_isLoggedIn()) {
      users.doc(userId).collection('events').add({
        'eventName': eventName,
        'date': date,
      }).then((docRef) {
        setState(() {
          events.add(Event(uid: docRef.id, eventName: eventName, date: date));
        });
      }).catchError((error) {
        print("Error adding event: $error");
      });
    }
  }

  void _editEvent(Event event, String newEventName, DateTime newDate) {
    if (_isLoggedIn()) {
      users.doc(userId).collection('events').doc(event.uid).update({
        'eventName': newEventName,
        'date': newDate,
      }).then((_) {
        setState(() {
          event.eventName = newEventName;
          event.date = newDate;
        });
      }).catchError((error) {
        print("Error updating event: $error");
      });
    }
  }

  void _deleteEvent(Event event) {
    if (_isLoggedIn()) {
      users.doc(userId).collection('events').doc(event.uid).delete().then((_) {
        setState(() {
          events.remove(event);
        });
      }).catchError((error) {
        print("Error deleting event: $error");
      });
    }
  }

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

  DateTime today = DateTime.now();

  void _selectDated(DateTime day, DateTime focusedDay) {
    setState(() {
      today = day;
    });
  }

  List<Event> _getEventsForDay(DateTime day) {
    return events.where((event) => isSameDay(event.date, day)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: _backButton(),
        title: Text("Quản lý lịch học"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                scrollable: true,
                title: Text("Event Name"),
                content: Padding(
                  padding: EdgeInsets.all(20),
                  child: TextField(controller: eventcontroller),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      _addEvent(eventcontroller.text, today);
                      Navigator.of(context).pop();
                    },
                    child: Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Text(
              "selected day: " + DateFormat('dd-MM-yyyy').format(today),
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            Container(
              child: TableCalendar(
                locale: "en_US",
                rowHeight: 43,
                headerStyle: HeaderStyle(
                  formatButtonVisible: false, titleCentered: true),
                availableGestures: AvailableGestures.all,
                selectedDayPredicate: (day) => isSameDay(day, today),
                focusedDay: today,
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 1, 1),
                onDaySelected: _selectDated,
                eventLoader: (day) {
                  final eventsForDay = _getEventsForDay(day);
                  return eventsForDay.isNotEmpty ? [Container(color: Colors.red)] : [];
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(events[index].eventName),
                    subtitle: Text(
                        DateFormat('dd-MM-yyyy').format(events[index].date)),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _deleteEvent(events[index]);
                      },
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            scrollable: true,
                            title: Text("Edit Event Name"),
                            content: Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  TextField(
                                    controller: TextEditingController(
                                        text: events[index].eventName),
                                    onChanged: (value) {
                                      events[index].eventName = value;
                                    },
                                  ),
                                  SizedBox(height: 20),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _editEvent(
                                          events[index],
                                          events[index].eventName,
                                          events[index].date);
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Save'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Event {
  String uid;
  String eventName;
  DateTime date;

  Event({required this.uid, required this.eventName, required this.date});
}
