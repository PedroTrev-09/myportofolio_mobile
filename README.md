# MyPortfolio Mobile

**Nama:** Haikal Rafka A Rahman  
**NPM:** 2506553383  
**Kelas:** PBP A

## Progres

- Tugas 08 (Done)
- Tutorial 09 (Done)
- Tutorial 08 (Done)
- Tugas 7 (Done)

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
dart run examples/halo_haikal.dart
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


## Tugas 7: implementasi

Aplikasi tetap berupa menu portofolio statis. Nama, NPM, dan kelas tampil melalui tiga `InfoCard`. Lima `ItemCard` yang sudah ada sejak tutorial adalah Lihat Proyek, Tambah Proyek, Lihat Pengalaman, Tambah Pengalaman, dan Logout. Jumlah ini memenuhi ketentuan minimal tiga tombol. Masing-masing mempunyai ikon, label, dan warna latar unik dari model `ItemHomepage`; `ItemCard` membaca `item.color` tanpa percabangan berdasarkan nama tombol.

Ketika disentuh, semua kartu hanya menampilkan pesan `Kamu telah menekan tombol [Nama Tombol]!`. Logout juga hanya menampilkan SnackBar, sesuai tahap tugas ini. Tidak ada penambahan halaman, login, penyimpanan item, atau integrasi Django pada Tugas 7.

Langkah pengerjaan:

1. Melanjutkan proyek Tutorial 08 dengan pemisahan `main.dart` dan `menu.dart`, serta mempertahankan `MyHomePage` sebagai `StatelessWidget`.
2. Memeriksa identitas asli pemilik, minimal tiga aksi, warna latar yang berbeda, dan kecocokan isi SnackBar.
3. Merapikan konstruktor `ItemHomepage` dengan parameter bernama agar warna latar dan warna teks tidak tertukar ketika daftar menu dibaca atau diubah.
4. Memeriksa model warna dan kartu yang ditampilkan melalui widget test, lalu menjalankan analisis serta build web.
5. Menyiapkan dokumentasi dan jawaban reflektif di bawah untuk ditinjau pemilik sebelum README di-commit.

Hasil validasi Tugas 7 pada 16 November 2026:

- `flutter analyze --no-pub`: **No issues found**.
- `flutter test --no-pub`: **15 test lulus**, termasuk pemeriksaan warna model benar-benar dipakai sebagai latar kartu yang tampil.
- `flutter build web --no-web-resources-cdn --no-pub`: berhasil.
- Pemeriksaan browser build rilis: **30 pemeriksaan lulus** untuk desktop, ponsel, layar sempit, tema terang/gelap, identitas, kelima SnackBar, dan keyboard.
- Tidak ada fitur baru di luar menu statis yang diminta. README masih merupakan perubahan lokal untuk review dan belum dimasukkan ke commit Tugas 7. Branch belum di-push atau digabungkan ke main.

### Tugas 7

1. **Widget tree dan hubungan parent-child**

   Widget tree adalah susunan hierarkis widget yang mendeskripsikan antarmuka Flutter. Widget induk menampung anak lewat properti seperti `child`, `children`, `body`, atau `home`. Induk memberikan batas ukuran kepada anak; anak menentukan ukurannya dalam batas itu, lalu induk mengatur posisinya. Data tampilan dapat diteruskan melalui parameter konstruktor, misalnya `InfoCard(title: 'NPM', content: npm)`. Sebaliknya, interaksi anak dapat diberitahukan kepada induk melalui callback bila diperlukan.

   Di proyek ini, `MyApp` menghasilkan `MaterialApp`, yang membuka `MyHomePage` melalui `home`. Halaman membangun `Scaffold`, lalu bagian `body` berisi layout profil dan menu. `GridView.count` menampung beberapa `ItemCard`; setiap kartu membangun `Material` dan `InkWell`, lalu ikon serta teks. Memakai widget reusable membuat setiap kartu memiliki struktur yang konsisten. Widget adalah konfigurasi immutable; Flutter memelihara element tree untuk menghubungkan konfigurasi tersebut dengan posisi dan siklus hidupnya, serta render tree untuk layout dan penggambaran.

2. **Widget yang digunakan dan fungsinya**

   Daftar berikut mencakup widget yang dipanggil secara langsung dalam kode aplikasi `lib/`, bukan seluruh widget internal yang dibangun framework.

   | Widget | Fungsi pada proyek |
   | --- | --- |
   | `MyApp` | Widget root buatan proyek yang menyusun konfigurasi aplikasi. |
   | `MaterialApp` | Menyediakan kerangka aplikasi Material, tema, serta halaman awal. |
   | `MyHomePage` | Halaman menu stateless yang menampilkan identitas dan daftar aksi. |
   | `Scaffold` | Struktur halaman dengan AppBar, body, dan tempat tampilan SnackBar. |
   | `AppBar` | Menampilkan judul MyPortfolio pada bagian atas halaman. |
   | `Text` | Menampilkan judul, identitas, deskripsi, label menu, footer, dan pesan SnackBar. |
   | `Icon` | Menampilkan simbol menu serta dekorasi matahari pada AppBar. |
   | `Padding` | Memberikan ruang di sekeliling isi halaman, kartu, dan ikon AppBar. |
   | `SafeArea` | Menjaga body dari bagian layar yang terhalang antarmuka sistem. |
   | `SingleChildScrollView` | Membuat halaman dapat digulir ketika konten melebihi tinggi layar. |
   | `Center` | Memusatkan area konten dalam ruang halaman yang tersedia. |
   | `ConstrainedBox` | Membatasi lebar maksimal konten agar nyaman dibaca pada desktop. |
   | `Column` | Menyusun elemen secara vertikal, termasuk isi kartu dan bagian halaman. |
   | `Row` | Menyusun kartu identitas secara horizontal ketika ruang mencukupi. |
   | `Expanded` | Membagi ruang horizontal Row untuk kartu identitas. |
   | `SizedBox` | Memberikan jarak antarbagian dan lebar penuh isi InfoCard. |
   | `LayoutBuilder` | Membaca batas ukuran dari induk untuk memilih susunan identitas dan ukuran grid. |
   | `InfoCard` | Komponen reusable untuk pasangan judul dan nilai identitas. |
   | `Card` | Wadah visual kartu identitas dengan bentuk dan warna dari tema. |
   | `GridView.count` | Menyusun ItemCard dalam grid; jumlah kolom menyesuaikan ruang dan ukuran teks. |
   | `ItemCard` | Komponen reusable untuk satu aksi portofolio. |
   | `Semantics` | Menandai kartu aksi sebagai tombol untuk teknologi bantu. |
   | `Material` | Memberikan permukaan, warna latar, bentuk kartu, dan tempat efek tinta. |
   | `InkWell` | Menangani tap, fokus keyboard, dan efek ripple pada kartu aksi. |
   | `SnackBar` | Menampilkan konfirmasi nama tombol yang ditekan. |

   `Theme`, `MediaQuery`, dan `Directionality` juga dibaca melalui context untuk memperoleh tema, skala teks, serta arah tulisan. `ScaffoldMessenger.of(context)` digunakan untuk mengelola SnackBar; host-nya disediakan oleh `MaterialApp`. `MediaQuery` diinstansiasi secara langsung pada pembungkus pengujian untuk mensimulasikan ukuran layar dan pembesaran teks.

   `ItemHomepage` bukan widget, melainkan model data tombol. `ThemeData`, `ColorScheme`, `TextStyle`, `TextPainter`, `BoxConstraints`, dan `ValueKey` juga bukan widget: masing-masing berperan sebagai konfigurasi tema, skema warna, gaya teks, pengukur teks, batas ukuran, atau identitas widget.

3. **Fungsi MaterialApp dan alasan dipakai dekat root**

   `MaterialApp` menyiapkan layanan umum aplikasi bergaya Material. Dalam proyek ini, `title` memberi nama aplikasi, `theme` dan `darkTheme` mengatur tampilan, `home` membuka `MyHomePage`, dan banner debug disembunyikan. Widget ini juga menyediakan infrastruktur yang diperlukan untuk pengelolaan rute serta SnackBar melalui layanan turunannya.

   Menempatkannya dekat root membuat konfigurasi aplikasi tersedia bagi halaman-halaman di bawahnya dan menghindari pengaturan ulang pada setiap kartu. Root yang diberikan ke `runApp` di proyek ini sebenarnya `MyApp`; `MaterialApp` dikembalikan oleh `MyApp.build`. MaterialApp bukan kewajiban untuk seluruh aplikasi Flutter: aplikasi dengan pendekatan lain dapat memakai `CupertinoApp` atau `WidgetsApp`.

4. **StatelessWidget dan StatefulWidget**

   `StatelessWidget` mendeskripsikan UI berdasarkan konfigurasi yang diterimanya dan data dari context, tanpa objek `State` lokal yang dapat dimutasi. Stateless tetap dapat dibangun ulang, misalnya ketika induknya memperbarui konfigurasi atau tema berubah. Jadi, stateless tidak berarti tampilannya tidak pernah berubah atau tidak dapat menerima tap.

   `StatefulWidget` juga merupakan konfigurasi immutable, tetapi mempunyai objek `State` terpisah untuk menyimpan keadaan yang bertahan antar-build. Ketika keadaan lokal berubah melalui `setState`, Flutter menjadwalkan pembangunan ulang bagian UI terkait. Contohnya adalah input formulir, counter, atau pilihan filter yang dikelola secara lokal.

   `MyHomePage`, `InfoCard`, dan `ItemCard` memakai StatelessWidget karena data yang ditampilkan tetap. Tap cukup meminta ScaffoldMessenger menampilkan SnackBar; kartu tidak perlu menyimpan variabel statusnya sendiri. StatefulWidget diperlukan bila pada tugas berikutnya suatu komponen benar-benar perlu mengelola perubahan keadaan lokal. Tidak perlu mengubah menu menjadi stateful hanya karena tombolnya dapat ditekan.

5. **BuildContext dan penggunaannya di build**

   `BuildContext` merepresentasikan posisi sebuah widget dalam tree. Parameter `context` pada `build` memungkinkan kode mencari layanan atau data dari ancestor yang sesuai. Contohnya, `Theme.of(context)` memperoleh tema, `MediaQuery.textScalerOf(context)` memperoleh skala teks, dan `ScaffoldMessenger.of(context)` menemukan pengelola SnackBar.

   Posisi context menentukan hasil pencarian. Context dari sebuah widget berada di atas subtree yang dikembalikan oleh build-nya; context itu tidak otomatis melihat provider baru di bawahnya. Bila membutuhkan context di dalam subtree tertentu, dapat digunakan widget anak atau Builder. Pada proyek ini, context ItemCard sudah berada di bawah MaterialApp dan layanan ScaffoldMessenger sehingga tap dapat menampilkan notifikasi.

   Context tidak sebaiknya disimpan untuk dipakai sembarangan setelah widget dilepas. Bila digunakan setelah operasi asynchronous, periksa `context.mounted` sebelum mengakses layanan UI.

6. **Hot reload, hot restart, dan full restart**

   | Mekanisme | Efek | Contoh penggunaan |
   | --- | --- | --- |
   | Hot reload | Memuat perubahan kode dan membangun ulang UI sambil mempertahankan state; tidak menjalankan ulang `main()` atau `initState()`. | Mengubah padding, teks, atau tampilan kartu. Pada terminal debug tekan `r`. |
   | Hot restart | Memulai ulang bagian Dart dan menjalankan `main()` kembali; state aplikasi direset. | Mengubah inisialisasi yang hanya berjalan saat startup. Pada terminal debug tekan `R`. |
   | Full restart | Menghentikan dan menjalankan aplikasi kembali, termasuk pembangunan ulang bagian platform bila diperlukan. | Mengubah kode native Kotlin/Java/Swift/Objective-C atau konfigurasi platform. |

   Hot reload tidak cukup jika perubahan harus mengeksekusi ulang inisialisasi atau tidak didukung oleh mekanisme reload, misalnya perubahan bentuk generic tertentu. Kesalahan kompilasi juga harus diperbaiki sebelum reload berhasil. Untuk perubahan kode Dart yang butuh state awal baru, gunakan hot restart; untuk perubahan native, gunakan full restart. Hot reload dan hot restart merupakan alat pengembangan pada mode debug, bukan fitur aplikasi rilis.

### Tugas 8

1. **Perbedaan push, pushReplacement, dan pop serta navigasi formulir**

   `Navigator.push()` menambahkan route di atas tumpukan sehingga halaman sebelumnya masih ada. Kartu **Tambah Pengalaman** memakainya untuk membuka `ExperienceFormPage` melalui `MaterialPageRoute`. Back bawaan perangkat atau browser dapat menutup route tersebut dan menampilkan menu sebelumnya.

   `Navigator.pushReplacement()` mengganti route teratas. Drawer menggunakan cara ini untuk membuka Home, Add Project, dan Tambah Pengalaman, sehingga perpindahan lewat drawer tidak terus menambahkan halaman. Saat Home dipilih, `Navigator.pop(context)` terlebih dahulu menutup drawer, lalu `pushReplacement()` mengganti halaman aktif dengan `MyHomePage`. Jika sebelumnya sudah ada route lain di bawahnya, route itu tetap ada; replacement bukan penghapusan seluruh riwayat. `Navigator.pop()` juga dipakai oleh tombol Tutup untuk menutup dialog ringkasan dan kembali ke form.

2. **Struktur halaman dan konsistensi tema**

   `Scaffold` menyediakan kerangka halaman, `AppBar` menampilkan judul, dan properti `drawer` memasang komponen `LeftDrawer` yang sama. Home, form proyek, dan form pengalaman berbagi menu navigasi tersebut, sehingga opsi Home dan Add Project tetap tersedia setelah form baru ditambahkan.

   Seluruh halaman memakai tema dari `MaterialApp`. Contohnya, warna utama portofolio dari `colorScheme.primary` dipakai pada judul AppBar melalui `AppBarTheme`, header drawer, dan tombol Simpan pada form pengalaman. Warna teks tombol mengambil `onPrimary` agar sesuai dengan latarnya. Tidak perlu membuat skema warna terpisah pada setiap halaman.

3. **Alasan memilih tata letak formulir**

   Form menggunakan `Column` karena enam isian dikerjakan berurutan: judul, kategori, lokasi, tanggal mulai, tanggal selesai opsional, dan deskripsi. Susunan satu kolom menjaga label dan isian tetap terbaca pada ponsel. `Padding` memberi ruang dari tepi layar, sedangkan `SizedBox` memberi jarak antarkolom input. `ConstrainedBox` membatasi lebar form pada layar besar, dan `Align` menempatkan tombol Simpan di tengah.

   `SingleChildScrollView` membuat bagian bawah form tetap dapat dijangkau ketika layar pendek, teks diperbesar, atau keyboard mengurangi ruang. `Scaffold` menggunakan perilaku resize untuk menyesuaikan body terhadap keyboard; `SafeArea` menjaga konten dari area antarmuka sistem. Isi dialog juga dapat digulir ketika deskripsi panjang. Tanggal menggunakan `showDatePicker`, sesuai tipe `DateField` model Experience, sedangkan kategori menggunakan dropdown enam pilihan yang sama dengan model.

4. **GlobalKey, validator, dan validate saat Simpan**

   `GlobalKey<FormState>` menghubungkan kode tombol dengan state `Form`. Ketika Simpan ditekan, `_formKey.currentState!.validate()` menjalankan validator setiap field. Validator mengembalikan pesan jika salah dan `null` jika valid. Dialog hanya dibuka bila seluruh validator lolos.

   Judul, lokasi, serta deskripsi harus berisi teks yang dapat dibaca; teks kosong, spasi, atau tag kosong ditolak. Judul dan lokasi maksimal 255 karakter mengikuti model Django. Kategori harus termasuk pilihan model. Tanggal mulai wajib, tanggal selesai opsional, dan tanggal selesai yang dipilih tidak boleh lebih awal dari tanggal mulai. Contoh: mulai `2026-01-10` dengan selesai `2026-01-09` ditolak. Selesai pada hari yang sama diperbolehkan; tanggal selesai kosong ditampilkan sebagai “Masih berlangsung”.

   Jenis keyboard hanya membantu pemasukan data dan tidak menjamin data sah. Date picker membantu memilih tanggal kalender yang valid, tetapi hubungan antara dua tanggal tetap membutuhkan validator. Form ini tidak mempunyai field URL karena model Experience yang dipilih memang tidak memilikinya. Ringkasan menampilkan seluruh enam isian; Tutup menutup dialog dan mempertahankan form. Pada tahap ini data belum disimpan atau dikirim ke Django.

#### Penggunaan AI pada Tugas 8

Saya menggunakan Codex untuk membantu menyusun form dan navigasi dan membuat serta menjalankan pengujian.

Bantuan AI tidak menggantikan pemeriksaan hasil. Aturan field saya cocokkan dengan model/form/validator backend yang dibaca langsung, hasil saya uji untuk input valid, tidak valid, navigasi, dan layar sempit. Keterbatasannya antara lain risiko salah memahami aturan model dan interaksi browser.