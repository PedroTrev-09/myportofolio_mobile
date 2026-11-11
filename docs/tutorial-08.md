# Tutorial 08 — Basic Flutter

Tanggal pengerjaan lokal: 11 November 2026. Proyek baru: `myportofolio_mobile`, terpisah dari backend Django `myportofolio`. Branch aktif: `tutorial-8`. Semua commit implementasi memakai awalan `tutorial-08:` dengan pesan langsung. Tidak ada push atau merge ke repositori backend.

## Checklist seluruh tahapan

| Bagian PDF | Implementasi/bukti |
| --- | --- |
| Flutter dan Dart | Flutter stable 3.47.8 dan Dart 3.13.7 dipasang melalui Homebrew. Dart memakai SDK bawaan Flutter; instalasi standalone dan DartPad adalah alternatif, bukan instalasi tambahan yang diperlukan. |
| PATH Flutter | Homebrew menyediakan symlink `flutter` dan `dart` di `/opt/homebrew/bin`, yang sudah tersedia pada PATH pengguna. Keduanya dijalankan dan versinya diperiksa. |
| Latihan program Dart | `examples/halo_haikal.dart`; `dart run examples/halo_haikal.dart` menghasilkan `Halo dari Dart, PBP Gasal 2026/2027!`. Aturan `avoid_print` hanya dikecualikan pada satu baris latihan console tersebut. |
| Android Studio | Android Studio Rabbit 2, 2026.2.2, dipasang melalui Homebrew; versi CLI terverifikasi. |
| Android SDK Tools | SDK pengguna di `/Users/Pedro/Library/Android/sdk`: command-line tools, Platform-Tools, Build-Tools 36.0.0, platform Android 36, dan Emulator 37.2.13 terpasang. |
| Java | Flutter dikonfigurasi memakai JDK 21 yang sudah ada. Java default sistem tidak diganti. Ini menghindari peringatan kompatibilitas Java 26 saat bootstrap. |
| Lisensi Android | Lisensi diselesaikan melalui SDK Manager. `flutter doctor --android-licenses` dijalankan; CLI Android terbaru menyatakan opsi itu tidak lagi diperlukan. `flutter doctor -v` mengonfirmasi **All Android licenses accepted**. |
| `flutter doctor` | Flutter, Android toolchain, Chrome, connected devices, dan network resources bertanda ✓. Output aktual disimpan di `docs/flutter-doctor.txt`. |
| IDE | Ekstensi resmi `Dart-Code.flutter` dan `Dart-Code.dart-code` versi 3.146.0 terpasang di VS Code; rekomendasi dan format-on-save proyek berada di `.vscode/`. |
| Pembuatan proyek | Dibuat menggunakan `flutter create`, termasuk wrapper Android/iOS/web/Linux/macOS/Windows, `pubspec.yaml`, lockfile, analisis linter, dan test. |
| Menjalankan aplikasi awal | Counter bawaan dijalankan lewat `flutter run -d chrome --web-run-headless`. Test counter awal juga lulus sebelum refactor. |
| Struktur direktori | `lib/` menyimpan kode Dart; `test/` widget tests; `pubspec.yaml` manifest; folder platform menyimpan wrapper native; `web/` metadata web; `examples/` latihan Dart. |
| Pemisahan halaman | `main.dart` berisi `main()`/`MyApp`; halaman dipindahkan ke `menu.dart`. Commit refactor tetap dapat dianalisis dan menjalankan test counter sebelum tahap stateless. |
| Tema | `ColorScheme.fromSeed` dan Material 3 di `lib/theme.dart`. Palet diadaptasi dari `static/css/style.css` backend: krem, merah dusk, oranye sunset, kuning midday, dan warna ink. |
| Stateless | `MyApp` dan `MyHomePage` memakai `StatelessWidget`; `_MyHomePageState`, counter, dan `setState` demo telah dihapus dari source akhir. |
| `InfoCard` | Widget reusable menerima `title`/`content`; memuat Nama, NPM, dan Kelas milik Haikal Rafka. |
| `ItemHomepage` | Model immutable dengan nama, `IconData`, serta warna latar/foreground agar menu mudah dibedakan dan tetap terbaca. |
| `ItemCard` | Material, InkWell, ikon, label, ripple, dan semantic button. Menggunakan `ScaffoldMessenger`, `hideCurrentSnackBar`, dan `showSnackBar`. |
| Menu inti | `Lihat Proyek`, `Tambah Proyek`, dan `Logout` dari tutorial tetap tersedia. `Lihat Pengalaman` dan `Tambah Pengalaman` disesuaikan dengan bagian Experience dari Tugas 3–6. |
| Integrasi widget tree | Scaffold, AppBar, Padding, Column, Row, GridView.count, InfoCard, dan ItemCard dipakai dalam halaman yang sama. |
| Responsivitas | Nama panjang tidak dipotong. Desktop menampilkan tiga InfoCard sejajar; ponsel menempatkan Nama di atas Row NPM/Kelas. Grid umumnya tiga kolom dan menjadi dua kolom untuk layar sempit/teks besar. |
| Scroll dan aksesibilitas | SafeArea dan SingleChildScrollView menjaga konten tetap dapat dijangkau. Ukuran kartu memperhitungkan tinggi label agar teks diperbesar tidak overflow. Keyboard/kontras juga diuji. |
| Hot reload | Menu akhir dijalankan di Chrome; perintah `r` berhasil dengan keluaran `Reloaded application in 155ms`. |
| Analisis kode | `flutter analyze`: **No issues found**. Pemformatan Dart diperiksa. |
| Git | Repositori lokal tersendiri, branch `tutorial-8`, commit progresif. `main` lokal merupakan baseline bootstrap; tutorial belum digabungkan ke main. |
| `.gitignore` | Build, `.dart_tool`, konfigurasi SDK lokal, cache dan file IDE pribadi tidak dilacak. Wrapper platform dan `pubspec.lock` aplikasi tetap dilacak. |
| README | Disiapkan untuk review pemilik dan sengaja tidak dimasukkan ke commit implementasi. |
| Publikasi | Belum membuat/push repositori GitHub publik dan belum mengirim tautan commit ke SCELE, sesuai instruksi **jangan langsung push**. |

Bagian instalasi Windows/Linux tidak diterapkan karena mesin pengembangan menggunakan macOS Apple Silicon. Pilihan Android emulator/perangkat fisik bersifat opsional dalam PDF: binary Emulator dipasang, tetapi tidak membuat AVD, menjalankan emulator, atau menguji perangkat fisik pada tahap ini. Target eksekusi yang diverifikasi adalah Chrome.

## Batas fitur tahap Tutorial 08

Aplikasi ini merupakan fondasi UI statis. Semua kartu, termasuk Logout, menampilkan konfirmasi tap melalui SnackBar sebagaimana tutorial. Belum ada login/session, CRUD mobile, pengambilan data DRF, atau pengubahan data backend. Identitas/palet memakai data proyek yang sudah ada; tidak menambahkan data portofolio palsu.

## Validasi yang dijalankan

- `dart --version` dan `flutter --version`: sukses.
- `dart run examples/halo_haikal.dart`: keluaran sesuai contoh tutorial.
- `flutter devices`: Chrome terdeteksi dan dipakai.
- `flutter run -d chrome --web-run-headless`: counter awal dan menu akhir berjalan.
- `flutter analyze`: tidak ada issue.
- `flutter test`: **14 test lulus**.
- `flutter test --platform chrome`: **14 test lulus**.
- `flutter build web --no-web-resources-cdn`: build rilis berhasil; dry run Wasm juga berhasil.
- `scripts/qa_web.cjs`: **30 pemeriksaan browser lulus** pada 1440×900, 390×844, dan 320×568, termasuk tema gelap, seluruh SnackBar, identitas, serta keyboard. Tidak ditemukan JavaScript exception.
- Metadata Android XML, iOS plist, dan web manifest berhasil diparse dan nama aplikasi sesuai.
- `git diff --check`: bersih. Root README belum di-commit; file itu tetap tersedia untuk pemilik.

Screenshot dan hasil QA web berada di `/tmp/myportofolio-mobile-qa/`. `QA_OUTPUT_DIR` dapat dipakai untuk mengubah lokasinya. Script menunggu inisialisasi render/font sebelum mengambil screenshot.

## Cara mengulang

```bash
cd /Users/Pedro/myportofolio_mobile
flutter pub get
dart run examples/halo_haikal.dart
flutter analyze
flutter test
flutter test --platform chrome
flutter run -d chrome
```

Untuk memeriksa build rilis:

```bash
flutter build web --no-web-resources-cdn
python3 -m http.server 8018 --bind 127.0.0.1 --directory build/web
```

Di terminal lain, runtime pengembangan ini dapat menjalankan QA:

```bash
cd /Users/Pedro/myportofolio_mobile
PLAYWRIGHT_MODULE=/Users/Pedro/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright \
/Users/Pedro/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin/node scripts/qa_web.cjs
```

Playwright/Node adalah alat QA eksternal dan tidak dibutuhkan untuk menjalankan aplikasi Flutter. Pada mesin lain sesuaikan lokasi Node, `PLAYWRIGHT_MODULE`, dan bila perlu `CHROME_PATH`.

## Batas toolchain dan pengumpulan

`flutter doctor` melaporkan satu kategori yang belum lengkap: Xcode/CocoaPods untuk native iOS/macOS. Target tersebut tidak dipakai pada tutorial ini dan tidak dinyatakan sudah diuji. Proyek menyediakan wrapper platform dari Flutter, tetapi build native Android/iOS/macOS/Windows/Linux belum diverifikasi.

Buat repositori GitHub **publik yang terpisah** dari Django saat siap publikasi. Review/commit README sendiri, lalu push branch tutorial atau gabungkan ke main sesuai alur pilihanmu. Tidak ada remote/push yang dibuat otomatis pada tahap lokal ini.

PDF meminta tautan commit GitHub yang di-push sebelum **Rabu, 11 November 2026, pukul 23.59 WIB**, lalu dikumpulkan ke slot SCELE. Penyelesaian lokal tidak sama dengan publikasi atau submisi yang sudah diterima.
