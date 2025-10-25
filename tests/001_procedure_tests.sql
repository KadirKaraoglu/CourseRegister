-- Test: Stored procedures basic flow
-- Runs: reserve_spot -> confirm_payment -> cancel_reservation

DO $$
DECLARE
  v_group uuid := '11111111-1111-1111-1111-111111111111';
  reg1 uuid;
  reg2 uuid;
  rc_reserved int;
  rc_registered int;
BEGIN
  -- Ensure clean state
  DELETE FROM registrations WHERE group_id = v_group;
  DELETE FROM course_groups WHERE group_id = v_group;

  -- Create a small test group with capacity 2
  INSERT INTO course_groups (group_id, name, max_capacity, registered_count, reserved_count, is_active)
    VALUES (v_group, 'TEST GROUP', 2, 0, 0, true)
    ON CONFLICT DO NOTHING;

  -- Reserve two spots
  reg1 := reserve_spot(v_group, 'a.test@example.com', 'A Test', '05551111');
  reg2 := reserve_spot(v_group, 'b.test@example.com', 'B Test', '05552222');

  SELECT reserved_count INTO rc_reserved FROM course_groups WHERE group_id = v_group;
  IF rc_reserved <> 2 THEN
    RAISE EXCEPTION 'Expected reserved_count 2 after two reservations, got %', rc_reserved;
  END IF;

  -- Confirm payment for first registration
  PERFORM confirm_payment(reg1);
  SELECT registered_count, reserved_count INTO rc_registered, rc_reserved FROM course_groups WHERE group_id = v_group;
  IF rc_registered <> 1 THEN
    RAISE EXCEPTION 'Expected registered_count 1 after confirm, got %', rc_registered;
  END IF;
  IF rc_reserved <> 1 THEN
    RAISE EXCEPTION 'Expected reserved_count 1 after confirm, got %', rc_reserved;
  END IF;

  -- Cancel the second reservation
  PERFORM cancel_reservation(reg2);
  SELECT reserved_count INTO rc_reserved FROM course_groups WHERE group_id = v_group;
  IF rc_reserved <> 0 THEN
    RAISE EXCEPTION 'Expected reserved_count 0 after cancel, got %', rc_reserved;
  END IF;

  -- Cleanup
  DELETE FROM registrations WHERE group_id = v_group;
  DELETE FROM course_groups WHERE group_id = v_group;

  RAISE NOTICE 'Procedure tests passed.';
END
$$;
