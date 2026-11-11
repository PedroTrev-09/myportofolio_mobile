# MyPortfolio Mobile

**Nama:** Haikal Rafka A Rahman  
**NPM:** 2506553383  
**Kelas:** PBP A

## Progres

- Tutorial 08: implementasi dan validasi lokal selesai.
- Branch: `tutorial-8` pada repositori mobile tersendiri.

## Menjalankan aplikasi

Flutter 3.47.8 / Dart 3.13.7 digunakan saat validasi. Dari terminal:

```bash
cd <root folder>
flutter pub get
flutter run -d chrome
```

Saat aplikasi berjalan, `r` menjalankan hot reload dan `q` menghentikan aplikasi. Android emulator/perangkat fisik dapat digunakan nanti setelah disiapkan dan terdeteksi oleh `flutter devices`.

## Struktur dan fitur

| File | Peran |
| --- | --- |
| `lib/main.dart` | Entry point, `MyApp`, dan konfigurasi MaterialApp |
| `lib/menu.dart` | `MyHomePage` stateless, model `ItemHomepage`, reusable `InfoCard` dan `ItemCard` |
| `lib/theme.dart` | Material 3, `ColorScheme.fromSeed`, dan palet portofolio light/dark |
| `examples/halo_haikal.dart` | Latihan program console Dart |
| `test/widget_test.dart` | Test identitas, SnackBar, layout, teks besar, tema, keyboard, dan kontras |
| `scripts/qa_web.cjs` | Pemeriksaan build rilis lewat Chrome/Playwright |
| `android/`, `ios/`, `web/`, dan folder desktop | Wrapper platform hasil Flutter create |

`Scaffold` menyediakan AppBar, body, dan SnackBar. Body menyusun `Padding`, `Column`, `Row`, `InfoCard`, dan `GridView.count`; kartu menu memakai Material/InkWell untuk ripple dan respons tap. Nama panjang tetap tampil lengkap; grid dan kartu menyesuaikan layar sempit serta pembesaran teks.


## Pengujian

```bash
dart run examples/halo.dart
flutter analyze
flutter test
flutter test --platform chrome
flutter build web --no-web-resources-cdn
flutter doctor -v
```

Hasil lokal 11 November 2026:

- `flutter analyze`: **No issues found**.
- **14 test widget lulus** pada Flutter tester dan **14 test lulus** pada Chrome.
- **30 pemeriksaan browser build rilis lulus**, meliputi desktop/mobile/narrow, light/dark, lima SnackBar, identitas, dan keyboard.
- Counter awal, menu akhir, serta hot reload berjalan lewat Chrome.
- Flutter doctor: Android toolchain dan Chrome, native iOS/macOS belum siap karena Xcode/CocoaPods belum lengkap.

