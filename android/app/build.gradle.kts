plugins { id("com.android.application") }
android {
    namespace = "com.oanarinaldi.drawthrough"
    compileSdk = 36
    defaultConfig {
        applicationId = "com.oanarinaldi.drawthrough"
        minSdk = 29
        targetSdk = 36
        versionCode = 1
        versionName = "1.0.0"
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    signingConfigs {
        providers.environmentVariable("DRAWTHROUGH_UPLOAD_KEYSTORE").orNull?.let { path ->
            create("upload") {
                storeFile = file(path)
                storePassword = providers.environmentVariable("DRAWTHROUGH_UPLOAD_STORE_PASSWORD").get()
                keyAlias = providers.environmentVariable("DRAWTHROUGH_UPLOAD_KEY_ALIAS").get()
                keyPassword = providers.environmentVariable("DRAWTHROUGH_UPLOAD_KEY_PASSWORD").get()
            }
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.findByName("upload")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}
dependencies {
    implementation("androidx.activity:activity:1.13.0")
    implementation("androidx.webkit:webkit:1.15.0")
    implementation("androidx.core:core:1.17.0")
    implementation("androidx.exifinterface:exifinterface:1.4.1")
    androidTestImplementation("androidx.test:runner:1.7.0")
    androidTestImplementation("androidx.test.ext:junit:1.3.0")
}
