const express = require('express');
const router = express.Router();
const Appointment = require('../models/Appointment');
const { authenticate, authorize } = require('../middleware/auth');

router.get('/', authenticate, async (req, res) => {
  try {
    const query = {};

    if (req.user.role === 'patient') {
      query.patientId = req.user._id;
    } else if (req.user.role === 'doctor') {
      const DoctorProfile = require('../models/DoctorProfile');
      const doctorProfile = await DoctorProfile.findOne({ userId: req.user._id });
      if (!doctorProfile) {
        return res.status(404).json({
          success: false,
          message: 'Doctor profile not found'
        });
      }
      query.doctorId = doctorProfile._id;
    }

    const appointments = await Appointment.find(query)
      .populate('patientId', 'fullName email phone')
      .populate({
        path: 'doctorId',
        populate: { path: 'userId', select: 'fullName email' }
      })
      .sort({ appointmentDate: 1, appointmentTime: 1 });

    res.json({
      success: true,
      count: appointments.length,
      appointments
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

router.post('/', authenticate, authorize('patient'), async (req, res) => {
  try {
    const { doctorId, appointmentDate, appointmentTime, reason } = req.body;

    const appointment = await Appointment.create({
      patientId: req.user._id,
      doctorId,
      appointmentDate,
      appointmentTime,
      reason,
      status: 'pending'
    });

    const Notification = require('../models/Notification');
    const DoctorProfile = require('../models/DoctorProfile');
    const doctor = await DoctorProfile.findById(doctorId).populate('userId');

    if (doctor) {
      await Notification.create({
        userId: doctor.userId._id,
        title: 'New Appointment Request',
        message: `${req.user.fullName} has requested an appointment`,
        type: 'appointment',
        relatedId: appointment._id
      });
    }

    res.status(201).json({
      success: true,
      appointment
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

router.patch('/:id/status', authenticate, async (req, res) => {
  try {
    const { status } = req.body;

    if (!['confirmed', 'cancelled', 'completed', 'rescheduled'].includes(status)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid status'
      });
    }

    const appointment = await Appointment.findById(req.params.id);

    if (!appointment) {
      return res.status(404).json({
        success: false,
        message: 'Appointment not found'
      });
    }

    if (req.user.role === 'doctor') {
      const DoctorProfile = require('../models/DoctorProfile');
      const doctorProfile = await DoctorProfile.findOne({ userId: req.user._id });
      if (!doctorProfile || !appointment.doctorId.equals(doctorProfile._id)) {
        return res.status(403).json({
          success: false,
          message: 'Not authorized'
        });
      }
    }

    appointment.status = status;
    await appointment.save();

    const Notification = require('../models/Notification');
    await Notification.create({
      userId: appointment.patientId,
      title: 'Appointment Status Updated',
      message: `Your appointment status is now: ${status}`,
      type: 'appointment',
      relatedId: appointment._id
    });

    res.json({
      success: true,
      appointment
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

module.exports = router;
