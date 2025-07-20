import 'package:flutter/material.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

void main() {
  runApp(const ToDoApp());
}

class ToDoApp extends StatelessWidget {
  const ToDoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDoリスト',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFE0E5EC),
      ),
      home: const ToDoHomePage(),
    );
  }
}

class ToDoHomePage extends StatefulWidget {
  const ToDoHomePage({super.key});

  @override
  State<ToDoHomePage> createState() => _ToDoHomePageState();
}

class _ToDoHomePageState extends State<ToDoHomePage> {
  final List<Folder> _folders = [
    Folder(
      id: '1',
      name: '仕事',
      color: Colors.blue,
      todos: [
        TodoItem(id: '1', title: 'Flutterの学習', isDone: true),
        TodoItem(id: '2', title: 'UIのデザインを考える', isDone: true),
        TodoItem(id: '3', title: '新しい機能のアイデア出し', isDone: false),
      ],
    ),
    Folder(
      id: '2',
      name: 'プライベート',
      color: Colors.green,
      todos: [
        TodoItem(id: '4', title: '買い物リスト', isDone: false),
        TodoItem(id: '5', title: '映画を見る', isDone: false),
      ],
    ),
    Folder(
      id: '3',
      name: '学習',
      color: Colors.orange,
      todos: [
        TodoItem(id: '6', title: 'Dartの基礎', isDone: true),
        TodoItem(id: '7', title: 'Flutter State管理', isDone: false),
      ],
    ),
  ];

  final TextEditingController _folderNameController = TextEditingController();
  final TextEditingController _todoTitleController = TextEditingController();

  void _addFolder(String name) {
    if (name.trim().isNotEmpty) {
      setState(() {
        _folders.add(
          Folder(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: name.trim(),
            color: _getRandomColor(),
            todos: [],
          ),
        );
      });
    }
  }

  // _ToDoHomePageState 内のメソッドを修正

  void _addTodoToFolder(String folderId, String title) {
    if (title.trim().isNotEmpty) {
      setState(() {
        final folderIndex = _folders.indexWhere(
          (folder) => folder.id == folderId,
        );
        if (folderIndex != -1) {
          _folders[folderIndex].todos.add(
            TodoItem(
              // --- ここが重要 ---
              id: DateTime.now().millisecondsSinceEpoch.toString(), // IDを生成
              // -----------------
              title: title.trim(),
              isDone: false,
            ),
          );
        }
      });
    }
  }

  void _toggleTodo(String folderId, int todoIndex) {
    setState(() {
      final folderIndex = _folders.indexWhere(
        (folder) => folder.id == folderId,
      );
      if (folderIndex != -1 && todoIndex < _folders[folderIndex].todos.length) {
        _folders[folderIndex].todos[todoIndex].isDone =
            !_folders[folderIndex].todos[todoIndex].isDone;
      }
    });
  }

  void _deleteTodo(String folderId, int todoIndex) {
    setState(() {
      final folderIndex = _folders.indexWhere(
        (folder) => folder.id == folderId,
      );
      if (folderIndex != -1 && todoIndex < _folders[folderIndex].todos.length) {
        _folders[folderIndex].todos.removeAt(todoIndex);
      }
    });
  }

  void _deleteFolder(String folderId) {
    setState(() {
      _folders.removeWhere((folder) => folder.id == folderId);
    });
  }

  void _reorderFolders(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = _folders.removeAt(oldIndex);
      _folders.insert(newIndex, item);
    });
  }

  void _reorderTodos(String folderId, int oldIndex, int newIndex) {
    setState(() {
      final folderIndex = _folders.indexWhere(
        (folder) => folder.id == folderId,
      );
      if (folderIndex != -1) {
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }
        final item = _folders[folderIndex].todos.removeAt(oldIndex);
        _folders[folderIndex].todos.insert(newIndex, item);
      }
    });
  }

  Color _getRandomColor() {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[DateTime.now().millisecondsSinceEpoch % colors.length];
  }

  void _showAddFolderDialog() {
    _folderNameController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildNeumorphicDialog(
          title: '新しいフォルダーを作成',
          content: TextField(
            controller: _folderNameController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'フォルダー名を入力...',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) {
              _addFolder(value);
              Navigator.of(context).pop();
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                _addFolder(_folderNameController.text);
                Navigator.of(context).pop();
              },
              child: const Text('作成'),
            ),
          ],
        );
      },
    );
  }

  void _showAddTodoDialog(String folderId) {
    _todoTitleController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildNeumorphicDialog(
          title: '新しいタスクを追加',
          content: TextField(
            controller: _todoTitleController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'タスク名を入力...',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) {
              _addTodoToFolder(folderId, value);
              Navigator.of(context).pop();
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                _addTodoToFolder(folderId, _todoTitleController.text);
                Navigator.of(context).pop();
              },
              child: const Text('追加'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNeumorphicDialog({
    required String title,
    required Widget content,
    required List<Widget> actions,
  }) {
    return AlertDialog(
      backgroundColor: const Color(0xFFE0E5EC),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title),
      content: content,
      actions: actions,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ToDoリスト',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFE0E5EC),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      body: _folders.isEmpty
          ? Center(
              child: _buildNeumorphicContainer(
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_open, size: 64, color: Color(0xFF2D3748)),
                    SizedBox(height: 16),
                    Text(
                      'フォルダーがありません',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '右下の+ボタンでフォルダーを作成してください',
                      style: TextStyle(fontSize: 14, color: Color(0xFF4A5568)),
                    ),
                  ],
                ),
              ),
            )
          : ReorderableGridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              padding: const EdgeInsets.all(16),
              onReorder: _reorderFolders,
              children: _folders.map((folder) {
                return _buildFolderCard(folder);
              }).toList(),
            ),
      floatingActionButton: _buildNeumorphicFloatingActionButton(
        onPressed: _showAddFolderDialog,
        child: const Icon(Icons.add, color: Color.fromARGB(255, 55, 81, 124)),
      ),
    );
  }

  Widget _buildFolderCard(Folder folder) {
    final completedTodos = folder.todos.where((todo) => todo.isDone).length;
    final totalTodos = folder.todos.length;
    final progress = totalTodos > 0 ? completedTodos / totalTodos : 0.0;

    return _buildNeumorphicContainer(
      key: ValueKey(folder.id),
      child: InkWell(
        onTap: () => _showFolderDetails(folder),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: folder.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.folder, color: folder.color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      folder.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deleteFolder(folder.id);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('削除'),
                          ],
                        ),
                      ),
                    ],
                    child: const Icon(
                      Icons.more_vert,
                      color: Color(0xFF4A5568),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '$completedTodos / $totalTodos 完了',
                style: const TextStyle(fontSize: 12, color: Color(0xFF4A5568)),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: const Color(0xFFCBD5E0),
                valueColor: AlwaysStoppedAnimation<Color>(folder.color),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${folder.todos.length} タスク',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4A5568),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showAddTodoDialog(folder.id),
                    icon: const Icon(
                      Icons.add,
                      size: 20,
                      color: Color(0xFF4A5568),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFolderDetails(Folder folder) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return _buildNeumorphicContainer(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: folder.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.folder,
                            color: folder.color,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                folder.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                              Text(
                                '${folder.todos.length} タスク',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF4A5568),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _showAddTodoDialog(folder.id),
                          icon: const Icon(Icons.add, color: Color(0xFF2D3748)),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: folder.todos.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.task_alt,
                                  size: 64,
                                  color: folder.color.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'タスクがありません',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: folder.color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  '+ボタンでタスクを追加してください',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF4A5568),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ReorderableListView.builder(
                            onReorder: (oldIndex, newIndex) {
                              _reorderTodos(folder.id, oldIndex, newIndex);
                            },
                            itemCount: folder.todos.length,
                            itemBuilder: (context, index) {
                              final todo = folder.todos[index];
                              return _buildTodoItem(
                                key: ValueKey(
                                  todo.id,
                                ), // indexではなく、todo固有のIDを使用
                                todo: todo,
                                folderColor: folder.color,
                                onToggle: () => _toggleTodo(folder.id, index),
                                onDelete: () => _deleteTodo(folder.id, index),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTodoItem({
    required Key key,
    required TodoItem todo,
    required Color folderColor,
    required VoidCallback onToggle,
    required VoidCallback onDelete,
  }) {
    return _buildNeumorphicContainer(
      key: key,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: todo.isDone,
          onChanged: (value) => onToggle(),
          activeColor: folderColor,
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isDone ? TextDecoration.lineThrough : null,
            color: todo.isDone
                ? const Color(0xFF4A5568)
                : const Color(0xFF2D3748),
            fontWeight: todo.isDone ? FontWeight.normal : FontWeight.w500,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
          color: const Color(0xFF4A5568),
        ),
      ),
    );
  }

  Widget _buildNeumorphicContainer({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E5EC),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            offset: const Offset(-8, -8),
            blurRadius: 16,
          ),
          BoxShadow(
            color: const Color(0xFFA3B1C6).withOpacity(0.8),
            offset: const Offset(8, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildNeumorphicFloatingActionButton({
    required VoidCallback onPressed,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE0E5EC),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            offset: const Offset(-4, -4),
            blurRadius: 8,
          ),
          BoxShadow(
            color: const Color(0xFFA3B1C6).withOpacity(0.8),
            offset: const Offset(4, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _folderNameController.dispose();
    _todoTitleController.dispose();
    super.dispose();
  }
}

class Folder {
  final String id;
  final String name;
  final Color color;
  final List<TodoItem> todos;

  Folder({
    required this.id,
    required this.name,
    required this.color,
    required this.todos,
  });
}

class TodoItem {
  final String id; //  <-- これを追加！
  final String title;
  bool isDone;

  TodoItem({
    required this.id, //  <-- これを追加！
    required this.title,
    required this.isDone,
  });
}
