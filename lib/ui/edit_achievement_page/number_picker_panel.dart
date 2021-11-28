import 'package:flutter/material.dart';

class NumberPickerPanel extends StatefulWidget {
  final int delta;
  final Function(int) onEditComplete;

  const NumberPickerPanel({
    Key? key,
    required this.delta,
    required this.onEditComplete,
  }) : super(key: key);

  @override
  _NumberPickerPanelState createState() => _NumberPickerPanelState();
}

class _NumberPickerPanelState extends State<NumberPickerPanel> {
  @override
  Widget build(BuildContext context) {
    final _textEditingController =
        TextEditingController(text: widget.delta.toString());
    return SizedBox(
      width: 50,
      child: TextFormField(
        controller: _textEditingController,
        keyboardType: TextInputType.number,
        maxLength: 10,
        textAlign: TextAlign.end,
        decoration: InputDecoration(
          isDense: true,
          counterText: '',
          border: UnderlineInputBorder(),
        ),
        onEditingComplete: () {
          widget.onEditComplete.call(int.parse(_textEditingController.text));
          FocusScope.of(context).unfocus();
        },
      ),
    );
  }
}
