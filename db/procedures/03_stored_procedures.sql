-- Dosya: 03_stored_procedures.sql
-- Açıklama: Atomik işlemler için stored procedure'lar

-- reserve_spot: Yeni rezervasyon oluşturma
CREATE OR REPLACE PROCEDURE reserve_spot(
    p_group_id UUID,
    p_email TEXT,
    p_full_name TEXT,
    p_phone TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_expiry TIMESTAMP WITH TIME ZONE;
BEGIN
    -- Transaction başlat
    BEGIN
        -- Grup aktif ve kontenjan müsait mi kontrol et
        IF NOT EXISTS (
            SELECT 1 FROM course_groups 
            WHERE group_id = p_group_id 
            AND is_active = true 
            AND (registered_count + reserved_count) < max_capacity
            FOR UPDATE
        ) THEN
            RAISE EXCEPTION 'Grup dolu veya aktif değil';
        END IF;

        -- Email adresi ile aktif kayıt var mı kontrol et
        IF EXISTS (
            SELECT 1 FROM registrations 
            WHERE group_id = p_group_id 
            AND email = p_email 
            AND status IN ('RESERVED', 'PAID')
        ) THEN
            RAISE EXCEPTION 'Bu email adresi ile zaten kayıt mevcut';
        END IF;

        -- Rezervasyon süresi hesapla (30 dakika)
        v_expiry := CURRENT_TIMESTAMP + INTERVAL '30 minutes';

        -- Yeni rezervasyon kaydı oluştur
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
            v_expiry
        );

        -- Rezerve sayısını artır
        UPDATE course_groups 
        SET reserved_count = reserved_count + 1
        WHERE group_id = p_group_id;

        -- Transaction commit
        COMMIT;
    EXCEPTION 
        WHEN OTHERS THEN
            -- Hata durumunda rollback
            ROLLBACK;
            RAISE;
    END;
END;
$$;

-- confirm_payment: Ödeme onayı ve kalıcı kayıt
CREATE OR REPLACE PROCEDURE confirm_payment(
    p_registration_id UUID
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_group_id UUID;
    v_status TEXT;
BEGIN
    -- Transaction başlat
    BEGIN
        -- Kayıt bilgilerini al
        SELECT group_id, status INTO v_group_id, v_status
        FROM registrations
        WHERE registration_id = p_registration_id
        FOR UPDATE;

        -- Kayıt durumunu kontrol et
        IF v_status != 'RESERVED' THEN
            RAISE EXCEPTION 'Geçersiz kayıt durumu: %', v_status;
        END IF;

        -- Rezervasyon süresini kontrol et
        IF EXISTS (
            SELECT 1 FROM registrations
            WHERE registration_id = p_registration_id
            AND reservation_expiry < CURRENT_TIMESTAMP
        ) THEN
            RAISE EXCEPTION 'Rezervasyon süresi dolmuş';
        END IF;

        -- Kayıt durumunu güncelle
        UPDATE registrations
        SET status = 'PAID',
            updated_at = CURRENT_TIMESTAMP
        WHERE registration_id = p_registration_id;

        -- Grup sayaçlarını güncelle
        UPDATE course_groups
        SET reserved_count = reserved_count - 1,
            registered_count = registered_count + 1
        WHERE group_id = v_group_id;

        -- Transaction commit
        COMMIT;
    EXCEPTION 
        WHEN OTHERS THEN
            -- Hata durumunda rollback
            ROLLBACK;
            RAISE;
    END;
END;
$$;

-- cancel_reservation: Rezervasyon iptali
CREATE OR REPLACE PROCEDURE cancel_reservation(
    p_registration_id UUID
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_group_id UUID;
    v_status TEXT;
BEGIN
    -- Transaction başlat
    BEGIN
        -- Kayıt bilgilerini al
        SELECT group_id, status INTO v_group_id, v_status
        FROM registrations
        WHERE registration_id = p_registration_id
        FOR UPDATE;

        -- Sadece RESERVED durumundaki kayıtlar iptal edilebilir
        IF v_status != 'RESERVED' THEN
            RAISE EXCEPTION 'Sadece RESERVED durumundaki kayıtlar iptal edilebilir';
        END IF;

        -- Kayıt durumunu güncelle
        UPDATE registrations
        SET status = 'CANCELLED',
            updated_at = CURRENT_TIMESTAMP
        WHERE registration_id = p_registration_id;

        -- Grup rezervasyon sayısını azalt
        UPDATE course_groups
        SET reserved_count = reserved_count - 1
        WHERE group_id = v_group_id;

        -- Transaction commit
        COMMIT;
    EXCEPTION 
        WHEN OTHERS THEN
            -- Hata durumunda rollback
            ROLLBACK;
            RAISE;
    END;
END;
$$;

-- cleanup_expired_reservations: Süresi dolmuş rezervasyonları temizle
CREATE OR REPLACE PROCEDURE cleanup_expired_reservations()
LANGUAGE plpgsql
AS $$
DECLARE
    v_expired_registration RECORD;
BEGIN
    -- Her süresi geçmiş rezervasyon için döngü
    FOR v_expired_registration IN 
        SELECT registration_id
        FROM registrations
        WHERE status = 'RESERVED'
        AND reservation_expiry < CURRENT_TIMESTAMP
        FOR UPDATE
    LOOP
        -- Her kayıt için cancel_reservation prosedürünü çağır
        CALL cancel_reservation(v_expired_registration.registration_id);
    END LOOP;
END;
$$;

-- Yardımcı fonksiyonlar
CREATE OR REPLACE FUNCTION get_group_status(p_group_id UUID)
RETURNS TABLE (
    available_spots INTEGER,
    reserved_spots INTEGER,
    is_full BOOLEAN,
    is_active BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (max_capacity - (registered_count + reserved_count)) as available_spots,
        reserved_count as reserved_spots,
        ((registered_count + reserved_count) >= max_capacity) as is_full,
        is_active
    FROM course_groups
    WHERE group_id = p_group_id;
END;
$$;