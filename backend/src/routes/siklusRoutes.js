const express = require('express');
const router = express.Router();
const siklusController = require('../controllers/siklusController');

router.get('/', siklusController.getAllSiklus);
router.post('/', siklusController.createSiklus);
router.put('/:id/selesai', siklusController.finishSiklus);
router.put('/:id/tanggal-tanam', siklusController.updateTanggalTanam);

module.exports = router;
