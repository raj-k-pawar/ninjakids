import 'package:flutter/material.dart';
class QuizResultScreen extends StatelessWidget {
  final Map<String, dynamic> resultData;
  const QuizResultScreen({super.key, required this.resultData});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Quiz Result')));
}
