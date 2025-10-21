import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables');
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

export interface Database {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string;
          email: string;
          full_name: string;
          role: 'patient' | 'doctor' | 'admin';
          phone: string | null;
          avatar_url: string | null;
          date_of_birth: string | null;
          gender: 'male' | 'female' | 'other' | 'prefer_not_to_say' | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id: string;
          email: string;
          full_name: string;
          role: 'patient' | 'doctor' | 'admin';
          phone?: string | null;
          avatar_url?: string | null;
          date_of_birth?: string | null;
          gender?: 'male' | 'female' | 'other' | 'prefer_not_to_say' | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: {
          email?: string;
          full_name?: string;
          role?: 'patient' | 'doctor' | 'admin';
          phone?: string | null;
          avatar_url?: string | null;
          date_of_birth?: string | null;
          gender?: 'male' | 'female' | 'other' | 'prefer_not_to_say' | null;
          updated_at?: string;
        };
      };
      doctor_profiles: {
        Row: {
          id: string;
          user_id: string;
          specialization: string;
          license_number: string;
          qualification: string;
          experience_years: number;
          consultation_fee: number;
          bio: string | null;
          is_verified: boolean;
          is_available: boolean;
          rating: number;
          total_consultations: number;
          created_at: string;
          updated_at: string;
        };
      };
      appointments: {
        Row: {
          id: string;
          patient_id: string;
          doctor_id: string;
          appointment_date: string;
          appointment_time: string;
          status: 'pending' | 'confirmed' | 'completed' | 'cancelled' | 'rescheduled';
          reason: string;
          notes: string | null;
          video_room_id: string | null;
          created_at: string;
          updated_at: string;
        };
      };
      prescriptions: {
        Row: {
          id: string;
          appointment_id: string;
          patient_id: string;
          doctor_id: string;
          diagnosis: string;
          medications: any;
          instructions: string | null;
          file_url: string | null;
          created_at: string;
        };
      };
      notifications: {
        Row: {
          id: string;
          user_id: string;
          title: string;
          message: string;
          type: 'appointment' | 'prescription' | 'system' | 'reminder';
          is_read: boolean;
          related_id: string | null;
          created_at: string;
        };
      };
    };
  };
}
