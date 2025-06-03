// lib/widgets/task_item.dart

import 'package:flutter/material.dart';
import '../models/task.dart';

typedef OnToggleDone = void Function(Task task);
typedef OnEdit = void Function(Task task);
typedef OnDelete = void Function(int id);

class TaskItem extends StatelessWidget {
  final Task task;
  final OnToggleDone onToggleDone;
  final OnEdit onEdit;
  final OnDelete onDelete;

  const TaskItem({
    Key? key,
    required this.task,
    required this.onToggleDone,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Checkbox(
          value: task.isDone,
          onChanged: (_) => onToggleDone(task),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration:
                task.isDone ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        subtitle: Text(task.description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => onEdit(task),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => onDelete(task.id!),
            ),
          ],
        ),
      ),
    );
  }
}
