// database.js
const sqlite3 = require('sqlite3').verbose();
const path = require('path');

// Define o caminho do arquivo SQLite
const dbPath = path.resolve(__dirname, 'tasks.db');

// Abre (ou cria) o banco de dados
const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error('Erro ao conectar ao SQLite:', err.message);
  } else {
    console.log('Conectado ao SQLite em', dbPath);
  }
});

// Cria a tabela `tasks` caso não exista
const createTableQuery = `
  CREATE TABLE IF NOT EXISTS tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    is_done INTEGER NOT NULL DEFAULT 0
  )
`;

db.run(createTableQuery, (err) => {
  if (err) {
    console.error('Erro ao criar tabela tasks:', err.message);
  } else {
    console.log('Tabela tasks pronta.');
  }
});

module.exports = db;
