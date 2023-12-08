import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter/material.dart';
import '../getX/data_controller.dart';
import 'package:prototype/dataClass/data_class.dart';
import 'package:flutter_spinner_time_picker/flutter_spinner_time_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class CalendarWeek extends StatefulWidget {
  final DataController dataController;

  const CalendarWeek({Key? key, required this.dataController}) : super(key: key);


  @override
  State<CalendarWeek> createState() => _CalendarWeek();
} //createState(): State 객체를 반환, stateful widget 처음 생성되는 순간에만 호출

class _CalendarWeek extends State<CalendarWeek> {
  /*DateTime? dragStart;
  DateTime? dragEnd;
  List<Meeting> meetings = [];*/

  @override
  Widget build(BuildContext context) {
    return  SfCalendar(
      showNavigationArrow: true,
      view: CalendarView.week,
      allowDragAndDrop: true,
      onDragEnd: (AppointmentDragEndDetails details) {
  // details에서 필요한 정보 추출
  dynamic appointment = details.appointment!;
  DateTime? draggingTime = details.droppingTime;

  // 드래그된 시간이 존재하는 경우에만 실행
  if (draggingTime != null) {
    // 새로운 드래그된 시간으로 일정을 업데이트
    setState(() {

      appointment.from = draggingTime;
      appointment.to = draggingTime.add(appointment.to.difference(appointment.from));
    });
  }
},
        
      timeSlotViewSettings: const TimeSlotViewSettings(
          timeInterval: Duration(minutes: 30),
          timeIntervalHeight: -1,
          timeFormat: 'HH:mm',
          dayFormat: 'EEE',
          timeRulerSize: 40,
          timeTextStyle:
              TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      dataSource: MeetingDataSource(_getDataSource()),
      monthViewSettings: const MonthViewSettings(
          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
    );
  
  }

  List<Meeting> _getDataSource() { //일정생성?
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
  
  // 얘는 언제 호출되는겅ㅁ?
  // 생성하면 -> 미팅클래스만들어서 리스트에 집어넣고 
  //-> 어포인트먼트로 바꾸고(젤 최근 인덱스를?)
  // 화면에 띄우면되는건가
  Appointment convertToCalendarAppointment(int index) {
    Meeting meeting = appointments![index];
    return Appointment(
      startTime: meeting.from,
      endTime: meeting.to,
      subject: meeting.eventName,
      color: meeting.background,
      isAllDay: meeting.isAllDay,
    ); 
}}

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}
