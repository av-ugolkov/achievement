import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textEditingController.value =
        TextEditingValue(text: widget.delta.toString());
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      child: TextFormField(
        controller: _textEditingController,
        keyboardType: TextInputType.number,
        maxLength: 5,
        textAlign: TextAlign.end,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly
        ],
        decoration: InputDecoration(
          isDense: true,
          counterText: '',
          border: UnderlineInputBorder(),
        ),
        onChanged: (value) {
          widget.onEditComplete.call(int.parse(value));
        },
      ),
    );
  }
}
