"""Richtet eine frisch mit `flutter create` erzeugte App für das Repo ein:
App-Name (Android + Windows), Signierung mit dem Upload-Schlüssel aus
GitHub-Secrets, minSdk 23.

Aufruf:  python3 tools/app_einrichten.py <ordner> "<Anzeigename>" [--desugaring]
"""
import re
import sys
from pathlib import Path

WURZEL = Path(__file__).resolve().parent.parent


def main():
    ordner, name = sys.argv[1], sys.argv[2]
    desugaring = "--desugaring" in sys.argv
    app = WURZEL / "apps" / ordner

    manifest = app / "android/app/src/main/AndroidManifest.xml"
    text = manifest.read_text()
    text = re.sub(r'android:label="[^"]*"', f'android:label="{name}"', text, count=1)
    manifest.write_text(text)

    gradle = app / "android/app/build.gradle.kts"
    text = gradle.read_text()
    if "key.properties" not in text:
        text = text.replace(
            "plugins {",
            "import java.util.Properties\n\nplugins {",
            1,
        )
        text = text.replace(
            "android {",
            '''// Upload-Schlüssel für Google Play. android/key.properties wird nie
// eingecheckt – in GitHub Actions entsteht sie aus den Secrets.
val schluessel = Properties().apply {
    val datei = rootProject.file("key.properties")
    if (datei.exists()) datei.inputStream().use { load(it) }
}

android {''',
            1,
        )
        text = re.sub(
            r"    buildTypes \{.*?\n    \}\n",
            '''    signingConfigs {
        if (schluessel.containsKey("storeFile")) {
            create("upload") {
                storeFile = rootProject.file(schluessel.getProperty("storeFile"))
                storePassword = schluessel.getProperty("storePassword")
                keyAlias = schluessel.getProperty("keyAlias")
                keyPassword = schluessel.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // Mit Upload-Schlüssel, falls vorhanden – sonst Debug-Schlüssel
            // (reicht für Test-APKs).
            signingConfig = signingConfigs.findByName("upload")
                ?: signingConfigs.getByName("debug")
        }
    }
''',
            text,
            count=1,
            flags=re.S,
        )
        text = text.replace("minSdk = flutter.minSdkVersion", "minSdk = maxOf(flutter.minSdkVersion, 23)")
        text = text.replace(
            "        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).\n",
            "",
        )
    if desugaring and "isCoreLibraryDesugaringEnabled" not in text:
        text = text.replace(
            "        targetCompatibility = JavaVersion.VERSION_17\n",
            "        targetCompatibility = JavaVersion.VERSION_17\n"
            "        // Für Erinnerungen (flutter_local_notifications).\n"
            "        isCoreLibraryDesugaringEnabled = true\n",
            1,
        )
        text += '\ndependencies {\n    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")\n}\n'
    gradle.write_text(text)

    for datei in ["windows/runner/main.cpp", "windows/runner/Runner.rc"]:
        pfad = app / datei
        if pfad.exists():
            text = pfad.read_text()
            text = text.replace(f'L"{ordner}"', f'L"{name}"')
            text = text.replace(f'"FileDescription", "{ordner}"', f'"FileDescription", "{name}"')
            text = text.replace(f'"ProductName", "{ordner}"', f'"ProductName", "{name}"')
            pfad.write_text(text)
    print("✓", ordner, "→", name)


if __name__ == "__main__":
    main()
