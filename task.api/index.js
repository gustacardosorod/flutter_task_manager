// index.js
const express = require('express');
const cors = require('cors');
const app = express();
const tasksRouter = require('./routes/tasks');
const PORT = process.env.PORT || 3000;

// Middlewares
app.use(cors());
app.use(express.json());

// Rotas
app.use('/tasks', tasksRouter);

// Rota raiz para checar se está vivo
app.get('/', (req, res) => {
  res.send('API de Gerenciamento de Tarefas está no ar!');
});

// Inicia o servidor
app.listen(PORT, () => {
  console.log(`Servidor rodando na porta ${PORT}`);
});
