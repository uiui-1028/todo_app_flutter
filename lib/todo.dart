class Todo {
  final String title;
  bool isDone;
  bool isImportant;
  String note;
  DateTime? dueDate;

  Todo({
    required this.title,
    this.isDone = false,
    this.isImportant = false,
    this.note = '',
    this.dueDate,
  });

  Todo copyWith({
    String? title,
    bool? isDone,
    bool? isImportant,
    String? note,
    DateTime? dueDate,
  }) {
    return Todo(
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      isImportant: isImportant ?? this.isImportant,
      note: note ?? this.note,
      dueDate: dueDate ?? this.dueDate,
    );
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      title: json['title'] as String,
      isDone: json['isDone'] as bool? ?? false,
      isImportant: json['isImportant'] as bool? ?? false,
      note: json['note'] as String? ?? '',
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isDone': isDone,
      'isImportant': isImportant,
      'note': note,
      'dueDate': dueDate?.toIso8601String(),
    };
  }
}
