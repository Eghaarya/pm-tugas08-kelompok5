# Dokumentasi API Pesanan Servis

## Base URL
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

### 2. Get All Pesanan
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

### 3. Backup & Upload Foto
```
POST /pesanan-backup
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
- `foto_awal` (optional): image file (jpg/jpeg/png, max 2MB)
- `foto_progress_1` s/d `foto_progress_5` (optional): image files

**Response:**
```json
{
  "success": true,
  "message": "Backup & upload foto berhasil",
  "data": {...}
}
```

---

## Catatan
- Semua endpoint kecuali login memerlukan JWT token di header
- Foto akan menimpa foto lama jika sudah ada
- Data di-upsert berdasarkan `kode_transaksi`