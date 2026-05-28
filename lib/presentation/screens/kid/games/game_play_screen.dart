import 'package:flutter/material.dart';
class GamePlayScreen extends StatelessWidget {
  final String gameId;
  const GamePlayScreen({super.key, required this.gameId});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Playing: $gameId')));
}
