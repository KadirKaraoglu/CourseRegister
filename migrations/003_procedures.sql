-- Migration: 003_procedures.sql
-- Stored procedures to handle atomic reservation, confirm and cancel operations.

-- reserve_spot(p_group_id UUID, p_email TEXT, p_name TEXT, p_phone TEXT, OUT p_registration_id UUID)
-- Returns newly created registration_id if reservation succeeds, otherwise raises exception.

CREATE OR REPLACE FUNCTION reserve_spot(p_group_id UUID, p_email TEXT, p_name TEXT, p_phone TEXT)
RETURNS UUID AS $$
DECLARE
  v_remaining INT;
  v_reg_id UUID;
BEGIN
  -- Lock group row for update to avoid races
  SELECT (max_capacity - registered_count - reserved_count) INTO v_remaining
    FROM course_groups WHERE group_id = p_group_id FOR UPDATE;

  IF v_remaining IS NULL THEN
    RAISE EXCEPTION 'Group not found';
  END IF;

  IF v_remaining <= 0 THEN
    RAISE EXCEPTION 'No available spots';
  END IF;

  -- Create registration with RESERVED status and expiry +30 minutes
  v_reg_id := gen_random_uuid();
  INSERT INTO registrations (registration_id, group_id, email, status, reservation_expiry)
    VALUES (v_reg_id, p_group_id, p_email, 'RESERVED', now() + interval '30 minutes');

  -- Atomically increment reserved_count but double-check invariant to be safe
  UPDATE course_groups
    SET reserved_count = reserved_count + 1
  WHERE group_id = p_group_id
    AND (registered_count + reserved_count) < max_capacity;

  IF NOT FOUND THEN
    -- This should be rare due to earlier checks, but guard against race
    -- Roll back the new registration to keep DB consistent
    DELETE FROM registrations WHERE registration_id = v_reg_id;
    RAISE EXCEPTION 'Failed to reserve spot due to concurrent updates';
  END IF;

  RETURN v_reg_id;
EXCEPTION WHEN unique_violation THEN
  -- If email+group unique constraint violated
  RAISE EXCEPTION 'Email already registered for this group';
END;
$$ LANGUAGE plpgsql;


-- confirm_payment(p_registration_id UUID)
-- Moves registration from RESERVED -> PAID, adjusts counters atomically
CREATE OR REPLACE FUNCTION confirm_payment(p_registration_id UUID)
RETURNS VOID AS $$
DECLARE
  v_group_id UUID;
  v_status TEXT;
BEGIN
  -- Lock the registration row
  SELECT group_id, status INTO v_group_id, v_status FROM registrations WHERE registration_id = p_registration_id FOR UPDATE;

  IF v_group_id IS NULL THEN
    RAISE EXCEPTION 'Registration not found';
  END IF;

  IF v_status <> 'RESERVED' THEN
    RAISE EXCEPTION 'Registration not in RESERVED state';
  END IF;

  -- Update registration status
  UPDATE registrations SET status = 'PAID' WHERE registration_id = p_registration_id;

  -- Update counts atomically (decrement reserved, increment registered) and guard invariants
  UPDATE course_groups
    SET registered_count = registered_count + 1,
        reserved_count = reserved_count - 1
  WHERE group_id = v_group_id
    AND reserved_count > 0
    AND (registered_count + reserved_count) <= max_capacity;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Invariant violation while confirming payment';
  END IF;

END;
$$ LANGUAGE plpgsql;


-- cancel_reservation(p_registration_id UUID)
-- Cancels a reservation and decrements reserved_count
CREATE OR REPLACE FUNCTION cancel_reservation(p_registration_id UUID)
RETURNS VOID AS $$
DECLARE
  v_group_id UUID;
  v_status TEXT;
BEGIN
  SELECT group_id, status INTO v_group_id, v_status FROM registrations WHERE registration_id = p_registration_id FOR UPDATE;

  IF v_group_id IS NULL THEN
    RAISE EXCEPTION 'Registration not found';
  END IF;

  IF v_status = 'CANCELLED' THEN
    RETURN; -- already cancelled
  END IF;

  -- Update registration status
  UPDATE registrations SET status = 'CANCELLED' WHERE registration_id = p_registration_id;

  -- If it was RESERVED, decrement reserved_count. If PAID, adjust registered_count accordingly (unlikely for cancel)
  IF v_status = 'RESERVED' THEN
    UPDATE course_groups SET reserved_count = reserved_count - 1 WHERE group_id = v_group_id AND reserved_count > 0;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'Invariant violation while cancelling RESERVED registration';
    END IF;
  ELSIF v_status = 'PAID' THEN
    UPDATE course_groups SET registered_count = registered_count - 1 WHERE group_id = v_group_id AND registered_count > 0;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'Invariant violation while cancelling PAID registration';
    END IF;
  END IF;

END;
$$ LANGUAGE plpgsql;


-- Simple unit-test SQL snippets (run manually) to validate basic flows
-- 1) Reserve a spot
-- SELECT reserve_spot('<GROUP_UUID>', 'u1@example.com', 'User One', '555-0101');

-- 2) Confirm payment
-- SELECT confirm_payment('<REGISTRATION_UUID>');

-- 3) Cancel reservation
-- SELECT cancel_reservation('<REGISTRATION_UUID>');
