import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter/material.dart';
import '../getX/data_controller.dart';
import 'package:prototype/dataClass/data_class.dart';
import 'package:flutter_spinner_time_picker/flutter_spinner_time_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:math';

class CalendarWeek extends StatefulWidget {
  final DataController dataController;

  const CalendarWeek(this.dataController, {Key? key}) : super(key: key);

  @override
  State<CalendarWeek> createState() => _CalendarWeek();
}

class _CalendarWeek extends State<CalendarWeek> {
  late DataController dataController;
  late int dragId;
  late int sizeId;
  late String? recurRule;
  final CalendarController calendarController = CalendarController();

  List<Appointment> convertToCalendarAppointment(List<dynamic> newdata) {
    List<Appointment> appointments = <Appointment>[];
    for (var meeting in newdata) {
      appointments.add(Appointment(
        startTime: meeting.from,
        endTime: meeting.to,
        recurrenceRule: meeting.recurrenceRule,
        recurrenceExceptionDates: meeting.recurrenceExceptionDates,
        id: dataController.mMeetings.appointments!.firstWhere((element) => element.eventName == meeting.eventName).id,
        isAllDay: meeting.isAllDay,
        subject: meeting.eventName,
        color: meeting.color,
      ));
    }

    return appointments;
  }

  @override
  Widget build(BuildContext context) {
    dataController = widget.dataController;
    return SafeArea(
        child: SfCalendar(
      controller: calendarController,
      showNavigationArrow: true,
      onTap: _onTappedEvent,
      view: CalendarView.week,
      timeSlotViewSettings: const TimeSlotViewSettings(
          timeInterval: Duration(minutes: 60),
          timeIntervalHeight: -1,
          timeFormat: 'HH:mm',
          dayFormat: 'EEE',
          timeRulerSize: 60,
          timeTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      dataSource: _DataSource(convertToCalendarAppointment(dataController.mMeetings.appointments!)),
      allowDragAndDrop: true,
      allowAppointmentResize: true,
      dragAndDropSettings: const DragAndDropSettings(
        allowNavigation: true,
        allowScroll: true,
        showTimeIndicator: true,
        autoNavigateDelay: Duration(seconds: 1),
        indicatorTimeFormat: 'HH:mm a',
        timeIndicatorStyle: TextStyle(
          backgroundColor: Color(0xFFCEE5D0),
          color: Colors.black,
          fontSize: 15,
        ),
      ),
      initialDisplayDate: dataController.initialDisplayDate,
      onDragStart: dragStart,
      onDragEnd: dragEnd,
      onAppointmentResizeEnd: resizeEnd,
      onAppointmentResizeStart: resizeStart,
    ));
  }

  void dragStart(AppointmentDragStartDetails appointmentDragStartDetails) {
    Appointment meeting = appointmentDragStartDetails.appointment as Appointment;
    dragId = meeting.id as int;
  }

  void dragEnd(AppointmentDragEndDetails appointmentDragEndDetails) {
    Appointment meeting = appointmentDragEndDetails.appointment as Appointment;
    Meeting originalMeeting = dataController.mMeetings.appointments!.firstWhere((element) => element.eventName == meeting.subject && element.id == dragId);
    int durationh = meeting.endTime.hour - meeting.startTime.hour;
    int durationm = meeting.endTime.minute - meeting.startTime.minute;
    DateTime from = appointmentDragEndDetails.droppingTime!;
    final cvrt = Meeting(
        id: originalMeeting.id,
        eventName: meeting.subject,
        from: from,
        to: DateTime(from.year, from.month, from.day, from.hour + durationh, from.minute + durationm),
        recurrenceRule: originalMeeting.recurrenceRule,
        color: meeting.color,
        recurrenceExceptionDates: meeting.recurrenceExceptionDates);
    if (cvrt.recurrenceRule != null) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Would you like to move the whole recurring event?"),
              actions: [
                TextButton(
                    onPressed: () {
                      setState(() {
                        dataController.updateMeeting(cvrt);
                        Navigator.pop(context);
                      });
                    },
                    child: const Text("Yes")),
                TextButton(
                    onPressed: () {
                      originalMeeting.recurrenceExceptionDates == null
                          ? originalMeeting.recurrenceExceptionDates = [meeting.startTime]
                          : originalMeeting.recurrenceExceptionDates!.add(meeting.startTime);
                      Meeting temp = Meeting(
                        id: dataController.mMeetings.appointments!.length + 1,
                        eventName: '${cvrt.eventName}${dataController.mMeetings.appointments!.length + 1}',
                        from: cvrt.from,
                        to: cvrt.to,
                        color: cvrt.color,
                      );
                      setState(() {
                        dataController.updateMeeting(originalMeeting);
                        dataController.mMeetings.appointments!.add(temp);
                        dataController.mMeetings.notifyListeners(CalendarDataSourceAction.add, dataController.mMeetings.appointments!);
                        Navigator.pop(context);
                      });
                    },
                    child: const Text("Only This")),
              ],
            );
          });
    } else {
      dataController.updateMeeting(cvrt);
    }
  }

  void resizeStart(AppointmentResizeStartDetails appointmentResizeStartDetails) {
    Appointment meeting = appointmentResizeStartDetails.appointment as Appointment;
    sizeId = meeting.id as int;
  }

  void resizeEnd(AppointmentResizeEndDetails appointmentResizeEndDetails) {
    Appointment meeting = appointmentResizeEndDetails.appointment as Appointment;
    Meeting originalMeeting = dataController.mMeetings.appointments!.firstWhere((element) => element.eventName == meeting.subject && element.id == sizeId);
    final cvrt = Meeting(
        id: dataController.mMeetings.appointments!.firstWhere((element) => element.eventName == meeting.subject).id,
        eventName: meeting.subject,
        from: meeting.startTime,
        to: meeting.endTime,
        recurrenceRule: originalMeeting.recurrenceRule,
        color: meeting.color,
        recurrenceExceptionDates: meeting.recurrenceExceptionDates);

    if (originalMeeting.recurrenceRule != null) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Would you like to resize the whole recurring event?"),
              actions: [
                TextButton(
                    onPressed: () {
                      setState(() {
                        dataController.updateMeeting(cvrt);
                        Navigator.pop(context);
                      });
                    },
                    //? cvrt.recurrenceExceptionDates!.remove(DateTime(from.year, from.month, from.day, from.hour, from.minute))
                    //   : null;
                    child: const Text("Yes")),
                TextButton(
                    onPressed: () {
                      originalMeeting.recurrenceExceptionDates == null
                          ? originalMeeting.recurrenceExceptionDates = [meeting.startTime]
                          : originalMeeting.recurrenceExceptionDates!.add(meeting.startTime);
                      Meeting temp = Meeting(
                        id: dataController.mMeetings.appointments!.length + 1,
                        eventName: '${cvrt.eventName}${dataController.mMeetings.appointments!.length + 1}',
                        from: cvrt.from,
                        to: cvrt.to,
                        color: cvrt.color,
                      );
                      setState(() {
                        dataController.updateMeeting(originalMeeting);
                        dataController.mMeetings.appointments!.add(temp);
                        dataController.mMeetings.notifyListeners(CalendarDataSourceAction.add, dataController.mMeetings.appointments!);
                        Navigator.pop(context);
                      });
                    },
                    child: const Text("Only This")),
              ],
            );
          });
    } else {
      dataController.mMeetings.updateMeetingData(cvrt);
    }
  }

  void _onTappedEvent(CalendarTapDetails details) {
    if (details.date == null) return;
    if (details.appointments != null) {
      dynamic meeting = details.appointments![0];
      if (meeting is Appointment) {
        final cvrt = Meeting(
          id: dataController.mMeetings.appointments!.firstWhere((element) => element.eventName == meeting.subject).id,
          eventName: meeting.subject,
          from: meeting.startTime,
          to: meeting.endTime,
          recurrenceRule: meeting.recurrenceRule,
          color: meeting.color,
        );
        meeting = cvrt;
      }
      _editMeeting(meeting);
    }

    if (details.appointments == null) {
      _addMeeting(details);
    }
  }

  void _editMeeting(Meeting meeting) {
    TimeOfDay startedTime = TimeOfDay(hour: meeting.from.hour, minute: meeting.from.minute);
    TimeOfDay endedTime = TimeOfDay(hour: meeting.to.hour, minute: meeting.to.minute);

    String startTime = '${startedTime.hour.toString().padLeft(2, '0')}:${startedTime.minute.toString().padLeft(2, '0')}';
    String endTime = '${endedTime.hour.toString().padLeft(2, '0')}:${endedTime.minute.toString().padLeft(2, '0')}';

    void showTimePicker(index, setInnerState) async {
      final pickedTime = await showSpinnerTimePicker(context,
          title: 'Edit ${index == 1 ? 'Start' : 'End'} Time',
          height: 100,
          width: 70,
          spinnerBgColor: Colors.grey,
          spinnerHeight: 100,
          spinnerWidth: 50,
          backgroundColor: Colors.yellow[50],
          selectedTextStyle: const TextStyle(color: Colors.black, fontSize: 30),
          nonSelectedTextStyle: TextStyle(color: Colors.grey[700], fontSize: 30),
          titleStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          buttonStyle: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
          buttonTextStyle: const TextStyle(fontSize: 16, color: Colors.transparent),
          barrierDismissible: true,
          initTime: index == 1 ? startedTime : endedTime);
      if (pickedTime != null) {
        setState(() {
          if (index == 1) {
            startedTime = pickedTime;
          } else {
            endedTime = pickedTime;
          }
        });
        setInnerState(() {
          startTime = '${startedTime.hour.toString().padLeft(2, '0')}:${startedTime.minute.toString().padLeft(2, '0')}';
          endTime = '${endedTime.hour.toString().padLeft(2, '0')}:${endedTime.minute.toString().padLeft(2, '0')}';
        });
      }
    }

    final recurSelect = ['NONE', 'DAILY', 'WEEKLY', 'MONTHLY', 'YEARLY'];
    var selectedRecur = meeting.recurrenceRule == null ? 'NONE' : meeting.recurrenceRule!.split(';')[0].substring(5);
    Color color = meeting.color;
    showDialog(
        context: context,
        builder: (BuildContext buildContext) {
          return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(10),
              child: SizedBox(
                width: 30,
                height: 450,
                child: DecoratedBox(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                    child: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setInnerState) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                    padding: const EdgeInsets.fromLTRB(10, 15, 0, 10),
                                    child: RichText(
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      text: TextSpan(
                                        text: '${meeting.eventName} (${meeting.from.day}/${meeting.from.month}/${meeting.from.year})',
                                        style: const TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            height: 1.5,
                                            shadows: [Shadow(color: Colors.black, offset: Offset(0, -5))],
                                            color: Colors.transparent,
                                            decoration: TextDecoration.underline,
                                            decorationColor: Colors.black,
                                            decorationStyle: TextDecorationStyle.double,
                                            decorationThickness: 1.5),
                                      ),
                                      textAlign: TextAlign.center,
                                    )),
                                SizedBox(
                                  width: 25,
                                  height: 25,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30.0),
                                        gradient: const LinearGradient(
                                          begin: Alignment.topRight,
                                          end: Alignment.bottomLeft,
                                          colors: [
                                            Color.fromARGB(255, 213, 213, 213),
                                            Color.fromARGB(255, 234, 231, 231),
                                          ],
                                        )),
                                    child: FloatingActionButton.small(
                                      shape: const CircleBorder(),
                                      backgroundColor: Colors.transparent,
                                      onPressed: () {
                                        setState(() {
                                          Navigator.of(context, rootNavigator: true).pop();
                                        });
                                      },
                                      child: const Text("X", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            ListView(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              children: [
                                const Text(
                                  "Starts At",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(50, 5, 50, 15),
                                  child: SizedBox(
                                      width: 20,
                                      height: 40,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15),
                                          gradient: const LinearGradient(
                                            begin: Alignment.topRight,
                                            end: Alignment.bottomLeft,
                                            colors: [
                                              Color.fromARGB(255, 213, 213, 213),
                                              Color.fromARGB(255, 234, 231, 231),
                                            ],
                                          ),
                                        ),
                                        child: FloatingActionButton(
                                          backgroundColor: Colors.transparent,
                                          onPressed: () {
                                            showTimePicker(1, setInnerState);
                                          },
                                          child: Text(
                                            startTime,
                                            style: const TextStyle(color: Colors.black),
                                          ),
                                        ),
                                      )),
                                ),
                                const Text(
                                  "Ends At",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(50, 5, 50, 15),
                                  child: SizedBox(
                                      width: 20,
                                      height: 40,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15),
                                          gradient: const LinearGradient(
                                            begin: Alignment.topRight,
                                            end: Alignment.bottomLeft,
                                            colors: [
                                              Color.fromARGB(255, 213, 213, 213),
                                              Color.fromARGB(255, 234, 231, 231),
                                            ],
                                          ),
                                        ),
                                        child: FloatingActionButton(
                                          backgroundColor: Colors.transparent,
                                          onPressed: () {
                                            showTimePicker(2, setInnerState);
                                          },
                                          child: Text(
                                            endTime,
                                            style: const TextStyle(color: Colors.black),
                                          ),
                                        ),
                                      )),
                                ),
                                const Text(
                                  "Recurring...",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Padding(
                                    padding: const EdgeInsets.fromLTRB(5, 0, 10, 10),
                                    child: Center(
                                      child: DropdownButton(
                                        alignment: Alignment.center,
                                        value: selectedRecur,
                                        items: recurSelect.map((e) {
                                          return DropdownMenuItem(
                                            value: e,
                                            child: Text(e),
                                          );
                                        }).toList(),
                                        onChanged: (e) {
                                          setInnerState(() {
                                            selectedRecur = e!;
                                          });
                                          setState(() {
                                            selectedRecur = e!;
                                          });
                                        },
                                      ),
                                    )),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
                                  child: Container(
                                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                      decoration: BoxDecoration(shape: BoxShape.rectangle, color: color, borderRadius: BorderRadius.circular(15.0)),
                                      child: GestureDetector(
                                        onTap: () {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext buildcontext) {
                                                return Dialog(
                                                    backgroundColor: Colors.transparent,
                                                    child: SingleChildScrollView(
                                                      scrollDirection: Axis.vertical,
                                                      child: Container(
                                                          width: 50,
                                                          height: 480,
                                                          padding: const EdgeInsets.all(20),
                                                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                                                          child: ColorPicker(
                                                              enableAlpha: false,
                                                              pickerColor: color,
                                                              onColorChanged: ((Color colorr) {
                                                                setInnerState(() {
                                                                  color = colorr;
                                                                });
                                                                setState(() {
                                                                  color = colorr;
                                                                });
                                                              }))),
                                                    ));
                                              });
                                        },
                                        child: const Text(
                                          "Choose Color",
                                          style: TextStyle(color: Colors.white),
                                          textAlign: TextAlign.center,
                                        ),
                                      )),
                                )
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                              decoration: BoxDecoration(shape: BoxShape.rectangle, color: Colors.red, borderRadius: BorderRadius.circular(15.0)),
                              child: GestureDetector(
                                  child: const Text(
                                    "Delete",
                                    style: TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                  onTap: () {
                                    if (meeting.recurrenceRule != null) {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text("Would you like to delete the whole recurring event?"),
                                              actions: [
                                                TextButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        Meeting originalMeeting =
                                                            dataController.mMeetings.appointments!.firstWhere((element) => element.id == meeting.id);
                                                        dataController.mMeetings.appointments!.remove(originalMeeting);
                                                        dataController.mMeetings.notifyListeners(CalendarDataSourceAction.remove, <Meeting>[originalMeeting]);

                                                        Navigator.pop(context);
                                                        Navigator.pop(context);
                                                      });
                                                    },
                                                    child: const Text("Yes")),
                                                TextButton(
                                                    onPressed: () {
                                                      Meeting originalMeeting =
                                                          dataController.mMeetings.appointments!.firstWhere((element) => element.id == meeting.id);

                                                      originalMeeting.recurrenceExceptionDates == null
                                                          ? originalMeeting.recurrenceExceptionDates = [meeting.from]
                                                          : originalMeeting.recurrenceExceptionDates!.add(meeting.from);
                                                      setState(() {
                                                        dataController.updateMeeting(originalMeeting);
                                                        Navigator.pop(context);
                                                        Navigator.pop(context);
                                                      });
                                                    },
                                                    child: const Text("Only This")),
                                              ],
                                            );
                                          });
                                    } else {
                                      setState(() {
                                        dataController.mMeetings.appointments!.removeWhere((element) => element.id == meeting.id);
                                        dataController.mMeetings.notifyListeners(CalendarDataSourceAction.remove, <Meeting>[meeting]);

                                        Navigator.pop(context);
                                      });
                                    }
                                    setState(() {});
                                  }),
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                              decoration: BoxDecoration(shape: BoxShape.rectangle, color: Colors.green, borderRadius: BorderRadius.circular(15.0)),
                              child: GestureDetector(
                                  child: const Text(
                                    "Confirm",
                                    style: TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                  onTap: () {
                                    _calculateRecurrence(selectedRecur, meeting);
                                    setState(() {
                                      final editStartTime =
                                          DateTime(meeting.from.year, meeting.from.month, meeting.from.day, startedTime.hour, startedTime.minute);
                                      meeting.from = editStartTime;

                                      final editEndTime = DateTime(meeting.to.year, meeting.to.month, meeting.to.day, endedTime.hour, endedTime.minute);
                                      meeting.to = editEndTime;
                                      meeting.color = color;
                                      dataController.updateMeeting(meeting);

                                      Navigator.pop(context);
                                    });
                                  }),
                            ),
                          ],
                        );
                      },
                    )),
              ));
        });
  }

  void _addMeeting(details) {
    TimeOfDay startedTime = TimeOfDay.now();
    TimeOfDay endedTime = TimeOfDay.now();

    String startTime = '${startedTime.hour.toString().padLeft(2, '0')}:${startedTime.minute.toString().padLeft(2, '0')}';
    String endTime = '${endedTime.hour.toString().padLeft(2, '0')}:${endedTime.minute.toString().padLeft(2, '0')}';

    String recurrenceRule = 'NONE';

    DateTime selectedDate = details.date!;

    TextEditingController textController = TextEditingController();

    void showTimePicker(index, setInnerState) async {
      final pickedTime = await showSpinnerTimePicker(context,
          title: 'Edit ${index == 1 ? 'Start' : 'End'} Time',
          height: 100,
          width: 70,
          spinnerBgColor: Colors.grey,
          spinnerHeight: 100,
          spinnerWidth: 50,
          backgroundColor: Colors.yellow[50],
          selectedTextStyle: const TextStyle(color: Colors.black, fontSize: 30),
          nonSelectedTextStyle: TextStyle(color: Colors.grey[700], fontSize: 30),
          titleStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          buttonStyle: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.transparent)),
          buttonTextStyle: const TextStyle(fontSize: 16, color: Colors.transparent),
          barrierDismissible: true,
          initTime: index == 1 ? startedTime : endedTime);
      if (pickedTime != null) {
        setState(() {
          if (index == 1) {
            startedTime = pickedTime;
          } else {
            endedTime = pickedTime;
          }
        });
        setInnerState(() {
          startTime = '${startedTime.hour.toString().padLeft(2, '0')}:${startedTime.minute.toString().padLeft(2, '0')}';
          endTime = '${endedTime.hour.toString().padLeft(2, '0')}:${endedTime.minute.toString().padLeft(2, '0')}';
        });
      }
    }

    final recurSelect = ['NONE', 'DAILY', 'WEEKLY', 'MONTHLY', 'YEARLY'];
    var selectedRecur = recurrenceRule == 'NONE' ? 'NONE' : recurrenceRule.split(';')[0].substring(5);

    Color color = const Color.fromARGB(255, 228, 126, 126);

    showDialog(
        context: context,
        builder: (BuildContext buildContext) {
          return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(10),
              child: SizedBox(
                width: 30,
                height: 450,
                child: DecoratedBox(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                    child: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setInnerState) {
                        return Column(mainAxisAlignment: MainAxisAlignment.spaceAround, crossAxisAlignment: CrossAxisAlignment.center, children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                  padding: const EdgeInsets.fromLTRB(10, 15, 0, 10),
                                  child: RichText(
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                      text: 'Add Meeting (${selectedDate.day}/${selectedDate.month}/${selectedDate.year})',
                                      style: const TextStyle(
                                          fontStyle: FontStyle.italic,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          height: 1.5,
                                          shadows: [Shadow(color: Colors.black, offset: Offset(0, -5))],
                                          color: Colors.transparent,
                                          decoration: TextDecoration.underline,
                                          decorationColor: Colors.black,
                                          decorationStyle: TextDecorationStyle.double,
                                          decorationThickness: 1.5),
                                    ),
                                    textAlign: TextAlign.center,
                                  )),
                              SizedBox(
                                width: 25,
                                height: 25,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30.0),
                                      gradient: const LinearGradient(
                                        begin: Alignment.topRight,
                                        end: Alignment.bottomLeft,
                                        colors: [
                                          Color.fromARGB(255, 213, 213, 213),
                                          Color.fromARGB(255, 234, 231, 231),
                                        ],
                                      )),
                                  child: FloatingActionButton.small(
                                    shape: const CircleBorder(),
                                    backgroundColor: Colors.transparent,
                                    onPressed: () {
                                      setState(() {
                                        Navigator.of(context, rootNavigator: true).pop();
                                      });
                                    },
                                    child: const Text("X", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                                  ),
                                ),
                              )
                            ],
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(25)),
                            child: SizedBox(
                              height: 55,
                              width: 250,
                              child: TextFormField(
                                  textAlignVertical: TextAlignVertical.top,
                                  minLines: 1,
                                  maxLines: 1,
                                  cursorWidth: 1,
                                  cursorColor: Colors.black,
                                  textAlign: TextAlign.center,
                                  controller: textController,
                                  decoration: InputDecoration(
                                    labelText: "Name of Event",
                                    labelStyle: TextStyle(
                                      color: Colors.grey[850],
                                    ),
                                    floatingLabelBehavior: FloatingLabelBehavior.never,
                                    border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(25.0)),
                                  )),
                            ),
                          ),
                          ListView(scrollDirection: Axis.vertical, shrinkWrap: true, children: [
                            const Text(
                              "Starts At",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(50, 5, 50, 15),
                              child: SizedBox(
                                  width: 20,
                                  height: 40,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      gradient: const LinearGradient(
                                        begin: Alignment.topRight,
                                        end: Alignment.bottomLeft,
                                        colors: [
                                          Color.fromARGB(255, 213, 213, 213),
                                          Color.fromARGB(255, 234, 231, 231),
                                        ],
                                      ),
                                    ),
                                    child: FloatingActionButton(
                                      backgroundColor: Colors.transparent,
                                      onPressed: () {
                                        showTimePicker(1, setInnerState);
                                      },
                                      child: Text(
                                        startTime,
                                        style: const TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  )),
                            ),
                            const Text(
                              "Ends At",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(50, 5, 50, 15),
                              child: SizedBox(
                                  width: 20,
                                  height: 40,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      gradient: const LinearGradient(
                                        begin: Alignment.topRight,
                                        end: Alignment.bottomLeft,
                                        colors: [
                                          Color.fromARGB(255, 213, 213, 213),
                                          Color.fromARGB(255, 234, 231, 231),
                                        ],
                                      ),
                                    ),
                                    child: FloatingActionButton(
                                      backgroundColor: Colors.transparent,
                                      onPressed: () {
                                        showTimePicker(2, setInnerState);
                                      },
                                      child: Text(
                                        endTime,
                                        style: const TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  )),
                            ),
                            const Text(
                              "Recurring...",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Padding(
                                padding: const EdgeInsets.fromLTRB(5, 0, 10, 10),
                                child: Center(
                                  child: DropdownButton(
                                    alignment: Alignment.center,
                                    value: selectedRecur,
                                    items: recurSelect.map((e) {
                                      return DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      );
                                    }).toList(),
                                    onChanged: (e) {
                                      setInnerState(() {
                                        selectedRecur = e!;
                                      });
                                      setState(() {
                                        selectedRecur = e!;
                                      });
                                    },
                                  ),
                                )),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
                              child: Container(
                                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                  decoration: BoxDecoration(shape: BoxShape.rectangle, color: color, borderRadius: BorderRadius.circular(15.0)),
                                  child: GestureDetector(
                                    onTap: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext buildcontext) {
                                            return Dialog(
                                                backgroundColor: Colors.transparent,
                                                child: SingleChildScrollView(
                                                  scrollDirection: Axis.vertical,
                                                  child: Container(
                                                      width: 50,
                                                      height: 480,
                                                      padding: const EdgeInsets.all(20),
                                                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                                                      child: ColorPicker(
                                                          enableAlpha: false,
                                                          pickerColor: color,
                                                          onColorChanged: ((Color colorr) {
                                                            setInnerState(() {
                                                              color = colorr;
                                                            });
                                                            setState(() {
                                                              color = colorr;
                                                            });
                                                          }))),
                                                ));
                                          });
                                    },
                                    child: const Text(
                                      "Choose Color",
                                      style: TextStyle(color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  )),
                            )
                          ]),
                          Container(
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                            decoration: BoxDecoration(shape: BoxShape.rectangle, color: Colors.grey[850], borderRadius: BorderRadius.circular(15.0)),
                            child: GestureDetector(
                                child: const Text(
                                  "Create",
                                  style: TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                                onTap: () {
                                  final Meeting newMeeting = Meeting(
                                    eventName: textController.text,
                                    id: dataController.mMeetings.appointments!.length + 1,
                                    from: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, startedTime.hour, startedTime.minute),
                                    to: DateTime(selectedDate.year, selectedDate.month, selectedDate.day, endedTime.hour, endedTime.minute),
                                    color: color,
                                  );
                                  dataController.mMeetings.appointments!.add(newMeeting);
                                  dataController.mMeetings.notifyListeners(CalendarDataSourceAction.add, dataController.mMeetings.appointments!);
                                  setState(() {
                                    _calculateRecurrence(selectedRecur, newMeeting);
                                    Navigator.pop(context);
                                  });
                                }),
                          ),
                        ]);
                      },
                    )),
              ));
        });
  }

  void _calculateRecurrence(String rec, Meeting meeting) {
    WeekDays getWeekDays(int n) {
      switch (n) {
        case 1:
          return WeekDays.monday;
        case 2:
          return WeekDays.tuesday;
        case 3:
          return WeekDays.wednesday;
        case 4:
          return WeekDays.thursday;
        case 5:
          return WeekDays.friday;
        case 6:
          return WeekDays.saturday;
        default:
          return WeekDays.sunday;
      }
    }

    dynamic type;
    switch (rec) {
      case 'NONE':
        setState(() {
          meeting.recurrenceRule = null;
          if (dataController.mMeetings.appointments!.where((element) => element.id == meeting.id && element.eventName == meeting.eventName) == []) {
            dataController.mMeetings.appointments!.add(meeting);
          } else {
            dataController.updateMeeting(meeting);
          }
        });
        break;
      case 'DAILY':
        setState(() {
          final RecurrenceProperties recProperties = RecurrenceProperties(startDate: meeting.from, recurrenceRange: RecurrenceRange.count, recurrenceCount: 60);
          meeting.recurrenceRule = SfCalendar.generateRRule(recProperties, meeting.from, meeting.to);

          if (dataController.mMeetings.appointments!.where((element) => element.id == meeting.id && element.eventName == meeting.eventName) == []) {
            dataController.mMeetings.appointments!.add(meeting);
          } else {
            dataController.updateMeeting(meeting);
          }
        });
        break;
      case 'WEEKLY':
        setState(() {
          type = RecurrenceType.weekly;
          final RecurrenceProperties recProperties = RecurrenceProperties(
            startDate: meeting.from,
            recurrenceType: type,
            weekDays: [getWeekDays(meeting.from.weekday)],
          );
          meeting.recurrenceRule = SfCalendar.generateRRule(recProperties, meeting.from, meeting.to);
          if (dataController.mMeetings.appointments!.where((element) => element.id == meeting.id && element.eventName == meeting.eventName) == []) {
            dataController.mMeetings.appointments!.add(meeting);
          } else {
            dataController.updateMeeting(meeting);
          }
        });
        break;
      case 'MONTHLY':
        setState(() {
          type = RecurrenceType.monthly;
          final RecurrenceProperties recProperties =
              RecurrenceProperties(startDate: meeting.from, recurrenceType: type, recurrenceCount: 20, dayOfMonth: meeting.from.day);
          meeting.recurrenceRule = SfCalendar.generateRRule(recProperties, meeting.from, meeting.to);
          if (dataController.mMeetings.appointments!.where((element) => element.id == meeting.id && element.eventName == meeting.eventName) == []) {
            dataController.mMeetings.appointments!.add(meeting);
          } else {
            dataController.updateMeeting(meeting);
          }
        });
        break;
      case 'YEARLY':
        setState(() {
          type = RecurrenceType.yearly;
          final RecurrenceProperties recProperties =
              RecurrenceProperties(startDate: meeting.from, recurrenceType: type, month: meeting.from.month, dayOfMonth: meeting.from.day);
          meeting.recurrenceRule = SfCalendar.generateRRule(recProperties, meeting.from, meeting.to);
          if (dataController.mMeetings.appointments!.where((element) => element.id == meeting.id && element.eventName == meeting.eventName) == []) {
            dataController.mMeetings.appointments!.add(meeting);
          } else {
            dataController.updateMeeting(meeting);
          }
        });
        break;
    }
  }

  List<Appointment> getAppointmentDetails() {
    final List<String> subjectCollection = <String>[];
    subjectCollection.add('General Meeting');
    subjectCollection.add('Plan Execution');
    subjectCollection.add('Project Plan');
    subjectCollection.add('Consulting');
    subjectCollection.add('Support');
    subjectCollection.add('Development Meeting');
    subjectCollection.add('Scrum');
    subjectCollection.add('Project Completion');
    subjectCollection.add('Release updates');
    subjectCollection.add('Performance Check');

    final List<Color> colorCollection = <Color>[];
    colorCollection.add(const Color(0xFF0F8644));
    colorCollection.add(const Color(0xFF8B1FA9));
    colorCollection.add(const Color(0xFFD20100));
    colorCollection.add(const Color(0xFFFC571D));
    colorCollection.add(const Color(0xFF36B37B));
    colorCollection.add(const Color(0xFF01A1EF));
    colorCollection.add(const Color(0xFF3D4FB5));
    colorCollection.add(const Color(0xFFE47C73));
    colorCollection.add(const Color(0xFF636363));
    colorCollection.add(const Color(0xFF0A8043));

    final List<Appointment> appointments = <Appointment>[];
    final Random random = Random();
    DateTime today = DateTime.now();
    final DateTime rangeStartDate = today.add(const Duration(days: -(365 ~/ 2)));
    final DateTime rangeEndDate = today.add(const Duration(days: 365));
    for (DateTime i = rangeStartDate; i.isBefore(rangeEndDate); i = i.add(const Duration(days: 1))) {
      final DateTime date = i;
      final int count = random.nextInt(2);
      for (int j = 0; j < count; j++) {
        final DateTime startDate = DateTime(date.year, date.month, date.day, 8 + random.nextInt(8));
        appointments.add(Appointment(
          subject: subjectCollection[random.nextInt(7)],
          startTime: startDate,
          endTime: startDate.add(Duration(hours: random.nextInt(3))),
          color: colorCollection[random.nextInt(9)],
        ));
      }
    }

    today = DateTime(today.year, today.month, today.day, 9);
    // added recurrence appointment
    appointments.add(Appointment(
        subject: 'Development status',
        startTime: today,
        endTime: today.add(const Duration(hours: 2)),
        color: colorCollection[random.nextInt(9)],
        recurrenceRule: 'FREQ=WEEKLY;BYDAY=FR;INTERVAL=1'));
    return appointments;
  }
}

class _DataSource extends CalendarDataSource {
  _DataSource(List<Appointment> source) {
    appointments = source;
  }
}
