import 'package:flutter/material.dart';
import 'screens/todo_list_page.dart';
import 'screens/todo_add_page.dart';

void main() {
  runApp(const ToDoApp());
}

class ToDoApp extends StatelessWidget {
  const ToDoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Microsoft To Do風タスク管理',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFE0E5EC),
      ),
      home: const TodoListPage(),
    );
  }
}
