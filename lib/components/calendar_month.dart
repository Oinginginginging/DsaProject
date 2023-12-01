import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:prototype/getX/data_controller.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter/material.dart';

import '../dataClass/data_class.dart';

class CalendarMonth extends StatefulWidget {
  final DataController dataController;

  const CalendarMonth(this.dataController, {Key? key}) : super(key: key);

  @override
  State<CalendarMonth> createState() => _CalendarMonth();
}

class _CalendarMonth extends State<CalendarMonth> {
  bool showAgenda = false;
  late DataController dataController;
  MeetingDataSource? data;
  List<dynamic> selectedDayAppointments = [];
  final CalendarController _calendarController = CalendarController();

  @override
  void initState() {
    super.initState();
    setState(() {
      dataController = Get.put(DataController());
    });
  }

  @override
  Widget build(BuildContext context) {
    dataController = widget.dataController;
    return GetBuilder<DataController>(builder: (dataController) {
      return Column(
        children: [
          const SizedBox(child: Text('오늘은 날씨가 춥네요! 따듯하게 입으소')),
          Expanded(child: calendar(widget.dataController.mMeetings)),
          if (showAgenda)
            SizedBox(
              height: MediaQuery.of(context).size.height *
                  0.25, // Adjust the height as needed
              child: ListView.builder(
                itemCount: selectedDayAppointments.length,
                itemBuilder: (context, index) {
                  final meeting = selectedDayAppointments[index];
                  return Dismissible(
                      key: Key(index.toString()),
                      background: Container(
                        color: Colors.green,
                        child: const Align(
                          alignment: Alignment.centerLeft,
                          child: Icon(Icons.edit),
                        ),
                      ),
                      secondaryBackground: Container(
                        color: Colors.red,
                        child: const Align(
                          alignment: Alignment.centerRight,
                          child: Icon(Icons.delete),
                        ),
                      ),
                      onDismissed: (direction) {
                        if (direction == DismissDirection.startToEnd) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("$index item saved")));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("$index item deleted")));
                        }
                      },
                      child: Card(
                        child: Row(children: [
                          _buildCustomCheckbox(meeting),
                          Center(
                            child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: ListTile(
                                    title: Text(meeting.eventName),
                                    subtitle: Text(meeting.isAllDay
                                        ? 'All day'
                                        : "${DateFormat('hh:mm').format(meeting.from)} - ${DateFormat('HH:mm').format(meeting.to)}"),
                                    onLongPress: () => _editMeeting(meeting))),
                          )
                        ]),
                      ));
                },
              ),
            ),
        ],
      );
    });
  }

  SfCalendar calendar(data) {
    return SfCalendar(
      key: ValueKey(data),
      controller: _calendarController,
      view: CalendarView.month,
      dataSource: data,
      monthViewSettings: const MonthViewSettings(
        appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
      ),
      onTap: _onTappedDay,
    );
  }

  void _editMeeting(Meeting meeting) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(10),
              child: Stack(
                fit: StackFit.passthrough,
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Text(
                            meeting.eventName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ListView(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          children: [
                            ListTile(
                                title: Center(
                                    child: Text(DateFormat('hh:mm')
                                        .format(meeting.from)))),
                            ListTile(
                                title: Center(
                                    child: Text(DateFormat('hh:mm')
                                        .format(meeting.to)))),
                            ListTile(
                                title: Column(
                              children: [
                                Text("Recurrence?"),
                                Checkbox(
                                    value: true,
                                    onChanged: (bool? newValue) {
                                      setState(() {});
                                    })
                              ],
                            ))
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(4.0),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                          child: GestureDetector(
                              child: const Icon(
                                Icons.delete_rounded,
                                color: Colors.white,
                              ),
                              onTap: () {
                                setState(() {
                                  dataController.deleteMeeting(meeting);

                                  selectedDayAppointments = dataController
                                      .mMeetings.appointments!
                                      .where((e) =>
                                          e.from.day ==
                                              selectedDayAppointments[0]
                                                  .from
                                                  .day &&
                                          e.from.hour <= 24)
                                      .toList();

                                  Navigator.pop(
                                      context, selectedDayAppointments);
                                });
                              }),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ),
                ],
              ));
        });
  }

  Widget _buildCustomCheckbox(Meeting meeting) {
    return GestureDetector(
        onTap: () {
          _onCheckboxClicked(meeting);
        },
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: meeting.showTriangularMark
                ? Colors.yellow
                : meeting.isDone
                    ? Colors.green
                    : Colors.grey,
          ),
          child: Icon(
            meeting.showTriangularMark ? Icons.details : Icons.check,
            color: Colors.white,
          ),
        ));
  }

  void _onCheckboxClicked(Meeting meeting) {
    setState(() {
      if (!meeting.isDone) {
        // First click, set to checked
        meeting.isDone = true;
      } else if (!meeting.showTriangularMark) {
        // Second click, set to triangular mark
        meeting.showTriangularMark = true;
      } else {
        // Third click, reset to unchecked
        meeting.isDone = false;
        meeting.showTriangularMark = false;
      }

      // Update your logic here based on the checkbox state
      // For example, you can update the dataController or perform other actions
    });
  }

  void _onTappedDay(CalendarTapDetails details) {
    selectedDayAppointments = [];
    if (details.date == null) return;
    final selectedDate = details.date!;
    final appointmentsOnTappedDate = dataController.mMeetings.appointments!
        .where((appointment) =>
            appointment.from.year == selectedDate.year &&
            appointment.from.month == selectedDate.month &&
            appointment.from.day == selectedDate.day)
        .cast<Meeting>()
        .toList();
    setState(() {
      showAgenda = _showAgenda(details.appointments);
      if (showAgenda) {
        selectedDayAppointments = appointmentsOnTappedDate;
      } else {
        selectedDayAppointments = [];
      }
    });
  }

  void _onCheckboxChanged(int index, bool value) {
    setState(() {
      selectedDayAppointments = List.from(selectedDayAppointments)
        ..[index] = selectedDayAppointments[index].copyWith(isDone: value);
      dataController.mMeetings.notifyListeners(
          CalendarDataSourceAction.addResource, selectedDayAppointments);
      dataController.mMeetings.updateMeetingData(selectedDayAppointments);
    });
  }

  bool _showAgenda(List<dynamic>? appointments) {
    return appointments != null && appointments.isNotEmpty;
  }
}
