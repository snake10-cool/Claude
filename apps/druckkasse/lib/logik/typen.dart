/// Wie bezahlt wurde. Der Index wird in der Datenbank gespeichert –
/// Reihenfolge deshalb nie ändern, nur hinten anfügen.
enum Zahlungsart { bar, karte, online }

/// Fortschritt eines Auftrags. Bezahlt ist ein eigenes Häkchen, weil manche
/// vorher und manche erst bei Abholung zahlen.
enum AuftragStatus { offen, gedruckt, abgeholt }

/// Was für ein Sparziel zählt.
enum SparBasis { gewinn, umsatz }
