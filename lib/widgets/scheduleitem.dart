import 'package:flutter/material.dart';
import 'package:appdemo/models/schedule.dart';

class ScheduleItem extends StatelessWidget {
  final Schedule schedule;

  // Constructor để nhận dữ liệu Schedule
  ScheduleItem({required this.schedule});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(schedule.eventName),
      subtitle: Text('${schedule.date} - ${schedule.time}'),
      // Bạn có thể thêm các thành phần khác tùy thuộc vào yêu cầu cụ thể
    );
  }
}
