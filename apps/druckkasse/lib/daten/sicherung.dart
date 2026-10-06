import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';

import 'datenbank.dart';

/// Sicherung = eine Kopie der ganzen Datenbank als Datei.
class Sicherung {
  Sicherung(this.d, {Future<Directory> Function()? tempOrdner})
    : _tempOrdner = tempOrdner ?? getTemporaryDirectory;
  final AppDatenbank d;
  final Future<Directory> Function() _tempOrdner;

  /// Reihenfolge wichtig: zuerst Tabellen ohne Abhängigkeiten.
  List<TableInfo<Table, dynamic>> get _tabellen => [
    d.einstellungenTabelle,
    d.druckerTabelle,
    d.filamentTabelle,
    d.extraTabelle,
    d.produktTabelle,
    d.produktFilamentTabelle,
    d.produktExtraTabelle,
    d.auftragTabelle,
    d.auftragPositionTabelle,
    d.verkaufTabelle,
    d.sparzielTabelle,
  ];

  /// Erstellt eine saubere Kopie der Datenbank und gibt ihren Inhalt zurück.
  Future<Uint8List> erstellen() async {
    final ordner = await _tempOrdner();
    final datei = File(
      '${ordner.path}/sicherung_${DateTime.now().millisecondsSinceEpoch}.sqlite',
    );
    // VACUUM INTO schreibt eine konsistente Kopie, auch während die App läuft.
    await d.customStatement('VACUUM INTO ?', [datei.path]);
    final bytes = await datei.readAsBytes();
    await datei.delete();
    return bytes;
  }

  /// Ersetzt alle Daten durch die aus [bytes]. Wirft [FormatException], wenn
  /// die Datei keine passende Sicherung ist.
  Future<void> wiederherstellen(Uint8List bytes) async {
    final ordner = await _tempOrdner();
    final datei = File('${ordner.path}/wiederherstellen.sqlite');
    await datei.writeAsBytes(bytes, flush: true);
    var angehaengt = false;
    try {
      await d.customStatement('ATTACH DATABASE ? AS sicherung', [datei.path]);
      angehaengt = true;
      final version = await d
          .customSelect('PRAGMA sicherung.user_version')
          .getSingle();
      final v = version.data.values.first as int;
      if (v < 1 || v > d.schemaVersion) {
        throw const FormatException('Keine passende Sicherung');
      }
      await d.transaction(() async {
        for (final t in _tabellen.reversed) {
          await d.customStatement('DELETE FROM main.${t.actualTableName}');
        }
        for (final t in _tabellen) {
          final spalten = t.$columns.map((c) => '"${c.name}"').join(', ');
          await d.customStatement(
            'INSERT INTO main.${t.actualTableName} ($spalten) '
            'SELECT $spalten FROM sicherung.${t.actualTableName}',
          );
        }
      });
    } on FormatException {
      rethrow;
    } catch (e) {
      throw FormatException('$e');
    } finally {
      if (angehaengt) await d.customStatement('DETACH DATABASE sicherung');
      await datei.delete();
    }
    d.markTablesUpdated(_tabellen);
  }
}
