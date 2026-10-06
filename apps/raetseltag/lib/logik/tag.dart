/// Der erste Rätseltag (Nummer 1).
final startTag = DateTime(2026, 10, 1);

DateTime tagBeginn(DateTime t) => DateTime(t.year, t.month, t.day);

/// Rätselnummer eines Tages (1 = Starttag). Über UTC gerechnet, damit
/// Sommer-/Winterzeit nichts verschiebt.
int raetselNummer(DateTime tag) {
  final a = DateTime.utc(startTag.year, startTag.month, startTag.day);
  final b = DateTime.utc(tag.year, tag.month, tag.day);
  return b.difference(a).inDays + 1;
}

DateTime tagVonNummer(int nummer) =>
    DateTime(startTag.year, startTag.month, startTag.day + nummer - 1);
