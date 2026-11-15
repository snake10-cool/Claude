import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../data/katalog.dart';
import '../data/korrekturen.dart';
import '../models/buch.dart';
import '../models/meldung.dart';
import 'speicher.dart';

/// Administrator: gibt Quizfragen frei (muss mit firestore.rules übereinstimmen).
const adminEmail = 'snakejoni10@yahoo.com';

/// Eine Rezension zu einem Buch (eine pro Leser und Buch).
class Rezension {
  const Rezension(this.id, this.buchId, this.uid, this.name, this.sterne, this.text, this.spoiler, this.erstellt);

  final String id;
  final String buchId;
  final String uid;
  final String name;
  final int sterne;
  final String text;
  final bool spoiler;
  final DateTime? erstellt;

  factory Rezension.ausDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final j = d.data() ?? const {};
    return Rezension(
      d.id,
      j['buchId'] as String? ?? '',
      j['uid'] as String? ?? '',
      j['name'] as String? ?? '?',
      j['sterne'] as int? ?? 0,
      j['text'] as String? ?? '',
      j['spoiler'] as bool? ?? false,
      (j['erstellt'] as Timestamp?)?.toDate(),
    );
  }
}

/// Eine Lesegruppe (Buchclub).
class Gruppe {
  const Gruppe(this.id, this.name, this.code, this.mitglieder, this.namen, this.buchId, this.buchTitel);

  final String id;
  final String name;

  /// 6-stelliger Beitrittscode.
  final String code;
  final List<String> mitglieder;
  final Map<String, String> namen;
  final String? buchId;
  final String? buchTitel;

  factory Gruppe.ausDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final j = d.data() ?? const {};
    return Gruppe(
      d.id,
      j['name'] as String? ?? '',
      j['code'] as String? ?? '',
      List<String>.from(j['mitglieder'] as List? ?? const []),
      Map<String, String>.from(j['namen'] as Map? ?? const {}),
      j['buchId'] as String?,
      j['buchTitel'] as String?,
    );
  }
}

/// Fortschritt eines Mitglieds beim Gruppenbuch.
class GruppenFortschritt {
  const GruppenFortschritt(this.uid, this.name, this.seite, this.seiten, this.gelesen);

  final String uid;
  final String name;
  final int seite;
  final int seiten;
  final bool gelesen;
}

/// Eine von Lesern vorgeschlagene Quizfrage.
class Vorschlag {
  const Vorschlag(this.id, this.buchId, this.buchTitel, this.frage, this.antworten, this.name, this.status);

  final String id;
  final String buchId;
  final String buchTitel;
  final String frage;

  /// Die richtige Antwort steht zuerst.
  final List<String> antworten;
  final String name;

  /// neu, frei oder abgelehnt.
  final String status;

  factory Vorschlag.ausDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final j = d.data() ?? const {};
    return Vorschlag(
      d.id,
      j['buchId'] as String? ?? '',
      j['buchTitel'] as String? ?? '',
      j['frage'] as String? ?? '',
      List<String>.from(j['antworten'] as List? ?? const []),
      j['name'] as String? ?? '?',
      j['status'] as String? ?? 'neu',
    );
  }
}

/// Ein Eintrag in der Online-Rangliste.
class Spieler {
  const Spieler(this.uid, this.name, this.punkte, this.bewiesen, this.gelesen);

  final String uid;
  final String name;
  final int punkte;
  final int bewiesen;
  final int gelesen;

  factory Spieler.ausDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final j = d.data() ?? const {};
    return Spieler(
      d.id,
      j['name'] as String? ?? '?',
      j['punkte'] as int? ?? 0,
      j['bewiesen'] as int? ?? 0,
      j['gelesen'] as int? ?? 0,
    );
  }
}

class KontoFehler implements Exception {
  const KontoFehler(this.text);
  final String text;
  @override
  String toString() => text;
}

/// @Name: 3–20 Zeichen, nur Kleinbuchstaben, Ziffern, Punkt und Unterstrich.
final nameMuster = RegExp(r'^[a-z0-9_.]{3,20}$');

String nameNormal(String eingabe) => eingabe.trim().toLowerCase().replaceFirst('@', '');

/// Konto und Online-Rangliste über Firebase. Lädt den eigenen Stand
/// automatisch hoch, sobald sich Punkte ändern.
class Konto extends ChangeNotifier {
  Konto(this._speicher) {
    _abo = _auth.authStateChanges().listen(_nutzerGeaendert);
    _speicher.addListener(_hochladen);
    _fragenAbo = _db.collection('quizfragen').limit(5000).snapshots().listen((s) {
      final neu = <String, List<Frage>>{};
      for (final d in s.docs) {
        final j = d.data();
        final antworten = List<String>.from(j['antworten'] as List? ?? const []);
        final buchId = j['buchId'] as String?;
        if (buchId == null || antworten.length != 4) continue;
        neu.putIfAbsent(buchId, () => []).add(Frage(j['frage'] as String? ?? '', antworten));
      }
      gemeinschaftsFragen = neu;
      notifyListeners();
    }, onError: (Object e) => debugPrint('Quizfragen nicht geladen: $e'));
    _korrekturAbo = _db.collection('buchkorrekturen').snapshots().listen((s) {
      korrekturenSetzen({for (final d in s.docs) d.id: d.data()}, (id) => katalogBuch(id) != null);
      _speicher.katalogAktualisiert();
    }, onError: (Object e) => debugPrint('Katalog-Korrekturen nicht geladen: $e'));
  }

  final Speicher _speicher;
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  late final StreamSubscription<User?> _abo;
  late final StreamSubscription<QuerySnapshot<Map<String, dynamic>>> _fragenAbo;
  late final StreamSubscription<QuerySnapshot<Map<String, dynamic>>> _korrekturAbo;

  /// Freigegebene Quizfragen der Leser, nach Buch-ID.
  Map<String, List<Frage>> gemeinschaftsFragen = const {};

  /// Eigener @Name, sobald das Profil geladen ist.
  String? name;
  String? _hochgeladen;

  User? get nutzer => _auth.currentUser;
  bool get angemeldet => nutzer != null;
  bool get istAdmin => nutzer?.email == adminEmail && (nutzer?.emailVerified ?? false);

  CollectionReference<Map<String, dynamic>> get _spieler => _db.collection('spieler');
  DocumentReference<Map<String, dynamic>> _namensDoc(String n) => _db.collection('namen').doc(n);
  CollectionReference<Map<String, dynamic>> _freunde(String uid) =>
      _spieler.doc(uid).collection('freunde');

  @override
  void dispose() {
    _abo.cancel();
    _fragenAbo.cancel();
    _korrekturAbo.cancel();
    _speicher.removeListener(_hochladen);
    super.dispose();
  }

  Future<void> _nutzerGeaendert(User? u) async {
    name = null;
    _hochgeladen = null;
    if (u != null) {
      try {
        name = (await _spieler.doc(u.uid).get()).data()?['name'] as String?;
      } catch (e) {
        debugPrint('Profil nicht geladen: $e');
      }
    }
    notifyListeners();
    _hochladen();
  }

  Map<String, dynamic> _stand(String n) => {
        'name': n,
        'punkte': _speicher.punkte,
        'bewiesen': _speicher.bewiesen,
        'gelesen': _speicher.gelesen,
        'aktualisiert': FieldValue.serverTimestamp(),
      };

  void _hochladen() {
    final u = nutzer;
    final n = name;
    if (u == null || n == null) return;
    final kennung = '${_speicher.punkte}/${_speicher.bewiesen}/${_speicher.gelesen}';
    if (kennung == _hochgeladen) return;
    _hochgeladen = kennung;
    _spieler.doc(u.uid).set(_stand(n)).catchError((Object e) {
      _hochgeladen = null;
      debugPrint('Stand nicht hochgeladen: $e');
    });
  }

  Future<void> registrieren(String email, String passwort, String wunschname) async {
    final n = nameNormal(wunschname);
    if (!nameMuster.hasMatch(n)) {
      throw const KontoFehler('Der @Name braucht 3–20 Zeichen: a–z, 0–9, Punkt oder Unterstrich.');
    }
    if ((await _fehler(() => _namensDoc(n).get())).exists) {
      throw KontoFehler('@$n ist schon vergeben.');
    }
    final zugang = await _fehler(
      () => _auth.createUserWithEmailAndPassword(email: email.trim(), password: passwort),
    );
    final uid = zugang.user!.uid;
    final batch = _db.batch()
      ..set(_namensDoc(n), {'uid': uid})
      ..set(_spieler.doc(uid), _stand(n));
    try {
      await batch.commit();
    } catch (e) {
      // Name in der Zwischenzeit vergeben: Konto wieder entfernen.
      await zugang.user!.delete().catchError((_) {});
      throw KontoFehler('@$n ist schon vergeben.');
    }
    name = n;
    _hochgeladen = '${_speicher.punkte}/${_speicher.bewiesen}/${_speicher.gelesen}';
    notifyListeners();
  }

  Future<void> anmelden(String email, String passwort) => _fehler(
        () => _auth.signInWithEmailAndPassword(email: email.trim(), password: passwort),
      );

  Future<void> passwortVergessen(String email) =>
      _fehler(() => _auth.sendPasswordResetEmail(email: email.trim()));

  Future<void> abmelden() => _auth.signOut();

  Future<void> bestaetigungSenden() => _fehler(() => nutzer!.sendEmailVerification());

  /// Lädt den Nutzer neu, z. B. nachdem die E-Mail bestätigt wurde.
  Future<void> neuLaden() async {
    await _fehler(() => nutzer!.reload());
    notifyListeners();
  }

  /// Löscht Rangliste-Eintrag, Freunde, @Name und das Konto selbst.
  Future<void> kontoLoeschen(String passwort) async {
    final u = nutzer;
    if (u == null) return;
    await _fehler(() => u.reauthenticateWithCredential(
          EmailAuthProvider.credential(email: u.email ?? '', password: passwort),
        ));
    final freunde = await _freunde(u.uid).get();
    final batch = _db.batch();
    for (final f in freunde.docs) {
      batch.delete(f.reference);
    }
    batch.delete(_spieler.doc(u.uid));
    if (name != null) batch.delete(_namensDoc(name!));
    await _fehler(batch.commit);
    await _fehler(u.delete);
  }

  // ───────── Rangliste ─────────

  Stream<List<Spieler>> weltweit() => _spieler
      .orderBy('punkte', descending: true)
      .limit(50)
      .snapshots()
      .map((s) => s.docs.map(Spieler.ausDoc).toList());

  Stream<List<String>> freundUids() {
    final u = nutzer;
    if (u == null) return Stream.value(const []);
    return _freunde(u.uid).snapshots().map((s) => s.docs.map((d) => d.id).toList());
  }

  /// Stände mehrerer Spieler (Firestore erlaubt höchstens 30 IDs pro Abfrage).
  Future<List<Spieler>> staende(List<String> uids) async {
    final ergebnis = <Spieler>[];
    for (var i = 0; i < uids.length; i += 30) {
      final teil = uids.sublist(i, i + 30 > uids.length ? uids.length : i + 30);
      final s = await _spieler.where(FieldPath.documentId, whereIn: teil).get();
      ergebnis.addAll(s.docs.map(Spieler.ausDoc));
    }
    return ergebnis;
  }

  Future<void> freundHinzufuegen(String eingabe) async {
    final u = nutzer;
    if (u == null) return;
    final n = nameNormal(eingabe);
    if (n == name) throw const KontoFehler('Das bist du selbst. 😉');
    final doc = await _fehler(() => _namensDoc(n).get());
    final uid = doc.data()?['uid'] as String?;
    if (uid == null) throw KontoFehler('@$n gibt es nicht.');
    await _fehler(() => _freunde(u.uid).doc(uid).set({'name': n, 'seit': FieldValue.serverTimestamp()}));
  }

  Future<void> freundEntfernen(String uid) async {
    final u = nutzer;
    if (u == null) return;
    await _fehler(() => _freunde(u.uid).doc(uid).delete());
  }

  // ───────── Quizfragen der Leser ─────────

  Future<void> quizVorschlagen(Buch buch, String frage, List<String> antworten) async {
    final u = nutzer;
    if (u == null) throw const KontoFehler('Bitte melde dich zuerst an.');
    await _fehler(() => _db.collection('quizvorschlaege').add({
          'buchId': buch.id,
          'buchTitel': buch.titel,
          'frage': frage.trim(),
          'antworten': [for (final a in antworten) a.trim()],
          'uid': u.uid,
          'name': name ?? '',
          'status': 'neu',
          'erstellt': FieldValue.serverTimestamp(),
        }));
  }

  /// Eigene Vorschläge mit ihrem Status.
  Stream<List<Vorschlag>> meineVorschlaege() {
    final u = nutzer;
    if (u == null) return Stream.value(const []);
    return _db
        .collection('quizvorschlaege')
        .where('uid', isEqualTo: u.uid)
        .snapshots()
        .map((s) => s.docs.map(Vorschlag.ausDoc).toList());
  }

  /// Nur für den Admin: alle Vorschläge, die noch geprüft werden müssen.
  Stream<List<Vorschlag>> offeneVorschlaege() => _db
      .collection('quizvorschlaege')
      .where('status', isEqualTo: 'neu')
      .snapshots()
      .map((s) => s.docs.map(Vorschlag.ausDoc).toList());

  Future<void> freigeben(Vorschlag v) async {
    final batch = _db.batch()
      ..set(_db.collection('quizfragen').doc(v.id), {
        'buchId': v.buchId,
        'buchTitel': v.buchTitel,
        'frage': v.frage,
        'antworten': v.antworten,
        'von': v.name,
        'erstellt': FieldValue.serverTimestamp(),
      })
      ..update(_db.collection('quizvorschlaege').doc(v.id), {'status': 'frei'});
    await _fehler(batch.commit);
  }

  Future<void> ablehnen(Vorschlag v) =>
      _fehler(() => _db.collection('quizvorschlaege').doc(v.id).update({'status': 'abgelehnt'}));

  // ───────── Gemeldete Quizfragen ─────────

  /// Schickt eine Meldung an den Admin. Ohne Anmeldung geht es nicht –
  /// dann merkt sich die App die Meldung und reicht sie später nach.
  Future<void> frageMelden(FrageMeldung m) async {
    final u = nutzer;
    if (u == null) throw const KontoFehler('Bitte melde dich an, damit die Meldung beim Admin ankommt.');
    await _fehler(() => _db.collection('fragemeldungen').add({
          ...m.toJson(),
          'uid': u.uid,
          'name': name ?? '',
          'status': 'neu',
          'erstellt': FieldValue.serverTimestamp(),
        }));
  }

  /// Nur für den Admin: noch nicht bearbeitete Meldungen.
  Stream<List<FrageMeldung>> offeneMeldungen() => _db
      .collection('fragemeldungen')
      .where('status', isEqualTo: 'neu')
      .snapshots()
      .map((s) => [for (final d in s.docs) FrageMeldung.fromJson(d.data(), id: d.id)]);

  Future<void> meldungErledigt(FrageMeldung m) =>
      _fehler(() => _db.collection('fragemeldungen').doc(m.id).update({'status': 'erledigt'}));

  // ───────── Rezensionen ─────────

  CollectionReference<Map<String, dynamic>> get _rezensionen => _db.collection('rezensionen');

  // Ohne orderBy, damit Firestore keinen zusätzlichen Index braucht.
  Stream<List<Rezension>> rezensionen(String buchId) => _rezensionen
      .where('buchId', isEqualTo: buchId)
      .limit(100)
      .snapshots()
      .map((s) => s.docs.map(Rezension.ausDoc).toList()
        ..sort((a, b) => (b.erstellt ?? DateTime(2100)).compareTo(a.erstellt ?? DateTime(2100))));

  Future<void> rezensionSchreiben(String buchId, int sterne, String text, bool spoiler) async {
    final u = nutzer;
    if (u == null || name == null) throw const KontoFehler('Bitte melde dich zuerst an.');
    await _fehler(() => _rezensionen.doc('${buchId}_${u.uid}').set({
          'buchId': buchId,
          'uid': u.uid,
          'name': name,
          'sterne': sterne,
          'text': text.trim(),
          'spoiler': spoiler,
          'erstellt': FieldValue.serverTimestamp(),
        }));
  }

  Future<void> rezensionLoeschen(String id) => _fehler(() => _rezensionen.doc(id).delete());

  Future<int> hilfreichAnzahl(String rezensionId) async {
    final s = await _rezensionen.doc(rezensionId).collection('hilfreich').count().get();
    return s.count ?? 0;
  }

  Future<void> hilfreich(String rezensionId) async {
    final u = nutzer;
    if (u == null) throw const KontoFehler('Bitte melde dich zuerst an.');
    await _fehler(() => _rezensionen.doc(rezensionId).collection('hilfreich').doc(u.uid).set({'am': FieldValue.serverTimestamp()}));
  }

  // ───────── Lesegruppen ─────────

  CollectionReference<Map<String, dynamic>> get _gruppen => _db.collection('gruppen');

  Stream<List<Gruppe>> meineGruppen() {
    final u = nutzer;
    if (u == null) return Stream.value(const []);
    return _gruppen.where('mitglieder', arrayContains: u.uid).snapshots().map((s) => s.docs.map(Gruppe.ausDoc).toList());
  }

  Stream<Gruppe> gruppe(String id) => _gruppen.doc(id).snapshots().map(Gruppe.ausDoc);

  Future<Gruppe> gruppeGruenden(String gruppenName) async {
    final u = nutzer;
    if (u == null || name == null) throw const KontoFehler('Bitte melde dich zuerst an.');
    const zeichen = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final zufall = DateTime.now().microsecondsSinceEpoch;
    final code = List.generate(6, (i) => zeichen[(zufall ~/ (i * 7 + 1) + i * 13) % zeichen.length]).join();
    final ref = _gruppen.doc();
    await _fehler(() => ref.set({
          'name': gruppenName.trim(),
          'code': code,
          'ersteller': u.uid,
          'mitglieder': [u.uid],
          'namen': {u.uid: name},
          'erstellt': FieldValue.serverTimestamp(),
        }));
    return Gruppe(ref.id, gruppenName.trim(), code, [u.uid], {u.uid: name!}, null, null);
  }

  Future<void> gruppeBeitreten(String code) async {
    final u = nutzer;
    if (u == null || name == null) throw const KontoFehler('Bitte melde dich zuerst an.');
    final treffer = await _fehler(() => _gruppen.where('code', isEqualTo: code.trim().toUpperCase()).limit(1).get());
    if (treffer.docs.isEmpty) throw const KontoFehler('Diesen Code gibt es nicht.');
    await _fehler(() => treffer.docs.first.reference.update({
          'mitglieder': FieldValue.arrayUnion([u.uid]),
          'namen.${u.uid}': name,
        }));
  }

  Future<void> gruppeVerlassen(String gruppenId) async {
    final u = nutzer;
    if (u == null) return;
    await _fehler(() => _gruppen.doc(gruppenId).update({
          'mitglieder': FieldValue.arrayRemove([u.uid]),
          'namen.${u.uid}': FieldValue.delete(),
        }));
  }

  Future<void> gruppenBuchSetzen(String gruppenId, Buch buch) =>
      _fehler(() => _gruppen.doc(gruppenId).update({'buchId': buch.id, 'buchTitel': buch.titel}));

  /// Eigenen Fortschritt beim Gruppenbuch hochladen.
  Future<void> fortschrittMelden(String gruppenId, int seite, int seiten, bool gelesen) async {
    final u = nutzer;
    if (u == null || name == null) return;
    await _gruppen.doc(gruppenId).collection('fortschritt').doc(u.uid).set({
      'name': name,
      'seite': seite,
      'seiten': seiten,
      'gelesen': gelesen,
      'aktualisiert': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<GruppenFortschritt>> fortschritte(String gruppenId) =>
      _gruppen.doc(gruppenId).collection('fortschritt').snapshots().map((s) => [
            for (final d in s.docs)
              GruppenFortschritt(
                d.id,
                d.data()['name'] as String? ?? '?',
                d.data()['seite'] as int? ?? 0,
                d.data()['seiten'] as int? ?? 0,
                d.data()['gelesen'] as bool? ?? false,
              ),
          ]);

  /// Übersetzt Firebase-Fehler in verständliche deutsche Meldungen.
  Future<T> _fehler<T>(Future<T> Function() aktion) async {
    try {
      return await aktion();
    } on FirebaseAuthException catch (e) {
      throw KontoFehler(switch (e.code) {
        'email-already-in-use' => 'Mit dieser E-Mail gibt es schon ein Konto. Melde dich an.',
        'invalid-email' => 'Die E-Mail-Adresse stimmt nicht.',
        'weak-password' => 'Das Passwort ist zu schwach (mindestens 6 Zeichen).',
        'wrong-password' || 'invalid-credential' || 'user-not-found' => 'E-Mail oder Passwort falsch.',
        'too-many-requests' => 'Zu viele Versuche. Probier es später noch einmal.',
        'network-request-failed' => 'Keine Internetverbindung.',
        'requires-recent-login' => 'Bitte melde dich neu an und versuch es dann noch einmal.',
        _ => 'Das hat nicht geklappt (${e.code}).',
      });
    } on FirebaseException catch (e) {
      throw KontoFehler(e.code == 'unavailable'
          ? 'Keine Internetverbindung.'
          : e.code == 'permission-denied'
              ? 'Die Online-Rangliste ist noch nicht freigeschaltet.'
              : 'Das hat nicht geklappt (${e.code}).');
    }
  }
}
