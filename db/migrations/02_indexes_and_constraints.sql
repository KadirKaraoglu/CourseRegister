-- Dosya: 02_indexes_and_constraints.sql
-- Açıklama: Ek indeksler ve kısıtlamalar

-- Email formatı doğrulama fonksiyonu
CREATE OR REPLACE FUNCTION is_valid_email(email TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN email ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$';
END;
$$ LANGUAGE plpgsql;

-- Telefon formatı doğrulama fonksiyonu (TR: 10 haneli numara)
CREATE OR REPLACE FUNCTION is_valid_phone(phone TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN phone ~ '^[0-9]{10}$';
END;
$$ LANGUAGE plpgsql;

-- Email ve telefon doğrulama kısıtlamaları
ALTER TABLE registrations 
    ADD CONSTRAINT valid_email 
    CHECK (is_valid_email(email));

ALTER TABLE registrations 
    ADD CONSTRAINT valid_phone 
    CHECK (is_valid_phone(phone));

-- Full text search için GIN indeks
CREATE INDEX registrations_full_text_idx ON registrations 
    USING gin(to_tsvector('turkish', full_name || ' ' || email));

-- Reservation expiry kontrolü için kısıtlama
ALTER TABLE registrations 
    ADD CONSTRAINT valid_reservation_expiry 
    CHECK (
        CASE 
            WHEN status = 'RESERVED' THEN reservation_expiry > created_at
            ELSE TRUE
        END
    );

-- Composite index for performance
CREATE INDEX idx_registrations_group_status ON registrations(group_id, status);

-- Partial index for active registrations
CREATE INDEX idx_active_registrations ON registrations(email, group_id) 
    WHERE status = 'PAID';

-- Status transition kontrolü için trigger
CREATE OR REPLACE FUNCTION validate_status_transition()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status = 'CANCELLED' AND NEW.status != 'CANCELLED' THEN
        RAISE EXCEPTION 'Cannot change status from CANCELLED';
    END IF;
    
    IF OLD.status = 'PAID' AND NEW.status != 'PAID' THEN
        RAISE EXCEPTION 'Cannot change status from PAID';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_status_transition
    BEFORE UPDATE OF status ON registrations
    FOR EACH ROW
    EXECUTE FUNCTION validate_status_transition();