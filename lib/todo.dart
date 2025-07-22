import 'models/step.dart';

class Todo {
  final String title;
  bool isDone;
  bool isImportant;
  String note;
  DateTime? dueDate;
  List<Step> steps;

  Todo({
    required this.title,
    this.isDone = false,
    this.isImportant = false,
    this.note = '',
    this.dueDate,
    List<Step>? steps,
  }) : steps = steps ?? [];

  Todo copyWith({
    String? title,
    bool? isDone,
    bool? isImportant,
    String? note,
    DateTime? dueDate,
    List<Step>? steps,
  }) {
    return Todo(
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      isImportant: isImportant ?? this.isImportant,
      note: note ?? this.note,
      dueDate: dueDate ?? this.dueDate,
      steps: steps ?? List<Step>.from(this.steps),
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
      steps:
          (json['steps'] as List?)?.map((e) => Step.fromJson(e)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isDone': isDone,
      'isImportant': isImportant,
      'note': note,
      'dueDate': dueDate?.toIso8601String(),
      'steps': steps.map((s) => s.toJson()).toList(),
    };
  }
}
