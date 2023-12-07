import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter/material.dart';
import '../getX/data_controller.dart';

class CalendarWeek extends StatefulWidget {
  final DataController dataController;

  const CalendarWeek(this.dataController, {Key? key}) : super(key: key);

  @override
  State<CalendarWeek> createState() => _CalendarWeek();
}

class _CalendarWeek extends State<CalendarWeek> {
  late DataController dataController;
  @override
  Widget build(BuildContext context) {
    dataController = widget.dataController;
    return SafeArea(
        child: SfCalendar(
      showNavigationArrow: true,
      onTap: _onTappedEvent,
      view: CalendarView.week,
      timeSlotViewSettings: const TimeSlotViewSettings(
          timeInterval: Duration(minutes: 60),
          timeIntervalHeight: -1,
          timeFormat: 'HH:mm',
          dayFormat: 'EEE',
          timeRulerSize: 40,
          timeTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      dataSource: dataController.mMeetings,
    ));
  }

  void _onTappedEvent(CalendarTapDetails details) {
    if (details.date == null) return;
    print(details.targetElement);
  }
}
