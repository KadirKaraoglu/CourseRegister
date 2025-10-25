-- Migration: 002_seed.sql
-- Seed initial course_groups and an example registration (for local dev/testing)

INSERT INTO course_groups (group_id, name, max_capacity, registered_count, reserved_count, is_active)
VALUES
  (gen_random_uuid(), 'Ekim 2025 Grubu', 10, 3, 1, true),
  (gen_random_uuid(), 'Aralık 2025 Grubu', 10, 10, 0, true)
ON CONFLICT DO NOTHING;

-- Example reserved registration (for Ekim group) — adjust group_id accordingly in real usage
-- INSERT INTO registrations (registration_id, group_id, email, status, reservation_expiry)
-- VALUES (gen_random_uuid(), '<PUT-EKIM-GROUP-ID-HERE>', 'test@example.com', 'RESERVED', now() + interval '30 minutes');
