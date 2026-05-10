import 'package:achievement/bridge/localization.dart';
import 'package:achievement/data/entities/progress_entity.dart';
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

  bool _isDoAnything = false;
  final TextEditingController _textEditingController = TextEditingController();
  Map<String, ProgressDescription> _mapProgressDesc = {};

  @override
  Widget build(BuildContext context) {
    _dateNow = DateTime.now().getDate();
    var progressDesc =
        ProgressDescription(isDoAnything: false, description: '');
    if (_mapProgressDesc.containsKey(widget.keyDate)) {
      var tempMap = _mapProgressDesc[widget.keyDate];
      if (tempMap != null) {
        progressDesc = tempMap;
      }
    } else {
      _mapProgressDesc.putIfAbsent(widget.keyDate, () => progressDesc);
    }
    _isDoAnything = progressDesc.isDoAnything;
    return Column(children: [
      _buttonActiveProgressField(),
      _fieldDescriptionProgress(progressDesc.description),
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

  Widget _fieldDescriptionProgress(String description) {
    if (widget.currentDateTime.compareTo(_dateNow) <= 0) {
      _textEditingController.text = description;
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
          _mapProgressDesc[widget.keyDate]?.isDoAnything = _isDoAnything;
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
          value: _isDoAnything,
          onChanged: (value) {
            setState(() {
              _isDoAnything = !_isDoAnything;
              _mapProgressDesc[widget.keyDate]?.isDoAnything = _isDoAnything;
            });
          },
        )
      ],
    );
  }
}
