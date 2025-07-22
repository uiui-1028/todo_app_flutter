import 'package:uuid/uuid.dart';

class Step {
  final String id;
  final String title;
  final bool isDone;

  Step({String? id, required this.title, this.isDone = false})
    : id = id ?? const Uuid().v4();

  Step copyWith({String? id, String? title, bool? isDone}) {
    return Step(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }

  factory Step.fromJson(Map<String, dynamic> json) {
    return Step(
      id: json['id'] as String?,
      title: json['title'] as String,
      isDone: json['isDone'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'isDone': isDone};
  }
}
