// lib/screens/task_form_screen.dart

import 'package:flutter/material.dart';
import '../helpers/db_helper.dart';
import '../models/task.dart';
import '../services/api_service.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? existingTask;

  const TaskFormScreen({Key? key, this.existingTask}) : super(key: key);

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final DBHelper _dbHelper = DBHelper();
  final ApiService _apiService = ApiService();

  late String _title;
  late String _description;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _title = widget.existingTask?.title ?? '';
    _description = widget.existingTask?.description ?? '';
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    if (widget.existingTask == null) {
      // Criando nova tarefa
      final newTask = Task(title: _title, description: _description, isDone: false);
      // 1) Tenta criar na API
      try {
        final created = await _apiService.createTask(newTask);
        // Salva localmente com o ID retornado pela API
        await _dbHelper.insertTask(created);
      } catch (_) {
        // Se falhar (offline), salva local sem ID (id será gerado localmente)
        await _dbHelper.insertTask(newTask);
      }
    } else {
      // Atualizando tarefa
      final updatedTask = Task(
        id: widget.existingTask!.id,
        title: _title,
        description: _description,
        isDone: widget.existingTask!.isDone,
      );
      // 1) Atualiza local
      await _dbHelper.updateTask(updatedTask);

      // 2) Tenta atualizar na API (pode falhar se estiver offline)
      try {
        await _apiService.updateTask(updatedTask);
      } catch (_) {}

    }

    setState(() => _isLoading = false);
    // Retorna true para sinalizar que a lista deve recarregar
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingTask != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Tarefa' : 'Nova Tarefa'),
        backgroundColor: Colors.lightBlue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: _title,
                      decoration: const InputDecoration(labelText: 'Título'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, insira um título.';
                        }
                        return null;
                      },
                      onSaved: (value) => _title = value!.trim(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _description,
                      decoration: const InputDecoration(labelText: 'Descrição'),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor, insira uma descrição.';
                        }
                        return null;
                      },
                      onSaved: (value) => _description = value!.trim(),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        backgroundColor: Colors.lightBlue,
                      ),
                      onPressed: _saveTask,
                      child: Text(isEditing ? 'Atualizar' : 'Salvar'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
