/// Ein Objekt, wie es in der Cloud liegt.
class FernObjekt {
  const FernObjekt({
    required this.typ,
    required this.id,
    required this.geaendert,
    required this.daten,
  });

  /// gruppe, person, liste, artikel, ausgabe
  final String typ;
  final String id;
  final DateTime geaendert;
  final Map<String, dynamic> daten;
}

/// Die Cloud aus Sicht der App. Die echte Umsetzung ist Firestore
/// ([FirestoreSpeicher]); für Tests gibt es eine Fälschung im Speicher.
abstract class Fernspeicher {
  /// Meldet das Gerät an (anonym) und gibt die Nutzer-ID zurück.
  Future<String> anmelden();

  /// Legt die Gruppe in der Cloud an und reserviert den Einladungscode.
  /// Gibt `false` zurück, wenn der Code schon vergeben ist.
  Future<bool> gruppeErstellen(String gruppeId, String code);

  /// Tritt mit einem Code bei. Gibt die Gruppen-ID zurück oder `null`,
  /// wenn es den Code nicht gibt.
  Future<String?> beitreten(String code);

  /// Alle Objekte der Gruppe, bei jeder Änderung neu.
  Stream<List<FernObjekt>> beobachten(String gruppeId);

  Future<void> schreiben(String gruppeId, List<FernObjekt> objekte);
}
