const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.json({ servico: 'TechNova API', fase: 2, status: 'online' });
});

// Endpoint que revela a flag da Fase 2.
// Só é útil quando a imagem builda e roda corretamente como não-root.
app.get('/flag', (req, res) => {
  res.json({ flag: 'FLAG{docker-image-buildada-e-non-root}' });
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', uptime: process.uptime() });
});

app.listen(PORT, () => {
  console.log(`TechNova API (Fase 2) rodando na porta ${PORT}`);
});
