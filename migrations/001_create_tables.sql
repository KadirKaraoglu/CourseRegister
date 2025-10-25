-- Migration: 001_create_tables.sql
-- Creates course_groups and registrations tables

-- Ensure pgcrypto is available for gen_random_uuid
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS course_groups (
  group_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  max_capacity SMALLINT NOT NULL DEFAULT 10 CHECK (max_capacity > 0),
  registered_count SMALLINT NOT NULL DEFAULT 0 CHECK (registered_count >= 0),
  reserved_count SMALLINT NOT NULL DEFAULT 0 CHECK (reserved_count >= 0),
  -- Invariant: sum of registered + reserved must never exceed max_capacity
  CHECK (registered_count + reserved_count <= max_capacity),
  is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS registrations (
  registration_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id UUID NOT NULL REFERENCES course_groups(group_id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('RESERVED','PAID','CANCELLED')),
  reservation_expiry TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT registrations_email_group_unique UNIQUE (email, group_id)
);

-- Optional: index by group for faster lookups
CREATE INDEX IF NOT EXISTS idx_registrations_group_id ON registrations(group_id);
