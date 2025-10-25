# YZESKS Operasyon Runbook

Bu runbook, Yapay Zeka Eğitim Kayıt Sistemi'nin operasyonel yönetimi için gerekli tüm prosedürleri içerir.

## 1. Günlük Operasyonlar

### 1.1 Sağlık Kontrolü
```sql
-- Kontenjan tutarlılığı kontrolü
SELECT group_id, name,
       max_capacity, 
       registered_count,
       reserved_count,
       (registered_count + reserved_count) as total,
       CASE WHEN registered_count + reserved_count > max_capacity 
            THEN 'HATA'
            ELSE 'OK'
       END as status
FROM course_groups;
```

### 1.2 Rezervasyon Temizliği
```sql
-- Süresi geçmiş rezervasyonları temizle
SELECT cancel_reservation(registration_id)
FROM registrations 
WHERE status = 'RESERVED' 
AND reservation_expiry < NOW();
```

### 1.3 Metrik Kontrolü
- Supabase Dashboard -> Metrics -> Registration Speed
- n8n -> Workflows -> Metric Collector -> Executions

## 2. Acil Durum Prosedürleri

### 2.1 Yüksek Hata Oranı
1. n8n webhook loglarını kontrol et
2. Supabase stored procedure hatalarını incele
3. Rate limit durumunu kontrol et
4. Gerekirse yeni kayıtları geçici olarak durdur:
```sql
UPDATE course_groups SET is_active = false WHERE is_active = true;
```

### 2.2 Kontenjan Tutarsızlığı
1. Tüm aktif grupları dondur
```sql
BEGIN;
  UPDATE course_groups SET is_active = false;
  -- Tutarlılık kontrolü
  SELECT * FROM validate_group_capacities();
  -- Düzeltme gerekiyorsa:
  SELECT fix_group_capacities();
COMMIT;
```

### 2.3 Ödeme Sistemi Sorunları
1. Mock ödeme servisini yeniden başlat
2. Bekleyen ödemeleri iptal et
3. Frontend'de ödeme butonunu devre dışı bırak

## 3. Bakım Prosedürleri

### 3.1 Veritabanı Bakımı
```sql
-- İndeks bakımı
VACUUM ANALYZE course_groups;
VACUUM ANALYZE registrations;

-- İstatistik güncelleme
ANALYZE course_groups;
ANALYZE registrations;
```

### 3.2 Log Rotasyonu
```bash
# n8n loglarını arşivle
find /var/log/n8n -name "*.log" -mtime +30 -exec gzip {} \;

# Supabase audit loglarını temizle
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "
DELETE FROM audit.logged_actions WHERE action_tstamp_tx < now() - interval '90 days';"
```

### 3.3 Performans İzleme
```sql
-- Yavaş sorguları bul
SELECT * FROM pg_stat_statements 
ORDER BY mean_time DESC 
LIMIT 10;

-- Aktif bağlantıları kontrol et
SELECT * FROM pg_stat_activity 
WHERE state != 'idle';
```

## 4. Backup ve Recovery

### 4.1 Manuel Backup
```bash
# Veritabanı yedeği
pg_dump -h $DB_HOST -U $DB_USER -d $DB_NAME > backup_$(date +%Y%m%d).sql

# n8n workflow yedeği
n8n export:workflow --all --output workflows/backup_$(date +%Y%m%d)/
```

### 4.2 Recovery Prosedürü
1. Servisleri durdur
2. Yedekten geri yükle
3. Tutarlılık kontrolü
4. Servisleri başlat

## 5. Ölçekleme ve Kapasite

### 5.1 Yeni Grup Ekleme
```sql
INSERT INTO course_groups 
(name, max_capacity, registered_count, reserved_count, is_active)
VALUES 
('Yeni Grup 2026', 10, 0, 0, true);
```

### 5.2 Rate Limit Ayarları
```nginx
# Nginx rate limit güncelleme
limit_req_zone $binary_remote_addr zone=one:10m rate=10r/s;
```

## 6. Güvenlik Prosedürleri

### 6.1 Şüpheli Aktivite Kontrolü
```sql
-- Hızlı rezervasyon denemeleri
SELECT email, COUNT(*) 
FROM registrations 
WHERE created_at > NOW() - INTERVAL '1 hour'
GROUP BY email 
HAVING COUNT(*) > 3;
```

### 6.2 IP Bazlı Engelleme
1. Şüpheli IP'leri tespit et
2. Nginx blacklist'e ekle
3. Rate limit kurallarını güncelle

## 7. Monitoring ve Alerting

### 7.1 Metrik Dashboards
- Kayıt Hızı: `/metrics/registration-speed`
- Dönüşüm: `/metrics/conversion-rate`
- Hata Oranı: `/metrics/error-rate`

### 7.2 Alert Kuralları
- Yüksek Hata: >10% / 5dk
- Düşük Dönüşüm: <40% / saat
- Rate Limit: >100 ihlal / dk

## 8. Veri Yönetimi

### 8.1 Veri Temizliği
```sql
-- 30 günden eski iptal kayıtlarını temizle
DELETE FROM registrations 
WHERE status = 'CANCELLED' 
AND updated_at < NOW() - INTERVAL '30 days';
```

### 8.2 GDPR Veri Silme
```sql
-- Belirli bir kullanıcının verilerini sil
BEGIN;
  DELETE FROM registrations WHERE email = 'user@example.com';
  -- Audit log oluştur
  INSERT INTO gdpr_deletion_log (email, deleted_at) 
  VALUES ('user@example.com', NOW());
COMMIT;
```