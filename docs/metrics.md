# Metrik İzleme ve Başarı Kriterleri

Bu dokümantasyon, YZESKS (Yapay Zeka Eğitim Kayıt Sistemi) için metrik izleme ve başarı kriterlerini detaylandırır.

## 1. İzlenen Metrikler

### 1.1 Kayıt Hızı ve Kullanıcı Deneyimi
- **3 Tıklama Kuralı Uyumu**
  - Hedef: Kullanıcıların %90'ı
  - Ölçüm: `duration_ms` bazlı işlem süreleri
  - Dashboard: "İşlem Süresi Dağılımı" raporu

### 1.2 Kontenjan Doğruluğu
- **Rezervasyon Tutarlılığı**
  - `registered_count + reserved_count <= max_capacity`
  - Anlık izleme: "Grup Bazlı Doluluk" raporu
  - Hata durumları: "Hata Analizi" raporu

### 1.3 Dönüşüm Oranı
- **Kayıt -> Ödeme Dönüşümü**
  - Hedef: > %50 dönüşüm
  - Günlük/Haftalık/Aylık trend
  - "Dönüşüm Oranı" raporu

## 2. Event Modeli

### 2.1 Event Tipleri
- `reserved`: Rezervasyon yapıldı
- `paid`: Ödeme tamamlandı
- `cancelled`: İptal edildi

### 2.2 İzlenen Detaylar
- İşlem süreleri (ms)
- Hata tipleri ve oranları
- İptal nedenleri
- Grup doluluk oranları

## 3. Dashboard ve Raporlar

### 3.1 Anlık Metrikler
- Aktif rezervasyon sayısı
- Grup doluluk oranları
- Son 24 saat işlem hacmi

### 3.2 Trend Analizleri
- Günlük dönüşüm oranları
- Haftalık kayıt/iptal trendi
- Hata tipi dağılımı

### 3.3 Performans Metrikleri
- P95 işlem süreleri
- Başarılı/Başarısız işlem oranı
- Timeout ve hata dağılımı

## 4. Alarm ve Uyarılar

### 4.1 Kritik Durumlar
- Yüksek iptal oranı (>30%)
- Düşük dönüşüm (<40%)
- Uzun işlem süreleri (>5sn)

### 4.2 Bildirim Kanalları
- Slack entegrasyonu
- E-posta bildirimleri
- Dashboard göstergeleri

## 5. Raporlama Döngüsü

### 5.1 Günlük Rapor
- Toplam işlem hacmi
- Dönüşüm oranları
- Hata özetleri

### 5.2 Haftalık Analiz
- Trend karşılaştırmaları
- Performans değerlendirmesi
- Optimizasyon önerileri

### 5.3 Aylık Değerlendirme
- KPI karşılaştırması
- Uzun vadeli trendler
- Kapasite planlaması

## 6. Metrik Toplama Best Practices

### 6.1 Veri Toplama
- Her işlem için timestamp
- Detaylı hata logları
- İşlem süresi ölçümü

### 6.2 Veri Saklama
- 30 günlük detaylı veri
- 1 yıllık özet veriler
- Düzenli backup

### 6.3 Veri Analizi
- Günlük trendler
- Anomali tespiti
- Pattern analizi