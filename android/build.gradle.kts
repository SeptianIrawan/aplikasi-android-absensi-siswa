// INI ADALAH ISI FILE C:\apk\aplikasi_absensi_sederhana\android\build.gradle.kts
// (FILE ROOT PROYEK ANDA)

plugins {
    id("com.android.application") apply false
    id("com.android.library") apply false

    // Ubah versi yang Anda deklarasikan ke 4.3.15
    id("com.google.gms.google-services") version "4.4.1" apply false 

    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
    id("dev.flutter.flutter-gradle-plugin")
}
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Pastikan baris-baris modifikasi buildDirectory yang non-standar sudah dihapus/dikomentari
// val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
// rootProject.layout.buildDirectory.value(newBuildDir)
// subprojects {
//     val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
//     project.layout.buildDirectory.value(newSubprojectBuildDir)
// }


subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}