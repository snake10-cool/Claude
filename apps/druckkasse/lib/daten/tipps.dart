/// „Druck-Tipp des Tages“ auf dem Verkaufen-Bildschirm. Jeden Tag ein
/// anderer, damit es sich lohnt, die App täglich zu öffnen.
const druckTipps = [
  'Miss den Stromverbrauch deines Druckers einmal mit einer Messsteckdose. Der Durchschnitt liegt meist weit unter der Netzteil-Angabe.',
  'Fehldrucke passieren. Ein Zuschlag von 5–10 % auf die Druckkosten sorgt dafür, dass sie dich nichts extra kosten.',
  'Kleine Teile wie Klicker lohnen sich auf einer vollen Platte: Druckzeit und Strom verteilen sich auf viele Stück.',
  'Trockenes Filament druckt sauberer. PETG und TPU vor dem Drucken ein paar Stunden trocknen.',
  'Bei Flexi-Figuren sind die Gelenke empfindlich: lieber 0,2 mm Schichthöhe und langsame Außenwände.',
  'Zähle deine Verpackung als Extra. Auch 10 Cent pro Stück summieren sich über 100 Verkäufe.',
  'Saisonale Drucke (Halloween, Weihnachten, Ostern) etwa 4–6 Wochen vorher anbieten.',
  'Beim Farbwechsel mit AMS fällt Spülabfall an. Trag ihn beim Produkt ein, sonst rechnest du zu billig.',
  '„In Objekt spülen“ im Slicer spart Abfall: Infill oder ein Stützobjekt nehmen die Spülmenge auf.',
  'Halte Preise rund: 3,00 € oder 5,00 € verkaufen sich am Stand leichter als 3,37 €.',
  'Mengenrabatt („3 für 10 €“) steigert den Umsatz pro Kunde. Halte den Finger auf ein Produkt für einen Sonderpreis.',
  'Fotografiere deine Bestseller vor einem einfarbigen Hintergrund. Gute Fotos verkaufen besser.',
  'Reinige die Druckplatte mit Spülmittel und warmem Wasser. Isopropanol allein entfernt Fett nicht vollständig.',
  'Eine 0,6-mm-Düse halbiert bei großen Teilen oft die Druckzeit. Das spart Strom und Abnutzung.',
  'Silk-PLA glänzt schön, ist aber spröder. Für Klicker und bewegliche Teile lieber normales PLA.',
  'Notiere bei Aufträgen die Wunschfarbe in der Position. So verwechselst du nichts.',
  'Prüfe einmal im Monat in der Übersicht, welche Produkte am meisten Gewinn bringen, nicht nur Umsatz.',
  'Lagere Filament mit Trockenmittel in einer luftdichten Box.',
  'Ein Sparziel motiviert: Leg fest, wofür du sparst, und schau beim Verkaufen, wie viele Stück noch fehlen.',
  'Wenn ein Produkt kaum Gewinn bringt: Druckzeit verkürzen (weniger Infill, dickere Schichten) oder Preis anpassen.',
  'Biete Personalisierung an (Name, Farbe). Dafür zahlen Kunden gerne mehr.',
  'Bei TPU die Geschwindigkeit stark reduzieren und den Retract klein halten.',
  'Plane Wartung ein: Düsen und PTFE-Schläuche sind Verschleißteile. Die Abnutzung pro Stunde deckt das ab.',
  'Mach regelmäßig eine Sicherung deiner Daten (Mehr → Einstellungen → Sicherung).',
];

String tippDesTages(DateTime tag) {
  final tageSeit2000 = DateTime.utc(
    tag.year,
    tag.month,
    tag.day,
  ).difference(DateTime.utc(2000)).inDays;
  return druckTipps[tageSeit2000 % druckTipps.length];
}
