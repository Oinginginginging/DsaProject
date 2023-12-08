import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../dataClass/data_class.dart';

import 'package:flutter/material.dart';

class DataController extends GetxController {
  MeetingDataSource mMeetings = MeetingDataSource(getMeetingsDataSource());

  void updateMeeting(dynamic newData) {
    mMeetings.updateMeetingData(newData);
    update();
  }
}

List<Meeting> getMeetingsDataSource() {
  List<Meeting> meetings = <Meeting>[];
  final DateTime today = DateTime.now();
  final DateTime startTime = DateTime(today.year, today.month, today.day, 9, 0, 0);
  final DateTime endTime = startTime.add(const Duration(hours: 2));

  final DateTime startTime2 = DateTime(today.year, today.month, today.day, 12, 0, 0);
  final DateTime endTime2 = startTime2.add(const Duration(hours: 2));

  final DateTime startTime3 = DateTime(today.year, today.month, today.day, 15, 0, 0);
  final DateTime endTime3 = startTime3.add(const Duration(hours: 2));

  final DateTime startTime4 = DateTime(today.year, today.month, today.day, 17, 0, 0);
  final DateTime endTime4 = startTime4.add(const Duration(hours: 2));

  final DateTime startTime5 = DateTime(today.year, today.month, today.day + 1, 4, 0, 0);
  final DateTime endTime5 = startTime5.add(const Duration(hours: 2));
  /* recurrence rule
    - FREQ : DIALY, WEEKLY, MONTHLY, YEARLY, EVERYWEEKDAY
    - INTERVEL : Number
    - COUNT : Number
    - UNTIL : 
    - BYDAY : MO, WE
    - BYMONTHDAY :
    - BYMONTH :
    - BYSETPOS :
  */
  meetings.add(Meeting(id: 1, eventName: 'Conference', from: startTime, to: endTime, color: Colors.blue, category: 'Official'));
  meetings.add(Meeting(id: 2, eventName: 'Meeting', from: startTime2, to: endTime2, color: Colors.red));

  meetings.add(Meeting(id: 3, eventName: 'Hangout with friends', from: startTime3, to: endTime3, color: Colors.green));

  meetings.add(Meeting(id: 4, eventName: 'Hangout and chill', from: startTime4, to: endTime4, color: Colors.orange));

  meetings.add(Meeting(id: 5, eventName: 'Do Something', from: startTime5, to: endTime5, color: Colors.pink));

  return meetings;
}

class MeetingDataSource extends CalendarDataSource {
  /// Creates a meeting data source, which used to set the appointment
  /// collection to the calendar
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return _getMeetingData(index).from;
  }

  @override
  DateTime getEndTime(int index) {
    return _getMeetingData(index).to;
  }

  @override
  String getSubject(int index) {
    return _getMeetingData(index).eventName;
  }

  @override
  Color getColor(int index) {
    return _getMeetingData(index).color;
  }

  @override
  bool isAllDay(int index) {
    return _getMeetingData(index).isAllDay;
  }

  @override
  String? getRecurrenceRule(int index) {
    return appointments![index].recurrenceRule;
  }

  String getCategory(int index) {
    return _getMeetingData(index).category;
  }

  bool isDone(int index) {
    return _getMeetingData(index).isDone;
  }

  bool showTriangularMark(int index) {
    return _getMeetingData(index).showTriangularMark;
  }

  List<String> categoryList() {
    return [
      'None',
      'Official',
      'Private',
    ];
  }

  Meeting _getMeetingData(int index) {
    final dynamic meeting = appointments![index];
    late final Meeting meetingData;
    if (meeting is Meeting) {
      meetingData = meeting;
    }

    return meetingData;
  }

  void updateMeetingData(dynamic newData) {
    List<dynamic> result = [];

    for (var item1 in appointments!) {
      String eventName1 = item1.eventName;

      if (eventName1 == newData.eventName) {
        result.add(newData);
      } else {
        result.add(item1);
      }
    }
    appointments = result;

    notifyListeners(CalendarDataSourceAction.reset, appointments!);
  }
}
