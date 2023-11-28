import 'package:get/get.dart';
import 'package:prototype/getX/data_controller.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter/material.dart';

import '../dataClass/data_class.dart';

class CalendarMonth extends StatefulWidget {
  const CalendarMonth({Key? key}) : super(key: key);
  @override
  State<CalendarMonth> createState() => _CalendarMonth();
}

class _CalendarMonth extends State<CalendarMonth> {
  bool showAgenda = false;
  List<Meeting> selectedDayAppointments = [];
  final dataController = Get.put(DataController());

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(child: Text('오늘은 날씨가 춥네요! 따듯하게 입으소')),
        Expanded(
          child: SfCalendar(
            view: CalendarView.month,
            dataSource: dataController.mMeetings,
            monthViewSettings: const MonthViewSettings(
              showAgenda: false,
              agendaItemHeight: 50,
              agendaViewHeight: 150,
              appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
            ),
            onTap: _onTappedDay,
            onLongPress: (calLongPressDetail) => const PopupMenuItem(
              child: Text("hhhad"),
            ),
          ),
        ),
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
                        Checkbox(
                          value: meeting.isDone,
                          onChanged: (bool? value) {
                            _onCheckboxChanged(index, value ?? false);
                          },
                        ),
                      ]),
                    ));
              },
            ),
          ),
      ],
    );
  }

  void _onTappedDay(CalendarTapDetails details) {
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
      }
    });
  }

  void _onCheckboxChanged(int index, bool value) {
    setState(() {
      selectedDayAppointments = List.from(selectedDayAppointments)
        ..[index] = selectedDayAppointments[index].copyWith(isDone: value);
      dataController.mMeetings.updateMeetingData(selectedDayAppointments);
    });
  }

  bool _showAgenda(List<dynamic>? appointments) {
    return appointments!.isNotEmpty;
  }
}


/*
ListView.builder(
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
                    child: CheckboxListTile(
                      title: Text(meeting.eventName),
                      value: meeting.isDone,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (bool? value) {
                        _onCheckboxChanged(index, value ?? false);
                      },
                    ));
              },
            ),
 */
