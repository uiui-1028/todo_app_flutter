import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../todo.dart';
import '../models/step.dart' as step_model;

class TodoDetailPage extends StatefulWidget {
  final Todo todo;
  const TodoDetailPage({super.key, required this.todo});

  @override
  State<TodoDetailPage> createState() => _TodoDetailPageState();
}

class _TodoDetailPageState extends State<TodoDetailPage> {
  late bool isImportant;
  late TextEditingController noteController;
  late List<step_model.Step> steps;
  final TextEditingController stepInputController = TextEditingController();
  DateTime? dueDate;

  @override
  void initState() {
    super.initState();
    isImportant = widget.todo.isImportant;
    noteController = TextEditingController(text: widget.todo.note);
    steps = List<step_model.Step>.from(widget.todo.steps);
    dueDate = widget.todo.dueDate;
    noteController.addListener(_autoSave);
  }

  @override
  void dispose() {
    noteController.removeListener(_autoSave);
    noteController.dispose();
    stepInputController.dispose();
    super.dispose();
  }

  void _autoSave() {
    _saveAndPop(auto: true);
  }

  void _saveAndPop({bool auto = false}) {
    final updated = widget.todo.copyWith(
      isImportant: isImportant,
      note: noteController.text,
      steps: steps,
      dueDate: dueDate,
    );
    if (auto) {
      // 親画面に戻らず、値だけ返す
      Navigator.of(context).pop(updated);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => MainScreen()),
        (route) => false,
      );
    } else {
      Navigator.of(context).pop(updated);
    }
  }

  void _addStep() {
    final text = stepInputController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      steps.add(step_model.Step(title: text));
      stepInputController.clear();
    });
    _autoSave();
  }

  void _toggleStepDone(int index, bool? checked) {
    setState(() {
      steps[index] = steps[index].copyWith(isDone: checked ?? false);
    });
    _autoSave();
  }

  String _formatDueDate(DateTime? date) {
    if (date == null) return '期日を追加';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return '今日';
    if (d == tomorrow) return '明日';
    return DateFormat('yyyy/MM/dd').format(date);
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        dueDate = picked;
      });
      _autoSave();
    }
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
              _autoSave();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.event),
              title: Text(_formatDueDate(dueDate)),
              onTap: _pickDueDate,
              trailing: dueDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          dueDate = null;
                        });
                        _autoSave();
                      },
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            const Text('メモ', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: noteController,
              maxLines: null,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'メモを入力...',
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: stepInputController,
                    decoration: const InputDecoration(
                      hintText: 'ステップを追加',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addStep(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _addStep, child: const Text('追加')),
              ],
            ),
            const SizedBox(height: 16),
            const Text('ステップ', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: steps.isEmpty
                  ? const Text('ステップがありません')
                  : ListView.separated(
                      itemCount: steps.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final step = steps[index];
                        return CheckboxListTile(
                          value: step.isDone,
                          onChanged: (checked) =>
                              _toggleStepDone(index, checked),
                          title: Text(
                            step.title,
                            style: TextStyle(
                              decoration: step.isDone
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: step.isDone ? Colors.grey : Colors.black,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
