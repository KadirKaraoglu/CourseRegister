-- Dosya: 01_initial_schema.sql
-- Açıklama: İlk veritabanı şeması ve tablo oluşturma

-- Enumerated types
CREATE TYPE registration_status AS ENUM ('RESERVED', 'PAID', 'CANCELLED');

-- course_groups tablosu
CREATE TABLE course_groups (
    group_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    max_capacity SMALLINT NOT NULL DEFAULT 10 
        CHECK (max_capacity > 0),
    registered_count SMALLINT NOT NULL DEFAULT 0 
        CHECK (registered_count >= 0),
    reserved_count SMALLINT NOT NULL DEFAULT 0 
        CHECK (reserved_count >= 0),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT valid_capacity CHECK (registered_count + reserved_count <= max_capacity)
);

-- registrations tablosu
CREATE TABLE registrations (
    registration_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES course_groups(group_id),
    email TEXT NOT NULL,
    full_name TEXT NOT NULL,
    phone TEXT NOT NULL,
    status registration_status NOT NULL DEFAULT 'RESERVED',
    reservation_expiry TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_active_registration UNIQUE (email, group_id, status)
);

-- İndeksler
CREATE INDEX idx_registrations_group_id ON registrations(group_id);
CREATE INDEX idx_registrations_email ON registrations(email);
CREATE INDEX idx_registrations_status ON registrations(status);
CREATE INDEX idx_registrations_expiry ON registrations(reservation_expiry) 
    WHERE status = 'RESERVED';

-- Otomatik güncelleme için trigger fonksiyonu
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggerları oluştur
CREATE TRIGGER update_course_groups_updated_at
    BEFORE UPDATE ON course_groups
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_registrations_updated_at
    BEFORE UPDATE ON registrations
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Açıklayıcı yorumlar
COMMENT ON TABLE course_groups IS 'Eğitim grupları ve kontenjan bilgileri';
COMMENT ON TABLE registrations IS 'Kullanıcı kayıtları ve rezervasyon durumları';
COMMENT ON COLUMN course_groups.group_id IS 'Grubun benzersiz kimliği';
COMMENT ON COLUMN course_groups.max_capacity IS 'Grubun maksimum kontenjanı';
COMMENT ON COLUMN course_groups.registered_count IS 'Başarılı ödeme yapmış katılımcı sayısı';
COMMENT ON COLUMN course_groups.reserved_count IS 'Ödeme bekleyen geçici rezervasyon sayısı';
COMMENT ON COLUMN registrations.status IS 'Kayıt durumu: RESERVED, PAID veya CANCELLED';
COMMENT ON COLUMN registrations.reservation_expiry IS 'Rezervasyonun geçerlilik süresi sonu';