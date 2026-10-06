import 'srs.dart';

/// Eine Karte mit ihrem Lernstand (null = neu), unabhängig von der Datenbank.
class LernKarte<T> {
  const LernKarte(this.karte, this.stand, {required this.reihenfolge});
  final T karte;
  final Lernstand? stand;
  final int reihenfolge;

  bool get neu => stand == null;
}

/// Stellt eine Lernrunde zusammen: zuerst alle fälligen Karten (die am
/// längsten überfälligen zuerst), dann neue Karten bis zum Tageslimit.
List<LernKarte<T>> lernrundeZusammenstellen<T>(
  Iterable<LernKarte<T>> karten, {
  required DateTime jetzt,
  required int neueProTag,
  required int neueHeuteSchon,
  int? maximal,
}) {
  final faellig =
      karten.where((k) => !k.neu && !k.stand!.faellig.isAfter(jetzt)).toList()
        ..sort((a, b) => a.stand!.faellig.compareTo(b.stand!.faellig));
  final frei = (neueProTag - neueHeuteSchon).clamp(0, neueProTag);
  final neue = karten.where((k) => k.neu).toList()
    ..sort((a, b) => a.reihenfolge.compareTo(b.reihenfolge));
  final runde = [...faellig, ...neue.take(frei)];
  return maximal == null ? runde : runde.take(maximal).toList();
}
