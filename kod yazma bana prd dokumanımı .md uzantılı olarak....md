# **Yapay Zeka Eğitim Kayıt Sistemi (YZESKS) \- Ürün Gereksinim Belgesi (PRD)**

| Kategori | Değer |
| :---- | :---- |
| **Proje Adı** | Yapay Zeka Eğitim Kayıt Sistemi (YZESKS) |
| **Versiyon** | 1.2 (Final Veri Modeli ve Gateway Mimarisi) |
| **Oluşturulma Tarihi** | Ekim 2025 |
| **Hedef Kitle** | Yapay Zeka eğitimi almak isteyen bireyler. |

## **1\. Proje Özeti ve Amaç**

Bu projenin temel amacı, kullanıcıların Yapay Zeka eğitim gruplarına (örneğin Ekim, Aralık grupları) kontenjanları anlık olarak takip ederek, giriş yapmadan, tek bir sayfa üzerinden ve en fazla üç (3) tıklama ile kayıt ve ödeme işlemlerini tamamlayabilmelerini sağlamaktır. Kayıt süreci basit, hızlı ve hatasız olmalıdır.

## **2\. Temel İş Gereksinimleri (Business Requirements)**

### **BR-01: Kontenjan Yönetimi**

* Eğitimler, 10 kişilik sabit kontenjanlarla açılacaktır.  
* Her eğitim grubu (örneğin "Ekim Grubu") için bir kontenjan sayacı tutulmalıdır.

### **BR-02: Kayıt ve Ödeme Akışı**

* Kayıt, tek bir sayfa üzerinde (Single Page Application \- SPA) ve anonim olarak (Login olmadan) gerçekleşmelidir.  
* Kontenjan, kayıt formu doldurulduktan ve "Kaydet" butonuna basıldıktan hemen sonra **geçici olarak** bir (1) azaltılmalıdır (Rezervasyon Durumu).  
* Kalıcı kayıt, sadece ödeme işlemi başarılı bir şekilde tamamlandığında gerçekleşecektir.  
* Eğer kullanıcı ödeme yapmazsa veya ödeme başarısız olursa, kontenjan geri yüklenmelidir.

### **BR-03: Üç Tıklama Kuralı (Kullanıcı Deneyimi Hedefi)**

Kullanıcının kayıt akışı, aşağıdaki 3 ana tıklama ile tamamlanmalıdır:

1. **Tıklama 1 (Grup Seçimi):** Kullanıcı Ana Sayfada yer alan ilgili eğitim grubunu seçer (Örn: "Ekim Grubu Kayıt Ol").  
2. **Tıklama 2 (Kayıt Formu Gönderimi):** Açılan kayıt formunu doldurur ve "Kaydı Tamamla & Ödemeye Geç" butonuna tıklar. (Kontenjan burada rezerve edilir).  
3. **Tıklama 3 (Ödeme Onayı):** Aynı sayfada açılan ödeme panelinde, ödeme bilgilerini girdikten sonra "Ödemeyi Onayla" butonuna tıklar.

## **3\. Fonksiyonel Gereksinimler (Functional Requirements)**

### **FR-01: Ana Sayfa Görünümü ve Grup Listeleme**

* Sistem, mevcut ve gelecekteki eğitim gruplarını listelemelidir (Örn: Ekim Grubu, Aralık Grubu).  
* Her grubun yanında kalan anlık kontenjan bilgisi (Örn: 5/10) gösterilmelidir.  
* Kontenjan dolduğunda, ilgili grubun butonu "Kontenjan Dolu" olarak değişmeli ve tıklanamaz olmalıdır.

### **FR-02: Kayıt Formu Modülü**

* Kullanıcı bir grubu seçtiğinde, aynı sayfanın dinamik olarak açılan bir alanında bir kayıt formu gösterilmelidir.  
* Form Alanları: Ad Soyad, E-posta, Telefon Numarası.  
* Formun başarılı şekilde gönderilmesi (Tıklama 2\) sonrası, kullanıcıya geçici rezervasyon yapıldığı ve ödeme bekleme mesajı verilmelidir.

### **FR-03: Ödeme Modülü**

* Kayıt formunun gönderilmesinin (Tıklama 2\) ardından, kayıt formu alanı yerini dinamik olarak ödeme arayüzüne bırakmalıdır.  
* Ödeme arayüzü, mock-up bir ödeme entegrasyonu simüle etmelidir (Gerçek ödeme entegrasyonu bu fazın kapsamı dışındadır, ancak simülasyon yapılmalıdır).  
* Başarılı ödeme (Tıklama 3\) sonrası, kontenjan kalıcı olarak azaltılmalı ve kullanıcıya "Kayıt Başarılı" mesajı verilmelidir.  
* Başarısız ödeme durumunda, kullanıcıya hata mesajı gösterilmeli ve rezerve edilen kontenjan geri serbest bırakılmalıdır.

## **4\. Teknik Mimari ve Çözüm Önerisi (Software Architecture)**

### **TA-01: Teknoloji ve Mimari**

* **Veri Tabanı (Database):** **Supabase (PostgreSQL İlişkisel Veri Tabanı)** kullanılacaktır.  
* **Backend/İş Akışı (Workflow):** **n8n** kullanılacaktır. Tüm iş mantığı n8n iş akışları (Workflow) aracılığıyla Supabase ile güvenli bir şekilde yönetilecektir.  
* **Ön Yüz (Frontend):** HTML5, Tailwind CSS ve Vanilla JavaScript (Tek sayfa yapısı için).  
* **Dağıtım/Hosting:** **Hostinger Coolify** platformu üzerinden dağıtımı yapılacaktır.

### **TA-02: Veri Modeli (Supabase \- PostgreSQL İlişkisel Tabloları)**

Kontenjan takibi ve kayıt bilgileri için iki ana tablo kullanılacaktır:

#### **Tablo 1: course\_groups (Eğitim Grupları)**

| Alan Adı (Column) | Tür (Type) | Kısıtlama (Constraint) | Açıklama |
| :---- | :---- | :---- | :---- |
| group\_id | uuid (veya SERIAL) | PRIMARY KEY | Grubun benzersiz kimliği. |
| name | text | NOT NULL | Eğitimin Adı (Örn: 'Ekim 2025 Grubu'). |
| max\_capacity | smallint | NOT NULL (DEFAULT 10\) | Maksimum Kontenjan. |
| registered\_count | smallint | NOT NULL (DEFAULT 0\) | Başarılı ödeme yapmış katılımcı sayısı. |
| reserved\_count | smallint | NOT NULL (DEFAULT 0\) | Ödeme bekleyen geçici rezervasyon sayısı. |
| is\_active | boolean | NOT NULL (DEFAULT TRUE) | Kayıtların açık olup olmadığı. |

#### **Tablo 2: registrations (Kayıtlar)**

| Alan Adı (Column) | Tür (Type) | Kısıtlama (Constraint) | Açıklama |
| :---- | :---- | :---- | :---- |
| registration\_id | uuid (veya SERIAL) | PRIMARY KEY | Kaydın benzersiz kimliği. |
| group\_id | uuid | FOREIGN KEY (course\_groups) | Katılımcının kayıt olduğu grubun ID'si. |
| email | text | NOT NULL, UNIQUE | Katılımcının E-posta adresi. |
| status | text | NOT NULL | Durum: 'RESERVED', 'PAID', 'CANCELLED'. |
| reservation\_expiry | timestamp with time zone | NOT NULL | Rezervasyonun sona erme zamanı (Örn: \+30 dakika). |

### **TA-03: Kontenjan Güncelleme Mantığı (n8n ve Stored Procedures)**

Kontenjanın doğru yönetimi için kritik yazma işlemleri, n8n tarafından çağrılan **Supabase PostgreSQL Stored Procedures** ile atomik olarak yapılacaktır.

1. **Grup Seçimi (Okuma):** Frontend, course\_groups tablosundan anlık kontenjan verilerini okur.  
2. **Form Kaydı (Tıklama 2):** n8n, rezervasyon prosedürünü çağırır (reserved\_count \+1, registrations kaydı 'RESERVED' oluşturulur).  
3. **Ödeme Başarılı (Tıklama 3):** n8n, onay prosedürünü çağırır (registered\_count \+1, reserved\_count \-1, registrations.status 'PAID' yapılır).  
4. **Ödeme Başarısız/Zaman Aşımı:** n8n, iptal prosedürünü çağırır (reserved\_count \-1, registrations.status 'CANCELLED' yapılır).

### **TA-04: Merkezi n8n Gateway (Dispatcher Webhook)**

Tüm ön yüz ve dış sistem istekleri, tek bir n8n Webhook URL'ine yönlendirilecektir. Bu Webhook, bir **Gateway (Ağ Geçidi)** yapısı olarak görev yapacaktır.

* **Tek Endpoint:** Frontend, tüm iş mantığı (rezervasyon, ödeme onayı vb.) için sadece tek bir n8n Webhook URL'ine POST isteği gönderecektir.  
* **Yönlendirme Mekanizması:** Gelen istek gövdesinde (body) zorunlu olarak bir action (eylem) alanı bulunacaktır. n8n'deki ilk düğüm (Switch veya IF) bu action alanına göre ilgili iş akışına yönlendirme yapacaktır.

| action Değeri | Açıklama | İlgili İş Akışı / İşlem |
| :---- | :---- | :---- |
| reserve\_spot | Kayıt formu gönderimi (Tıklama 2). | Rezervasyon İş Akışı (TA-03/2) |
| confirm\_payment | Başarılı ödeme bildirimi (Tıklama 3). | Ödeme Onay İş Akışı (TA-03/3) |
| cancel\_reservation | Ödeme zaman aşımı veya iptali. | İptal İş Akışı (TA-03/4) |

## **5\. Başarı Metrikleri**

* **Kayıt Hızı:** Kullanıcıların %90'ı, 3 tıklama kuralına uygun olarak akışı tamamlayabilmelidir.  
* **Kontenjan Doğruluğu:** Kontenjan güncellemeleri, PostgreSQL Stored Procedures ve n8n ile yönetildiği için her zaman atomik ve doğru olmalıdır.  
* **Dönüşüm Oranı:** Kayıt formunu doldurup ödeme yapan kullanıcı oranı takip edilmelidir.