-- Rezervasyon oluşturma prosedürü
CREATE OR REPLACE PROCEDURE reserve_spot(
    p_group_id uuid,
    p_email text,
    p_full_name text,
    p_phone text,
    INOUT p_registration_id uuid DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Grup kontrolü
    IF NOT EXISTS (
        SELECT 1 FROM course_groups 
        WHERE group_id = p_group_id 
        AND is_active = true 
        AND (registered_count + reserved_count) < max_capacity
    ) THEN
        RAISE EXCEPTION 'Grup dolu veya aktif değil';
    END IF;

    -- Aynı email ile aktif kayıt kontrolü
    IF EXISTS (
        SELECT 1 FROM registrations 
        WHERE group_id = p_group_id 
        AND email = p_email 
        AND status IN ('RESERVED', 'PAID')
    ) THEN
        RAISE EXCEPTION 'Bu email adresi ile zaten kayıt var';
    END IF;

    -- Rezervasyon oluştur
    INSERT INTO registrations (
        group_id,
        email,
        full_name,
        phone,
        status,
        reservation_expiry
    ) VALUES (
        p_group_id,
        p_email,
        p_full_name,
        p_phone,
        'RESERVED',
        CURRENT_TIMESTAMP + INTERVAL '30 minutes'
    ) RETURNING registration_id INTO p_registration_id;

    -- Rezervasyon sayacını artır
    UPDATE course_groups 
    SET reserved_count = reserved_count + 1
    WHERE group_id = p_group_id;

    COMMIT;
END;
$$;

-- Ödeme onaylama prosedürü
CREATE OR REPLACE PROCEDURE confirm_payment(
    p_registration_id uuid
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_group_id uuid;
BEGIN
    -- Kayıt kontrolü
    SELECT group_id INTO v_group_id
    FROM registrations
    WHERE registration_id = p_registration_id
    AND status = 'RESERVED'
    AND reservation_expiry > CURRENT_TIMESTAMP;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Geçerli rezervasyon bulunamadı';
    END IF;

    -- Ödeme onayı
    UPDATE registrations 
    SET status = 'PAID'
    WHERE registration_id = p_registration_id;

    -- Sayaçları güncelle
    UPDATE course_groups 
    SET 
        reserved_count = reserved_count - 1,
        registered_count = registered_count + 1
    WHERE group_id = v_group_id;

    COMMIT;
END;
$$;

-- Rezervasyon iptal prosedürü
CREATE OR REPLACE PROCEDURE cancel_reservation(
    p_registration_id uuid
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_group_id uuid;
BEGIN
    -- Kayıt kontrolü
    SELECT group_id INTO v_group_id
    FROM registrations
    WHERE registration_id = p_registration_id
    AND status = 'RESERVED';

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Geçerli rezervasyon bulunamadı';
    END IF;

    -- Rezervasyonu iptal et
    UPDATE registrations 
    SET status = 'CANCELLED'
    WHERE registration_id = p_registration_id;

    -- Rezervasyon sayacını azalt
    UPDATE course_groups 
    SET reserved_count = reserved_count - 1
    WHERE group_id = v_group_id;

    COMMIT;
END;
$$;