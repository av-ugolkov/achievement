import 'package:achievement/bloc/bloc_base.dart';
import 'package:flutter/material.dart';

class BlocProvider<T extends BlocBase> extends StatefulWidget {
  final T bloc;
  final Widget child;

  const BlocProvider({super.key, required this.child, required this.bloc});

  @override
  State<BlocProvider> createState() => _BlocProviderState<T>();

  static T of<T extends BlocBase>(BuildContext context) {
    var provider = context.findAncestorWidgetOfExactType<BlocProvider<T>>();
    return provider!.bloc;
  }
}

class _BlocProviderState<T> extends State<BlocProvider<BlocBase>> {
  @override
  void dispose() {
    widget.bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
