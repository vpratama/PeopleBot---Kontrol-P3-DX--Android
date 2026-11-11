// Mengatur plugin, target Android, dan opsi kompilasi aplikasi.
plugins {
    id("com.android.application")
    // Plugin Gradle Flutter harus diterapkan setelah plugin Android dan Kotlin.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "id.smartsystem.remote_control_apk"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Tentukan ID aplikasi unik untuk aplikasi ini.
        applicationId = "id.smartsystem.remote_control_apk"
        // Sesuaikan nilai berikut dengan kebutuhan aplikasi.
        // Lihat dokumentasi Flutter untuk penjelasan konfigurasi Gradle.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Kode versi berasal dari pubspec.yaml. Pada APK terpisah, Flutter menambahkan 1000 * ABI_VERSION
        // secara otomatis.
        // Untuk memakai nilai versionCode langsung, gunakan argumen
        // `-P force-version-code-ignoring-abi=true` saat proses build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Tambahkan konfigurasi penandatanganan untuk build rilis.
            // Saat ini build rilis memakai kunci debug agar `flutter run --release` dapat dijalankan.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
