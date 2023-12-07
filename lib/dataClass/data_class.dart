import 'package:flutter/material.dart';

class Meeting {
  /// Creates a meeting class with required details.
  Meeting(
      {required this.id,
      this.eventName = '',
      required this.from,
      required this.to,
      this.color = Colors.white,
      this.isAllDay = false,
      this.recurrenceRule,
      this.isDone = false,
      this.category = 'None',
      this.showTriangularMark = false});

  int id;

  /// Event name which is equivalent to subject property of [Appointment].
  String eventName;

  /// From which is equivalent to start time property of [Appointment].
  DateTime from;

  /// To which is equivalent to end time property of [Appointment].
  DateTime to;

  /// Background which is equivalent to color property of [Appointment].
  Color color;

  String? recurrenceRule;

  /// IsAllDay which is equivalent to isAllDay property of [Appointment].
  bool isAllDay;

  bool isDone;

  bool showTriangularMark;

  String category;

  Meeting copyWith({bool? isDone}) {
    return Meeting(
      id: id,
      eventName: eventName,
      from: from,
      to: to,
      color: color,
      isAllDay: isAllDay,
      recurrenceRule: recurrenceRule,
      isDone: isDone ?? this.isDone,
    );
  }
}
