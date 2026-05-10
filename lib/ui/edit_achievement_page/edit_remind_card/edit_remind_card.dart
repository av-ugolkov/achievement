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

  const EditRemindCard({
    super.key,
    required this.remindModel,
    required this.dateTimeRange,
    this.onChanged,
    this.decoration,
  });

  @override
  State<EditRemindCard> createState() => _EditRemindCardState();
}

class _EditRemindCardState extends State<EditRemindCard> {
  TypeRepetition _typeRepetition = TypeRepetition.none;
  late List<DropdownMenuItem<TypeRepetition>> _listTypeRepetition;

  DateTime get _afternoon => DateTime(1, 1, 1, 12, 0);
  DateTime get _getTimeAdd12Hours => DateTime.now().add(Duration(hours: 12));

  bool get _hasError =>
      widget.decoration != null &&
      widget.decoration!.errorText != null &&
      widget.decoration!.errorText!.isNotEmpty;

  @override
  void initState() {
    super.initState();

    _typeRepetition = widget.remindModel.typeRepetition;
  }

  @override
  Widget build(BuildContext context) {
    _listTypeRepetition =
        TypeRepetition.values.map<DropdownMenuItem<TypeRepetition>>((value) {
      return DropdownMenuItem<TypeRepetition>(
          value: value,
          child: Text(
            _getStringRepetition(value),
            style: Theme.of(context).textTheme.labelLarge,
          ));
    }).toList();

    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            height: 36,
            child: DropdownButton<TypeRepetition>(
              value: _typeRepetition,
              onChanged: (TypeRepetition? value) {
                setState(() {
                  _typeRepetition = value ?? TypeRepetition.none;
                  widget.remindModel.typeRepetition = _typeRepetition;
                  if (_typeRepetition == TypeRepetition.week) {
                    widget.remindModel.remindDateTime =
                        RemindDateTime.fromDateTime(dateTime: _afternoon);
                  } else {
                    widget.remindModel.remindDateTime =
                        RemindDateTime.fromDateTime(
                      dateTime: _getTimeAdd12Hours,
                    );
                  }
                });
              },
              items: _listTypeRepetition,
            ),
          ),
          SizedBox(
            height: 36,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _getRemindView(_typeRepetition),
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

  List<Widget> _getRemindView(TypeRepetition typeRepetition) {
    switch (typeRepetition) {
      case TypeRepetition.day:
        return _getDayRepetition();
      case TypeRepetition.week:
        return _getWeekRepetition();
      default:
        return _getNoneRepetition();
    }
  }

  List<Widget> _getNoneRepetition() {
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

  List<Widget> _getDayRepetition() {
    return <Widget>[
      EditRemindTimeBtn(
        remindModel: widget.remindModel,
        dateTimeRange: widget.dateTimeRange,
        onChangeTime: _onChangeDateTime,
      )
    ];
  }

  List<Widget> _getWeekRepetition() {
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

  String _getStringRepetition(TypeRepetition typeRepetition) {
    switch (typeRepetition) {
      case TypeRepetition.day:
        return 'каждый день';
      case TypeRepetition.week:
        return 'каждую неделю';
      default:
        return 'без повтора';
    }
  }
}
