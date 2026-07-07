plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.stocklearn.stock_market_game_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.stocklearn.stock_market_game_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

fun deleteAppleDoubleFiles(dir: File) {
    if (!dir.exists()) return
    dir.walkBottomUp().forEach { file ->
        if (file.name.startsWith("._")) {
            try {
                file.delete()
            } catch (e: Exception) {
                // ignore deletion errors
            }
        }
    }
}

tasks.register("cleanAppleDouble") {
    doLast {
        deleteAppleDoubleFiles(project.projectDir)
        deleteAppleDoubleFiles(layout.buildDirectory.get().asFile)
    }
}

tasks.configureEach {
    if (name.contains("merge") || name.contains("parse") || name.contains("package") || name.contains("process")) {
        if (name != "cleanAppleDouble") {
            dependsOn("cleanAppleDouble")
        }
    }
}
