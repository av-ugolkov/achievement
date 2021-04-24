import 'package:achievement/model/progress_model.dart';
import 'package:achievement/pages/view_achievement_page/inherited_description_progress.dart';
import 'package:flutter/material.dart';
import 'package:achievement/utils/extensions.dart';

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
    return _fieldDescriptionProgress();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _mapProgressDesc = InheritedDescriptionProgress.of(context);
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
      return Stack(
        clipBehavior: Clip.none,
        children: [
          _fieldProgressDescription(),
          _buttonActiveProgressField(),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget _fieldProgressDescription() {
    return TextField(
      readOnly: !_isDoAnythink,
      controller: _textEditingController,
      minLines: 1,
      maxLines: 7,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: _isDoAnythink ? Colors.blue : Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: _isDoAnythink ? Colors.blue : Colors.grey),
        ),
      ),
      onTap: () {
        setState(() {
          _isDoAnythink = true;
          _mapProgressDesc[widget.keyDate]?.isDoAnythink = _isDoAnythink;
        });
      },
      onChanged: (value) {
        _mapProgressDesc[widget.keyDate]?.description = value;
      },
    );
  }

  Widget _buttonActiveProgressField() {
    return Positioned(
      right: -20,
      top: -20,
      child: IconButton(
        icon: Stack(
          children: [
            Icon(
              Icons.circle,
              color: Colors.white,
            ),
            Icon(
              Icons.check_circle,
              color: _isDoAnythink ? Colors.green : Colors.grey,
            ),
          ],
        ),
        onPressed: () {
          setState(() {
            _isDoAnythink = !_isDoAnythink;
            _mapProgressDesc[widget.keyDate]?.isDoAnythink = _isDoAnythink;
          });
        },
        iconSize: 30,
      ),
    );
  }
}
