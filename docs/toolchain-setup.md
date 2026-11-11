# Toolchain Tutorial 08 pada macOS

Diperiksa 11 November 2026 pada macOS 26.5.1, Apple Silicon arm64.

| Komponen | Hasil |
| --- | --- |
| Flutter | stable 3.47.8, `/opt/homebrew/share/flutter` |
| Dart bawaan Flutter | 3.13.7; symlink `/opt/homebrew/bin/dart` |
| Android Studio | Rabbit 2, 2026.2.2, `/Applications/Android Studio.app` |
| Command-line tools | paket Homebrew 15859902 dan paket SDK `cmdline-tools;latest` |
| Android SDK | `/Users/Pedro/Library/Android/sdk`, Android 36, Build-Tools 36.0.0 |
| Platform-Tools | adb 37.0.1; CLI `adb version` berhasil |
| Emulator | 37.2.13, belum ada AVD dan belum dijalankan |
| Java untuk Flutter | OpenJDK 21.0.8 yang sudah terpasang; dipilih lewat `flutter config --jdk-dir` |
| Editor | VS Code dengan Flutter/Dart resmi 3.146.0 |
| Chrome | Terdeteksi oleh `flutter devices`; runtime browser dan widget tests berhasil |

## Instalasi yang dilakukan

```bash
brew install --cask flutter
brew install --cask android-commandlinetools
brew install --cask android-studio
code --install-extension Dart-Code.flutter --install-extension Dart-Code.dart-code
```

SDK Android dipasang pada direktori pengguna melalui SDK Manager: `cmdline-tools;latest`, `platform-tools`, `platforms;android-36`, `build-tools;36.0.0`, dan `emulator`. Flutter dikonfigurasi memakai SDK tersebut dan JDK 21, dengan perintah:

```bash
flutter config --android-sdk /Users/Pedro/Library/Android/sdk
flutter config --jdk-dir /opt/homebrew/Cellar/openjdk@21/21.0.8/libexec/openjdk.jdk/Contents/Home
flutter doctor --android-licenses
flutter doctor -v
```

Lisensi diselesaikan dan Flutter doctor mengonfirmasi semuanya diterima. Android CLI versi baru memberi peringatan bahwa `sdkmanager` digantikan Android CLI dan `--licenses` tidak lagi diperlukan; warning tersebut tidak menunjukkan kegagalan pemasangan pada hasil ini.

## PATH dan IDE

Flutter/Dart menggunakan PATH Homebrew yang sudah ada. Konfigurasi Android berikut ditambahkan secara idempotent ke `.zprofile`:

```bash
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
```

Profil sebelumnya dicadangkan di `/Users/Pedro/.zprofile.before-tutorial08`. Buka terminal baru agar variabel baru terbaca. Java default sistem tidak diganti; hanya konfigurasi Java milik Flutter yang dipilih ke JDK 21.

File `.vscode/extensions.json` merekomendasikan ekstensi Flutter/Dart, dan `.vscode/settings.json` mengaktifkan formatter Dart. SDK Android dapat dilihat/dikelola melalui SDK Manager Android Studio maupun CLI.

## Diagnostik yang tersisa

Lihat [output aktual flutter doctor](flutter-doctor.txt). Android toolchain dan Chrome siap. Xcode lengkap serta CocoaPods belum dipasang, sehingga native iOS/macOS belum siap. Tutorial menggunakan Chrome, sementara menjalankan Android emulator/perangkat fisik merupakan opsi tambahan. Tidak ada hasil build native yang diklaim.

Referensi: [instalasi Flutter](https://docs.flutter.dev/install), [setup Android](https://docs.flutter.dev/platform-integration/android/setup), dan [SDK Manager](https://developer.android.com/tools/sdkmanager).
