# API Uç Noktaları (FastAPI - REST & WebSocket)

Bu belge, Berber ve Müşteri Ağı uygulamasının iletişimini sağlayacak API uç noktalarını tanımlar.

## 1. Kimlik Doğrulama (Auth)
- `POST /api/v1/auth/register`: E-posta/Telefon ile kayıt (Müşteri ve Berber).
- `POST /api/v1/auth/login`: E-posta veya Telefon ile giriş. Dönen değer: `{"access_token": "...", "token_type": "bearer"}`
- `POST /api/v1/auth/otp/send`: OTP Gönderimi.
- `POST /api/v1/auth/otp/verify`: OTP Doğrulaması.
- `POST /api/v1/auth/social/google`: Google ile giriş/kayıt (Payload: OAuth token).
- `POST /api/v1/auth/social/apple`: Apple ile giriş/kayıt.

## 2. Kullanıcı Profili (Customer)
- `GET /api/v1/profile/me`: Giriş yapan kullanıcının profil bilgileri.
- `PUT /api/v1/profile/me`: Profil güncelleme.
- `GET /api/v1/profile/favorites`: Favori berberleri listeleme.
- `POST /api/v1/profile/favorites/{shop_id}`: Berberi favorilere ekleme.

## 3. Berber (İşletme) İşlemleri
- `GET /api/v1/shops`: Berberleri listeleme (Parametreler: `lat`, `lng`, `radius`, `rating`, `service_type`).
- `GET /api/v1/shops/{shop_id}`: Berber detayı (Hizmetler, personel, yorumlar).
- `POST /api/v1/shops`: (Sadece Barber) Yeni işletme profili oluşturma.
- `PUT /api/v1/shops/{shop_id}`: (Sadece Barber) İşletme profilini güncelleme.

## 4. Personel ve Hizmetler
- `GET /api/v1/shops/{shop_id}/staff`: İşletme personelini listeleme.
- `POST /api/v1/shops/{shop_id}/staff`: Yeni personel ekleme.
- `GET /api/v1/shops/{shop_id}/services`: İşletme hizmetlerini listeleme.
- `POST /api/v1/shops/{shop_id}/services`: Yeni hizmet ekleme.

## 5. Randevu ve Canlı Sıra (REST & WebSocket)
- `POST /api/v1/appointments/schedule`: İleri tarihli randevu alma.
- `POST /api/v1/appointments/queue`: Anlık sıraya girme.
- `GET /api/v1/appointments/my`: Kullanıcının kendi randevuları/sıraları.
- `GET /api/v1/appointments/shop`: İşletmenin randevu takvimi.
- `PUT /api/v1/appointments/{appointment_id}/status`: Randevu durumunu güncelleme (PENDING -> APPROVED vb.)

**WebSocket Uç Noktaları:**
- `WS /ws/v1/queue/{shop_id}`: İşletmeye ait canlı sıra güncellemelerini almak için WebSocket bağlantısı.
- `WS /ws/v1/notifications/{user_id}`: Kullanıcıya özel anlık bildirimler.

## 6. Değerlendirme
- `POST /api/v1/reviews/{appointment_id}`: Hizmet sonrası değerlendirme yapma.
- `GET /api/v1/shops/{shop_id}/reviews`: Bir işletmenin yorumlarını listeleme.

## 7. Ödeme ve Abonelik
- `POST /api/v1/payments/intent`: Ödeme niyeti oluşturma (Stripe/Iyzico Client Secret döner).
- `POST /api/v1/subscriptions/subscribe`: Berber için SaaS paketine abone olma.
- `GET /api/v1/subscriptions/my`: İşletmenin mevcut abonelik durumu.

## 8. B2B Berber Ağı
- `GET /api/v1/b2b/posts`: B2B ilanları/forum gönderilerini listeleme.
- `POST /api/v1/b2b/posts`: Yeni ilan/gönderi oluşturma.
- `GET /api/v1/b2b/posts/{post_id}`: Gönderi detayı.
