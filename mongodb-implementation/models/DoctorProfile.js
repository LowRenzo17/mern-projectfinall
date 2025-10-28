const mongoose = require('mongoose');

const doctorProfileSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'User ID is required'],
    unique: true
  },
  specialization: {
    type: String,
    required: [true, 'Specialization is required'],
    trim: true
  },
  licenseNumber: {
    type: String,
    required: [true, 'License number is required'],
    unique: true,
    trim: true
  },
  qualification: {
    type: String,
    required: [true, 'Qualification is required'],
    trim: true
  },
  experienceYears: {
    type: Number,
    default: 0,
    min: [0, 'Experience years cannot be negative']
  },
  consultationFee: {
    type: Number,
    default: 0,
    min: [0, 'Consultation fee cannot be negative']
  },
  bio: {
    type: String,
    trim: true,
    maxlength: [1000, 'Bio cannot exceed 1000 characters']
  },
  isVerified: {
    type: Boolean,
    default: false
  },
  isAvailable: {
    type: Boolean,
    default: true
  },
  rating: {
    type: Number,
    default: 0,
    min: [0, 'Rating cannot be less than 0'],
    max: [5, 'Rating cannot exceed 5']
  },
  totalConsultations: {
    type: Number,
    default: 0,
    min: [0, 'Total consultations cannot be negative']
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

doctorProfileSchema.index({ userId: 1 });
doctorProfileSchema.index({ licenseNumber: 1 });
doctorProfileSchema.index({ isVerified: 1, isAvailable: 1 });
doctorProfileSchema.index({ specialization: 1 });

doctorProfileSchema.virtual('user', {
  ref: 'User',
  localField: 'userId',
  foreignField: '_id',
  justOne: true
});

doctorProfileSchema.methods.updateRating = async function(newRating) {
  const Review = mongoose.model('Review');
  const reviews = await Review.find({ doctorId: this._id });

  if (reviews.length === 0) {
    this.rating = newRating;
  } else {
    const totalRating = reviews.reduce((sum, review) => sum + review.rating, 0);
    this.rating = totalRating / reviews.length;
  }

  await this.save();
};

const DoctorProfile = mongoose.model('DoctorProfile', doctorProfileSchema);

module.exports = DoctorProfile;
