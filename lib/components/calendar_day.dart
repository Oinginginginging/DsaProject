import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter/material.dart';

class CalendarDay extends StatefulWidget {
  const CalendarDay({super.key});

  @override
  State<CalendarDay> createState() => _CalendarDay();
}

class _CalendarDay extends State<CalendarDay> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(children: [
      SfCalendar(
        showNavigationArrow: true,
        view: CalendarView.timelineDay,
        timeZone: 'Tokyo Standard Time',
        timeSlotViewSettings: const TimeSlotViewSettings(
            timeIntervalHeight: 10,
            timeInterval: Duration(minutes: 30),
            timeFormat: 'HH:mm',
            dayFormat: 'EEE',
            timeRulerSize: 40,
            timeTextStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        dataSource: MeetingDataSource(_getDataSource()),
        monthViewSettings: const MonthViewSettings(
            appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
      ),
      const SizedBox(
        height: 20,
      ),
      const Text(
        "TO-DO-LIST",
        style: TextStyle(fontWeight: FontWeight.bold),
      )
    ]));
  }

  List<Meeting> _getDataSource() {
    final List<Meeting> meetings = <Meeting>[];
    final DateTime today = DateTime.now();
    final DateTime startTime =
        DateTime(today.year, today.month, today.day, 9, 0, 0);
    final DateTime endTime = startTime.add(const Duration(hours: 2));
    meetings.add(Meeting('Conferenceadsfadsfasdffasd', startTime, endTime,
        const Color(0xFF0F8644), false));
    return meetings;
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}
