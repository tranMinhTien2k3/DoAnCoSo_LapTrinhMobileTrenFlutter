import 'package:appdemo/models/schedule.dart';
import 'package:flutter/material.dart';
import 'package:appdemo/widgets/scheduleitem.dart';
import 'package:appdemo/services/data_repository.dart';

class ScheduleScreen extends StatefulWidget {
  final DataRepository dataRepository;

  ScheduleScreen({required this.dataRepository});

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late Future<List<Schedule>> _scheduleFuture;

  @override
  void initState() {
    super.initState();
    _scheduleFuture = widget.dataRepository.getSchedule();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule'),
      ),
      body: FutureBuilder<List<Schedule>>(
        future: _scheduleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No schedule available.'),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ScheduleItem(schedule: snapshot.data![index]);
              },
            );
          }
        },
      ),
    );
  }
}
