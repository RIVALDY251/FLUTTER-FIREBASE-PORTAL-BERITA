# Portal Berita - Flutter Firebase App

Aplikasi Portal Berita dengan Firebase Authentication yang dibuat menggunakan Flutter.

## Fitur

### ✅ Autentikasi Firebase
- Registrasi akun baru dengan email & password
- Login dan Logout
- Protected routes (hanya user yang login bisa akses fitur)

### 📱 Halaman Aplikasi
1. **Halaman Login/Register** - Autentikasi pengguna
2. **Halaman Home** - Menampilkan nama user yang login dan menu navigasi
3. **Halaman Daftar Berita** - Menampilkan list berita dengan berbagai kategori
4. **Halaman Profil** - Fitur CRUD untuk profil pengguna

### 🎨 Desain
- UI profesional dengan warna yang menarik
- Responsif untuk berbagai ukuran layar
- Material Design 3

## Setup

1. Install dependencies:
```bash
flutter pub get
```

2. Pastikan Firebase sudah dikonfigurasi dengan menjalankan:
```bash
flutterfire configure
```

3. Jalankan aplikasi:
```bash
flutter run
```

## Struktur Project

```
lib/
├── main.dart                 # Entry point aplikasi
├── firebase_options.dart     # Konfigurasi Firebase
├── services/
│   └── auth_service.dart    # Service untuk Firebase Authentication
├── screens/
│   ├── login_register_screen.dart  # Halaman login/register
│   ├── home_screen.dart           # Halaman home
│   ├── berita_list_screen.dart    # Halaman daftar berita
│   └── profile_screen.dart        # Halaman profil
├── widgets/
│   └── auth_wrapper.dart     # Wrapper untuk protected routes
└── theme/
    └── app_theme.dart        # Theme aplikasi
```

## Dependencies

- `firebase_core: ^3.15.2`
- `firebase_auth: ^5.3.1`
- `cloud_firestore: ^5.5.0`

## Catatan

Pastikan Firebase Authentication sudah diaktifkan di Firebase Console dengan metode Email/Password enabled.
