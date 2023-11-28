import 'package:flutter/material.dart';

class Meeting {
  /// Creates a meeting class with required details.
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay,
      {this.isDone = false, this.category = 'None'});

  /// Event name which is equivalent to subject property of [Appointment].
  String eventName;

  /// From which is equivalent to start time property of [Appointment].
  DateTime from;

  /// To which is equivalent to end time property of [Appointment].
  DateTime to;

  /// Background which is equivalent to color property of [Appointment].
  Color background;

  /// IsAllDay which is equivalent to isAllDay property of [Appointment].
  bool isAllDay;

  bool isDone;

  String category;

  Meeting copyWith({bool? isDone}) {
    return Meeting(
      eventName,
      from,
      to,
      background,
      isAllDay,
      isDone: isDone ?? this.isDone,
    );
  }
}
