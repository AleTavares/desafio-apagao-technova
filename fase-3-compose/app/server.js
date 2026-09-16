const express = require('express');
const { Pool } = require('pg');

const app = express();
const PORT = process.env.PORT || 3000;

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432'),
  database: process.env.DB_NAME || 'technova',
  user: process.env.DB_USER || 'technova',
  password: process.env.DB_PASSWORD || 'technova',
});

app.get('/', (req, res) => {
  res.json({ servico: 'TechNova API', fase: 3, status: 'online' });
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', uptime: process.uptime() });
});

// A flag só é liberada quando a API consegue REALMENTE conectar ao PostgreSQL.
// Se o compose (rede/env/healthcheck) estiver quebrado, esta rota falha.
app.get('/flag', async (req, res) => {
  try {
    const result = await pool.query('SELECT 1 AS ok');
    if (result.rows[0].ok === 1) {
      return res.json({ flag: 'FLAG{compose-stack-saudavel-e-conectada}' });
    }
    return res.status(500).json({ erro: 'query inesperada' });
  } catch (err) {
    return res.status(503).json({ erro: 'sem conexão com o banco', detalhe: err.message });
  }
});

app.listen(PORT, () => {
  console.log(`TechNova API (Fase 3) rodando na porta ${PORT}`);
});
