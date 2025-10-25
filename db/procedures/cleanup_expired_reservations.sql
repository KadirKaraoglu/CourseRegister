-- Zaman aşımına uğramış rezervasyonları tespit eden ve iptal eden stored procedure
CREATE OR REPLACE PROCEDURE cleanup_expired_reservations()
LANGUAGE plpgsql
AS $$
DECLARE
    expired_registration RECORD;
BEGIN
    -- Süresi dolmuş ve hala RESERVED durumunda olan kayıtları bul
    FOR expired_registration IN 
        SELECT registration_id, group_id 
        FROM registrations 
        WHERE status = 'RESERVED' 
        AND reservation_expiry < NOW()
    LOOP
        -- Her kayıt için cancel_reservation prosedürünü çağır
        CALL cancel_reservation(
            expired_registration.registration_id,
            'timeout'::text
        );
    END LOOP;
END;
$$;