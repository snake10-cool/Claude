/// Eigene Übungsfragen zur Fischerprüfung (kein offizieller Fragenkatalog).
class Frage {
  const Frage(this.thema, this.text, this.antworten, this.erklaerung);

  final String thema;
  final String text;

  /// Die erste Antwort ist immer die richtige; die App mischt sie.
  final List<String> antworten;
  final String erklaerung;
}

const pruefungsfragen = <Frage>[
  // Fischkunde
  Frage('Fischkunde', 'Welche Fische haben eine Fettflosse?', [
    'Lachsfische wie Forelle, Saibling und Äsche',
    'Karpfenfische wie Karpfen und Schleie',
    'Barsche wie Zander und Flussbarsch',
    'Hechte',
  ], 'Die kleine Fettflosse zwischen Rücken- und Schwanzflosse ist typisch für Salmoniden.'),
  Frage('Fischkunde', 'Wozu dient die Seitenlinie?', [
    'Zum Spüren von Wasserbewegungen und Druckwellen',
    'Zum Atmen',
    'Zum Schwimmen in der Strömung',
    'Zur Verdauung',
  ], 'Mit der Seitenlinie "fühlt" der Fisch Bewegungen im Wasser, auch im Dunkeln.'),
  Frage('Fischkunde', 'Wozu dient die Schwimmblase?', [
    'Zum Schweben in einer bestimmten Wassertiefe',
    'Zum Speichern von Nahrung',
    'Zum Hören von Geräuschen über Wasser',
    'Zum Ablaichen',
  ], 'Über die Gasmenge in der Schwimmblase regelt der Fisch seinen Auftrieb.'),
  Frage('Fischkunde', 'Womit atmen Fische?', [
    'Mit den Kiemen',
    'Mit der Schwimmblase',
    'Mit der Seitenlinie',
    'Mit der Haut allein',
  ], 'In den Kiemen wird Sauerstoff aus dem Wasser ins Blut aufgenommen.'),
  Frage('Fischkunde', 'Welcher Fisch hat eine große, fahnenartige Rückenflosse?', [
    'Äsche',
    'Hecht',
    'Barbe',
    'Aalrutte',
  ], 'Die "Fahne" der Äsche ist ihr bekanntestes Merkmal.'),
  Frage('Fischkunde', 'Woran erkennt man eine Bachforelle?', [
    'Rote Punkte mit hellem Rand',
    'Rosa Band entlang der Seite',
    'Sechs Barteln',
    'Zwei getrennte Rückenflossen',
  ], 'Das rosa Band hat die Regenbogenforelle, sechs Barteln der Wels.'),
  Frage('Fischkunde', 'Wie viele Barteln hat ein Karpfen?', [
    '4',
    '2',
    '6',
    'Keine',
  ], 'Karpfen 4, Schleie 2, Wels 6, Aalrutte 1.'),
  Frage('Fischkunde', 'Welcher Fisch ist der größte Süßwasserfisch Europas?', [
    'Wels',
    'Hecht',
    'Huchen',
    'Karpfen',
  ], 'Welse können über 2 m lang werden.'),
  Frage('Fischkunde', 'Welcher Fisch ist ein Dorschartiger und laicht im Winter?', [
    'Aalrutte',
    'Barbe',
    'Schleie',
    'Reinanke',
  ], 'Die Aalrutte ist der einzige Dorsch im Süßwasser.'),
  Frage('Fischkunde', 'Woher stammt die Regenbogenforelle ursprünglich?', [
    'Aus Nordamerika',
    'Aus den Alpen',
    'Aus Asien',
    'Aus Skandinavien',
  ], 'Auch der Bachsaibling stammt aus Nordamerika.'),
  Frage('Fischkunde', 'Welche Merkmale hat der Zander?', [
    'Glasige Augen und zwei Rückenflossen, die erste mit Stacheln',
    'Eine Bartel am Kinn',
    'Rote Punkte und Fettflosse',
    'Entenschnabelartiges Maul',
  ], 'Das Entenschnabelmaul gehört zum Hecht.'),
  Frage('Fischkunde', 'Welcher Fisch wird auch "Donaulachs" genannt?', [
    'Huchen',
    'Seeforelle',
    'Nase',
    'Barbe',
  ], 'Der Huchen ist stark gefährdet und hat lange Schonzeiten.'),
  Frage('Fischkunde', 'Wann laicht der Hecht?', [
    'Im zeitigen Frühjahr (ca. Februar bis April)',
    'Im Hochsommer',
    'Im Spätherbst',
    'Im Dezember',
  ], 'Deshalb fällt die Hecht-Schonzeit in OÖ und Salzburg auf 1.2. – 30.4.'),
  Frage('Fischkunde', 'Wann laichen Bachforellen?', [
    'Im Herbst und Winter',
    'Im Frühling',
    'Im Sommer',
    'Das ganze Jahr',
  ], 'Forellen laichen in kaltem Wasser auf Kiesbänken.'),
  Frage('Fischkunde', 'Welcher dieser Fische ist ein Friedfisch?', [
    'Schleie',
    'Hecht',
    'Zander',
    'Wels',
  ], 'Friedfische fressen vor allem Pflanzen, Insektenlarven und Kleintiere.'),
  // Gewässerkunde
  Frage('Gewässerkunde', 'Welche Fischregion folgt flussabwärts auf die Äschenregion?', [
    'Barbenregion',
    'Forellenregion',
    'Brachsenregion',
    'Kaulbarschregion',
  ], 'Reihenfolge von oben: Forellen-, Äschen-, Barben-, Brachsenregion.'),
  Frage('Gewässerkunde', 'Welches Wasser kann mehr Sauerstoff speichern?', [
    'Kaltes Wasser',
    'Warmes Wasser',
    'Beide gleich viel',
    'Trübes Wasser',
  ], 'Im Sommer wird Sauerstoff in warmen Teichen deshalb oft knapp.'),
  Frage('Gewässerkunde', 'Was bedeutet "Eutrophierung"?', [
    'Überdüngung eines Gewässers mit Nährstoffen',
    'Austrocknen eines Baches',
    'Zufrieren eines Sees',
    'Besatz mit Jungfischen',
  ], 'Zu viele Nährstoffe führen zu Algenblüten und Sauerstoffmangel.'),
  Frage('Gewässerkunde', 'Wie ist die Forellenregion typischerweise?', [
    'Kalt, schnell fließend und sauerstoffreich',
    'Warm und schlammig',
    'Breit und langsam',
    'Salzig',
  ], 'Forellen brauchen kühles Wasser mit viel Sauerstoff.'),
  Frage('Gewässerkunde', 'Welcher Krebs überträgt die Krebspest?', [
    'Signalkrebs (eingeschleppt)',
    'Edelkrebs',
    'Steinkrebs',
    'Dohlenkrebs',
  ], 'Der amerikanische Signalkrebs ist selbst immun, heimische Krebse sterben daran.'),
  Frage('Gewässerkunde', 'Was ist ein "Neozoon"?', [
    'Eine vom Menschen eingeschleppte, nicht heimische Tierart',
    'Ein frisch geschlüpfter Fisch',
    'Ein besonders alter Fisch',
    'Eine Wasserpflanze',
  ], 'Beispiele: Signalkrebs, Sonnenbarsch, Blaubandbärbling.'),
  // Gerätekunde
  Frage('Gerätekunde', 'Wozu dient die Bremse an der Rolle?', [
    'Damit die Schnur bei starkem Zug nachgibt und nicht reißt',
    'Damit der Köder schneller sinkt',
    'Damit die Rute nicht bricht beim Transport',
    'Zum Messen des Fisches',
  ], 'Die Bremse wird etwas unter der Tragkraft der Schnur eingestellt.'),
  Frage('Gerätekunde', 'Was ist ein Vorfach?', [
    'Ein Stück Schnur zwischen Hauptschnur und Haken',
    'Eine Rutenhalterung',
    'Ein Kescher',
    'Ein Schwimmer',
  ], 'Beim Hechtfischen nimmt man ein bissfestes Stahl- oder Titanvorfach.'),
  Frage('Gerätekunde', 'Warum braucht man beim Hechtfischen ein Stahlvorfach?', [
    'Weil die scharfen Zähne normale Schnur durchbeißen',
    'Damit der Köder glänzt',
    'Weil es leichter ist',
    'Weil es vorgeschrieben ist, für alle Fische',
  ], 'Ohne bissfestes Vorfach bleibt der Köder sonst oft im Fisch zurück.'),
  Frage('Gerätekunde', 'Welche Schnur dehnt sich fast gar nicht?', [
    'Geflochtene Schnur',
    'Monofile Schnur',
    'Beide gleich',
    'Fluorocarbon dehnt sich am wenigsten von allen',
  ], 'Geflochtene Schnur überträgt Bisse sehr direkt.'),
  Frage('Gerätekunde', 'Wozu dient ein Kescher?', [
    'Zum schonenden Landen des Fisches',
    'Zum Anfüttern',
    'Zum Auswerfen',
    'Zum Aufbewahren der Köder',
  ], 'Ein knotenloses Netz schont die Schleimhaut des Fisches.'),
  Frage('Gerätekunde', 'Wozu dient ein Hakenlöser?', [
    'Zum schnellen und schonenden Entfernen des Hakens',
    'Zum Binden von Knoten',
    'Zum Schärfen des Hakens',
    'Zum Betäuben des Fisches',
  ], 'Tief geschluckte Haken lassen sich so ohne große Verletzungen lösen.'),
  // Tierschutz und Praxis
  Frage('Tierschutz', 'Was bedeutet "Brittelmaß"?', [
    'Das Mindestmaß, das ein Fisch haben muss, um entnommen zu werden',
    'Das größte erlaubte Maß',
    'Das Gewicht eines Fisches',
    'Die Länge der Angelrute',
  ], 'Kleinere ("untermaßige") Fische müssen sofort schonend zurückgesetzt werden.'),
  Frage('Tierschutz', 'Wie misst man die Länge eines Fisches?', [
    'Von der Kopfspitze bis zum Ende der Schwanzflosse',
    'Vom Auge bis zur Rückenflosse',
    'Nur den Körper ohne Kopf',
    'Vom Maul bis zur Afterflosse',
  ], 'Gemessen wird die Gesamtlänge bei natürlich gestreckter Schwanzflosse.'),
  Frage('Tierschutz', 'Warum fasst man einen Fisch, der zurückgesetzt wird, mit nassen Händen an?', [
    'Um seine schützende Schleimhaut nicht zu beschädigen',
    'Damit er nicht wegrutscht',
    'Damit die Hände sauber bleiben',
    'Weil der Fisch sonst friert',
  ], 'Eine verletzte Schleimhaut macht Fische anfällig für Pilze und Krankheiten.'),
  Frage('Tierschutz', 'Wie tötet man einen Fisch waidgerecht?', [
    'Zuerst betäuben (Schlag auf den Hinterkopf), dann sofort töten (Herzstich/Kiemenschnitt)',
    'In einem Kübel ersticken lassen',
    'Auf Eis legen und warten',
    'Lebend mitnehmen',
  ], 'Der Fisch muss vor dem Töten immer betäubt werden.'),
  Frage('Tierschutz', 'Ein Fisch hat Schonzeit und beißt. Was tun?', [
    'Sofort schonend zurücksetzen',
    'Mitnehmen, wenn er groß genug ist',
    'Einem anderen Fischer schenken',
    'Im Setzkescher aufbewahren',
  ], 'In der Schonzeit darf der Fisch nicht entnommen werden – egal wie groß.'),
  Frage('Tierschutz', 'Wann trägt man einen entnommenen Fisch meist in die Fangstatistik ein?', [
    'Sofort nach der Entnahme',
    'Am Ende der Saison',
    'Nur bei großen Fischen',
    'Gar nicht',
  ], 'Viele Reviere verlangen den Eintrag sofort – genaue Regeln stehen auf der Lizenz.'),
  // Recht
  Frage('Recht', 'Was braucht man in Österreich zum Fischen?', [
    'Eine amtliche Fischerkarte und eine Erlaubnis für das Gewässer',
    'Nur eine Angelrute',
    'Nur eine Tageskarte',
    'Einen Führerschein',
  ], 'Die Fischerkarte gibt das Land aus, die Lizenz/Tageskarte der Revierbesitzer.'),
  Frage('Recht', 'Ab welchem Alter kann man in OÖ die Fischerprüfung machen?', [
    'Ab 12 Jahren',
    'Ab 6 Jahren',
    'Ab 16 Jahren',
    'Ab 18 Jahren',
  ], 'Vorher braucht man einen Fischerkurs mit mindestens 10 Stunden.'),
  Frage('Recht', 'Wie lange gilt die Gastfischerkarte in OÖ?', [
    '3 Wochen',
    '1 Tag',
    '1 Jahr',
    'Unbegrenzt',
  ], 'Sie kann höchstens zweimal pro Jahr ausgestellt werden.'),
  Frage('Recht', 'Wer regelt in Österreich Schonzeiten und Brittelmaße?', [
    'Jedes Bundesland selbst',
    'Die EU für alle Länder gleich',
    'Nur der Bund',
    'Jeder Fischer selbst',
  ], 'Deshalb sind z. B. die Hecht-Brittelmaße in OÖ (60 cm) und Salzburg (50 cm) verschieden.'),
  // Weitere Fragen
  Frage('Fischkunde', 'Welche Fische haben eine weiße Vorderkante an Bauch- und Afterflosse?', [
    'Saiblinge (Bach- und Seesaibling)',
    'Hechte',
    'Karpfen',
    'Barsche',
  ], 'Der weiße Flossensaum ist ein gutes Erkennungsmerkmal der Saiblinge.'),
  Frage('Fischkunde', 'Welcher heimische Karpfenfisch lebt als erwachsener Fisch fast nur räuberisch?', [
    'Rapfen (Schied)',
    'Brachse',
    'Rotauge',
    'Schleie',
  ], 'Der Rapfen jagt kleine Fische an der Wasseroberfläche.'),
  Frage('Fischkunde', 'Was frisst die Nase hauptsächlich?', [
    'Algen, die sie von Steinen abweidet',
    'Andere Fische',
    'Insekten an der Oberfläche',
    'Schnecken im Schlamm',
  ], 'Dafür hat sie eine harte, scharfkantige Unterlippe.'),
  Frage('Fischkunde', 'Welcher Fisch hat rote Augen, sehr kleine Schuppen und eine grün-goldene Farbe?', [
    'Schleie',
    'Zander',
    'Äsche',
    'Aitel',
  ], 'Die Schleie ist außerdem sehr schleimig und hat zwei kurze Barteln.'),
  Frage('Fischkunde', 'Wie viele Rückenflossen hat der Flussbarsch?', [
    'Zwei',
    'Eine',
    'Drei',
    'Keine',
  ], 'Die erste ist stachelig und hat am Ende einen schwarzen Fleck.'),
  Frage('Fischkunde', 'Welche Fischart ist in Oberösterreich ganzjährig geschont?', [
    'Karausche',
    'Karpfen',
    'Hecht',
    'Aitel',
  ], 'Auch der Perlfisch ist ganzjährig geschont.'),
  Frage('Gewässerkunde', 'Was ist die Brachsenregion?', [
    'Der langsam fließende, warme Unterlauf eines Flusses',
    'Der Quellbereich eines Baches',
    'Ein Bergsee',
    'Ein Wasserfall',
  ], 'Hier leben vor allem Karpfenfische wie die Brachse.'),
  Frage('Gewässerkunde', 'Warum sind Wasserpflanzen und bewachsene Ufer wichtig?', [
    'Sie bieten Versteck, Nahrung und Laichplätze',
    'Sie machen das Wasser wärmer',
    'Sie halten Fischer fern',
    'Sie haben keine Bedeutung',
  ], 'Viele Fische laichen an Pflanzen, Jungfische verstecken sich darin.'),
  Frage('Gewässerkunde', 'Was ist ein Altarm?', [
    'Ein abgetrennter, ehemaliger Flussarm',
    'Ein besonders alter Fisch',
    'Ein Teil der Angelrute',
    'Eine Staumauer',
  ], 'Altarme sind wertvolle Lebensräume, z. B. für Hecht und Schleie.'),
  Frage('Gerätekunde', 'Wozu dient ein Wirbel?', [
    'Er verhindert, dass sich die Schnur verdrallt',
    'Er macht den Köder schwerer',
    'Er zeigt Bisse an',
    'Er ersetzt den Haken',
  ], 'Besonders bei Spinnern dreht sich sonst die Schnur ein.'),
  Frage('Gerätekunde', 'Was ist der "Anschlag"?', [
    'Ein Ruck mit der Rute, damit der Haken im Fischmaul greift',
    'Das Auswerfen des Köders',
    'Das Anfüttern',
    'Das Messen des Fisches',
  ], 'Beim Biss setzt man den Anschlag, um den Fisch zu haken.'),
  Frage('Gerätekunde', 'Wofür ist ein Schwimmer (Pose)?', [
    'Er zeigt Bisse an und hält den Köder in der gewünschten Tiefe',
    'Er lockt Fische mit Licht an',
    'Er ersetzt das Blei',
    'Er schützt die Schnur vor Bissen',
  ], 'Taucht die Pose ab, hat ein Fisch gebissen.'),
  Frage('Gerätekunde', 'Was ist ein Drilling?', [
    'Ein Haken mit drei Spitzen',
    'Eine Rute mit drei Teilen',
    'Drei Fische an einem Tag',
    'Ein dreifacher Knoten',
  ], 'Drillinge sitzen oft an Wobblern und Blinkern.'),
  Frage('Recht', 'Wie oft ist in OÖ die Jahresfischerkarten-Abgabe zu zahlen?', [
    'Jedes Kalenderjahr',
    'Einmal im Leben',
    'Alle 10 Jahre',
    'Nur beim ersten Fang',
  ], 'Die Abgabe beträgt derzeit € 32 pro Jahr.'),
  Frage('Recht', 'Was kostet die Gastfischerkarte in OÖ?', [
    '€ 20',
    '€ 2',
    '€ 200',
    'Sie ist gratis',
  ], 'Sie gilt 3 Wochen und kann höchstens zweimal pro Jahr ausgestellt werden.'),
  Frage('Recht', 'Welcher Fisch hat in OÖ ein Brittelmaß von 60 cm?', [
    'Hecht',
    'Bachforelle',
    'Flussbarsch',
    'Schleie',
  ], 'In Salzburg liegt das Hecht-Brittelmaß bei 50 cm.'),
  Frage('Tierschutz', 'Ein untermaßiger Fisch hat den Haken tief geschluckt. Was ist am schonendsten?', [
    'Vorfach knapp abschneiden und den Fisch zurücksetzen',
    'Den Haken mit Gewalt herausreißen',
    'Den Fisch mitnehmen',
    'Den Fisch länger an Land liegen lassen',
  ], 'Der Haken löst sich oft von selbst oder wächst ein – Reißen verletzt stark.'),
  Frage('Tierschutz', 'Darf man einen Fisch in der Schonzeit entnehmen, wenn er über dem Brittelmaß ist?', [
    'Nein, in der Schonzeit nie',
    'Ja, wenn er groß genug ist',
    'Ja, aber nur einen pro Tag',
    'Ja, am Wochenende',
  ], 'Schonzeit und Brittelmaß gelten beide – beides muss passen.'),
  Frage('Tierschutz', 'Was bedeutet "Hege" in der Fischerei?', [
    'Den Fischbestand pflegen, schützen und erhalten',
    'Möglichst viele Fische fangen',
    'Nur nachts fischen',
    'Fremde Fischarten aussetzen',
  ], 'Zur Hege gehören z. B. Besatz, Schonzeiten und Lebensraumschutz.'),
];
