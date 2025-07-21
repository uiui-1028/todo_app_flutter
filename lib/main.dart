import 'package:flutter/material.dart';

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
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum SmartListType { today, important, planned }

class _HomeScreenState extends State<HomeScreen> {
  // ダミーデータ
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
  final Map<String, List<Map<String, dynamic>>> tasksByList = {
    'today': [
      {'id': 't1', 'title': 'レポート提出', 'isDone': false, 'isImportant': true},
      {'id': 't2', 'title': '会議参加', 'isDone': false, 'isImportant': false},
    ],
    'important': [
      {'id': 't1', 'title': 'レポート提出', 'isDone': false, 'isImportant': true},
      {'id': 't3', 'title': '家賃支払い', 'isDone': false, 'isImportant': true},
    ],
    'planned': [
      {'id': 't4', 'title': '旅行予約', 'isDone': false, 'isImportant': false},
    ],
    '1': [
      {'id': 't1', 'title': 'レポート提出', 'isDone': false, 'isImportant': true},
      {'id': 't2', 'title': '会議参加', 'isDone': false, 'isImportant': false},
    ],
    '2': [
      {'id': 't3', 'title': '家賃支払い', 'isDone': false, 'isImportant': true},
    ],
    '3': [
      {'id': 't4', 'title': '旅行予約', 'isDone': false, 'isImportant': false},
    ],
  };

  String _selectedListKey = 'today';
  String _selectedListTitle = '今日';
  Color _selectedListColor = Colors.blue;
  IconData? _selectedListIcon = Icons.wb_sunny;
  String? _selectedListEmoji;

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
                  children: myLists
                      .map(
                        (myList) => ListTile(
                          leading: Text(
                            myList['emoji'],
                            style: const TextStyle(fontSize: 24),
                          ),
                          title: Text(myList['name']),
                          selected: _selectedListKey == myList['id'],
                          onTap: () => _selectMyList(myList),
                        ),
                      )
                      .toList(),
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
                final task = tasks[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  child: ListTile(
                    leading: Checkbox(
                      value: task['isDone'],
                      onChanged: (_) {},
                      activeColor: _selectedListColor,
                    ),
                    title: Text(
                      task['title'],
                      style: TextStyle(
                        decoration: task['isDone']
                            ? TextDecoration.lineThrough
                            : null,
                        color: task['isDone'] ? Colors.grey : Colors.black,
                      ),
                    ),
                    trailing: task['isImportant'] == true
                        ? Icon(Icons.star, color: Colors.red)
                        : null,
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: _selectedListColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
