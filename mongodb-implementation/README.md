# MediReach MongoDB Backend

## Option 3: Hybrid Approach - Complete Implementation

This directory contains a complete MongoDB backend implementation for MediReach that you can deploy alongside or replace the Supabase backend.

---

## Installation

### Prerequisites
- Node.js (v16 or higher)
- MongoDB (local or Atlas account)
- npm or yarn

### Step 1: Install Dependencies
```bash
cd mongodb-implementation
npm install
```

### Step 2: Environment Setup
```bash
cp .env.example .env
# Edit .env with your MongoDB connection string
```

### Step 3: Start MongoDB
**Local MongoDB:**
```bash
mongod --dbpath=/path/to/data
```

**Or use MongoDB Atlas:**
- Sign up at https://www.mongodb.com/cloud/atlas
- Create a free cluster
- Get connection string
- Add to `.env` file

### Step 4: Run the Server
```bash
npm run dev
```

Server will start on http://localhost:5000

---

## Project Structure

```
mongodb-implementation/
├── config/
│   └── database.js          # MongoDB connection
├── models/
│   ├── User.js              # User model with auth
│   ├── DoctorProfile.js     # Doctor profiles
│   ├── Appointment.js       # Appointments
│   ├── Prescription.js      # Prescriptions (create this)
│   ├── Notification.js      # Notifications (create this)
│   └── Review.js            # Reviews (create this)
├── routes/
│   ├── auth.js              # Authentication routes
│   ├── appointments.js      # Appointment routes
│   ├── doctors.js           # Doctor routes (create this)
│   └── patients.js          # Patient routes (create this)
├── middleware/
│   ├── auth.js              # JWT authentication
│   └── errorHandler.js      # Error handling (create this)
├── server.js                # Express server
├── package.json             # Dependencies
└── .env.example             # Environment template
```

---

## API Endpoints

### Authentication
```
POST   /api/auth/register      # Register new user
POST   /api/auth/login         # Login user
GET    /api/auth/me            # Get current user
```

### Appointments
```
GET    /api/appointments       # Get user appointments
POST   /api/appointments       # Create appointment (patient)
PATCH  /api/appointments/:id/status  # Update status (doctor)
```

### Doctors (To implement)
```
GET    /api/doctors            # Get all verified doctors
GET    /api/doctors/:id        # Get doctor details
POST   /api/doctors/profile    # Create doctor profile
PATCH  /api/doctors/profile    # Update doctor profile
```

### Admin (To implement)
```
GET    /api/admin/doctors/pending    # Get pending verifications
PATCH  /api/admin/doctors/:id/verify # Verify doctor
GET    /api/admin/stats              # Get platform statistics
```

---

## Frontend Integration

### Replace Supabase Client

**Old (Supabase):**
```javascript
import { supabase } from './lib/supabase';

const { data, error } = await supabase
  .from('appointments')
  .select('*');
```

**New (MongoDB API):**
```javascript
import axios from 'axios';

const api = axios.create({
  baseURL: 'http://localhost:5000/api',
  headers: {
    'Authorization': `Bearer ${localStorage.getItem('token')}`
  }
});

const { data } = await api.get('/appointments');
```

### Update Auth Context

Create a new `src/lib/api.js`:
```javascript
import axios from 'axios';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000/api';

export const api = axios.create({
  baseURL: API_URL,
});

api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export const authAPI = {
  register: (data) => api.post('/auth/register', data),
  login: (data) => api.post('/auth/login', data),
  getMe: () => api.get('/auth/me'),
};

export const appointmentsAPI = {
  getAll: () => api.get('/appointments'),
  create: (data) => api.post('/appointments', data),
  updateStatus: (id, status) => api.patch(`/appointments/${id}/status`, { status }),
};
```

---

## Real-time Features with Socket.io

### Server Setup
```javascript
// In server.js
const http = require('http');
const socketIO = require('socket.io');

const server = http.createServer(app);
const io = socketIO(server, {
  cors: { origin: process.env.FRONTEND_URL }
});

io.use((socket, next) => {
  const token = socket.handshake.auth.token;
  // Verify JWT token
  next();
});

io.on('connection', (socket) => {
  socket.on('join-room', (appointmentId) => {
    socket.join(`appointment-${appointmentId}`);
  });

  socket.on('send-message', (data) => {
    io.to(`appointment-${data.appointmentId}`).emit('new-message', data);
  });
});
```

### Frontend Setup
```javascript
import { io } from 'socket.io-client';

const socket = io('http://localhost:5000', {
  auth: { token: localStorage.getItem('token') }
});

socket.on('new-message', (message) => {
  console.log('New message:', message);
});
```

---

## Deployment

### Deploy to Railway, Render, or Heroku

**Railway:**
```bash
# Install Railway CLI
npm i -g @railway/cli

# Login
railway login

# Deploy
railway up
```

**Environment Variables:**
- `MONGODB_URI`
- `JWT_SECRET`
- `NODE_ENV=production`
- `FRONTEND_URL`

### MongoDB Atlas Setup
1. Create cluster at mongodb.com/cloud/atlas
2. Add IP whitelist (0.0.0.0/0 for all IPs)
3. Create database user
4. Copy connection string
5. Add to environment variables

---

## Migration from Supabase

### Export Data Script
```javascript
// scripts/export-supabase.js
const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');

const supabase = createClient(URL, KEY);

async function exportData() {
  const { data: users } = await supabase.from('profiles').select('*');
  const { data: appointments } = await supabase.from('appointments').select('*');

  fs.writeFileSync('users.json', JSON.stringify(users));
  fs.writeFileSync('appointments.json', JSON.stringify(appointments));
}

exportData();
```

### Import to MongoDB Script
```javascript
// scripts/import-mongodb.js
const mongoose = require('mongoose');
const User = require('../models/User');
const fs = require('fs');

async function importData() {
  await mongoose.connect(process.env.MONGODB_URI);

  const users = JSON.parse(fs.readFileSync('users.json'));

  for (const user of users) {
    await User.create({
      email: user.email,
      fullName: user.full_name,
      role: user.role,
      // ... map other fields
    });
  }

  console.log('Import complete');
}

importData();
```

---

## Testing

```bash
npm test
```

### Example Test
```javascript
const request = require('supertest');
const app = require('./server');

describe('Auth API', () => {
  it('should register a new user', async () => {
    const res = await request(app)
      .post('/api/auth/register')
      .send({
        email: 'test@example.com',
        password: 'password123',
        fullName: 'Test User',
        role: 'patient'
      });

    expect(res.statusCode).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.token).toBeDefined();
  });
});
```

---

## Performance Optimization

### Indexing
All models have appropriate indexes defined. Monitor with:
```javascript
db.collection.getIndexes()
```

### Caching
Consider Redis for session management:
```bash
npm install redis
```

### Rate Limiting
```javascript
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100
});

app.use('/api/', limiter);
```

---

## Security Checklist

- [ ] Change JWT_SECRET in production
- [ ] Use HTTPS in production
- [ ] Sanitize user input
- [ ] Implement rate limiting
- [ ] Add request validation
- [ ] Use helmet.js for security headers
- [ ] Enable MongoDB authentication
- [ ] Backup database regularly

---

## Support

For issues or questions:
1. Check MongoDB logs: `mongod.log`
2. Check application logs
3. Review API documentation
4. Test with Postman/Insomnia

---

## Next Steps

1. Complete remaining models (Prescription, Notification, Review)
2. Implement remaining API routes
3. Add file upload functionality
4. Set up Socket.io for real-time features
5. Write comprehensive tests
6. Deploy to production
7. Migrate data from Supabase
8. Update frontend to use new API
