import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") apply false
}

// Push needs the Firebase project's config file, which is not committed (docs/FIREBASE.md).
// Without it the app still builds and runs with push unavailable.
if (file("google-services.json").exists()) {
    apply(plugin = "com.google.gms.google-services")
} else {
    logger.lifecycle("android/app/google-services.json not found: building without push (docs/FIREBASE.md)")
}

// Release signing with the upload key (docs/RELEASE_ANDROID.md). android/key.properties is not
// committed (see key.properties.example); without it, release builds are signed with the debug key,
// which is enough for `flutter run --release` and CI checks but is rejected by Google Play.
val keyProperties = Properties()
val keyPropertiesFile = rootProject.file("key.properties")
val hasUploadKey = keyPropertiesFile.exists()
if (hasUploadKey) {
    keyPropertiesFile.inputStream().use { keyProperties.load(it) }
} else {
    logger.lifecycle("android/key.properties not found: release builds use the debug key (docs/RELEASE_ANDROID.md)")
}

android {
    namespace = "tech.tetengo.te_tengo"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "tech.tetengo.te_tengo"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // From pubspec.yaml `version: <versionName>+<versionCode>` (or --build-name/--build-number).
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasUploadKey) {
            create("release") {
                // storeFile is relative to android/app/.
                storeFile = file(keyProperties.getProperty("storeFile"))
                storePassword = keyProperties.getProperty("storePassword")
                keyAlias = keyProperties.getProperty("keyAlias")
                keyPassword = keyProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName(if (hasUploadKey) "release" else "debug")
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
