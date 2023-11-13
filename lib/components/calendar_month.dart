import 'dart:math';

import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter/material.dart';

class CalendarMonth extends StatefulWidget {
  const CalendarMonth({Key? key}) : super(key: key);

  @override
  State<CalendarMonth> createState() => _CalendarMonthState();
}

class _CalendarMonthState extends State<CalendarMonth> {
  late _AppointmentDataSource _dataSource;
  final CalendarController _calendarController = CalendarController();
  final ScrollController _scrollController = ScrollController();
  final List<Color> _colorCollection = <Color>[];
  final List<String> _colorNames = <String>[];

  final List<CalendarView> _allowedViews = <CalendarView>[
    CalendarView.day,
    CalendarView.week,
    CalendarView.workWeek,
    CalendarView.month,
    CalendarView.schedule
  ];

  final GlobalKey _globalKey = GlobalKey();
  late List<DateTime> _visibleDates;
  CalendarView _view = CalendarView.week;

  Appointment? _selectedAppointment;
  bool _isAllDay = false;
  String _subject = '';
  int _selectedColorIndex = 0;

  @override
  void initState() {
    _calendarController.selectedDate = DateTime.now();
    _dataSource = _AppointmentDataSource(_getRecursiveAppointments());
    super.initState();
  }

  void _onCalendarTapped(CalendarTapDetails calendarTapDetails) {
    if (calendarTapDetails.targetElement == CalendarElement.header ||
        calendarTapDetails.targetElement == CalendarElement.viewHeader) {
      return;
    }

    _selectedAppointment = null;
    if (_calendarController.view == CalendarView.month) {
      _calendarController.view = CalendarView.day;
    } else {
      if (calendarTapDetails.appointments != null &&
          calendarTapDetails.targetElement == CalendarElement.appointment) {
        final dynamic appointment = calendarTapDetails.appointments![0];
        if (appointment is Appointment) {
          _selectedAppointment = appointment;
        }
      }
    }

    final DateTime selectedDate = calendarTapDetails.date!;
    final CalendarElement targetElement = calendarTapDetails.targetElement;

    final bool isAppointmentTapped =
        calendarTapDetails.targetElement == CalendarElement.appointment;
    /*showDialog<Widget>(
        context: context,
        builder: (BuildContext context) {
          final List<Appointment> appointment = <Appointment>[];
          Appointment? newAppointment;

          /// Creates a new appointment, which is displayed on the tapped
          /// calendar element, when the editor is opened.
          if (_selectedAppointment == null) {
            _isAllDay =
                calendarTapDetails.targetElement == CalendarElement.allDayPanel;
            _selectedColorIndex = 0;
            _subject = '';
            final DateTime date = calendarTapDetails.date!;

            newAppointment = Appointment(
              startTime: date,
              endTime: date.add(const Duration(hours: 1)),
              color: _colorCollection[_selectedColorIndex],
              isAllDay: _isAllDay,
              subject: _subject == '' ? '(No title)' : _subject,
            );
            appointment.add(newAppointment);

            _dataSource.appointments.add(appointment[0]);

            _selectedAppointment = newAppointment;
          }

          return WillPopScope(
            onWillPop: () async {
              if (newAppointment != null) {
                /// To remove the created appointment when the pop-up closed
                /// without saving the appointment.
                _dataSource.appointments
                    .removeAt(_dataSource.appointments.indexOf(newAppointment));
                _dataSource.notifyListeners(CalendarDataSourceAction.remove,
                    <Appointment>[newAppointment]);
              }
              return true;
            },
            child: Center(
                child: SizedBox(
                    width: isAppointmentTapped ? 400 : 500,
                    height: isAppointmentTapped
                        ? (_selectedAppointment!.location == null ||
                                _selectedAppointment!.location!.isEmpty
                            ? 150
                            : 200)
                        : 400,
                    child: Theme(
                        data: ThemeData(colorScheme: const ColorScheme.light()),
                        child: Card(
                          margin: EdgeInsets.zero,
                          color: Theme.of(context).colorScheme.primaryContainer,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4))),
                          child: isAppointmentTapped
                              ? displayAppointmentDetails(
                                  context,
                                  targetElement,
                                  selectedDate,
                                  _selectedAppointment!,
                                  _colorCollection,
                                  _colorNames,
                                  _dataSource,
                                  _visibleDates)
                              : PopUpAppointmentEditor(
                                  newAppointment,
                                  appointment,
                                  _dataSource,
                                  _colorCollection,
                                  _colorNames,
                                  _selectedAppointment!,
                                  _visibleDates),
                        )))),
          );
        });*/
  }

  @override
  Widget build(BuildContext context) {
    final Widget calendar = Theme(
        key: _globalKey,
        data: ThemeData(colorScheme: const ColorScheme.light()),
        child: _getRecurrenceCalendar(
            _calendarController, _dataSource, _onCalendarTapped));
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
                width: 2.0,
                color: Theme.of(context).colorScheme.primaryContainer),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.fromLTRB(80, 10, 80, 10),
          child: const Text("날씨가 어제보다 5도 낮아요! \n 외투를 챙기세요!",
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(
            child: Scrollbar(
                controller: _scrollController,
                child: ListView(
                  controller: _scrollController,
                  children: <Widget>[
                    SizedBox(
                      height: 600,
                      child: calendar,
                    )
                  ],
                ))),
      ],
    );
  }

  List<Appointment> _getRecursiveAppointments() {
    _colorNames.add('Green');
    _colorNames.add('Purple');
    _colorNames.add('Red');
    _colorNames.add('Orange');
    _colorNames.add('Caramel');
    _colorNames.add('Light Green');
    _colorNames.add('Blue');
    _colorNames.add('Peach');
    _colorNames.add('Gray');

    _colorCollection.add(const Color(0xFF0F8644));
    _colorCollection.add(const Color(0xFF8B1FA9));
    _colorCollection.add(const Color(0xFFD20100));
    _colorCollection.add(const Color(0xFFFC571D));
    _colorCollection.add(const Color(0xFF36B37B));
    _colorCollection.add(const Color(0xFF01A1EF));
    _colorCollection.add(const Color(0xFF3D4FB5));
    _colorCollection.add(const Color(0xFFE47C73));
    _colorCollection.add(const Color(0xFF636363));

    final List<Appointment> appointments = <Appointment>[];
    final Random random = Random();
    //Recurrence Appointment 1
    final DateTime currentDate = DateTime.now();
    final DateTime startTime =
        DateTime(currentDate.year, currentDate.month, currentDate.day, 9);
    final DateTime endTime =
        DateTime(currentDate.year, currentDate.month, currentDate.day, 11);
    final RecurrenceProperties recurrencePropertiesForAlternativeDay =
        RecurrenceProperties(
            startDate: startTime,
            interval: 2,
            recurrenceRange: RecurrenceRange.count,
            recurrenceCount: 20);
    final Appointment alternativeDayAppointment = Appointment(
        startTime: startTime,
        endTime: endTime,
        color: _colorCollection[random.nextInt(8)],
        subject: 'Scrum meeting',
        recurrenceRule: SfCalendar.generateRRule(
            recurrencePropertiesForAlternativeDay, startTime, endTime));

    appointments.add(alternativeDayAppointment);

    //Recurrence Appointment 2
    final DateTime startTime1 =
        DateTime(currentDate.year, currentDate.month, currentDate.day, 13);
    final DateTime endTime1 =
        DateTime(currentDate.year, currentDate.month, currentDate.day, 15);
    final RecurrenceProperties recurrencePropertiesForWeeklyAppointment =
        RecurrenceProperties(
      startDate: startTime1,
      recurrenceType: RecurrenceType.weekly,
      recurrenceRange: RecurrenceRange.count,
      weekDays: <WeekDays>[WeekDays.monday],
      recurrenceCount: 20,
    );

    final Appointment weeklyAppointment = Appointment(
        startTime: startTime1,
        endTime: endTime1,
        color: _colorCollection[random.nextInt(8)],
        subject: 'product development status',
        recurrenceRule: SfCalendar.generateRRule(
            recurrencePropertiesForWeeklyAppointment, startTime1, endTime1));

    appointments.add(weeklyAppointment);

    final DateTime startTime2 =
        DateTime(currentDate.year, currentDate.month, currentDate.day, 14);
    final DateTime endTime2 =
        DateTime(currentDate.year, currentDate.month, currentDate.day, 15);
    final RecurrenceProperties recurrencePropertiesForMonthlyAppointment =
        RecurrenceProperties(
            startDate: startTime2,
            recurrenceType: RecurrenceType.monthly,
            recurrenceRange: RecurrenceRange.count,
            recurrenceCount: 10);

    final Appointment monthlyAppointment = Appointment(
        startTime: startTime2,
        endTime: endTime2,
        color: _colorCollection[random.nextInt(8)],
        subject: 'Sprint planning meeting',
        recurrenceRule: SfCalendar.generateRRule(
            recurrencePropertiesForMonthlyAppointment, startTime2, endTime2));

    appointments.add(monthlyAppointment);

    final DateTime startTime3 =
        DateTime(currentDate.year, currentDate.month, currentDate.day, 12);
    final DateTime endTime3 =
        DateTime(currentDate.year, currentDate.month, currentDate.day, 14);
    final RecurrenceProperties recurrencePropertiesForYearlyAppointment =
        RecurrenceProperties(
            startDate: startTime3,
            recurrenceType: RecurrenceType.yearly,
            dayOfMonth: 5);

    final Appointment yearlyAppointment = Appointment(
        startTime: startTime3,
        endTime: endTime3,
        color: _colorCollection[random.nextInt(8)],
        isAllDay: true,
        subject: 'Stephen birthday',
        recurrenceRule: SfCalendar.generateRRule(
            recurrencePropertiesForYearlyAppointment, startTime3, endTime3));

    appointments.add(yearlyAppointment);

    final DateTime startTime4 =
        DateTime(currentDate.year, currentDate.month, currentDate.day, 17);
    final DateTime endTime4 =
        DateTime(currentDate.year, currentDate.month, currentDate.day, 18);
    final RecurrenceProperties recurrencePropertiesForCustomDailyAppointment =
        RecurrenceProperties(startDate: startTime4);

    final Appointment customDailyAppointment = Appointment(
      startTime: startTime4,
      endTime: endTime4,
      color: _colorCollection[random.nextInt(8)],
      subject: 'General meeting',
      recurrenceRule: SfCalendar.generateRRule(
          recurrencePropertiesForCustomDailyAppointment, startTime4, endTime4),
    );

    appointments.add(customDailyAppointment);

    final DateTime startTime5 =
        DateTime(currentDate.year, currentDate.month, currentDate.day, 12);
    final DateTime endTime5 =
        DateTime(currentDate.year, currentDate.month, currentDate.day, 13);
    final RecurrenceProperties recurrencePropertiesForCustomWeeklyAppointment =
        RecurrenceProperties(
            startDate: startTime5,
            recurrenceType: RecurrenceType.weekly,
            recurrenceRange: RecurrenceRange.endDate,
            weekDays: <WeekDays>[WeekDays.monday, WeekDays.friday],
            endDate: DateTime.now().add(const Duration(days: 14)));

    final Appointment customWeeklyAppointment = Appointment(
        startTime: startTime5,
        endTime: endTime5,
        color: _colorCollection[random.nextInt(8)],
        subject: 'performance check',
        recurrenceRule: SfCalendar.generateRRule(
            recurrencePropertiesForCustomWeeklyAppointment,
            startTime5,
            endTime5));

    appointments.add(customWeeklyAppointment);

    final DateTime startTime6 =
        DateTime(currentDate.year, currentDate.month, currentDate.day, 16);
    final DateTime endTime6 =
        DateTime(currentDate.year, currentDate.month, currentDate.day, 18);

    final RecurrenceProperties recurrencePropertiesForCustomMonthlyAppointment =
        RecurrenceProperties(
            startDate: startTime6,
            recurrenceType: RecurrenceType.monthly,
            recurrenceRange: RecurrenceRange.count,
            dayOfWeek: DateTime.friday,
            week: 4,
            recurrenceCount: 12);

    final Appointment customMonthlyAppointment = Appointment(
        startTime: startTime6,
        endTime: endTime6,
        color: _colorCollection[random.nextInt(8)],
        subject: 'Sprint end meeting',
        recurrenceRule: SfCalendar.generateRRule(
            recurrencePropertiesForCustomMonthlyAppointment,
            startTime6,
            endTime6));

    appointments.add(customMonthlyAppointment);

    final DateTime startTime7 =
        DateTime(currentDate.year, currentDate.month, currentDate.day, 14);
    final DateTime endTime7 =
        DateTime(currentDate.year, currentDate.month, currentDate.day, 15);
    final RecurrenceProperties recurrencePropertiesForCustomYearlyAppointment =
        RecurrenceProperties(
            startDate: startTime7,
            recurrenceType: RecurrenceType.yearly,
            recurrenceRange: RecurrenceRange.count,
            interval: 2,
            month: DateTime.february,
            week: 2,
            dayOfWeek: DateTime.sunday,
            recurrenceCount: 10);

    final Appointment customYearlyAppointment = Appointment(
        startTime: startTime7,
        endTime: endTime7,
        color: _colorCollection[random.nextInt(8)],
        subject: 'Alumini meet',
        recurrenceRule: SfCalendar.generateRRule(
            recurrencePropertiesForCustomYearlyAppointment,
            startTime7,
            endTime7));

    appointments.add(customYearlyAppointment);
    return appointments;
  }

  SfCalendar _getRecurrenceCalendar(
      [CalendarController? calendarController,
      CalendarDataSource? calendarDataSource,
      dynamic calendarTapCallback]) {
    return SfCalendar(
      controller: calendarController,
      allowedViews: _allowedViews,
      showDatePickerButton: true,
      dataSource: calendarDataSource,
      monthViewSettings: const MonthViewSettings(
          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
      onTap: calendarTapCallback,
    );
  }
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(this.source);

  List<Appointment> source;

  @override
  List<dynamic> get appointments => source;
}
