# MongoDB Migration Guide for MediReach

## Option 2: Architectural Guidance

This document provides complete MongoDB schema designs, implementation patterns, and migration strategies for converting MediReach from Supabase (PostgreSQL) to MongoDB.

---

## MongoDB Schema Design

### Collection Structure

MongoDB uses a document-based approach. Here's how the PostgreSQL tables translate to MongoDB collections:

#### 1. Users Collection
```javascript
{
  _id: ObjectId,
  email: String (unique, required),
  passwordHash: String (required),
  fullName: String (required),
  role: String (enum: ['patient', 'doctor', 'admin'], required),
  phone: String,
  avatarUrl: String,
  dateOfBirth: Date,
  gender: String (enum: ['male', 'female', 'other', 'prefer_not_to_say']),
  createdAt: Date (default: now),
  updatedAt: Date (default: now)
}
```

**Indexes:**
- `{ email: 1 }` - unique
- `{ role: 1 }`

---

#### 2. DoctorProfiles Collection
```javascript
{
  _id: ObjectId,
  userId: ObjectId (ref: 'User', required),
  specialization: String (required),
  licenseNumber: String (unique, required),
  qualification: String (required),
  experienceYears: Number (default: 0),
  consultationFee: Number (default: 0),
  bio: String,
  isVerified: Boolean (default: false),
  isAvailable: Boolean (default: true),
  rating: Number (default: 0, min: 0, max: 5),
  totalConsultations: Number (default: 0),
  createdAt: Date (default: now),
  updatedAt: Date (default: now)
}
```

**Indexes:**
- `{ userId: 1 }` - unique
- `{ licenseNumber: 1 }` - unique
- `{ isVerified: 1, isAvailable: 1 }`
- `{ specialization: 1 }`

---

#### 3. DoctorAvailability Collection
```javascript
{
  _id: ObjectId,
  doctorId: ObjectId (ref: 'DoctorProfile', required),
  dayOfWeek: Number (0-6, required),
  startTime: String (HH:mm format, required),
  endTime: String (HH:mm format, required),
  isActive: Boolean (default: true),
  createdAt: Date (default: now)
}
```

**Indexes:**
- `{ doctorId: 1, dayOfWeek: 1, startTime: 1 }` - unique compound
- `{ doctorId: 1, isActive: 1 }`

---

#### 4. Appointments Collection
```javascript
{
  _id: ObjectId,
  patientId: ObjectId (ref: 'User', required),
  doctorId: ObjectId (ref: 'DoctorProfile', required),
  appointmentDate: Date (required),
  appointmentTime: String (HH:mm format, required),
  status: String (enum: ['pending', 'confirmed', 'completed', 'cancelled', 'rescheduled'], default: 'pending'),
  reason: String (required),
  notes: String,
  videoRoomId: String,
  createdAt: Date (default: now),
  updatedAt: Date (default: now)
}
```

**Indexes:**
- `{ patientId: 1, appointmentDate: 1 }`
- `{ doctorId: 1, appointmentDate: 1 }`
- `{ status: 1, appointmentDate: 1 }`

---

#### 5. Prescriptions Collection
```javascript
{
  _id: ObjectId,
  appointmentId: ObjectId (ref: 'Appointment', required),
  patientId: ObjectId (ref: 'User', required),
  doctorId: ObjectId (ref: 'DoctorProfile', required),
  diagnosis: String (required),
  medications: [{
    name: String (required),
    dosage: String (required),
    frequency: String (required),
    duration: String (required)
  }],
  instructions: String,
  fileUrl: String,
  createdAt: Date (default: now)
}
```

**Indexes:**
- `{ patientId: 1, createdAt: -1 }`
- `{ doctorId: 1, createdAt: -1 }`
- `{ appointmentId: 1 }`

---

#### 6. MedicalRecords Collection
```javascript
{
  _id: ObjectId,
  patientId: ObjectId (ref: 'User', required),
  recordType: String (enum: ['lab_report', 'imaging', 'prescription', 'diagnosis', 'other'], required),
  title: String (required),
  description: String,
  fileUrl: String,
  uploadedBy: ObjectId (ref: 'User', required),
  createdAt: Date (default: now)
}
```

**Indexes:**
- `{ patientId: 1, createdAt: -1 }`
- `{ patientId: 1, recordType: 1 }`

---

#### 7. Notifications Collection
```javascript
{
  _id: ObjectId,
  userId: ObjectId (ref: 'User', required),
  title: String (required),
  message: String (required),
  type: String (enum: ['appointment', 'prescription', 'system', 'reminder'], required),
  isRead: Boolean (default: false),
  relatedId: ObjectId,
  createdAt: Date (default: now)
}
```

**Indexes:**
- `{ userId: 1, isRead: 1, createdAt: -1 }`
- `{ userId: 1, createdAt: -1 }`

---

#### 8. ChatMessages Collection
```javascript
{
  _id: ObjectId,
  appointmentId: ObjectId (ref: 'Appointment', required),
  senderId: ObjectId (ref: 'User', required),
  message: String (required),
  createdAt: Date (default: now)
}
```

**Indexes:**
- `{ appointmentId: 1, createdAt: 1 }`

---

#### 9. Reviews Collection
```javascript
{
  _id: ObjectId,
  appointmentId: ObjectId (ref: 'Appointment', required, unique),
  patientId: ObjectId (ref: 'User', required),
  doctorId: ObjectId (ref: 'DoctorProfile', required),
  rating: Number (min: 1, max: 5, required),
  comment: String,
  createdAt: Date (default: now)
}
```

**Indexes:**
- `{ appointmentId: 1 }` - unique
- `{ doctorId: 1, createdAt: -1 }`
- `{ patientId: 1, createdAt: -1 }`

---

## Key Differences from PostgreSQL

### 1. Authentication
- **PostgreSQL/Supabase**: Built-in auth.users table
- **MongoDB**: You'll need to implement your own authentication using:
  - **Passport.js** with local strategy
  - **bcrypt** for password hashing
  - **JWT** for session management

### 2. Relationships
- **PostgreSQL**: Foreign keys with referential integrity
- **MongoDB**: Manual ObjectId references (no automatic cascade)
- You must manually handle cascade deletes/updates

### 3. Transactions
- **PostgreSQL**: ACID transactions by default
- **MongoDB**: Multi-document transactions available in replica sets
- Use sessions for atomic operations across collections

### 4. Real-time Updates
- **PostgreSQL/Supabase**: Built-in real-time subscriptions
- **MongoDB**: Use Change Streams or Socket.io for real-time features

### 5. Security
- **PostgreSQL/Supabase**: Row Level Security (RLS)
- **MongoDB**: Application-level security in your API layer
- Implement authorization middleware for all routes

---

## Migration Strategy

### Phase 1: Preparation (Week 1)
1. **Export existing data** from Supabase
2. **Set up MongoDB Atlas** or local MongoDB instance
3. **Install dependencies**: mongoose, bcrypt, jsonwebtoken, express
4. **Design API architecture** (REST or GraphQL)

### Phase 2: Backend Setup (Week 2)
1. Create MongoDB connection
2. Define Mongoose models
3. Implement authentication system
4. Build API endpoints
5. Add authorization middleware

### Phase 3: Data Migration (Week 3)
1. Write migration scripts
2. Transform data to match MongoDB schema
3. Import data to MongoDB
4. Verify data integrity
5. Test relationships and queries

### Phase 4: Frontend Integration (Week 4)
1. Replace Supabase client with API calls
2. Update authentication flow
3. Implement real-time features with Socket.io
4. Update state management
5. Test all user flows

### Phase 5: Testing & Deployment (Week 5)
1. End-to-end testing
2. Performance testing
3. Security audit
4. Deploy to production
5. Monitor and fix issues

---

## Data Transformation Example

### PostgreSQL to MongoDB User Data

**PostgreSQL Row:**
```sql
SELECT * FROM profiles WHERE id = 'uuid-123';
-- Result:
-- id: uuid-123
-- email: john@example.com
-- full_name: John Doe
-- role: patient
-- created_at: 2024-01-01T00:00:00Z
```

**MongoDB Document:**
```javascript
{
  _id: ObjectId("507f1f77bcf86cd799439011"),
  email: "john@example.com",
  fullName: "John Doe",
  role: "patient",
  createdAt: ISODate("2024-01-01T00:00:00Z")
}
```

### Migration Script Pseudocode

```javascript
// 1. Connect to both databases
const supabase = createSupabaseClient();
const mongoose = await connectToMongoDB();

// 2. Fetch all users from Supabase
const { data: profiles } = await supabase.from('profiles').select('*');

// 3. Transform and insert to MongoDB
for (const profile of profiles) {
  await User.create({
    email: profile.email,
    fullName: profile.full_name,
    role: profile.role,
    phone: profile.phone,
    avatarUrl: profile.avatar_url,
    dateOfBirth: profile.date_of_birth,
    gender: profile.gender,
    createdAt: profile.created_at,
    updatedAt: profile.updated_at
  });
}
```

---

## Estimated Costs

### MongoDB Atlas Pricing (M10 Cluster)
- **Shared Tier (Free)**: 512 MB storage, good for testing
- **M10 (Recommended)**: ~$57/month, 10GB storage, 2GB RAM
- **M30 (Production)**: ~$240/month, 40GB storage, 8GB RAM

### Supabase Pricing (Current)
- **Free Tier**: 500MB database, 2GB bandwidth
- **Pro**: $25/month, 8GB database, 50GB bandwidth

**Note:** MongoDB may cost more but provides more flexibility for complex queries and data structures.

---

## Next Steps

1. Review this architecture
2. Decide if MongoDB is worth the migration effort
3. If yes, proceed to Option 3 for implementation code
4. If no, continue with Supabase (recommended for most use cases)
