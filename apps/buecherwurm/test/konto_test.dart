import 'package:buecherwurm/firebase_options.dart';
import 'package:buecherwurm/services/konto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('@Namen werden vereinheitlicht und geprüft', () {
    expect(nameNormal(' @LeseRatte12 '), 'leseratte12');
    expect(nameMuster.hasMatch('leseratte12'), isTrue);
    expect(nameMuster.hasMatch('le'), isFalse);
    expect(nameMuster.hasMatch('lese ratte'), isFalse);
    expect(nameMuster.hasMatch('lese.ratte_1'), isTrue);
  });

  test('Ohne Zugangsdaten bleibt Firebase aus', () {
    expect(firebaseKonfiguriert, firebaseOptionen.apiKey.isNotEmpty);
  });
}
