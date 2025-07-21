import 'user.dart';

class TaskList {
  final String id;
  final String name;
  final String? emoji;
  final String? background;
  final bool isShared;
  final List<User> members;

  TaskList({
    required this.id,
    required this.name,
    this.emoji,
    this.background,
    this.isShared = false,
    this.members = const [],
  });
}
