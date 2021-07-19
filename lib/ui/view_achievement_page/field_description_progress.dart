import 'package:achievement/bridge/localization.dart';
import 'package:achievement/data/model/progress_model.dart';
import 'package:achievement/ui/view_achievement_page/inherited_description_progress.dart';
import 'package:flutter/material.dart';
import 'package:achievement/core/extensions.dart';

class FieldDescriptionProgress extends StatefulWidget {
  final DateTime currentDateTime;
  FieldDescriptionProgress({required this.currentDateTime});

  @override
  _FieldDescriptionProgressState createState() =>
      _FieldDescriptionProgressState();

  String get keyDate => currentDateTime.getDate().toIso8601String();
}

class _FieldDescriptionProgressState extends State<FieldDescriptionProgress> {
  late DateTime _dateNow;

  bool _isDoAnythink = false;
  final TextEditingController _textEditingController = TextEditingController();
  Map<String, ProgressDescription> _mapProgressDesc = {};

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _buttonActiveProgressField(),
      _fieldDescriptionProgress(),
    ]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _mapProgressDesc = InheritedDescriptionProgress.of(context);
  }

  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
  }

  Widget _fieldDescriptionProgress() {
    _dateNow = DateTime.now().getDate();
    if (widget.currentDateTime.compareTo(_dateNow) <= 0) {
      var progressDesc =
          ProgressDescription(isDoAnythink: false, description: '');
      if (_mapProgressDesc.containsKey(widget.keyDate)) {
        var tempMap = _mapProgressDesc[widget.keyDate];
        if (tempMap != null) {
          progressDesc = tempMap;
        }
      } else {
        _mapProgressDesc.putIfAbsent(widget.keyDate, () => progressDesc);
      }
      _isDoAnythink = progressDesc.isDoAnythink;
      _textEditingController.text = progressDesc.description;
      return _fieldProgressDescription();
    } else {
      return Container();
    }
  }

  Widget _fieldProgressDescription() {
    return TextField(
      controller: _textEditingController,
      minLines: 1,
      maxLines: 7,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
        hintText: getLocaleOfContext(context).what_do_you_do_or_not_do,
      ),
      onTap: () {
        setState(() {
          _mapProgressDesc[widget.keyDate]?.isDoAnythink = _isDoAnythink;
        });
      },
      onChanged: (value) {
        _mapProgressDesc[widget.keyDate]?.description = value;
      },
    );
  }

  Widget _buttonActiveProgressField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(getLocaleOfContext(context).what_do_you_do),
        Switch(
          value: _isDoAnythink,
          onChanged: (value) {
            setState(() {
              _isDoAnythink = !_isDoAnythink;
              _mapProgressDesc[widget.keyDate]?.isDoAnythink = _isDoAnythink;
            });
          },
        )
      ],
    );
  }
}
