const app = require('./app');
require('dotenv').config();

const PORT = process.env.PORT || 3000;

app.listen(PORT, '0.0.0.0', () => {
  console.log('═══════════════════════════════════════════════');
  console.log(`🌾 AgroPlan REST API Server Aktif!`);
  console.log(`📡 URL Lokal    : http://localhost:${PORT}`);
  console.log(`📱 URL Jaringan  : http://0.0.0.0:${PORT} (dapat diakses dari HP)`);
  console.log(`🏥 Health Check : http://localhost:${PORT}/api/health`);
  console.log('═══════════════════════════════════════════════');
});
