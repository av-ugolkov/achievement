import 'package:achievement/core/changed_date_time_range.dart';
import 'package:achievement/core/enums.dart';
import 'package:achievement/model/remind_model.dart';
import 'package:achievement/ui/edit_achievement_page/edit_remind_card/form_edit_remind_card.dart';
import 'package:flutter/material.dart';
import 'package:achievement/core/extensions.dart';

class TestWidget extends StatefulWidget {
  @override
  _TestWidgetState createState() => _TestWidgetState();
}

class _TestWidgetState extends State<TestWidget> {
  final RemindModel _remindModel = RemindModel(
    id: 1,
    remindDateTime:
        RemindDateTime(year: 2021, month: 5, day: 15, hour: 15, minute: 0),
    typeRepition: TypeRepition.day,
  );
  final ChangedDateTimeRange _dateTimeRange = ChangedDateTimeRange(
    start: DateTime.now().getDate(),
    end: DateTime.now().getDate().add(
          Duration(days: 5),
        ),
  );

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _submitForm,
        child: Icon(Icons.done),
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: FormEditRemindCard(
            remindModel: _remindModel,
            dateTimeRange: _dateTimeRange,
            validator: (value) {
              if (value!.isAfter(DateTime.now())) {
                return 'asdfad asdf adf asdf a';
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      print('object');
    }
  }
}
