import 'package:achievement/ui/edit_achievement_page/edit_remind_date_btn.dart';
import 'package:achievement/ui/edit_achievement_page/edit_remind_day_btn.dart';
import 'package:achievement/ui/edit_achievement_page/edit_remind_time_btn.dart';
import 'package:achievement/core/changed_date_time_range.dart';
import 'package:achievement/core/enums.dart';
import 'package:achievement/model/remind_model.dart';
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

  bool get _hasError =>
      widget.decoration != null &&
      widget.decoration!.errorText != null &&
      widget.decoration!.errorText!.isNotEmpty;

  @override
  void initState() {
    super.initState();

    _listTypeRepition =
        TypeRepition.values.map<DropdownMenuItem<TypeRepition>>((value) {
      return DropdownMenuItem<TypeRepition>(
          value: value,
          child: Text(
            _getStringRepition(value),
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
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
          color: Colors.red,
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
      case TypeRepition.month:
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
      case TypeRepition.month:
        return 'каждый месяц';
      default:
        return 'без повтора';
    }
  }
}
