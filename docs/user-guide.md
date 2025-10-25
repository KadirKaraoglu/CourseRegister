# YZESKS Kullanım Kılavuzu

Bu kılavuz, Yapay Zeka Eğitim Kayıt Sistemi'nin (YZESKS) kullanımı hakkında detaylı bilgi sağlar.

## 1. Sistem Özeti

YZESKS, yapay zeka eğitimlerine kayıt olmak isteyen kullanıcılara yönelik, basit ve hızlı bir kayıt sistemidir. Sistem, kullanıcıların maksimum 3 tıklama ile kayıt işlemlerini tamamlamalarını hedefler.

## 2. Kullanıcı Arayüzü

### 2.1 Ana Sayfa
- Aktif eğitim grupları listelenir
- Her grup için kontenjan durumu gösterilir (Örn: 5/10)
- "Kayıt Ol" butonları

### 2.2 Kayıt Formu
- Ad Soyad
- E-posta
- Telefon Numarası
- "Kaydı Tamamla & Ödemeye Geç" butonu

### 2.3 Ödeme Paneli
- Ödeme bilgileri girişi
- Ödeme onay butonu
- İşlem sonuç bildirimi

## 3. Kayıt Süreci

### 3.1 Adım 1: Grup Seçimi
1. Ana sayfada listelenen grupları inceleyin
2. İstediğiniz grubun "Kayıt Ol" butonuna tıklayın
3. Kontenjan doluysa buton pasif olacaktır

### 3.2 Adım 2: Bilgi Girişi
1. Ad Soyad (en az 5 karakter)
2. Geçerli bir e-posta adresi
3. 10 haneli telefon numarası
4. "Kaydı Tamamla & Ödemeye Geç" butonuna tıklayın

### 3.3 Adım 3: Ödeme
1. Ödeme bilgilerini girin
2. "Ödemeyi Onayla" butonuna tıklayın
3. Sonucu bekleyin

## 4. Önemli Bilgiler

### 4.1 Rezervasyon Süresi
- Kayıt formu doldurulduğunda 30 dakikalık rezervasyon yapılır
- Bu süre içinde ödeme yapılmazsa rezervasyon iptal olur
- Kontenjan otomatik olarak serbest bırakılır

### 4.2 İşlem Limitleri
- Aynı e-posta ile 24 saatte maksimum 3 rezervasyon
- 1 saatte maksimum 1 başarılı kayıt
- IP bazlı rate limiting uygulanır

### 4.3 Hata Durumları
- "Kontenjan Dolu": Grup kontenjanı dolmuştur
- "Rezervasyon Süresi Doldu": 30 dakika içinde ödeme yapılmadı
- "İşlem Limiti Aşıldı": Rate limit kuralları ihlal edildi

## 5. Sık Sorulan Sorular

### 5.1 Kayıt İşlemleri
**S**: Kayıt işlemini yarıda bırakırsam ne olur?
**C**: 30 dakika sonra rezervasyonunuz otomatik iptal olur.

**S**: Aynı gruba birden fazla kayıt olabilir miyim?
**C**: Hayır, her e-posta bir grup için sadece bir kayıt yapabilir.

**S**: Ödeme başarısız olursa ne yapmalıyım?
**C**: 30 dakika içinde tekrar deneyebilirsiniz.

### 5.2 Teknik Konular
**S**: Tarayıcım destekleniyor mu?
**C**: Modern tarayıcıların (Chrome, Firefox, Safari, Edge) son sürümleri desteklenir.

**S**: İnternet bağlantım kesilirse ne olur?
**C**: Rezervasyon süresi dolmadıysa tekrar bağlanıp kaldığınız yerden devam edebilirsiniz.

### 5.3 Güvenlik
**S**: Bilgilerim güvende mi?
**C**: Tüm veriler GDPR uyumlu şekilde işlenir ve saklanır.

**S**: CAPTCHA neden var?
**C**: Otomatik botları engellemek ve sistemi korumak için kullanılır.

## 6. İletişim ve Destek

### 6.1 Teknik Destek
- E-posta: support@yzesks.com
- Yanıt süresi: 1-2 iş günü

### 6.2 Acil Durumlar
- Sistem hatası bildirimi: error@yzesks.com
- 7/24 yanıt

## 7. Yasal Bilgiler

### 7.1 Kişisel Verilerin Korunması
- KVKK ve GDPR uyumlu veri işleme
- 30 günlük veri saklama politikası
- Veri silme hakkı

### 7.2 Kullanım Koşulları
- Adil kullanım politikası
- Rate limiting kuralları
- İptal ve iade koşulları