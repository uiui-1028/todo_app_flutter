class Todo {
  final String title;
  bool isDone;

  Todo({required this.title, this.isDone = false});

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      title: json['title'] as String,
      isDone: json['isDone'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'isDone': isDone};
  }
}
