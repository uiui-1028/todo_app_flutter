import 'package:flutter/material.dart';
import '../todo.dart';

class TodoDetailPage extends StatefulWidget {
  final Todo todo;
  const TodoDetailPage({super.key, required this.todo});

  @override
  State<TodoDetailPage> createState() => _TodoDetailPageState();
}

class _TodoDetailPageState extends State<TodoDetailPage> {
  late bool isImportant;
  late TextEditingController noteController;

  @override
  void initState() {
    super.initState();
    isImportant = widget.todo.isImportant;
    noteController = TextEditingController(text: widget.todo.note);
  }

  @override
  void dispose() {
    noteController.dispose();
    super.dispose();
  }

  void _saveAndPop() {
    final updated = widget.todo.copyWith(
      isImportant: isImportant,
      note: noteController.text,
    );
    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.todo.title),
        actions: [
          IconButton(
            icon: Icon(
              isImportant ? Icons.star : Icons.star_border,
              color: isImportant ? Colors.amber : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                isImportant = !isImportant;
              });
            },
          ),
          IconButton(icon: const Icon(Icons.save), onPressed: _saveAndPop),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('メモ', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: noteController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'メモを入力...',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
