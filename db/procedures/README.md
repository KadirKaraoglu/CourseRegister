# PostgreSQL Stored Procedures

Bu klasör, YZESKS için gerekli olan stored procedure'ları ve bunların test senaryolarını içerir.

## Prosedürler

### 1. reserve_spot
Yeni bir rezervasyon oluşturur.
- Parametreler:
  - p_group_id: Grup ID
  - p_email: Email adresi
  - p_full_name: Ad soyad
  - p_phone: Telefon
- İşlemler:
  - Kontenjan kontrolü
  - Email tekrar kontrolü
  - Atomik rezervasyon işlemi
  - Grup sayaçlarının güncellenmesi

### 2. confirm_payment
Ödeme onayı ve kalıcı kayıt işlemi.
- Parametreler:
  - p_registration_id: Kayıt ID
- İşlemler:
  - Rezervasyon durumu kontrolü
  - Süre kontrolü
  - Atomik durum güncellemesi
  - Grup sayaçlarının güncellenmesi

### 3. cancel_reservation
Rezervasyon iptali.
- Parametreler:
  - p_registration_id: Kayıt ID
- İşlemler:
  - Durum kontrolü
  - Atomik iptal işlemi
  - Grup sayaçlarının güncellenmesi

### 4. cleanup_expired_reservations
Süresi dolmuş rezervasyonları temizler.
- İşlemler:
  - Süresi geçmiş kayıtları bulma
  - Her kayıt için cancel_reservation çağrısı

## Test Senaryoları

Test senaryoları `04_procedure_tests.sql` dosyasında bulunur:

1. Başarılı rezervasyon
2. Tekrar rezervasyon denemesi
3. Başarılı ödeme onayı
4. Rezervasyon iptali
5. Süresi dolmuş rezervasyonların temizlenmesi

## Çalıştırma

```bash
# Prosedürleri yükle
psql -d your_database -f 03_stored_procedures.sql

# Testleri çalıştır
psql -d your_database -f 04_procedure_tests.sql
```

## Önemli Notlar

1. Tüm işlemler transaction içinde yapılır
2. Her prosedür kendi içinde rollback mekanizmasına sahiptir
3. Race condition'ları önlemek için FOR UPDATE kullanılmıştır
4. Hata durumları detaylı mesajlarla raporlanır