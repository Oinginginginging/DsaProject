import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter/material.dart';

class CalendarWeek extends StatefulWidget {
  const CalendarWeek({super.key}); //이 키는 뭐지

  @override
  State<CalendarWeek> createState() => _CalendarWeek();
} //createState(): State 객체를 반환, stateful widget 처음 생성되는 순간에만 호출

class _CalendarWeek extends State<CalendarWeek> {
  late List<Meeting> meetings;
  DateTime? dragStart;
  DateTime? dragEnd;

  @override
  void initState() {
    super.initState();
    meetings = _getDataSource();
  }

  @override
  Widget build(BuildContext context) { // 이 위젯이 들어있는 위젯트리에서의 위치를 가져옴.
    return SafeArea(
         child: GestureDetector(
           behavior: HitTestBehavior.translucent,
        onPanUpdate: (details) {
          print('Pan Update Details: $details');
          // 드래그 중인 영역 표시
          setState(() {
          dragEnd = dragStart != null && details.primaryDelta != null
          ? dragStart!.add(Duration(minutes: details.primaryDelta!.toInt()))
          : null;
          });
        },
        onPanStart: (details) {
          // 드래그 시작 시간 저장
          setState(() {
            dragStart = DateTime.now();
          });
        },
        
        onPanEnd: (details) {
  print('onPanEnd is called');
  print('dragStart at onPanEnd: $dragStart');
  print('dragEnd at onPanEnd: $dragEnd');

  // 드롭 시 새로운 일정 생성
  if (dragStart != null) {
    setState(() {
      // 적절한 드롭 로직 추가
      if (dragEnd == null) {
        // dragEnd 값이 null일 경우 현재 시간으로 설정
        dragEnd = DateTime.now();
      }

      print('Updated dragEnd at onPanEnd: $dragEnd');
      meetings.add(Meeting('New Meeting', dragStart!, dragEnd!, Colors.blue, false));
      dragStart = null;
      dragEnd = null;

      print('Number of meetings: ${meetings.length}');
    });
  }
},
        child: SfCalendar(
      showNavigationArrow: true,
      view: CalendarView.week,
      timeSlotViewSettings: const TimeSlotViewSettings(
          timeInterval: Duration(minutes: 10),
          timeIntervalHeight: 10,
          startHour: 4,
          endHour: 3,
          timeFormat: 'HH:mm',
          dayFormat: 'EEE',
          timeRulerSize: 40,
          timeTextStyle:
              TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      dataSource: MeetingDataSource(_getDataSource()),
      monthViewSettings: const MonthViewSettings(
          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
          
    )));
  }

  List<Meeting> _getDataSource() {
    final List<Meeting> meetings = <Meeting>[];
    final DateTime today = DateTime.now();
    final DateTime startTime =
        DateTime(today.year, today.month, today.day, 9, 0, 0);
    final DateTime endTime = startTime.add(const Duration(hours: 2));
    meetings.add(Meeting('Conferenceadsfasdfasdf', startTime, endTime,
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

