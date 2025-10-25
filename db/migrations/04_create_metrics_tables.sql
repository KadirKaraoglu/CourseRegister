-- Metrik toplama için events tablosu
CREATE TABLE registration_events (
    event_id SERIAL PRIMARY KEY,
    event_type TEXT NOT NULL CHECK (event_type IN ('reserved', 'paid', 'cancelled')),
    registration_id UUID NOT NULL REFERENCES registrations(registration_id),
    group_id UUID NOT NULL REFERENCES course_groups(group_id),
    email TEXT NOT NULL,
    occurred_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    duration_ms INTEGER, -- İşlem süresi (ms)
    error_type TEXT,    -- Hata durumunda hata tipi
    details JSONB       -- Ek detaylar (ör: iptal nedeni, ödeme bilgileri)
);

-- Performans analizi için indexler
CREATE INDEX idx_events_type ON registration_events(event_type);
CREATE INDEX idx_events_occurred_at ON registration_events(occurred_at);
CREATE INDEX idx_events_registration ON registration_events(registration_id);
CREATE INDEX idx_events_group ON registration_events(group_id);

-- Event kayıt fonksiyonu
CREATE OR REPLACE FUNCTION log_registration_event(
    p_event_type TEXT,
    p_registration_id UUID,
    p_duration_ms INTEGER DEFAULT NULL,
    p_error_type TEXT DEFAULT NULL,
    p_details JSONB DEFAULT NULL
) RETURNS void AS $$
DECLARE
    v_group_id UUID;
    v_email TEXT;
BEGIN
    -- Kayıt bilgilerini al
    SELECT group_id, email INTO v_group_id, v_email
    FROM registrations
    WHERE registration_id = p_registration_id;

    -- Event'i kaydet
    INSERT INTO registration_events (
        event_type,
        registration_id,
        group_id,
        email,
        duration_ms,
        error_type,
        details
    ) VALUES (
        p_event_type,
        p_registration_id,
        v_group_id,
        v_email,
        p_duration_ms,
        p_error_type,
        p_details
    );
END;
$$ LANGUAGE plpgsql;