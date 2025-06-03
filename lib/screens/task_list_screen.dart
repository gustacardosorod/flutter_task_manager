// lib/screens/task_list_screen.dart

import 'package:flutter/material.dart';
import '../helpers/db_helper.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import '../widgets/task_item.dart';
import 'task_form_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final DBHelper _dbHelper = DBHelper();
  final ApiService _apiService = ApiService();

  List<Task> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);

    // 1) Tenta buscar do servidor; se falhar, usa o local
    try {
      final remoteTasks = await _apiService.fetchTasks();

      // Substitui os registros locais pelo que veio da API
      // Limpa local e re-popula
      for (var t in await _dbHelper.getAllTasks()) {
        await _dbHelper.deleteTask(t.id!);
      }
      for (var t in remoteTasks) {
        await _dbHelper.insertTask(t);
      }

      _tasks = remoteTasks;
    } catch (e) {
      // Se a API falhar, carrega do local
      _tasks = await _dbHelper.getAllTasks();
    }

    setState(() => _isLoading = false);
  }

  Future<void> _deleteTask(int id) async {
    // Tenta deletar remotamente
    try {
      await _apiService.deleteTask(id);
    } catch (_) {
      // Se falhar, ignora (pode estar offline)
    }

    // Deleta localmente também
    await _dbHelper.deleteTask(id);
    await _loadTasks();
  }

  Future<void> _toggleDone(Task task) async {
    final updated = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      isDone: !task.isDone,
    );
    // Atualiza local
    await _dbHelper.updateTask(updated);

    // Tenta enviar à API
    try {
      await _apiService.updateTask(updated);
    } catch (_) {
      // ignora
    }

    await _loadTasks();
  }

  void _goToForm({Task? task}) async {
    final bool? shouldReload = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TaskFormScreen(existingTask: task),
      ),
    );
    if (shouldReload == true) {
      await _loadTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Tarefas'),
        centerTitle: true,
        backgroundColor: Colors.lightBlue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? const Center(child: Text('Nenhuma tarefa encontrada.'))
              : RefreshIndicator(
                  onRefresh: _loadTasks,
                  child: ListView.builder(
                    itemCount: _tasks.length,
                    itemBuilder: (ctx, i) => TaskItem(
                      task: _tasks[i],
                      onToggleDone: _toggleDone,
                      onEdit: (task) => _goToForm(task: task),
                      onDelete: (id) => _deleteTask(id),
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue,
        onPressed: () => _goToForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
