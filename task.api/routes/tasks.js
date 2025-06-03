// routes/tasks.js
const express = require('express');
const router = express.Router();
const db = require('../database');

// GET /tasks - lista todas as tarefas
router.get('/', (req, res) => {
  const query = 'SELECT * FROM tasks ORDER BY id DESC';
  db.all(query, [], (err, rows) => {
    if (err) {
      console.error('Erro ao buscar tarefas:', err.message);
      return res.status(500).json({ error: 'Erro interno do servidor.' });
    }
    const tasks = rows.map((row) => ({
      id: row.id,
      title: row.title,
      description: row.description,
      is_done: row.is_done,
    }));
    res.json(tasks);
  });
});

// GET /tasks/:id - busca tarefa por ID (opcional)
router.get('/:id', (req, res) => {
  const { id } = req.params;
  const query = 'SELECT * FROM tasks WHERE id = ?';
  db.get(query, [id], (err, row) => {
    if (err) {
      console.error('Erro ao buscar tarefa:', err.message);
      return res.status(500).json({ error: 'Erro interno do servidor.' });
    }
    if (!row) {
      return res.status(404).json({ error: 'Tarefa não encontrada.' });
    }
    res.json({
      id: row.id,
      title: row.title,
      description: row.description,
      is_done: row.is_done,
    });
  });
});

// POST /tasks - cria nova tarefa
router.post('/', (req, res) => {
  const { title, description, is_done } = req.body;
  if (!title || !description) {
    return res
      .status(400)
      .json({ error: 'title e description são obrigatórios.' });
  }
  const query =
    'INSERT INTO tasks (title, description, is_done) VALUES (?, ?, ?)';
  db.run(query, [title, description, is_done ? 1 : 0], function (err) {
    if (err) {
      console.error('Erro ao inserir tarefa:', err.message);
      return res.status(500).json({ error: 'Erro interno do servidor.' });
    }
    const newTask = {
      id: this.lastID,
      title,
      description,
      is_done: is_done ? 1 : 0,
    };
    res.status(201).json(newTask);
  });
});

// PUT /tasks/:id - atualiza uma tarefa
router.put('/:id', (req, res) => {
  const { id } = req.params;
  const { title, description, is_done } = req.body;
  const queryCheck = 'SELECT * FROM tasks WHERE id = ?';

  db.get(queryCheck, [id], (err, row) => {
    if (err) {
      console.error('Erro ao verificar tarefa:', err.message);
      return res.status(500).json({ error: 'Erro interno do servidor.' });
    }
    if (!row) {
      return res.status(404).json({ error: 'Tarefa não encontrada.' });
    }
    const queryUpdate =
      'UPDATE tasks SET title = ?, description = ?, is_done = ? WHERE id = ?';
    db.run(
      queryUpdate,
      [title ?? row.title, description ?? row.description, is_done ? 1 : 0, id],
      function (err) {
        if (err) {
          console.error('Erro ao atualizar tarefa:', err.message);
          return res.status(500).json({ error: 'Erro interno do servidor.' });
        }
        res.json({
          id: Number(id),
          title: title ?? row.title,
          description: description ?? row.description,
          is_done: is_done ? 1 : 0,
        });
      }
    );
  });
});

// DELETE /tasks/:id - deleta uma tarefa
router.delete('/:id', (req, res) => {
  const { id } = req.params;
  const query = 'DELETE FROM tasks WHERE id = ?';
  db.run(query, [id], function (err) {
    if (err) {
      console.error('Erro ao deletar tarefa:', err.message);
      return res.status(500).json({ error: 'Erro interno do servidor.' });
    }
    if (this.changes === 0) {
      return res.status(404).json({ error: 'Tarefa não encontrada.' });
    }
    res.json({ message: 'Tarefa removida com sucesso.' });
  });
});

module.exports = router;
