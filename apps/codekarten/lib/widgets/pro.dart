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
          ProVorteil(Icons.all_inclusive, l.proVorteilAlle),
          ProVorteil(Icons.new_releases_outlined, l.proVorteilNeue),
          ProVorteil(Icons.block, l.proVorteilWerbefrei),
          ProVorteil(Icons.favorite, l.proVorteilUnterstuetzen),
        ],
      ),
    ),
  );
}
