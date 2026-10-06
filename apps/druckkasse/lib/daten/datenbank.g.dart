// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'datenbank.dart';

// ignore_for_file: type=lint
class $DruckerTabelleTable extends DruckerTabelle
    with TableInfo<$DruckerTabelleTable, Drucker> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DruckerTabelleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _leistungWattMeta = const VerificationMeta(
    'leistungWatt',
  );
  @override
  late final GeneratedColumn<int> leistungWatt = GeneratedColumn<int>(
    'leistung_watt',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _anschaffungCentMeta = const VerificationMeta(
    'anschaffungCent',
  );
  @override
  late final GeneratedColumn<int> anschaffungCent = GeneratedColumn<int>(
    'anschaffung_cent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lebensdauerStundenMeta =
      const VerificationMeta('lebensdauerStunden');
  @override
  late final GeneratedColumn<int> lebensdauerStunden = GeneratedColumn<int>(
    'lebensdauer_stunden',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archiviertMeta = const VerificationMeta(
    'archiviert',
  );
  @override
  late final GeneratedColumn<bool> archiviert = GeneratedColumn<bool>(
    'archiviert',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archiviert" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    leistungWatt,
    anschaffungCent,
    lebensdauerStunden,
    archiviert,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'drucker';
  @override
  VerificationContext validateIntegrity(
    Insertable<Drucker> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('leistung_watt')) {
      context.handle(
        _leistungWattMeta,
        leistungWatt.isAcceptableOrUnknown(
          data['leistung_watt']!,
          _leistungWattMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_leistungWattMeta);
    }
    if (data.containsKey('anschaffung_cent')) {
      context.handle(
        _anschaffungCentMeta,
        anschaffungCent.isAcceptableOrUnknown(
          data['anschaffung_cent']!,
          _anschaffungCentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_anschaffungCentMeta);
    }
    if (data.containsKey('lebensdauer_stunden')) {
      context.handle(
        _lebensdauerStundenMeta,
        lebensdauerStunden.isAcceptableOrUnknown(
          data['lebensdauer_stunden']!,
          _lebensdauerStundenMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lebensdauerStundenMeta);
    }
    if (data.containsKey('archiviert')) {
      context.handle(
        _archiviertMeta,
        archiviert.isAcceptableOrUnknown(data['archiviert']!, _archiviertMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Drucker map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Drucker(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      leistungWatt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}leistung_watt'],
      )!,
      anschaffungCent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}anschaffung_cent'],
      )!,
      lebensdauerStunden: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lebensdauer_stunden'],
      )!,
      archiviert: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archiviert'],
      )!,
    );
  }

  @override
  $DruckerTabelleTable createAlias(String alias) {
    return $DruckerTabelleTable(attachedDatabase, alias);
  }
}

class Drucker extends DataClass implements Insertable<Drucker> {
  final int id;
  final String name;

  /// Durchschnittlicher Verbrauch beim Drucken (nicht das Netzteil-Maximum).
  final int leistungWatt;
  final int anschaffungCent;

  /// Nach so vielen Stunden gilt der Drucker als abbezahlt.
  final int lebensdauerStunden;
  final bool archiviert;
  const Drucker({
    required this.id,
    required this.name,
    required this.leistungWatt,
    required this.anschaffungCent,
    required this.lebensdauerStunden,
    required this.archiviert,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['leistung_watt'] = Variable<int>(leistungWatt);
    map['anschaffung_cent'] = Variable<int>(anschaffungCent);
    map['lebensdauer_stunden'] = Variable<int>(lebensdauerStunden);
    map['archiviert'] = Variable<bool>(archiviert);
    return map;
  }

  DruckerTabelleCompanion toCompanion(bool nullToAbsent) {
    return DruckerTabelleCompanion(
      id: Value(id),
      name: Value(name),
      leistungWatt: Value(leistungWatt),
      anschaffungCent: Value(anschaffungCent),
      lebensdauerStunden: Value(lebensdauerStunden),
      archiviert: Value(archiviert),
    );
  }

  factory Drucker.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Drucker(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      leistungWatt: serializer.fromJson<int>(json['leistungWatt']),
      anschaffungCent: serializer.fromJson<int>(json['anschaffungCent']),
      lebensdauerStunden: serializer.fromJson<int>(json['lebensdauerStunden']),
      archiviert: serializer.fromJson<bool>(json['archiviert']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'leistungWatt': serializer.toJson<int>(leistungWatt),
      'anschaffungCent': serializer.toJson<int>(anschaffungCent),
      'lebensdauerStunden': serializer.toJson<int>(lebensdauerStunden),
      'archiviert': serializer.toJson<bool>(archiviert),
    };
  }

  Drucker copyWith({
    int? id,
    String? name,
    int? leistungWatt,
    int? anschaffungCent,
    int? lebensdauerStunden,
    bool? archiviert,
  }) => Drucker(
    id: id ?? this.id,
    name: name ?? this.name,
    leistungWatt: leistungWatt ?? this.leistungWatt,
    anschaffungCent: anschaffungCent ?? this.anschaffungCent,
    lebensdauerStunden: lebensdauerStunden ?? this.lebensdauerStunden,
    archiviert: archiviert ?? this.archiviert,
  );
  Drucker copyWithCompanion(DruckerTabelleCompanion data) {
    return Drucker(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      leistungWatt: data.leistungWatt.present
          ? data.leistungWatt.value
          : this.leistungWatt,
      anschaffungCent: data.anschaffungCent.present
          ? data.anschaffungCent.value
          : this.anschaffungCent,
      lebensdauerStunden: data.lebensdauerStunden.present
          ? data.lebensdauerStunden.value
          : this.lebensdauerStunden,
      archiviert: data.archiviert.present
          ? data.archiviert.value
          : this.archiviert,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Drucker(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('leistungWatt: $leistungWatt, ')
          ..write('anschaffungCent: $anschaffungCent, ')
          ..write('lebensdauerStunden: $lebensdauerStunden, ')
          ..write('archiviert: $archiviert')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    leistungWatt,
    anschaffungCent,
    lebensdauerStunden,
    archiviert,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Drucker &&
          other.id == this.id &&
          other.name == this.name &&
          other.leistungWatt == this.leistungWatt &&
          other.anschaffungCent == this.anschaffungCent &&
          other.lebensdauerStunden == this.lebensdauerStunden &&
          other.archiviert == this.archiviert);
}

class DruckerTabelleCompanion extends UpdateCompanion<Drucker> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> leistungWatt;
  final Value<int> anschaffungCent;
  final Value<int> lebensdauerStunden;
  final Value<bool> archiviert;
  const DruckerTabelleCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.leistungWatt = const Value.absent(),
    this.anschaffungCent = const Value.absent(),
    this.lebensdauerStunden = const Value.absent(),
    this.archiviert = const Value.absent(),
  });
  DruckerTabelleCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int leistungWatt,
    required int anschaffungCent,
    required int lebensdauerStunden,
    this.archiviert = const Value.absent(),
  }) : name = Value(name),
       leistungWatt = Value(leistungWatt),
       anschaffungCent = Value(anschaffungCent),
       lebensdauerStunden = Value(lebensdauerStunden);
  static Insertable<Drucker> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? leistungWatt,
    Expression<int>? anschaffungCent,
    Expression<int>? lebensdauerStunden,
    Expression<bool>? archiviert,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (leistungWatt != null) 'leistung_watt': leistungWatt,
      if (anschaffungCent != null) 'anschaffung_cent': anschaffungCent,
      if (lebensdauerStunden != null) 'lebensdauer_stunden': lebensdauerStunden,
      if (archiviert != null) 'archiviert': archiviert,
    });
  }

  DruckerTabelleCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? leistungWatt,
    Value<int>? anschaffungCent,
    Value<int>? lebensdauerStunden,
    Value<bool>? archiviert,
  }) {
    return DruckerTabelleCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      leistungWatt: leistungWatt ?? this.leistungWatt,
      anschaffungCent: anschaffungCent ?? this.anschaffungCent,
      lebensdauerStunden: lebensdauerStunden ?? this.lebensdauerStunden,
      archiviert: archiviert ?? this.archiviert,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (leistungWatt.present) {
      map['leistung_watt'] = Variable<int>(leistungWatt.value);
    }
    if (anschaffungCent.present) {
      map['anschaffung_cent'] = Variable<int>(anschaffungCent.value);
    }
    if (lebensdauerStunden.present) {
      map['lebensdauer_stunden'] = Variable<int>(lebensdauerStunden.value);
    }
    if (archiviert.present) {
      map['archiviert'] = Variable<bool>(archiviert.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DruckerTabelleCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('leistungWatt: $leistungWatt, ')
          ..write('anschaffungCent: $anschaffungCent, ')
          ..write('lebensdauerStunden: $lebensdauerStunden, ')
          ..write('archiviert: $archiviert')
          ..write(')'))
        .toString();
  }
}

class $FilamentTabelleTable extends FilamentTabelle
    with TableInfo<$FilamentTabelleTable, Filament> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FilamentTabelleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _materialMeta = const VerificationMeta(
    'material',
  );
  @override
  late final GeneratedColumn<String> material = GeneratedColumn<String>(
    'material',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _farbeMeta = const VerificationMeta('farbe');
  @override
  late final GeneratedColumn<int> farbe = GeneratedColumn<int>(
    'farbe',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _preisProKgCentMeta = const VerificationMeta(
    'preisProKgCent',
  );
  @override
  late final GeneratedColumn<int> preisProKgCent = GeneratedColumn<int>(
    'preis_pro_kg_cent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archiviertMeta = const VerificationMeta(
    'archiviert',
  );
  @override
  late final GeneratedColumn<bool> archiviert = GeneratedColumn<bool>(
    'archiviert',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archiviert" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    material,
    farbe,
    preisProKgCent,
    archiviert,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'filamente';
  @override
  VerificationContext validateIntegrity(
    Insertable<Filament> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('material')) {
      context.handle(
        _materialMeta,
        material.isAcceptableOrUnknown(data['material']!, _materialMeta),
      );
    } else if (isInserting) {
      context.missing(_materialMeta);
    }
    if (data.containsKey('farbe')) {
      context.handle(
        _farbeMeta,
        farbe.isAcceptableOrUnknown(data['farbe']!, _farbeMeta),
      );
    } else if (isInserting) {
      context.missing(_farbeMeta);
    }
    if (data.containsKey('preis_pro_kg_cent')) {
      context.handle(
        _preisProKgCentMeta,
        preisProKgCent.isAcceptableOrUnknown(
          data['preis_pro_kg_cent']!,
          _preisProKgCentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_preisProKgCentMeta);
    }
    if (data.containsKey('archiviert')) {
      context.handle(
        _archiviertMeta,
        archiviert.isAcceptableOrUnknown(data['archiviert']!, _archiviertMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Filament map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Filament(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      material: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}material'],
      )!,
      farbe: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}farbe'],
      )!,
      preisProKgCent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}preis_pro_kg_cent'],
      )!,
      archiviert: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archiviert'],
      )!,
    );
  }

  @override
  $FilamentTabelleTable createAlias(String alias) {
    return $FilamentTabelleTable(attachedDatabase, alias);
  }
}

class Filament extends DataClass implements Insertable<Filament> {
  final int id;
  final String name;
  final String material;

  /// Farbe als ARGB-Zahl (z. B. 0xFF2196F3).
  final int farbe;
  final int preisProKgCent;
  final bool archiviert;
  const Filament({
    required this.id,
    required this.name,
    required this.material,
    required this.farbe,
    required this.preisProKgCent,
    required this.archiviert,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['material'] = Variable<String>(material);
    map['farbe'] = Variable<int>(farbe);
    map['preis_pro_kg_cent'] = Variable<int>(preisProKgCent);
    map['archiviert'] = Variable<bool>(archiviert);
    return map;
  }

  FilamentTabelleCompanion toCompanion(bool nullToAbsent) {
    return FilamentTabelleCompanion(
      id: Value(id),
      name: Value(name),
      material: Value(material),
      farbe: Value(farbe),
      preisProKgCent: Value(preisProKgCent),
      archiviert: Value(archiviert),
    );
  }

  factory Filament.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Filament(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      material: serializer.fromJson<String>(json['material']),
      farbe: serializer.fromJson<int>(json['farbe']),
      preisProKgCent: serializer.fromJson<int>(json['preisProKgCent']),
      archiviert: serializer.fromJson<bool>(json['archiviert']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'material': serializer.toJson<String>(material),
      'farbe': serializer.toJson<int>(farbe),
      'preisProKgCent': serializer.toJson<int>(preisProKgCent),
      'archiviert': serializer.toJson<bool>(archiviert),
    };
  }

  Filament copyWith({
    int? id,
    String? name,
    String? material,
    int? farbe,
    int? preisProKgCent,
    bool? archiviert,
  }) => Filament(
    id: id ?? this.id,
    name: name ?? this.name,
    material: material ?? this.material,
    farbe: farbe ?? this.farbe,
    preisProKgCent: preisProKgCent ?? this.preisProKgCent,
    archiviert: archiviert ?? this.archiviert,
  );
  Filament copyWithCompanion(FilamentTabelleCompanion data) {
    return Filament(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      material: data.material.present ? data.material.value : this.material,
      farbe: data.farbe.present ? data.farbe.value : this.farbe,
      preisProKgCent: data.preisProKgCent.present
          ? data.preisProKgCent.value
          : this.preisProKgCent,
      archiviert: data.archiviert.present
          ? data.archiviert.value
          : this.archiviert,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Filament(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('material: $material, ')
          ..write('farbe: $farbe, ')
          ..write('preisProKgCent: $preisProKgCent, ')
          ..write('archiviert: $archiviert')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, material, farbe, preisProKgCent, archiviert);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Filament &&
          other.id == this.id &&
          other.name == this.name &&
          other.material == this.material &&
          other.farbe == this.farbe &&
          other.preisProKgCent == this.preisProKgCent &&
          other.archiviert == this.archiviert);
}

class FilamentTabelleCompanion extends UpdateCompanion<Filament> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> material;
  final Value<int> farbe;
  final Value<int> preisProKgCent;
  final Value<bool> archiviert;
  const FilamentTabelleCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.material = const Value.absent(),
    this.farbe = const Value.absent(),
    this.preisProKgCent = const Value.absent(),
    this.archiviert = const Value.absent(),
  });
  FilamentTabelleCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String material,
    required int farbe,
    required int preisProKgCent,
    this.archiviert = const Value.absent(),
  }) : name = Value(name),
       material = Value(material),
       farbe = Value(farbe),
       preisProKgCent = Value(preisProKgCent);
  static Insertable<Filament> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? material,
    Expression<int>? farbe,
    Expression<int>? preisProKgCent,
    Expression<bool>? archiviert,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (material != null) 'material': material,
      if (farbe != null) 'farbe': farbe,
      if (preisProKgCent != null) 'preis_pro_kg_cent': preisProKgCent,
      if (archiviert != null) 'archiviert': archiviert,
    });
  }

  FilamentTabelleCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? material,
    Value<int>? farbe,
    Value<int>? preisProKgCent,
    Value<bool>? archiviert,
  }) {
    return FilamentTabelleCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      material: material ?? this.material,
      farbe: farbe ?? this.farbe,
      preisProKgCent: preisProKgCent ?? this.preisProKgCent,
      archiviert: archiviert ?? this.archiviert,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (material.present) {
      map['material'] = Variable<String>(material.value);
    }
    if (farbe.present) {
      map['farbe'] = Variable<int>(farbe.value);
    }
    if (preisProKgCent.present) {
      map['preis_pro_kg_cent'] = Variable<int>(preisProKgCent.value);
    }
    if (archiviert.present) {
      map['archiviert'] = Variable<bool>(archiviert.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FilamentTabelleCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('material: $material, ')
          ..write('farbe: $farbe, ')
          ..write('preisProKgCent: $preisProKgCent, ')
          ..write('archiviert: $archiviert')
          ..write(')'))
        .toString();
  }
}

class $ExtraTabelleTable extends ExtraTabelle
    with TableInfo<$ExtraTabelleTable, Extra> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExtraTabelleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kostenCentMeta = const VerificationMeta(
    'kostenCent',
  );
  @override
  late final GeneratedColumn<int> kostenCent = GeneratedColumn<int>(
    'kosten_cent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archiviertMeta = const VerificationMeta(
    'archiviert',
  );
  @override
  late final GeneratedColumn<bool> archiviert = GeneratedColumn<bool>(
    'archiviert',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archiviert" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, kostenCent, archiviert];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'extras';
  @override
  VerificationContext validateIntegrity(
    Insertable<Extra> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('kosten_cent')) {
      context.handle(
        _kostenCentMeta,
        kostenCent.isAcceptableOrUnknown(data['kosten_cent']!, _kostenCentMeta),
      );
    } else if (isInserting) {
      context.missing(_kostenCentMeta);
    }
    if (data.containsKey('archiviert')) {
      context.handle(
        _archiviertMeta,
        archiviert.isAcceptableOrUnknown(data['archiviert']!, _archiviertMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Extra map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Extra(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kostenCent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}kosten_cent'],
      )!,
      archiviert: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archiviert'],
      )!,
    );
  }

  @override
  $ExtraTabelleTable createAlias(String alias) {
    return $ExtraTabelleTable(attachedDatabase, alias);
  }
}

class Extra extends DataClass implements Insertable<Extra> {
  final int id;
  final String name;
  final int kostenCent;
  final bool archiviert;
  const Extra({
    required this.id,
    required this.name,
    required this.kostenCent,
    required this.archiviert,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['kosten_cent'] = Variable<int>(kostenCent);
    map['archiviert'] = Variable<bool>(archiviert);
    return map;
  }

  ExtraTabelleCompanion toCompanion(bool nullToAbsent) {
    return ExtraTabelleCompanion(
      id: Value(id),
      name: Value(name),
      kostenCent: Value(kostenCent),
      archiviert: Value(archiviert),
    );
  }

  factory Extra.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Extra(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kostenCent: serializer.fromJson<int>(json['kostenCent']),
      archiviert: serializer.fromJson<bool>(json['archiviert']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'kostenCent': serializer.toJson<int>(kostenCent),
      'archiviert': serializer.toJson<bool>(archiviert),
    };
  }

  Extra copyWith({int? id, String? name, int? kostenCent, bool? archiviert}) =>
      Extra(
        id: id ?? this.id,
        name: name ?? this.name,
        kostenCent: kostenCent ?? this.kostenCent,
        archiviert: archiviert ?? this.archiviert,
      );
  Extra copyWithCompanion(ExtraTabelleCompanion data) {
    return Extra(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kostenCent: data.kostenCent.present
          ? data.kostenCent.value
          : this.kostenCent,
      archiviert: data.archiviert.present
          ? data.archiviert.value
          : this.archiviert,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Extra(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kostenCent: $kostenCent, ')
          ..write('archiviert: $archiviert')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, kostenCent, archiviert);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Extra &&
          other.id == this.id &&
          other.name == this.name &&
          other.kostenCent == this.kostenCent &&
          other.archiviert == this.archiviert);
}

class ExtraTabelleCompanion extends UpdateCompanion<Extra> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> kostenCent;
  final Value<bool> archiviert;
  const ExtraTabelleCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kostenCent = const Value.absent(),
    this.archiviert = const Value.absent(),
  });
  ExtraTabelleCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int kostenCent,
    this.archiviert = const Value.absent(),
  }) : name = Value(name),
       kostenCent = Value(kostenCent);
  static Insertable<Extra> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? kostenCent,
    Expression<bool>? archiviert,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kostenCent != null) 'kosten_cent': kostenCent,
      if (archiviert != null) 'archiviert': archiviert,
    });
  }

  ExtraTabelleCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? kostenCent,
    Value<bool>? archiviert,
  }) {
    return ExtraTabelleCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      kostenCent: kostenCent ?? this.kostenCent,
      archiviert: archiviert ?? this.archiviert,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kostenCent.present) {
      map['kosten_cent'] = Variable<int>(kostenCent.value);
    }
    if (archiviert.present) {
      map['archiviert'] = Variable<bool>(archiviert.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExtraTabelleCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kostenCent: $kostenCent, ')
          ..write('archiviert: $archiviert')
          ..write(')'))
        .toString();
  }
}

class $ProduktTabelleTable extends ProduktTabelle
    with TableInfo<$ProduktTabelleTable, Produkt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProduktTabelleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
    'symbol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('📦'),
  );
  static const VerificationMeta _farbeMeta = const VerificationMeta('farbe');
  @override
  late final GeneratedColumn<int> farbe = GeneratedColumn<int>(
    'farbe',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _druckerIdMeta = const VerificationMeta(
    'druckerId',
  );
  @override
  late final GeneratedColumn<int> druckerId = GeneratedColumn<int>(
    'drucker_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES drucker (id)',
    ),
  );
  static const VerificationMeta _druckzeitMinutenMeta = const VerificationMeta(
    'druckzeitMinuten',
  );
  @override
  late final GeneratedColumn<int> druckzeitMinuten = GeneratedColumn<int>(
    'druckzeit_minuten',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stueckProDruckMeta = const VerificationMeta(
    'stueckProDruck',
  );
  @override
  late final GeneratedColumn<int> stueckProDruck = GeneratedColumn<int>(
    'stueck_pro_druck',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _spuelabfallGrammMeta = const VerificationMeta(
    'spuelabfallGramm',
  );
  @override
  late final GeneratedColumn<double> spuelabfallGramm = GeneratedColumn<double>(
    'spuelabfall_gramm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _arbeitMinutenMeta = const VerificationMeta(
    'arbeitMinuten',
  );
  @override
  late final GeneratedColumn<int> arbeitMinuten = GeneratedColumn<int>(
    'arbeit_minuten',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _aufschlagProzentMeta = const VerificationMeta(
    'aufschlagProzent',
  );
  @override
  late final GeneratedColumn<int> aufschlagProzent = GeneratedColumn<int>(
    'aufschlag_prozent',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _preisManuellCentMeta = const VerificationMeta(
    'preisManuellCent',
  );
  @override
  late final GeneratedColumn<int> preisManuellCent = GeneratedColumn<int>(
    'preis_manuell_cent',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortierungMeta = const VerificationMeta(
    'sortierung',
  );
  @override
  late final GeneratedColumn<int> sortierung = GeneratedColumn<int>(
    'sortierung',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _archiviertMeta = const VerificationMeta(
    'archiviert',
  );
  @override
  late final GeneratedColumn<bool> archiviert = GeneratedColumn<bool>(
    'archiviert',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archiviert" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    symbol,
    farbe,
    druckerId,
    druckzeitMinuten,
    stueckProDruck,
    spuelabfallGramm,
    arbeitMinuten,
    aufschlagProzent,
    preisManuellCent,
    sortierung,
    archiviert,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'produkte';
  @override
  VerificationContext validateIntegrity(
    Insertable<Produkt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('symbol')) {
      context.handle(
        _symbolMeta,
        symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta),
      );
    }
    if (data.containsKey('farbe')) {
      context.handle(
        _farbeMeta,
        farbe.isAcceptableOrUnknown(data['farbe']!, _farbeMeta),
      );
    } else if (isInserting) {
      context.missing(_farbeMeta);
    }
    if (data.containsKey('drucker_id')) {
      context.handle(
        _druckerIdMeta,
        druckerId.isAcceptableOrUnknown(data['drucker_id']!, _druckerIdMeta),
      );
    }
    if (data.containsKey('druckzeit_minuten')) {
      context.handle(
        _druckzeitMinutenMeta,
        druckzeitMinuten.isAcceptableOrUnknown(
          data['druckzeit_minuten']!,
          _druckzeitMinutenMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_druckzeitMinutenMeta);
    }
    if (data.containsKey('stueck_pro_druck')) {
      context.handle(
        _stueckProDruckMeta,
        stueckProDruck.isAcceptableOrUnknown(
          data['stueck_pro_druck']!,
          _stueckProDruckMeta,
        ),
      );
    }
    if (data.containsKey('spuelabfall_gramm')) {
      context.handle(
        _spuelabfallGrammMeta,
        spuelabfallGramm.isAcceptableOrUnknown(
          data['spuelabfall_gramm']!,
          _spuelabfallGrammMeta,
        ),
      );
    }
    if (data.containsKey('arbeit_minuten')) {
      context.handle(
        _arbeitMinutenMeta,
        arbeitMinuten.isAcceptableOrUnknown(
          data['arbeit_minuten']!,
          _arbeitMinutenMeta,
        ),
      );
    }
    if (data.containsKey('aufschlag_prozent')) {
      context.handle(
        _aufschlagProzentMeta,
        aufschlagProzent.isAcceptableOrUnknown(
          data['aufschlag_prozent']!,
          _aufschlagProzentMeta,
        ),
      );
    }
    if (data.containsKey('preis_manuell_cent')) {
      context.handle(
        _preisManuellCentMeta,
        preisManuellCent.isAcceptableOrUnknown(
          data['preis_manuell_cent']!,
          _preisManuellCentMeta,
        ),
      );
    }
    if (data.containsKey('sortierung')) {
      context.handle(
        _sortierungMeta,
        sortierung.isAcceptableOrUnknown(data['sortierung']!, _sortierungMeta),
      );
    }
    if (data.containsKey('archiviert')) {
      context.handle(
        _archiviertMeta,
        archiviert.isAcceptableOrUnknown(data['archiviert']!, _archiviertMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Produkt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Produkt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      symbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symbol'],
      )!,
      farbe: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}farbe'],
      )!,
      druckerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}drucker_id'],
      ),
      druckzeitMinuten: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}druckzeit_minuten'],
      )!,
      stueckProDruck: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stueck_pro_druck'],
      )!,
      spuelabfallGramm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}spuelabfall_gramm'],
      )!,
      arbeitMinuten: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}arbeit_minuten'],
      )!,
      aufschlagProzent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}aufschlag_prozent'],
      ),
      preisManuellCent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}preis_manuell_cent'],
      ),
      sortierung: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sortierung'],
      )!,
      archiviert: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archiviert'],
      )!,
    );
  }

  @override
  $ProduktTabelleTable createAlias(String alias) {
    return $ProduktTabelleTable(attachedDatabase, alias);
  }
}

class Produkt extends DataClass implements Insertable<Produkt> {
  final int id;
  final String name;

  /// Ein Emoji als Bild für den Verkaufen-Knopf, z. B. 🐉.
  final String symbol;
  final int farbe;
  final int? druckerId;
  final int druckzeitMinuten;
  final int stueckProDruck;

  /// Spülabfall bei Farbwechseln (AMS), in Gramm pro Druck.
  final double spuelabfallGramm;

  /// Handarbeit pro Stück (Nacharbeit, Zusammenbauen, Verpacken).
  final int arbeitMinuten;

  /// Eigener Aufschlag; `null` = Standard aus den Einstellungen.
  final int? aufschlagProzent;

  /// Fester Verkaufspreis; `null` = Preisvorschlag verwenden.
  final int? preisManuellCent;
  final int sortierung;
  final bool archiviert;
  const Produkt({
    required this.id,
    required this.name,
    required this.symbol,
    required this.farbe,
    this.druckerId,
    required this.druckzeitMinuten,
    required this.stueckProDruck,
    required this.spuelabfallGramm,
    required this.arbeitMinuten,
    this.aufschlagProzent,
    this.preisManuellCent,
    required this.sortierung,
    required this.archiviert,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['symbol'] = Variable<String>(symbol);
    map['farbe'] = Variable<int>(farbe);
    if (!nullToAbsent || druckerId != null) {
      map['drucker_id'] = Variable<int>(druckerId);
    }
    map['druckzeit_minuten'] = Variable<int>(druckzeitMinuten);
    map['stueck_pro_druck'] = Variable<int>(stueckProDruck);
    map['spuelabfall_gramm'] = Variable<double>(spuelabfallGramm);
    map['arbeit_minuten'] = Variable<int>(arbeitMinuten);
    if (!nullToAbsent || aufschlagProzent != null) {
      map['aufschlag_prozent'] = Variable<int>(aufschlagProzent);
    }
    if (!nullToAbsent || preisManuellCent != null) {
      map['preis_manuell_cent'] = Variable<int>(preisManuellCent);
    }
    map['sortierung'] = Variable<int>(sortierung);
    map['archiviert'] = Variable<bool>(archiviert);
    return map;
  }

  ProduktTabelleCompanion toCompanion(bool nullToAbsent) {
    return ProduktTabelleCompanion(
      id: Value(id),
      name: Value(name),
      symbol: Value(symbol),
      farbe: Value(farbe),
      druckerId: druckerId == null && nullToAbsent
          ? const Value.absent()
          : Value(druckerId),
      druckzeitMinuten: Value(druckzeitMinuten),
      stueckProDruck: Value(stueckProDruck),
      spuelabfallGramm: Value(spuelabfallGramm),
      arbeitMinuten: Value(arbeitMinuten),
      aufschlagProzent: aufschlagProzent == null && nullToAbsent
          ? const Value.absent()
          : Value(aufschlagProzent),
      preisManuellCent: preisManuellCent == null && nullToAbsent
          ? const Value.absent()
          : Value(preisManuellCent),
      sortierung: Value(sortierung),
      archiviert: Value(archiviert),
    );
  }

  factory Produkt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Produkt(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      symbol: serializer.fromJson<String>(json['symbol']),
      farbe: serializer.fromJson<int>(json['farbe']),
      druckerId: serializer.fromJson<int?>(json['druckerId']),
      druckzeitMinuten: serializer.fromJson<int>(json['druckzeitMinuten']),
      stueckProDruck: serializer.fromJson<int>(json['stueckProDruck']),
      spuelabfallGramm: serializer.fromJson<double>(json['spuelabfallGramm']),
      arbeitMinuten: serializer.fromJson<int>(json['arbeitMinuten']),
      aufschlagProzent: serializer.fromJson<int?>(json['aufschlagProzent']),
      preisManuellCent: serializer.fromJson<int?>(json['preisManuellCent']),
      sortierung: serializer.fromJson<int>(json['sortierung']),
      archiviert: serializer.fromJson<bool>(json['archiviert']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'symbol': serializer.toJson<String>(symbol),
      'farbe': serializer.toJson<int>(farbe),
      'druckerId': serializer.toJson<int?>(druckerId),
      'druckzeitMinuten': serializer.toJson<int>(druckzeitMinuten),
      'stueckProDruck': serializer.toJson<int>(stueckProDruck),
      'spuelabfallGramm': serializer.toJson<double>(spuelabfallGramm),
      'arbeitMinuten': serializer.toJson<int>(arbeitMinuten),
      'aufschlagProzent': serializer.toJson<int?>(aufschlagProzent),
      'preisManuellCent': serializer.toJson<int?>(preisManuellCent),
      'sortierung': serializer.toJson<int>(sortierung),
      'archiviert': serializer.toJson<bool>(archiviert),
    };
  }

  Produkt copyWith({
    int? id,
    String? name,
    String? symbol,
    int? farbe,
    Value<int?> druckerId = const Value.absent(),
    int? druckzeitMinuten,
    int? stueckProDruck,
    double? spuelabfallGramm,
    int? arbeitMinuten,
    Value<int?> aufschlagProzent = const Value.absent(),
    Value<int?> preisManuellCent = const Value.absent(),
    int? sortierung,
    bool? archiviert,
  }) => Produkt(
    id: id ?? this.id,
    name: name ?? this.name,
    symbol: symbol ?? this.symbol,
    farbe: farbe ?? this.farbe,
    druckerId: druckerId.present ? druckerId.value : this.druckerId,
    druckzeitMinuten: druckzeitMinuten ?? this.druckzeitMinuten,
    stueckProDruck: stueckProDruck ?? this.stueckProDruck,
    spuelabfallGramm: spuelabfallGramm ?? this.spuelabfallGramm,
    arbeitMinuten: arbeitMinuten ?? this.arbeitMinuten,
    aufschlagProzent: aufschlagProzent.present
        ? aufschlagProzent.value
        : this.aufschlagProzent,
    preisManuellCent: preisManuellCent.present
        ? preisManuellCent.value
        : this.preisManuellCent,
    sortierung: sortierung ?? this.sortierung,
    archiviert: archiviert ?? this.archiviert,
  );
  Produkt copyWithCompanion(ProduktTabelleCompanion data) {
    return Produkt(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      farbe: data.farbe.present ? data.farbe.value : this.farbe,
      druckerId: data.druckerId.present ? data.druckerId.value : this.druckerId,
      druckzeitMinuten: data.druckzeitMinuten.present
          ? data.druckzeitMinuten.value
          : this.druckzeitMinuten,
      stueckProDruck: data.stueckProDruck.present
          ? data.stueckProDruck.value
          : this.stueckProDruck,
      spuelabfallGramm: data.spuelabfallGramm.present
          ? data.spuelabfallGramm.value
          : this.spuelabfallGramm,
      arbeitMinuten: data.arbeitMinuten.present
          ? data.arbeitMinuten.value
          : this.arbeitMinuten,
      aufschlagProzent: data.aufschlagProzent.present
          ? data.aufschlagProzent.value
          : this.aufschlagProzent,
      preisManuellCent: data.preisManuellCent.present
          ? data.preisManuellCent.value
          : this.preisManuellCent,
      sortierung: data.sortierung.present
          ? data.sortierung.value
          : this.sortierung,
      archiviert: data.archiviert.present
          ? data.archiviert.value
          : this.archiviert,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Produkt(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('symbol: $symbol, ')
          ..write('farbe: $farbe, ')
          ..write('druckerId: $druckerId, ')
          ..write('druckzeitMinuten: $druckzeitMinuten, ')
          ..write('stueckProDruck: $stueckProDruck, ')
          ..write('spuelabfallGramm: $spuelabfallGramm, ')
          ..write('arbeitMinuten: $arbeitMinuten, ')
          ..write('aufschlagProzent: $aufschlagProzent, ')
          ..write('preisManuellCent: $preisManuellCent, ')
          ..write('sortierung: $sortierung, ')
          ..write('archiviert: $archiviert')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    symbol,
    farbe,
    druckerId,
    druckzeitMinuten,
    stueckProDruck,
    spuelabfallGramm,
    arbeitMinuten,
    aufschlagProzent,
    preisManuellCent,
    sortierung,
    archiviert,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Produkt &&
          other.id == this.id &&
          other.name == this.name &&
          other.symbol == this.symbol &&
          other.farbe == this.farbe &&
          other.druckerId == this.druckerId &&
          other.druckzeitMinuten == this.druckzeitMinuten &&
          other.stueckProDruck == this.stueckProDruck &&
          other.spuelabfallGramm == this.spuelabfallGramm &&
          other.arbeitMinuten == this.arbeitMinuten &&
          other.aufschlagProzent == this.aufschlagProzent &&
          other.preisManuellCent == this.preisManuellCent &&
          other.sortierung == this.sortierung &&
          other.archiviert == this.archiviert);
}

class ProduktTabelleCompanion extends UpdateCompanion<Produkt> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> symbol;
  final Value<int> farbe;
  final Value<int?> druckerId;
  final Value<int> druckzeitMinuten;
  final Value<int> stueckProDruck;
  final Value<double> spuelabfallGramm;
  final Value<int> arbeitMinuten;
  final Value<int?> aufschlagProzent;
  final Value<int?> preisManuellCent;
  final Value<int> sortierung;
  final Value<bool> archiviert;
  const ProduktTabelleCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.symbol = const Value.absent(),
    this.farbe = const Value.absent(),
    this.druckerId = const Value.absent(),
    this.druckzeitMinuten = const Value.absent(),
    this.stueckProDruck = const Value.absent(),
    this.spuelabfallGramm = const Value.absent(),
    this.arbeitMinuten = const Value.absent(),
    this.aufschlagProzent = const Value.absent(),
    this.preisManuellCent = const Value.absent(),
    this.sortierung = const Value.absent(),
    this.archiviert = const Value.absent(),
  });
  ProduktTabelleCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.symbol = const Value.absent(),
    required int farbe,
    this.druckerId = const Value.absent(),
    required int druckzeitMinuten,
    this.stueckProDruck = const Value.absent(),
    this.spuelabfallGramm = const Value.absent(),
    this.arbeitMinuten = const Value.absent(),
    this.aufschlagProzent = const Value.absent(),
    this.preisManuellCent = const Value.absent(),
    this.sortierung = const Value.absent(),
    this.archiviert = const Value.absent(),
  }) : name = Value(name),
       farbe = Value(farbe),
       druckzeitMinuten = Value(druckzeitMinuten);
  static Insertable<Produkt> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? symbol,
    Expression<int>? farbe,
    Expression<int>? druckerId,
    Expression<int>? druckzeitMinuten,
    Expression<int>? stueckProDruck,
    Expression<double>? spuelabfallGramm,
    Expression<int>? arbeitMinuten,
    Expression<int>? aufschlagProzent,
    Expression<int>? preisManuellCent,
    Expression<int>? sortierung,
    Expression<bool>? archiviert,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (symbol != null) 'symbol': symbol,
      if (farbe != null) 'farbe': farbe,
      if (druckerId != null) 'drucker_id': druckerId,
      if (druckzeitMinuten != null) 'druckzeit_minuten': druckzeitMinuten,
      if (stueckProDruck != null) 'stueck_pro_druck': stueckProDruck,
      if (spuelabfallGramm != null) 'spuelabfall_gramm': spuelabfallGramm,
      if (arbeitMinuten != null) 'arbeit_minuten': arbeitMinuten,
      if (aufschlagProzent != null) 'aufschlag_prozent': aufschlagProzent,
      if (preisManuellCent != null) 'preis_manuell_cent': preisManuellCent,
      if (sortierung != null) 'sortierung': sortierung,
      if (archiviert != null) 'archiviert': archiviert,
    });
  }

  ProduktTabelleCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? symbol,
    Value<int>? farbe,
    Value<int?>? druckerId,
    Value<int>? druckzeitMinuten,
    Value<int>? stueckProDruck,
    Value<double>? spuelabfallGramm,
    Value<int>? arbeitMinuten,
    Value<int?>? aufschlagProzent,
    Value<int?>? preisManuellCent,
    Value<int>? sortierung,
    Value<bool>? archiviert,
  }) {
    return ProduktTabelleCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      farbe: farbe ?? this.farbe,
      druckerId: druckerId ?? this.druckerId,
      druckzeitMinuten: druckzeitMinuten ?? this.druckzeitMinuten,
      stueckProDruck: stueckProDruck ?? this.stueckProDruck,
      spuelabfallGramm: spuelabfallGramm ?? this.spuelabfallGramm,
      arbeitMinuten: arbeitMinuten ?? this.arbeitMinuten,
      aufschlagProzent: aufschlagProzent ?? this.aufschlagProzent,
      preisManuellCent: preisManuellCent ?? this.preisManuellCent,
      sortierung: sortierung ?? this.sortierung,
      archiviert: archiviert ?? this.archiviert,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (farbe.present) {
      map['farbe'] = Variable<int>(farbe.value);
    }
    if (druckerId.present) {
      map['drucker_id'] = Variable<int>(druckerId.value);
    }
    if (druckzeitMinuten.present) {
      map['druckzeit_minuten'] = Variable<int>(druckzeitMinuten.value);
    }
    if (stueckProDruck.present) {
      map['stueck_pro_druck'] = Variable<int>(stueckProDruck.value);
    }
    if (spuelabfallGramm.present) {
      map['spuelabfall_gramm'] = Variable<double>(spuelabfallGramm.value);
    }
    if (arbeitMinuten.present) {
      map['arbeit_minuten'] = Variable<int>(arbeitMinuten.value);
    }
    if (aufschlagProzent.present) {
      map['aufschlag_prozent'] = Variable<int>(aufschlagProzent.value);
    }
    if (preisManuellCent.present) {
      map['preis_manuell_cent'] = Variable<int>(preisManuellCent.value);
    }
    if (sortierung.present) {
      map['sortierung'] = Variable<int>(sortierung.value);
    }
    if (archiviert.present) {
      map['archiviert'] = Variable<bool>(archiviert.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProduktTabelleCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('symbol: $symbol, ')
          ..write('farbe: $farbe, ')
          ..write('druckerId: $druckerId, ')
          ..write('druckzeitMinuten: $druckzeitMinuten, ')
          ..write('stueckProDruck: $stueckProDruck, ')
          ..write('spuelabfallGramm: $spuelabfallGramm, ')
          ..write('arbeitMinuten: $arbeitMinuten, ')
          ..write('aufschlagProzent: $aufschlagProzent, ')
          ..write('preisManuellCent: $preisManuellCent, ')
          ..write('sortierung: $sortierung, ')
          ..write('archiviert: $archiviert')
          ..write(')'))
        .toString();
  }
}

class $ProduktFilamentTabelleTable extends ProduktFilamentTabelle
    with TableInfo<$ProduktFilamentTabelleTable, ProduktFilament> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProduktFilamentTabelleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _produktIdMeta = const VerificationMeta(
    'produktId',
  );
  @override
  late final GeneratedColumn<int> produktId = GeneratedColumn<int>(
    'produkt_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES produkte (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _filamentIdMeta = const VerificationMeta(
    'filamentId',
  );
  @override
  late final GeneratedColumn<int> filamentId = GeneratedColumn<int>(
    'filament_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES filamente (id)',
    ),
  );
  static const VerificationMeta _grammMeta = const VerificationMeta('gramm');
  @override
  late final GeneratedColumn<double> gramm = GeneratedColumn<double>(
    'gramm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, produktId, filamentId, gramm];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'produkt_filamente';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProduktFilament> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('produkt_id')) {
      context.handle(
        _produktIdMeta,
        produktId.isAcceptableOrUnknown(data['produkt_id']!, _produktIdMeta),
      );
    } else if (isInserting) {
      context.missing(_produktIdMeta);
    }
    if (data.containsKey('filament_id')) {
      context.handle(
        _filamentIdMeta,
        filamentId.isAcceptableOrUnknown(data['filament_id']!, _filamentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_filamentIdMeta);
    }
    if (data.containsKey('gramm')) {
      context.handle(
        _grammMeta,
        gramm.isAcceptableOrUnknown(data['gramm']!, _grammMeta),
      );
    } else if (isInserting) {
      context.missing(_grammMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProduktFilament map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProduktFilament(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      produktId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}produkt_id'],
      )!,
      filamentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}filament_id'],
      )!,
      gramm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gramm'],
      )!,
    );
  }

  @override
  $ProduktFilamentTabelleTable createAlias(String alias) {
    return $ProduktFilamentTabelleTable(attachedDatabase, alias);
  }
}

class ProduktFilament extends DataClass implements Insertable<ProduktFilament> {
  final int id;
  final int produktId;
  final int filamentId;

  /// Gramm pro Druck (so wie der Slicer es anzeigt).
  final double gramm;
  const ProduktFilament({
    required this.id,
    required this.produktId,
    required this.filamentId,
    required this.gramm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['produkt_id'] = Variable<int>(produktId);
    map['filament_id'] = Variable<int>(filamentId);
    map['gramm'] = Variable<double>(gramm);
    return map;
  }

  ProduktFilamentTabelleCompanion toCompanion(bool nullToAbsent) {
    return ProduktFilamentTabelleCompanion(
      id: Value(id),
      produktId: Value(produktId),
      filamentId: Value(filamentId),
      gramm: Value(gramm),
    );
  }

  factory ProduktFilament.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProduktFilament(
      id: serializer.fromJson<int>(json['id']),
      produktId: serializer.fromJson<int>(json['produktId']),
      filamentId: serializer.fromJson<int>(json['filamentId']),
      gramm: serializer.fromJson<double>(json['gramm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'produktId': serializer.toJson<int>(produktId),
      'filamentId': serializer.toJson<int>(filamentId),
      'gramm': serializer.toJson<double>(gramm),
    };
  }

  ProduktFilament copyWith({
    int? id,
    int? produktId,
    int? filamentId,
    double? gramm,
  }) => ProduktFilament(
    id: id ?? this.id,
    produktId: produktId ?? this.produktId,
    filamentId: filamentId ?? this.filamentId,
    gramm: gramm ?? this.gramm,
  );
  ProduktFilament copyWithCompanion(ProduktFilamentTabelleCompanion data) {
    return ProduktFilament(
      id: data.id.present ? data.id.value : this.id,
      produktId: data.produktId.present ? data.produktId.value : this.produktId,
      filamentId: data.filamentId.present
          ? data.filamentId.value
          : this.filamentId,
      gramm: data.gramm.present ? data.gramm.value : this.gramm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProduktFilament(')
          ..write('id: $id, ')
          ..write('produktId: $produktId, ')
          ..write('filamentId: $filamentId, ')
          ..write('gramm: $gramm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, produktId, filamentId, gramm);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProduktFilament &&
          other.id == this.id &&
          other.produktId == this.produktId &&
          other.filamentId == this.filamentId &&
          other.gramm == this.gramm);
}

class ProduktFilamentTabelleCompanion extends UpdateCompanion<ProduktFilament> {
  final Value<int> id;
  final Value<int> produktId;
  final Value<int> filamentId;
  final Value<double> gramm;
  const ProduktFilamentTabelleCompanion({
    this.id = const Value.absent(),
    this.produktId = const Value.absent(),
    this.filamentId = const Value.absent(),
    this.gramm = const Value.absent(),
  });
  ProduktFilamentTabelleCompanion.insert({
    this.id = const Value.absent(),
    required int produktId,
    required int filamentId,
    required double gramm,
  }) : produktId = Value(produktId),
       filamentId = Value(filamentId),
       gramm = Value(gramm);
  static Insertable<ProduktFilament> custom({
    Expression<int>? id,
    Expression<int>? produktId,
    Expression<int>? filamentId,
    Expression<double>? gramm,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (produktId != null) 'produkt_id': produktId,
      if (filamentId != null) 'filament_id': filamentId,
      if (gramm != null) 'gramm': gramm,
    });
  }

  ProduktFilamentTabelleCompanion copyWith({
    Value<int>? id,
    Value<int>? produktId,
    Value<int>? filamentId,
    Value<double>? gramm,
  }) {
    return ProduktFilamentTabelleCompanion(
      id: id ?? this.id,
      produktId: produktId ?? this.produktId,
      filamentId: filamentId ?? this.filamentId,
      gramm: gramm ?? this.gramm,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (produktId.present) {
      map['produkt_id'] = Variable<int>(produktId.value);
    }
    if (filamentId.present) {
      map['filament_id'] = Variable<int>(filamentId.value);
    }
    if (gramm.present) {
      map['gramm'] = Variable<double>(gramm.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProduktFilamentTabelleCompanion(')
          ..write('id: $id, ')
          ..write('produktId: $produktId, ')
          ..write('filamentId: $filamentId, ')
          ..write('gramm: $gramm')
          ..write(')'))
        .toString();
  }
}

class $ProduktExtraTabelleTable extends ProduktExtraTabelle
    with TableInfo<$ProduktExtraTabelleTable, ProduktExtra> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProduktExtraTabelleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _produktIdMeta = const VerificationMeta(
    'produktId',
  );
  @override
  late final GeneratedColumn<int> produktId = GeneratedColumn<int>(
    'produkt_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES produkte (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _extraIdMeta = const VerificationMeta(
    'extraId',
  );
  @override
  late final GeneratedColumn<int> extraId = GeneratedColumn<int>(
    'extra_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES extras (id)',
    ),
  );
  static const VerificationMeta _mengeMeta = const VerificationMeta('menge');
  @override
  late final GeneratedColumn<int> menge = GeneratedColumn<int>(
    'menge',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [id, produktId, extraId, menge];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'produkt_extras';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProduktExtra> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('produkt_id')) {
      context.handle(
        _produktIdMeta,
        produktId.isAcceptableOrUnknown(data['produkt_id']!, _produktIdMeta),
      );
    } else if (isInserting) {
      context.missing(_produktIdMeta);
    }
    if (data.containsKey('extra_id')) {
      context.handle(
        _extraIdMeta,
        extraId.isAcceptableOrUnknown(data['extra_id']!, _extraIdMeta),
      );
    } else if (isInserting) {
      context.missing(_extraIdMeta);
    }
    if (data.containsKey('menge')) {
      context.handle(
        _mengeMeta,
        menge.isAcceptableOrUnknown(data['menge']!, _mengeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProduktExtra map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProduktExtra(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      produktId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}produkt_id'],
      )!,
      extraId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}extra_id'],
      )!,
      menge: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}menge'],
      )!,
    );
  }

  @override
  $ProduktExtraTabelleTable createAlias(String alias) {
    return $ProduktExtraTabelleTable(attachedDatabase, alias);
  }
}

class ProduktExtra extends DataClass implements Insertable<ProduktExtra> {
  final int id;
  final int produktId;
  final int extraId;

  /// Menge pro Stück.
  final int menge;
  const ProduktExtra({
    required this.id,
    required this.produktId,
    required this.extraId,
    required this.menge,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['produkt_id'] = Variable<int>(produktId);
    map['extra_id'] = Variable<int>(extraId);
    map['menge'] = Variable<int>(menge);
    return map;
  }

  ProduktExtraTabelleCompanion toCompanion(bool nullToAbsent) {
    return ProduktExtraTabelleCompanion(
      id: Value(id),
      produktId: Value(produktId),
      extraId: Value(extraId),
      menge: Value(menge),
    );
  }

  factory ProduktExtra.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProduktExtra(
      id: serializer.fromJson<int>(json['id']),
      produktId: serializer.fromJson<int>(json['produktId']),
      extraId: serializer.fromJson<int>(json['extraId']),
      menge: serializer.fromJson<int>(json['menge']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'produktId': serializer.toJson<int>(produktId),
      'extraId': serializer.toJson<int>(extraId),
      'menge': serializer.toJson<int>(menge),
    };
  }

  ProduktExtra copyWith({int? id, int? produktId, int? extraId, int? menge}) =>
      ProduktExtra(
        id: id ?? this.id,
        produktId: produktId ?? this.produktId,
        extraId: extraId ?? this.extraId,
        menge: menge ?? this.menge,
      );
  ProduktExtra copyWithCompanion(ProduktExtraTabelleCompanion data) {
    return ProduktExtra(
      id: data.id.present ? data.id.value : this.id,
      produktId: data.produktId.present ? data.produktId.value : this.produktId,
      extraId: data.extraId.present ? data.extraId.value : this.extraId,
      menge: data.menge.present ? data.menge.value : this.menge,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProduktExtra(')
          ..write('id: $id, ')
          ..write('produktId: $produktId, ')
          ..write('extraId: $extraId, ')
          ..write('menge: $menge')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, produktId, extraId, menge);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProduktExtra &&
          other.id == this.id &&
          other.produktId == this.produktId &&
          other.extraId == this.extraId &&
          other.menge == this.menge);
}

class ProduktExtraTabelleCompanion extends UpdateCompanion<ProduktExtra> {
  final Value<int> id;
  final Value<int> produktId;
  final Value<int> extraId;
  final Value<int> menge;
  const ProduktExtraTabelleCompanion({
    this.id = const Value.absent(),
    this.produktId = const Value.absent(),
    this.extraId = const Value.absent(),
    this.menge = const Value.absent(),
  });
  ProduktExtraTabelleCompanion.insert({
    this.id = const Value.absent(),
    required int produktId,
    required int extraId,
    this.menge = const Value.absent(),
  }) : produktId = Value(produktId),
       extraId = Value(extraId);
  static Insertable<ProduktExtra> custom({
    Expression<int>? id,
    Expression<int>? produktId,
    Expression<int>? extraId,
    Expression<int>? menge,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (produktId != null) 'produkt_id': produktId,
      if (extraId != null) 'extra_id': extraId,
      if (menge != null) 'menge': menge,
    });
  }

  ProduktExtraTabelleCompanion copyWith({
    Value<int>? id,
    Value<int>? produktId,
    Value<int>? extraId,
    Value<int>? menge,
  }) {
    return ProduktExtraTabelleCompanion(
      id: id ?? this.id,
      produktId: produktId ?? this.produktId,
      extraId: extraId ?? this.extraId,
      menge: menge ?? this.menge,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (produktId.present) {
      map['produkt_id'] = Variable<int>(produktId.value);
    }
    if (extraId.present) {
      map['extra_id'] = Variable<int>(extraId.value);
    }
    if (menge.present) {
      map['menge'] = Variable<int>(menge.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProduktExtraTabelleCompanion(')
          ..write('id: $id, ')
          ..write('produktId: $produktId, ')
          ..write('extraId: $extraId, ')
          ..write('menge: $menge')
          ..write(')'))
        .toString();
  }
}

class $AuftragTabelleTable extends AuftragTabelle
    with TableInfo<$AuftragTabelleTable, Auftrag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuftragTabelleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _kundeMeta = const VerificationMeta('kunde');
  @override
  late final GeneratedColumn<String> kunde = GeneratedColumn<String>(
    'kunde',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kontaktMeta = const VerificationMeta(
    'kontakt',
  );
  @override
  late final GeneratedColumn<String> kontakt = GeneratedColumn<String>(
    'kontakt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _notizMeta = const VerificationMeta('notiz');
  @override
  late final GeneratedColumn<String> notiz = GeneratedColumn<String>(
    'notiz',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _erstelltAmMeta = const VerificationMeta(
    'erstelltAm',
  );
  @override
  late final GeneratedColumn<DateTime> erstelltAm = GeneratedColumn<DateTime>(
    'erstellt_am',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _faelligAmMeta = const VerificationMeta(
    'faelligAm',
  );
  @override
  late final GeneratedColumn<DateTime> faelligAm = GeneratedColumn<DateTime>(
    'faellig_am',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bezahltAmMeta = const VerificationMeta(
    'bezahltAm',
  );
  @override
  late final GeneratedColumn<DateTime> bezahltAm = GeneratedColumn<DateTime>(
    'bezahlt_am',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _zahlungsartMeta = const VerificationMeta(
    'zahlungsart',
  );
  @override
  late final GeneratedColumn<int> zahlungsart = GeneratedColumn<int>(
    'zahlungsart',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kunde,
    kontakt,
    notiz,
    erstelltAm,
    faelligAm,
    status,
    bezahltAm,
    zahlungsart,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'auftraege';
  @override
  VerificationContext validateIntegrity(
    Insertable<Auftrag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kunde')) {
      context.handle(
        _kundeMeta,
        kunde.isAcceptableOrUnknown(data['kunde']!, _kundeMeta),
      );
    } else if (isInserting) {
      context.missing(_kundeMeta);
    }
    if (data.containsKey('kontakt')) {
      context.handle(
        _kontaktMeta,
        kontakt.isAcceptableOrUnknown(data['kontakt']!, _kontaktMeta),
      );
    }
    if (data.containsKey('notiz')) {
      context.handle(
        _notizMeta,
        notiz.isAcceptableOrUnknown(data['notiz']!, _notizMeta),
      );
    }
    if (data.containsKey('erstellt_am')) {
      context.handle(
        _erstelltAmMeta,
        erstelltAm.isAcceptableOrUnknown(data['erstellt_am']!, _erstelltAmMeta),
      );
    } else if (isInserting) {
      context.missing(_erstelltAmMeta);
    }
    if (data.containsKey('faellig_am')) {
      context.handle(
        _faelligAmMeta,
        faelligAm.isAcceptableOrUnknown(data['faellig_am']!, _faelligAmMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('bezahlt_am')) {
      context.handle(
        _bezahltAmMeta,
        bezahltAm.isAcceptableOrUnknown(data['bezahlt_am']!, _bezahltAmMeta),
      );
    }
    if (data.containsKey('zahlungsart')) {
      context.handle(
        _zahlungsartMeta,
        zahlungsart.isAcceptableOrUnknown(
          data['zahlungsart']!,
          _zahlungsartMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Auftrag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Auftrag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      kunde: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kunde'],
      )!,
      kontakt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kontakt'],
      )!,
      notiz: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notiz'],
      )!,
      erstelltAm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}erstellt_am'],
      )!,
      faelligAm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}faellig_am'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      bezahltAm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}bezahlt_am'],
      ),
      zahlungsart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}zahlungsart'],
      )!,
    );
  }

  @override
  $AuftragTabelleTable createAlias(String alias) {
    return $AuftragTabelleTable(attachedDatabase, alias);
  }
}

class Auftrag extends DataClass implements Insertable<Auftrag> {
  final int id;
  final String kunde;
  final String kontakt;
  final String notiz;
  final DateTime erstelltAm;
  final DateTime? faelligAm;

  /// 0 = offen, 1 = gedruckt, 2 = abgeholt (siehe [AuftragStatus]).
  final int status;
  final DateTime? bezahltAm;
  final int zahlungsart;
  const Auftrag({
    required this.id,
    required this.kunde,
    required this.kontakt,
    required this.notiz,
    required this.erstelltAm,
    this.faelligAm,
    required this.status,
    this.bezahltAm,
    required this.zahlungsart,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['kunde'] = Variable<String>(kunde);
    map['kontakt'] = Variable<String>(kontakt);
    map['notiz'] = Variable<String>(notiz);
    map['erstellt_am'] = Variable<DateTime>(erstelltAm);
    if (!nullToAbsent || faelligAm != null) {
      map['faellig_am'] = Variable<DateTime>(faelligAm);
    }
    map['status'] = Variable<int>(status);
    if (!nullToAbsent || bezahltAm != null) {
      map['bezahlt_am'] = Variable<DateTime>(bezahltAm);
    }
    map['zahlungsart'] = Variable<int>(zahlungsart);
    return map;
  }

  AuftragTabelleCompanion toCompanion(bool nullToAbsent) {
    return AuftragTabelleCompanion(
      id: Value(id),
      kunde: Value(kunde),
      kontakt: Value(kontakt),
      notiz: Value(notiz),
      erstelltAm: Value(erstelltAm),
      faelligAm: faelligAm == null && nullToAbsent
          ? const Value.absent()
          : Value(faelligAm),
      status: Value(status),
      bezahltAm: bezahltAm == null && nullToAbsent
          ? const Value.absent()
          : Value(bezahltAm),
      zahlungsart: Value(zahlungsart),
    );
  }

  factory Auftrag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Auftrag(
      id: serializer.fromJson<int>(json['id']),
      kunde: serializer.fromJson<String>(json['kunde']),
      kontakt: serializer.fromJson<String>(json['kontakt']),
      notiz: serializer.fromJson<String>(json['notiz']),
      erstelltAm: serializer.fromJson<DateTime>(json['erstelltAm']),
      faelligAm: serializer.fromJson<DateTime?>(json['faelligAm']),
      status: serializer.fromJson<int>(json['status']),
      bezahltAm: serializer.fromJson<DateTime?>(json['bezahltAm']),
      zahlungsart: serializer.fromJson<int>(json['zahlungsart']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kunde': serializer.toJson<String>(kunde),
      'kontakt': serializer.toJson<String>(kontakt),
      'notiz': serializer.toJson<String>(notiz),
      'erstelltAm': serializer.toJson<DateTime>(erstelltAm),
      'faelligAm': serializer.toJson<DateTime?>(faelligAm),
      'status': serializer.toJson<int>(status),
      'bezahltAm': serializer.toJson<DateTime?>(bezahltAm),
      'zahlungsart': serializer.toJson<int>(zahlungsart),
    };
  }

  Auftrag copyWith({
    int? id,
    String? kunde,
    String? kontakt,
    String? notiz,
    DateTime? erstelltAm,
    Value<DateTime?> faelligAm = const Value.absent(),
    int? status,
    Value<DateTime?> bezahltAm = const Value.absent(),
    int? zahlungsart,
  }) => Auftrag(
    id: id ?? this.id,
    kunde: kunde ?? this.kunde,
    kontakt: kontakt ?? this.kontakt,
    notiz: notiz ?? this.notiz,
    erstelltAm: erstelltAm ?? this.erstelltAm,
    faelligAm: faelligAm.present ? faelligAm.value : this.faelligAm,
    status: status ?? this.status,
    bezahltAm: bezahltAm.present ? bezahltAm.value : this.bezahltAm,
    zahlungsart: zahlungsart ?? this.zahlungsart,
  );
  Auftrag copyWithCompanion(AuftragTabelleCompanion data) {
    return Auftrag(
      id: data.id.present ? data.id.value : this.id,
      kunde: data.kunde.present ? data.kunde.value : this.kunde,
      kontakt: data.kontakt.present ? data.kontakt.value : this.kontakt,
      notiz: data.notiz.present ? data.notiz.value : this.notiz,
      erstelltAm: data.erstelltAm.present
          ? data.erstelltAm.value
          : this.erstelltAm,
      faelligAm: data.faelligAm.present ? data.faelligAm.value : this.faelligAm,
      status: data.status.present ? data.status.value : this.status,
      bezahltAm: data.bezahltAm.present ? data.bezahltAm.value : this.bezahltAm,
      zahlungsart: data.zahlungsart.present
          ? data.zahlungsart.value
          : this.zahlungsart,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Auftrag(')
          ..write('id: $id, ')
          ..write('kunde: $kunde, ')
          ..write('kontakt: $kontakt, ')
          ..write('notiz: $notiz, ')
          ..write('erstelltAm: $erstelltAm, ')
          ..write('faelligAm: $faelligAm, ')
          ..write('status: $status, ')
          ..write('bezahltAm: $bezahltAm, ')
          ..write('zahlungsart: $zahlungsart')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kunde,
    kontakt,
    notiz,
    erstelltAm,
    faelligAm,
    status,
    bezahltAm,
    zahlungsart,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Auftrag &&
          other.id == this.id &&
          other.kunde == this.kunde &&
          other.kontakt == this.kontakt &&
          other.notiz == this.notiz &&
          other.erstelltAm == this.erstelltAm &&
          other.faelligAm == this.faelligAm &&
          other.status == this.status &&
          other.bezahltAm == this.bezahltAm &&
          other.zahlungsart == this.zahlungsart);
}

class AuftragTabelleCompanion extends UpdateCompanion<Auftrag> {
  final Value<int> id;
  final Value<String> kunde;
  final Value<String> kontakt;
  final Value<String> notiz;
  final Value<DateTime> erstelltAm;
  final Value<DateTime?> faelligAm;
  final Value<int> status;
  final Value<DateTime?> bezahltAm;
  final Value<int> zahlungsart;
  const AuftragTabelleCompanion({
    this.id = const Value.absent(),
    this.kunde = const Value.absent(),
    this.kontakt = const Value.absent(),
    this.notiz = const Value.absent(),
    this.erstelltAm = const Value.absent(),
    this.faelligAm = const Value.absent(),
    this.status = const Value.absent(),
    this.bezahltAm = const Value.absent(),
    this.zahlungsart = const Value.absent(),
  });
  AuftragTabelleCompanion.insert({
    this.id = const Value.absent(),
    required String kunde,
    this.kontakt = const Value.absent(),
    this.notiz = const Value.absent(),
    required DateTime erstelltAm,
    this.faelligAm = const Value.absent(),
    this.status = const Value.absent(),
    this.bezahltAm = const Value.absent(),
    this.zahlungsart = const Value.absent(),
  }) : kunde = Value(kunde),
       erstelltAm = Value(erstelltAm);
  static Insertable<Auftrag> custom({
    Expression<int>? id,
    Expression<String>? kunde,
    Expression<String>? kontakt,
    Expression<String>? notiz,
    Expression<DateTime>? erstelltAm,
    Expression<DateTime>? faelligAm,
    Expression<int>? status,
    Expression<DateTime>? bezahltAm,
    Expression<int>? zahlungsart,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kunde != null) 'kunde': kunde,
      if (kontakt != null) 'kontakt': kontakt,
      if (notiz != null) 'notiz': notiz,
      if (erstelltAm != null) 'erstellt_am': erstelltAm,
      if (faelligAm != null) 'faellig_am': faelligAm,
      if (status != null) 'status': status,
      if (bezahltAm != null) 'bezahlt_am': bezahltAm,
      if (zahlungsart != null) 'zahlungsart': zahlungsart,
    });
  }

  AuftragTabelleCompanion copyWith({
    Value<int>? id,
    Value<String>? kunde,
    Value<String>? kontakt,
    Value<String>? notiz,
    Value<DateTime>? erstelltAm,
    Value<DateTime?>? faelligAm,
    Value<int>? status,
    Value<DateTime?>? bezahltAm,
    Value<int>? zahlungsart,
  }) {
    return AuftragTabelleCompanion(
      id: id ?? this.id,
      kunde: kunde ?? this.kunde,
      kontakt: kontakt ?? this.kontakt,
      notiz: notiz ?? this.notiz,
      erstelltAm: erstelltAm ?? this.erstelltAm,
      faelligAm: faelligAm ?? this.faelligAm,
      status: status ?? this.status,
      bezahltAm: bezahltAm ?? this.bezahltAm,
      zahlungsart: zahlungsart ?? this.zahlungsart,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kunde.present) {
      map['kunde'] = Variable<String>(kunde.value);
    }
    if (kontakt.present) {
      map['kontakt'] = Variable<String>(kontakt.value);
    }
    if (notiz.present) {
      map['notiz'] = Variable<String>(notiz.value);
    }
    if (erstelltAm.present) {
      map['erstellt_am'] = Variable<DateTime>(erstelltAm.value);
    }
    if (faelligAm.present) {
      map['faellig_am'] = Variable<DateTime>(faelligAm.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (bezahltAm.present) {
      map['bezahlt_am'] = Variable<DateTime>(bezahltAm.value);
    }
    if (zahlungsart.present) {
      map['zahlungsart'] = Variable<int>(zahlungsart.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuftragTabelleCompanion(')
          ..write('id: $id, ')
          ..write('kunde: $kunde, ')
          ..write('kontakt: $kontakt, ')
          ..write('notiz: $notiz, ')
          ..write('erstelltAm: $erstelltAm, ')
          ..write('faelligAm: $faelligAm, ')
          ..write('status: $status, ')
          ..write('bezahltAm: $bezahltAm, ')
          ..write('zahlungsart: $zahlungsart')
          ..write(')'))
        .toString();
  }
}

class $VerkaufTabelleTable extends VerkaufTabelle
    with TableInfo<$VerkaufTabelleTable, Verkauf> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VerkaufTabelleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _zeitpunktMeta = const VerificationMeta(
    'zeitpunkt',
  );
  @override
  late final GeneratedColumn<DateTime> zeitpunkt = GeneratedColumn<DateTime>(
    'zeitpunkt',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _produktIdMeta = const VerificationMeta(
    'produktId',
  );
  @override
  late final GeneratedColumn<int> produktId = GeneratedColumn<int>(
    'produkt_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES produkte (id)',
    ),
  );
  static const VerificationMeta _produktNameMeta = const VerificationMeta(
    'produktName',
  );
  @override
  late final GeneratedColumn<String> produktName = GeneratedColumn<String>(
    'produkt_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mengeMeta = const VerificationMeta('menge');
  @override
  late final GeneratedColumn<int> menge = GeneratedColumn<int>(
    'menge',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _einzelpreisCentMeta = const VerificationMeta(
    'einzelpreisCent',
  );
  @override
  late final GeneratedColumn<int> einzelpreisCent = GeneratedColumn<int>(
    'einzelpreis_cent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _einzelkostenCentMeta = const VerificationMeta(
    'einzelkostenCent',
  );
  @override
  late final GeneratedColumn<int> einzelkostenCent = GeneratedColumn<int>(
    'einzelkosten_cent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gebuehrCentMeta = const VerificationMeta(
    'gebuehrCent',
  );
  @override
  late final GeneratedColumn<int> gebuehrCent = GeneratedColumn<int>(
    'gebuehr_cent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _zahlungsartMeta = const VerificationMeta(
    'zahlungsart',
  );
  @override
  late final GeneratedColumn<int> zahlungsart = GeneratedColumn<int>(
    'zahlungsart',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _auftragIdMeta = const VerificationMeta(
    'auftragId',
  );
  @override
  late final GeneratedColumn<int> auftragId = GeneratedColumn<int>(
    'auftrag_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES auftraege (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    zeitpunkt,
    produktId,
    produktName,
    menge,
    einzelpreisCent,
    einzelkostenCent,
    gebuehrCent,
    zahlungsart,
    auftragId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'verkaeufe';
  @override
  VerificationContext validateIntegrity(
    Insertable<Verkauf> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('zeitpunkt')) {
      context.handle(
        _zeitpunktMeta,
        zeitpunkt.isAcceptableOrUnknown(data['zeitpunkt']!, _zeitpunktMeta),
      );
    } else if (isInserting) {
      context.missing(_zeitpunktMeta);
    }
    if (data.containsKey('produkt_id')) {
      context.handle(
        _produktIdMeta,
        produktId.isAcceptableOrUnknown(data['produkt_id']!, _produktIdMeta),
      );
    }
    if (data.containsKey('produkt_name')) {
      context.handle(
        _produktNameMeta,
        produktName.isAcceptableOrUnknown(
          data['produkt_name']!,
          _produktNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_produktNameMeta);
    }
    if (data.containsKey('menge')) {
      context.handle(
        _mengeMeta,
        menge.isAcceptableOrUnknown(data['menge']!, _mengeMeta),
      );
    } else if (isInserting) {
      context.missing(_mengeMeta);
    }
    if (data.containsKey('einzelpreis_cent')) {
      context.handle(
        _einzelpreisCentMeta,
        einzelpreisCent.isAcceptableOrUnknown(
          data['einzelpreis_cent']!,
          _einzelpreisCentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_einzelpreisCentMeta);
    }
    if (data.containsKey('einzelkosten_cent')) {
      context.handle(
        _einzelkostenCentMeta,
        einzelkostenCent.isAcceptableOrUnknown(
          data['einzelkosten_cent']!,
          _einzelkostenCentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_einzelkostenCentMeta);
    }
    if (data.containsKey('gebuehr_cent')) {
      context.handle(
        _gebuehrCentMeta,
        gebuehrCent.isAcceptableOrUnknown(
          data['gebuehr_cent']!,
          _gebuehrCentMeta,
        ),
      );
    }
    if (data.containsKey('zahlungsart')) {
      context.handle(
        _zahlungsartMeta,
        zahlungsart.isAcceptableOrUnknown(
          data['zahlungsart']!,
          _zahlungsartMeta,
        ),
      );
    }
    if (data.containsKey('auftrag_id')) {
      context.handle(
        _auftragIdMeta,
        auftragId.isAcceptableOrUnknown(data['auftrag_id']!, _auftragIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Verkauf map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Verkauf(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      zeitpunkt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}zeitpunkt'],
      )!,
      produktId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}produkt_id'],
      ),
      produktName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}produkt_name'],
      )!,
      menge: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}menge'],
      )!,
      einzelpreisCent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}einzelpreis_cent'],
      )!,
      einzelkostenCent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}einzelkosten_cent'],
      )!,
      gebuehrCent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gebuehr_cent'],
      )!,
      zahlungsart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}zahlungsart'],
      )!,
      auftragId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}auftrag_id'],
      ),
    );
  }

  @override
  $VerkaufTabelleTable createAlias(String alias) {
    return $VerkaufTabelleTable(attachedDatabase, alias);
  }
}

class Verkauf extends DataClass implements Insertable<Verkauf> {
  final int id;
  final DateTime zeitpunkt;
  final int? produktId;

  /// Name zum Zeitpunkt des Verkaufs (für Export und falls das Produkt
  /// später umbenannt wird).
  final String produktName;
  final int menge;
  final int einzelpreisCent;
  final int einzelkostenCent;

  /// Zahlungsgebühr für den ganzen Verkauf (z. B. SumUp).
  final int gebuehrCent;

  /// 0 = bar, 1 = Karte, 2 = online (siehe [Zahlungsart]).
  final int zahlungsart;
  final int? auftragId;
  const Verkauf({
    required this.id,
    required this.zeitpunkt,
    this.produktId,
    required this.produktName,
    required this.menge,
    required this.einzelpreisCent,
    required this.einzelkostenCent,
    required this.gebuehrCent,
    required this.zahlungsart,
    this.auftragId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['zeitpunkt'] = Variable<DateTime>(zeitpunkt);
    if (!nullToAbsent || produktId != null) {
      map['produkt_id'] = Variable<int>(produktId);
    }
    map['produkt_name'] = Variable<String>(produktName);
    map['menge'] = Variable<int>(menge);
    map['einzelpreis_cent'] = Variable<int>(einzelpreisCent);
    map['einzelkosten_cent'] = Variable<int>(einzelkostenCent);
    map['gebuehr_cent'] = Variable<int>(gebuehrCent);
    map['zahlungsart'] = Variable<int>(zahlungsart);
    if (!nullToAbsent || auftragId != null) {
      map['auftrag_id'] = Variable<int>(auftragId);
    }
    return map;
  }

  VerkaufTabelleCompanion toCompanion(bool nullToAbsent) {
    return VerkaufTabelleCompanion(
      id: Value(id),
      zeitpunkt: Value(zeitpunkt),
      produktId: produktId == null && nullToAbsent
          ? const Value.absent()
          : Value(produktId),
      produktName: Value(produktName),
      menge: Value(menge),
      einzelpreisCent: Value(einzelpreisCent),
      einzelkostenCent: Value(einzelkostenCent),
      gebuehrCent: Value(gebuehrCent),
      zahlungsart: Value(zahlungsart),
      auftragId: auftragId == null && nullToAbsent
          ? const Value.absent()
          : Value(auftragId),
    );
  }

  factory Verkauf.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Verkauf(
      id: serializer.fromJson<int>(json['id']),
      zeitpunkt: serializer.fromJson<DateTime>(json['zeitpunkt']),
      produktId: serializer.fromJson<int?>(json['produktId']),
      produktName: serializer.fromJson<String>(json['produktName']),
      menge: serializer.fromJson<int>(json['menge']),
      einzelpreisCent: serializer.fromJson<int>(json['einzelpreisCent']),
      einzelkostenCent: serializer.fromJson<int>(json['einzelkostenCent']),
      gebuehrCent: serializer.fromJson<int>(json['gebuehrCent']),
      zahlungsart: serializer.fromJson<int>(json['zahlungsart']),
      auftragId: serializer.fromJson<int?>(json['auftragId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'zeitpunkt': serializer.toJson<DateTime>(zeitpunkt),
      'produktId': serializer.toJson<int?>(produktId),
      'produktName': serializer.toJson<String>(produktName),
      'menge': serializer.toJson<int>(menge),
      'einzelpreisCent': serializer.toJson<int>(einzelpreisCent),
      'einzelkostenCent': serializer.toJson<int>(einzelkostenCent),
      'gebuehrCent': serializer.toJson<int>(gebuehrCent),
      'zahlungsart': serializer.toJson<int>(zahlungsart),
      'auftragId': serializer.toJson<int?>(auftragId),
    };
  }

  Verkauf copyWith({
    int? id,
    DateTime? zeitpunkt,
    Value<int?> produktId = const Value.absent(),
    String? produktName,
    int? menge,
    int? einzelpreisCent,
    int? einzelkostenCent,
    int? gebuehrCent,
    int? zahlungsart,
    Value<int?> auftragId = const Value.absent(),
  }) => Verkauf(
    id: id ?? this.id,
    zeitpunkt: zeitpunkt ?? this.zeitpunkt,
    produktId: produktId.present ? produktId.value : this.produktId,
    produktName: produktName ?? this.produktName,
    menge: menge ?? this.menge,
    einzelpreisCent: einzelpreisCent ?? this.einzelpreisCent,
    einzelkostenCent: einzelkostenCent ?? this.einzelkostenCent,
    gebuehrCent: gebuehrCent ?? this.gebuehrCent,
    zahlungsart: zahlungsart ?? this.zahlungsart,
    auftragId: auftragId.present ? auftragId.value : this.auftragId,
  );
  Verkauf copyWithCompanion(VerkaufTabelleCompanion data) {
    return Verkauf(
      id: data.id.present ? data.id.value : this.id,
      zeitpunkt: data.zeitpunkt.present ? data.zeitpunkt.value : this.zeitpunkt,
      produktId: data.produktId.present ? data.produktId.value : this.produktId,
      produktName: data.produktName.present
          ? data.produktName.value
          : this.produktName,
      menge: data.menge.present ? data.menge.value : this.menge,
      einzelpreisCent: data.einzelpreisCent.present
          ? data.einzelpreisCent.value
          : this.einzelpreisCent,
      einzelkostenCent: data.einzelkostenCent.present
          ? data.einzelkostenCent.value
          : this.einzelkostenCent,
      gebuehrCent: data.gebuehrCent.present
          ? data.gebuehrCent.value
          : this.gebuehrCent,
      zahlungsart: data.zahlungsart.present
          ? data.zahlungsart.value
          : this.zahlungsart,
      auftragId: data.auftragId.present ? data.auftragId.value : this.auftragId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Verkauf(')
          ..write('id: $id, ')
          ..write('zeitpunkt: $zeitpunkt, ')
          ..write('produktId: $produktId, ')
          ..write('produktName: $produktName, ')
          ..write('menge: $menge, ')
          ..write('einzelpreisCent: $einzelpreisCent, ')
          ..write('einzelkostenCent: $einzelkostenCent, ')
          ..write('gebuehrCent: $gebuehrCent, ')
          ..write('zahlungsart: $zahlungsart, ')
          ..write('auftragId: $auftragId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    zeitpunkt,
    produktId,
    produktName,
    menge,
    einzelpreisCent,
    einzelkostenCent,
    gebuehrCent,
    zahlungsart,
    auftragId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Verkauf &&
          other.id == this.id &&
          other.zeitpunkt == this.zeitpunkt &&
          other.produktId == this.produktId &&
          other.produktName == this.produktName &&
          other.menge == this.menge &&
          other.einzelpreisCent == this.einzelpreisCent &&
          other.einzelkostenCent == this.einzelkostenCent &&
          other.gebuehrCent == this.gebuehrCent &&
          other.zahlungsart == this.zahlungsart &&
          other.auftragId == this.auftragId);
}

class VerkaufTabelleCompanion extends UpdateCompanion<Verkauf> {
  final Value<int> id;
  final Value<DateTime> zeitpunkt;
  final Value<int?> produktId;
  final Value<String> produktName;
  final Value<int> menge;
  final Value<int> einzelpreisCent;
  final Value<int> einzelkostenCent;
  final Value<int> gebuehrCent;
  final Value<int> zahlungsart;
  final Value<int?> auftragId;
  const VerkaufTabelleCompanion({
    this.id = const Value.absent(),
    this.zeitpunkt = const Value.absent(),
    this.produktId = const Value.absent(),
    this.produktName = const Value.absent(),
    this.menge = const Value.absent(),
    this.einzelpreisCent = const Value.absent(),
    this.einzelkostenCent = const Value.absent(),
    this.gebuehrCent = const Value.absent(),
    this.zahlungsart = const Value.absent(),
    this.auftragId = const Value.absent(),
  });
  VerkaufTabelleCompanion.insert({
    this.id = const Value.absent(),
    required DateTime zeitpunkt,
    this.produktId = const Value.absent(),
    required String produktName,
    required int menge,
    required int einzelpreisCent,
    required int einzelkostenCent,
    this.gebuehrCent = const Value.absent(),
    this.zahlungsart = const Value.absent(),
    this.auftragId = const Value.absent(),
  }) : zeitpunkt = Value(zeitpunkt),
       produktName = Value(produktName),
       menge = Value(menge),
       einzelpreisCent = Value(einzelpreisCent),
       einzelkostenCent = Value(einzelkostenCent);
  static Insertable<Verkauf> custom({
    Expression<int>? id,
    Expression<DateTime>? zeitpunkt,
    Expression<int>? produktId,
    Expression<String>? produktName,
    Expression<int>? menge,
    Expression<int>? einzelpreisCent,
    Expression<int>? einzelkostenCent,
    Expression<int>? gebuehrCent,
    Expression<int>? zahlungsart,
    Expression<int>? auftragId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (zeitpunkt != null) 'zeitpunkt': zeitpunkt,
      if (produktId != null) 'produkt_id': produktId,
      if (produktName != null) 'produkt_name': produktName,
      if (menge != null) 'menge': menge,
      if (einzelpreisCent != null) 'einzelpreis_cent': einzelpreisCent,
      if (einzelkostenCent != null) 'einzelkosten_cent': einzelkostenCent,
      if (gebuehrCent != null) 'gebuehr_cent': gebuehrCent,
      if (zahlungsart != null) 'zahlungsart': zahlungsart,
      if (auftragId != null) 'auftrag_id': auftragId,
    });
  }

  VerkaufTabelleCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? zeitpunkt,
    Value<int?>? produktId,
    Value<String>? produktName,
    Value<int>? menge,
    Value<int>? einzelpreisCent,
    Value<int>? einzelkostenCent,
    Value<int>? gebuehrCent,
    Value<int>? zahlungsart,
    Value<int?>? auftragId,
  }) {
    return VerkaufTabelleCompanion(
      id: id ?? this.id,
      zeitpunkt: zeitpunkt ?? this.zeitpunkt,
      produktId: produktId ?? this.produktId,
      produktName: produktName ?? this.produktName,
      menge: menge ?? this.menge,
      einzelpreisCent: einzelpreisCent ?? this.einzelpreisCent,
      einzelkostenCent: einzelkostenCent ?? this.einzelkostenCent,
      gebuehrCent: gebuehrCent ?? this.gebuehrCent,
      zahlungsart: zahlungsart ?? this.zahlungsart,
      auftragId: auftragId ?? this.auftragId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (zeitpunkt.present) {
      map['zeitpunkt'] = Variable<DateTime>(zeitpunkt.value);
    }
    if (produktId.present) {
      map['produkt_id'] = Variable<int>(produktId.value);
    }
    if (produktName.present) {
      map['produkt_name'] = Variable<String>(produktName.value);
    }
    if (menge.present) {
      map['menge'] = Variable<int>(menge.value);
    }
    if (einzelpreisCent.present) {
      map['einzelpreis_cent'] = Variable<int>(einzelpreisCent.value);
    }
    if (einzelkostenCent.present) {
      map['einzelkosten_cent'] = Variable<int>(einzelkostenCent.value);
    }
    if (gebuehrCent.present) {
      map['gebuehr_cent'] = Variable<int>(gebuehrCent.value);
    }
    if (zahlungsart.present) {
      map['zahlungsart'] = Variable<int>(zahlungsart.value);
    }
    if (auftragId.present) {
      map['auftrag_id'] = Variable<int>(auftragId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VerkaufTabelleCompanion(')
          ..write('id: $id, ')
          ..write('zeitpunkt: $zeitpunkt, ')
          ..write('produktId: $produktId, ')
          ..write('produktName: $produktName, ')
          ..write('menge: $menge, ')
          ..write('einzelpreisCent: $einzelpreisCent, ')
          ..write('einzelkostenCent: $einzelkostenCent, ')
          ..write('gebuehrCent: $gebuehrCent, ')
          ..write('zahlungsart: $zahlungsart, ')
          ..write('auftragId: $auftragId')
          ..write(')'))
        .toString();
  }
}

class $AuftragPositionTabelleTable extends AuftragPositionTabelle
    with TableInfo<$AuftragPositionTabelleTable, AuftragPosition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuftragPositionTabelleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _auftragIdMeta = const VerificationMeta(
    'auftragId',
  );
  @override
  late final GeneratedColumn<int> auftragId = GeneratedColumn<int>(
    'auftrag_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES auftraege (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _produktIdMeta = const VerificationMeta(
    'produktId',
  );
  @override
  late final GeneratedColumn<int> produktId = GeneratedColumn<int>(
    'produkt_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES produkte (id)',
    ),
  );
  static const VerificationMeta _mengeMeta = const VerificationMeta('menge');
  @override
  late final GeneratedColumn<int> menge = GeneratedColumn<int>(
    'menge',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _einzelpreisCentMeta = const VerificationMeta(
    'einzelpreisCent',
  );
  @override
  late final GeneratedColumn<int> einzelpreisCent = GeneratedColumn<int>(
    'einzelpreis_cent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notizMeta = const VerificationMeta('notiz');
  @override
  late final GeneratedColumn<String> notiz = GeneratedColumn<String>(
    'notiz',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    auftragId,
    produktId,
    menge,
    einzelpreisCent,
    notiz,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'auftrag_positionen';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuftragPosition> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('auftrag_id')) {
      context.handle(
        _auftragIdMeta,
        auftragId.isAcceptableOrUnknown(data['auftrag_id']!, _auftragIdMeta),
      );
    } else if (isInserting) {
      context.missing(_auftragIdMeta);
    }
    if (data.containsKey('produkt_id')) {
      context.handle(
        _produktIdMeta,
        produktId.isAcceptableOrUnknown(data['produkt_id']!, _produktIdMeta),
      );
    } else if (isInserting) {
      context.missing(_produktIdMeta);
    }
    if (data.containsKey('menge')) {
      context.handle(
        _mengeMeta,
        menge.isAcceptableOrUnknown(data['menge']!, _mengeMeta),
      );
    } else if (isInserting) {
      context.missing(_mengeMeta);
    }
    if (data.containsKey('einzelpreis_cent')) {
      context.handle(
        _einzelpreisCentMeta,
        einzelpreisCent.isAcceptableOrUnknown(
          data['einzelpreis_cent']!,
          _einzelpreisCentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_einzelpreisCentMeta);
    }
    if (data.containsKey('notiz')) {
      context.handle(
        _notizMeta,
        notiz.isAcceptableOrUnknown(data['notiz']!, _notizMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuftragPosition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuftragPosition(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      auftragId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}auftrag_id'],
      )!,
      produktId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}produkt_id'],
      )!,
      menge: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}menge'],
      )!,
      einzelpreisCent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}einzelpreis_cent'],
      )!,
      notiz: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notiz'],
      )!,
    );
  }

  @override
  $AuftragPositionTabelleTable createAlias(String alias) {
    return $AuftragPositionTabelleTable(attachedDatabase, alias);
  }
}

class AuftragPosition extends DataClass implements Insertable<AuftragPosition> {
  final int id;
  final int auftragId;
  final int produktId;
  final int menge;
  final int einzelpreisCent;

  /// z. B. Wunschfarbe.
  final String notiz;
  const AuftragPosition({
    required this.id,
    required this.auftragId,
    required this.produktId,
    required this.menge,
    required this.einzelpreisCent,
    required this.notiz,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['auftrag_id'] = Variable<int>(auftragId);
    map['produkt_id'] = Variable<int>(produktId);
    map['menge'] = Variable<int>(menge);
    map['einzelpreis_cent'] = Variable<int>(einzelpreisCent);
    map['notiz'] = Variable<String>(notiz);
    return map;
  }

  AuftragPositionTabelleCompanion toCompanion(bool nullToAbsent) {
    return AuftragPositionTabelleCompanion(
      id: Value(id),
      auftragId: Value(auftragId),
      produktId: Value(produktId),
      menge: Value(menge),
      einzelpreisCent: Value(einzelpreisCent),
      notiz: Value(notiz),
    );
  }

  factory AuftragPosition.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuftragPosition(
      id: serializer.fromJson<int>(json['id']),
      auftragId: serializer.fromJson<int>(json['auftragId']),
      produktId: serializer.fromJson<int>(json['produktId']),
      menge: serializer.fromJson<int>(json['menge']),
      einzelpreisCent: serializer.fromJson<int>(json['einzelpreisCent']),
      notiz: serializer.fromJson<String>(json['notiz']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'auftragId': serializer.toJson<int>(auftragId),
      'produktId': serializer.toJson<int>(produktId),
      'menge': serializer.toJson<int>(menge),
      'einzelpreisCent': serializer.toJson<int>(einzelpreisCent),
      'notiz': serializer.toJson<String>(notiz),
    };
  }

  AuftragPosition copyWith({
    int? id,
    int? auftragId,
    int? produktId,
    int? menge,
    int? einzelpreisCent,
    String? notiz,
  }) => AuftragPosition(
    id: id ?? this.id,
    auftragId: auftragId ?? this.auftragId,
    produktId: produktId ?? this.produktId,
    menge: menge ?? this.menge,
    einzelpreisCent: einzelpreisCent ?? this.einzelpreisCent,
    notiz: notiz ?? this.notiz,
  );
  AuftragPosition copyWithCompanion(AuftragPositionTabelleCompanion data) {
    return AuftragPosition(
      id: data.id.present ? data.id.value : this.id,
      auftragId: data.auftragId.present ? data.auftragId.value : this.auftragId,
      produktId: data.produktId.present ? data.produktId.value : this.produktId,
      menge: data.menge.present ? data.menge.value : this.menge,
      einzelpreisCent: data.einzelpreisCent.present
          ? data.einzelpreisCent.value
          : this.einzelpreisCent,
      notiz: data.notiz.present ? data.notiz.value : this.notiz,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuftragPosition(')
          ..write('id: $id, ')
          ..write('auftragId: $auftragId, ')
          ..write('produktId: $produktId, ')
          ..write('menge: $menge, ')
          ..write('einzelpreisCent: $einzelpreisCent, ')
          ..write('notiz: $notiz')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, auftragId, produktId, menge, einzelpreisCent, notiz);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuftragPosition &&
          other.id == this.id &&
          other.auftragId == this.auftragId &&
          other.produktId == this.produktId &&
          other.menge == this.menge &&
          other.einzelpreisCent == this.einzelpreisCent &&
          other.notiz == this.notiz);
}

class AuftragPositionTabelleCompanion extends UpdateCompanion<AuftragPosition> {
  final Value<int> id;
  final Value<int> auftragId;
  final Value<int> produktId;
  final Value<int> menge;
  final Value<int> einzelpreisCent;
  final Value<String> notiz;
  const AuftragPositionTabelleCompanion({
    this.id = const Value.absent(),
    this.auftragId = const Value.absent(),
    this.produktId = const Value.absent(),
    this.menge = const Value.absent(),
    this.einzelpreisCent = const Value.absent(),
    this.notiz = const Value.absent(),
  });
  AuftragPositionTabelleCompanion.insert({
    this.id = const Value.absent(),
    required int auftragId,
    required int produktId,
    required int menge,
    required int einzelpreisCent,
    this.notiz = const Value.absent(),
  }) : auftragId = Value(auftragId),
       produktId = Value(produktId),
       menge = Value(menge),
       einzelpreisCent = Value(einzelpreisCent);
  static Insertable<AuftragPosition> custom({
    Expression<int>? id,
    Expression<int>? auftragId,
    Expression<int>? produktId,
    Expression<int>? menge,
    Expression<int>? einzelpreisCent,
    Expression<String>? notiz,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (auftragId != null) 'auftrag_id': auftragId,
      if (produktId != null) 'produkt_id': produktId,
      if (menge != null) 'menge': menge,
      if (einzelpreisCent != null) 'einzelpreis_cent': einzelpreisCent,
      if (notiz != null) 'notiz': notiz,
    });
  }

  AuftragPositionTabelleCompanion copyWith({
    Value<int>? id,
    Value<int>? auftragId,
    Value<int>? produktId,
    Value<int>? menge,
    Value<int>? einzelpreisCent,
    Value<String>? notiz,
  }) {
    return AuftragPositionTabelleCompanion(
      id: id ?? this.id,
      auftragId: auftragId ?? this.auftragId,
      produktId: produktId ?? this.produktId,
      menge: menge ?? this.menge,
      einzelpreisCent: einzelpreisCent ?? this.einzelpreisCent,
      notiz: notiz ?? this.notiz,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (auftragId.present) {
      map['auftrag_id'] = Variable<int>(auftragId.value);
    }
    if (produktId.present) {
      map['produkt_id'] = Variable<int>(produktId.value);
    }
    if (menge.present) {
      map['menge'] = Variable<int>(menge.value);
    }
    if (einzelpreisCent.present) {
      map['einzelpreis_cent'] = Variable<int>(einzelpreisCent.value);
    }
    if (notiz.present) {
      map['notiz'] = Variable<String>(notiz.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuftragPositionTabelleCompanion(')
          ..write('id: $id, ')
          ..write('auftragId: $auftragId, ')
          ..write('produktId: $produktId, ')
          ..write('menge: $menge, ')
          ..write('einzelpreisCent: $einzelpreisCent, ')
          ..write('notiz: $notiz')
          ..write(')'))
        .toString();
  }
}

class $SparzielTabelleTable extends SparzielTabelle
    with TableInfo<$SparzielTabelleTable, Sparziel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SparzielTabelleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
    'symbol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('🎯'),
  );
  static const VerificationMeta _zielCentMeta = const VerificationMeta(
    'zielCent',
  );
  @override
  late final GeneratedColumn<int> zielCent = GeneratedColumn<int>(
    'ziel_cent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _basisMeta = const VerificationMeta('basis');
  @override
  late final GeneratedColumn<int> basis = GeneratedColumn<int>(
    'basis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _startDatumMeta = const VerificationMeta(
    'startDatum',
  );
  @override
  late final GeneratedColumn<DateTime> startDatum = GeneratedColumn<DateTime>(
    'start_datum',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _angeheftetMeta = const VerificationMeta(
    'angeheftet',
  );
  @override
  late final GeneratedColumn<bool> angeheftet = GeneratedColumn<bool>(
    'angeheftet',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("angeheftet" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _erreichtAmMeta = const VerificationMeta(
    'erreichtAm',
  );
  @override
  late final GeneratedColumn<DateTime> erreichtAm = GeneratedColumn<DateTime>(
    'erreicht_am',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    symbol,
    zielCent,
    basis,
    startDatum,
    angeheftet,
    erreichtAm,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sparziele';
  @override
  VerificationContext validateIntegrity(
    Insertable<Sparziel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('symbol')) {
      context.handle(
        _symbolMeta,
        symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta),
      );
    }
    if (data.containsKey('ziel_cent')) {
      context.handle(
        _zielCentMeta,
        zielCent.isAcceptableOrUnknown(data['ziel_cent']!, _zielCentMeta),
      );
    } else if (isInserting) {
      context.missing(_zielCentMeta);
    }
    if (data.containsKey('basis')) {
      context.handle(
        _basisMeta,
        basis.isAcceptableOrUnknown(data['basis']!, _basisMeta),
      );
    }
    if (data.containsKey('start_datum')) {
      context.handle(
        _startDatumMeta,
        startDatum.isAcceptableOrUnknown(data['start_datum']!, _startDatumMeta),
      );
    } else if (isInserting) {
      context.missing(_startDatumMeta);
    }
    if (data.containsKey('angeheftet')) {
      context.handle(
        _angeheftetMeta,
        angeheftet.isAcceptableOrUnknown(data['angeheftet']!, _angeheftetMeta),
      );
    }
    if (data.containsKey('erreicht_am')) {
      context.handle(
        _erreichtAmMeta,
        erreichtAm.isAcceptableOrUnknown(data['erreicht_am']!, _erreichtAmMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Sparziel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sparziel(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      symbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symbol'],
      )!,
      zielCent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ziel_cent'],
      )!,
      basis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}basis'],
      )!,
      startDatum: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_datum'],
      )!,
      angeheftet: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}angeheftet'],
      )!,
      erreichtAm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}erreicht_am'],
      ),
    );
  }

  @override
  $SparzielTabelleTable createAlias(String alias) {
    return $SparzielTabelleTable(attachedDatabase, alias);
  }
}

class Sparziel extends DataClass implements Insertable<Sparziel> {
  final int id;
  final String name;
  final String symbol;
  final int zielCent;

  /// 0 = Gewinn zählt, 1 = Umsatz zählt (siehe [SparBasis]).
  final int basis;
  final DateTime startDatum;

  /// Wird auf dem Verkaufen-Bildschirm angezeigt.
  final bool angeheftet;
  final DateTime? erreichtAm;
  const Sparziel({
    required this.id,
    required this.name,
    required this.symbol,
    required this.zielCent,
    required this.basis,
    required this.startDatum,
    required this.angeheftet,
    this.erreichtAm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['symbol'] = Variable<String>(symbol);
    map['ziel_cent'] = Variable<int>(zielCent);
    map['basis'] = Variable<int>(basis);
    map['start_datum'] = Variable<DateTime>(startDatum);
    map['angeheftet'] = Variable<bool>(angeheftet);
    if (!nullToAbsent || erreichtAm != null) {
      map['erreicht_am'] = Variable<DateTime>(erreichtAm);
    }
    return map;
  }

  SparzielTabelleCompanion toCompanion(bool nullToAbsent) {
    return SparzielTabelleCompanion(
      id: Value(id),
      name: Value(name),
      symbol: Value(symbol),
      zielCent: Value(zielCent),
      basis: Value(basis),
      startDatum: Value(startDatum),
      angeheftet: Value(angeheftet),
      erreichtAm: erreichtAm == null && nullToAbsent
          ? const Value.absent()
          : Value(erreichtAm),
    );
  }

  factory Sparziel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sparziel(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      symbol: serializer.fromJson<String>(json['symbol']),
      zielCent: serializer.fromJson<int>(json['zielCent']),
      basis: serializer.fromJson<int>(json['basis']),
      startDatum: serializer.fromJson<DateTime>(json['startDatum']),
      angeheftet: serializer.fromJson<bool>(json['angeheftet']),
      erreichtAm: serializer.fromJson<DateTime?>(json['erreichtAm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'symbol': serializer.toJson<String>(symbol),
      'zielCent': serializer.toJson<int>(zielCent),
      'basis': serializer.toJson<int>(basis),
      'startDatum': serializer.toJson<DateTime>(startDatum),
      'angeheftet': serializer.toJson<bool>(angeheftet),
      'erreichtAm': serializer.toJson<DateTime?>(erreichtAm),
    };
  }

  Sparziel copyWith({
    int? id,
    String? name,
    String? symbol,
    int? zielCent,
    int? basis,
    DateTime? startDatum,
    bool? angeheftet,
    Value<DateTime?> erreichtAm = const Value.absent(),
  }) => Sparziel(
    id: id ?? this.id,
    name: name ?? this.name,
    symbol: symbol ?? this.symbol,
    zielCent: zielCent ?? this.zielCent,
    basis: basis ?? this.basis,
    startDatum: startDatum ?? this.startDatum,
    angeheftet: angeheftet ?? this.angeheftet,
    erreichtAm: erreichtAm.present ? erreichtAm.value : this.erreichtAm,
  );
  Sparziel copyWithCompanion(SparzielTabelleCompanion data) {
    return Sparziel(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      zielCent: data.zielCent.present ? data.zielCent.value : this.zielCent,
      basis: data.basis.present ? data.basis.value : this.basis,
      startDatum: data.startDatum.present
          ? data.startDatum.value
          : this.startDatum,
      angeheftet: data.angeheftet.present
          ? data.angeheftet.value
          : this.angeheftet,
      erreichtAm: data.erreichtAm.present
          ? data.erreichtAm.value
          : this.erreichtAm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Sparziel(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('symbol: $symbol, ')
          ..write('zielCent: $zielCent, ')
          ..write('basis: $basis, ')
          ..write('startDatum: $startDatum, ')
          ..write('angeheftet: $angeheftet, ')
          ..write('erreichtAm: $erreichtAm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    symbol,
    zielCent,
    basis,
    startDatum,
    angeheftet,
    erreichtAm,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sparziel &&
          other.id == this.id &&
          other.name == this.name &&
          other.symbol == this.symbol &&
          other.zielCent == this.zielCent &&
          other.basis == this.basis &&
          other.startDatum == this.startDatum &&
          other.angeheftet == this.angeheftet &&
          other.erreichtAm == this.erreichtAm);
}

class SparzielTabelleCompanion extends UpdateCompanion<Sparziel> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> symbol;
  final Value<int> zielCent;
  final Value<int> basis;
  final Value<DateTime> startDatum;
  final Value<bool> angeheftet;
  final Value<DateTime?> erreichtAm;
  const SparzielTabelleCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.symbol = const Value.absent(),
    this.zielCent = const Value.absent(),
    this.basis = const Value.absent(),
    this.startDatum = const Value.absent(),
    this.angeheftet = const Value.absent(),
    this.erreichtAm = const Value.absent(),
  });
  SparzielTabelleCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.symbol = const Value.absent(),
    required int zielCent,
    this.basis = const Value.absent(),
    required DateTime startDatum,
    this.angeheftet = const Value.absent(),
    this.erreichtAm = const Value.absent(),
  }) : name = Value(name),
       zielCent = Value(zielCent),
       startDatum = Value(startDatum);
  static Insertable<Sparziel> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? symbol,
    Expression<int>? zielCent,
    Expression<int>? basis,
    Expression<DateTime>? startDatum,
    Expression<bool>? angeheftet,
    Expression<DateTime>? erreichtAm,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (symbol != null) 'symbol': symbol,
      if (zielCent != null) 'ziel_cent': zielCent,
      if (basis != null) 'basis': basis,
      if (startDatum != null) 'start_datum': startDatum,
      if (angeheftet != null) 'angeheftet': angeheftet,
      if (erreichtAm != null) 'erreicht_am': erreichtAm,
    });
  }

  SparzielTabelleCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? symbol,
    Value<int>? zielCent,
    Value<int>? basis,
    Value<DateTime>? startDatum,
    Value<bool>? angeheftet,
    Value<DateTime?>? erreichtAm,
  }) {
    return SparzielTabelleCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      zielCent: zielCent ?? this.zielCent,
      basis: basis ?? this.basis,
      startDatum: startDatum ?? this.startDatum,
      angeheftet: angeheftet ?? this.angeheftet,
      erreichtAm: erreichtAm ?? this.erreichtAm,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (zielCent.present) {
      map['ziel_cent'] = Variable<int>(zielCent.value);
    }
    if (basis.present) {
      map['basis'] = Variable<int>(basis.value);
    }
    if (startDatum.present) {
      map['start_datum'] = Variable<DateTime>(startDatum.value);
    }
    if (angeheftet.present) {
      map['angeheftet'] = Variable<bool>(angeheftet.value);
    }
    if (erreichtAm.present) {
      map['erreicht_am'] = Variable<DateTime>(erreichtAm.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SparzielTabelleCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('symbol: $symbol, ')
          ..write('zielCent: $zielCent, ')
          ..write('basis: $basis, ')
          ..write('startDatum: $startDatum, ')
          ..write('angeheftet: $angeheftet, ')
          ..write('erreichtAm: $erreichtAm')
          ..write(')'))
        .toString();
  }
}

class $EinstellungenTabelleTable extends EinstellungenTabelle
    with TableInfo<$EinstellungenTabelleTable, Einstellungen> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EinstellungenTabelleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _strompreisCentProKwhMeta =
      const VerificationMeta('strompreisCentProKwh');
  @override
  late final GeneratedColumn<double> strompreisCentProKwh =
      GeneratedColumn<double>(
        'strompreis_cent_pro_kwh',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(25),
      );
  static const VerificationMeta _standardAufschlagProzentMeta =
      const VerificationMeta('standardAufschlagProzent');
  @override
  late final GeneratedColumn<int> standardAufschlagProzent =
      GeneratedColumn<int>(
        'standard_aufschlag_prozent',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(200),
      );
  static const VerificationMeta _fehldruckProzentMeta = const VerificationMeta(
    'fehldruckProzent',
  );
  @override
  late final GeneratedColumn<int> fehldruckProzent = GeneratedColumn<int>(
    'fehldruck_prozent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(10),
  );
  static const VerificationMeta _rundungCentMeta = const VerificationMeta(
    'rundungCent',
  );
  @override
  late final GeneratedColumn<int> rundungCent = GeneratedColumn<int>(
    'rundung_cent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(50),
  );
  static const VerificationMeta _stundenlohnCentMeta = const VerificationMeta(
    'stundenlohnCent',
  );
  @override
  late final GeneratedColumn<int> stundenlohnCent = GeneratedColumn<int>(
    'stundenlohn_cent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _gebuehrKarteProzentMeta =
      const VerificationMeta('gebuehrKarteProzent');
  @override
  late final GeneratedColumn<double> gebuehrKarteProzent =
      GeneratedColumn<double>(
        'gebuehr_karte_prozent',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _gebuehrOnlineProzentMeta =
      const VerificationMeta('gebuehrOnlineProzent');
  @override
  late final GeneratedColumn<double> gebuehrOnlineProzent =
      GeneratedColumn<double>(
        'gebuehr_online_prozent',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _standardZahlungsartMeta =
      const VerificationMeta('standardZahlungsart');
  @override
  late final GeneratedColumn<int> standardZahlungsart = GeneratedColumn<int>(
    'standard_zahlungsart',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    strompreisCentProKwh,
    standardAufschlagProzent,
    fehldruckProzent,
    rundungCent,
    stundenlohnCent,
    gebuehrKarteProzent,
    gebuehrOnlineProzent,
    standardZahlungsart,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'einstellungen';
  @override
  VerificationContext validateIntegrity(
    Insertable<Einstellungen> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('strompreis_cent_pro_kwh')) {
      context.handle(
        _strompreisCentProKwhMeta,
        strompreisCentProKwh.isAcceptableOrUnknown(
          data['strompreis_cent_pro_kwh']!,
          _strompreisCentProKwhMeta,
        ),
      );
    }
    if (data.containsKey('standard_aufschlag_prozent')) {
      context.handle(
        _standardAufschlagProzentMeta,
        standardAufschlagProzent.isAcceptableOrUnknown(
          data['standard_aufschlag_prozent']!,
          _standardAufschlagProzentMeta,
        ),
      );
    }
    if (data.containsKey('fehldruck_prozent')) {
      context.handle(
        _fehldruckProzentMeta,
        fehldruckProzent.isAcceptableOrUnknown(
          data['fehldruck_prozent']!,
          _fehldruckProzentMeta,
        ),
      );
    }
    if (data.containsKey('rundung_cent')) {
      context.handle(
        _rundungCentMeta,
        rundungCent.isAcceptableOrUnknown(
          data['rundung_cent']!,
          _rundungCentMeta,
        ),
      );
    }
    if (data.containsKey('stundenlohn_cent')) {
      context.handle(
        _stundenlohnCentMeta,
        stundenlohnCent.isAcceptableOrUnknown(
          data['stundenlohn_cent']!,
          _stundenlohnCentMeta,
        ),
      );
    }
    if (data.containsKey('gebuehr_karte_prozent')) {
      context.handle(
        _gebuehrKarteProzentMeta,
        gebuehrKarteProzent.isAcceptableOrUnknown(
          data['gebuehr_karte_prozent']!,
          _gebuehrKarteProzentMeta,
        ),
      );
    }
    if (data.containsKey('gebuehr_online_prozent')) {
      context.handle(
        _gebuehrOnlineProzentMeta,
        gebuehrOnlineProzent.isAcceptableOrUnknown(
          data['gebuehr_online_prozent']!,
          _gebuehrOnlineProzentMeta,
        ),
      );
    }
    if (data.containsKey('standard_zahlungsart')) {
      context.handle(
        _standardZahlungsartMeta,
        standardZahlungsart.isAcceptableOrUnknown(
          data['standard_zahlungsart']!,
          _standardZahlungsartMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Einstellungen map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Einstellungen(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      strompreisCentProKwh: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}strompreis_cent_pro_kwh'],
      )!,
      standardAufschlagProzent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}standard_aufschlag_prozent'],
      )!,
      fehldruckProzent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fehldruck_prozent'],
      )!,
      rundungCent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rundung_cent'],
      )!,
      stundenlohnCent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stundenlohn_cent'],
      )!,
      gebuehrKarteProzent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gebuehr_karte_prozent'],
      )!,
      gebuehrOnlineProzent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gebuehr_online_prozent'],
      )!,
      standardZahlungsart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}standard_zahlungsart'],
      )!,
    );
  }

  @override
  $EinstellungenTabelleTable createAlias(String alias) {
    return $EinstellungenTabelleTable(attachedDatabase, alias);
  }
}

class Einstellungen extends DataClass implements Insertable<Einstellungen> {
  final int id;
  final double strompreisCentProKwh;
  final int standardAufschlagProzent;
  final int fehldruckProzent;

  /// Preisvorschläge werden auf diesen Betrag aufgerundet (50 = 0,50 €).
  final int rundungCent;
  final int stundenlohnCent;
  final double gebuehrKarteProzent;
  final double gebuehrOnlineProzent;
  final int standardZahlungsart;
  const Einstellungen({
    required this.id,
    required this.strompreisCentProKwh,
    required this.standardAufschlagProzent,
    required this.fehldruckProzent,
    required this.rundungCent,
    required this.stundenlohnCent,
    required this.gebuehrKarteProzent,
    required this.gebuehrOnlineProzent,
    required this.standardZahlungsart,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['strompreis_cent_pro_kwh'] = Variable<double>(strompreisCentProKwh);
    map['standard_aufschlag_prozent'] = Variable<int>(standardAufschlagProzent);
    map['fehldruck_prozent'] = Variable<int>(fehldruckProzent);
    map['rundung_cent'] = Variable<int>(rundungCent);
    map['stundenlohn_cent'] = Variable<int>(stundenlohnCent);
    map['gebuehr_karte_prozent'] = Variable<double>(gebuehrKarteProzent);
    map['gebuehr_online_prozent'] = Variable<double>(gebuehrOnlineProzent);
    map['standard_zahlungsart'] = Variable<int>(standardZahlungsart);
    return map;
  }

  EinstellungenTabelleCompanion toCompanion(bool nullToAbsent) {
    return EinstellungenTabelleCompanion(
      id: Value(id),
      strompreisCentProKwh: Value(strompreisCentProKwh),
      standardAufschlagProzent: Value(standardAufschlagProzent),
      fehldruckProzent: Value(fehldruckProzent),
      rundungCent: Value(rundungCent),
      stundenlohnCent: Value(stundenlohnCent),
      gebuehrKarteProzent: Value(gebuehrKarteProzent),
      gebuehrOnlineProzent: Value(gebuehrOnlineProzent),
      standardZahlungsart: Value(standardZahlungsart),
    );
  }

  factory Einstellungen.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Einstellungen(
      id: serializer.fromJson<int>(json['id']),
      strompreisCentProKwh: serializer.fromJson<double>(
        json['strompreisCentProKwh'],
      ),
      standardAufschlagProzent: serializer.fromJson<int>(
        json['standardAufschlagProzent'],
      ),
      fehldruckProzent: serializer.fromJson<int>(json['fehldruckProzent']),
      rundungCent: serializer.fromJson<int>(json['rundungCent']),
      stundenlohnCent: serializer.fromJson<int>(json['stundenlohnCent']),
      gebuehrKarteProzent: serializer.fromJson<double>(
        json['gebuehrKarteProzent'],
      ),
      gebuehrOnlineProzent: serializer.fromJson<double>(
        json['gebuehrOnlineProzent'],
      ),
      standardZahlungsart: serializer.fromJson<int>(
        json['standardZahlungsart'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'strompreisCentProKwh': serializer.toJson<double>(strompreisCentProKwh),
      'standardAufschlagProzent': serializer.toJson<int>(
        standardAufschlagProzent,
      ),
      'fehldruckProzent': serializer.toJson<int>(fehldruckProzent),
      'rundungCent': serializer.toJson<int>(rundungCent),
      'stundenlohnCent': serializer.toJson<int>(stundenlohnCent),
      'gebuehrKarteProzent': serializer.toJson<double>(gebuehrKarteProzent),
      'gebuehrOnlineProzent': serializer.toJson<double>(gebuehrOnlineProzent),
      'standardZahlungsart': serializer.toJson<int>(standardZahlungsart),
    };
  }

  Einstellungen copyWith({
    int? id,
    double? strompreisCentProKwh,
    int? standardAufschlagProzent,
    int? fehldruckProzent,
    int? rundungCent,
    int? stundenlohnCent,
    double? gebuehrKarteProzent,
    double? gebuehrOnlineProzent,
    int? standardZahlungsart,
  }) => Einstellungen(
    id: id ?? this.id,
    strompreisCentProKwh: strompreisCentProKwh ?? this.strompreisCentProKwh,
    standardAufschlagProzent:
        standardAufschlagProzent ?? this.standardAufschlagProzent,
    fehldruckProzent: fehldruckProzent ?? this.fehldruckProzent,
    rundungCent: rundungCent ?? this.rundungCent,
    stundenlohnCent: stundenlohnCent ?? this.stundenlohnCent,
    gebuehrKarteProzent: gebuehrKarteProzent ?? this.gebuehrKarteProzent,
    gebuehrOnlineProzent: gebuehrOnlineProzent ?? this.gebuehrOnlineProzent,
    standardZahlungsart: standardZahlungsart ?? this.standardZahlungsart,
  );
  Einstellungen copyWithCompanion(EinstellungenTabelleCompanion data) {
    return Einstellungen(
      id: data.id.present ? data.id.value : this.id,
      strompreisCentProKwh: data.strompreisCentProKwh.present
          ? data.strompreisCentProKwh.value
          : this.strompreisCentProKwh,
      standardAufschlagProzent: data.standardAufschlagProzent.present
          ? data.standardAufschlagProzent.value
          : this.standardAufschlagProzent,
      fehldruckProzent: data.fehldruckProzent.present
          ? data.fehldruckProzent.value
          : this.fehldruckProzent,
      rundungCent: data.rundungCent.present
          ? data.rundungCent.value
          : this.rundungCent,
      stundenlohnCent: data.stundenlohnCent.present
          ? data.stundenlohnCent.value
          : this.stundenlohnCent,
      gebuehrKarteProzent: data.gebuehrKarteProzent.present
          ? data.gebuehrKarteProzent.value
          : this.gebuehrKarteProzent,
      gebuehrOnlineProzent: data.gebuehrOnlineProzent.present
          ? data.gebuehrOnlineProzent.value
          : this.gebuehrOnlineProzent,
      standardZahlungsart: data.standardZahlungsart.present
          ? data.standardZahlungsart.value
          : this.standardZahlungsart,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Einstellungen(')
          ..write('id: $id, ')
          ..write('strompreisCentProKwh: $strompreisCentProKwh, ')
          ..write('standardAufschlagProzent: $standardAufschlagProzent, ')
          ..write('fehldruckProzent: $fehldruckProzent, ')
          ..write('rundungCent: $rundungCent, ')
          ..write('stundenlohnCent: $stundenlohnCent, ')
          ..write('gebuehrKarteProzent: $gebuehrKarteProzent, ')
          ..write('gebuehrOnlineProzent: $gebuehrOnlineProzent, ')
          ..write('standardZahlungsart: $standardZahlungsart')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    strompreisCentProKwh,
    standardAufschlagProzent,
    fehldruckProzent,
    rundungCent,
    stundenlohnCent,
    gebuehrKarteProzent,
    gebuehrOnlineProzent,
    standardZahlungsart,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Einstellungen &&
          other.id == this.id &&
          other.strompreisCentProKwh == this.strompreisCentProKwh &&
          other.standardAufschlagProzent == this.standardAufschlagProzent &&
          other.fehldruckProzent == this.fehldruckProzent &&
          other.rundungCent == this.rundungCent &&
          other.stundenlohnCent == this.stundenlohnCent &&
          other.gebuehrKarteProzent == this.gebuehrKarteProzent &&
          other.gebuehrOnlineProzent == this.gebuehrOnlineProzent &&
          other.standardZahlungsart == this.standardZahlungsart);
}

class EinstellungenTabelleCompanion extends UpdateCompanion<Einstellungen> {
  final Value<int> id;
  final Value<double> strompreisCentProKwh;
  final Value<int> standardAufschlagProzent;
  final Value<int> fehldruckProzent;
  final Value<int> rundungCent;
  final Value<int> stundenlohnCent;
  final Value<double> gebuehrKarteProzent;
  final Value<double> gebuehrOnlineProzent;
  final Value<int> standardZahlungsart;
  const EinstellungenTabelleCompanion({
    this.id = const Value.absent(),
    this.strompreisCentProKwh = const Value.absent(),
    this.standardAufschlagProzent = const Value.absent(),
    this.fehldruckProzent = const Value.absent(),
    this.rundungCent = const Value.absent(),
    this.stundenlohnCent = const Value.absent(),
    this.gebuehrKarteProzent = const Value.absent(),
    this.gebuehrOnlineProzent = const Value.absent(),
    this.standardZahlungsart = const Value.absent(),
  });
  EinstellungenTabelleCompanion.insert({
    this.id = const Value.absent(),
    this.strompreisCentProKwh = const Value.absent(),
    this.standardAufschlagProzent = const Value.absent(),
    this.fehldruckProzent = const Value.absent(),
    this.rundungCent = const Value.absent(),
    this.stundenlohnCent = const Value.absent(),
    this.gebuehrKarteProzent = const Value.absent(),
    this.gebuehrOnlineProzent = const Value.absent(),
    this.standardZahlungsart = const Value.absent(),
  });
  static Insertable<Einstellungen> custom({
    Expression<int>? id,
    Expression<double>? strompreisCentProKwh,
    Expression<int>? standardAufschlagProzent,
    Expression<int>? fehldruckProzent,
    Expression<int>? rundungCent,
    Expression<int>? stundenlohnCent,
    Expression<double>? gebuehrKarteProzent,
    Expression<double>? gebuehrOnlineProzent,
    Expression<int>? standardZahlungsart,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (strompreisCentProKwh != null)
        'strompreis_cent_pro_kwh': strompreisCentProKwh,
      if (standardAufschlagProzent != null)
        'standard_aufschlag_prozent': standardAufschlagProzent,
      if (fehldruckProzent != null) 'fehldruck_prozent': fehldruckProzent,
      if (rundungCent != null) 'rundung_cent': rundungCent,
      if (stundenlohnCent != null) 'stundenlohn_cent': stundenlohnCent,
      if (gebuehrKarteProzent != null)
        'gebuehr_karte_prozent': gebuehrKarteProzent,
      if (gebuehrOnlineProzent != null)
        'gebuehr_online_prozent': gebuehrOnlineProzent,
      if (standardZahlungsart != null)
        'standard_zahlungsart': standardZahlungsart,
    });
  }

  EinstellungenTabelleCompanion copyWith({
    Value<int>? id,
    Value<double>? strompreisCentProKwh,
    Value<int>? standardAufschlagProzent,
    Value<int>? fehldruckProzent,
    Value<int>? rundungCent,
    Value<int>? stundenlohnCent,
    Value<double>? gebuehrKarteProzent,
    Value<double>? gebuehrOnlineProzent,
    Value<int>? standardZahlungsart,
  }) {
    return EinstellungenTabelleCompanion(
      id: id ?? this.id,
      strompreisCentProKwh: strompreisCentProKwh ?? this.strompreisCentProKwh,
      standardAufschlagProzent:
          standardAufschlagProzent ?? this.standardAufschlagProzent,
      fehldruckProzent: fehldruckProzent ?? this.fehldruckProzent,
      rundungCent: rundungCent ?? this.rundungCent,
      stundenlohnCent: stundenlohnCent ?? this.stundenlohnCent,
      gebuehrKarteProzent: gebuehrKarteProzent ?? this.gebuehrKarteProzent,
      gebuehrOnlineProzent: gebuehrOnlineProzent ?? this.gebuehrOnlineProzent,
      standardZahlungsart: standardZahlungsart ?? this.standardZahlungsart,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (strompreisCentProKwh.present) {
      map['strompreis_cent_pro_kwh'] = Variable<double>(
        strompreisCentProKwh.value,
      );
    }
    if (standardAufschlagProzent.present) {
      map['standard_aufschlag_prozent'] = Variable<int>(
        standardAufschlagProzent.value,
      );
    }
    if (fehldruckProzent.present) {
      map['fehldruck_prozent'] = Variable<int>(fehldruckProzent.value);
    }
    if (rundungCent.present) {
      map['rundung_cent'] = Variable<int>(rundungCent.value);
    }
    if (stundenlohnCent.present) {
      map['stundenlohn_cent'] = Variable<int>(stundenlohnCent.value);
    }
    if (gebuehrKarteProzent.present) {
      map['gebuehr_karte_prozent'] = Variable<double>(
        gebuehrKarteProzent.value,
      );
    }
    if (gebuehrOnlineProzent.present) {
      map['gebuehr_online_prozent'] = Variable<double>(
        gebuehrOnlineProzent.value,
      );
    }
    if (standardZahlungsart.present) {
      map['standard_zahlungsart'] = Variable<int>(standardZahlungsart.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EinstellungenTabelleCompanion(')
          ..write('id: $id, ')
          ..write('strompreisCentProKwh: $strompreisCentProKwh, ')
          ..write('standardAufschlagProzent: $standardAufschlagProzent, ')
          ..write('fehldruckProzent: $fehldruckProzent, ')
          ..write('rundungCent: $rundungCent, ')
          ..write('stundenlohnCent: $stundenlohnCent, ')
          ..write('gebuehrKarteProzent: $gebuehrKarteProzent, ')
          ..write('gebuehrOnlineProzent: $gebuehrOnlineProzent, ')
          ..write('standardZahlungsart: $standardZahlungsart')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatenbank extends GeneratedDatabase {
  _$AppDatenbank(QueryExecutor e) : super(e);
  $AppDatenbankManager get managers => $AppDatenbankManager(this);
  late final $DruckerTabelleTable druckerTabelle = $DruckerTabelleTable(this);
  late final $FilamentTabelleTable filamentTabelle = $FilamentTabelleTable(
    this,
  );
  late final $ExtraTabelleTable extraTabelle = $ExtraTabelleTable(this);
  late final $ProduktTabelleTable produktTabelle = $ProduktTabelleTable(this);
  late final $ProduktFilamentTabelleTable produktFilamentTabelle =
      $ProduktFilamentTabelleTable(this);
  late final $ProduktExtraTabelleTable produktExtraTabelle =
      $ProduktExtraTabelleTable(this);
  late final $AuftragTabelleTable auftragTabelle = $AuftragTabelleTable(this);
  late final $VerkaufTabelleTable verkaufTabelle = $VerkaufTabelleTable(this);
  late final $AuftragPositionTabelleTable auftragPositionTabelle =
      $AuftragPositionTabelleTable(this);
  late final $SparzielTabelleTable sparzielTabelle = $SparzielTabelleTable(
    this,
  );
  late final $EinstellungenTabelleTable einstellungenTabelle =
      $EinstellungenTabelleTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    druckerTabelle,
    filamentTabelle,
    extraTabelle,
    produktTabelle,
    produktFilamentTabelle,
    produktExtraTabelle,
    auftragTabelle,
    verkaufTabelle,
    auftragPositionTabelle,
    sparzielTabelle,
    einstellungenTabelle,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'produkte',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('produkt_filamente', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'produkte',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('produkt_extras', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'auftraege',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('verkaeufe', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'auftraege',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('auftrag_positionen', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$DruckerTabelleTableCreateCompanionBuilder =
    DruckerTabelleCompanion Function({
      Value<int> id,
      required String name,
      required int leistungWatt,
      required int anschaffungCent,
      required int lebensdauerStunden,
      Value<bool> archiviert,
    });
typedef $$DruckerTabelleTableUpdateCompanionBuilder =
    DruckerTabelleCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> leistungWatt,
      Value<int> anschaffungCent,
      Value<int> lebensdauerStunden,
      Value<bool> archiviert,
    });

final class $$DruckerTabelleTableReferences
    extends BaseReferences<_$AppDatenbank, $DruckerTabelleTable, Drucker> {
  $$DruckerTabelleTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$ProduktTabelleTable, List<Produkt>>
  _produktTabelleRefsTable(_$AppDatenbank db) => MultiTypedResultKey.fromTable(
    db.produktTabelle,
    aliasName: 'drucker__id__produkte__drucker_id',
  );

  $$ProduktTabelleTableProcessedTableManager get produktTabelleRefs {
    final manager = $$ProduktTabelleTableTableManager(
      $_db,
      $_db.produktTabelle,
    ).filter((f) => f.druckerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_produktTabelleRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DruckerTabelleTableFilterComposer
    extends Composer<_$AppDatenbank, $DruckerTabelleTable> {
  $$DruckerTabelleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get leistungWatt => $composableBuilder(
    column: $table.leistungWatt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get anschaffungCent => $composableBuilder(
    column: $table.anschaffungCent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lebensdauerStunden => $composableBuilder(
    column: $table.lebensdauerStunden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archiviert => $composableBuilder(
    column: $table.archiviert,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> produktTabelleRefs(
    Expression<bool> Function($$ProduktTabelleTableFilterComposer f) f,
  ) {
    final $$ProduktTabelleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.produktTabelle,
      getReferencedColumn: (t) => t.druckerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduktTabelleTableFilterComposer(
            $db: $db,
            $table: $db.produktTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DruckerTabelleTableOrderingComposer
    extends Composer<_$AppDatenbank, $DruckerTabelleTable> {
  $$DruckerTabelleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get leistungWatt => $composableBuilder(
    column: $table.leistungWatt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get anschaffungCent => $composableBuilder(
    column: $table.anschaffungCent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lebensdauerStunden => $composableBuilder(
    column: $table.lebensdauerStunden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archiviert => $composableBuilder(
    column: $table.archiviert,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DruckerTabelleTableAnnotationComposer
    extends Composer<_$AppDatenbank, $DruckerTabelleTable> {
  $$DruckerTabelleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get leistungWatt => $composableBuilder(
    column: $table.leistungWatt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get anschaffungCent => $composableBuilder(
    column: $table.anschaffungCent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lebensdauerStunden => $composableBuilder(
    column: $table.lebensdauerStunden,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get archiviert => $composableBuilder(
    column: $table.archiviert,
    builder: (column) => column,
  );

  Expression<T> produktTabelleRefs<T extends Object>(
    Expression<T> Function($$ProduktTabelleTableAnnotationComposer a) f,
  ) {
    final $$ProduktTabelleTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.produktTabelle,
      getReferencedColumn: (t) => t.druckerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduktTabelleTableAnnotationComposer(
            $db: $db,
            $table: $db.produktTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DruckerTabelleTableTableManager
    extends
        RootTableManager<
          _$AppDatenbank,
          $DruckerTabelleTable,
          Drucker,
          $$DruckerTabelleTableFilterComposer,
          $$DruckerTabelleTableOrderingComposer,
          $$DruckerTabelleTableAnnotationComposer,
          $$DruckerTabelleTableCreateCompanionBuilder,
          $$DruckerTabelleTableUpdateCompanionBuilder,
          (Drucker, $$DruckerTabelleTableReferences),
          Drucker,
          PrefetchHooks Function({bool produktTabelleRefs})
        > {
  $$DruckerTabelleTableTableManager(
    _$AppDatenbank db,
    $DruckerTabelleTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DruckerTabelleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DruckerTabelleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DruckerTabelleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> leistungWatt = const Value.absent(),
                Value<int> anschaffungCent = const Value.absent(),
                Value<int> lebensdauerStunden = const Value.absent(),
                Value<bool> archiviert = const Value.absent(),
              }) => DruckerTabelleCompanion(
                id: id,
                name: name,
                leistungWatt: leistungWatt,
                anschaffungCent: anschaffungCent,
                lebensdauerStunden: lebensdauerStunden,
                archiviert: archiviert,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int leistungWatt,
                required int anschaffungCent,
                required int lebensdauerStunden,
                Value<bool> archiviert = const Value.absent(),
              }) => DruckerTabelleCompanion.insert(
                id: id,
                name: name,
                leistungWatt: leistungWatt,
                anschaffungCent: anschaffungCent,
                lebensdauerStunden: lebensdauerStunden,
                archiviert: archiviert,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DruckerTabelleTable, Drucker>(table),
                  $$DruckerTabelleTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({produktTabelleRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (produktTabelleRefs) db.produktTabelle,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (produktTabelleRefs)
                    await $_getPrefetchedData<
                      Drucker,
                      $DruckerTabelleTable,
                      Produkt
                    >(
                      currentTable: table,
                      referencedTable: $$DruckerTabelleTableReferences
                          ._produktTabelleRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$DruckerTabelleTableReferences(
                            db,
                            table,
                            p0,
                          ).produktTabelleRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.druckerId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DruckerTabelleTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatenbank,
      $DruckerTabelleTable,
      Drucker,
      $$DruckerTabelleTableFilterComposer,
      $$DruckerTabelleTableOrderingComposer,
      $$DruckerTabelleTableAnnotationComposer,
      $$DruckerTabelleTableCreateCompanionBuilder,
      $$DruckerTabelleTableUpdateCompanionBuilder,
      (Drucker, $$DruckerTabelleTableReferences),
      Drucker,
      PrefetchHooks Function({bool produktTabelleRefs})
    >;
typedef $$FilamentTabelleTableCreateCompanionBuilder =
    FilamentTabelleCompanion Function({
      Value<int> id,
      required String name,
      required String material,
      required int farbe,
      required int preisProKgCent,
      Value<bool> archiviert,
    });
typedef $$FilamentTabelleTableUpdateCompanionBuilder =
    FilamentTabelleCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> material,
      Value<int> farbe,
      Value<int> preisProKgCent,
      Value<bool> archiviert,
    });

final class $$FilamentTabelleTableReferences
    extends BaseReferences<_$AppDatenbank, $FilamentTabelleTable, Filament> {
  $$FilamentTabelleTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $ProduktFilamentTabelleTable,
    List<ProduktFilament>
  >
  _produktFilamentTabelleRefsTable(_$AppDatenbank db) =>
      MultiTypedResultKey.fromTable(
        db.produktFilamentTabelle,
        aliasName: 'filamente__id__produkt_filamente__filament_id',
      );

  $$ProduktFilamentTabelleTableProcessedTableManager
  get produktFilamentTabelleRefs {
    final manager = $$ProduktFilamentTabelleTableTableManager(
      $_db,
      $_db.produktFilamentTabelle,
    ).filter((f) => f.filamentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _produktFilamentTabelleRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FilamentTabelleTableFilterComposer
    extends Composer<_$AppDatenbank, $FilamentTabelleTable> {
  $$FilamentTabelleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get material => $composableBuilder(
    column: $table.material,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get farbe => $composableBuilder(
    column: $table.farbe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get preisProKgCent => $composableBuilder(
    column: $table.preisProKgCent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archiviert => $composableBuilder(
    column: $table.archiviert,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> produktFilamentTabelleRefs(
    Expression<bool> Function($$ProduktFilamentTabelleTableFilterComposer f) f,
  ) {
    final $$ProduktFilamentTabelleTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.produktFilamentTabelle,
          getReferencedColumn: (t) => t.filamentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProduktFilamentTabelleTableFilterComposer(
                $db: $db,
                $table: $db.produktFilamentTabelle,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$FilamentTabelleTableOrderingComposer
    extends Composer<_$AppDatenbank, $FilamentTabelleTable> {
  $$FilamentTabelleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get material => $composableBuilder(
    column: $table.material,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get farbe => $composableBuilder(
    column: $table.farbe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get preisProKgCent => $composableBuilder(
    column: $table.preisProKgCent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archiviert => $composableBuilder(
    column: $table.archiviert,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FilamentTabelleTableAnnotationComposer
    extends Composer<_$AppDatenbank, $FilamentTabelleTable> {
  $$FilamentTabelleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get material =>
      $composableBuilder(column: $table.material, builder: (column) => column);

  GeneratedColumn<int> get farbe =>
      $composableBuilder(column: $table.farbe, builder: (column) => column);

  GeneratedColumn<int> get preisProKgCent => $composableBuilder(
    column: $table.preisProKgCent,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get archiviert => $composableBuilder(
    column: $table.archiviert,
    builder: (column) => column,
  );

  Expression<T> produktFilamentTabelleRefs<T extends Object>(
    Expression<T> Function($$ProduktFilamentTabelleTableAnnotationComposer a) f,
  ) {
    final $$ProduktFilamentTabelleTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.produktFilamentTabelle,
          getReferencedColumn: (t) => t.filamentId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProduktFilamentTabelleTableAnnotationComposer(
                $db: $db,
                $table: $db.produktFilamentTabelle,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$FilamentTabelleTableTableManager
    extends
        RootTableManager<
          _$AppDatenbank,
          $FilamentTabelleTable,
          Filament,
          $$FilamentTabelleTableFilterComposer,
          $$FilamentTabelleTableOrderingComposer,
          $$FilamentTabelleTableAnnotationComposer,
          $$FilamentTabelleTableCreateCompanionBuilder,
          $$FilamentTabelleTableUpdateCompanionBuilder,
          (Filament, $$FilamentTabelleTableReferences),
          Filament,
          PrefetchHooks Function({bool produktFilamentTabelleRefs})
        > {
  $$FilamentTabelleTableTableManager(
    _$AppDatenbank db,
    $FilamentTabelleTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FilamentTabelleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FilamentTabelleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FilamentTabelleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> material = const Value.absent(),
                Value<int> farbe = const Value.absent(),
                Value<int> preisProKgCent = const Value.absent(),
                Value<bool> archiviert = const Value.absent(),
              }) => FilamentTabelleCompanion(
                id: id,
                name: name,
                material: material,
                farbe: farbe,
                preisProKgCent: preisProKgCent,
                archiviert: archiviert,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String material,
                required int farbe,
                required int preisProKgCent,
                Value<bool> archiviert = const Value.absent(),
              }) => FilamentTabelleCompanion.insert(
                id: id,
                name: name,
                material: material,
                farbe: farbe,
                preisProKgCent: preisProKgCent,
                archiviert: archiviert,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FilamentTabelleTable, Filament>(table),
                  $$FilamentTabelleTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({produktFilamentTabelleRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (produktFilamentTabelleRefs) db.produktFilamentTabelle,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (produktFilamentTabelleRefs)
                    await $_getPrefetchedData<
                      Filament,
                      $FilamentTabelleTable,
                      ProduktFilament
                    >(
                      currentTable: table,
                      referencedTable: $$FilamentTabelleTableReferences
                          ._produktFilamentTabelleRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$FilamentTabelleTableReferences(
                            db,
                            table,
                            p0,
                          ).produktFilamentTabelleRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.filamentId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$FilamentTabelleTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatenbank,
      $FilamentTabelleTable,
      Filament,
      $$FilamentTabelleTableFilterComposer,
      $$FilamentTabelleTableOrderingComposer,
      $$FilamentTabelleTableAnnotationComposer,
      $$FilamentTabelleTableCreateCompanionBuilder,
      $$FilamentTabelleTableUpdateCompanionBuilder,
      (Filament, $$FilamentTabelleTableReferences),
      Filament,
      PrefetchHooks Function({bool produktFilamentTabelleRefs})
    >;
typedef $$ExtraTabelleTableCreateCompanionBuilder =
    ExtraTabelleCompanion Function({
      Value<int> id,
      required String name,
      required int kostenCent,
      Value<bool> archiviert,
    });
typedef $$ExtraTabelleTableUpdateCompanionBuilder =
    ExtraTabelleCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> kostenCent,
      Value<bool> archiviert,
    });

final class $$ExtraTabelleTableReferences
    extends BaseReferences<_$AppDatenbank, $ExtraTabelleTable, Extra> {
  $$ExtraTabelleTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProduktExtraTabelleTable, List<ProduktExtra>>
  _produktExtraTabelleRefsTable(_$AppDatenbank db) =>
      MultiTypedResultKey.fromTable(
        db.produktExtraTabelle,
        aliasName: 'extras__id__produkt_extras__extra_id',
      );

  $$ProduktExtraTabelleTableProcessedTableManager get produktExtraTabelleRefs {
    final manager = $$ProduktExtraTabelleTableTableManager(
      $_db,
      $_db.produktExtraTabelle,
    ).filter((f) => f.extraId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _produktExtraTabelleRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExtraTabelleTableFilterComposer
    extends Composer<_$AppDatenbank, $ExtraTabelleTable> {
  $$ExtraTabelleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get kostenCent => $composableBuilder(
    column: $table.kostenCent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archiviert => $composableBuilder(
    column: $table.archiviert,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> produktExtraTabelleRefs(
    Expression<bool> Function($$ProduktExtraTabelleTableFilterComposer f) f,
  ) {
    final $$ProduktExtraTabelleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.produktExtraTabelle,
      getReferencedColumn: (t) => t.extraId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduktExtraTabelleTableFilterComposer(
            $db: $db,
            $table: $db.produktExtraTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExtraTabelleTableOrderingComposer
    extends Composer<_$AppDatenbank, $ExtraTabelleTable> {
  $$ExtraTabelleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get kostenCent => $composableBuilder(
    column: $table.kostenCent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archiviert => $composableBuilder(
    column: $table.archiviert,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExtraTabelleTableAnnotationComposer
    extends Composer<_$AppDatenbank, $ExtraTabelleTable> {
  $$ExtraTabelleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get kostenCent => $composableBuilder(
    column: $table.kostenCent,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get archiviert => $composableBuilder(
    column: $table.archiviert,
    builder: (column) => column,
  );

  Expression<T> produktExtraTabelleRefs<T extends Object>(
    Expression<T> Function($$ProduktExtraTabelleTableAnnotationComposer a) f,
  ) {
    final $$ProduktExtraTabelleTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.produktExtraTabelle,
          getReferencedColumn: (t) => t.extraId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProduktExtraTabelleTableAnnotationComposer(
                $db: $db,
                $table: $db.produktExtraTabelle,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ExtraTabelleTableTableManager
    extends
        RootTableManager<
          _$AppDatenbank,
          $ExtraTabelleTable,
          Extra,
          $$ExtraTabelleTableFilterComposer,
          $$ExtraTabelleTableOrderingComposer,
          $$ExtraTabelleTableAnnotationComposer,
          $$ExtraTabelleTableCreateCompanionBuilder,
          $$ExtraTabelleTableUpdateCompanionBuilder,
          (Extra, $$ExtraTabelleTableReferences),
          Extra,
          PrefetchHooks Function({bool produktExtraTabelleRefs})
        > {
  $$ExtraTabelleTableTableManager(_$AppDatenbank db, $ExtraTabelleTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExtraTabelleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExtraTabelleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExtraTabelleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> kostenCent = const Value.absent(),
                Value<bool> archiviert = const Value.absent(),
              }) => ExtraTabelleCompanion(
                id: id,
                name: name,
                kostenCent: kostenCent,
                archiviert: archiviert,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int kostenCent,
                Value<bool> archiviert = const Value.absent(),
              }) => ExtraTabelleCompanion.insert(
                id: id,
                name: name,
                kostenCent: kostenCent,
                archiviert: archiviert,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExtraTabelleTable, Extra>(table),
                  $$ExtraTabelleTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({produktExtraTabelleRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (produktExtraTabelleRefs) db.produktExtraTabelle,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (produktExtraTabelleRefs)
                    await $_getPrefetchedData<
                      Extra,
                      $ExtraTabelleTable,
                      ProduktExtra
                    >(
                      currentTable: table,
                      referencedTable: $$ExtraTabelleTableReferences
                          ._produktExtraTabelleRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ExtraTabelleTableReferences(
                            db,
                            table,
                            p0,
                          ).produktExtraTabelleRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.extraId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ExtraTabelleTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatenbank,
      $ExtraTabelleTable,
      Extra,
      $$ExtraTabelleTableFilterComposer,
      $$ExtraTabelleTableOrderingComposer,
      $$ExtraTabelleTableAnnotationComposer,
      $$ExtraTabelleTableCreateCompanionBuilder,
      $$ExtraTabelleTableUpdateCompanionBuilder,
      (Extra, $$ExtraTabelleTableReferences),
      Extra,
      PrefetchHooks Function({bool produktExtraTabelleRefs})
    >;
typedef $$ProduktTabelleTableCreateCompanionBuilder =
    ProduktTabelleCompanion Function({
      Value<int> id,
      required String name,
      Value<String> symbol,
      required int farbe,
      Value<int?> druckerId,
      required int druckzeitMinuten,
      Value<int> stueckProDruck,
      Value<double> spuelabfallGramm,
      Value<int> arbeitMinuten,
      Value<int?> aufschlagProzent,
      Value<int?> preisManuellCent,
      Value<int> sortierung,
      Value<bool> archiviert,
    });
typedef $$ProduktTabelleTableUpdateCompanionBuilder =
    ProduktTabelleCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> symbol,
      Value<int> farbe,
      Value<int?> druckerId,
      Value<int> druckzeitMinuten,
      Value<int> stueckProDruck,
      Value<double> spuelabfallGramm,
      Value<int> arbeitMinuten,
      Value<int?> aufschlagProzent,
      Value<int?> preisManuellCent,
      Value<int> sortierung,
      Value<bool> archiviert,
    });

final class $$ProduktTabelleTableReferences
    extends BaseReferences<_$AppDatenbank, $ProduktTabelleTable, Produkt> {
  $$ProduktTabelleTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DruckerTabelleTable _druckerIdTable(_$AppDatenbank db) =>
      db.druckerTabelle.createAlias('produkte__drucker_id__drucker__id');

  $$DruckerTabelleTableProcessedTableManager? get druckerId {
    final $_column = $_itemColumn<int>('drucker_id');
    if ($_column == null) return null;
    final manager = $$DruckerTabelleTableTableManager(
      $_db,
      $_db.druckerTabelle,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_druckerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $ProduktFilamentTabelleTable,
    List<ProduktFilament>
  >
  _produktFilamentTabelleRefsTable(_$AppDatenbank db) =>
      MultiTypedResultKey.fromTable(
        db.produktFilamentTabelle,
        aliasName: 'produkte__id__produkt_filamente__produkt_id',
      );

  $$ProduktFilamentTabelleTableProcessedTableManager
  get produktFilamentTabelleRefs {
    final manager = $$ProduktFilamentTabelleTableTableManager(
      $_db,
      $_db.produktFilamentTabelle,
    ).filter((f) => f.produktId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _produktFilamentTabelleRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ProduktExtraTabelleTable, List<ProduktExtra>>
  _produktExtraTabelleRefsTable(_$AppDatenbank db) =>
      MultiTypedResultKey.fromTable(
        db.produktExtraTabelle,
        aliasName: 'produkte__id__produkt_extras__produkt_id',
      );

  $$ProduktExtraTabelleTableProcessedTableManager get produktExtraTabelleRefs {
    final manager = $$ProduktExtraTabelleTableTableManager(
      $_db,
      $_db.produktExtraTabelle,
    ).filter((f) => f.produktId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _produktExtraTabelleRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$VerkaufTabelleTable, List<Verkauf>>
  _verkaufTabelleRefsTable(_$AppDatenbank db) => MultiTypedResultKey.fromTable(
    db.verkaufTabelle,
    aliasName: 'produkte__id__verkaeufe__produkt_id',
  );

  $$VerkaufTabelleTableProcessedTableManager get verkaufTabelleRefs {
    final manager = $$VerkaufTabelleTableTableManager(
      $_db,
      $_db.verkaufTabelle,
    ).filter((f) => f.produktId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_verkaufTabelleRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $AuftragPositionTabelleTable,
    List<AuftragPosition>
  >
  _auftragPositionTabelleRefsTable(_$AppDatenbank db) =>
      MultiTypedResultKey.fromTable(
        db.auftragPositionTabelle,
        aliasName: 'produkte__id__auftrag_positionen__produkt_id',
      );

  $$AuftragPositionTabelleTableProcessedTableManager
  get auftragPositionTabelleRefs {
    final manager = $$AuftragPositionTabelleTableTableManager(
      $_db,
      $_db.auftragPositionTabelle,
    ).filter((f) => f.produktId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _auftragPositionTabelleRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProduktTabelleTableFilterComposer
    extends Composer<_$AppDatenbank, $ProduktTabelleTable> {
  $$ProduktTabelleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get farbe => $composableBuilder(
    column: $table.farbe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get druckzeitMinuten => $composableBuilder(
    column: $table.druckzeitMinuten,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stueckProDruck => $composableBuilder(
    column: $table.stueckProDruck,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get spuelabfallGramm => $composableBuilder(
    column: $table.spuelabfallGramm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get arbeitMinuten => $composableBuilder(
    column: $table.arbeitMinuten,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get aufschlagProzent => $composableBuilder(
    column: $table.aufschlagProzent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get preisManuellCent => $composableBuilder(
    column: $table.preisManuellCent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortierung => $composableBuilder(
    column: $table.sortierung,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archiviert => $composableBuilder(
    column: $table.archiviert,
    builder: (column) => ColumnFilters(column),
  );

  $$DruckerTabelleTableFilterComposer get druckerId {
    final $$DruckerTabelleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.druckerId,
      referencedTable: $db.druckerTabelle,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DruckerTabelleTableFilterComposer(
            $db: $db,
            $table: $db.druckerTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> produktFilamentTabelleRefs(
    Expression<bool> Function($$ProduktFilamentTabelleTableFilterComposer f) f,
  ) {
    final $$ProduktFilamentTabelleTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.produktFilamentTabelle,
          getReferencedColumn: (t) => t.produktId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProduktFilamentTabelleTableFilterComposer(
                $db: $db,
                $table: $db.produktFilamentTabelle,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> produktExtraTabelleRefs(
    Expression<bool> Function($$ProduktExtraTabelleTableFilterComposer f) f,
  ) {
    final $$ProduktExtraTabelleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.produktExtraTabelle,
      getReferencedColumn: (t) => t.produktId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduktExtraTabelleTableFilterComposer(
            $db: $db,
            $table: $db.produktExtraTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> verkaufTabelleRefs(
    Expression<bool> Function($$VerkaufTabelleTableFilterComposer f) f,
  ) {
    final $$VerkaufTabelleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.verkaufTabelle,
      getReferencedColumn: (t) => t.produktId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VerkaufTabelleTableFilterComposer(
            $db: $db,
            $table: $db.verkaufTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> auftragPositionTabelleRefs(
    Expression<bool> Function($$AuftragPositionTabelleTableFilterComposer f) f,
  ) {
    final $$AuftragPositionTabelleTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.auftragPositionTabelle,
          getReferencedColumn: (t) => t.produktId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AuftragPositionTabelleTableFilterComposer(
                $db: $db,
                $table: $db.auftragPositionTabelle,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ProduktTabelleTableOrderingComposer
    extends Composer<_$AppDatenbank, $ProduktTabelleTable> {
  $$ProduktTabelleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get farbe => $composableBuilder(
    column: $table.farbe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get druckzeitMinuten => $composableBuilder(
    column: $table.druckzeitMinuten,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stueckProDruck => $composableBuilder(
    column: $table.stueckProDruck,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get spuelabfallGramm => $composableBuilder(
    column: $table.spuelabfallGramm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get arbeitMinuten => $composableBuilder(
    column: $table.arbeitMinuten,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get aufschlagProzent => $composableBuilder(
    column: $table.aufschlagProzent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get preisManuellCent => $composableBuilder(
    column: $table.preisManuellCent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortierung => $composableBuilder(
    column: $table.sortierung,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archiviert => $composableBuilder(
    column: $table.archiviert,
    builder: (column) => ColumnOrderings(column),
  );

  $$DruckerTabelleTableOrderingComposer get druckerId {
    final $$DruckerTabelleTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.druckerId,
      referencedTable: $db.druckerTabelle,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DruckerTabelleTableOrderingComposer(
            $db: $db,
            $table: $db.druckerTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProduktTabelleTableAnnotationComposer
    extends Composer<_$AppDatenbank, $ProduktTabelleTable> {
  $$ProduktTabelleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<int> get farbe =>
      $composableBuilder(column: $table.farbe, builder: (column) => column);

  GeneratedColumn<int> get druckzeitMinuten => $composableBuilder(
    column: $table.druckzeitMinuten,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stueckProDruck => $composableBuilder(
    column: $table.stueckProDruck,
    builder: (column) => column,
  );

  GeneratedColumn<double> get spuelabfallGramm => $composableBuilder(
    column: $table.spuelabfallGramm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get arbeitMinuten => $composableBuilder(
    column: $table.arbeitMinuten,
    builder: (column) => column,
  );

  GeneratedColumn<int> get aufschlagProzent => $composableBuilder(
    column: $table.aufschlagProzent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get preisManuellCent => $composableBuilder(
    column: $table.preisManuellCent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortierung => $composableBuilder(
    column: $table.sortierung,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get archiviert => $composableBuilder(
    column: $table.archiviert,
    builder: (column) => column,
  );

  $$DruckerTabelleTableAnnotationComposer get druckerId {
    final $$DruckerTabelleTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.druckerId,
      referencedTable: $db.druckerTabelle,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DruckerTabelleTableAnnotationComposer(
            $db: $db,
            $table: $db.druckerTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> produktFilamentTabelleRefs<T extends Object>(
    Expression<T> Function($$ProduktFilamentTabelleTableAnnotationComposer a) f,
  ) {
    final $$ProduktFilamentTabelleTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.produktFilamentTabelle,
          getReferencedColumn: (t) => t.produktId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProduktFilamentTabelleTableAnnotationComposer(
                $db: $db,
                $table: $db.produktFilamentTabelle,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> produktExtraTabelleRefs<T extends Object>(
    Expression<T> Function($$ProduktExtraTabelleTableAnnotationComposer a) f,
  ) {
    final $$ProduktExtraTabelleTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.produktExtraTabelle,
          getReferencedColumn: (t) => t.produktId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ProduktExtraTabelleTableAnnotationComposer(
                $db: $db,
                $table: $db.produktExtraTabelle,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> verkaufTabelleRefs<T extends Object>(
    Expression<T> Function($$VerkaufTabelleTableAnnotationComposer a) f,
  ) {
    final $$VerkaufTabelleTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.verkaufTabelle,
      getReferencedColumn: (t) => t.produktId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VerkaufTabelleTableAnnotationComposer(
            $db: $db,
            $table: $db.verkaufTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> auftragPositionTabelleRefs<T extends Object>(
    Expression<T> Function($$AuftragPositionTabelleTableAnnotationComposer a) f,
  ) {
    final $$AuftragPositionTabelleTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.auftragPositionTabelle,
          getReferencedColumn: (t) => t.produktId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AuftragPositionTabelleTableAnnotationComposer(
                $db: $db,
                $table: $db.auftragPositionTabelle,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ProduktTabelleTableTableManager
    extends
        RootTableManager<
          _$AppDatenbank,
          $ProduktTabelleTable,
          Produkt,
          $$ProduktTabelleTableFilterComposer,
          $$ProduktTabelleTableOrderingComposer,
          $$ProduktTabelleTableAnnotationComposer,
          $$ProduktTabelleTableCreateCompanionBuilder,
          $$ProduktTabelleTableUpdateCompanionBuilder,
          (Produkt, $$ProduktTabelleTableReferences),
          Produkt,
          PrefetchHooks Function({
            bool druckerId,
            bool produktFilamentTabelleRefs,
            bool produktExtraTabelleRefs,
            bool verkaufTabelleRefs,
            bool auftragPositionTabelleRefs,
          })
        > {
  $$ProduktTabelleTableTableManager(
    _$AppDatenbank db,
    $ProduktTabelleTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProduktTabelleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProduktTabelleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProduktTabelleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> symbol = const Value.absent(),
                Value<int> farbe = const Value.absent(),
                Value<int?> druckerId = const Value.absent(),
                Value<int> druckzeitMinuten = const Value.absent(),
                Value<int> stueckProDruck = const Value.absent(),
                Value<double> spuelabfallGramm = const Value.absent(),
                Value<int> arbeitMinuten = const Value.absent(),
                Value<int?> aufschlagProzent = const Value.absent(),
                Value<int?> preisManuellCent = const Value.absent(),
                Value<int> sortierung = const Value.absent(),
                Value<bool> archiviert = const Value.absent(),
              }) => ProduktTabelleCompanion(
                id: id,
                name: name,
                symbol: symbol,
                farbe: farbe,
                druckerId: druckerId,
                druckzeitMinuten: druckzeitMinuten,
                stueckProDruck: stueckProDruck,
                spuelabfallGramm: spuelabfallGramm,
                arbeitMinuten: arbeitMinuten,
                aufschlagProzent: aufschlagProzent,
                preisManuellCent: preisManuellCent,
                sortierung: sortierung,
                archiviert: archiviert,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> symbol = const Value.absent(),
                required int farbe,
                Value<int?> druckerId = const Value.absent(),
                required int druckzeitMinuten,
                Value<int> stueckProDruck = const Value.absent(),
                Value<double> spuelabfallGramm = const Value.absent(),
                Value<int> arbeitMinuten = const Value.absent(),
                Value<int?> aufschlagProzent = const Value.absent(),
                Value<int?> preisManuellCent = const Value.absent(),
                Value<int> sortierung = const Value.absent(),
                Value<bool> archiviert = const Value.absent(),
              }) => ProduktTabelleCompanion.insert(
                id: id,
                name: name,
                symbol: symbol,
                farbe: farbe,
                druckerId: druckerId,
                druckzeitMinuten: druckzeitMinuten,
                stueckProDruck: stueckProDruck,
                spuelabfallGramm: spuelabfallGramm,
                arbeitMinuten: arbeitMinuten,
                aufschlagProzent: aufschlagProzent,
                preisManuellCent: preisManuellCent,
                sortierung: sortierung,
                archiviert: archiviert,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProduktTabelleTable, Produkt>(table),
                  $$ProduktTabelleTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                druckerId = false,
                produktFilamentTabelleRefs = false,
                produktExtraTabelleRefs = false,
                verkaufTabelleRefs = false,
                auftragPositionTabelleRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (produktFilamentTabelleRefs) db.produktFilamentTabelle,
                    if (produktExtraTabelleRefs) db.produktExtraTabelle,
                    if (verkaufTabelleRefs) db.verkaufTabelle,
                    if (auftragPositionTabelleRefs) db.auftragPositionTabelle,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (druckerId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.druckerId,
                            referencedTable: $$ProduktTabelleTableReferences
                                ._druckerIdTable(db),
                            referencedColumn: $$ProduktTabelleTableReferences
                                ._druckerIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (produktFilamentTabelleRefs)
                        await $_getPrefetchedData<
                          Produkt,
                          $ProduktTabelleTable,
                          ProduktFilament
                        >(
                          currentTable: table,
                          referencedTable: $$ProduktTabelleTableReferences
                              ._produktFilamentTabelleRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProduktTabelleTableReferences(
                                db,
                                table,
                                p0,
                              ).produktFilamentTabelleRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.produktId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (produktExtraTabelleRefs)
                        await $_getPrefetchedData<
                          Produkt,
                          $ProduktTabelleTable,
                          ProduktExtra
                        >(
                          currentTable: table,
                          referencedTable: $$ProduktTabelleTableReferences
                              ._produktExtraTabelleRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProduktTabelleTableReferences(
                                db,
                                table,
                                p0,
                              ).produktExtraTabelleRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.produktId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (verkaufTabelleRefs)
                        await $_getPrefetchedData<
                          Produkt,
                          $ProduktTabelleTable,
                          Verkauf
                        >(
                          currentTable: table,
                          referencedTable: $$ProduktTabelleTableReferences
                              ._verkaufTabelleRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProduktTabelleTableReferences(
                                db,
                                table,
                                p0,
                              ).verkaufTabelleRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.produktId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (auftragPositionTabelleRefs)
                        await $_getPrefetchedData<
                          Produkt,
                          $ProduktTabelleTable,
                          AuftragPosition
                        >(
                          currentTable: table,
                          referencedTable: $$ProduktTabelleTableReferences
                              ._auftragPositionTabelleRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProduktTabelleTableReferences(
                                db,
                                table,
                                p0,
                              ).auftragPositionTabelleRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.produktId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProduktTabelleTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatenbank,
      $ProduktTabelleTable,
      Produkt,
      $$ProduktTabelleTableFilterComposer,
      $$ProduktTabelleTableOrderingComposer,
      $$ProduktTabelleTableAnnotationComposer,
      $$ProduktTabelleTableCreateCompanionBuilder,
      $$ProduktTabelleTableUpdateCompanionBuilder,
      (Produkt, $$ProduktTabelleTableReferences),
      Produkt,
      PrefetchHooks Function({
        bool druckerId,
        bool produktFilamentTabelleRefs,
        bool produktExtraTabelleRefs,
        bool verkaufTabelleRefs,
        bool auftragPositionTabelleRefs,
      })
    >;
typedef $$ProduktFilamentTabelleTableCreateCompanionBuilder =
    ProduktFilamentTabelleCompanion Function({
      Value<int> id,
      required int produktId,
      required int filamentId,
      required double gramm,
    });
typedef $$ProduktFilamentTabelleTableUpdateCompanionBuilder =
    ProduktFilamentTabelleCompanion Function({
      Value<int> id,
      Value<int> produktId,
      Value<int> filamentId,
      Value<double> gramm,
    });

final class $$ProduktFilamentTabelleTableReferences
    extends
        BaseReferences<
          _$AppDatenbank,
          $ProduktFilamentTabelleTable,
          ProduktFilament
        > {
  $$ProduktFilamentTabelleTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProduktTabelleTable _produktIdTable(_$AppDatenbank db) => db
      .produktTabelle
      .createAlias('produkt_filamente__produkt_id__produkte__id');

  $$ProduktTabelleTableProcessedTableManager get produktId {
    final $_column = $_itemColumn<int>('produkt_id')!;

    final manager = $$ProduktTabelleTableTableManager(
      $_db,
      $_db.produktTabelle,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_produktIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FilamentTabelleTable _filamentIdTable(_$AppDatenbank db) => db
      .filamentTabelle
      .createAlias('produkt_filamente__filament_id__filamente__id');

  $$FilamentTabelleTableProcessedTableManager get filamentId {
    final $_column = $_itemColumn<int>('filament_id')!;

    final manager = $$FilamentTabelleTableTableManager(
      $_db,
      $_db.filamentTabelle,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_filamentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProduktFilamentTabelleTableFilterComposer
    extends Composer<_$AppDatenbank, $ProduktFilamentTabelleTable> {
  $$ProduktFilamentTabelleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gramm => $composableBuilder(
    column: $table.gramm,
    builder: (column) => ColumnFilters(column),
  );

  $$ProduktTabelleTableFilterComposer get produktId {
    final $$ProduktTabelleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.produktId,
      referencedTable: $db.produktTabelle,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduktTabelleTableFilterComposer(
            $db: $db,
            $table: $db.produktTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FilamentTabelleTableFilterComposer get filamentId {
    final $$FilamentTabelleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.filamentId,
      referencedTable: $db.filamentTabelle,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FilamentTabelleTableFilterComposer(
            $db: $db,
            $table: $db.filamentTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProduktFilamentTabelleTableOrderingComposer
    extends Composer<_$AppDatenbank, $ProduktFilamentTabelleTable> {
  $$ProduktFilamentTabelleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gramm => $composableBuilder(
    column: $table.gramm,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProduktTabelleTableOrderingComposer get produktId {
    final $$ProduktTabelleTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.produktId,
      referencedTable: $db.produktTabelle,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduktTabelleTableOrderingComposer(
            $db: $db,
            $table: $db.produktTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FilamentTabelleTableOrderingComposer get filamentId {
    final $$FilamentTabelleTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.filamentId,
      referencedTable: $db.filamentTabelle,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FilamentTabelleTableOrderingComposer(
            $db: $db,
            $table: $db.filamentTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProduktFilamentTabelleTableAnnotationComposer
    extends Composer<_$AppDatenbank, $ProduktFilamentTabelleTable> {
  $$ProduktFilamentTabelleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get gramm =>
      $composableBuilder(column: $table.gramm, builder: (column) => column);

  $$ProduktTabelleTableAnnotationComposer get produktId {
    final $$ProduktTabelleTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.produktId,
      referencedTable: $db.produktTabelle,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduktTabelleTableAnnotationComposer(
            $db: $db,
            $table: $db.produktTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FilamentTabelleTableAnnotationComposer get filamentId {
    final $$FilamentTabelleTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.filamentId,
      referencedTable: $db.filamentTabelle,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FilamentTabelleTableAnnotationComposer(
            $db: $db,
            $table: $db.filamentTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProduktFilamentTabelleTableTableManager
    extends
        RootTableManager<
          _$AppDatenbank,
          $ProduktFilamentTabelleTable,
          ProduktFilament,
          $$ProduktFilamentTabelleTableFilterComposer,
          $$ProduktFilamentTabelleTableOrderingComposer,
          $$ProduktFilamentTabelleTableAnnotationComposer,
          $$ProduktFilamentTabelleTableCreateCompanionBuilder,
          $$ProduktFilamentTabelleTableUpdateCompanionBuilder,
          (ProduktFilament, $$ProduktFilamentTabelleTableReferences),
          ProduktFilament,
          PrefetchHooks Function({bool produktId, bool filamentId})
        > {
  $$ProduktFilamentTabelleTableTableManager(
    _$AppDatenbank db,
    $ProduktFilamentTabelleTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProduktFilamentTabelleTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ProduktFilamentTabelleTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ProduktFilamentTabelleTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> produktId = const Value.absent(),
                Value<int> filamentId = const Value.absent(),
                Value<double> gramm = const Value.absent(),
              }) => ProduktFilamentTabelleCompanion(
                id: id,
                produktId: produktId,
                filamentId: filamentId,
                gramm: gramm,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int produktId,
                required int filamentId,
                required double gramm,
              }) => ProduktFilamentTabelleCompanion.insert(
                id: id,
                produktId: produktId,
                filamentId: filamentId,
                gramm: gramm,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProduktFilamentTabelleTable, ProduktFilament>(
                    table,
                  ),
                  $$ProduktFilamentTabelleTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({produktId = false, filamentId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (produktId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.produktId,
                        referencedTable: $$ProduktFilamentTabelleTableReferences
                            ._produktIdTable(db),
                        referencedColumn:
                            $$ProduktFilamentTabelleTableReferences
                                ._produktIdTable(db)
                                .id,
                      ) as T;
                    }
                    if (filamentId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.filamentId,
                        referencedTable: $$ProduktFilamentTabelleTableReferences
                            ._filamentIdTable(db),
                        referencedColumn:
                            $$ProduktFilamentTabelleTableReferences
                                ._filamentIdTable(db)
                                .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ProduktFilamentTabelleTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatenbank,
      $ProduktFilamentTabelleTable,
      ProduktFilament,
      $$ProduktFilamentTabelleTableFilterComposer,
      $$ProduktFilamentTabelleTableOrderingComposer,
      $$ProduktFilamentTabelleTableAnnotationComposer,
      $$ProduktFilamentTabelleTableCreateCompanionBuilder,
      $$ProduktFilamentTabelleTableUpdateCompanionBuilder,
      (ProduktFilament, $$ProduktFilamentTabelleTableReferences),
      ProduktFilament,
      PrefetchHooks Function({bool produktId, bool filamentId})
    >;
typedef $$ProduktExtraTabelleTableCreateCompanionBuilder =
    ProduktExtraTabelleCompanion Function({
      Value<int> id,
      required int produktId,
      required int extraId,
      Value<int> menge,
    });
typedef $$ProduktExtraTabelleTableUpdateCompanionBuilder =
    ProduktExtraTabelleCompanion Function({
      Value<int> id,
      Value<int> produktId,
      Value<int> extraId,
      Value<int> menge,
    });

final class $$ProduktExtraTabelleTableReferences
    extends
        BaseReferences<
          _$AppDatenbank,
          $ProduktExtraTabelleTable,
          ProduktExtra
        > {
  $$ProduktExtraTabelleTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProduktTabelleTable _produktIdTable(_$AppDatenbank db) =>
      db.produktTabelle.createAlias('produkt_extras__produkt_id__produkte__id');

  $$ProduktTabelleTableProcessedTableManager get produktId {
    final $_column = $_itemColumn<int>('produkt_id')!;

    final manager = $$ProduktTabelleTableTableManager(
      $_db,
      $_db.produktTabelle,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_produktIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExtraTabelleTable _extraIdTable(_$AppDatenbank db) =>
      db.extraTabelle.createAlias('produkt_extras__extra_id__extras__id');

  $$ExtraTabelleTableProcessedTableManager get extraId {
    final $_column = $_itemColumn<int>('extra_id')!;

    final manager = $$ExtraTabelleTableTableManager(
      $_db,
      $_db.extraTabelle,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_extraIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ProduktExtraTabelleTableFilterComposer
    extends Composer<_$AppDatenbank, $ProduktExtraTabelleTable> {
  $$ProduktExtraTabelleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get menge => $composableBuilder(
    column: $table.menge,
    builder: (column) => ColumnFilters(column),
  );

  $$ProduktTabelleTableFilterComposer get produktId {
    final $$ProduktTabelleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.produktId,
      referencedTable: $db.produktTabelle,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduktTabelleTableFilterComposer(
            $db: $db,
            $table: $db.produktTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExtraTabelleTableFilterComposer get extraId {
    final $$ExtraTabelleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.extraId,
      referencedTable: $db.extraTabelle,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExtraTabelleTableFilterComposer(
            $db: $db,
            $table: $db.extraTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProduktExtraTabelleTableOrderingComposer
    extends Composer<_$AppDatenbank, $ProduktExtraTabelleTable> {
  $$ProduktExtraTabelleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get menge => $composableBuilder(
    column: $table.menge,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProduktTabelleTableOrderingComposer get produktId {
    final $$ProduktTabelleTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.produktId,
      referencedTable: $db.produktTabelle,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduktTabelleTableOrderingComposer(
            $db: $db,
            $table: $db.produktTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExtraTabelleTableOrderingComposer get extraId {
    final $$ExtraTabelleTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.extraId,
      referencedTable: $db.extraTabelle,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExtraTabelleTableOrderingComposer(
            $db: $db,
            $table: $db.extraTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProduktExtraTabelleTableAnnotationComposer
    extends Composer<_$AppDatenbank, $ProduktExtraTabelleTable> {
  $$ProduktExtraTabelleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get menge =>
      $composableBuilder(column: $table.menge, builder: (column) => column);

  $$ProduktTabelleTableAnnotationComposer get produktId {
    final $$ProduktTabelleTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.produktId,
      referencedTable: $db.produktTabelle,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduktTabelleTableAnnotationComposer(
            $db: $db,
            $table: $db.produktTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExtraTabelleTableAnnotationComposer get extraId {
    final $$ExtraTabelleTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.extraId,
      referencedTable: $db.extraTabelle,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExtraTabelleTableAnnotationComposer(
            $db: $db,
            $table: $db.extraTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProduktExtraTabelleTableTableManager
    extends
        RootTableManager<
          _$AppDatenbank,
          $ProduktExtraTabelleTable,
          ProduktExtra,
          $$ProduktExtraTabelleTableFilterComposer,
          $$ProduktExtraTabelleTableOrderingComposer,
          $$ProduktExtraTabelleTableAnnotationComposer,
          $$ProduktExtraTabelleTableCreateCompanionBuilder,
          $$ProduktExtraTabelleTableUpdateCompanionBuilder,
          (ProduktExtra, $$ProduktExtraTabelleTableReferences),
          ProduktExtra,
          PrefetchHooks Function({bool produktId, bool extraId})
        > {
  $$ProduktExtraTabelleTableTableManager(
    _$AppDatenbank db,
    $ProduktExtraTabelleTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProduktExtraTabelleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProduktExtraTabelleTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ProduktExtraTabelleTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> produktId = const Value.absent(),
                Value<int> extraId = const Value.absent(),
                Value<int> menge = const Value.absent(),
              }) => ProduktExtraTabelleCompanion(
                id: id,
                produktId: produktId,
                extraId: extraId,
                menge: menge,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int produktId,
                required int extraId,
                Value<int> menge = const Value.absent(),
              }) => ProduktExtraTabelleCompanion.insert(
                id: id,
                produktId: produktId,
                extraId: extraId,
                menge: menge,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProduktExtraTabelleTable, ProduktExtra>(table),
                  $$ProduktExtraTabelleTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({produktId = false, extraId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (produktId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.produktId,
                        referencedTable: $$ProduktExtraTabelleTableReferences
                            ._produktIdTable(db),
                        referencedColumn: $$ProduktExtraTabelleTableReferences
                            ._produktIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (extraId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.extraId,
                        referencedTable: $$ProduktExtraTabelleTableReferences
                            ._extraIdTable(db),
                        referencedColumn: $$ProduktExtraTabelleTableReferences
                            ._extraIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ProduktExtraTabelleTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatenbank,
      $ProduktExtraTabelleTable,
      ProduktExtra,
      $$ProduktExtraTabelleTableFilterComposer,
      $$ProduktExtraTabelleTableOrderingComposer,
      $$ProduktExtraTabelleTableAnnotationComposer,
      $$ProduktExtraTabelleTableCreateCompanionBuilder,
      $$ProduktExtraTabelleTableUpdateCompanionBuilder,
      (ProduktExtra, $$ProduktExtraTabelleTableReferences),
      ProduktExtra,
      PrefetchHooks Function({bool produktId, bool extraId})
    >;
typedef $$AuftragTabelleTableCreateCompanionBuilder =
    AuftragTabelleCompanion Function({
      Value<int> id,
      required String kunde,
      Value<String> kontakt,
      Value<String> notiz,
      required DateTime erstelltAm,
      Value<DateTime?> faelligAm,
      Value<int> status,
      Value<DateTime?> bezahltAm,
      Value<int> zahlungsart,
    });
typedef $$AuftragTabelleTableUpdateCompanionBuilder =
    AuftragTabelleCompanion Function({
      Value<int> id,
      Value<String> kunde,
      Value<String> kontakt,
      Value<String> notiz,
      Value<DateTime> erstelltAm,
      Value<DateTime?> faelligAm,
      Value<int> status,
      Value<DateTime?> bezahltAm,
      Value<int> zahlungsart,
    });

final class $$AuftragTabelleTableReferences
    extends BaseReferences<_$AppDatenbank, $AuftragTabelleTable, Auftrag> {
  $$AuftragTabelleTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$VerkaufTabelleTable, List<Verkauf>>
  _verkaufTabelleRefsTable(_$AppDatenbank db) => MultiTypedResultKey.fromTable(
    db.verkaufTabelle,
    aliasName: 'auftraege__id__verkaeufe__auftrag_id',
  );

  $$VerkaufTabelleTableProcessedTableManager get verkaufTabelleRefs {
    final manager = $$VerkaufTabelleTableTableManager(
      $_db,
      $_db.verkaufTabelle,
    ).filter((f) => f.auftragId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_verkaufTabelleRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $AuftragPositionTabelleTable,
    List<AuftragPosition>
  >
  _auftragPositionTabelleRefsTable(_$AppDatenbank db) =>
      MultiTypedResultKey.fromTable(
        db.auftragPositionTabelle,
        aliasName: 'auftraege__id__auftrag_positionen__auftrag_id',
      );

  $$AuftragPositionTabelleTableProcessedTableManager
  get auftragPositionTabelleRefs {
    final manager = $$AuftragPositionTabelleTableTableManager(
      $_db,
      $_db.auftragPositionTabelle,
    ).filter((f) => f.auftragId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _auftragPositionTabelleRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AuftragTabelleTableFilterComposer
    extends Composer<_$AppDatenbank, $AuftragTabelleTable> {
  $$AuftragTabelleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kunde => $composableBuilder(
    column: $table.kunde,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kontakt => $composableBuilder(
    column: $table.kontakt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notiz => $composableBuilder(
    column: $table.notiz,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get erstelltAm => $composableBuilder(
    column: $table.erstelltAm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get faelligAm => $composableBuilder(
    column: $table.faelligAm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get bezahltAm => $composableBuilder(
    column: $table.bezahltAm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get zahlungsart => $composableBuilder(
    column: $table.zahlungsart,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> verkaufTabelleRefs(
    Expression<bool> Function($$VerkaufTabelleTableFilterComposer f) f,
  ) {
    final $$VerkaufTabelleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.verkaufTabelle,
      getReferencedColumn: (t) => t.auftragId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VerkaufTabelleTableFilterComposer(
            $db: $db,
            $table: $db.verkaufTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> auftragPositionTabelleRefs(
    Expression<bool> Function($$AuftragPositionTabelleTableFilterComposer f) f,
  ) {
    final $$AuftragPositionTabelleTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.auftragPositionTabelle,
          getReferencedColumn: (t) => t.auftragId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AuftragPositionTabelleTableFilterComposer(
                $db: $db,
                $table: $db.auftragPositionTabelle,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$AuftragTabelleTableOrderingComposer
    extends Composer<_$AppDatenbank, $AuftragTabelleTable> {
  $$AuftragTabelleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kunde => $composableBuilder(
    column: $table.kunde,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kontakt => $composableBuilder(
    column: $table.kontakt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notiz => $composableBuilder(
    column: $table.notiz,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get erstelltAm => $composableBuilder(
    column: $table.erstelltAm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get faelligAm => $composableBuilder(
    column: $table.faelligAm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get bezahltAm => $composableBuilder(
    column: $table.bezahltAm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get zahlungsart => $composableBuilder(
    column: $table.zahlungsart,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AuftragTabelleTableAnnotationComposer
    extends Composer<_$AppDatenbank, $AuftragTabelleTable> {
  $$AuftragTabelleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kunde =>
      $composableBuilder(column: $table.kunde, builder: (column) => column);

  GeneratedColumn<String> get kontakt =>
      $composableBuilder(column: $table.kontakt, builder: (column) => column);

  GeneratedColumn<String> get notiz =>
      $composableBuilder(column: $table.notiz, builder: (column) => column);

  GeneratedColumn<DateTime> get erstelltAm => $composableBuilder(
    column: $table.erstelltAm,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get faelligAm =>
      $composableBuilder(column: $table.faelligAm, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get bezahltAm =>
      $composableBuilder(column: $table.bezahltAm, builder: (column) => column);

  GeneratedColumn<int> get zahlungsart => $composableBuilder(
    column: $table.zahlungsart,
    builder: (column) => column,
  );

  Expression<T> verkaufTabelleRefs<T extends Object>(
    Expression<T> Function($$VerkaufTabelleTableAnnotationComposer a) f,
  ) {
    final $$VerkaufTabelleTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.verkaufTabelle,
      getReferencedColumn: (t) => t.auftragId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VerkaufTabelleTableAnnotationComposer(
            $db: $db,
            $table: $db.verkaufTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> auftragPositionTabelleRefs<T extends Object>(
    Expression<T> Function($$AuftragPositionTabelleTableAnnotationComposer a) f,
  ) {
    final $$AuftragPositionTabelleTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.auftragPositionTabelle,
          getReferencedColumn: (t) => t.auftragId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AuftragPositionTabelleTableAnnotationComposer(
                $db: $db,
                $table: $db.auftragPositionTabelle,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$AuftragTabelleTableTableManager
    extends
        RootTableManager<
          _$AppDatenbank,
          $AuftragTabelleTable,
          Auftrag,
          $$AuftragTabelleTableFilterComposer,
          $$AuftragTabelleTableOrderingComposer,
          $$AuftragTabelleTableAnnotationComposer,
          $$AuftragTabelleTableCreateCompanionBuilder,
          $$AuftragTabelleTableUpdateCompanionBuilder,
          (Auftrag, $$AuftragTabelleTableReferences),
          Auftrag,
          PrefetchHooks Function({
            bool verkaufTabelleRefs,
            bool auftragPositionTabelleRefs,
          })
        > {
  $$AuftragTabelleTableTableManager(
    _$AppDatenbank db,
    $AuftragTabelleTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuftragTabelleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuftragTabelleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuftragTabelleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> kunde = const Value.absent(),
                Value<String> kontakt = const Value.absent(),
                Value<String> notiz = const Value.absent(),
                Value<DateTime> erstelltAm = const Value.absent(),
                Value<DateTime?> faelligAm = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<DateTime?> bezahltAm = const Value.absent(),
                Value<int> zahlungsart = const Value.absent(),
              }) => AuftragTabelleCompanion(
                id: id,
                kunde: kunde,
                kontakt: kontakt,
                notiz: notiz,
                erstelltAm: erstelltAm,
                faelligAm: faelligAm,
                status: status,
                bezahltAm: bezahltAm,
                zahlungsart: zahlungsart,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String kunde,
                Value<String> kontakt = const Value.absent(),
                Value<String> notiz = const Value.absent(),
                required DateTime erstelltAm,
                Value<DateTime?> faelligAm = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<DateTime?> bezahltAm = const Value.absent(),
                Value<int> zahlungsart = const Value.absent(),
              }) => AuftragTabelleCompanion.insert(
                id: id,
                kunde: kunde,
                kontakt: kontakt,
                notiz: notiz,
                erstelltAm: erstelltAm,
                faelligAm: faelligAm,
                status: status,
                bezahltAm: bezahltAm,
                zahlungsart: zahlungsart,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AuftragTabelleTable, Auftrag>(table),
                  $$AuftragTabelleTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                verkaufTabelleRefs = false,
                auftragPositionTabelleRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (verkaufTabelleRefs) db.verkaufTabelle,
                    if (auftragPositionTabelleRefs) db.auftragPositionTabelle,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (verkaufTabelleRefs)
                        await $_getPrefetchedData<
                          Auftrag,
                          $AuftragTabelleTable,
                          Verkauf
                        >(
                          currentTable: table,
                          referencedTable: $$AuftragTabelleTableReferences
                              ._verkaufTabelleRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AuftragTabelleTableReferences(
                                db,
                                table,
                                p0,
                              ).verkaufTabelleRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.auftragId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (auftragPositionTabelleRefs)
                        await $_getPrefetchedData<
                          Auftrag,
                          $AuftragTabelleTable,
                          AuftragPosition
                        >(
                          currentTable: table,
                          referencedTable: $$AuftragTabelleTableReferences
                              ._auftragPositionTabelleRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AuftragTabelleTableReferences(
                                db,
                                table,
                                p0,
                              ).auftragPositionTabelleRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.auftragId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AuftragTabelleTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatenbank,
      $AuftragTabelleTable,
      Auftrag,
      $$AuftragTabelleTableFilterComposer,
      $$AuftragTabelleTableOrderingComposer,
      $$AuftragTabelleTableAnnotationComposer,
      $$AuftragTabelleTableCreateCompanionBuilder,
      $$AuftragTabelleTableUpdateCompanionBuilder,
      (Auftrag, $$AuftragTabelleTableReferences),
      Auftrag,
      PrefetchHooks Function({
        bool verkaufTabelleRefs,
        bool auftragPositionTabelleRefs,
      })
    >;
typedef $$VerkaufTabelleTableCreateCompanionBuilder =
    VerkaufTabelleCompanion Function({
      Value<int> id,
      required DateTime zeitpunkt,
      Value<int?> produktId,
      required String produktName,
      required int menge,
      required int einzelpreisCent,
      required int einzelkostenCent,
      Value<int> gebuehrCent,
      Value<int> zahlungsart,
      Value<int?> auftragId,
    });
typedef $$VerkaufTabelleTableUpdateCompanionBuilder =
    VerkaufTabelleCompanion Function({
      Value<int> id,
      Value<DateTime> zeitpunkt,
      Value<int?> produktId,
      Value<String> produktName,
      Value<int> menge,
      Value<int> einzelpreisCent,
      Value<int> einzelkostenCent,
      Value<int> gebuehrCent,
      Value<int> zahlungsart,
      Value<int?> auftragId,
    });

final class $$VerkaufTabelleTableReferences
    extends BaseReferences<_$AppDatenbank, $VerkaufTabelleTable, Verkauf> {
  $$VerkaufTabelleTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProduktTabelleTable _produktIdTable(_$AppDatenbank db) =>
      db.produktTabelle.createAlias('verkaeufe__produkt_id__produkte__id');

  $$ProduktTabelleTableProcessedTableManager? get produktId {
    final $_column = $_itemColumn<int>('produkt_id');
    if ($_column == null) return null;
    final manager = $$ProduktTabelleTableTableManager(
      $_db,
      $_db.produktTabelle,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_produktIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AuftragTabelleTable _auftragIdTable(_$AppDatenbank db) =>
      db.auftragTabelle.createAlias('verkaeufe__auftrag_id__auftraege__id');

  $$AuftragTabelleTableProcessedTableManager? get auftragId {
    final $_column = $_itemColumn<int>('auftrag_id');
    if ($_column == null) return null;
    final manager = $$AuftragTabelleTableTableManager(
      $_db,
      $_db.auftragTabelle,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_auftragIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$VerkaufTabelleTableFilterComposer
    extends Composer<_$AppDatenbank, $VerkaufTabelleTable> {
  $$VerkaufTabelleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get zeitpunkt => $composableBuilder(
    column: $table.zeitpunkt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get produktName => $composableBuilder(
    column: $table.produktName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get menge => $composableBuilder(
    column: $table.menge,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get einzelpreisCent => $composableBuilder(
    column: $table.einzelpreisCent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get einzelkostenCent => $composableBuilder(
    column: $table.einzelkostenCent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gebuehrCent => $composableBuilder(
    column: $table.gebuehrCent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get zahlungsart => $composableBuilder(
    column: $table.zahlungsart,
    builder: (column) => ColumnFilters(column),
  );

  $$ProduktTabelleTableFilterComposer get produktId {
    final $$ProduktTabelleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.produktId,
      referencedTable: $db.produktTabelle,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduktTabelleTableFilterComposer(
            $db: $db,
            $table: $db.produktTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AuftragTabelleTableFilterComposer get auftragId {
    final $$AuftragTabelleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.auftragId,
      referencedTable: $db.auftragTabelle,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuftragTabelleTableFilterComposer(
            $db: $db,
            $table: $db.auftragTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VerkaufTabelleTableOrderingComposer
    extends Composer<_$AppDatenbank, $VerkaufTabelleTable> {
  $$VerkaufTabelleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get zeitpunkt => $composableBuilder(
    column: $table.zeitpunkt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get produktName => $composableBuilder(
    column: $table.produktName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get menge => $composableBuilder(
    column: $table.menge,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get einzelpreisCent => $composableBuilder(
    column: $table.einzelpreisCent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get einzelkostenCent => $composableBuilder(
    column: $table.einzelkostenCent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gebuehrCent => $composableBuilder(
    column: $table.gebuehrCent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get zahlungsart => $composableBuilder(
    column: $table.zahlungsart,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProduktTabelleTableOrderingComposer get produktId {
    final $$ProduktTabelleTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.produktId,
      referencedTable: $db.produktTabelle,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduktTabelleTableOrderingComposer(
            $db: $db,
            $table: $db.produktTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AuftragTabelleTableOrderingComposer get auftragId {
    final $$AuftragTabelleTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.auftragId,
      referencedTable: $db.auftragTabelle,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuftragTabelleTableOrderingComposer(
            $db: $db,
            $table: $db.auftragTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VerkaufTabelleTableAnnotationComposer
    extends Composer<_$AppDatenbank, $VerkaufTabelleTable> {
  $$VerkaufTabelleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get zeitpunkt =>
      $composableBuilder(column: $table.zeitpunkt, builder: (column) => column);

  GeneratedColumn<String> get produktName => $composableBuilder(
    column: $table.produktName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get menge =>
      $composableBuilder(column: $table.menge, builder: (column) => column);

  GeneratedColumn<int> get einzelpreisCent => $composableBuilder(
    column: $table.einzelpreisCent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get einzelkostenCent => $composableBuilder(
    column: $table.einzelkostenCent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get gebuehrCent => $composableBuilder(
    column: $table.gebuehrCent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get zahlungsart => $composableBuilder(
    column: $table.zahlungsart,
    builder: (column) => column,
  );

  $$ProduktTabelleTableAnnotationComposer get produktId {
    final $$ProduktTabelleTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.produktId,
      referencedTable: $db.produktTabelle,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduktTabelleTableAnnotationComposer(
            $db: $db,
            $table: $db.produktTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AuftragTabelleTableAnnotationComposer get auftragId {
    final $$AuftragTabelleTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.auftragId,
      referencedTable: $db.auftragTabelle,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuftragTabelleTableAnnotationComposer(
            $db: $db,
            $table: $db.auftragTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VerkaufTabelleTableTableManager
    extends
        RootTableManager<
          _$AppDatenbank,
          $VerkaufTabelleTable,
          Verkauf,
          $$VerkaufTabelleTableFilterComposer,
          $$VerkaufTabelleTableOrderingComposer,
          $$VerkaufTabelleTableAnnotationComposer,
          $$VerkaufTabelleTableCreateCompanionBuilder,
          $$VerkaufTabelleTableUpdateCompanionBuilder,
          (Verkauf, $$VerkaufTabelleTableReferences),
          Verkauf,
          PrefetchHooks Function({bool produktId, bool auftragId})
        > {
  $$VerkaufTabelleTableTableManager(
    _$AppDatenbank db,
    $VerkaufTabelleTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VerkaufTabelleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VerkaufTabelleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VerkaufTabelleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> zeitpunkt = const Value.absent(),
                Value<int?> produktId = const Value.absent(),
                Value<String> produktName = const Value.absent(),
                Value<int> menge = const Value.absent(),
                Value<int> einzelpreisCent = const Value.absent(),
                Value<int> einzelkostenCent = const Value.absent(),
                Value<int> gebuehrCent = const Value.absent(),
                Value<int> zahlungsart = const Value.absent(),
                Value<int?> auftragId = const Value.absent(),
              }) => VerkaufTabelleCompanion(
                id: id,
                zeitpunkt: zeitpunkt,
                produktId: produktId,
                produktName: produktName,
                menge: menge,
                einzelpreisCent: einzelpreisCent,
                einzelkostenCent: einzelkostenCent,
                gebuehrCent: gebuehrCent,
                zahlungsart: zahlungsart,
                auftragId: auftragId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime zeitpunkt,
                Value<int?> produktId = const Value.absent(),
                required String produktName,
                required int menge,
                required int einzelpreisCent,
                required int einzelkostenCent,
                Value<int> gebuehrCent = const Value.absent(),
                Value<int> zahlungsart = const Value.absent(),
                Value<int?> auftragId = const Value.absent(),
              }) => VerkaufTabelleCompanion.insert(
                id: id,
                zeitpunkt: zeitpunkt,
                produktId: produktId,
                produktName: produktName,
                menge: menge,
                einzelpreisCent: einzelpreisCent,
                einzelkostenCent: einzelkostenCent,
                gebuehrCent: gebuehrCent,
                zahlungsart: zahlungsart,
                auftragId: auftragId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VerkaufTabelleTable, Verkauf>(table),
                  $$VerkaufTabelleTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({produktId = false, auftragId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (produktId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.produktId,
                        referencedTable: $$VerkaufTabelleTableReferences
                            ._produktIdTable(db),
                        referencedColumn: $$VerkaufTabelleTableReferences
                            ._produktIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (auftragId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.auftragId,
                        referencedTable: $$VerkaufTabelleTableReferences
                            ._auftragIdTable(db),
                        referencedColumn: $$VerkaufTabelleTableReferences
                            ._auftragIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$VerkaufTabelleTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatenbank,
      $VerkaufTabelleTable,
      Verkauf,
      $$VerkaufTabelleTableFilterComposer,
      $$VerkaufTabelleTableOrderingComposer,
      $$VerkaufTabelleTableAnnotationComposer,
      $$VerkaufTabelleTableCreateCompanionBuilder,
      $$VerkaufTabelleTableUpdateCompanionBuilder,
      (Verkauf, $$VerkaufTabelleTableReferences),
      Verkauf,
      PrefetchHooks Function({bool produktId, bool auftragId})
    >;
typedef $$AuftragPositionTabelleTableCreateCompanionBuilder =
    AuftragPositionTabelleCompanion Function({
      Value<int> id,
      required int auftragId,
      required int produktId,
      required int menge,
      required int einzelpreisCent,
      Value<String> notiz,
    });
typedef $$AuftragPositionTabelleTableUpdateCompanionBuilder =
    AuftragPositionTabelleCompanion Function({
      Value<int> id,
      Value<int> auftragId,
      Value<int> produktId,
      Value<int> menge,
      Value<int> einzelpreisCent,
      Value<String> notiz,
    });

final class $$AuftragPositionTabelleTableReferences
    extends
        BaseReferences<
          _$AppDatenbank,
          $AuftragPositionTabelleTable,
          AuftragPosition
        > {
  $$AuftragPositionTabelleTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AuftragTabelleTable _auftragIdTable(_$AppDatenbank db) => db
      .auftragTabelle
      .createAlias('auftrag_positionen__auftrag_id__auftraege__id');

  $$AuftragTabelleTableProcessedTableManager get auftragId {
    final $_column = $_itemColumn<int>('auftrag_id')!;

    final manager = $$AuftragTabelleTableTableManager(
      $_db,
      $_db.auftragTabelle,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_auftragIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProduktTabelleTable _produktIdTable(_$AppDatenbank db) => db
      .produktTabelle
      .createAlias('auftrag_positionen__produkt_id__produkte__id');

  $$ProduktTabelleTableProcessedTableManager get produktId {
    final $_column = $_itemColumn<int>('produkt_id')!;

    final manager = $$ProduktTabelleTableTableManager(
      $_db,
      $_db.produktTabelle,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_produktIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AuftragPositionTabelleTableFilterComposer
    extends Composer<_$AppDatenbank, $AuftragPositionTabelleTable> {
  $$AuftragPositionTabelleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get menge => $composableBuilder(
    column: $table.menge,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get einzelpreisCent => $composableBuilder(
    column: $table.einzelpreisCent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notiz => $composableBuilder(
    column: $table.notiz,
    builder: (column) => ColumnFilters(column),
  );

  $$AuftragTabelleTableFilterComposer get auftragId {
    final $$AuftragTabelleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.auftragId,
      referencedTable: $db.auftragTabelle,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuftragTabelleTableFilterComposer(
            $db: $db,
            $table: $db.auftragTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProduktTabelleTableFilterComposer get produktId {
    final $$ProduktTabelleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.produktId,
      referencedTable: $db.produktTabelle,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduktTabelleTableFilterComposer(
            $db: $db,
            $table: $db.produktTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AuftragPositionTabelleTableOrderingComposer
    extends Composer<_$AppDatenbank, $AuftragPositionTabelleTable> {
  $$AuftragPositionTabelleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get menge => $composableBuilder(
    column: $table.menge,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get einzelpreisCent => $composableBuilder(
    column: $table.einzelpreisCent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notiz => $composableBuilder(
    column: $table.notiz,
    builder: (column) => ColumnOrderings(column),
  );

  $$AuftragTabelleTableOrderingComposer get auftragId {
    final $$AuftragTabelleTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.auftragId,
      referencedTable: $db.auftragTabelle,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuftragTabelleTableOrderingComposer(
            $db: $db,
            $table: $db.auftragTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProduktTabelleTableOrderingComposer get produktId {
    final $$ProduktTabelleTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.produktId,
      referencedTable: $db.produktTabelle,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduktTabelleTableOrderingComposer(
            $db: $db,
            $table: $db.produktTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AuftragPositionTabelleTableAnnotationComposer
    extends Composer<_$AppDatenbank, $AuftragPositionTabelleTable> {
  $$AuftragPositionTabelleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get menge =>
      $composableBuilder(column: $table.menge, builder: (column) => column);

  GeneratedColumn<int> get einzelpreisCent => $composableBuilder(
    column: $table.einzelpreisCent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notiz =>
      $composableBuilder(column: $table.notiz, builder: (column) => column);

  $$AuftragTabelleTableAnnotationComposer get auftragId {
    final $$AuftragTabelleTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.auftragId,
      referencedTable: $db.auftragTabelle,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuftragTabelleTableAnnotationComposer(
            $db: $db,
            $table: $db.auftragTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProduktTabelleTableAnnotationComposer get produktId {
    final $$ProduktTabelleTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.produktId,
      referencedTable: $db.produktTabelle,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProduktTabelleTableAnnotationComposer(
            $db: $db,
            $table: $db.produktTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AuftragPositionTabelleTableTableManager
    extends
        RootTableManager<
          _$AppDatenbank,
          $AuftragPositionTabelleTable,
          AuftragPosition,
          $$AuftragPositionTabelleTableFilterComposer,
          $$AuftragPositionTabelleTableOrderingComposer,
          $$AuftragPositionTabelleTableAnnotationComposer,
          $$AuftragPositionTabelleTableCreateCompanionBuilder,
          $$AuftragPositionTabelleTableUpdateCompanionBuilder,
          (AuftragPosition, $$AuftragPositionTabelleTableReferences),
          AuftragPosition,
          PrefetchHooks Function({bool auftragId, bool produktId})
        > {
  $$AuftragPositionTabelleTableTableManager(
    _$AppDatenbank db,
    $AuftragPositionTabelleTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuftragPositionTabelleTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$AuftragPositionTabelleTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AuftragPositionTabelleTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> auftragId = const Value.absent(),
                Value<int> produktId = const Value.absent(),
                Value<int> menge = const Value.absent(),
                Value<int> einzelpreisCent = const Value.absent(),
                Value<String> notiz = const Value.absent(),
              }) => AuftragPositionTabelleCompanion(
                id: id,
                auftragId: auftragId,
                produktId: produktId,
                menge: menge,
                einzelpreisCent: einzelpreisCent,
                notiz: notiz,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int auftragId,
                required int produktId,
                required int menge,
                required int einzelpreisCent,
                Value<String> notiz = const Value.absent(),
              }) => AuftragPositionTabelleCompanion.insert(
                id: id,
                auftragId: auftragId,
                produktId: produktId,
                menge: menge,
                einzelpreisCent: einzelpreisCent,
                notiz: notiz,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AuftragPositionTabelleTable, AuftragPosition>(
                    table,
                  ),
                  $$AuftragPositionTabelleTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({auftragId = false, produktId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (auftragId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.auftragId,
                        referencedTable: $$AuftragPositionTabelleTableReferences
                            ._auftragIdTable(db),
                        referencedColumn:
                            $$AuftragPositionTabelleTableReferences
                                ._auftragIdTable(db)
                                .id,
                      ) as T;
                    }
                    if (produktId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.produktId,
                        referencedTable: $$AuftragPositionTabelleTableReferences
                            ._produktIdTable(db),
                        referencedColumn:
                            $$AuftragPositionTabelleTableReferences
                                ._produktIdTable(db)
                                .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AuftragPositionTabelleTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatenbank,
      $AuftragPositionTabelleTable,
      AuftragPosition,
      $$AuftragPositionTabelleTableFilterComposer,
      $$AuftragPositionTabelleTableOrderingComposer,
      $$AuftragPositionTabelleTableAnnotationComposer,
      $$AuftragPositionTabelleTableCreateCompanionBuilder,
      $$AuftragPositionTabelleTableUpdateCompanionBuilder,
      (AuftragPosition, $$AuftragPositionTabelleTableReferences),
      AuftragPosition,
      PrefetchHooks Function({bool auftragId, bool produktId})
    >;
typedef $$SparzielTabelleTableCreateCompanionBuilder =
    SparzielTabelleCompanion Function({
      Value<int> id,
      required String name,
      Value<String> symbol,
      required int zielCent,
      Value<int> basis,
      required DateTime startDatum,
      Value<bool> angeheftet,
      Value<DateTime?> erreichtAm,
    });
typedef $$SparzielTabelleTableUpdateCompanionBuilder =
    SparzielTabelleCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> symbol,
      Value<int> zielCent,
      Value<int> basis,
      Value<DateTime> startDatum,
      Value<bool> angeheftet,
      Value<DateTime?> erreichtAm,
    });

class $$SparzielTabelleTableFilterComposer
    extends Composer<_$AppDatenbank, $SparzielTabelleTable> {
  $$SparzielTabelleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get zielCent => $composableBuilder(
    column: $table.zielCent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get basis => $composableBuilder(
    column: $table.basis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDatum => $composableBuilder(
    column: $table.startDatum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get angeheftet => $composableBuilder(
    column: $table.angeheftet,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get erreichtAm => $composableBuilder(
    column: $table.erreichtAm,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SparzielTabelleTableOrderingComposer
    extends Composer<_$AppDatenbank, $SparzielTabelleTable> {
  $$SparzielTabelleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get zielCent => $composableBuilder(
    column: $table.zielCent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get basis => $composableBuilder(
    column: $table.basis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDatum => $composableBuilder(
    column: $table.startDatum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get angeheftet => $composableBuilder(
    column: $table.angeheftet,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get erreichtAm => $composableBuilder(
    column: $table.erreichtAm,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SparzielTabelleTableAnnotationComposer
    extends Composer<_$AppDatenbank, $SparzielTabelleTable> {
  $$SparzielTabelleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<int> get zielCent =>
      $composableBuilder(column: $table.zielCent, builder: (column) => column);

  GeneratedColumn<int> get basis =>
      $composableBuilder(column: $table.basis, builder: (column) => column);

  GeneratedColumn<DateTime> get startDatum => $composableBuilder(
    column: $table.startDatum,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get angeheftet => $composableBuilder(
    column: $table.angeheftet,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get erreichtAm => $composableBuilder(
    column: $table.erreichtAm,
    builder: (column) => column,
  );
}

class $$SparzielTabelleTableTableManager
    extends
        RootTableManager<
          _$AppDatenbank,
          $SparzielTabelleTable,
          Sparziel,
          $$SparzielTabelleTableFilterComposer,
          $$SparzielTabelleTableOrderingComposer,
          $$SparzielTabelleTableAnnotationComposer,
          $$SparzielTabelleTableCreateCompanionBuilder,
          $$SparzielTabelleTableUpdateCompanionBuilder,
          (
            Sparziel,
            BaseReferences<_$AppDatenbank, $SparzielTabelleTable, Sparziel>,
          ),
          Sparziel,
          PrefetchHooks Function()
        > {
  $$SparzielTabelleTableTableManager(
    _$AppDatenbank db,
    $SparzielTabelleTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SparzielTabelleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SparzielTabelleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SparzielTabelleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> symbol = const Value.absent(),
                Value<int> zielCent = const Value.absent(),
                Value<int> basis = const Value.absent(),
                Value<DateTime> startDatum = const Value.absent(),
                Value<bool> angeheftet = const Value.absent(),
                Value<DateTime?> erreichtAm = const Value.absent(),
              }) => SparzielTabelleCompanion(
                id: id,
                name: name,
                symbol: symbol,
                zielCent: zielCent,
                basis: basis,
                startDatum: startDatum,
                angeheftet: angeheftet,
                erreichtAm: erreichtAm,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> symbol = const Value.absent(),
                required int zielCent,
                Value<int> basis = const Value.absent(),
                required DateTime startDatum,
                Value<bool> angeheftet = const Value.absent(),
                Value<DateTime?> erreichtAm = const Value.absent(),
              }) => SparzielTabelleCompanion.insert(
                id: id,
                name: name,
                symbol: symbol,
                zielCent: zielCent,
                basis: basis,
                startDatum: startDatum,
                angeheftet: angeheftet,
                erreichtAm: erreichtAm,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SparzielTabelleTable, Sparziel>(table),
                  BaseReferences<
                    _$AppDatenbank,
                    $SparzielTabelleTable,
                    Sparziel
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SparzielTabelleTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatenbank,
      $SparzielTabelleTable,
      Sparziel,
      $$SparzielTabelleTableFilterComposer,
      $$SparzielTabelleTableOrderingComposer,
      $$SparzielTabelleTableAnnotationComposer,
      $$SparzielTabelleTableCreateCompanionBuilder,
      $$SparzielTabelleTableUpdateCompanionBuilder,
      (
        Sparziel,
        BaseReferences<_$AppDatenbank, $SparzielTabelleTable, Sparziel>,
      ),
      Sparziel,
      PrefetchHooks Function()
    >;
typedef $$EinstellungenTabelleTableCreateCompanionBuilder =
    EinstellungenTabelleCompanion Function({
      Value<int> id,
      Value<double> strompreisCentProKwh,
      Value<int> standardAufschlagProzent,
      Value<int> fehldruckProzent,
      Value<int> rundungCent,
      Value<int> stundenlohnCent,
      Value<double> gebuehrKarteProzent,
      Value<double> gebuehrOnlineProzent,
      Value<int> standardZahlungsart,
    });
typedef $$EinstellungenTabelleTableUpdateCompanionBuilder =
    EinstellungenTabelleCompanion Function({
      Value<int> id,
      Value<double> strompreisCentProKwh,
      Value<int> standardAufschlagProzent,
      Value<int> fehldruckProzent,
      Value<int> rundungCent,
      Value<int> stundenlohnCent,
      Value<double> gebuehrKarteProzent,
      Value<double> gebuehrOnlineProzent,
      Value<int> standardZahlungsart,
    });

class $$EinstellungenTabelleTableFilterComposer
    extends Composer<_$AppDatenbank, $EinstellungenTabelleTable> {
  $$EinstellungenTabelleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get strompreisCentProKwh => $composableBuilder(
    column: $table.strompreisCentProKwh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get standardAufschlagProzent => $composableBuilder(
    column: $table.standardAufschlagProzent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fehldruckProzent => $composableBuilder(
    column: $table.fehldruckProzent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rundungCent => $composableBuilder(
    column: $table.rundungCent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stundenlohnCent => $composableBuilder(
    column: $table.stundenlohnCent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gebuehrKarteProzent => $composableBuilder(
    column: $table.gebuehrKarteProzent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gebuehrOnlineProzent => $composableBuilder(
    column: $table.gebuehrOnlineProzent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get standardZahlungsart => $composableBuilder(
    column: $table.standardZahlungsart,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EinstellungenTabelleTableOrderingComposer
    extends Composer<_$AppDatenbank, $EinstellungenTabelleTable> {
  $$EinstellungenTabelleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get strompreisCentProKwh => $composableBuilder(
    column: $table.strompreisCentProKwh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get standardAufschlagProzent => $composableBuilder(
    column: $table.standardAufschlagProzent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fehldruckProzent => $composableBuilder(
    column: $table.fehldruckProzent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rundungCent => $composableBuilder(
    column: $table.rundungCent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stundenlohnCent => $composableBuilder(
    column: $table.stundenlohnCent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gebuehrKarteProzent => $composableBuilder(
    column: $table.gebuehrKarteProzent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gebuehrOnlineProzent => $composableBuilder(
    column: $table.gebuehrOnlineProzent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get standardZahlungsart => $composableBuilder(
    column: $table.standardZahlungsart,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EinstellungenTabelleTableAnnotationComposer
    extends Composer<_$AppDatenbank, $EinstellungenTabelleTable> {
  $$EinstellungenTabelleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get strompreisCentProKwh => $composableBuilder(
    column: $table.strompreisCentProKwh,
    builder: (column) => column,
  );

  GeneratedColumn<int> get standardAufschlagProzent => $composableBuilder(
    column: $table.standardAufschlagProzent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fehldruckProzent => $composableBuilder(
    column: $table.fehldruckProzent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rundungCent => $composableBuilder(
    column: $table.rundungCent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stundenlohnCent => $composableBuilder(
    column: $table.stundenlohnCent,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gebuehrKarteProzent => $composableBuilder(
    column: $table.gebuehrKarteProzent,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gebuehrOnlineProzent => $composableBuilder(
    column: $table.gebuehrOnlineProzent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get standardZahlungsart => $composableBuilder(
    column: $table.standardZahlungsart,
    builder: (column) => column,
  );
}

class $$EinstellungenTabelleTableTableManager
    extends
        RootTableManager<
          _$AppDatenbank,
          $EinstellungenTabelleTable,
          Einstellungen,
          $$EinstellungenTabelleTableFilterComposer,
          $$EinstellungenTabelleTableOrderingComposer,
          $$EinstellungenTabelleTableAnnotationComposer,
          $$EinstellungenTabelleTableCreateCompanionBuilder,
          $$EinstellungenTabelleTableUpdateCompanionBuilder,
          (
            Einstellungen,
            BaseReferences<
              _$AppDatenbank,
              $EinstellungenTabelleTable,
              Einstellungen
            >,
          ),
          Einstellungen,
          PrefetchHooks Function()
        > {
  $$EinstellungenTabelleTableTableManager(
    _$AppDatenbank db,
    $EinstellungenTabelleTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EinstellungenTabelleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EinstellungenTabelleTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$EinstellungenTabelleTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> strompreisCentProKwh = const Value.absent(),
                Value<int> standardAufschlagProzent = const Value.absent(),
                Value<int> fehldruckProzent = const Value.absent(),
                Value<int> rundungCent = const Value.absent(),
                Value<int> stundenlohnCent = const Value.absent(),
                Value<double> gebuehrKarteProzent = const Value.absent(),
                Value<double> gebuehrOnlineProzent = const Value.absent(),
                Value<int> standardZahlungsart = const Value.absent(),
              }) => EinstellungenTabelleCompanion(
                id: id,
                strompreisCentProKwh: strompreisCentProKwh,
                standardAufschlagProzent: standardAufschlagProzent,
                fehldruckProzent: fehldruckProzent,
                rundungCent: rundungCent,
                stundenlohnCent: stundenlohnCent,
                gebuehrKarteProzent: gebuehrKarteProzent,
                gebuehrOnlineProzent: gebuehrOnlineProzent,
                standardZahlungsart: standardZahlungsart,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> strompreisCentProKwh = const Value.absent(),
                Value<int> standardAufschlagProzent = const Value.absent(),
                Value<int> fehldruckProzent = const Value.absent(),
                Value<int> rundungCent = const Value.absent(),
                Value<int> stundenlohnCent = const Value.absent(),
                Value<double> gebuehrKarteProzent = const Value.absent(),
                Value<double> gebuehrOnlineProzent = const Value.absent(),
                Value<int> standardZahlungsart = const Value.absent(),
              }) => EinstellungenTabelleCompanion.insert(
                id: id,
                strompreisCentProKwh: strompreisCentProKwh,
                standardAufschlagProzent: standardAufschlagProzent,
                fehldruckProzent: fehldruckProzent,
                rundungCent: rundungCent,
                stundenlohnCent: stundenlohnCent,
                gebuehrKarteProzent: gebuehrKarteProzent,
                gebuehrOnlineProzent: gebuehrOnlineProzent,
                standardZahlungsart: standardZahlungsart,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EinstellungenTabelleTable, Einstellungen>(table),
                  BaseReferences<
                    _$AppDatenbank,
                    $EinstellungenTabelleTable,
                    Einstellungen
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EinstellungenTabelleTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatenbank,
      $EinstellungenTabelleTable,
      Einstellungen,
      $$EinstellungenTabelleTableFilterComposer,
      $$EinstellungenTabelleTableOrderingComposer,
      $$EinstellungenTabelleTableAnnotationComposer,
      $$EinstellungenTabelleTableCreateCompanionBuilder,
      $$EinstellungenTabelleTableUpdateCompanionBuilder,
      (
        Einstellungen,
        BaseReferences<
          _$AppDatenbank,
          $EinstellungenTabelleTable,
          Einstellungen
        >,
      ),
      Einstellungen,
      PrefetchHooks Function()
    >;

class $AppDatenbankManager {
  final _$AppDatenbank _db;
  $AppDatenbankManager(this._db);
  $$DruckerTabelleTableTableManager get druckerTabelle =>
      $$DruckerTabelleTableTableManager(_db, _db.druckerTabelle);
  $$FilamentTabelleTableTableManager get filamentTabelle =>
      $$FilamentTabelleTableTableManager(_db, _db.filamentTabelle);
  $$ExtraTabelleTableTableManager get extraTabelle =>
      $$ExtraTabelleTableTableManager(_db, _db.extraTabelle);
  $$ProduktTabelleTableTableManager get produktTabelle =>
      $$ProduktTabelleTableTableManager(_db, _db.produktTabelle);
  $$ProduktFilamentTabelleTableTableManager get produktFilamentTabelle =>
      $$ProduktFilamentTabelleTableTableManager(
        _db,
        _db.produktFilamentTabelle,
      );
  $$ProduktExtraTabelleTableTableManager get produktExtraTabelle =>
      $$ProduktExtraTabelleTableTableManager(_db, _db.produktExtraTabelle);
  $$AuftragTabelleTableTableManager get auftragTabelle =>
      $$AuftragTabelleTableTableManager(_db, _db.auftragTabelle);
  $$VerkaufTabelleTableTableManager get verkaufTabelle =>
      $$VerkaufTabelleTableTableManager(_db, _db.verkaufTabelle);
  $$AuftragPositionTabelleTableTableManager get auftragPositionTabelle =>
      $$AuftragPositionTabelleTableTableManager(
        _db,
        _db.auftragPositionTabelle,
      );
  $$SparzielTabelleTableTableManager get sparzielTabelle =>
      $$SparzielTabelleTableTableManager(_db, _db.sparzielTabelle);
  $$EinstellungenTabelleTableTableManager get einstellungenTabelle =>
      $$EinstellungenTabelleTableTableManager(_db, _db.einstellungenTabelle);
}
