import 'package:flutter/material.dart';

class TodoAddPage extends StatefulWidget {
  const TodoAddPage({super.key});

  @override
  State<TodoAddPage> createState() => _TodoAddPageState();
}

class _TodoAddPageState extends State<TodoAddPage> {
  @override
  Widget build(BuildContext context) {
    // 仮のUI
    return Scaffold(
      appBar: AppBar(title: const Text('新しいタスクを追加')),
      body: const Center(child: Text('Todo追加画面')),
    );
  }
}
