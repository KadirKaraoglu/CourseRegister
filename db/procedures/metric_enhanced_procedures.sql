-- Rezervasyon prosedürüne metrik toplama ekle
CREATE OR REPLACE PROCEDURE reserve_spot(
    p_group_id UUID,
    p_email TEXT,
    OUT p_registration_id UUID
) AS $$
DECLARE
    start_time TIMESTAMPTZ;
    end_time TIMESTAMPTZ;
BEGIN
    start_time := clock_timestamp();
    
    -- Mevcut rezervasyon mantığı...
    -- [Varolan kod buraya gelecek]
    
    end_time := clock_timestamp();
    
    -- Metrikleri kaydet
    PERFORM log_registration_event(
        'reserved',
        p_registration_id,
        EXTRACT(MILLISECONDS FROM (end_time - start_time))::INTEGER,
        NULL,
        jsonb_build_object('email', p_email)
    );
END;
$$ LANGUAGE plpgsql;

-- Ödeme onay prosedürüne metrik toplama ekle
CREATE OR REPLACE PROCEDURE confirm_payment(
    p_registration_id UUID,
    p_transaction_id TEXT
) AS $$
DECLARE
    start_time TIMESTAMPTZ;
    end_time TIMESTAMPTZ;
BEGIN
    start_time := clock_timestamp();
    
    -- Mevcut ödeme onay mantığı...
    -- [Varolan kod buraya gelecek]
    
    end_time := clock_timestamp();
    
    -- Metrikleri kaydet
    PERFORM log_registration_event(
        'paid',
        p_registration_id,
        EXTRACT(MILLISECONDS FROM (end_time - start_time))::INTEGER,
        NULL,
        jsonb_build_object('transaction_id', p_transaction_id)
    );
END;
$$ LANGUAGE plpgsql;

-- İptal prosedürüne metrik toplama ekle
CREATE OR REPLACE PROCEDURE cancel_reservation(
    p_registration_id UUID,
    p_reason TEXT
) AS $$
DECLARE
    start_time TIMESTAMPTZ;
    end_time TIMESTAMPTZ;
BEGIN
    start_time := clock_timestamp();
    
    -- Mevcut iptal mantığı...
    -- [Varolan kod buraya gelecek]
    
    end_time := clock_timestamp();
    
    -- Metrikleri kaydet
    PERFORM log_registration_event(
        'cancelled',
        p_registration_id,
        EXTRACT(MILLISECONDS FROM (end_time - start_time))::INTEGER,
        CASE 
            WHEN p_reason = 'timeout' THEN 'timeout'
            WHEN p_reason = 'payment_failed' THEN 'payment_failure'
            ELSE 'user_cancelled'
        END,
        jsonb_build_object('reason', p_reason)
    );
END;
$$ LANGUAGE plpgsql;