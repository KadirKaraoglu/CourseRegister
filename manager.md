# Yapay Zeka Eğitim Kayıt Sistemi - Görev Listesi (manager.md)

Bu dosya, PRD'de belirtilen gereksinimler doğrultusunda oluşturulmuş ana görevleri ve alt-görevleri, her birinin durumunu ve bağımlılıklarını içerir. Her görev numaralandırılmıştır; alt görevler ilgili ana görevin altında 1.1, 1.2... şeklinde listelenmiştir.

Not: Durumlar Türkçe olarak verilmiştir: "Başlamadı", "Devam Ediyor", "Tamamlandı".

---

1) manager.md oluşturma ve task çıkarımı
   - Açıklama: PRD dokümanındaki tüm gereksinimleri okuyup proje görevlerini ve alt görevlerini numaralandırarak belirle. Bu dosyanın oluşturulması.
   - Alt görevler:
     1.1) PRD taraması ve gereksinimlerin özetlenmesi
     1.2) Yüksek seviyeli görevlerin ve bağımlılıkların çıkarılması
     1.3) `manager.md` dosyasının oluşturulması ve commit edilebilir hale getirilmesi
   - Status: Devam Ediyor
   - Bağımlılıklar: Yok

2) Proje başlangıç yapılandırması
   - Açıklama: Repo temel dosyalarının oluşturulması ve geliştirme ortamı talimatları.
   - Alt görevler:
     2.1) `README.md` oluşturma (kurulum ve geliştirme yönergeleri)
     2.2) `.gitignore` ekleme
     2.3) Geliştirme ortamı notları (Node/Python/DB sürümleri)
     2.4) (Opsiyonel) Basit CI pipeline iskeleti ekleme
  - Status: Tamamlandı
   - Bağımlılıklar: 1

3) Veri modeli ve migrations
   - Açıklama: Supabase(Postgres) için veritabanı şeması ve migration scriptlerinin hazırlanması.
   - Alt görevler:
     3.1) `course_groups` tablosunu tanımlama (group_id, name, max_capacity, registered_count, reserved_count, is_active)
     3.2) `registrations` tablosunu tanımlama (registration_id, group_id, email, status, reservation_expiry)
     3.3) Gerekli index ve constraint'leri ekleme (foreign key, unique email)
     3.4) Migration scriptlerini (SQL) hazırlama ve dokümante etme
  - Status: Tamamlandı
   - Bağımlılıklar: 2

4) PostgreSQL Stored Procedures (atomik işlemler)
   - Açıklama: Kritik yazma işlemlerini atomik olarak gerçekleştirecek stored procedure'ların geliştirilmesi.
   - Alt görevler:
     4.1) `reserve_spot` procedure: rezervasyon yaratma (reserved_count +1, registrations 'RESERVED')
     4.2) `confirm_payment` procedure: ödeme onayı (registered_count +1, reserved_count -1, registrations.status -> 'PAID')
     4.3) `cancel_reservation` procedure: iptal/timeout (reserved_count -1, registrations.status -> 'CANCELLED')
     4.4) Transaction ve concurrency testleri (race condition senaryoları)
   - Status: Tamamlandı
   - Bağımlılıklar: 3

5) n8n iş akışları (Gateway ve Dispatcher)
   - Açıklama: Tüm ön yüz isteklerini tek bir webhook üzerinden yönetecek dispatcher ve action bazlı iş akışları.
   - Alt görevler:
     5.1) Tek bir webhook (dispatcher) oluşturma
     5.2) Dispatcher içinde action switch: `reserve_spot`, `confirm_payment`, `cancel_reservation`
     5.3) Her action için ilgili stored procedure çağrılarını ekleme
     5.4) Rezervasyon süre aşımları için n8n scheduler/timer node kurulumu
   - Status: Tamamlandı
   - Bağımlılıklar: 4

6) Frontend SPA (HTML5 + Tailwind + Vanilla JS)
   - Açıklama: Tek sayfa uygulaması olarak kullanıcı akışının (3 tıklama) gerçekleştirileceği ön yüz.
   - Alt görevler:
     6.1) Ana sayfa: grup listeleme ve anlık kontenjan gösterimi (örn: 5/10)
     6.2) Dinamik açılan kayıt formu (Ad Soyad, E-posta, Telefon)
     6.3) Form gönderimi -> n8n dispatcher'a `reserve_spot` action gönderimi (Tıklama 2)
     6.4) Ödeme paneli mock'u ve frontend doğrulamaları (Tıklama 3)
     6.5) UX: Kontenjan doluysa butonun pasif hale gelmesi ve kullanıcı bilgilendirme
   - Status: Başlamadı
   - Bağımlılıklar: 5

7) Mock ödeme entegrasyonu ve doğrulama
   - Açıklama: Gerçek ödeme entegrasyonu dışındadır; başarı/başarısız/timeout senaryolarını simüle eden modül.
   - Alt görevler:
     7.1) Ödeme simülatörü servisinin hazırlanması (başarılı, başarısız, timeout)
     7.2) Frontend'de ödeme sonucu notify (n8n dispatcher'a `confirm_payment` veya `cancel_reservation` gönderimi)
     7.3) Edge-case testleri: network error, double-submit, tekrar ödeme denemesi
   - Status: Başlamadı
   - Bağımlılıklar: 6

8) Rezervasyon zaman aşımı ve cleanup
   - Açıklama: Rezervasyonun süre dolduğunda otomatik iptal ve kontenjan geri verme mekanizması.
   - Alt görevler:
     8.1) Rezervasyon expiry alanını (+30 dakika) uygulama
     8.2) n8n schedule görevi veya DB job ile zaman aşımı tetikleyicisi oluşturma
     8.3) Süresi geçen rezervasyonları `cancel_reservation` ile işleme alma
   - Status: Başlamadı
   - Bağımlılıklar: 4,5

9) Testler ve otomasyon
   - Açıklama: Birim, entegrasyon ve uçtan uca testlerin hazırlanması.
   - Alt görevler:
     9.1) Stored procedure birim testleri (örnek SQL test senaryoları)
     9.2) n8n workflow entegrasyon testleri (mocked webhook çağrıları)
     9.3) Frontend e2e test (ör. Playwright veya Cypress) — 3 tıklama akışı
     9.4) Load test / concurrency simülasyonu (örn: k6 veya Artillery)
   - Status: Başlamadı
   - Bağımlılıklar: 4,5,6

10) Dağıtım ve hosting (Hostinger Coolify)
   - Açıklama: Uygulamayı üretime alma ve gerekli ortam değişkenlerini yönetme.
   - Alt görevler:
     10.1) Deployment pipeline tanımlama (build & deploy)
     10.2) Ortam değişkenleri dokümantasyonu (Supabase URL/Key, n8n URL/Key)
     10.3) SSL, custom domain ve temel ölçekleme parametreleri
   - Status: Başlamadı
   - Bağımlılıklar: 5,6,7

11) Gözleme (Monitoring) ve Başarı metrikleri
   - Açıklama: Kayıt hızı, dönüşüm oranı ve kontenjan doğruluğu için metrik toplama.
   - Alt görevler:
     11.1) Event modelleme: `reserved`, `paid`, `cancelled` event'lerinin tanımı
     11.2) Metrik toplama pipeline (ör. Supabase logs -> metrik toplayıcı veya basit webhook)
     11.3) Basit dashboard oluşturma (Grafana/Metabase veya Supabase SQL dashboard)
   - Status: Başlamadı
   - Bağımlılıklar: 9,10

12) Güvenlik, doğrulama ve rate limit
   - Açıklama: Input validation, rate limiting ve veri gizliliği kontrolleri.
   - Alt görevler:
     12.1) Frontend ve DB tarafı input validation kuralları
     12.2) Rate limiting / anti-bot stratejileri (IP throttling, CAPTCHA opsiyonları)
     12.3) Veri gizliliği ve GDPR uyumluluk notlarının hazırlanması
   - Status: Başlamadı
   - Bağımlılıklar: 6,4

13) Dokümantasyon ve teslimat (Handoff)
   - Açıklama: Projenin teslimi için gerekli dökümantasyon ve runbook hazırlığı.
   - Alt görevler:
     13.1) Proje README (kurulum, geliştirme, test, deploy)
     13.2) Runbook: sık karşılaşılan sorunlar ve rollback adımları
     13.3) PRD'ye referans ve kullanım kılavuzu (ürün sahibi için özet)
   - Status: Tamamlandı
   - Bağımlılıklar: 2,10,11

---

Nasıl kullanılır:
- Her görev tamamlandıkça lütfen ilgili `Status` satırını güncelleyin.
- Yeni görev/alt-görev eklenecekse numaralandırmayı bozmadan sonuna ekleyin veya yeni bir ana görev oluşturun.

İlgili dosyalar:
- PRD kaynağı: `kod yazma bana prd dokumanımı .md uzantılı olarak....md`
