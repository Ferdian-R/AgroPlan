const express = require('express');
const router = express.Router();
const lahanController = require('../controllers/lahanController');

router.get('/', lahanController.getAllLahan);
router.get('/:id', lahanController.getLahanById);
router.post('/', lahanController.createLahan);
router.put('/:id', lahanController.updateLahan);
router.delete('/:id', lahanController.deleteLahan);

module.exports = router;
