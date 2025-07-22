import 'package:flutter/material.dart';

class TodoAddPage extends StatefulWidget {
  const TodoAddPage({super.key});

  @override
  State<TodoAddPage> createState() => _TodoAddPageState();
}

class _TodoAddPageState extends State<TodoAddPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController customTagController = TextEditingController();
  bool isToday = false;
  bool isImportant = false;
  List<String> tags = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('新しいタスクを追加')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'タスク名を入力...'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: isToday,
                  onChanged: (checked) {
                    setState(() {
                      isToday = checked ?? false;
                      if (isToday && !tags.contains('today')) {
                        tags.add('today');
                      } else if (!isToday && tags.contains('today')) {
                        tags.remove('today');
                      }
                    });
                  },
                ),
                const Text('今日'),
                const SizedBox(width: 24),
                Checkbox(
                  value: isImportant,
                  onChanged: (checked) {
                    setState(() {
                      isImportant = checked ?? false;
                      if (isImportant && !tags.contains('important')) {
                        tags.add('important');
                      } else if (!isImportant && tags.contains('important')) {
                        tags.remove('important');
                      }
                    });
                  },
                ),
                const Text('重要'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: customTagController,
                    decoration: const InputDecoration(hintText: 'カスタムタグを追加'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    final tag = customTagController.text.trim();
                    if (tag.isNotEmpty && !tags.contains(tag)) {
                      setState(() {
                        tags.add(tag);
                        customTagController.clear();
                      });
                    }
                  },
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              children: tags
                  .map(
                    (tag) => Chip(
                      label: Text(tag),
                      onDeleted: () {
                        setState(() {
                          tags.remove(tag);
                          if (tag == 'today') isToday = false;
                          if (tag == 'important') isImportant = false;
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final title = titleController.text.trim();
                  if (title.isEmpty) return;
                  Navigator.of(context).pop({
                    'title': title,
                    'isImportant': isImportant,
                    'tags': tags,
                  });
                },
                child: const Text('追加'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
