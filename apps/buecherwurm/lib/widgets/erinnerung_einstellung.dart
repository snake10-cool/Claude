import 'package:flutter/material.dart';

import '../main.dart';
import '../services/erinnerung.dart';

/// Schalter und Uhrzeit für die sanfte Lese-Erinnerung (Profil).
class ErinnerungEinstellung extends StatefulWidget {
  const ErinnerungEinstellung({super.key});

  @override
  State<ErinnerungEinstellung> createState() => _ErinnerungEinstellungState();
}

class _ErinnerungEinstellungState extends State<ErinnerungEinstellung> {
  bool? _an;
  var _zeit = const TimeOfDay(hour: 19, minute: 0);

  @override
  void initState() {
    super.initState();
    Erinnerung.einstellungen().then((e) {
      if (mounted) {
        setState(() {
          _an = e.$1;
          _zeit = TimeOfDay(hour: e.$2, minute: e.$3);
        });
      }
    });
  }

  Future<void> _speichern() => Erinnerung.instanz
      .setzen(SpeicherScope.of(context), an: _an ?? false, stunde: _zeit.hour, minute: _zeit.minute);

  @override
  Widget build(BuildContext context) {
    final an = _an ?? false;
    return Column(
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.notifications_none),
          title: const Text('Lese-Erinnerung'),
          subtitle: Text(an
              ? 'Höchstens einmal am Tag um ${_zeit.format(context)} – nicht, wenn du schon gelesen hast'
              : 'Aus. Eine freundliche Erinnerung am Tag, wenn du willst.'),
          value: an,
          onChanged: _an == null
              ? null
              : (v) {
                  setState(() => _an = v);
                  _speichern();
                },
        ),
        if (an)
          ListTile(
            leading: const SizedBox(width: 24),
            title: const Text('Uhrzeit'),
            trailing: Text(_zeit.format(context)),
            onTap: () async {
              final neu = await showTimePicker(context: context, initialTime: _zeit);
              if (neu == null) return;
              setState(() => _zeit = neu);
              await _speichern();
            },
          ),
      ],
    );
  }
}
