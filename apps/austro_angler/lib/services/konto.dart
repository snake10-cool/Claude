import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'fang_dienst.dart';

/// Anmeldung mit E-Mail und Passwort sowie der öffentliche Nutzername.
class Konto extends ChangeNotifier {
  Konto() {
    _abo = FirebaseAuth.instance.authStateChanges().listen(_nutzerGeaendert);
  }

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  late final StreamSubscription<User?> _abo;

  User? nutzer;
  String? name;

  bool get angemeldet => nutzer != null;
  String? get uid => nutzer?.uid;

  Future<void> _nutzerGeaendert(User? u) async {
    nutzer = u;
    name = null;
    notifyListeners();
    if (u == null) return;
    try {
      final doc = await _db.doc('nutzer/${u.uid}').get();
      name = (doc.data()?['name'] as String?) ?? name;
    } catch (_) {
      // Offline – der Name kommt beim nächsten Mal.
    }
    notifyListeners();
  }

  static String? nameProblem(String name) {
    final n = name.trim();
    if (n.length < 3) return 'Mindestens 3 Zeichen';
    if (n.length > 20) return 'Höchstens 20 Zeichen';
    if (!RegExp(r'^[A-Za-z0-9ÄÖÜäöüß_.\-]+$').hasMatch(n)) {
      return 'Nur Buchstaben, Zahlen, _ . -';
    }
    return null;
  }

  Future<void> registrieren(String email, String passwort, String name) async {
    final n = name.trim();
    final schluessel = n.toLowerCase();
    final vergeben = await _db.doc('namen/$schluessel').get();
    if (vergeben.exists) throw KontoFehler('Der Name "$n" ist schon vergeben.');

    final cred = await _fehlerUebersetzen(() =>
        _auth.createUserWithEmailAndPassword(email: email.trim(), password: passwort));
    final uid = cred.user!.uid;
    try {
      final batch = _db.batch()
        ..set(_db.doc('namen/$schluessel'), {'uid': uid})
        ..set(_db.doc('nutzer/$uid'), {
          'name': n,
          'erstellt': FieldValue.serverTimestamp(),
        });
      await batch.commit();
    } catch (_) {
      await cred.user!.delete();
      throw KontoFehler('Der Name "$n" ist schon vergeben.');
    }
    this.name = n;
    notifyListeners();
  }

  Future<void> anmelden(String email, String passwort) => _fehlerUebersetzen(
      () => _auth.signInWithEmailAndPassword(email: email.trim(), password: passwort));

  Future<void> passwortVergessen(String email) => _fehlerUebersetzen(
      () => _auth.sendPasswordResetEmail(email: email.trim()));

  Future<void> abmelden() => _auth.signOut();

  /// Löscht alle Daten und das Konto. Braucht das Passwort zur Bestätigung.
  Future<void> kontoLoeschen(String passwort) async {
    final u = nutzer;
    if (u == null) return;
    await _fehlerUebersetzen(() => u.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: u.email!, password: passwort)));
    await fangDienst.allesLoeschen(u.uid, name);
    await u.delete();
  }

  Future<T> _fehlerUebersetzen<T>(Future<T> Function() aktion) async {
    try {
      return await aktion();
    } on FirebaseAuthException catch (e) {
      throw KontoFehler(switch (e.code) {
        'invalid-email' => 'Die E-Mail-Adresse ist ungültig.',
        'email-already-in-use' => 'Mit dieser E-Mail gibt es schon ein Konto.',
        'weak-password' => 'Das Passwort ist zu schwach (mind. 6 Zeichen).',
        'user-not-found' ||
        'wrong-password' ||
        'invalid-credential' =>
          'E-Mail oder Passwort stimmt nicht.',
        'too-many-requests' => 'Zu viele Versuche – bitte später nochmal.',
        'network-request-failed' => 'Keine Internetverbindung.',
        _ => 'Fehler: ${e.message ?? e.code}',
      });
    }
  }

  @override
  void dispose() {
    _abo.cancel();
    super.dispose();
  }
}

class KontoFehler implements Exception {
  KontoFehler(this.text);

  final String text;

  @override
  String toString() => text;
}
