# app_werbung

AdMob für alle Apps – so, dass sie nicht nervt.

- **Nur Test-Anzeigen**, solange `WerbeIds.nurTest` gilt (Standard). Echte IDs erst
  nach dem Play-Store-Start eintragen, sonst droht die Sperre des AdMob-Kontos.
- `WerbeDienst.starten()`: holt die DSGVO-Einwilligung (Google UMP) und startet AdMob.
- `WerbeBanner`: Banner unten. Zeigt nichts, wenn Werbung aus ist (Pro/werbefrei).
- `WerbeDienst.belohnungZeigen()`: freiwilliges Video, gibt `true` zurück, wenn
  die Belohnung verdient wurde.
- `WerbeDienst.zwischenwerbung()`: nur zwischen zwei Aktionen, höchstens alle
  3 Minuten (`ZwischenwerbungsTakt`).

In der App nötig (`android/app/src/main/AndroidManifest.xml`, in `<application>`):

```xml
<meta-data android:name="com.google.android.gms.ads.APPLICATION_ID"
           android:value="ca-app-pub-3940256099942544~3347511713"/>
```

(Das ist die Test-App-ID von Google. Beim Start durch die echte ersetzen.)
