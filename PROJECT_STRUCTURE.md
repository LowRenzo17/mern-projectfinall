# MediReach - Project Structure

## Overview
The MediReach application is organized into **Frontend** and **Backend** layers for clean separation of concerns, maintainability, and scalability.

---

## Directory Organization

```
project/
├── src/
│   ├── frontend/                    # Frontend - React application
│   │   ├── main.tsx                 # Application entry point
│   │   ├── styles.css               # Global styles
│   │   ├── vite-env.d.ts            # Vite environment types
│   │   ├── pages/                   # Page components
│   │   │   └── App.tsx              # Main app routing & layout
│   │   ├── components/              # Reusable UI components
│   │   │   ├── auth/                # Authentication UI
│   │   │   │   ├── LoginForm.tsx
│   │   │   │   └── RegisterForm.tsx
│   │   │   ├── patient/             # Patient-specific components
│   │   │   │   ├── PatientDashboard.tsx
│   │   │   │   └── BookAppointmentModal.tsx
│   │   │   ├── doctor/              # Doctor-specific components
│   │   │   │   ├── DoctorDashboard.tsx
│   │   │   │   └── DoctorProfileSetup.tsx
│   │   │   ├── admin/               # Admin-specific components
│   │   │   │   └── AdminDashboard.tsx
│   │   │   ├── layout/              # Layout components
│   │   │   │   └── Header.tsx
│   │   │   ├── video/               # Video consultation components
│   │   │   │   └── VideoConsultation.tsx
│   │   │   └── notifications/       # Notification components
│   │   │       └── NotificationPanel.tsx
│   │   ├── contexts/                # React Context for state management
│   │   │   ├── AuthContext.tsx      # Authentication state
│   │   │   └── ThemeContext.tsx     # Theme management
│   │   └── hooks/                   # Custom React hooks (future)
│   │
│   ├── backend/                     # Backend services & logic
│   │   ├── services/                # External service integrations
│   │   │   └── supabase.ts          # Supabase client configuration
│   │   ├── api/                     # API integration layer (future)
│   │   └── types/                   # TypeScript types for backend (future)
│   │
│   └── shared/                      # Shared code between frontend & backend
│       └── types/                   # Shared TypeScript interfaces
│
├── supabase/
│   └── migrations/                  # Database migrations
│       └── 20251020213951_create_medireach_schema.sql
│
├── public/                          # Static assets
├── dist/                            # Build output
│
├── index.html                       # HTML entry point
├── vite.config.ts                   # Vite configuration
├── tailwind.config.js               # Tailwind CSS configuration
├── tsconfig.json                    # TypeScript configuration
├── package.json                     # Dependencies & scripts
└── README.md                        # Project documentation
```

---

## Frontend Layer (`src/frontend/`)

### Purpose
Handles all user interface, client-side logic, and user interactions using React and Tailwind CSS.

### Key Components

#### Pages (`pages/`)
- **App.tsx**: Main application component
  - Handles authentication state
  - Routes to appropriate dashboard (Patient, Doctor, Admin)
  - Manages app-level state

#### Components (`components/`)
Organized by feature/domain:

- **auth/**: Login and registration forms
- **patient/**: Patient-specific UI (book appointments, view history)
- **doctor/**: Doctor dashboard and profile management
- **admin/**: Admin dashboard for verification and management
- **layout/**: Header, navigation, layout elements
- **video/**: Video consultation interface
- **notifications/**: Notification panel and alerts

#### Contexts (`contexts/`)
Global state management using React Context API:

- **AuthContext.tsx**: User authentication, profile, session
- **ThemeContext.tsx**: Dark/light theme management

#### Styling
- **styles.css**: Global styles and Tailwind directives
- Component-level styles use Tailwind utility classes

---

## Backend Layer (`src/backend/`)

### Purpose
Handles data access, external integrations, and business logic.

### Current Structure

#### Services (`services/`)
- **supabase.ts**: Supabase client initialization and configuration
  - Manages database connections
  - Provides authenticated client instance

#### API (`api/`) - *Reserved for future*
- API route handlers and middleware

#### Types (`types/`) - *Reserved for future*
- Backend-specific TypeScript interfaces

---

## Database (`supabase/`)

### Migrations (`migrations/`)
SQL schema and data management:

- **20251020213951_create_medireach_schema.sql**
  - Creates all tables (profiles, appointments, prescriptions, etc.)
  - Sets up Row Level Security (RLS) policies
  - Creates indexes and triggers

### Database Tables

#### Core Tables
- **profiles**: User account information
- **doctor_profiles**: Extended doctor information
- **appointments**: Appointment bookings
- **prescriptions**: Medical prescriptions

#### Supporting Tables
- **doctor_availability**: Doctor scheduling
- **medical_records**: Patient medical history
- **notifications**: System notifications
- **chat_messages**: Appointment messaging
- **reviews**: Doctor ratings and reviews

---

## Data Flow

### Authentication Flow
```
User Input → LoginForm → AuthContext.signIn() → Supabase Auth → Profile Fetched → App Routes
```

### Data Access Flow
```
Frontend Component → Supabase Client (services/supabase.ts) → Database → RLS Policies → Response
```

---

## Key Principles

### Separation of Concerns
- **Frontend**: User interface and interactions
- **Backend**: Data access and external services
- **Shared**: Common types and utilities

### Security
- Row Level Security (RLS) enforced at database layer
- Authentication state managed in AuthContext
- Supabase handles credential security

### Scalability
- Modular component structure allows easy feature addition
- Backend services layer enables easy integration of new APIs
- TypeScript ensures type safety across layers

### Best Practices
- No hardcoded configuration; environment variables used
- Components follow single responsibility principle
- Consistent naming conventions across layers
- Proper error handling and user feedback

---

## Development Workflow

### Adding New Features

1. **UI Components**: Add to `frontend/components/{feature}/`
2. **State Management**: Use AuthContext or create feature-specific hooks
3. **Database Operations**: Call Supabase methods in components or create service functions
4. **Types**: Define interfaces in component files or `shared/types/`

### Example: New Feature
```typescript
// frontend/components/myfeature/MyComponent.tsx
import { supabase } from '../../../backend/services/supabase';
import { useAuth } from '../../contexts/AuthContext';

export default function MyComponent() {
  const { user } = useAuth();

  const fetchData = async () => {
    const { data, error } = await supabase
      .from('my_table')
      .select('*');
  };

  return <div>...</div>;
}
```

---

## Environment Configuration

All environment variables are managed through `.env` file:
```
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_anon_key
```

Access in frontend:
```typescript
const url = import.meta.env.VITE_SUPABASE_URL;
```

---

## Build & Deployment

### Local Development
```bash
npm run dev    # Start dev server
```

### Production Build
```bash
npm run build  # Build for production
npm run preview # Preview build locally
```

### Deployment
- Frontend: Deploy `dist/` folder to CDN or static host
- Backend: Supabase handles automatically
- Database: Migrations applied via Supabase console

---

## Future Enhancements

### Planned Additions
- **Edge Functions** (`supabase/functions/`): Serverless backend logic
- **Backend Hooks** (`src/backend/hooks/`): Custom React hooks for data fetching
- **Utils** (`src/frontend/utils/`): Helper functions for formatting, validation
- **Services** (`src/backend/services/`): Third-party API integrations
- **API Routes** (`src/backend/api/`): Custom backend endpoints

---

## File Naming Conventions

- **Components**: PascalCase (e.g., `LoginForm.tsx`)
- **Utilities/Services**: camelCase (e.g., `supabase.ts`)
- **Types**: PascalCase (e.g., `Profile`)
- **Directories**: kebab-case (e.g., `patient-dashboard`)

---

## Quick Reference

| Task | Location |
|------|----------|
| Add UI Component | `src/frontend/components/{category}/` |
| Manage Auth State | `src/frontend/contexts/AuthContext.tsx` |
| Access Database | `src/backend/services/supabase.ts` |
| Create Migration | `supabase/migrations/` |
| Global Styles | `src/frontend/styles.css` |
| Theme Settings | `tailwind.config.js` |
| Configuration | `.env` |
