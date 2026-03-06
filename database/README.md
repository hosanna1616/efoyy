# Database Setup Guide

## Quick Setup

1. **Create Supabase Project**
   - Go to [supabase.com](https://supabase.com)
   - Create a new project
   - Wait for project to be ready (2-3 minutes)

2. **Run SQL Schema**
   - Open Supabase Dashboard
   - Go to SQL Editor
   - Copy and paste contents of `supabase_schema.sql`
   - Click "Run" to execute

3. **Enable Realtime**
   - Go to Database > Replication
   - Enable replication for:
     - `queue_entries`
     - `pain_reports`
     - `emergency_alerts`

4. **Get API Credentials**
   - Go to Settings > API
   - Copy:
     - Project URL
     - `anon` `public` key

5. **Configure App**
   - Set environment variables:
     ```bash
     export SUPABASE_URL=https://your-project.supabase.co
     export SUPABASE_ANON_KEY=your-anon-key
     ```
   - Or configure in app settings (if implemented)

## Tables Created

- `patients` - Patient records
- `queue_entries` - OPD queue management
- `instructions` - Pre-op/Post-op instructions
- `navigation_steps` - Hospital navigation
- `pain_reports` - Pain management tracking
- `feedback` - Patient feedback
- `emergency_alerts` - Emergency help requests

## Features

- **Row Level Security (RLS)** enabled on all tables
- **Realtime** enabled for queue, pain reports, and emergencies
- **Auto-updating** queue positions via triggers
- **Indexes** for fast queries
- **Timestamps** auto-updated on changes

## Testing

After setup, test with:
1. Register a patient
2. Join a queue
3. Report pain
4. Send feedback
5. Request emergency help

All should sync to Supabase automatically!




