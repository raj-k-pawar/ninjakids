import 'package:flutter/material.dart';

class ScreenTimeRing extends StatelessWidget {
  final int usedMinutes;
  final int limitMinutes;
  const ScreenTimeRing({super.key, required this.usedMinutes, required this.limitMinutes});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
