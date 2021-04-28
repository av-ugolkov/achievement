import 'package:flutter/material.dart';

class ChangedDateTimeRange {
  DateTime _start;
  DateTime get start => _start;
  set start(DateTime value) {
    if (_start == value) return;
    _start = value;
  }

  DateTime _end;
  DateTime get end => _end;
  set end(DateTime value) {
    if (_end == value) return;
    _end = value;
  }

  ChangedDateTimeRange({
    required DateTime start,
    required DateTime end,
  })   : _start = start,
        _end = end,
        assert(!start.isAfter(end));

  Duration get duration => _end.difference(_start);

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is ChangedDateTimeRange &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode => hashValues(start, end);

  @override
  String toString() => '$start - $end';
}
