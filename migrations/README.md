Migrations kullanım notları

1) Bu SQL dosyaları Postgres uyumludur ve Supabase üzerinde çalıştırılabilir.
2) Lokal Postgres veya Supabase kullanıyorsanız, şu adımlarla uygulayabilirsiniz:

- psql ile:
  - psql -h <host> -U <user> -d <db> -f migrations/001_create_tables.sql
  - psql -h <host> -U <user> -d <db> -f migrations/002_seed.sql

- Supabase CLI ile (opsiyonel):
  - supabase db reset && supabase db push (kendi proje ayarlarınıza göre)

3) Notlar:
  - `gen_random_uuid()` kullanımı için `pgcrypto` extension'ını enable eden bir satır eklenmiştir.
  - `registrations` tablosunda (email, group_id) kombinasyonu unique olarak tutulmaktadır.
