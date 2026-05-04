# Veritabanı Şeması (PostgreSQL)

Bu belge, kapsamlı Berber ve Müşteri Ağı SaaS uygulaması için tasarlanmış veritabanı şemasını içerir.

## 1. Kullanıcı ve Kimlik Doğrulama Yönetimi

**`users`**
Sistemdeki tüm kullanıcıların (Müşteri, Berber, SuperAdmin) temel bilgilerini tutar.
- `id` (UUID, PK)
- `role` (Enum: 'CUSTOMER', 'BARBER', 'SUPERADMIN')
- `email` (String, Unique, Nullable)
- `phone` (String, Unique, Nullable)
- `password_hash` (String, Nullable - Social Login için null olabilir)
- `is_active` (Boolean)
- `created_at` (Timestamp)
- `updated_at` (Timestamp)

**`auth_providers`** (Social Login Desteği)
Müşterilerin Google, Apple gibi sağlayıcılar ile giriş yapmasını sağlar.
- `id` (UUID, PK)
- `user_id` (UUID, FK -> users.id)
- `provider` (Enum: 'GOOGLE', 'APPLE')
- `provider_id` (String, Unique)
- `created_at` (Timestamp)

## 2. Profil Yönetimi

**`customer_profiles`**
- `id` (UUID, PK)
- `user_id` (UUID, FK -> users.id, Unique)
- `first_name` (String)
- `last_name` (String)
- `loyalty_points` (Integer, Default: 0)
- `avatar_url` (String, Nullable)

**`barber_shops`** (İşletme Profili)
- `id` (UUID, PK)
- `owner_id` (UUID, FK -> users.id)
- `name` (String)
- `description` (Text, Nullable)
- `address` (Text)
- `latitude` (Float)
- `longitude` (Float)
- `average_rating` (Float, Default: 0.0)
- `is_open` (Boolean, Default: True)

**`staff`** (Personel Yönetimi)
Bir işletmede çalışan berberleri temsil eder.
- `id` (UUID, PK)
- `shop_id` (UUID, FK -> barber_shops.id)
- `name` (String)
- `is_available` (Boolean, Default: True)

## 3. Hizmetler ve Uluslararasılaştırma (i18n)

**`services`**
Berberlerin sunduğu hizmetler (Saç Kesimi, Sakal vb.).
- `id` (UUID, PK)
- `shop_id` (UUID, FK -> barber_shops.id)
- `translation_key` (String) - Çoklu dil desteği için (Örn: 'service.haircut')
- `duration_minutes` (Integer)
- `price` (Decimal)
- `currency` (String, Default: 'TRY')

**`translations`** (Çoklu Dil Desteği)
- `id` (UUID, PK)
- `lang_code` (String) - (Örn: 'tr', 'en')
- `key` (String)
- `value` (Text)

## 4. Randevu ve Canlı Sıra Sistemi

**`appointments`**
İleri tarihli randevular veya anlık sıraya giren müşterileri tutar.
- `id` (UUID, PK)
- `customer_id` (UUID, FK -> users.id)
- `shop_id` (UUID, FK -> barber_shops.id)
- `staff_id` (UUID, FK -> staff.id, Nullable)
- `service_id` (UUID, FK -> services.id)
- `type` (Enum: 'SCHEDULED', 'LIVE_QUEUE')
- `status` (Enum: 'PENDING', 'APPROVED', 'REJECTED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED')
- `scheduled_time` (Timestamp, Nullable - 'SCHEDULED' ise zorunlu)
- `queue_number` (Integer, Nullable - 'LIVE_QUEUE' ise geçerli)
- `created_at` (Timestamp)

## 5. Değerlendirme ve Puanlama

**`reviews`**
- `id` (UUID, PK)
- `appointment_id` (UUID, FK -> appointments.id, Unique)
- `customer_id` (UUID, FK -> users.id)
- `shop_id` (UUID, FK -> barber_shops.id)
- `rating` (Integer, 1-5 arası)
- `comment` (Text, Nullable)
- `created_at` (Timestamp)

## 6. Ödeme ve Abonelik (SaaS)

**`subscriptions`** (SaaS Paketleri)
- `id` (UUID, PK)
- `shop_id` (UUID, FK -> barber_shops.id)
- `plan_name` (Enum: 'BASIC', 'PRO', 'PREMIUM')
- `status` (Enum: 'ACTIVE', 'CANCELED', 'EXPIRED')
- `start_date` (Timestamp)
- `end_date` (Timestamp)

**`payments`**
- `id` (UUID, PK)
- `user_id` (UUID, FK -> users.id)
- `amount` (Decimal)
- `currency` (String)
- `transaction_id` (String) - Stripe/Iyzico işlem ID'si
- `type` (Enum: 'SUBSCRIPTION', 'SERVICE')
- `status` (Enum: 'PENDING', 'SUCCESS', 'FAILED')
- `created_at` (Timestamp)

## 7. B2B Berber Ağı (Topluluk / Forum)

**`b2b_posts`**
Berberlerin kendi aralarında iletişimi için.
- `id` (UUID, PK)
- `author_id` (UUID, FK -> users.id)
- `type` (Enum: 'TRADE', 'JOB_LISTING', 'FORUM')
- `title` (String)
- `content` (Text)
- `created_at` (Timestamp)
