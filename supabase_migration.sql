-- Run this in your Supabase SQL Editor
-- Go to: https://supabase.com/dashboard/project/bgqnhkddlmdtldrolpoj/sql/new

-- Drop existing tables (order matters due to foreign keys)
DROP TABLE IF EXISTS todos;
DROP TABLE IF EXISTS users;

-- Users table for storing user data
CREATE TABLE IF NOT EXISTS users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL,
  profile_pic TEXT,
  phone_number TEXT,
  home_address TEXT,
  created_at TIMESTAMP DEFAULT (NOW() AT TIME ZONE 'Asia/Kathmandu'),
  updated_at TIMESTAMP DEFAULT (NOW() AT TIME ZONE 'Asia/Kathmandu')
);

-- Enable Row Level Security (RLS)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Allow all operations for anonymous users (for this demo)
CREATE POLICY "Allow all for anon" ON users
  FOR ALL
  TO anon
  USING (true)
  WITH CHECK (true);

-- Allow all operations for authenticated users
CREATE POLICY "Allow all for authenticated" ON users
  FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Todos table
CREATE TABLE IF NOT EXISTS todos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  is_completed BOOLEAN DEFAULT FALSE,
  completed_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT (NOW() AT TIME ZONE 'Asia/Kathmandu')
);

-- Enable Row Level Security (RLS)
ALTER TABLE todos ENABLE ROW LEVEL SECURITY;

-- Allow all operations for anonymous users (for this demo)
CREATE POLICY "Allow all for anon" ON todos
  FOR ALL
  TO anon
  USING (true)
  WITH CHECK (true);

-- Allow all operations for authenticated users
CREATE POLICY "Allow all for authenticated" ON todos
  FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);
