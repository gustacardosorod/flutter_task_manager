// lib/models/task.dart

class Task {
  int? id;
  String title;
  String description;
  bool isDone;

  Task({
    this.id,
    required this.title,
    required this.description,
    this.isDone = false,
  });

  // Converter de JSON (da API) para modelo Dart
  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        isDone: json['is_done'] == 1,
      );

  // Converter Task para JSON (para a API)
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'is_done': isDone ? 1 : 0,
      };

  // Converter para Map<String, dynamic> para sqflite
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'is_done': isDone ? 1 : 0,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  // Criar Task a partir de Map vindo do SQLite
  factory Task.fromMap(Map<String, dynamic> map) => Task(
        id: map['id'],
        title: map['title'],
        description: map['description'],
        isDone: map['is_done'] == 1,
      );
}
