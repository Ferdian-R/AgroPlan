const express = require('express');
const cors = require('cors');
const path = require('path');

// Import routes
const authRoutes = require('./routes/authRoutes');
const lahanRoutes = require('./routes/lahanRoutes');
const siklusRoutes = require('./routes/siklusRoutes');
const laporanRoutes = require('./routes/laporanRoutes');
const perawatanRoutes = require('./routes/perawatanRoutes');
const panenRoutes = require('./routes/panenRoutes');

const app = express();

// Middlewares
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve static uploads
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// Root & Health Check Endpoint
app.get('/', (req, res) => {
  res.json({
    name: 'AgroPlan REST API Server',
    status: 'Running',
    version: '1.0.0',
    documentation: {
      auth: '/api/auth',
      lahan: '/api/lahan',
      siklus: '/api/siklus',
      laporan: '/api/laporan',
      jadwal: '/api/jadwal',
      panen: '/api/panen',
    },
  });
});

app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date() });
});

// Mount modular API routes
app.use('/api/auth', authRoutes);
app.use('/api/lahan', lahanRoutes);
app.use('/api/siklus', siklusRoutes);
app.use('/api/laporan', laporanRoutes);
app.use('/api/jadwal', perawatanRoutes);
app.use('/api/panen', panenRoutes);

// Global Error Handler
app.use((err, req, res, next) => {
  console.error('Unhandled Error:', err.stack);
  res.status(500).json({
    success: false,
    message: err.message || 'Terjadi kesalahan internal server.',
  });
});

module.exports = app;
