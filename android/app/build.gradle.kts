plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.medrepo"
    compileSdk = flutter.compileSdkVersion
    //compileSdk = 34
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Change: Use 'is' prefix and '=' for Kotlin DSL
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.medrepo"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        //targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // Change: Use '=' for assignment
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // Change: dependencies block must be OUTSIDE the android block
}

// Move the dependencies block here, outside the android block
dependencies {
    // Change: Use function call syntax with parentheses
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
    implementation("androidx.multidex:multidex:2.0.1") 
}

flutter {
    source = "../.."
}