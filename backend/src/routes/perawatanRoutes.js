const express = require('express');
const router = express.Router();
const perawatanController = require('../controllers/perawatanController');

router.get('/', perawatanController.getAllJadwal);
router.get('/estimasi', perawatanController.getEstimasiPanen);
router.post('/', perawatanController.createJadwal);
router.put('/:id/status', perawatanController.updateStatus);
router.delete('/:id', perawatanController.deleteJadwal);

module.exports = router;
