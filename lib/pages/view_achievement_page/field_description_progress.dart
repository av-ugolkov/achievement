import 'package:achievement/model/progress_model.dart';
import 'package:flutter/material.dart';
import 'package:achievement/utils/extensions.dart';

class FieldDescriptionProgress extends StatefulWidget {
  @override
  _FieldDescriptionProgressState createState() =>
      _FieldDescriptionProgressState();
}

class _FieldDescriptionProgressState extends State<FieldDescriptionProgress> {
  late DateTime _dateNow;

  bool _isDoAnythink = false;
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return _fieldDescriptionProgress();
  }

  Widget _fieldDescriptionProgress() {
    _dateNow = DateTime.now().getDate();
    return FutureBuilder<ProgressModel>(
        future: _futureProgressModel,
        builder: (buildContext, snapshot) {
          if (snapshot.hasData) {
            if (_currentDateTime.compareTo(_dateNow) <= 0) {
              var progress = snapshot.data;
              _progressDesc = progress?.progressDescription[
                      _currentDateTime.getDate().toIso8601String()] ??
                  ProgressDescription(isDoAnythink: false, description: '');
              _isDoAnythink = _progressDesc.isDoAnythink;
              _textEditingController.text = _progressDesc.description;
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
          } else {
            return Container();
          }
        });
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
          //_onPressSetProgress(_progressDesc);
        });
      },
      onSubmitted: (value) {
        // _onPressSetProgress(_progressDesc);
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
            //_onPressSetProgress(_progressDesc);
          });
        },
        iconSize: 30,
      ),
    );
  }
}
