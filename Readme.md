# Dokumentasi API Pesanan Servis

## Install Server Laravel with JWT Token
```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate
php artisan db:seed
php artisan serve
```
```bash
ngrok http 8000
```

## Base URL `frontend/lib/services/api_service.dart`
```
http://your-domain.com/api
```

## Endpoints

### 1. Login
```
POST /login
```

**Request:**
```json
{
  "username": "your_username",
  "password": "your_password"
}
```

**Response:**
```json
{
  "success": true,
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "token_type": "Bearer",
  "expires_in": 3600
}
```

---

### 2. Get Pesanan
```
GET /pesanan
Headers: Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "total": 10,
  "data": [...]
}
```

---

### 3. Post Pesanan & Upload Foto
```
POST /posting-pesanan
Headers: Authorization: Bearer {token}
Content-Type: multipart/form-data
```

**Form Data:**
- `data` (required): JSON string
  ```json
  {
    "kode_transaksi": "TRX001",
    "biaya": 150000,
    "nama_pelanggan": "John Doe",
    "nomor_telp": "08123456789"
  }
  ```
- `foto_1` s/d `foto_3` (optional): image files

**Response:**
```json
{
  "success": true,
  "message": "Posting & upload foto berhasil",
  "data": {...}
}
```

---

## Catatan
- Semua endpoint kecuali login memerlukan JWT token di header
- Foto akan menimpa foto lama jika sudah ada
- Data di-upsert berdasarkan `kode_transaksi`