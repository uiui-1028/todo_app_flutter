import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../todo.dart';

class TodoListItem extends StatelessWidget {
  final Todo todo;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onDelete;
  final bool isDragging;
  final bool isFeedback;
  final Color? activeColor;

  const TodoListItem({
    super.key,
    required this.todo,
    required this.onChanged,
    required this.onDelete,
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
        leading: Checkbox(
          value: todo.isDone,
          onChanged: isFeedback ? null : onChanged,
          activeColor: activeColor,
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

enum SmartListType { today, important, planned }

class _TodoListPageState extends State<TodoListPage> {
  final List<Map<String, dynamic>> smartLists = [
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
    {
      'type': SmartListType.planned,
      'title': '計画済み',
      'icon': Icons.calendar_today,
      'color': Colors.purple,
    },
  ];
  final List<Map<String, dynamic>> myLists = [
    {'id': '1', 'name': '仕事', 'emoji': '💼', 'color': Colors.blue},
    {'id': '2', 'name': 'プライベート', 'emoji': '🏠', 'color': Colors.green},
    {'id': '3', 'name': '買い物', 'emoji': '🛒', 'color': Colors.orange},
  ];
  Map<String, List<Todo>> tasksByList = {
    'today': [Todo(title: 'レポート提出'), Todo(title: '会議参加')],
    'important': [Todo(title: 'レポート提出'), Todo(title: '家賃支払い')],
    'planned': [Todo(title: '旅行予約')],
    '1': [Todo(title: 'レポート提出'), Todo(title: '会議参加')],
    '2': [Todo(title: '家賃支払い')],
    '3': [Todo(title: '旅行予約')],
  };

  static const String _storageKey = 'tasksByList';

  String _selectedListKey = 'today';
  String _selectedListTitle = '今日';
  Color _selectedListColor = Colors.blue;
  IconData? _selectedListIcon = Icons.wb_sunny;
  String? _selectedListEmoji;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString != null) {
      final Map<String, dynamic> decoded = json.decode(jsonString);
      setState(() {
        tasksByList = decoded.map(
          (key, value) => MapEntry(
            key,
            (value as List).map((e) => Todo.fromJson(e)).toList(),
          ),
        );
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(
      tasksByList.map(
        (key, value) =>
            MapEntry(key, value.map((todo) => todo.toJson()).toList()),
      ),
    );
    await prefs.setString(_storageKey, jsonString);
  }

  void _selectSmartList(Map<String, dynamic> smartList) {
    setState(() {
      _selectedListKey = smartList['type'].toString().split('.').last;
      _selectedListTitle = smartList['title'];
      _selectedListColor = smartList['color'];
      _selectedListIcon = smartList['icon'];
      _selectedListEmoji = null;
    });
    Navigator.of(context).pop();
  }

  void _selectMyList(Map<String, dynamic> myList) {
    setState(() {
      _selectedListKey = myList['id'];
      _selectedListTitle = myList['name'];
      _selectedListColor = myList['color'];
      _selectedListIcon = null;
      _selectedListEmoji = myList['emoji'];
    });
    Navigator.of(context).pop();
  }

  String? _dragTargetListId;

  @override
  Widget build(BuildContext context) {
    final tasks = tasksByList[_selectedListKey] ?? [];
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (_selectedListIcon != null)
              Icon(_selectedListIcon, color: _selectedListColor),
            if (_selectedListEmoji != null)
              Text(_selectedListEmoji!, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(
              _selectedListTitle,
              style: TextStyle(
                color: _selectedListColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFE0E5EC),
        elevation: 0,
        iconTheme: IconThemeData(color: _selectedListColor),
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
                  selected:
                      _selectedListKey ==
                      smartList['type'].toString().split('.').last,
                  onTap: () => _selectSmartList(smartList),
                ),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'マイリスト',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Expanded(
                child: ListView(
                  children: myLists.map((myList) {
                    final isTarget = _dragTargetListId == myList['id'];
                    return DragTarget<Todo>(
                      onWillAccept: (data) => data != null,
                      onAccept: (todo) {
                        setState(() {
                          tasksByList[_selectedListKey]?.remove(todo);
                          tasksByList[myList['id']] ??= [];
                          tasksByList[myList['id']]!.add(todo);
                        });
                        _saveTasks();
                      },
                      onMove: (details) {
                        setState(() {
                          _dragTargetListId = myList['id'];
                        });
                      },
                      onLeave: (data) {
                        setState(() {
                          _dragTargetListId = null;
                        });
                      },
                      builder: (context, candidateData, rejectedData) {
                        return Container(
                          decoration: BoxDecoration(
                            border: isTarget
                                ? Border.all(color: Colors.blue, width: 2)
                                : null,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            leading: Text(
                              myList['emoji'],
                              style: const TextStyle(fontSize: 24),
                            ),
                            title: Text(myList['name']),
                            selected: _selectedListKey == myList['id'],
                            onTap: () => _selectMyList(myList),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      body: tasks.isEmpty
          ? const Center(child: Text('タスクがありません'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final todo = tasks[index];
                return LongPressDraggable<Todo>(
                  data: todo,
                  feedback: Material(
                    color: Colors.transparent,
                    child: TodoListItem(
                      todo: todo,
                      onChanged: (checked) {
                        setState(() {
                          todo.isDone = checked ?? false;
                        });
                        _saveTasks();
                      },
                      onDelete: () {
                        setState(() {
                          tasksByList[_selectedListKey]?.remove(todo);
                        });
                        _saveTasks();
                      },
                      isFeedback: true,
                    ),
                  ),
                  childWhenDragging: TodoListItem(
                    todo: todo,
                    onChanged: (checked) {
                      setState(() {
                        todo.isDone = checked ?? false;
                      });
                    },
                    onDelete: () {
                      setState(() {
                        tasksByList[_selectedListKey]?.remove(todo);
                      });
                      _saveTasks();
                    },
                    isDragging: true,
                  ),
                  child: TodoListItem(
                    todo: todo,
                    onChanged: (checked) {
                      setState(() {
                        todo.isDone = checked ?? false;
                      });
                      _saveTasks();
                    },
                    onDelete: () {
                      setState(() {
                        tasksByList[_selectedListKey]?.remove(todo);
                      });
                      _saveTasks();
                    },
                    activeColor: _selectedListColor,
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTitle = await showDialog<String>(
            context: context,
            builder: (context) {
              String input = '';
              return AlertDialog(
                title: const Text('新しいタスクを追加'),
                content: TextField(
                  autofocus: true,
                  decoration: const InputDecoration(hintText: 'タスク名を入力...'),
                  onChanged: (value) => input = value,
                  onSubmitted: (value) => Navigator.of(context).pop(value),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('キャンセル'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(input),
                    child: const Text('追加'),
                  ),
                ],
              );
            },
          );
          if (newTitle != null && newTitle.trim().isNotEmpty) {
            setState(() {
              tasksByList[_selectedListKey] ??= [];
              tasksByList[_selectedListKey]!.add(Todo(title: newTitle.trim()));
            });
            _saveTasks();
          }
        },
        backgroundColor: _selectedListColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
