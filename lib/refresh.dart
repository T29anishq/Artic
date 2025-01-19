import 'package:flutter/material.dart';

class RefreshWidget extends StatelessWidget {
  final Future<void> Function() onRefresh; // Callback for refresh action
  final Widget child;

  RefreshWidget({required this.onRefresh, required this.child});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: child,
    );
  }
}
