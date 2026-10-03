class Knoten {
  const Knoten(this.name, this.wofuer, this.schritte, {this.tipp});

  final String name;
  final String wofuer;
  final List<String> schritte;
  final String? tipp;
}

const knotenListe = <Knoten>[
  Knoten(
    'Verbesserter Clinchknoten',
    'Haken, Wirbel oder Kunstköder an monofiler Schnur befestigen.',
    [
      'Schnur etwa 15 cm durch das Öhr fädeln.',
      'Das Schnurende 5- bis 7-mal um die Hauptschnur wickeln.',
      'Das Ende durch die kleine Schlaufe direkt am Öhr stecken.',
      'Dann das Ende auch durch die große Schlaufe führen, die dabei '
          'entstanden ist.',
      'Knoten anfeuchten, langsam festziehen und das Ende abschneiden.',
    ],
    tipp: 'Bei dicker Schnur weniger Windungen nehmen.',
  ),
  Knoten(
    'Palomarknoten',
    'Sehr fester Knoten für Haken und Wirbel, gut für geflochtene Schnur.',
    [
      'Schnur doppelt nehmen (ca. 15 cm Schlaufe) und durch das Öhr führen.',
      'Mit der doppelten Schnur einen einfachen Knoten binden – der Haken '
          'hängt lose in der Schlaufe.',
      'Die Schlaufe über den ganzen Haken ziehen.',
      'Anfeuchten, an Haupt- und Endschnur festziehen, Ende abschneiden.',
    ],
  ),
  Knoten(
    'Grinner (Uni-Knoten)',
    'Universeller Knoten für Haken und Wirbel.',
    [
      'Schnur durch das Öhr führen und das Ende parallel zur Hauptschnur '
          'zurücklegen.',
      'Mit dem Ende eine Schlaufe über beide Schnüre legen.',
      'Das Ende 4- bis 6-mal durch die Schlaufe um beide Schnüre wickeln.',
      'Anfeuchten, am Ende ziehen, dann an der Hauptschnur ziehen, bis der '
          'Knoten am Öhr sitzt.',
    ],
  ),
  Knoten(
    'Doppelter Grinner',
    'Zwei Schnüre miteinander verbinden, z. B. Hauptschnur und Vorfach.',
    [
      'Beide Schnurenden überlappend nebeneinander legen.',
      'Mit dem ersten Ende einen Grinner um die zweite Schnur binden.',
      'Mit dem zweiten Ende einen Grinner um die erste Schnur binden.',
      'Anfeuchten und beide Hauptschnüre auseinanderziehen, bis die Knoten '
          'aneinander rutschen.',
    ],
  ),
  Knoten(
    'Chirurgenschlaufe',
    'Schnelle, feste Schlaufe am Schnurende, z. B. für Vorfächer.',
    [
      'Das Schnurende doppelt legen.',
      'Mit der doppelten Schnur einen einfachen Knoten binden.',
      'Die Schlaufe ein zweites Mal durch den Knoten stecken.',
      'Anfeuchten und festziehen.',
    ],
  ),
];
