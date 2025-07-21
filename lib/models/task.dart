import 'attachment.dart';
import 'task_step.dart';

class Task {
  final String id;
  final String title;
  final bool isDone;
  final DateTime? dueDate;
  final DateTime? reminder;
  final RepeatType? repeat;
  final String? note;
  final List<Attachment> attachments;
  final List<TaskStep> steps;
  final bool isImportant;
  final String listId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.title,
    required this.isDone,
    this.dueDate,
    this.reminder,
    this.repeat,
    this.note,
    this.attachments = const [],
    this.steps = const [],
    this.isImportant = false,
    required this.listId,
    required this.createdAt,
    required this.updatedAt,
  });
}

enum RepeatType { none, daily, weekly, monthly }
