# Güvenlik, Doğrulama ve Rate Limiting Spesifikasyonu

## 1. Input Validation Kuralları

### 1.1 Frontend Doğrulamalar
```javascript
const validationRules = {
  // Kişisel Bilgiler
  fullName: {
    minLength: 5,
    maxLength: 100,
    pattern: "^[a-zA-ZğüşıöçĞÜŞİÖÇ ]+$",
    required: true
  },
  email: {
    pattern: "^[^@]+@[^@]+\\.[^@]+$",
    maxLength: 255,
    required: true
  },
  phone: {
    pattern: "^[0-9]{10}$", // 5XX XXX XXXX formatı
    required: true
  }
}
```

### 1.2 Backend Doğrulamalar (Stored Procedures)
```sql
-- Email kontrol fonksiyonu
CREATE OR REPLACE FUNCTION validate_email(email text)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN email ~ '^[^@]+@[^@]+\.[^@]+$';
END;
$$ LANGUAGE plpgsql;

-- Telefon kontrol fonksiyonu
CREATE OR REPLACE FUNCTION validate_phone(phone text)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN phone ~ '^[0-9]{10}$';
END;
$$ LANGUAGE plpgsql;
```

## 2. Rate Limiting Stratejisi

### 2.1 IP Bazlı Rate Limiting
- n8n webhook gateway üzerinde:
  - 60 saniyede maksimum 10 istek
  - 24 saatte maksimum 100 istek
  - IP bazlı takip ve limit

### 2.2 Email Bazlı Rate Limiting
- Aynı email adresi ile:
  - 24 saatte maksimum 3 rezervasyon denemesi
  - 1 saatte maksimum 1 başarılı rezervasyon

### 2.3 CAPTCHA Entegrasyonu
- Google reCAPTCHA v3 entegrasyonu
- Score threshold: 0.5
- Uygulama noktaları:
  1. Kayıt formu gönderimi
  2. Ödeme başlatma

## 3. Veri Gizliliği ve GDPR Uyumluluğu

### 3.1 Toplanan Veriler
- Ad Soyad
- Email
- Telefon
- IP Adresi (rate limiting için)
- İşlem zaman damgaları

### 3.2 Veri Saklama Süreleri
- Başarılı kayıtlar: 5 yıl
- İptal edilen kayıtlar: 30 gün
- Rate limit verileri: 24 saat
- IP logları: 7 gün

### 3.3 Veri Hakları
- Silme (Right to be forgotten)
- Erişim (Data access)
- Düzeltme (Data correction)
- Taşınabilirlik (Data portability)

## 4. Güvenlik Best Practices

### 4.1 XSS Koruması
```javascript
// Frontend input sanitization
const sanitizeInput = (input) => {
  return input
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#x27;');
};
```

### 4.2 CSRF Koruması
- Double Submit Cookie Pattern
- SameSite=Strict cookie ayarı

### 4.3 HTTP Güvenlik Başlıkları
```nginx
# Nginx config
add_header X-Frame-Options "DENY";
add_header X-XSS-Protection "1; mode=block";
add_header X-Content-Type-Options "nosniff";
add_header Referrer-Policy "strict-origin";
add_header Content-Security-Policy "default-src 'self'";
```

## 5. Error Handling ve Logging

### 5.1 Hata Mesajları
- Kullanıcıya: Generic hata mesajları
- Loglama: Detaylı hata bilgileri

### 5.2 Log Formatı
```json
{
  "timestamp": "2025-10-19T10:00:00Z",
  "level": "ERROR",
  "event": "VALIDATION_FAILED",
  "component": "reserve_spot",
  "requestId": "uuid-v4",
  "error": {
    "code": "INVALID_EMAIL",
    "message": "Internal message"
  },
  "metadata": {
    "ip": "anonymized-ip",
    "userAgent": "browser-info"
  }
}
```

## 6. Monitoring ve Alerting

### 6.1 Güvenlik Metrikleri
- Rate limit ihlalleri
- Validation hataları
- CAPTCHA score dağılımı

### 6.2 Alert Kuralları
- 5 dakikada >100 rate limit ihlali
- 1 saatte >50 validation hatası
- Ortalama CAPTCHA score < 0.3