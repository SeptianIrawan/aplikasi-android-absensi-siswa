// settings.gradle.kts

pluginManagement { // Blok ini hanya boleh ADA SATU KALI
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal() // Ini juga sering ada di sini
    }
}

plugins {
    // Ini adalah blok 'plugins' di settings.gradle.kts (berbeda dengan build.gradle.kts)
    // yang biasanya digunakan untuk apply plugin pada root project
    id("dev.flutter.flutter-gradle-plugin") // Ini biasanya ada di sini
}

// Ini adalah direktori root project
rootProject.name = "aplikasi_absensi_sederhana"

// Ini adalah cara untuk menyertakan sub-proyek (seperti ':app')
include(":app")
// Tambahkan subproyek untuk setiap plugin Flutter Anda yang memiliki kode native Android
// Contoh:
include(":cloud_firestore")
include(":firebase_auth")
include(":firebase_core")
include(":path_provider_android")
// ... dan semua plugin lain yang punya folder 'android' di dalamnya