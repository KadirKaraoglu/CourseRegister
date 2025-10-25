# Veritabanı Migrasyonları

Bu klasör, YZESKS veritabanı şeması ve migrasyonları için gerekli SQL scriptlerini içerir.

## Migrasyon Dosyaları

### 01_initial_schema.sql
- Ana tablo yapıları (`course_groups` ve `registrations`)
- Temel indeksler ve kısıtlamalar
- Trigger ve yardımcı fonksiyonlar

### 02_indexes_and_constraints.sql
- Ek indeksler ve kısıtlamalar
- Email ve telefon doğrulama fonksiyonları
- Full text search indeksleri
- Status geçiş kontrolleri

## Nasıl Çalıştırılır

1. Supabase projenize bağlanın:
```bash
supabase link --project-ref your-project-ref
```

2. Migrasyonları çalıştırın:
```bash
supabase db reset
```

## Doğrulama Sorguları

Migrasyonların başarılı olduğunu doğrulamak için:

```sql
-- Tablo yapılarını kontrol et
\d course_groups
\d registrations

-- İndeksleri kontrol et
\di

-- Constraint'leri kontrol et
\d+ course_groups
\d+ registrations

-- Trigger'ları kontrol et
\dft *
```

## Dikkat Edilmesi Gerekenler

1. Migration sırasında veri kaybı olmaması için yedek alın
2. Prod ortamında çalıştırmadan önce test ortamında deneyin
3. Büyük tablolarda indeks oluşturma işlemi zaman alabilir