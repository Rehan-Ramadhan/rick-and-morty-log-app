# Rick & Morty Log App

Aplikasi mobile berbasis Flutter untuk menjelajahi karakter dari serial _Rick and Morty_ dan mengelola koleksi karakter secara pribadi.

Rick & Morty Log App terintegrasi dengan Rick and Morty Public API untuk menampilkan informasi karakter dan Laravel REST API sebagai backend untuk autentikasi serta pengelolaan koleksi berdasarkan akun pengguna.

## Repositories

Proyek ini terdiri dari dua repository yang saling terintegrasi:

| Repository                                                                         | Teknologi | Deskripsi                                     |
| ---------------------------------------------------------------------------------- | --------- | --------------------------------------------- |
| [rick-morty-log-app](https://github.com/Rehan-Ramadhan/rick-morty-log-app)         | Flutter   | Aplikasi frontend dan antarmuka pengguna      |
| [rick-morty-log-backend](https://github.com/Rehan-Ramadhan/rick-morty-log-backend) | Laravel   | REST API, autentikasi, dan manajemen database |

## Features

- **Authentication** — Registrasi dan login menggunakan Laravel Sanctum.
- **Session Management** — Menyimpan token autentikasi menggunakan Shared Preferences.
- **Character Exploration** — Menjelajahi karakter Rick and Morty dari Public API.
- **Character Search** — Mencari karakter berdasarkan nama.
- **Character Details** — Melihat informasi karakter, termasuk spesies, gender, asal, dan lokasi.
- **Dimension Management** — Membuat, melihat, mengubah, dan menghapus kategori koleksi.
- **Character Logs** — Menyimpan karakter ke koleksi pribadi beserta catatan.
- **Collection Management** — Mengelola karakter berdasarkan kategori yang dimiliki pengguna.
- **Profile** — Melihat informasi akun dan melakukan logout.
- **Responsive Interface** — Antarmuka yang menyesuaikan tampilan perangkat.

## Tech Stack

### Frontend

- Flutter
- Dart
- Dio
- Shared Preferences
- Provider

### Backend

- Laravel 13
- PHP 8.3+
- Laravel Sanctum
- MySQL
- RESTful API

### External API

- [Rick and Morty API](https://rickandmortyapi.com/)

## Application Screens

Aplikasi memiliki beberapa halaman utama:

| Screen               | Description                                             |
| -------------------- | ------------------------------------------------------- |
| Splash Screen        | Memeriksa status autentikasi pengguna                   |
| Login Page           | Halaman masuk ke akun                                   |
| Register Page        | Halaman pendaftaran akun                                |
| Explore Page         | Menjelajahi daftar karakter                             |
| Explore Detail Page  | Menampilkan detail karakter dan fitur simpan ke koleksi |
| Collection Page      | Mengelola kategori dan karakter yang disimpan           |
| Profile & About Page | Menampilkan profil pengguna dan informasi aplikasi      |

## API Integration

### Laravel Backend

Aplikasi menggunakan backend Laravel untuk autentikasi dan pengelolaan data koleksi.

| Method    | Endpoint               | Description                         |
| --------- | ---------------------- | ----------------------------------- |
| POST      | `/api/register`        | Registrasi akun                     |
| POST      | `/api/login`           | Login akun                          |
| GET       | `/api/user`            | Mengambil profil pengguna           |
| POST      | `/api/logout`          | Logout akun                         |
| GET       | `/api/dimensions`      | Mengambil daftar kategori           |
| POST      | `/api/dimensions`      | Menambahkan kategori                |
| GET       | `/api/dimensions/{id}` | Mengambil detail kategori           |
| PUT/PATCH | `/api/dimensions/{id}` | Memperbarui kategori                |
| DELETE    | `/api/dimensions/{id}` | Menghapus kategori                  |
| GET       | `/api/char-logs`       | Mengambil daftar karakter tersimpan |
| POST      | `/api/char-logs`       | Menyimpan karakter                  |
| GET       | `/api/char-logs/{id}`  | Mengambil detail karakter           |
| PUT/PATCH | `/api/char-logs/{id}`  | Memperbarui karakter                |
| DELETE    | `/api/char-logs/{id}`  | Menghapus karakter                  |

Endpoint selain register dan login membutuhkan Bearer Token dari Laravel Sanctum.

### Rick and Morty Public API

Aplikasi mengambil data karakter dari:

`https://rickandmortyapi.com/api/character`

Informasi yang digunakan antara lain:

- `name`
- `image`
- `status`
- `species`
- `gender`
- `origin.name`
- `location.name`

Dokumentasi API: [Rick and Morty API Documentation](https://rickandmortyapi.com/documentation)

## Project Structure

```text
rick-morty-log-app/
├── lib/
│   ├── constants/
│   │   └── api_constant.dart
│   ├── models/
│   ├── providers/
│   ├── routing/
│   │   └── app_routing.dart
│   ├── screens/
│   ├── services/
│   ├── theme/
│   ├── widgets/
│   ├── app.dart
│   └── main.dart
├── test/
├── web/
├── pubspec.yaml
└── README.md
```

## Installation

### Requirements

- Flutter SDK
- Dart SDK
- PHP 8
