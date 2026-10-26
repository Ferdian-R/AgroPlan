const express = require('express');
const router = express.Router();
const laporanController = require('../controllers/laporanController');
const upload = require('../middleware/upload');

router.get('/', laporanController.getAllLaporan);
router.post('/', upload.single('foto'), laporanController.createLaporan);
router.put('/:id', upload.single('foto'), laporanController.updateLaporan);
router.delete('/:id', laporanController.deleteLaporan);

module.exports = router;
