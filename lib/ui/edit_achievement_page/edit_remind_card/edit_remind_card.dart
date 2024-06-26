import 'package:achievement/data/entities/remind_entity.dart';
import 'package:achievement/ui/edit_achievement_page/edit_remind_date_btn.dart';
import 'package:achievement/ui/edit_achievement_page/edit_remind_day_btn.dart';
import 'package:achievement/ui/edit_achievement_page/edit_remind_time_btn.dart';
import 'package:achievement/core/changed_date_time_range.dart';
import 'package:achievement/core/enums.dart';
import 'package:achievement/data/model/remind_model.dart';
import 'package:flutter/material.dart';

class EditRemindCard extends StatefulWidget {
  final RemindModel remindModel;
  final ChangedDateTimeRange dateTimeRange;
  final ValueChanged<DateTime>? onChanged;
  final InputDecoration? decoration;

  EditRemindCard({
    required this.remindModel,
    required this.dateTimeRange,
    this.onChanged,
    this.decoration,
  });

  @override
  _EditRemindCardState createState() => _EditRemindCardState();
}

class _EditRemindCardState extends State<EditRemindCard> {
  TypeRepition _typeRepition = TypeRepition.none;
  late List<DropdownMenuItem<TypeRepition>> _listTypeRepition;

  DateTime get _12am => DateTime(1, 1, 1, 12, 0);
  DateTime get _getTimeAdd12Hours => DateTime.now().add(Duration(hours: 12));

  bool get _hasError =>
      widget.decoration != null &&
      widget.decoration!.errorText != null &&
      widget.decoration!.errorText!.isNotEmpty;

  @override
  void initState() {
    super.initState();

    _typeRepition = widget.remindModel.typeRepition;
  }

  @override
  Widget build(BuildContext context) {
    _listTypeRepition =
        TypeRepition.values.map<DropdownMenuItem<TypeRepition>>((value) {
      return DropdownMenuItem<TypeRepition>(
          value: value,
          child: Text(
            _getStringRepition(value),
            style: Theme.of(context).textTheme.labelLarge,
          ));
    }).toList();

    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            height: 36,
            child: DropdownButton<TypeRepition>(
              value: _typeRepition,
              onChanged: (TypeRepition? value) {
                setState(() {
                  _typeRepition = value ?? TypeRepition.none;
                  widget.remindModel.typeRepition = _typeRepition;
                  if (_typeRepition == TypeRepition.week) {
                    widget.remindModel.remindDateTime =
                        RemindDateTime.fromDateTime(dateTime: _12am);
                  } else {
                    widget.remindModel.remindDateTime =
                        RemindDateTime.fromDateTime(
                      dateTime: _getTimeAdd12Hours,
                    );
                  }
                });
              },
              items: _listTypeRepition,
            ),
          ),
          Container(
            height: 36,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _getRemindView(_typeRepition),
            ),
          ),
          _getShowErrorText(),
        ],
      ),
    );
  }

  Widget _getShowErrorText() {
    if (_hasError) {
      return Text(
        widget.decoration!.errorText!,
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
        ),
      );
    }
    return Container();
  }

  List<Widget> _getRemindView(TypeRepition typeRepition) {
    switch (typeRepition) {
      case TypeRepition.day:
        return _getDayRepition();
      case TypeRepition.week:
        return _getWeekRepition();
      default:
        return _getNoneRepition();
    }
  }

  List<Widget> _getNoneRepition() {
    return <Widget>[
      EditRemindDateBtn(
        remindModel: widget.remindModel,
        dateTimeRange: widget.dateTimeRange,
        onChangeDate: _onChangeDateTime,
      ),
      EditRemindTimeBtn(
        remindModel: widget.remindModel,
        dateTimeRange: widget.dateTimeRange,
        onChangeTime: _onChangeDateTime,
      ),
    ];
  }

  List<Widget> _getDayRepition() {
    return <Widget>[
      EditRemindTimeBtn(
        remindModel: widget.remindModel,
        dateTimeRange: widget.dateTimeRange,
        onChangeTime: _onChangeDateTime,
      )
    ];
  }

  List<Widget> _getWeekRepition() {
    return <Widget>[
      EditRemindDayBtn(remindModel: widget.remindModel),
      EditRemindTimeBtn(
        remindModel: widget.remindModel,
        dateTimeRange: widget.dateTimeRange,
        onChangeTime: _onChangeDateTime,
      ),
    ];
  }

  void _onChangeDateTime(DateTime value) {
    widget.onChanged?.call(value);
  }

  String _getStringRepition(TypeRepition typeRepition) {
    switch (typeRepition) {
      case TypeRepition.day:
        return 'каждый день';
      case TypeRepition.week:
        return 'каждую неделю';
      default:
        return 'без повтора';
    }
  }
}
