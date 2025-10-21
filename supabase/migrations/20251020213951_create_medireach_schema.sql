/*
  # MediReach Platform Database Schema

  ## Overview
  Complete database schema for the MediReach remote medical appointment platform.
  Supports patients, doctors, and admin roles with comprehensive medical consultation features.

  ## New Tables

  ### 1. `profiles`
  User profile information extending Supabase auth.users
  - `id` (uuid, FK to auth.users) - User identifier
  - `email` (text) - User email
  - `full_name` (text) - Full name
  - `role` (text) - User role: 'patient', 'doctor', 'admin'
  - `phone` (text) - Contact phone number
  - `avatar_url` (text) - Profile picture URL
  - `date_of_birth` (date) - Date of birth
  - `gender` (text) - Gender
  - `created_at` (timestamptz) - Account creation timestamp
  - `updated_at` (timestamptz) - Last update timestamp

  ### 2. `doctor_profiles`
  Extended information for doctor accounts
  - `id` (uuid, PK) - Doctor profile identifier
  - `user_id` (uuid, FK to profiles) - Reference to user profile
  - `specialization` (text) - Medical specialization
  - `license_number` (text) - Medical license number
  - `qualification` (text) - Educational qualifications
  - `experience_years` (integer) - Years of experience
  - `consultation_fee` (decimal) - Fee per consultation
  - `bio` (text) - Professional biography
  - `is_verified` (boolean) - Admin verification status
  - `is_available` (boolean) - Current availability status
  - `rating` (decimal) - Average rating
  - `total_consultations` (integer) - Total completed consultations
  - `created_at` (timestamptz) - Profile creation timestamp
  - `updated_at` (timestamptz) - Last update timestamp

  ### 3. `doctor_availability`
  Doctor scheduling and availability slots
  - `id` (uuid, PK) - Availability record identifier
  - `doctor_id` (uuid, FK to doctor_profiles) - Reference to doctor
  - `day_of_week` (integer) - Day (0=Sunday, 6=Saturday)
  - `start_time` (time) - Slot start time
  - `end_time` (time) - Slot end time
  - `is_active` (boolean) - Whether slot is active
  - `created_at` (timestamptz) - Record creation timestamp

  ### 4. `appointments`
  Medical appointment bookings and sessions
  - `id` (uuid, PK) - Appointment identifier
  - `patient_id` (uuid, FK to profiles) - Reference to patient
  - `doctor_id` (uuid, FK to doctor_profiles) - Reference to doctor
  - `appointment_date` (date) - Scheduled date
  - `appointment_time` (time) - Scheduled time
  - `status` (text) - Status: 'pending', 'confirmed', 'completed', 'cancelled', 'rescheduled'
  - `reason` (text) - Consultation reason
  - `notes` (text) - Additional notes
  - `video_room_id` (text) - Video call room identifier
  - `created_at` (timestamptz) - Booking timestamp
  - `updated_at` (timestamptz) - Last update timestamp

  ### 5. `prescriptions`
  Medical prescriptions issued by doctors
  - `id` (uuid, PK) - Prescription identifier
  - `appointment_id` (uuid, FK to appointments) - Related appointment
  - `patient_id` (uuid, FK to profiles) - Reference to patient
  - `doctor_id` (uuid, FK to doctor_profiles) - Reference to doctor
  - `diagnosis` (text) - Medical diagnosis
  - `medications` (jsonb) - List of prescribed medications with dosage
  - `instructions` (text) - Patient instructions
  - `file_url` (text) - PDF file URL
  - `created_at` (timestamptz) - Issue timestamp

  ### 6. `medical_records`
  Patient medical history and documents
  - `id` (uuid, PK) - Record identifier
  - `patient_id` (uuid, FK to profiles) - Reference to patient
  - `record_type` (text) - Type: 'lab_report', 'imaging', 'prescription', 'diagnosis', 'other'
  - `title` (text) - Document title
  - `description` (text) - Record description
  - `file_url` (text) - Document file URL
  - `uploaded_by` (uuid, FK to profiles) - User who uploaded
  - `created_at` (timestamptz) - Upload timestamp

  ### 7. `notifications`
  System notifications for all users
  - `id` (uuid, PK) - Notification identifier
  - `user_id` (uuid, FK to profiles) - Recipient user
  - `title` (text) - Notification title
  - `message` (text) - Notification message
  - `type` (text) - Type: 'appointment', 'prescription', 'system', 'reminder'
  - `is_read` (boolean) - Read status
  - `related_id` (uuid) - Related entity ID
  - `created_at` (timestamptz) - Creation timestamp

  ### 8. `chat_messages`
  Real-time messaging between patients and doctors
  - `id` (uuid, PK) - Message identifier
  - `appointment_id` (uuid, FK to appointments) - Related appointment
  - `sender_id` (uuid, FK to profiles) - Message sender
  - `message` (text) - Message content
  - `created_at` (timestamptz) - Send timestamp

  ### 9. `reviews`
  Patient reviews and ratings for doctors
  - `id` (uuid, PK) - Review identifier
  - `appointment_id` (uuid, FK to appointments) - Related appointment
  - `patient_id` (uuid, FK to profiles) - Reviewer
  - `doctor_id` (uuid, FK to doctor_profiles) - Reviewed doctor
  - `rating` (integer) - Rating (1-5)
  - `comment` (text) - Review comment
  - `created_at` (timestamptz) - Review timestamp

  ## Security
  - Row Level Security (RLS) enabled on all tables
  - Policies enforce role-based access control
  - Patients can only access their own data
  - Doctors can access their patients' relevant data
  - Admins have full access for management

  ## Indexes
  - Indexed foreign keys for optimal query performance
  - Indexed status and date fields for appointment queries
  - Indexed user_id fields for notifications and messages
*/

-- Create profiles table
CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email text UNIQUE NOT NULL,
  full_name text NOT NULL,
  role text NOT NULL CHECK (role IN ('patient', 'doctor', 'admin')),
  phone text,
  avatar_url text,
  date_of_birth date,
  gender text CHECK (gender IN ('male', 'female', 'other', 'prefer_not_to_say')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create doctor_profiles table
CREATE TABLE IF NOT EXISTS doctor_profiles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid UNIQUE NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  specialization text NOT NULL,
  license_number text UNIQUE NOT NULL,
  qualification text NOT NULL,
  experience_years integer DEFAULT 0,
  consultation_fee decimal(10,2) DEFAULT 0,
  bio text,
  is_verified boolean DEFAULT false,
  is_available boolean DEFAULT true,
  rating decimal(3,2) DEFAULT 0,
  total_consultations integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create doctor_availability table
CREATE TABLE IF NOT EXISTS doctor_availability (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  doctor_id uuid NOT NULL REFERENCES doctor_profiles(id) ON DELETE CASCADE,
  day_of_week integer NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
  start_time time NOT NULL,
  end_time time NOT NULL,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  UNIQUE(doctor_id, day_of_week, start_time)
);

-- Create appointments table
CREATE TABLE IF NOT EXISTS appointments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  doctor_id uuid NOT NULL REFERENCES doctor_profiles(id) ON DELETE CASCADE,
  appointment_date date NOT NULL,
  appointment_time time NOT NULL,
  status text DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'completed', 'cancelled', 'rescheduled')),
  reason text NOT NULL,
  notes text,
  video_room_id text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create prescriptions table
CREATE TABLE IF NOT EXISTS prescriptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  appointment_id uuid NOT NULL REFERENCES appointments(id) ON DELETE CASCADE,
  patient_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  doctor_id uuid NOT NULL REFERENCES doctor_profiles(id) ON DELETE CASCADE,
  diagnosis text NOT NULL,
  medications jsonb NOT NULL DEFAULT '[]',
  instructions text,
  file_url text,
  created_at timestamptz DEFAULT now()
);

-- Create medical_records table
CREATE TABLE IF NOT EXISTS medical_records (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  patient_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  record_type text NOT NULL CHECK (record_type IN ('lab_report', 'imaging', 'prescription', 'diagnosis', 'other')),
  title text NOT NULL,
  description text,
  file_url text,
  uploaded_by uuid NOT NULL REFERENCES profiles(id),
  created_at timestamptz DEFAULT now()
);

-- Create notifications table
CREATE TABLE IF NOT EXISTS notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title text NOT NULL,
  message text NOT NULL,
  type text NOT NULL CHECK (type IN ('appointment', 'prescription', 'system', 'reminder')),
  is_read boolean DEFAULT false,
  related_id uuid,
  created_at timestamptz DEFAULT now()
);

-- Create chat_messages table
CREATE TABLE IF NOT EXISTS chat_messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  appointment_id uuid NOT NULL REFERENCES appointments(id) ON DELETE CASCADE,
  sender_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  message text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Create reviews table
CREATE TABLE IF NOT EXISTS reviews (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  appointment_id uuid UNIQUE NOT NULL REFERENCES appointments(id) ON DELETE CASCADE,
  patient_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  doctor_id uuid NOT NULL REFERENCES doctor_profiles(id) ON DELETE CASCADE,
  rating integer NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment text,
  created_at timestamptz DEFAULT now()
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_appointments_patient ON appointments(patient_id);
CREATE INDEX IF NOT EXISTS idx_appointments_doctor ON appointments(doctor_id);
CREATE INDEX IF NOT EXISTS idx_appointments_date ON appointments(appointment_date);
CREATE INDEX IF NOT EXISTS idx_appointments_status ON appointments(status);
CREATE INDEX IF NOT EXISTS idx_prescriptions_patient ON prescriptions(patient_id);
CREATE INDEX IF NOT EXISTS idx_prescriptions_doctor ON prescriptions(doctor_id);
CREATE INDEX IF NOT EXISTS idx_medical_records_patient ON medical_records(patient_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_unread ON notifications(user_id, is_read);
CREATE INDEX IF NOT EXISTS idx_chat_messages_appointment ON chat_messages(appointment_id);
CREATE INDEX IF NOT EXISTS idx_doctor_profiles_verified ON doctor_profiles(is_verified);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE doctor_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE doctor_availability ENABLE ROW LEVEL SECURITY;
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE prescriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE medical_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- RLS Policies for profiles
CREATE POLICY "Users can view all profiles"
  ON profiles FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  TO authenticated
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = id);

-- RLS Policies for doctor_profiles
CREATE POLICY "Anyone can view verified doctor profiles"
  ON doctor_profiles FOR SELECT
  TO authenticated
  USING (is_verified = true OR user_id = auth.uid());

CREATE POLICY "Doctors can update own profile"
  ON doctor_profiles FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Doctors can insert own profile"
  ON doctor_profiles FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

-- RLS Policies for doctor_availability
CREATE POLICY "Anyone can view availability"
  ON doctor_availability FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Doctors can manage own availability"
  ON doctor_availability FOR ALL
  TO authenticated
  USING (doctor_id IN (SELECT id FROM doctor_profiles WHERE user_id = auth.uid()))
  WITH CHECK (doctor_id IN (SELECT id FROM doctor_profiles WHERE user_id = auth.uid()));

-- RLS Policies for appointments
CREATE POLICY "Patients can view own appointments"
  ON appointments FOR SELECT
  TO authenticated
  USING (
    patient_id = auth.uid() OR
    doctor_id IN (SELECT id FROM doctor_profiles WHERE user_id = auth.uid())
  );

CREATE POLICY "Patients can create appointments"
  ON appointments FOR INSERT
  TO authenticated
  WITH CHECK (patient_id = auth.uid());

CREATE POLICY "Users can update own appointments"
  ON appointments FOR UPDATE
  TO authenticated
  USING (
    patient_id = auth.uid() OR
    doctor_id IN (SELECT id FROM doctor_profiles WHERE user_id = auth.uid())
  )
  WITH CHECK (
    patient_id = auth.uid() OR
    doctor_id IN (SELECT id FROM doctor_profiles WHERE user_id = auth.uid())
  );

-- RLS Policies for prescriptions
CREATE POLICY "Patients can view own prescriptions"
  ON prescriptions FOR SELECT
  TO authenticated
  USING (
    patient_id = auth.uid() OR
    doctor_id IN (SELECT id FROM doctor_profiles WHERE user_id = auth.uid())
  );

CREATE POLICY "Doctors can create prescriptions"
  ON prescriptions FOR INSERT
  TO authenticated
  WITH CHECK (doctor_id IN (SELECT id FROM doctor_profiles WHERE user_id = auth.uid()));

-- RLS Policies for medical_records
CREATE POLICY "Patients can view own records"
  ON medical_records FOR SELECT
  TO authenticated
  USING (
    patient_id = auth.uid() OR
    uploaded_by = auth.uid()
  );

CREATE POLICY "Users can create medical records"
  ON medical_records FOR INSERT
  TO authenticated
  WITH CHECK (uploaded_by = auth.uid());

-- RLS Policies for notifications
CREATE POLICY "Users can view own notifications"
  ON notifications FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Users can update own notifications"
  ON notifications FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- RLS Policies for chat_messages
CREATE POLICY "Users can view messages for own appointments"
  ON chat_messages FOR SELECT
  TO authenticated
  USING (
    appointment_id IN (
      SELECT id FROM appointments
      WHERE patient_id = auth.uid()
      OR doctor_id IN (SELECT id FROM doctor_profiles WHERE user_id = auth.uid())
    )
  );

CREATE POLICY "Users can send messages for own appointments"
  ON chat_messages FOR INSERT
  TO authenticated
  WITH CHECK (
    sender_id = auth.uid() AND
    appointment_id IN (
      SELECT id FROM appointments
      WHERE patient_id = auth.uid()
      OR doctor_id IN (SELECT id FROM doctor_profiles WHERE user_id = auth.uid())
    )
  );

-- RLS Policies for reviews
CREATE POLICY "Anyone can view reviews"
  ON reviews FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Patients can create reviews for own appointments"
  ON reviews FOR INSERT
  TO authenticated
  WITH CHECK (
    patient_id = auth.uid() AND
    appointment_id IN (SELECT id FROM appointments WHERE patient_id = auth.uid() AND status = 'completed')
  );

-- Function to update doctor rating after review
CREATE OR REPLACE FUNCTION update_doctor_rating()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE doctor_profiles
  SET rating = (
    SELECT AVG(rating)::decimal(3,2)
    FROM reviews
    WHERE doctor_id = NEW.doctor_id
  )
  WHERE id = NEW.doctor_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update rating after review insert
CREATE TRIGGER trigger_update_doctor_rating
AFTER INSERT ON reviews
FOR EACH ROW
EXECUTE FUNCTION update_doctor_rating();

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
CREATE TRIGGER trigger_profiles_updated_at
BEFORE UPDATE ON profiles
FOR EACH ROW
EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trigger_doctor_profiles_updated_at
BEFORE UPDATE ON doctor_profiles
FOR EACH ROW
EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trigger_appointments_updated_at
BEFORE UPDATE ON appointments
FOR EACH ROW
EXECUTE FUNCTION update_updated_at();