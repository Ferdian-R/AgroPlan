const express = require('express');
const router = express.Router();
const panenController = require('../controllers/panenController');

router.get('/', panenController.getRiwayatPanen);
router.post('/', panenController.createPanen);

module.exports = router;
