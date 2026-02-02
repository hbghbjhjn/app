#!/usr/bin/env bash
set -euo pipefail

# מנקה אם כבר קיים (לא חובה; אפשר להסיר אם אתה רוצה לשמור דברים קיימים)
# rm -rf app gradle build.gradle.kts settings.gradle.kts gradle.properties gradlew gradlew.bat

mkdir -p .github/workflows
mkdir -p .github/commands

mkdir -p app/src/main/java/com/example/helloworld
mkdir -p app/src/main/res/layout
mkdir -p app/src/main/res/values
mkdir -p gradle/wrapper

cat > README.md <<'EOF'
# Android Hello World (שלום עולם)

This repository contains a minimal Android app that displays **"שלום עולם"**
and a GitHub Actions command runner that can:
- initialize the Android project
- build a Debug APK

## Command Center
Use Issue #1 (Command Center) and comment in this format:
`RUN <command> TOKEN=<your_token>`

Allowed commands:
- `init_android`
- `build_apk`

## Get the APK
After `build_apk`, go to **Actions → Command Runner → Artifacts** and download `app-debug-apk`.
EOF

cat > settings.gradle.kts <<'EOF'
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "HelloWorld"
include(":app")
EOF

cat > build.gradle.kts <<'EOF'
plugins {
    id("com.android.application") version "8.2.2" apply false
    id("org.jetbrains.kotlin.android") version "1.9.22" apply false
}
EOF

cat > gradle.properties <<'EOF'
org.gradle.jvmargs=-Xmx2g -Dfile.encoding=UTF-8
android.useAndroidX=true
android.nonTransitiveRClass=true
kotlin.code.style=official
EOF

cat > app/build.gradle.kts <<'EOF'
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.example.helloworld"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.helloworld"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.11.0")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")
}
EOF

cat > app/proguard-rules.pro <<'EOF'
# empty
EOF

cat > app/src/main/AndroidManifest.xml <<'EOF'
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <application
        android:label="@string/app_name"
        android:allowBackup="true"
        android:supportsRtl="true">

        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

    </application>
</manifest>
EOF

cat > app/src/main/java/com/example/helloworld/MainActivity.kt <<'EOF'
package com.example.helloworld

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
    }
}
EOF

cat > app/src/main/res/layout/activity_main.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <TextView
        android:id="@+id/helloText"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="שלום עולם"
        android:textSize="28sp"
        app:layout_constraintTop_toTopOf="parent"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintEnd_toEndOf="parent" />

</androidx.constraintlayout.widget.ConstraintLayout>
EOF

cat > app/src/main/res/values/strings.xml <<'EOF'
<resources>
    <string name="app_name">HelloWorld</string>
</resources>
EOF

cat > gradle/wrapper/gradle-wrapper.properties <<'EOF'
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.2-bin.zip
EOF

# wrapper scripts - הכי קל: להוסיף אותם מ-Gradle wrapper מקומי,
# אבל כדי שזה יעבוד ב-Actions, מספיק שניצור wrapper דרך gradle (אחרי שיש gradlew).
# כאן נשים גרסה מינימלית: נדרוש שהריצה הראשונה תהיה דרך setup (לוקאלי/סטודיו).
# כדי שזה יעבוד בלי לוקאלי, ניצור gradlew פשוט שמוריד wrapper? זה מסובך.
# פתרון פרקטי: ניצור gradlew ע"י שימוש ב-Gradle distribution ב-Actions.
# אבל build_apk ינסה ./gradlew. לכן נוסיף Gradle wrapper מינימלי ע"י קבצים סטנדרטיים:
# (הדרך הנקייה: להעתיק gradlew/gradlew.bat קנוניים. נשים אותם כאן.)

cat > gradlew <<'EOF'
#!/usr/bin/env sh
# Minimal Gradle wrapper script (standard)
DIR="$(cd "$(dirname "$0")" && pwd)"
WRAPPER_JAR="$DIR/gradle/wrapper/gradle-wrapper.jar"
PROPS="$DIR/gradle/wrapper/gradle-wrapper.properties"

if [ ! -f "$WRAPPER_JAR" ]; then
  echo "Missing gradle-wrapper.jar. Please add it (standard Gradle wrapper) or run 'gradle wrapper' locally once and commit."
  exit 1
fi

exec java -jar "$WRAPPER_JAR" "$@"
EOF
chmod +x gradlew

cat > gradlew.bat <<'EOF'
@echo off
set DIR=%~dp0
set WRAPPER_JAR=%DIR%gradle\wrapper\gradle-wrapper.jar

if not exist "%WRAPPER_JAR%" (
  echo Missing gradle-wrapper.jar. Please add it (standard Gradle wrapper) or run gradle wrapper locally once and commit.
  exit /b 1
)

java -jar "%WRAPPER_JAR%" %*
EOF

# NOTE: gradle-wrapper.jar אינו כאן. צריך להוסיף אותו פעם אחת.
# הדרך הכי פשוטה:
# 1) פותחים את הפרויקט באנדרואיד סטודיו -> הוא ייצור wrapper
# או:
# 2) מריצים מקומית: gradle wrapper (עם Gradle מותקן) ואז commit ל-jar.

echo "Initialized project files. NOTE: need gradle/wrapper/gradle-wrapper.jar committed once."
