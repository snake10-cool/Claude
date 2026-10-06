import 'package:app_kauf/app_kauf.dart';
import 'package:flutter/material.dart';

import '../dienste.dart';
import '../l10n/l.dart';

void proSeiteOeffnen(BuildContext context) {
  final l = context.l;
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ProSeite(
        dienst: kauf,
        titel: l.proTitel,
        vorteile: [
          ProVorteil(Icons.history, l.proArchiv),
          ProVorteil(Icons.all_inclusive, l.proEndlos),
          ProVorteil(Icons.block, l.proWerbefrei),
          ProVorteil(Icons.favorite, l.proUnterstuetzen),
        ],
      ),
    ),
  );
}
