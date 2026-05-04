# Berber ve Müşteri Ağı - Veritabanı Yapısı (Güncel)

Backend dizinindeki güncel SQLAlchemy modellerine (`backend/app/models/` altındaki dosyalar) göre veritabanı yapısı şu şekildedir:

## 1. Kullanıcılar ve Profil Yönetimi

*   **`users`**: Sistemdeki tüm kullanıcıların temel bilgilerini tutar.
    *   **Alanlar:** `id` (UUID), `email`, `phone`, `password_hash`, `role` (CUSTOMER, BARBER, SUPERADMIN), `is_active`.
*   **`auth_providers`**: Sosyal girişler için (Google, Apple).
    *   **Alanlar:** `provider`, `provider_id`, `user_id` (users ile ilişkili).
*   **`customer_profiles`**: Müşteri rollü kullanıcıların profil bilgileri.
    *   **Alanlar:** `first_name`, `last_name`, `loyalty_points`, `avatar_url`, `user_id`.
*   **`barber_shops`**: Berber işletmelerinin profilleri.
    *   **Alanlar:** `name`, `description`, `address`, `latitude`, `longitude`, `average_rating`, `is_open`, `owner_id` (users ile ilişkili).
*   **`staff`**: İşletmede çalışan personeller (Berberler).
    *   **Alanlar:** `name`, `is_available`, `shop_id` (barber_shops ile ilişkili).

## 2. Hizmetler ve Çeviriler

*   **`services`**: Bir berber dükkanının sunduğu hizmetler (Saç kesimi, sakal tıraşı vb.).
    *   **Alanlar:** `translation_key` (Çok dilli metinler için), `duration_minutes`, `price`, `currency`, `shop_id`.
*   **`translations`**: Dinamik i18n çevirileri.
    *   **Alanlar:** `lang_code` (örn. 'tr', 'en'), `key`, `value`.

## 3. Randevu ve Değerlendirme Sistemi

*   **`appointments`**: Hem ileri tarihli randevular hem de canlı sıradaki müşteriler.
    *   **Alanlar:** `type` (SCHEDULED, LIVE_QUEUE), `status` (PENDING, APPROVED, vb.), `scheduled_time`, `queue_number`, `customer_id`, `shop_id`, `staff_id`, `service_id`.
*   **`reviews`**: Hizmet alan müşterilerin berberi ve randevuyu değerlendirmesi.
    *   **Alanlar:** `rating` (Puan), `comment`, `appointment_id`, `customer_id`, `shop_id`.

## 4. Ödeme, SaaS Abonelikleri ve B2B Ağı

*   **`subscriptions`**: Berberlerin sisteme abone olma durumu (SaaS Paketleri).
    *   **Alanlar:** `plan_name` (BASIC, PRO, PREMIUM), `status` (ACTIVE vb.), `start_date`, `end_date`, `shop_id`.
*   **`payments`**: Kullanıcıların ödeme geçmişi (Hizmet ödemesi veya abonelik).
    *   **Alanlar:** `amount`, `currency`, `transaction_id`, `type` (SUBSCRIPTION, SERVICE), `status`, `user_id`.
*   **`b2b_posts`**: Berberlerin kendi aralarındaki forum, ilan ve iş ağındaki gönderiler.
    *   **Alanlar:** `type` (TRADE, JOB_LISTING, FORUM), `title`, `content`, `author_id` (users ile ilişkili).

---

> [!WARNING]
> Alembic veritabanı yansıtma (`alembic upgrade head`) işleminizin, bilgisayarınızda bir **PostgreSQL sunucusu çalışmadığı için** (`[Errno 61] Connect call failed`) hata verdiğini fark ettim. Modelleri oluşturabilmek için sisteminizde PostgreSQL'in kurulu olması ve `5432` portunda çalışıyor olması gerekmektedir.
