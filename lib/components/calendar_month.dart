import 'package:intl/intl.dart';
import 'package:prototype/getX/data_controller.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinner_time_picker/flutter_spinner_time_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../dataClass/data_class.dart';

import '../main.dart';

class CalendarMonth extends StatefulWidget {
  final DataController dataController;

  const CalendarMonth(this.dataController, {Key? key}) : super(key: key);

  @override
  State<CalendarMonth> createState() => _CalendarMonth();
}

class _CalendarMonth extends State<CalendarMonth> {
  bool showAgenda = false;
  late DataController dataController;
  List<dynamic> selectedDayAppointments = [];
  final CalendarController _calendarController = CalendarController();
  TimeOfDay selectedTime = TimeOfDay.now();
  DateTime pickedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    dataController = widget.dataController;
    return Column(
      children: [
        const SizedBox(
            child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '❝',
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
              TextSpan(
                text: '오늘은 기온이 4°C~15°C로 일교차가 크네요. 15시엔 ',
              ),
              TextSpan(
                text: '비',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: Color.fromARGB(255, 77, 112, 193), // "비"의 원하는 색상
                ),
              ),
              TextSpan(
                text: '도 올 예정이에요.\n',
              ),
              TextSpan(
                text: '"따듯한 여분 아우터"',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0, // 원하는 글자 크기
                  color: Color.fromARGB(255, 235, 77, 19), // 원하는 색상
                ),
              ),
              TextSpan(
                text: '와 ',
              ),
              TextSpan(
                text: '"우산"',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  color: Color.fromARGB(255, 50, 175, 12),
                ),
              ),
              TextSpan(
                text: '을 챙기세요!',
              ),
              TextSpan(
                text: '❞',
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
            ],
          ),
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        )),
        Expanded(child: calendar(widget.dataController.mMeetings)),
        if (showAgenda)
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.20, // Adjust the height as needed
            child: ListView.builder(
              itemCount: selectedDayAppointments.length,
              itemBuilder: (context, index) {
                final meeting = selectedDayAppointments[index];
                return Card(
                    color: meeting.color,
                    child: Row(children: [
                      _buildCustomCheckbox(meeting),
                      Center(
                        child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: ListTile(
                                title: Text(meeting.eventName),
                                subtitle: Text(
                                    meeting.isAllDay ? 'All day' : "${DateFormat('HH:mm').format(meeting.from)} - ${DateFormat('HH:mm').format(meeting.to)}"),
                                onLongPress: () => _editMeeting(meeting))),
                      ),
                    ]));
              },
            ),
          ),
        FloatingActionButton(
          onPressed: _addMeeting,
          child: const Icon(Icons.add),
        ),
      ],
    );
  }

  void _addMeeting() {
    TimeOfDay startedTime = TimeOfDay.now();
    TimeOfDay endedTime = TimeOfDay.now();

    String startTime = '${startedTime.hour.toString().padLeft(2, '0')}:${startedTime.minute.toString().padLeft(2, '0')}';
    String endTime = '${endedTime.hour.toString().padLeft(2, '0')}:${endedTime.minute.toString().padLeft(2, '0')}';

    String recurrenceRule = 'NONE';

    DateTime selectedDate = _calendarController.selectedDate ?? DateTime.now();

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
        onLongPress: ((CalendarLongPressDetails detail) {
          setState(() {
            dataController.changeIndex(1);
            dataController.changeDisplayDate(detail.date!);
            dataController.changeIsPressed(true);
          });
          Navigator.push(context, MaterialPageRoute(builder: (context) => const MyHomePage(1)));
        }));
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
                width: MediaQuery.of(context).size.width * 0.6,
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
                                                        selectedDayAppointments = dataController.mMeetings.appointments!
                                                            .where((e) => e.from.day == selectedDayAppointments[0].from.day && e.from.hour <= 24)
                                                            .toList();
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
                                        selectedDayAppointments = dataController.mMeetings.appointments!
                                            .where((e) => e.from.day == selectedDayAppointments[0].from.day && e.from.hour <= 24)
                                            .toList();
                                        Navigator.pop(context, selectedDayAppointments);
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
                                      selectedDayAppointments =
                                          dataController.mMeetings.appointments!.where((e) => e.from.day == meeting.from.day && e.from.hour <= 24).toList();
                                      Navigator.pop(context, selectedDayAppointments);
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
          if (!dataController.mMeetings.appointments!.contains(meeting)) {
            dataController.mMeetings.appointments!.add(meeting);
          } else {
            dataController.updateMeeting(meeting);
          }

          selectedDayAppointments = dataController.mMeetings.appointments!.where((e) => e.from.day == meeting.from.day && e.from.hour <= 24).toList();
        });
        break;
      case 'DAILY':
        setState(() {
          final RecurrenceProperties recProperties = RecurrenceProperties(startDate: meeting.from, recurrenceRange: RecurrenceRange.count, recurrenceCount: 60);
          meeting.recurrenceRule = SfCalendar.generateRRule(recProperties, meeting.from, meeting.to);

          if (!dataController.mMeetings.appointments!.contains(meeting)) {
            dataController.mMeetings.appointments!.add(meeting);
          } else {
            dataController.updateMeeting(meeting);
          }
          selectedDayAppointments = dataController.mMeetings.appointments!.where((e) => e.from.day == meeting.from.day <= 24).toList();
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
          if (!dataController.mMeetings.appointments!.contains(meeting)) {
            dataController.mMeetings.appointments!.add(meeting);
          } else {
            dataController.updateMeeting(meeting);
          }
          selectedDayAppointments = dataController.mMeetings.appointments!.where((e) => e.from.day == meeting.from.day && e.from.hour <= 24).toList();
        });
        break;
      case 'MONTHLY':
        setState(() {
          type = RecurrenceType.monthly;
          final RecurrenceProperties recProperties =
              RecurrenceProperties(startDate: meeting.from, recurrenceType: type, recurrenceCount: 20, dayOfMonth: meeting.from.day);
          meeting.recurrenceRule = SfCalendar.generateRRule(recProperties, meeting.from, meeting.to);
          if (!dataController.mMeetings.appointments!.contains(meeting)) {
            dataController.mMeetings.appointments!.add(meeting);
          } else {
            dataController.updateMeeting(meeting);
          }
          selectedDayAppointments = dataController.mMeetings.appointments!.where((e) => e.from.day == meeting.from.day && e.from.hour <= 24).toList();
        });
        break;
      case 'YEARLY':
        setState(() {
          type = RecurrenceType.yearly;
          final RecurrenceProperties recProperties =
              RecurrenceProperties(startDate: meeting.from, recurrenceType: type, month: meeting.from.month, dayOfMonth: meeting.from.day);
          meeting.recurrenceRule = SfCalendar.generateRRule(recProperties, meeting.from, meeting.to);
          if (!dataController.mMeetings.appointments!.contains(meeting)) {
            dataController.mMeetings.appointments!.add(meeting);
          } else {
            dataController.updateMeeting(meeting);
          }
          selectedDayAppointments = dataController.mMeetings.appointments!.where((e) => e.from.day == meeting.from.day && e.from.hour <= 24).toList();
        });
        break;
    }
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

  void _onCheckboxClicked(dynamic meeting) {
    setState(() {
      if (!meeting.isDone) {
        meeting.isDone = true;
        dataController.updateMeeting(meeting);
      } else if (!meeting.showTriangularMark) {
        meeting.showTriangularMark = true;
        dataController.updateMeeting(meeting);
      } else {
        meeting.isDone = false;
        meeting.showTriangularMark = false;
        dataController.updateMeeting(meeting);
      }
    });
  }

  void _onTappedDay(CalendarTapDetails details) {
    if (details.date == null) return;

    setState(() {
      showAgenda = _showAgenda(details.appointments);
      if (showAgenda) {
        selectedDayAppointments = _getRecurringAppointments(details.appointments!);
      } else {
        selectedDayAppointments = [];
      }
    });
  }

  List<dynamic> _getRecurringAppointments(List<dynamic> appointments) {
    List<Meeting> recurringAppointments = [];

    for (var appointment in appointments) {
      if (appointment is Appointment) {
        final recurringAppointment = Meeting(
          id: dataController.mMeetings.appointments!.firstWhere((element) => element.eventName == appointment.subject).id,
          eventName: appointment.subject,
          from: DateTime(
              appointment.startTime.year, appointment.startTime.month, appointment.startTime.day, appointment.startTime.hour, appointment.startTime.minute),
          to: DateTime(appointment.endTime.year, appointment.endTime.month, appointment.endTime.day, appointment.endTime.hour, appointment.endTime.minute),
          color: appointment.color,
          recurrenceRule: appointment.recurrenceRule,
        );
        if (!recurringAppointments.contains(recurringAppointment)) {
          recurringAppointments.add(recurringAppointment);
        }
      } else {
        if (!recurringAppointments.contains(appointment)) {
          recurringAppointments.add(appointment);
        }
      }
    }
    return recurringAppointments;
  }

  bool _showAgenda(List<dynamic>? appointments) {
    return appointments != null && appointments.isNotEmpty;
  }
}
