const mongoose = require('mongoose');

const appointmentSchema = new mongoose.Schema({
  patientId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'Patient ID is required']
  },
  doctorId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'DoctorProfile',
    required: [true, 'Doctor ID is required']
  },
  appointmentDate: {
    type: Date,
    required: [true, 'Appointment date is required']
  },
  appointmentTime: {
    type: String,
    required: [true, 'Appointment time is required'],
    match: [/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/, 'Please provide time in HH:mm format']
  },
  status: {
    type: String,
    enum: ['pending', 'confirmed', 'completed', 'cancelled', 'rescheduled'],
    default: 'pending'
  },
  reason: {
    type: String,
    required: [true, 'Reason for appointment is required'],
    trim: true
  },
  notes: {
    type: String,
    trim: true
  },
  videoRoomId: {
    type: String,
    trim: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  },
  updatedAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

appointmentSchema.index({ patientId: 1, appointmentDate: 1 });
appointmentSchema.index({ doctorId: 1, appointmentDate: 1 });
appointmentSchema.index({ status: 1, appointmentDate: 1 });

appointmentSchema.virtual('patient', {
  ref: 'User',
  localField: 'patientId',
  foreignField: '_id',
  justOne: true
});

appointmentSchema.virtual('doctor', {
  ref: 'DoctorProfile',
  localField: 'doctorId',
  foreignField: '_id',
  justOne: true
});

appointmentSchema.methods.canBeModified = function() {
  return ['pending', 'confirmed'].includes(this.status);
};

appointmentSchema.methods.complete = async function() {
  if (this.status !== 'confirmed') {
    throw new Error('Only confirmed appointments can be completed');
  }

  this.status = 'completed';
  await this.save();

  const DoctorProfile = mongoose.model('DoctorProfile');
  await DoctorProfile.findByIdAndUpdate(
    this.doctorId,
    { $inc: { totalConsultations: 1 } }
  );
};

const Appointment = mongoose.model('Appointment', appointmentSchema);

module.exports = Appointment;
