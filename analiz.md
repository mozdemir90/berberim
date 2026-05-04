# Berber ve Müşteri Ağı - Proje Analizi

Bu analiz, depodaki dokümanlar, backend ve frontend klasör yapısına göre oluşturulmuştur. Proje, berber işletmeleri ve müşterileri bir araya getiren kapsamlı bir SaaS (Hizmet olarak Yazılım) çözümüdür.

## 1. Proje Mimarisi
Proje, genel olarak iki ana bileşenden oluşmaktadır:
- **Backend**: FastAPI tabanlı, PostgreSQL kullanan bir REST & WebSocket API.
- **Frontend**: Flutter ile geliştirilmiş, çoklu platform destekli mobil uygulama.

### Backend Teknolojileri (Python / FastAPI)
`backend/requirements.txt` dosyasına göre ana bağımlılıklar şunlardır:
- **FastAPI & Uvicorn**: Yüksek performanslı ve asenkron web framework'ü. WebSockets desteği de bulunuyor.
- **SQLAlchemy & Alembic**: Veritabanı ORM (Object-Relational Mapping) ve migration (şema göçü) işlemleri.
- **Asyncpg**: PostgreSQL ile asenkron iletişim için veritabanı sürücüsü.
- **Pydantic**: Veri doğrulama ve veri modelleri için.
- **Passlib & Python-jose**: Şifreleme, güvenlik ve JWT tabanlı kimlik doğrulama işlemleri.

### Frontend Teknolojileri (Flutter)
- `pubspec.yaml` ve `lib` klasöründen anlaşıldığı üzere, müşteri ve berberlerin kullanacağı kullanıcı arayüzü Dart ve Flutter ile geliştirilmiştir.

## 2. Temel Özellikler

### Kimlik Doğrulama & Yetkilendirme
- Üç farklı kullanıcı rolü bulunmaktadır: `CUSTOMER` (Müşteri), `BARBER` (Berber), `SUPERADMIN`.
- E-posta, Telefon OTP (Tek Kullanımlık Şifre) ve Sosyal Giriş (Google, Apple) desteklenmektedir.

### Randevu ve Canlı Sıra Sistemi
Uygulamanın en önemli özelliklerinden biri randevu ve canlı sıra sistemidir:
- **İleri Tarihli Randevular**: Müşteriler belirli bir tarih ve saat için hizmet seçerek randevu alabilir.
- **Canlı Sıra (Live Queue)**: Berberin anlık sırasına girilebilir.
- **WebSocket Entegrasyonu**: Canlı sıra güncellemeleri ve anlık bildirimler, WebSocket üzerinden gerçek zamanlı olarak müşterilere ve berberlere iletilir (`/ws/v1/queue/{shop_id}`).

### İşletme ve Personel Yönetimi
- Berberler sisteme işletme (shop) olarak kaydolabilir; konum (lat/long), adres, hizmetler ve fiyatlandırmalarını yönetebilir.
- Birden fazla personel eklenebilir ve her personelin uygunluk durumu yönetilebilir.

### Değerlendirme Sistemi
Müşteriler, aldıkları hizmet sonrası berber işletmesini puanlayıp (1-5 arası) yorum yapabilir. İşletmenin ortalama puanı (`average_rating`) bu değerlendirmelere göre hesaplanır.

### Ödeme ve SaaS Abonelik Modeli
- Berberler sisteme abone olarak (`BASIC`, `PRO`, `PREMIUM`) platformu kullanırlar.
- Stripe veya Iyzico gibi ödeme altyapıları üzerinden ödeme niyetleri oluşturulur. Hem abonelik hem de hizmet içi ödeme işlemleri veritabanında takip edilir.

### Çoklu Dil (i18n) Desteği
- Sistem dinamik olarak `translations` tablosunda ve hizmetlerde `translation_key` kullanarak çoklu dil (Türkçe, İngilizce vb.) desteği sunabilecek altyapıya sahiptir.

### B2B Ağı / Topluluk
Berberlerin kendi aralarında malzeme alım/satımı, iş ilanı (eleman arayanlar) veya forum amaçlı iletişim kurabileceği bir B2B sosyal ağ/forum modülü bulunmaktadır.

## 3. Veritabanı Şeması (Özet)
- `users`, `auth_providers`: Kullanıcı hesapları ve giriş yöntemleri.
- `customer_profiles`, `barber_shops`, `staff`: Profil verileri.
- `services`, `translations`: İşletmenin verdiği hizmetler ve çok dilli metinler.
- `appointments`: Canlı sıralar ve ileri tarihli randevular.
- `reviews`: Yorum ve puanlamalar.
- `subscriptions`, `payments`: SaaS üyelik durumları ve ödeme kayıtları.
- `b2b_posts`: Berberler arası topluluk ilanları.

## 4. Sonuç ve Öneriler
Bu mimari modern, ölçeklenebilir ve gerçek zamanlı özelliklere sahip (WebSocket ile canlı sıra) güçlü bir altyapı üzerine kurulmuştur. Frontend tarafındaki geliştirmeler için state management (Durum Yönetimi) mimarisinin iyi kurulması önerilir.
