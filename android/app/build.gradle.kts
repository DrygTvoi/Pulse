import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load key.properties for release signing
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

android {
    namespace = "im.pulse.messenger"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "im.pulse.messenger"
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // Priority: key.properties file → CI environment variables → skip (debug fallback).
            // CI usage:
            //   KEYSTORE_STORE_PASSWORD=... KEYSTORE_KEY_PASSWORD=... \
            //   KEYSTORE_KEY_ALIAS=pulse    KEYSTORE_STORE_FILE=/path/to/pulse-release.jks \
            //   flutter build apk --release --dart-define=SENTRY_DSN=https://...
            val storePass   = keystoreProperties.getProperty("storePassword")
                ?: System.getenv("KEYSTORE_STORE_PASSWORD")
            val keyPass     = keystoreProperties.getProperty("keyPassword")
                ?: System.getenv("KEYSTORE_KEY_PASSWORD")
            val alias       = keystoreProperties.getProperty("keyAlias")
                ?: System.getenv("KEYSTORE_KEY_ALIAS")
            val storeFilePath = keystoreProperties.getProperty("storeFile")
                ?: System.getenv("KEYSTORE_STORE_FILE")

            if (storePass != null && keyPass != null && alias != null && storeFilePath != null) {
                keyAlias      = alias
                keyPassword   = keyPass
                storeFile     = file(storeFilePath)
                storePassword = storePass
            }
        }
    }

    // Helper: true when signing credentials are available from any source.
    val hasSigningCredentials = keystorePropertiesFile.exists()
        || System.getenv("KEYSTORE_STORE_PASSWORD") != null

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = if (hasSigningCredentials) {
                signingConfigs.getByName("release")
            } else {
                // No credentials available — debug-signed APK. Do NOT upload to Play Store.
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    // SQLCipher: bundles libsqlcipher.so for arm64, arm32, x86, x86_64.
    // Dart FFI loads it via DynamicLibrary.open('libsqlcipher.so').
    implementation("net.zetetic:android-database-sqlcipher:4.5.4@aar") {
        isTransitive = true
    }
}
