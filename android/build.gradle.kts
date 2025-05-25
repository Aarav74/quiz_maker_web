buildscript {
    ext.kotlin_version = '1.9.22' // Match Flutter's Kotlin version
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.1.2") // Flutter-compatible version
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version")
        classpath("com.google.gms:google-services:4.4.0") // If using Firebase
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://jitpack.io") } // For additional dependencies
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}

// Safe build directory configuration (removed custom dir setting)
subprojects {
    afterEvaluate {
        if (project.hasProperty("android")) {
            configure<com.android.build.gradle.BaseExtension> {
                compileSdkVersion(34) // Match Flutter's compileSdkVersion
                ndkVersion = "25.1.8937393" // Recommended NDK version
                
                defaultConfig {
                    minSdk = 21 // Flutter's default minSdk
                    targetSdk = 34 // Match Flutter's target
                }
                
                compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_17
                    targetCompatibility = JavaVersion.VERSION_17
                }
                
                kotlinOptions {
                    jvmTarget = "17"
                }
            }
        }
    }
    
    // Dependency for multi-module projects
    project.evaluationDependsOn(":app")
}