-- Gruplar tablosu
CREATE TABLE course_groups (
    group_id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    name text NOT NULL,
    max_capacity smallint NOT NULL DEFAULT 10,
    registered_count smallint NOT NULL DEFAULT 0,
    reserved_count smallint NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT TRUE,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

-- Kayıtlar tablosu
CREATE TABLE registrations (
    registration_id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    group_id uuid NOT NULL REFERENCES course_groups(group_id),
    email text NOT NULL,
    full_name text NOT NULL,
    phone text NOT NULL,
    status text NOT NULL CHECK (status IN ('RESERVED', 'PAID', 'CANCELLED')),
    reservation_expiry timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_active_registration UNIQUE (email, group_id)
);

-- Updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_course_groups_updated_at
    BEFORE UPDATE ON course_groups
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_registrations_updated_at
    BEFORE UPDATE ON registrations
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();