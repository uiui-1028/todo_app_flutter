import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../todo.dart';
import 'todo_detail_page.dart';
import 'todo_add_page.dart';

class TodoListItem extends StatelessWidget {
  final Todo todo;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onDelete;
  final VoidCallback onToggleImportant;
  final bool isDragging;
  final bool isFeedback;
  final Color? activeColor;

  const TodoListItem({
    super.key,
    required this.todo,
    required this.onChanged,
    required this.onDelete,
    required this.onToggleImportant,
    this.isDragging = false,
    this.isFeedback = false,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: isFeedback ? 4 : 2,
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                todo.isImportant ? Icons.star : Icons.star_border,
                color: todo.isImportant ? Colors.amber : Colors.grey,
              ),
              onPressed: isFeedback ? null : onToggleImportant,
              tooltip: '重要',
            ),
            Checkbox(
              value: todo.isDone,
              onChanged: isFeedback ? null : onChanged,
              activeColor: activeColor,
            ),
          ],
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isDone ? TextDecoration.lineThrough : null,
            color: todo.isDone ? Colors.grey : Colors.black,
          ),
        ),
        trailing: isFeedback
            ? null
            : IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
      ),
    );
  }
}

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

enum SmartListType { all, today, important, custom }

class _TodoListPageState extends State<TodoListPage> {
  final List<Map<String, dynamic>> smartLists = [
    {
      'type': SmartListType.all,
      'title': 'すべて',
      'icon': Icons.list,
      'color': Colors.grey,
    },
    {
      'type': SmartListType.today,
      'title': '今日',
      'icon': Icons.wb_sunny,
      'color': Colors.blue,
    },
    {
      'type': SmartListType.important,
      'title': '重要',
      'icon': Icons.star,
      'color': Colors.red,
    },
  ];
  List<Todo> tasks = [];
  static const String _storageKey = 'tasks';
  SmartListType _selectedListType = SmartListType.today;
  String? _selectedCustomTag;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      final List<dynamic> decoded = json.decode(jsonString);
      setState(() {
        tasks = decoded.map((e) => Todo.fromJson(e)).toList();
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(tasks.map((todo) => todo.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  void _selectSmartList(Map<String, dynamic> smartList) {
    setState(() {
      _selectedListType = smartList['type'];
      _selectedCustomTag = null;
    });
    Navigator.of(context).pop();
  }

  void _selectCustomTag(String tag) {
    setState(() {
      _selectedListType = SmartListType.custom;
      _selectedCustomTag = tag;
    });
    Navigator.of(context).pop();
  }

  List<String> get customTags {
    final tags = tasks.expand((t) => t.tags).toSet().toList();
    tags.removeWhere((t) => t == 'today' || t == 'important');
    return tags;
  }

  List<Todo> get filteredTasks {
    switch (_selectedListType) {
      case SmartListType.all:
        return tasks;
      case SmartListType.today:
        return tasks.where((t) => t.tags.contains('today')).toList();
      case SmartListType.important:
        return tasks.where((t) => t.tags.contains('important')).toList();
      case SmartListType.custom:
        if (_selectedCustomTag != null) {
          return tasks
              .where((t) => t.tags.contains(_selectedCustomTag!))
              .toList();
        }
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final listTitle = _selectedListType == SmartListType.custom
        ? _selectedCustomTag ?? ''
        : smartLists.firstWhere((s) => s['type'] == _selectedListType)['title'];
    final listColor = _selectedListType == SmartListType.custom
        ? Colors.green
        : smartLists.firstWhere((s) => s['type'] == _selectedListType)['color'];
    final listIcon = _selectedListType == SmartListType.custom
        ? Icons.label
        : smartLists.firstWhere((s) => s['type'] == _selectedListType)['icon'];
    final tasksToShow = filteredTasks;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(listIcon, color: listColor),
            const SizedBox(width: 8),
            Text(
              listTitle,
              style: TextStyle(color: listColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFE0E5EC),
        elevation: 0,
        iconTheme: IconThemeData(color: listColor),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'スマートリスト',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              ...smartLists.map(
                (smartList) => ListTile(
                  leading: Icon(smartList['icon'], color: smartList['color']),
                  title: Text(smartList['title']),
                  selected: _selectedListType == smartList['type'],
                  onTap: () => _selectSmartList(smartList),
                ),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'カスタムタグ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              ...customTags.map(
                (tag) => ListTile(
                  leading: const Icon(Icons.label, color: Colors.green),
                  title: Text(tag),
                  selected:
                      _selectedListType == SmartListType.custom &&
                      _selectedCustomTag == tag,
                  onTap: () => _selectCustomTag(tag),
                ),
              ),
            ],
          ),
        ),
      ),
      body: tasksToShow.isEmpty
          ? const Center(child: Text('タスクがありません'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: tasksToShow.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final todo = tasksToShow[index];
                return TodoListItem(
                  todo: todo,
                  onChanged: (checked) {
                    setState(() {
                      todo.isDone = checked ?? false;
                    });
                    _saveTasks();
                  },
                  onDelete: () {
                    setState(() {
                      tasks.remove(todo);
                    });
                    _saveTasks();
                  },
                  onToggleImportant: () {
                    setState(() {
                      todo.isImportant = !todo.isImportant;
                      if (todo.isImportant &&
                          !todo.tags.contains('important')) {
                        todo.tags.add('important');
                      } else if (!todo.isImportant &&
                          todo.tags.contains('important')) {
                        todo.tags.remove('important');
                      }
                    });
                    _saveTasks();
                  },
                  activeColor: listColor,
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TodoAddPage()),
          );
          if (result is Map<String, dynamic>) {
            setState(() {
              tasks.add(
                Todo(
                  title: result['title'],
                  isImportant: result['isImportant'] ?? false,
                  tags: List<String>.from(result['tags'] ?? []),
                ),
              );
            });
            _saveTasks();
          }
        },
        backgroundColor: listColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
