import 'package:flutter/material.dart';

class ShellScope extends InheritedWidget {
  const ShellScope({
    super.key,
    required this.goToTab,
    required super.child,
  });

  final void Function(int index) goToTab;

  static ShellScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ShellScope>();
  }

  @override
  bool updateShouldNotify(ShellScope oldWidget) => goToTab != oldWidget.goToTab;
}
