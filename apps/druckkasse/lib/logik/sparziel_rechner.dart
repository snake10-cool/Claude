import 'typen.dart';
import 'statistik.dart';

/// Wie viel für ein Sparziel schon zusammengekommen ist.
int sparStand(SparBasis basis, Auswertung seitStart) => switch (basis) {
  SparBasis.gewinn => seitStart.gewinnCent,
  SparBasis.umsatz => seitStart.umsatzCent,
};

/// 0.0 bis 1.0 für den Fortschrittsbalken.
double sparFortschritt({required int standCent, required int zielCent}) {
  if (zielCent <= 0) return 1;
  return (standCent / zielCent).clamp(0.0, 1.0);
}

/// Wie viele Stück eines Produkts noch fehlen, wenn jedes Stück
/// [proStueckCent] beiträgt. `null`, wenn das Produkt nichts beiträgt.
int? stueckFehlend({required int restCent, required int proStueckCent}) {
  if (restCent <= 0) return 0;
  if (proStueckCent <= 0) return null;
  return (restCent + proStueckCent - 1) ~/ proStueckCent;
}
