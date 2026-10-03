"""Erzeugt die rechtlichen Webseiten in public/ (python3 seiten.py)."""
STAND = '3. Oktober 2026'
KONTAKT = 'snakejoni10@yahoo.com'
P = lambda t: f'<span class="platzhalter">[{t}]</span>'

def seite(datei, titel, inhalt):
    html = f'''<!doctype html>
<html lang="de"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>{titel} – Austro Angler</title>
<link rel="icon" href="icon.png"><link rel="stylesheet" href="stil.css">
</head><body>
<header><a href="/"><img src="icon.png" alt="">Austro Angler</a></header>
<main>
{inhalt}
</main>
<footer><a href="/">Start</a> · <a href="datenschutz">Datenschutz</a> ·
<a href="nutzungsbedingungen">Nutzungsbedingungen</a> ·
<a href="konto-loeschen">Konto löschen</a> · <a href="impressum">Impressum</a></footer>
</body></html>
'''
    open(f'public/{datei}.html', 'w', encoding='utf-8').write(html)

seite('index', 'Start', f'''
<h1>Austro Angler</h1>
<p>Die Angel-App für den Bezirk Braunau und Umgebung (Oberösterreich und
Salzburg): Gewässer mit Lizenzinfos und Preisen, Fangbuch, Karte,
Fischlexikon mit Schonzeiten und Brittelmaßen, Fischerprüfung üben und eine
Community für Petri Heil unter Anglern.</p>
<p>Ohne Werbung. Keine Standortverfolgung – Orte gibst du immer selbst an.</p>
<nav><ul>
<li><a href="datenschutz">🔒 Datenschutzerklärung</a></li>
<li><a href="nutzungsbedingungen">📜 Nutzungsbedingungen &amp; Community-Regeln</a></li>
<li><a href="konto-loeschen">🗑️ Konto und Daten löschen</a></li>
<li><a href="impressum">ℹ️ Impressum</a></li>
</ul></nav>
<p class="klein">Kontakt: <a href="mailto:{KONTAKT}">{KONTAKT}</a></p>
''')

seite('datenschutz', 'Datenschutzerklärung', f'''
<h1>Datenschutzerklärung</h1>
<p class="klein">Stand: {STAND}</p>
<p>Hier steht in einfachen Worten, welche Daten die App „Austro Angler“
verarbeitet, wofür und welche Rechte du hast.</p>

<h2>1. Verantwortlich</h2>
<div class="karte">{P('Vor- und Nachname')}<br>{P('Straße Hausnummer')}<br>
{P('PLZ Ort')}, Österreich<br>E-Mail: <a href="mailto:{KONTAKT}">{KONTAKT}</a></div>

<h2>2. Was wir speichern</h2>
<table>
<tr><th>Daten</th><th>Wofür</th><th>Wer sieht es</th></tr>
<tr><td>E-Mail-Adresse und Passwort (verschlüsselt)</td><td>Anmeldung, Bestätigungs- und Passwort-Mails</td><td>Nur du (und technisch der Betreiber)</td></tr>
<tr><td>@Nutzername</td><td>Dein öffentlicher Name in der App</td><td>Alle angemeldeten Nutzer</td></tr>
<tr><td>Öffentliche Fänge: Fischart, Länge, Gewicht, Gewässer, Datum/Uhrzeit, Köder, Notiz, Foto, Wetter zur Fangzeit</td><td>Fangbuch, Feed, Rangliste, Challenge</td><td>Alle angemeldeten Nutzer</td></tr>
<tr><td>Private Fänge, eigene Angelplätze (selbst auf der Karte gewählt), Köder-Box, Angeltage</td><td>Dein persönliches Fangbuch</td><td>Nur du</td></tr>
<tr><td>Kommentare, „Petri Heil“, geplante Angeltage, Gewässerbewertungen</td><td>Community-Funktionen</td><td>Alle angemeldeten Nutzer</td></tr>
<tr><td>Freundesliste, blockierte Nutzer</td><td>Freunde-Feed, Blockieren</td><td>Nur du</td></tr>
<tr><td>Wünsche, Preisvorschläge, Meldungen</td><td>Verbesserung der App, Moderation</td><td>Betreiber (Wünsche auch andere Nutzer)</td></tr>
<tr><td>Premium-Status</td><td>Freischalten von Premium-Funktionen</td><td>Nur du und der Betreiber</td></tr>
</table>
<p><b>Standort:</b> Die App fragt <b>nie</b> nach deinem GPS-Standort und
verfolgt dich nicht. Orte wählst du immer selbst aus.</p>
<p><b>Auf dem Handy</b> (nicht in der Cloud) bleiben: Einstellungen
(z. B. Bundesland), Checkliste, Lizenzen mit Ablaufdatum und
Erinnerungen.</p>
<p><b>Keine Werbung, kein Tracking, kein Verkauf von Daten.</b></p>

<h2>3. Rechtsgrundlagen</h2>
<p>Wir verarbeiten deine Daten, um dir die App mit Konto bereitzustellen
(Vertrag, Art. 6 Abs. 1 lit. b DSGVO). Moderation und Schutz vor Missbrauch
erfolgen aufgrund berechtigter Interessen (Art. 6 Abs. 1 lit. f DSGVO).</p>

<h2>4. Dienstleister</h2>
<ul>
<li><b>Google Firebase</b> (Google Ireland Ltd., Gordon House, Barrow Street,
Dublin 4, Irland): Anmeldung (Firebase Authentication) und Datenbank
(Cloud Firestore). Google verarbeitet die Daten in unserem Auftrag; dabei
kann eine Übermittlung in die USA stattfinden (EU-US Data Privacy Framework
und Standardvertragsklauseln). <a href="https://firebase.google.com/support/privacy">Datenschutz bei Firebase</a></li>
<li><b>Open-Meteo</b> (Schweiz): Wetter, Abfluss und Beißzeit. Es werden nur
die Koordinaten der Gewässer bzw. des von dir gewählten Ortes übertragen,
keine Kontodaten. <a href="https://open-meteo.com/en/terms">Bedingungen</a></li>
<li><b>OpenStreetMap</b>: Kartenkacheln. Dabei wird wie bei jeder Webseite
deine IP-Adresse an die Kartenserver übertragen.
<a href="https://osmfoundation.org/wiki/Privacy_Policy">Datenschutz OSM</a></li>
<li><b>Google Play</b>: Download und (später) Abo-Zahlungen laufen über
Google. Wir bekommen dabei keine Zahlungsdaten.</li>
</ul>

<h2>5. Wie lange</h2>
<p>Solange du ein Konto hast. Wenn du dein Konto löschst, werden dein Profil,
deine Fänge, Fotos, privaten Daten, Freunde- und Blockierlisten sofort
gelöscht. Kommentare bei anderen und Meldungen können bis zu 30 Tage
länger bestehen bleiben, bis sie bereinigt sind.</p>

<h2>6. Kinder und Jugendliche</h2>
<p>Für ein Konto musst du mindestens 14 Jahre alt sein (§ 4 Abs. 4 DSG).
Wenn du jünger bist, brauchst du die Zustimmung deiner Eltern. Verwende
keinen echten Namen als @Nutzernamen und keine Fotos, auf denen man dich
oder andere klar erkennt, wenn du das nicht willst.</p>

<h2>7. Deine Rechte</h2>
<p>Du hast das Recht auf Auskunft, Berichtigung, Löschung, Einschränkung,
Datenübertragbarkeit und Widerspruch. Vieles kannst du direkt in der App
erledigen (Fänge bearbeiten/löschen, Konto löschen, PDF-Export). Sonst
schreib uns: <a href="mailto:{KONTAKT}">{KONTAKT}</a>.</p>
<p>Du kannst dich auch bei der österreichischen Datenschutzbehörde
beschweren: <a href="https://www.dsb.gv.at">www.dsb.gv.at</a>.</p>

<h2>8. Sicherheit</h2>
<p>Die Verbindung ist verschlüsselt (HTTPS). Sicherheitsregeln in der
Datenbank sorgen dafür, dass private Daten nur von dir gelesen werden
können.</p>

<h2>9. Änderungen</h2>
<p>Wenn sich etwas ändert, passen wir diese Seite an und weisen in der App
darauf hin.</p>
''')

seite('nutzungsbedingungen', 'Nutzungsbedingungen', f'''
<h1>Nutzungsbedingungen &amp; Community-Regeln</h1>
<p class="klein">Stand: {STAND}</p>

<h2>1. Worum es geht</h2>
<p>Austro Angler ist eine Info- und Community-App für Angler in
Oberösterreich und Salzburg. Mit dem Erstellen eines Kontos stimmst du
diesen Bedingungen zu.</p>

<h2>2. Ohne Gewähr</h2>
<p>Alle Angaben zu Schonzeiten, Brittelmaßen, Preisen, Gewässern, Wetter,
Abfluss und Beißzeiten sind sorgfältig recherchiert, aber <b>ohne Gewähr</b>.
Maßgeblich sind immer das jeweilige Landesfischereigesetz und die
Lizenzbedingungen des Reviers. Zum Fischen brauchst du eine gültige
Fischerkarte und eine Lizenz für das Gewässer. Die App ersetzt keine
Lizenz.</p>

<h2>3. Community-Regeln</h2>
<ul>
<li>Sei freundlich. Keine Beleidigungen, Drohungen, Hetze oder Mobbing.</li>
<li>Nur eigene Fotos hochladen – oder solche, für die du die Erlaubnis
hast. Keine Fotos von anderen Personen ohne deren Zustimmung.</li>
<li>Keine untermaßigen oder geschonten Fische als Entnahme zeigen und
nichts, was Tierquälerei verharmlost.</li>
<li>Keine Werbung, kein Spam, keine Fake-Fänge.</li>
<li>Keine privaten Daten anderer (Adressen, Telefonnummern …).</li>
<li>Angeltage: Trefft euch an öffentlichen Plätzen und sagt jemandem
Bescheid, wohin ihr geht.</li>
</ul>
<p>Du kannst Beiträge und Nutzer in der App <b>melden</b> und
<b>blockieren</b>. Wir prüfen Meldungen und können Inhalte löschen und
Konten sperren, wenn gegen die Regeln verstoßen wird.</p>

<h2>4. Deine Inhalte</h2>
<p>Deine Fänge, Fotos und Texte gehören dir. Damit wir sie in der App
anzeigen können, erlaubst du uns, sie innerhalb der App zu speichern und
anderen Nutzern zu zeigen. Löschst du sie, hören wir damit auf.</p>

<h2>5. Gratis und Premium</h2>
<p>Die Grundfunktionen sind gratis. Mit ⭐ markierte Funktionen werden nach
dem Start im Play Store Teil von <b>Premium</b> (3,99 € pro Monat oder
29,99 € pro Jahr, 7 Tage gratis testen). Bis dahin sind sie für alle
gratis. Abos laufen über Google Play und können dort jederzeit gekündigt
werden; es gelten die Bedingungen von Google Play. Gewinne der
Monats-Challenge (z. B. 1 Monat Premium) werden vom Betreiber vergeben;
ein Rechtsanspruch besteht nicht.</p>

<h2>6. Konto</h2>
<p>Halte dein Passwort geheim. Du kannst dein Konto jederzeit in der App
löschen (siehe <a href="konto-loeschen">Konto löschen</a>).</p>

<h2>7. Haftung</h2>
<p>Wir haften nur für Vorsatz und grobe Fahrlässigkeit, soweit das
gesetzlich zulässig ist. Für Inhalte anderer Nutzer sind diese selbst
verantwortlich.</p>

<h2>8. Recht</h2>
<p>Es gilt österreichisches Recht. Zwingende Verbraucherschutzrechte
bleiben unberührt.</p>

<p class="klein">Fragen: <a href="mailto:{KONTAKT}">{KONTAKT}</a></p>
''')

seite('konto-loeschen', 'Konto löschen', f'''
<h1>Konto und Daten löschen</h1>
<p>So löschst du dein Austro-Angler-Konto mit allen Daten:</p>

<h2>In der App (sofort)</h2>
<div class="karte"><ol>
<li>App öffnen und anmelden</li>
<li>Tab <b>Mehr</b> → <b>Mein Konto</b></li>
<li>Ganz unten <b>Konto löschen</b> tippen</li>
<li>Passwort eingeben und bestätigen</li>
</ol></div>

<h2>Ohne App (per E-Mail)</h2>
<p>Schreib von der E-Mail-Adresse deines Kontos an
<a href="mailto:{KONTAKT}?subject=Konto%20l%C3%B6schen">{KONTAKT}</a>
mit dem Betreff „Konto löschen“ und deinem @Nutzernamen. Wir löschen das
Konto innerhalb von 30 Tagen.</p>

<h2>Was gelöscht wird</h2>
<ul>
<li>Anmeldedaten (E-Mail, Passwort) und dein @Nutzername</li>
<li>Alle öffentlichen und privaten Fänge samt Fotos</li>
<li>Angelplätze, Köder-Box, Angeltage, Freunde, blockierte Nutzer,
Aktivitäten</li>
</ul>
<h2>Was bleiben kann</h2>
<ul>
<li>Kommentare unter Fängen anderer, Wünsche und Gewässerbewertungen
werden innerhalb von 30 Tagen entfernt oder anonymisiert.</li>
<li>Meldungen über Regelverstöße bis zu 6 Monate (zum Schutz der
Community).</li>
<li>Daten, die nur auf deinem Handy liegen, löschst du durch Deinstallieren
der App.</li>
</ul>
''')

seite('impressum', 'Impressum', f'''
<h1>Impressum</h1>
<p class="klein">Informationen gemäß § 5 ECG und § 25 MedienG</p>
<div class="karte">
<b>Medieninhaber und Betreiber der App „Austro Angler“:</b><br>
{P('Vor- und Nachname')}<br>
{P('Straße Hausnummer')}<br>
{P('PLZ Ort')}, Österreich<br>
E-Mail: <a href="mailto:{KONTAKT}">{KONTAKT}</a>
</div>
<p><b>Grundlegende Richtung:</b> Informationen rund ums Angeln in
Oberösterreich und Salzburg sowie eine Community für Angler.</p>
<p><b>Haftung für Inhalte:</b> Alle Angaben ohne Gewähr. Für Inhalte
von Nutzern sind diese selbst verantwortlich. Für Inhalte verlinkter
Seiten sind deren Betreiber verantwortlich.</p>
<p><b>Bildnachweise:</b> Fisch- und Knotenbilder von Wikimedia Commons
(Urheber und Lizenz stehen in der App beim jeweiligen Bild).
Kartendaten © OpenStreetMap-Mitwirkende. Wetterdaten: Open-Meteo.com
(CC BY 4.0).</p>
''')
print('fertig')
