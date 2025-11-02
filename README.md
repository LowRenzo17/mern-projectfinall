# MediReach - AI-Powered Healthcare Platform

A comprehensive healthcare management system with intelligent AI-powered features designed to enhance patient experience, optimize doctor workflows, and enable data-driven medical insights.

## 🌟 Features

### AI-Powered Capabilities
- **Symptom Checker Chatbot**: Interactive NLP-based chatbot for natural symptom analysis and condition identification
- **Automatic Appointment Triage**: Intelligent prioritization system that ranks patient requests by urgency and routes to appropriate specialists
- **Predictive Health Analytics**: Machine learning-powered insights for health risk assessment, trend analysis, and healthcare demand forecasting

### Patient Portal
- 24/7 AI symptom checking with specialist recommendations
- Easy appointment booking with intelligent scheduling
- Personal health dashboard with appointment history
- Real-time notifications and reminders

### Doctor Dashboard
- Triage-ranked appointment queue with pre-screened symptom summaries
- Patient risk profiles and health history
- AI-generated insights for better decision making
- Appointment management and scheduling tools

### Admin Console
- Predictive analytics dashboard with trend visualization
- Healthcare demand forecasting and resource planning
- Seasonal illness pattern analysis
- System-wide health metrics and KPIs

## 🏗️ Architecture

### Technology Stack
- **Frontend**: React + TypeScript + Tailwind CSS
- **Backend**: Supabase (PostgreSQL + Edge Functions)
- **AI/ML**: OpenAI API integration for NLP, predictive algorithms
- **Real-time**: Supabase Real-time subscriptions
- **Authentication**: Supabase Auth (Email/Password)
- **Database**: PostgreSQL with Row Level Security (RLS)

### Key Components

#### AI Services (Edge Functions)
1. **Symptom Checker** (`/functions/v1/symptom-checker`)
   - NLP-based symptom analysis
   - Condition identification and severity scoring
   - Specialist recommendations

2. **Appointment Triage** (`/functions/v1/appointment-triage`)
   - Urgency assessment and prioritization
   - Specialist routing based on symptoms
   - Schedule optimization

3. **Health Analytics** (`/functions/v1/health-analytics`)
   - Patient risk profiling
   - Trend analysis and forecasting
   - Seasonal pattern detection

#### Database Tables
- **users**: User accounts with role-based access
- **profiles**: Extended user profiles for doctors and patients
- **appointments**: Appointment records with triage status
- **symptom_logs**: AI-analyzed symptom data
- **triage_reports**: Appointment prioritization records
- **health_analytics**: Predictive insights and trends
- **patient_risk_profiles**: AI-generated health risk assessments
- **ai_interactions**: Audit trail of AI usage with consent tracking

## 🚀 Getting Started

### Prerequisites
- Node.js 18+ and npm
- Modern web browser

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd medireach
```

2. Install dependencies
```bash
npm install
```

3. Configure environment variables
```bash
# .env file is pre-configured with Supabase credentials
# No additional setup required
```

4. Start the development server
```bash
npm run dev
```

5. Open your browser and navigate to `http://localhost:5173`

### Build for Production
```bash
npm run build
```

## 📖 Usage Guide

### For Patients
1. **Register/Login**: Create an account or log in with your credentials
2. **Use Symptom Checker**: Click the AI chatbot widget to describe symptoms
3. **Book Appointment**: Follow AI recommendations to schedule with appropriate specialists
4. **Track Health**: Monitor your appointment history and health metrics

### For Doctors
1. **View Dashboard**: See triage-ranked appointments with urgency scores
2. **Review Insights**: Check pre-screened symptom summaries and patient risk profiles
3. **Manage Appointments**: Confirm, reschedule, or complete appointments
4. **Access Analytics**: View patient health trends and historical data

### For Administrators
1. **Analytics Dashboard**: Monitor system-wide health metrics
2. **Forecasting**: View demand predictions and resource allocation recommendations
3. **Trend Analysis**: Identify seasonal patterns and emerging health concerns
4. **System Management**: Manage users, roles, and platform settings

## 🔒 Security & Privacy

### Data Protection
- **End-to-End Security**: All data encrypted in transit and at rest
- **Row Level Security (RLS)**: Database-level access control ensuring users only see their own data
- **JWT Authentication**: Secure token-based authentication system

### Compliance
- **HIPAA Compliance**: Healthcare data handling follows HIPAA guidelines
- **GDPR Compliance**: User privacy and data protection measures in place
- **Audit Trail**: Complete logging of AI interactions and data access
- **User Consent**: Explicit opt-in required for AI data usage

### Privacy Features
- Data anonymization for analytics
- Patient consent tracking for all AI features
- Clear disclaimers: AI insights are supplementary to professional medical advice
- Configurable data retention policies

## 🧪 Testing

Run linting and type checking:
```bash
npm run lint
npm run typecheck
```

## 📁 Project Structure

```
medireach/
├── src/
│   ├── components/
│   │   ├── admin/              # Admin dashboard components
│   │   ├── auth/               # Authentication forms
│   │   ├── doctor/             # Doctor dashboard components
│   │   ├── patient/            # Patient portal components
│   │   ├── video/              # Video consultation components
│   │   ├── notifications/      # Notification system
│   │   └── layout/             # Layout components
│   ├── contexts/
│   │   ├── AuthContext.tsx      # Authentication state management
│   │   └── ThemeContext.tsx     # Theme management
│   ├── lib/
│   │   └── supabase.ts          # Supabase client configuration
│   ├── App.tsx                  # Main application component
│   ├── main.tsx                 # Application entry point
│   └── index.css                # Global styles
├── supabase/
│   ├── functions/               # Edge functions for AI services
│   └── migrations/              # Database schema migrations
├── public/                      # Static assets
└── package.json                 # Project dependencies
```

## 🤝 API Endpoints

### AI Symptom Checker
```
POST /functions/v1/symptom-checker
Content-Type: application/json

{
  "symptoms": "sore throat and fever",
  "duration": "2 days"
}

Response:
{
  "analysis": {
    "conditions": ["Viral Infection", "Flu", "Tonsillitis"],
    "severity": 6.5,
    "recommendations": ["See General Practitioner", "Rest", "Hydration"]
  }
}
```

### Appointment Triage
```
POST /functions/v1/appointment-triage
Content-Type: application/json

{
  "symptoms": "chest pain",
  "patientId": "user-uuid"
}

Response:
{
  "urgency": "emergency",
  "priority_score": 95,
  "recommended_specialist": "Cardiologist",
  "estimated_wait_time": "15 minutes"
}
```

### Health Analytics
```
GET /functions/v1/health-analytics?period=month

Response:
{
  "trends": [...],
  "forecast": {...},
  "risk_profiles": [...]
}
```

## 📊 AI Model Performance

The AI system continuously improves with real-world data:
- **Symptom Recognition**: Trained on medical databases and user feedback
- **Triage Accuracy**: Validated against established medical severity scales
- **Prediction Models**: Ensemble methods combining multiple ML algorithms

## 🔄 Real-Time Features

- Live appointment status updates
- Real-time notification delivery
- Instant chatbot responses
- Dynamic schedule synchronization

## 📈 Analytics & Insights

### Patient-Level Analytics
- Health risk scores and trends
- Appointment frequency and patterns
- Treatment effectiveness tracking

### System-Level Analytics
- Disease prevalence and seasonal trends
- Healthcare resource utilization
- Demand forecasting by specialty
- System performance metrics

## 🚨 Troubleshooting

### Common Issues

**Chatbot not responding**
- Check browser console for errors
- Verify Supabase credentials in `.env`
- Ensure JavaScript is enabled

**Appointment triage not working**
- Confirm symptoms are entered completely
- Check network connectivity
- Verify doctor availability in system

**Analytics dashboard empty**
- Requires sufficient historical data
- Check date range filter settings
- Verify admin access permissions

## 📞 Support

For issues or questions:
1. Check the troubleshooting section above
2. Review API documentation in code comments
3. Check browser console for error messages
4. Contact system administrator

## 📝 License

This project is proprietary and confidential.

## 🙏 Acknowledgments

- Built with React, Supabase, and modern web technologies
- AI capabilities powered by OpenAI API
- UI components styled with Tailwind CSS
- Icons from Lucide React

---

**Note**: This healthcare platform is designed to assist medical professionals and patients. AI recommendations are supplementary and should not replace professional medical advice. Always consult with qualified healthcare providers for diagnosis and treatment.
