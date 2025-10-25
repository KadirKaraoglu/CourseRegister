-- Dosya: 04_procedure_tests.sql
-- Açıklama: Stored procedure test senaryoları

-- Test Verisi Hazırlama
CREATE OR REPLACE PROCEDURE setup_test_data()
LANGUAGE plpgsql
AS $$
BEGIN
    -- Test grubu oluştur
    INSERT INTO course_groups (
        group_id,
        name,
        max_capacity,
        registered_count,
        reserved_count,
        is_active
    ) VALUES (
        'e99a2fd1-8f2a-4fe1-b90c-3e6c28a85e89',
        'Test Grubu 2025',
        10,
        0,
        0,
        true
    );
END;
$$;

-- Test 1: Başarılı Rezervasyon
DO $$
DECLARE
    v_group_id UUID := 'e99a2fd1-8f2a-4fe1-b90c-3e6c28a85e89';
BEGIN
    CALL reserve_spot(
        v_group_id,
        'test@example.com',
        'Test User',
        '5551234567'
    );
    
    -- Kontroller
    ASSERT (
        SELECT reserved_count = 1 
        FROM course_groups 
        WHERE group_id = v_group_id
    ), 'reserved_count artmadı';
    
    ASSERT (
        SELECT status = 'RESERVED' 
        FROM registrations 
        WHERE group_id = v_group_id
    ), 'kayıt durumu yanlış';
END;
$$;

-- Test 2: Aynı Email ile Tekrar Rezervasyon (Hata Beklenir)
DO $$
DECLARE
    v_group_id UUID := 'e99a2fd1-8f2a-4fe1-b90c-3e6c28a85e89';
BEGIN
    BEGIN
        CALL reserve_spot(
            v_group_id,
            'test@example.com',
            'Test User 2',
            '5557654321'
        );
        RAISE EXCEPTION 'Beklenen hata oluşmadı';
    EXCEPTION WHEN OTHERS THEN
        -- Hata bekleniyor
    END;
END;
$$;

-- Test 3: Başarılı Ödeme Onayı
DO $$
DECLARE
    v_registration_id UUID;
BEGIN
    -- Test kaydının ID'sini al
    SELECT registration_id INTO v_registration_id
    FROM registrations
    WHERE email = 'test@example.com';
    
    CALL confirm_payment(v_registration_id);
    
    -- Kontroller
    ASSERT (
        SELECT status = 'PAID'
        FROM registrations
        WHERE registration_id = v_registration_id
    ), 'ödeme durumu güncellenmedi';
    
    ASSERT (
        SELECT reserved_count = 0 AND registered_count = 1
        FROM course_groups
        WHERE group_id = 'e99a2fd1-8f2a-4fe1-b90c-3e6c28a85e89'
    ), 'grup sayaçları güncellenmedi';
END;
$$;

-- Test 4: Rezervasyon İptali
DO $$
DECLARE
    v_group_id UUID := 'e99a2fd1-8f2a-4fe1-b90c-3e6c28a85e89';
BEGIN
    -- Yeni test rezervasyonu
    CALL reserve_spot(
        v_group_id,
        'cancel@example.com',
        'Cancel Test',
        '5559876543'
    );
    
    -- İptal et
    CALL cancel_reservation(
        (SELECT registration_id 
         FROM registrations 
         WHERE email = 'cancel@example.com')
    );
    
    -- Kontroller
    ASSERT (
        SELECT status = 'CANCELLED'
        FROM registrations
        WHERE email = 'cancel@example.com'
    ), 'iptal durumu güncellenmedi';
    
    ASSERT (
        SELECT reserved_count = 0
        FROM course_groups
        WHERE group_id = v_group_id
    ), 'rezervasyon sayısı güncellenmedi';
END;
$$;

-- Test 5: Süresi Dolmuş Rezervasyonları Temizle
DO $$
DECLARE
    v_group_id UUID := 'e99a2fd1-8f2a-4fe1-b90c-3e6c28a85e89';
BEGIN
    -- Süresi dolmuş test rezervasyonu oluştur
    INSERT INTO registrations (
        group_id,
        email,
        full_name,
        phone,
        status,
        reservation_expiry
    ) VALUES (
        v_group_id,
        'expired@example.com',
        'Expired Test',
        '5553333333',
        'RESERVED',
        CURRENT_TIMESTAMP - INTERVAL '1 hour'
    );
    
    -- Cleanup çalıştır
    CALL cleanup_expired_reservations();
    
    -- Kontroller
    ASSERT (
        SELECT status = 'CANCELLED'
        FROM registrations
        WHERE email = 'expired@example.com'
    ), 'süresi dolmuş rezervasyon iptal edilmedi';
END;
$$;

-- Test verilerini temizle
CREATE OR REPLACE PROCEDURE cleanup_test_data()
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM registrations 
    WHERE email IN ('test@example.com', 'cancel@example.com', 'expired@example.com');
    
    DELETE FROM course_groups 
    WHERE group_id = 'e99a2fd1-8f2a-4fe1-b90c-3e6c28a85e89';
END;
$$;