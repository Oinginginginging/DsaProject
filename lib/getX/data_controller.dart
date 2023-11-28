import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../dataClass/data_class.dart';

import 'package:flutter/material.dart';

class DataController extends GetxController {
  MeetingDataSource mMeetings = MeetingDataSource(getMeetingsDataSource());
}

List<Meeting> getMeetingsDataSource() {
  List<Meeting> meetings = <Meeting>[];
  final DateTime today = DateTime.now();
  final DateTime startTime =
      DateTime(today.year, today.month, today.day, 9, 0, 0);
  final DateTime endTime = startTime.add(const Duration(hours: 2));

  final DateTime startTime2 =
      DateTime(today.year, today.month, today.day, 12, 0, 0);
  final DateTime endTime2 = startTime2.add(const Duration(hours: 2));

  final DateTime startTime3 =
      DateTime(today.year, today.month, today.day, 15, 0, 0);
  final DateTime endTime3 = startTime3.add(const Duration(hours: 2));

  final DateTime startTime4 =
      DateTime(today.year, today.month, today.day, 17, 0, 0);
  final DateTime endTime4 = startTime4.add(const Duration(hours: 2));

  final DateTime startTime5 =
      DateTime(today.year, today.month, today.day, 28, 0, 0);
  final DateTime endTime5 = startTime4.add(const Duration(hours: 2));
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
  meetings.add(Meeting('Conference', startTime, endTime, Colors.blue, false,
      category: 'Official'));
  meetings.add(Meeting('Meeting', startTime2, endTime2, Colors.red, false));

  meetings.add(Meeting(
      'Hangout with friends', startTime3, endTime3, Colors.green, false));

  meetings.add(
      Meeting('Hangout and chill', startTime4, endTime4, Colors.orange, false));

  meetings.add(
      Meeting('Hangout and chill', startTime5, endTime5, Colors.pink, false));

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
    return _getMeetingData(index).background;
  }

  @override
  bool isAllDay(int index) {
    return _getMeetingData(index).isAllDay;
  }

  String getCategory(int index) {
    return _getMeetingData(index).category;
  }

  bool isDone(int index) {
    return _getMeetingData(index).isDone;
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

  void updateMeetingData(List<dynamic> newData) {
    List<dynamic> result = [];

    for (var item1 in appointments!) {
      DateTime from1 = item1.from;

      var item2 = newData.firstWhere((element) => element.from == from1,
          orElse: () =>
              Meeting("", DateTime(2000), DateTime(2000), Colors.white, false));

      result.add(item2.eventName == "" ? item1 : item2);
    }
    appointments = result;
  }

  void addMeetingData(dynamic newData) {
    appointments!.add(newData);
  }
}
