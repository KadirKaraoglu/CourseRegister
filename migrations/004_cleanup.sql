-- Migration: 004_cleanup.sql
-- Procedure to cancel expired reservations and free up reserved_count

CREATE OR REPLACE FUNCTION cleanup_expired_reservations()
RETURNS INTEGER AS $$
DECLARE
  v_count INT := 0;
  rec RECORD;
BEGIN
  FOR rec IN SELECT registration_id, group_id FROM registrations WHERE status = 'RESERVED' AND reservation_expiry <= now() LOOP
    PERFORM cancel_reservation(rec.registration_id);
    v_count := v_count + 1;
  END LOOP;
  RETURN v_count;
END;
$$ LANGUAGE plpgsql;

-- Optional: a simple SQL to run manually
-- SELECT cleanup_expired_reservations();
