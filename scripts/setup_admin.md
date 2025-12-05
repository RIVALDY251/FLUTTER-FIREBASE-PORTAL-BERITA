# Script Setup Admin - Portal Berita

## Cara Menggunakan

### Langkah 1: Daftar Akun Baru
1. Buka aplikasi
2. Daftar dengan email dan password yang ingin dijadikan admin
   - Contoh: `admin@example.com` / `admin123456`
3. Setelah registrasi berhasil, catat email dan password tersebut

### Langkah 2: Setup di Firestore

#### Via Firebase Console:
1. Buka [Firebase Console](https://console.firebase.google.com)
2. Pilih project: `flutter-firebase-app-776b5`
3. Buka **Firestore Database**
4. Klik **Start collection** (jika belum ada collection `users`)
5. Collection ID: `users`
6. Document ID: **[UID dari Firebase Auth]** (PENTING!)
   - Cara dapatkan UID:
     - Buka **Authentication** → **Users**
     - Cari email yang baru didaftarkan
     - Copy **UID** (User ID)
7. Klik **Next**
8. Tambahkan fields berikut:

| Field | Type | Value |
|-------|------|-------|
| `uid` | string | [UID yang sama dengan Document ID] |
| `email` | string | [email yang digunakan saat registrasi] |
| `displayName` | string | [nama yang diisi saat registrasi] |
| `role` | string | `admin` |
| `emailVerified` | boolean | `true` |
| `createdAt` | timestamp | [pilih waktu sekarang] |
| `updatedAt` | timestamp | [pilih waktu sekarang] |

9. Klik **Save**

### Langkah 3: Verifikasi
1. Logout dari aplikasi (jika masih login)
2. Login kembali dengan email/password yang sudah di-set sebagai admin
3. Setelah login, seharusnya muncul menu **Admin** di aplikasi
4. Klik menu Admin → akan masuk ke Admin Dashboard

## Contoh Setup

**Email:** `admin@portalberita.com`  
**Password:** `Admin123!`  
**UID:** `abc123xyz456` (contoh)

**Document di Firestore:**
- Collection: `users`
- Document ID: `abc123xyz456`
- Fields:
  ```json
  {
    "uid": "abc123xyz456",
    "email": "admin@portalberita.com",
    "displayName": "Admin Portal",
    "role": "admin",
    "emailVerified": true,
    "createdAt": "2024-12-05T10:00:00Z",
    "updatedAt": "2024-12-05T10:00:00Z"
  }
  ```

## Catatan Penting

1. **Document ID HARUS sama dengan UID** dari Firebase Authentication
2. **Field `role` HARUS huruf kecil:** `admin` (bukan `Admin` atau `ADMIN`)
3. Setelah setup, **logout dan login lagi** agar perubahan terdeteksi
4. Jika menu Admin tidak muncul, cek:
   - Document ID = UID?
   - Field `role` = `admin`?
   - Sudah logout dan login lagi?

## Troubleshooting

### Menu Admin tidak muncul?
- Pastikan Document ID di Firestore = UID dari Firebase Auth
- Pastikan field `role` = `admin` (huruf kecil)
- Logout dan login lagi
- Cek console log untuk error

### Error "Permission denied"?
- Pastikan Firestore Security Rules sudah dikonfigurasi
- Untuk testing, gunakan rules yang lebih permisif dulu

