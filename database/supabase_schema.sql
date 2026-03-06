-- -- Complete Supabase Database Schema for Efoy
-- -- Run this in Supabase SQL Editor

-- -- Enable UUID extension
-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- -- Patients table
-- CREATE TABLE IF NOT EXISTS patients (
--   id TEXT PRIMARY KEY,
--   phone_number TEXT UNIQUE NOT NULL,
--   name TEXT NOT NULL,
--   photo_url TEXT,
--   created_at TIMESTAMP DEFAULT NOW(),
--   last_appointment TIMESTAMP,
--   next_appointment TIMESTAMP,
--   next_appointment_room TEXT,
--   medical_history JSONB DEFAULT '[]'::jsonb,
--   updated_at TIMESTAMP DEFAULT NOW()
-- );

-- -- Queue entries table
-- CREATE TABLE IF NOT EXISTS queue_entries (
--   id TEXT PRIMARY KEY,
--   patient_id TEXT REFERENCES patients(id) ON DELETE CASCADE,
--   patient_name TEXT NOT NULL,
--   patient_phone TEXT NOT NULL,
--   queue_number INTEGER NOT NULL,
--   room TEXT NOT NULL,
--   joined_at TIMESTAMP DEFAULT NOW(),
--   called_at TIMESTAMP,
--   is_active BOOLEAN DEFAULT true,
--   current_position INTEGER DEFAULT 0,
--   total_in_queue INTEGER DEFAULT 0,
--   updated_at TIMESTAMP DEFAULT NOW()
-- );

-- -- Instructions table
-- CREATE TABLE IF NOT EXISTS instructions (
--   id TEXT PRIMARY KEY,
--   patient_id TEXT REFERENCES patients(id) ON DELETE CASCADE,
--   type TEXT NOT NULL CHECK (type IN ('preOp', 'postOp', 'general')),
--   title TEXT NOT NULL,
--   steps JSONB NOT NULL DEFAULT '[]'::jsonb,
--   created_at TIMESTAMP DEFAULT NOW(),
--   scheduled_for TIMESTAMP,
--   is_read BOOLEAN DEFAULT false,
--   unavailable_medicine TEXT,
--   alternative_medicine TEXT,
--   pharmacy_location TEXT,
--   updated_at TIMESTAMP DEFAULT NOW()
-- );

-- -- Navigation steps table
-- CREATE TABLE IF NOT EXISTS navigation_steps (
--   id TEXT PRIMARY KEY,
--   patient_id TEXT REFERENCES patients(id) ON DELETE CASCADE,
--   destination TEXT NOT NULL,
--   destination_type TEXT NOT NULL,
--   directions JSONB NOT NULL DEFAULT '[]'::jsonb,
--   latitude DOUBLE PRECISION,
--   longitude DOUBLE PRECISION,
--   is_completed BOOLEAN DEFAULT false,
--   created_at TIMESTAMP DEFAULT NOW(),
--   updated_at TIMESTAMP DEFAULT NOW()
-- );

-- -- Pain reports table
-- CREATE TABLE IF NOT EXISTS pain_reports (
--   id TEXT PRIMARY KEY,
--   patient_id TEXT REFERENCES patients(id) ON DELETE CASCADE,
--   patient_name TEXT NOT NULL,
--   patient_phone TEXT NOT NULL,
--   pain_level INTEGER NOT NULL CHECK (pain_level >= 1 AND pain_level <= 10),
--   reported_at TIMESTAMP DEFAULT NOW(),
--   is_acknowledged BOOLEAN DEFAULT false,
--   notes TEXT,
--   updated_at TIMESTAMP DEFAULT NOW()
-- );

-- -- Feedback table
-- CREATE TABLE IF NOT EXISTS feedback (
--   id TEXT PRIMARY KEY,
--   patient_id TEXT REFERENCES patients(id) ON DELETE CASCADE,
--   is_positive BOOLEAN NOT NULL,
--   submitted_at TIMESTAMP DEFAULT NOW(),
--   comment TEXT,
--   updated_at TIMESTAMP DEFAULT NOW()
-- );

-- -- Emergency alerts table
-- CREATE TABLE IF NOT EXISTS emergency_alerts (
--   id TEXT PRIMARY KEY,
--   patient_id TEXT REFERENCES patients(id) ON DELETE CASCADE,
--   patient_name TEXT NOT NULL,
--   patient_phone TEXT NOT NULL,
--   location TEXT,
--   created_at TIMESTAMP DEFAULT NOW(),
--   is_resolved BOOLEAN DEFAULT false,
--   resolved_at TIMESTAMP,
--   resolved_by TEXT,
--   updated_at TIMESTAMP DEFAULT NOW()
-- );

-- -- Create indexes for better performance
-- CREATE INDEX IF NOT EXISTS idx_patients_phone ON patients(phone_number);
-- CREATE INDEX IF NOT EXISTS idx_queue_entries_room ON queue_entries(room);
-- CREATE INDEX IF NOT EXISTS idx_queue_entries_active ON queue_entries(is_active);
-- CREATE INDEX IF NOT EXISTS idx_queue_entries_patient ON queue_entries(patient_id);
-- CREATE INDEX IF NOT EXISTS idx_instructions_patient ON instructions(patient_id);
-- CREATE INDEX IF NOT EXISTS idx_navigation_steps_patient ON navigation_steps(patient_id);
-- CREATE INDEX IF NOT EXISTS idx_pain_reports_patient ON pain_reports(patient_id);
-- CREATE INDEX IF NOT EXISTS idx_pain_reports_acknowledged ON pain_reports(is_acknowledged);
-- CREATE INDEX IF NOT EXISTS idx_feedback_patient ON feedback(patient_id);
-- CREATE INDEX IF NOT EXISTS idx_emergency_alerts_resolved ON emergency_alerts(is_resolved);

-- -- Enable Row Level Security (RLS)
-- ALTER TABLE patients ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE queue_entries ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE instructions ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE navigation_steps ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE pain_reports ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE feedback ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE emergency_alerts ENABLE ROW LEVEL SECURITY;

-- -- Create policies (allow all for now - adjust based on your auth needs)
-- CREATE POLICY "Allow all operations on patients" ON patients
--   FOR ALL USING (true) WITH CHECK (true);

-- CREATE POLICY "Allow all operations on queue_entries" ON queue_entries
--   FOR ALL USING (true) WITH CHECK (true);

-- CREATE POLICY "Allow all operations on instructions" ON instructions
--   FOR ALL USING (true) WITH CHECK (true);

-- CREATE POLICY "Allow all operations on navigation_steps" ON navigation_steps
--   FOR ALL USING (true) WITH CHECK (true);

-- CREATE POLICY "Allow all operations on pain_reports" ON pain_reports
--   FOR ALL USING (true) WITH CHECK (true);

-- CREATE POLICY "Allow all operations on feedback" ON feedback
--   FOR ALL USING (true) WITH CHECK (true);

-- CREATE POLICY "Allow all operations on emergency_alerts" ON emergency_alerts
--   FOR ALL USING (true) WITH CHECK (true);

-- -- Enable Realtime for queue_entries (for live updates)
-- ALTER PUBLICATION supabase_realtime ADD TABLE queue_entries;
-- ALTER PUBLICATION supabase_realtime ADD TABLE pain_reports;
-- ALTER PUBLICATION supabase_realtime ADD TABLE emergency_alerts;

-- -- Create function to update updated_at timestamp
-- CREATE OR REPLACE FUNCTION update_updated_at_column()
-- RETURNS TRIGGER AS $$
-- BEGIN
--     NEW.updated_at = NOW();
--     RETURN NEW;
-- END;
-- $$ language 'plpgsql';

-- -- Create triggers for updated_at
-- CREATE TRIGGER update_patients_updated_at BEFORE UPDATE ON patients
--     FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- CREATE TRIGGER update_queue_entries_updated_at BEFORE UPDATE ON queue_entries
--     FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- CREATE TRIGGER update_instructions_updated_at BEFORE UPDATE ON instructions
--     FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- CREATE TRIGGER update_navigation_steps_updated_at BEFORE UPDATE ON navigation_steps
--     FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- CREATE TRIGGER update_pain_reports_updated_at BEFORE UPDATE ON pain_reports
--     FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- CREATE TRIGGER update_feedback_updated_at BEFORE UPDATE ON feedback
--     FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- CREATE TRIGGER update_emergency_alerts_updated_at BEFORE UPDATE ON emergency_alerts
--     FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- -- Create function to auto-update queue position
-- CREATE OR REPLACE FUNCTION update_queue_positions()
-- RETURNS TRIGGER AS $$
-- BEGIN
--     -- Update current_position for all entries in the same room
--     UPDATE queue_entries
--     SET current_position = sub.row_num - 1,
--         total_in_queue = sub.total_count
--     FROM (
--         SELECT 
--             id,
--             ROW_NUMBER() OVER (PARTITION BY room ORDER BY queue_number) as row_num,
--             COUNT(*) OVER (PARTITION BY room) as total_count
--         FROM queue_entries
--         WHERE room = NEW.room AND is_active = true
--     ) sub
--     WHERE queue_entries.id = sub.id;
    
--     RETURN NEW;
-- END;
-- $$ language 'plpgsql';

-- -- Create trigger for auto-updating queue positions
-- CREATE TRIGGER update_queue_positions_trigger
--     AFTER INSERT OR UPDATE OR DELETE ON queue_entries
--     FOR EACH ROW EXECUTE FUNCTION update_queue_positions();



-- Complete Supabase Database Schema for Efoy (Safe to re-run)
-- Run this in Supabase SQL Editor

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Patients table
CREATE TABLE IF NOT EXISTS patients (
  id TEXT PRIMARY KEY,
  phone_number TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  photo_url TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  last_appointment TIMESTAMP,
  next_appointment TIMESTAMP,
  next_appointment_room TEXT,
  medical_history JSONB DEFAULT '[]'::jsonb,
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Queue entries table
CREATE TABLE IF NOT EXISTS queue_entries (
  id TEXT PRIMARY KEY,
  patient_id TEXT REFERENCES patients(id) ON DELETE CASCADE,
  patient_name TEXT NOT NULL,
  patient_phone TEXT NOT NULL,
  queue_number INTEGER NOT NULL,
  room TEXT NOT NULL,
  joined_at TIMESTAMP DEFAULT NOW(),
  called_at TIMESTAMP,
  is_active BOOLEAN DEFAULT true,
  current_position INTEGER DEFAULT 0,
  total_in_queue INTEGER DEFAULT 0,
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Instructions table
CREATE TABLE IF NOT EXISTS instructions (
  id TEXT PRIMARY KEY,
  patient_id TEXT REFERENCES patients(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('preOp', 'postOp', 'general')),
  title TEXT NOT NULL,
  steps JSONB NOT NULL DEFAULT '[]'::jsonb,
  created_at TIMESTAMP DEFAULT NOW(),
  scheduled_for TIMESTAMP,
  is_read BOOLEAN DEFAULT false,
  unavailable_medicine TEXT,
  alternative_medicine TEXT,
  pharmacy_location TEXT,
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Navigation steps table
CREATE TABLE IF NOT EXISTS navigation_steps (
  id TEXT PRIMARY KEY,
  patient_id TEXT REFERENCES patients(id) ON DELETE CASCADE,
  destination TEXT NOT NULL,
  destination_type TEXT NOT NULL,
  directions JSONB NOT NULL DEFAULT '[]'::jsonb,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  is_completed BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Pain reports table
CREATE TABLE IF NOT EXISTS pain_reports (
  id TEXT PRIMARY KEY,
  patient_id TEXT REFERENCES patients(id) ON DELETE CASCADE,
  patient_name TEXT NOT NULL,
  patient_phone TEXT NOT NULL,
  pain_level INTEGER NOT NULL CHECK (pain_level >= 1 AND pain_level <= 10),
  reported_at TIMESTAMP DEFAULT NOW(),
  is_acknowledged BOOLEAN DEFAULT false,
  notes TEXT,
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Feedback table
CREATE TABLE IF NOT EXISTS feedback (
  id TEXT PRIMARY KEY,
  patient_id TEXT REFERENCES patients(id) ON DELETE CASCADE,
  is_positive BOOLEAN NOT NULL,
  submitted_at TIMESTAMP DEFAULT NOW(),
  comment TEXT,
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Emergency alerts table
CREATE TABLE IF NOT EXISTS emergency_alerts (
  id TEXT PRIMARY KEY,
  patient_id TEXT REFERENCES patients(id) ON DELETE CASCADE,
  patient_name TEXT NOT NULL,
  patient_phone TEXT NOT NULL,
  location TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  is_resolved BOOLEAN DEFAULT false,
  resolved_at TIMESTAMP,
  resolved_by TEXT,
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_patients_phone ON patients(phone_number);
CREATE INDEX IF NOT EXISTS idx_queue_entries_room ON queue_entries(room);
CREATE INDEX IF NOT EXISTS idx_queue_entries_active ON queue_entries(is_active);
CREATE INDEX IF NOT EXISTS idx_queue_entries_patient ON queue_entries(patient_id);
CREATE INDEX IF NOT EXISTS idx_instructions_patient ON instructions(patient_id);
CREATE INDEX IF NOT EXISTS idx_navigation_steps_patient ON navigation_steps(patient_id);
CREATE INDEX IF NOT EXISTS idx_pain_reports_patient ON pain_reports(patient_id);
CREATE INDEX IF NOT EXISTS idx_pain_reports_acknowledged ON pain_reports(is_acknowledged);
CREATE INDEX IF NOT EXISTS idx_feedback_patient ON feedback(patient_id);
CREATE INDEX IF NOT EXISTS idx_emergency_alerts_resolved ON emergency_alerts(is_resolved);

-- Enable Row Level Security (RLS)
ALTER TABLE patients ENABLE ROW LEVEL SECURITY;
ALTER TABLE queue_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE instructions ENABLE ROW LEVEL SECURITY;
ALTER TABLE navigation_steps ENABLE ROW LEVEL SECURITY;
ALTER TABLE pain_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE feedback ENABLE ROW LEVEL SECURITY;
ALTER TABLE emergency_alerts ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist, then recreate
DROP POLICY IF EXISTS "Allow all operations on patients" ON patients;
CREATE POLICY "Allow all operations on patients" ON patients
  FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow all operations on queue_entries" ON queue_entries;
CREATE POLICY "Allow all operations on queue_entries" ON queue_entries
  FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow all operations on instructions" ON instructions;
CREATE POLICY "Allow all operations on instructions" ON instructions
  FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow all operations on navigation_steps" ON navigation_steps;
CREATE POLICY "Allow all operations on navigation_steps" ON navigation_steps
  FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow all operations on pain_reports" ON pain_reports;
CREATE POLICY "Allow all operations on pain_reports" ON pain_reports
  FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow all operations on feedback" ON feedback;
CREATE POLICY "Allow all operations on feedback" ON feedback
  FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Allow all operations on emergency_alerts" ON emergency_alerts;
CREATE POLICY "Allow all operations on emergency_alerts" ON emergency_alerts
  FOR ALL USING (true) WITH CHECK (true);

-- Enable Realtime for queue_entries (for live updates)
-- Note: These might fail if already added, that's okay
DO $$ 
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE queue_entries;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ 
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE pain_reports;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ 
BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE emergency_alerts;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Drop and recreate triggers for updated_at
DROP TRIGGER IF EXISTS update_patients_updated_at ON patients;
CREATE TRIGGER update_patients_updated_at BEFORE UPDATE ON patients
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_queue_entries_updated_at ON queue_entries;
CREATE TRIGGER update_queue_entries_updated_at BEFORE UPDATE ON queue_entries
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_instructions_updated_at ON instructions;
CREATE TRIGGER update_instructions_updated_at BEFORE UPDATE ON instructions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_navigation_steps_updated_at ON navigation_steps;
CREATE TRIGGER update_navigation_steps_updated_at BEFORE UPDATE ON navigation_steps
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_pain_reports_updated_at ON pain_reports;
CREATE TRIGGER update_pain_reports_updated_at BEFORE UPDATE ON pain_reports
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_feedback_updated_at ON feedback;
CREATE TRIGGER update_feedback_updated_at BEFORE UPDATE ON feedback
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_emergency_alerts_updated_at ON emergency_alerts;
CREATE TRIGGER update_emergency_alerts_updated_at BEFORE UPDATE ON emergency_alerts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create function to auto-update queue position (FIXED VERSION - prevents recursion)
CREATE OR REPLACE FUNCTION update_queue_positions()
RETURNS TRIGGER AS $$
BEGIN
    -- Only update if the position actually needs to change
    -- This prevents infinite recursion
    UPDATE queue_entries qe
    SET 
        current_position = sub.row_num - 1,
        total_in_queue = sub.total_count
    FROM (
        SELECT 
            id,
            ROW_NUMBER() OVER (PARTITION BY room ORDER BY queue_number) as row_num,
            COUNT(*) OVER (PARTITION BY room) as total_count
        FROM queue_entries
        WHERE room = COALESCE(NEW.room, OLD.room) AND is_active = true
    ) sub
    WHERE qe.id = sub.id
      AND (
          qe.current_position IS DISTINCT FROM (sub.row_num - 1) OR
          qe.total_in_queue IS DISTINCT FROM sub.total_count
      );
    
    RETURN COALESCE(NEW, OLD);
END;
$$ language 'plpgsql';

-- Drop and recreate trigger for auto-updating queue positions (FIXED VERSION)
DROP TRIGGER IF EXISTS update_queue_positions_trigger ON queue_entries;
CREATE TRIGGER update_queue_positions_trigger
    AFTER INSERT OR UPDATE OF queue_number, is_active, room OR DELETE ON queue_entries
    FOR EACH ROW 
    EXECUTE FUNCTION update_queue_positions();
