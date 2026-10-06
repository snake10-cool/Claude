// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'datenbank.dart';

// ignore_for_file: type=lint
class $StapelTabelleTable extends StapelTabelle
    with TableInfo<$StapelTabelleTable, Stapel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StapelTabelleTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _schluesselMeta = const VerificationMeta(
    'schluessel',
  );
  @override
  late final GeneratedColumn<String> schluessel = GeneratedColumn<String>(
    'schluessel',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
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
  static const VerificationMeta _spracheMeta = const VerificationMeta(
    'sprache',
  );
  @override
  late final GeneratedColumn<String> sprache = GeneratedColumn<String>(
    'sprache',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stufeMeta = const VerificationMeta('stufe');
  @override
  late final GeneratedColumn<String> stufe = GeneratedColumn<String>(
    'stufe',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _beschreibungMeta = const VerificationMeta(
    'beschreibung',
  );
  @override
  late final GeneratedColumn<String> beschreibung = GeneratedColumn<String>(
    'beschreibung',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _produktMeta = const VerificationMeta(
    'produkt',
  );
  @override
  late final GeneratedColumn<String> produkt = GeneratedColumn<String>(
    'produkt',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eigenMeta = const VerificationMeta('eigen');
  @override
  late final GeneratedColumn<bool> eigen = GeneratedColumn<bool>(
    'eigen',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("eigen" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _aktivMeta = const VerificationMeta('aktiv');
  @override
  late final GeneratedColumn<bool> aktiv = GeneratedColumn<bool>(
    'aktiv',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("aktiv" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    schluessel,
    name,
    sprache,
    stufe,
    beschreibung,
    produkt,
    eigen,
    aktiv,
    sortierung,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stapel';
  @override
  VerificationContext validateIntegrity(
    Insertable<Stapel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('schluessel')) {
      context.handle(
        _schluesselMeta,
        schluessel.isAcceptableOrUnknown(data['schluessel']!, _schluesselMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sprache')) {
      context.handle(
        _spracheMeta,
        sprache.isAcceptableOrUnknown(data['sprache']!, _spracheMeta),
      );
    } else if (isInserting) {
      context.missing(_spracheMeta);
    }
    if (data.containsKey('stufe')) {
      context.handle(
        _stufeMeta,
        stufe.isAcceptableOrUnknown(data['stufe']!, _stufeMeta),
      );
    }
    if (data.containsKey('beschreibung')) {
      context.handle(
        _beschreibungMeta,
        beschreibung.isAcceptableOrUnknown(
          data['beschreibung']!,
          _beschreibungMeta,
        ),
      );
    }
    if (data.containsKey('produkt')) {
      context.handle(
        _produktMeta,
        produkt.isAcceptableOrUnknown(data['produkt']!, _produktMeta),
      );
    }
    if (data.containsKey('eigen')) {
      context.handle(
        _eigenMeta,
        eigen.isAcceptableOrUnknown(data['eigen']!, _eigenMeta),
      );
    }
    if (data.containsKey('aktiv')) {
      context.handle(
        _aktivMeta,
        aktiv.isAcceptableOrUnknown(data['aktiv']!, _aktivMeta),
      );
    }
    if (data.containsKey('sortierung')) {
      context.handle(
        _sortierungMeta,
        sortierung.isAcceptableOrUnknown(data['sortierung']!, _sortierungMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Stapel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Stapel(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      schluessel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schluessel'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sprache: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sprache'],
      )!,
      stufe: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stufe'],
      )!,
      beschreibung: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}beschreibung'],
      )!,
      produkt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}produkt'],
      ),
      eigen: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}eigen'],
      )!,
      aktiv: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}aktiv'],
      )!,
      sortierung: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sortierung'],
      )!,
    );
  }

  @override
  $StapelTabelleTable createAlias(String alias) {
    return $StapelTabelleTable(attachedDatabase, alias);
  }
}

class Stapel extends DataClass implements Insertable<Stapel> {
  final int id;

  /// Bei eingebauten Stapeln die ID aus der JSON-Datei, sonst `null`.
  final String? schluessel;
  final String name;
  final String sprache;
  final String stufe;
  final String beschreibung;

  /// Play-Produkt, das den Stapel freischaltet; `null` = gratis.
  final String? produkt;
  final bool eigen;

  /// Kommt in „Heute lernen“ vor.
  final bool aktiv;
  final int sortierung;
  const Stapel({
    required this.id,
    this.schluessel,
    required this.name,
    required this.sprache,
    required this.stufe,
    required this.beschreibung,
    this.produkt,
    required this.eigen,
    required this.aktiv,
    required this.sortierung,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || schluessel != null) {
      map['schluessel'] = Variable<String>(schluessel);
    }
    map['name'] = Variable<String>(name);
    map['sprache'] = Variable<String>(sprache);
    map['stufe'] = Variable<String>(stufe);
    map['beschreibung'] = Variable<String>(beschreibung);
    if (!nullToAbsent || produkt != null) {
      map['produkt'] = Variable<String>(produkt);
    }
    map['eigen'] = Variable<bool>(eigen);
    map['aktiv'] = Variable<bool>(aktiv);
    map['sortierung'] = Variable<int>(sortierung);
    return map;
  }

  StapelTabelleCompanion toCompanion(bool nullToAbsent) {
    return StapelTabelleCompanion(
      id: Value(id),
      schluessel: schluessel == null && nullToAbsent
          ? const Value.absent()
          : Value(schluessel),
      name: Value(name),
      sprache: Value(sprache),
      stufe: Value(stufe),
      beschreibung: Value(beschreibung),
      produkt: produkt == null && nullToAbsent
          ? const Value.absent()
          : Value(produkt),
      eigen: Value(eigen),
      aktiv: Value(aktiv),
      sortierung: Value(sortierung),
    );
  }

  factory Stapel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Stapel(
      id: serializer.fromJson<int>(json['id']),
      schluessel: serializer.fromJson<String?>(json['schluessel']),
      name: serializer.fromJson<String>(json['name']),
      sprache: serializer.fromJson<String>(json['sprache']),
      stufe: serializer.fromJson<String>(json['stufe']),
      beschreibung: serializer.fromJson<String>(json['beschreibung']),
      produkt: serializer.fromJson<String?>(json['produkt']),
      eigen: serializer.fromJson<bool>(json['eigen']),
      aktiv: serializer.fromJson<bool>(json['aktiv']),
      sortierung: serializer.fromJson<int>(json['sortierung']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'schluessel': serializer.toJson<String?>(schluessel),
      'name': serializer.toJson<String>(name),
      'sprache': serializer.toJson<String>(sprache),
      'stufe': serializer.toJson<String>(stufe),
      'beschreibung': serializer.toJson<String>(beschreibung),
      'produkt': serializer.toJson<String?>(produkt),
      'eigen': serializer.toJson<bool>(eigen),
      'aktiv': serializer.toJson<bool>(aktiv),
      'sortierung': serializer.toJson<int>(sortierung),
    };
  }

  Stapel copyWith({
    int? id,
    Value<String?> schluessel = const Value.absent(),
    String? name,
    String? sprache,
    String? stufe,
    String? beschreibung,
    Value<String?> produkt = const Value.absent(),
    bool? eigen,
    bool? aktiv,
    int? sortierung,
  }) => Stapel(
    id: id ?? this.id,
    schluessel: schluessel.present ? schluessel.value : this.schluessel,
    name: name ?? this.name,
    sprache: sprache ?? this.sprache,
    stufe: stufe ?? this.stufe,
    beschreibung: beschreibung ?? this.beschreibung,
    produkt: produkt.present ? produkt.value : this.produkt,
    eigen: eigen ?? this.eigen,
    aktiv: aktiv ?? this.aktiv,
    sortierung: sortierung ?? this.sortierung,
  );
  Stapel copyWithCompanion(StapelTabelleCompanion data) {
    return Stapel(
      id: data.id.present ? data.id.value : this.id,
      schluessel: data.schluessel.present
          ? data.schluessel.value
          : this.schluessel,
      name: data.name.present ? data.name.value : this.name,
      sprache: data.sprache.present ? data.sprache.value : this.sprache,
      stufe: data.stufe.present ? data.stufe.value : this.stufe,
      beschreibung: data.beschreibung.present
          ? data.beschreibung.value
          : this.beschreibung,
      produkt: data.produkt.present ? data.produkt.value : this.produkt,
      eigen: data.eigen.present ? data.eigen.value : this.eigen,
      aktiv: data.aktiv.present ? data.aktiv.value : this.aktiv,
      sortierung: data.sortierung.present
          ? data.sortierung.value
          : this.sortierung,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Stapel(')
          ..write('id: $id, ')
          ..write('schluessel: $schluessel, ')
          ..write('name: $name, ')
          ..write('sprache: $sprache, ')
          ..write('stufe: $stufe, ')
          ..write('beschreibung: $beschreibung, ')
          ..write('produkt: $produkt, ')
          ..write('eigen: $eigen, ')
          ..write('aktiv: $aktiv, ')
          ..write('sortierung: $sortierung')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    schluessel,
    name,
    sprache,
    stufe,
    beschreibung,
    produkt,
    eigen,
    aktiv,
    sortierung,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Stapel &&
          other.id == this.id &&
          other.schluessel == this.schluessel &&
          other.name == this.name &&
          other.sprache == this.sprache &&
          other.stufe == this.stufe &&
          other.beschreibung == this.beschreibung &&
          other.produkt == this.produkt &&
          other.eigen == this.eigen &&
          other.aktiv == this.aktiv &&
          other.sortierung == this.sortierung);
}

class StapelTabelleCompanion extends UpdateCompanion<Stapel> {
  final Value<int> id;
  final Value<String?> schluessel;
  final Value<String> name;
  final Value<String> sprache;
  final Value<String> stufe;
  final Value<String> beschreibung;
  final Value<String?> produkt;
  final Value<bool> eigen;
  final Value<bool> aktiv;
  final Value<int> sortierung;
  const StapelTabelleCompanion({
    this.id = const Value.absent(),
    this.schluessel = const Value.absent(),
    this.name = const Value.absent(),
    this.sprache = const Value.absent(),
    this.stufe = const Value.absent(),
    this.beschreibung = const Value.absent(),
    this.produkt = const Value.absent(),
    this.eigen = const Value.absent(),
    this.aktiv = const Value.absent(),
    this.sortierung = const Value.absent(),
  });
  StapelTabelleCompanion.insert({
    this.id = const Value.absent(),
    this.schluessel = const Value.absent(),
    required String name,
    required String sprache,
    this.stufe = const Value.absent(),
    this.beschreibung = const Value.absent(),
    this.produkt = const Value.absent(),
    this.eigen = const Value.absent(),
    this.aktiv = const Value.absent(),
    this.sortierung = const Value.absent(),
  }) : name = Value(name),
       sprache = Value(sprache);
  static Insertable<Stapel> custom({
    Expression<int>? id,
    Expression<String>? schluessel,
    Expression<String>? name,
    Expression<String>? sprache,
    Expression<String>? stufe,
    Expression<String>? beschreibung,
    Expression<String>? produkt,
    Expression<bool>? eigen,
    Expression<bool>? aktiv,
    Expression<int>? sortierung,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (schluessel != null) 'schluessel': schluessel,
      if (name != null) 'name': name,
      if (sprache != null) 'sprache': sprache,
      if (stufe != null) 'stufe': stufe,
      if (beschreibung != null) 'beschreibung': beschreibung,
      if (produkt != null) 'produkt': produkt,
      if (eigen != null) 'eigen': eigen,
      if (aktiv != null) 'aktiv': aktiv,
      if (sortierung != null) 'sortierung': sortierung,
    });
  }

  StapelTabelleCompanion copyWith({
    Value<int>? id,
    Value<String?>? schluessel,
    Value<String>? name,
    Value<String>? sprache,
    Value<String>? stufe,
    Value<String>? beschreibung,
    Value<String?>? produkt,
    Value<bool>? eigen,
    Value<bool>? aktiv,
    Value<int>? sortierung,
  }) {
    return StapelTabelleCompanion(
      id: id ?? this.id,
      schluessel: schluessel ?? this.schluessel,
      name: name ?? this.name,
      sprache: sprache ?? this.sprache,
      stufe: stufe ?? this.stufe,
      beschreibung: beschreibung ?? this.beschreibung,
      produkt: produkt ?? this.produkt,
      eigen: eigen ?? this.eigen,
      aktiv: aktiv ?? this.aktiv,
      sortierung: sortierung ?? this.sortierung,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (schluessel.present) {
      map['schluessel'] = Variable<String>(schluessel.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sprache.present) {
      map['sprache'] = Variable<String>(sprache.value);
    }
    if (stufe.present) {
      map['stufe'] = Variable<String>(stufe.value);
    }
    if (beschreibung.present) {
      map['beschreibung'] = Variable<String>(beschreibung.value);
    }
    if (produkt.present) {
      map['produkt'] = Variable<String>(produkt.value);
    }
    if (eigen.present) {
      map['eigen'] = Variable<bool>(eigen.value);
    }
    if (aktiv.present) {
      map['aktiv'] = Variable<bool>(aktiv.value);
    }
    if (sortierung.present) {
      map['sortierung'] = Variable<int>(sortierung.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StapelTabelleCompanion(')
          ..write('id: $id, ')
          ..write('schluessel: $schluessel, ')
          ..write('name: $name, ')
          ..write('sprache: $sprache, ')
          ..write('stufe: $stufe, ')
          ..write('beschreibung: $beschreibung, ')
          ..write('produkt: $produkt, ')
          ..write('eigen: $eigen, ')
          ..write('aktiv: $aktiv, ')
          ..write('sortierung: $sortierung')
          ..write(')'))
        .toString();
  }
}

class $KarteTabelleTable extends KarteTabelle
    with TableInfo<$KarteTabelleTable, Karte> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KarteTabelleTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _stapelIdMeta = const VerificationMeta(
    'stapelId',
  );
  @override
  late final GeneratedColumn<int> stapelId = GeneratedColumn<int>(
    'stapel_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES stapel (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _schluesselMeta = const VerificationMeta(
    'schluessel',
  );
  @override
  late final GeneratedColumn<String> schluessel = GeneratedColumn<String>(
    'schluessel',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _typMeta = const VerificationMeta('typ');
  @override
  late final GeneratedColumn<String> typ = GeneratedColumn<String>(
    'typ',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _frageMeta = const VerificationMeta('frage');
  @override
  late final GeneratedColumn<String> frage = GeneratedColumn<String>(
    'frage',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _antwortMeta = const VerificationMeta(
    'antwort',
  );
  @override
  late final GeneratedColumn<String> antwort = GeneratedColumn<String>(
    'antwort',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _optionenMeta = const VerificationMeta(
    'optionen',
  );
  @override
  late final GeneratedColumn<String> optionen = GeneratedColumn<String>(
    'optionen',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _erklaerungMeta = const VerificationMeta(
    'erklaerung',
  );
  @override
  late final GeneratedColumn<String> erklaerung = GeneratedColumn<String>(
    'erklaerung',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _reihenfolgeMeta = const VerificationMeta(
    'reihenfolge',
  );
  @override
  late final GeneratedColumn<int> reihenfolge = GeneratedColumn<int>(
    'reihenfolge',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    stapelId,
    schluessel,
    typ,
    frage,
    antwort,
    code,
    optionen,
    erklaerung,
    reihenfolge,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'karten';
  @override
  VerificationContext validateIntegrity(
    Insertable<Karte> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('stapel_id')) {
      context.handle(
        _stapelIdMeta,
        stapelId.isAcceptableOrUnknown(data['stapel_id']!, _stapelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_stapelIdMeta);
    }
    if (data.containsKey('schluessel')) {
      context.handle(
        _schluesselMeta,
        schluessel.isAcceptableOrUnknown(data['schluessel']!, _schluesselMeta),
      );
    }
    if (data.containsKey('typ')) {
      context.handle(
        _typMeta,
        typ.isAcceptableOrUnknown(data['typ']!, _typMeta),
      );
    } else if (isInserting) {
      context.missing(_typMeta);
    }
    if (data.containsKey('frage')) {
      context.handle(
        _frageMeta,
        frage.isAcceptableOrUnknown(data['frage']!, _frageMeta),
      );
    } else if (isInserting) {
      context.missing(_frageMeta);
    }
    if (data.containsKey('antwort')) {
      context.handle(
        _antwortMeta,
        antwort.isAcceptableOrUnknown(data['antwort']!, _antwortMeta),
      );
    } else if (isInserting) {
      context.missing(_antwortMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    if (data.containsKey('optionen')) {
      context.handle(
        _optionenMeta,
        optionen.isAcceptableOrUnknown(data['optionen']!, _optionenMeta),
      );
    }
    if (data.containsKey('erklaerung')) {
      context.handle(
        _erklaerungMeta,
        erklaerung.isAcceptableOrUnknown(data['erklaerung']!, _erklaerungMeta),
      );
    }
    if (data.containsKey('reihenfolge')) {
      context.handle(
        _reihenfolgeMeta,
        reihenfolge.isAcceptableOrUnknown(
          data['reihenfolge']!,
          _reihenfolgeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Karte map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Karte(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      stapelId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stapel_id'],
      )!,
      schluessel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schluessel'],
      ),
      typ: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}typ'],
      )!,
      frage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frage'],
      )!,
      antwort: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}antwort'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      ),
      optionen: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}optionen'],
      )!,
      erklaerung: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}erklaerung'],
      )!,
      reihenfolge: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reihenfolge'],
      )!,
    );
  }

  @override
  $KarteTabelleTable createAlias(String alias) {
    return $KarteTabelleTable(attachedDatabase, alias);
  }
}

class Karte extends DataClass implements Insertable<Karte> {
  final int id;
  final int stapelId;

  /// Bei eingebauten Karten der Key aus der JSON-Datei.
  final String? schluessel;

  /// Name von `KartenTyp`.
  final String typ;
  final String frage;
  final String antwort;
  final String? code;

  /// Auswahlmöglichkeiten als JSON-Liste.
  final String optionen;
  final String erklaerung;
  final int reihenfolge;
  const Karte({
    required this.id,
    required this.stapelId,
    this.schluessel,
    required this.typ,
    required this.frage,
    required this.antwort,
    this.code,
    required this.optionen,
    required this.erklaerung,
    required this.reihenfolge,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['stapel_id'] = Variable<int>(stapelId);
    if (!nullToAbsent || schluessel != null) {
      map['schluessel'] = Variable<String>(schluessel);
    }
    map['typ'] = Variable<String>(typ);
    map['frage'] = Variable<String>(frage);
    map['antwort'] = Variable<String>(antwort);
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    map['optionen'] = Variable<String>(optionen);
    map['erklaerung'] = Variable<String>(erklaerung);
    map['reihenfolge'] = Variable<int>(reihenfolge);
    return map;
  }

  KarteTabelleCompanion toCompanion(bool nullToAbsent) {
    return KarteTabelleCompanion(
      id: Value(id),
      stapelId: Value(stapelId),
      schluessel: schluessel == null && nullToAbsent
          ? const Value.absent()
          : Value(schluessel),
      typ: Value(typ),
      frage: Value(frage),
      antwort: Value(antwort),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
      optionen: Value(optionen),
      erklaerung: Value(erklaerung),
      reihenfolge: Value(reihenfolge),
    );
  }

  factory Karte.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Karte(
      id: serializer.fromJson<int>(json['id']),
      stapelId: serializer.fromJson<int>(json['stapelId']),
      schluessel: serializer.fromJson<String?>(json['schluessel']),
      typ: serializer.fromJson<String>(json['typ']),
      frage: serializer.fromJson<String>(json['frage']),
      antwort: serializer.fromJson<String>(json['antwort']),
      code: serializer.fromJson<String?>(json['code']),
      optionen: serializer.fromJson<String>(json['optionen']),
      erklaerung: serializer.fromJson<String>(json['erklaerung']),
      reihenfolge: serializer.fromJson<int>(json['reihenfolge']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'stapelId': serializer.toJson<int>(stapelId),
      'schluessel': serializer.toJson<String?>(schluessel),
      'typ': serializer.toJson<String>(typ),
      'frage': serializer.toJson<String>(frage),
      'antwort': serializer.toJson<String>(antwort),
      'code': serializer.toJson<String?>(code),
      'optionen': serializer.toJson<String>(optionen),
      'erklaerung': serializer.toJson<String>(erklaerung),
      'reihenfolge': serializer.toJson<int>(reihenfolge),
    };
  }

  Karte copyWith({
    int? id,
    int? stapelId,
    Value<String?> schluessel = const Value.absent(),
    String? typ,
    String? frage,
    String? antwort,
    Value<String?> code = const Value.absent(),
    String? optionen,
    String? erklaerung,
    int? reihenfolge,
  }) => Karte(
    id: id ?? this.id,
    stapelId: stapelId ?? this.stapelId,
    schluessel: schluessel.present ? schluessel.value : this.schluessel,
    typ: typ ?? this.typ,
    frage: frage ?? this.frage,
    antwort: antwort ?? this.antwort,
    code: code.present ? code.value : this.code,
    optionen: optionen ?? this.optionen,
    erklaerung: erklaerung ?? this.erklaerung,
    reihenfolge: reihenfolge ?? this.reihenfolge,
  );
  Karte copyWithCompanion(KarteTabelleCompanion data) {
    return Karte(
      id: data.id.present ? data.id.value : this.id,
      stapelId: data.stapelId.present ? data.stapelId.value : this.stapelId,
      schluessel: data.schluessel.present
          ? data.schluessel.value
          : this.schluessel,
      typ: data.typ.present ? data.typ.value : this.typ,
      frage: data.frage.present ? data.frage.value : this.frage,
      antwort: data.antwort.present ? data.antwort.value : this.antwort,
      code: data.code.present ? data.code.value : this.code,
      optionen: data.optionen.present ? data.optionen.value : this.optionen,
      erklaerung: data.erklaerung.present
          ? data.erklaerung.value
          : this.erklaerung,
      reihenfolge: data.reihenfolge.present
          ? data.reihenfolge.value
          : this.reihenfolge,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Karte(')
          ..write('id: $id, ')
          ..write('stapelId: $stapelId, ')
          ..write('schluessel: $schluessel, ')
          ..write('typ: $typ, ')
          ..write('frage: $frage, ')
          ..write('antwort: $antwort, ')
          ..write('code: $code, ')
          ..write('optionen: $optionen, ')
          ..write('erklaerung: $erklaerung, ')
          ..write('reihenfolge: $reihenfolge')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    stapelId,
    schluessel,
    typ,
    frage,
    antwort,
    code,
    optionen,
    erklaerung,
    reihenfolge,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Karte &&
          other.id == this.id &&
          other.stapelId == this.stapelId &&
          other.schluessel == this.schluessel &&
          other.typ == this.typ &&
          other.frage == this.frage &&
          other.antwort == this.antwort &&
          other.code == this.code &&
          other.optionen == this.optionen &&
          other.erklaerung == this.erklaerung &&
          other.reihenfolge == this.reihenfolge);
}

class KarteTabelleCompanion extends UpdateCompanion<Karte> {
  final Value<int> id;
  final Value<int> stapelId;
  final Value<String?> schluessel;
  final Value<String> typ;
  final Value<String> frage;
  final Value<String> antwort;
  final Value<String?> code;
  final Value<String> optionen;
  final Value<String> erklaerung;
  final Value<int> reihenfolge;
  const KarteTabelleCompanion({
    this.id = const Value.absent(),
    this.stapelId = const Value.absent(),
    this.schluessel = const Value.absent(),
    this.typ = const Value.absent(),
    this.frage = const Value.absent(),
    this.antwort = const Value.absent(),
    this.code = const Value.absent(),
    this.optionen = const Value.absent(),
    this.erklaerung = const Value.absent(),
    this.reihenfolge = const Value.absent(),
  });
  KarteTabelleCompanion.insert({
    this.id = const Value.absent(),
    required int stapelId,
    this.schluessel = const Value.absent(),
    required String typ,
    required String frage,
    required String antwort,
    this.code = const Value.absent(),
    this.optionen = const Value.absent(),
    this.erklaerung = const Value.absent(),
    this.reihenfolge = const Value.absent(),
  }) : stapelId = Value(stapelId),
       typ = Value(typ),
       frage = Value(frage),
       antwort = Value(antwort);
  static Insertable<Karte> custom({
    Expression<int>? id,
    Expression<int>? stapelId,
    Expression<String>? schluessel,
    Expression<String>? typ,
    Expression<String>? frage,
    Expression<String>? antwort,
    Expression<String>? code,
    Expression<String>? optionen,
    Expression<String>? erklaerung,
    Expression<int>? reihenfolge,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (stapelId != null) 'stapel_id': stapelId,
      if (schluessel != null) 'schluessel': schluessel,
      if (typ != null) 'typ': typ,
      if (frage != null) 'frage': frage,
      if (antwort != null) 'antwort': antwort,
      if (code != null) 'code': code,
      if (optionen != null) 'optionen': optionen,
      if (erklaerung != null) 'erklaerung': erklaerung,
      if (reihenfolge != null) 'reihenfolge': reihenfolge,
    });
  }

  KarteTabelleCompanion copyWith({
    Value<int>? id,
    Value<int>? stapelId,
    Value<String?>? schluessel,
    Value<String>? typ,
    Value<String>? frage,
    Value<String>? antwort,
    Value<String?>? code,
    Value<String>? optionen,
    Value<String>? erklaerung,
    Value<int>? reihenfolge,
  }) {
    return KarteTabelleCompanion(
      id: id ?? this.id,
      stapelId: stapelId ?? this.stapelId,
      schluessel: schluessel ?? this.schluessel,
      typ: typ ?? this.typ,
      frage: frage ?? this.frage,
      antwort: antwort ?? this.antwort,
      code: code ?? this.code,
      optionen: optionen ?? this.optionen,
      erklaerung: erklaerung ?? this.erklaerung,
      reihenfolge: reihenfolge ?? this.reihenfolge,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (stapelId.present) {
      map['stapel_id'] = Variable<int>(stapelId.value);
    }
    if (schluessel.present) {
      map['schluessel'] = Variable<String>(schluessel.value);
    }
    if (typ.present) {
      map['typ'] = Variable<String>(typ.value);
    }
    if (frage.present) {
      map['frage'] = Variable<String>(frage.value);
    }
    if (antwort.present) {
      map['antwort'] = Variable<String>(antwort.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (optionen.present) {
      map['optionen'] = Variable<String>(optionen.value);
    }
    if (erklaerung.present) {
      map['erklaerung'] = Variable<String>(erklaerung.value);
    }
    if (reihenfolge.present) {
      map['reihenfolge'] = Variable<int>(reihenfolge.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KarteTabelleCompanion(')
          ..write('id: $id, ')
          ..write('stapelId: $stapelId, ')
          ..write('schluessel: $schluessel, ')
          ..write('typ: $typ, ')
          ..write('frage: $frage, ')
          ..write('antwort: $antwort, ')
          ..write('code: $code, ')
          ..write('optionen: $optionen, ')
          ..write('erklaerung: $erklaerung, ')
          ..write('reihenfolge: $reihenfolge')
          ..write(')'))
        .toString();
  }
}

class $LernstandTabelleTable extends LernstandTabelle
    with TableInfo<$LernstandTabelleTable, LernstandZeile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LernstandTabelleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _karteIdMeta = const VerificationMeta(
    'karteId',
  );
  @override
  late final GeneratedColumn<int> karteId = GeneratedColumn<int>(
    'karte_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES karten (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _wiederholungenMeta = const VerificationMeta(
    'wiederholungen',
  );
  @override
  late final GeneratedColumn<int> wiederholungen = GeneratedColumn<int>(
    'wiederholungen',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _leichtigkeitMeta = const VerificationMeta(
    'leichtigkeit',
  );
  @override
  late final GeneratedColumn<double> leichtigkeit = GeneratedColumn<double>(
    'leichtigkeit',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intervallTageMeta = const VerificationMeta(
    'intervallTage',
  );
  @override
  late final GeneratedColumn<int> intervallTage = GeneratedColumn<int>(
    'intervall_tage',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _faelligMeta = const VerificationMeta(
    'faellig',
  );
  @override
  late final GeneratedColumn<DateTime> faellig = GeneratedColumn<DateTime>(
    'faellig',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fehlerMeta = const VerificationMeta('fehler');
  @override
  late final GeneratedColumn<int> fehler = GeneratedColumn<int>(
    'fehler',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _zuletztMeta = const VerificationMeta(
    'zuletzt',
  );
  @override
  late final GeneratedColumn<DateTime> zuletzt = GeneratedColumn<DateTime>(
    'zuletzt',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    karteId,
    wiederholungen,
    leichtigkeit,
    intervallTage,
    faellig,
    fehler,
    zuletzt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lernstand';
  @override
  VerificationContext validateIntegrity(
    Insertable<LernstandZeile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('karte_id')) {
      context.handle(
        _karteIdMeta,
        karteId.isAcceptableOrUnknown(data['karte_id']!, _karteIdMeta),
      );
    }
    if (data.containsKey('wiederholungen')) {
      context.handle(
        _wiederholungenMeta,
        wiederholungen.isAcceptableOrUnknown(
          data['wiederholungen']!,
          _wiederholungenMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_wiederholungenMeta);
    }
    if (data.containsKey('leichtigkeit')) {
      context.handle(
        _leichtigkeitMeta,
        leichtigkeit.isAcceptableOrUnknown(
          data['leichtigkeit']!,
          _leichtigkeitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_leichtigkeitMeta);
    }
    if (data.containsKey('intervall_tage')) {
      context.handle(
        _intervallTageMeta,
        intervallTage.isAcceptableOrUnknown(
          data['intervall_tage']!,
          _intervallTageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_intervallTageMeta);
    }
    if (data.containsKey('faellig')) {
      context.handle(
        _faelligMeta,
        faellig.isAcceptableOrUnknown(data['faellig']!, _faelligMeta),
      );
    } else if (isInserting) {
      context.missing(_faelligMeta);
    }
    if (data.containsKey('fehler')) {
      context.handle(
        _fehlerMeta,
        fehler.isAcceptableOrUnknown(data['fehler']!, _fehlerMeta),
      );
    }
    if (data.containsKey('zuletzt')) {
      context.handle(
        _zuletztMeta,
        zuletzt.isAcceptableOrUnknown(data['zuletzt']!, _zuletztMeta),
      );
    } else if (isInserting) {
      context.missing(_zuletztMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {karteId};
  @override
  LernstandZeile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LernstandZeile(
      karteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}karte_id'],
      )!,
      wiederholungen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wiederholungen'],
      )!,
      leichtigkeit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}leichtigkeit'],
      )!,
      intervallTage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}intervall_tage'],
      )!,
      faellig: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}faellig'],
      )!,
      fehler: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fehler'],
      )!,
      zuletzt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}zuletzt'],
      )!,
    );
  }

  @override
  $LernstandTabelleTable createAlias(String alias) {
    return $LernstandTabelleTable(attachedDatabase, alias);
  }
}

class LernstandZeile extends DataClass implements Insertable<LernstandZeile> {
  final int karteId;
  final int wiederholungen;
  final double leichtigkeit;
  final int intervallTage;
  final DateTime faellig;
  final int fehler;
  final DateTime zuletzt;
  const LernstandZeile({
    required this.karteId,
    required this.wiederholungen,
    required this.leichtigkeit,
    required this.intervallTage,
    required this.faellig,
    required this.fehler,
    required this.zuletzt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['karte_id'] = Variable<int>(karteId);
    map['wiederholungen'] = Variable<int>(wiederholungen);
    map['leichtigkeit'] = Variable<double>(leichtigkeit);
    map['intervall_tage'] = Variable<int>(intervallTage);
    map['faellig'] = Variable<DateTime>(faellig);
    map['fehler'] = Variable<int>(fehler);
    map['zuletzt'] = Variable<DateTime>(zuletzt);
    return map;
  }

  LernstandTabelleCompanion toCompanion(bool nullToAbsent) {
    return LernstandTabelleCompanion(
      karteId: Value(karteId),
      wiederholungen: Value(wiederholungen),
      leichtigkeit: Value(leichtigkeit),
      intervallTage: Value(intervallTage),
      faellig: Value(faellig),
      fehler: Value(fehler),
      zuletzt: Value(zuletzt),
    );
  }

  factory LernstandZeile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LernstandZeile(
      karteId: serializer.fromJson<int>(json['karteId']),
      wiederholungen: serializer.fromJson<int>(json['wiederholungen']),
      leichtigkeit: serializer.fromJson<double>(json['leichtigkeit']),
      intervallTage: serializer.fromJson<int>(json['intervallTage']),
      faellig: serializer.fromJson<DateTime>(json['faellig']),
      fehler: serializer.fromJson<int>(json['fehler']),
      zuletzt: serializer.fromJson<DateTime>(json['zuletzt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'karteId': serializer.toJson<int>(karteId),
      'wiederholungen': serializer.toJson<int>(wiederholungen),
      'leichtigkeit': serializer.toJson<double>(leichtigkeit),
      'intervallTage': serializer.toJson<int>(intervallTage),
      'faellig': serializer.toJson<DateTime>(faellig),
      'fehler': serializer.toJson<int>(fehler),
      'zuletzt': serializer.toJson<DateTime>(zuletzt),
    };
  }

  LernstandZeile copyWith({
    int? karteId,
    int? wiederholungen,
    double? leichtigkeit,
    int? intervallTage,
    DateTime? faellig,
    int? fehler,
    DateTime? zuletzt,
  }) => LernstandZeile(
    karteId: karteId ?? this.karteId,
    wiederholungen: wiederholungen ?? this.wiederholungen,
    leichtigkeit: leichtigkeit ?? this.leichtigkeit,
    intervallTage: intervallTage ?? this.intervallTage,
    faellig: faellig ?? this.faellig,
    fehler: fehler ?? this.fehler,
    zuletzt: zuletzt ?? this.zuletzt,
  );
  LernstandZeile copyWithCompanion(LernstandTabelleCompanion data) {
    return LernstandZeile(
      karteId: data.karteId.present ? data.karteId.value : this.karteId,
      wiederholungen: data.wiederholungen.present
          ? data.wiederholungen.value
          : this.wiederholungen,
      leichtigkeit: data.leichtigkeit.present
          ? data.leichtigkeit.value
          : this.leichtigkeit,
      intervallTage: data.intervallTage.present
          ? data.intervallTage.value
          : this.intervallTage,
      faellig: data.faellig.present ? data.faellig.value : this.faellig,
      fehler: data.fehler.present ? data.fehler.value : this.fehler,
      zuletzt: data.zuletzt.present ? data.zuletzt.value : this.zuletzt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LernstandZeile(')
          ..write('karteId: $karteId, ')
          ..write('wiederholungen: $wiederholungen, ')
          ..write('leichtigkeit: $leichtigkeit, ')
          ..write('intervallTage: $intervallTage, ')
          ..write('faellig: $faellig, ')
          ..write('fehler: $fehler, ')
          ..write('zuletzt: $zuletzt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    karteId,
    wiederholungen,
    leichtigkeit,
    intervallTage,
    faellig,
    fehler,
    zuletzt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LernstandZeile &&
          other.karteId == this.karteId &&
          other.wiederholungen == this.wiederholungen &&
          other.leichtigkeit == this.leichtigkeit &&
          other.intervallTage == this.intervallTage &&
          other.faellig == this.faellig &&
          other.fehler == this.fehler &&
          other.zuletzt == this.zuletzt);
}

class LernstandTabelleCompanion extends UpdateCompanion<LernstandZeile> {
  final Value<int> karteId;
  final Value<int> wiederholungen;
  final Value<double> leichtigkeit;
  final Value<int> intervallTage;
  final Value<DateTime> faellig;
  final Value<int> fehler;
  final Value<DateTime> zuletzt;
  const LernstandTabelleCompanion({
    this.karteId = const Value.absent(),
    this.wiederholungen = const Value.absent(),
    this.leichtigkeit = const Value.absent(),
    this.intervallTage = const Value.absent(),
    this.faellig = const Value.absent(),
    this.fehler = const Value.absent(),
    this.zuletzt = const Value.absent(),
  });
  LernstandTabelleCompanion.insert({
    this.karteId = const Value.absent(),
    required int wiederholungen,
    required double leichtigkeit,
    required int intervallTage,
    required DateTime faellig,
    this.fehler = const Value.absent(),
    required DateTime zuletzt,
  }) : wiederholungen = Value(wiederholungen),
       leichtigkeit = Value(leichtigkeit),
       intervallTage = Value(intervallTage),
       faellig = Value(faellig),
       zuletzt = Value(zuletzt);
  static Insertable<LernstandZeile> custom({
    Expression<int>? karteId,
    Expression<int>? wiederholungen,
    Expression<double>? leichtigkeit,
    Expression<int>? intervallTage,
    Expression<DateTime>? faellig,
    Expression<int>? fehler,
    Expression<DateTime>? zuletzt,
  }) {
    return RawValuesInsertable({
      if (karteId != null) 'karte_id': karteId,
      if (wiederholungen != null) 'wiederholungen': wiederholungen,
      if (leichtigkeit != null) 'leichtigkeit': leichtigkeit,
      if (intervallTage != null) 'intervall_tage': intervallTage,
      if (faellig != null) 'faellig': faellig,
      if (fehler != null) 'fehler': fehler,
      if (zuletzt != null) 'zuletzt': zuletzt,
    });
  }

  LernstandTabelleCompanion copyWith({
    Value<int>? karteId,
    Value<int>? wiederholungen,
    Value<double>? leichtigkeit,
    Value<int>? intervallTage,
    Value<DateTime>? faellig,
    Value<int>? fehler,
    Value<DateTime>? zuletzt,
  }) {
    return LernstandTabelleCompanion(
      karteId: karteId ?? this.karteId,
      wiederholungen: wiederholungen ?? this.wiederholungen,
      leichtigkeit: leichtigkeit ?? this.leichtigkeit,
      intervallTage: intervallTage ?? this.intervallTage,
      faellig: faellig ?? this.faellig,
      fehler: fehler ?? this.fehler,
      zuletzt: zuletzt ?? this.zuletzt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (karteId.present) {
      map['karte_id'] = Variable<int>(karteId.value);
    }
    if (wiederholungen.present) {
      map['wiederholungen'] = Variable<int>(wiederholungen.value);
    }
    if (leichtigkeit.present) {
      map['leichtigkeit'] = Variable<double>(leichtigkeit.value);
    }
    if (intervallTage.present) {
      map['intervall_tage'] = Variable<int>(intervallTage.value);
    }
    if (faellig.present) {
      map['faellig'] = Variable<DateTime>(faellig.value);
    }
    if (fehler.present) {
      map['fehler'] = Variable<int>(fehler.value);
    }
    if (zuletzt.present) {
      map['zuletzt'] = Variable<DateTime>(zuletzt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LernstandTabelleCompanion(')
          ..write('karteId: $karteId, ')
          ..write('wiederholungen: $wiederholungen, ')
          ..write('leichtigkeit: $leichtigkeit, ')
          ..write('intervallTage: $intervallTage, ')
          ..write('faellig: $faellig, ')
          ..write('fehler: $fehler, ')
          ..write('zuletzt: $zuletzt')
          ..write(')'))
        .toString();
  }
}

class $LerntagTabelleTable extends LerntagTabelle
    with TableInfo<$LerntagTabelleTable, Lerntag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LerntagTabelleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _datumMeta = const VerificationMeta('datum');
  @override
  late final GeneratedColumn<DateTime> datum = GeneratedColumn<DateTime>(
    'datum',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kartenMeta = const VerificationMeta('karten');
  @override
  late final GeneratedColumn<int> karten = GeneratedColumn<int>(
    'karten',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _richtigMeta = const VerificationMeta(
    'richtig',
  );
  @override
  late final GeneratedColumn<int> richtig = GeneratedColumn<int>(
    'richtig',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _neuMeta = const VerificationMeta('neu');
  @override
  late final GeneratedColumn<int> neu = GeneratedColumn<int>(
    'neu',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [datum, karten, richtig, neu];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lerntage';
  @override
  VerificationContext validateIntegrity(
    Insertable<Lerntag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('datum')) {
      context.handle(
        _datumMeta,
        datum.isAcceptableOrUnknown(data['datum']!, _datumMeta),
      );
    } else if (isInserting) {
      context.missing(_datumMeta);
    }
    if (data.containsKey('karten')) {
      context.handle(
        _kartenMeta,
        karten.isAcceptableOrUnknown(data['karten']!, _kartenMeta),
      );
    }
    if (data.containsKey('richtig')) {
      context.handle(
        _richtigMeta,
        richtig.isAcceptableOrUnknown(data['richtig']!, _richtigMeta),
      );
    }
    if (data.containsKey('neu')) {
      context.handle(
        _neuMeta,
        neu.isAcceptableOrUnknown(data['neu']!, _neuMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {datum};
  @override
  Lerntag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Lerntag(
      datum: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}datum'],
      )!,
      karten: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}karten'],
      )!,
      richtig: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}richtig'],
      )!,
      neu: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}neu'],
      )!,
    );
  }

  @override
  $LerntagTabelleTable createAlias(String alias) {
    return $LerntagTabelleTable(attachedDatabase, alias);
  }
}

class Lerntag extends DataClass implements Insertable<Lerntag> {
  final DateTime datum;
  final int karten;
  final int richtig;
  final int neu;
  const Lerntag({
    required this.datum,
    required this.karten,
    required this.richtig,
    required this.neu,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['datum'] = Variable<DateTime>(datum);
    map['karten'] = Variable<int>(karten);
    map['richtig'] = Variable<int>(richtig);
    map['neu'] = Variable<int>(neu);
    return map;
  }

  LerntagTabelleCompanion toCompanion(bool nullToAbsent) {
    return LerntagTabelleCompanion(
      datum: Value(datum),
      karten: Value(karten),
      richtig: Value(richtig),
      neu: Value(neu),
    );
  }

  factory Lerntag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Lerntag(
      datum: serializer.fromJson<DateTime>(json['datum']),
      karten: serializer.fromJson<int>(json['karten']),
      richtig: serializer.fromJson<int>(json['richtig']),
      neu: serializer.fromJson<int>(json['neu']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'datum': serializer.toJson<DateTime>(datum),
      'karten': serializer.toJson<int>(karten),
      'richtig': serializer.toJson<int>(richtig),
      'neu': serializer.toJson<int>(neu),
    };
  }

  Lerntag copyWith({DateTime? datum, int? karten, int? richtig, int? neu}) =>
      Lerntag(
        datum: datum ?? this.datum,
        karten: karten ?? this.karten,
        richtig: richtig ?? this.richtig,
        neu: neu ?? this.neu,
      );
  Lerntag copyWithCompanion(LerntagTabelleCompanion data) {
    return Lerntag(
      datum: data.datum.present ? data.datum.value : this.datum,
      karten: data.karten.present ? data.karten.value : this.karten,
      richtig: data.richtig.present ? data.richtig.value : this.richtig,
      neu: data.neu.present ? data.neu.value : this.neu,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Lerntag(')
          ..write('datum: $datum, ')
          ..write('karten: $karten, ')
          ..write('richtig: $richtig, ')
          ..write('neu: $neu')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(datum, karten, richtig, neu);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Lerntag &&
          other.datum == this.datum &&
          other.karten == this.karten &&
          other.richtig == this.richtig &&
          other.neu == this.neu);
}

class LerntagTabelleCompanion extends UpdateCompanion<Lerntag> {
  final Value<DateTime> datum;
  final Value<int> karten;
  final Value<int> richtig;
  final Value<int> neu;
  final Value<int> rowid;
  const LerntagTabelleCompanion({
    this.datum = const Value.absent(),
    this.karten = const Value.absent(),
    this.richtig = const Value.absent(),
    this.neu = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LerntagTabelleCompanion.insert({
    required DateTime datum,
    this.karten = const Value.absent(),
    this.richtig = const Value.absent(),
    this.neu = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : datum = Value(datum);
  static Insertable<Lerntag> custom({
    Expression<DateTime>? datum,
    Expression<int>? karten,
    Expression<int>? richtig,
    Expression<int>? neu,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (datum != null) 'datum': datum,
      if (karten != null) 'karten': karten,
      if (richtig != null) 'richtig': richtig,
      if (neu != null) 'neu': neu,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LerntagTabelleCompanion copyWith({
    Value<DateTime>? datum,
    Value<int>? karten,
    Value<int>? richtig,
    Value<int>? neu,
    Value<int>? rowid,
  }) {
    return LerntagTabelleCompanion(
      datum: datum ?? this.datum,
      karten: karten ?? this.karten,
      richtig: richtig ?? this.richtig,
      neu: neu ?? this.neu,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (datum.present) {
      map['datum'] = Variable<DateTime>(datum.value);
    }
    if (karten.present) {
      map['karten'] = Variable<int>(karten.value);
    }
    if (richtig.present) {
      map['richtig'] = Variable<int>(richtig.value);
    }
    if (neu.present) {
      map['neu'] = Variable<int>(neu.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LerntagTabelleCompanion(')
          ..write('datum: $datum, ')
          ..write('karten: $karten, ')
          ..write('richtig: $richtig, ')
          ..write('neu: $neu, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SnippetTabelleTable extends SnippetTabelle
    with TableInfo<$SnippetTabelleTable, Snippet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SnippetTabelleTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _titelMeta = const VerificationMeta('titel');
  @override
  late final GeneratedColumn<String> titel = GeneratedColumn<String>(
    'titel',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spracheMeta = const VerificationMeta(
    'sprache',
  );
  @override
  late final GeneratedColumn<String> sprache = GeneratedColumn<String>(
    'sprache',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
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
  static const VerificationMeta _favoritMeta = const VerificationMeta(
    'favorit',
  );
  @override
  late final GeneratedColumn<bool> favorit = GeneratedColumn<bool>(
    'favorit',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("favorit" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _erstelltMeta = const VerificationMeta(
    'erstellt',
  );
  @override
  late final GeneratedColumn<DateTime> erstellt = GeneratedColumn<DateTime>(
    'erstellt',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _geaendertMeta = const VerificationMeta(
    'geaendert',
  );
  @override
  late final GeneratedColumn<DateTime> geaendert = GeneratedColumn<DateTime>(
    'geaendert',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    titel,
    sprache,
    code,
    tags,
    notiz,
    favorit,
    erstellt,
    geaendert,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'snippets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Snippet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('titel')) {
      context.handle(
        _titelMeta,
        titel.isAcceptableOrUnknown(data['titel']!, _titelMeta),
      );
    } else if (isInserting) {
      context.missing(_titelMeta);
    }
    if (data.containsKey('sprache')) {
      context.handle(
        _spracheMeta,
        sprache.isAcceptableOrUnknown(data['sprache']!, _spracheMeta),
      );
    } else if (isInserting) {
      context.missing(_spracheMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('notiz')) {
      context.handle(
        _notizMeta,
        notiz.isAcceptableOrUnknown(data['notiz']!, _notizMeta),
      );
    }
    if (data.containsKey('favorit')) {
      context.handle(
        _favoritMeta,
        favorit.isAcceptableOrUnknown(data['favorit']!, _favoritMeta),
      );
    }
    if (data.containsKey('erstellt')) {
      context.handle(
        _erstelltMeta,
        erstellt.isAcceptableOrUnknown(data['erstellt']!, _erstelltMeta),
      );
    } else if (isInserting) {
      context.missing(_erstelltMeta);
    }
    if (data.containsKey('geaendert')) {
      context.handle(
        _geaendertMeta,
        geaendert.isAcceptableOrUnknown(data['geaendert']!, _geaendertMeta),
      );
    } else if (isInserting) {
      context.missing(_geaendertMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Snippet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Snippet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      titel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}titel'],
      )!,
      sprache: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sprache'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      )!,
      notiz: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notiz'],
      )!,
      favorit: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}favorit'],
      )!,
      erstellt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}erstellt'],
      )!,
      geaendert: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}geaendert'],
      )!,
    );
  }

  @override
  $SnippetTabelleTable createAlias(String alias) {
    return $SnippetTabelleTable(attachedDatabase, alias);
  }
}

class Snippet extends DataClass implements Insertable<Snippet> {
  final int id;
  final String titel;
  final String sprache;
  final String code;

  /// Mit Komma getrennt, klein geschrieben.
  final String tags;
  final String notiz;
  final bool favorit;
  final DateTime erstellt;
  final DateTime geaendert;
  const Snippet({
    required this.id,
    required this.titel,
    required this.sprache,
    required this.code,
    required this.tags,
    required this.notiz,
    required this.favorit,
    required this.erstellt,
    required this.geaendert,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['titel'] = Variable<String>(titel);
    map['sprache'] = Variable<String>(sprache);
    map['code'] = Variable<String>(code);
    map['tags'] = Variable<String>(tags);
    map['notiz'] = Variable<String>(notiz);
    map['favorit'] = Variable<bool>(favorit);
    map['erstellt'] = Variable<DateTime>(erstellt);
    map['geaendert'] = Variable<DateTime>(geaendert);
    return map;
  }

  SnippetTabelleCompanion toCompanion(bool nullToAbsent) {
    return SnippetTabelleCompanion(
      id: Value(id),
      titel: Value(titel),
      sprache: Value(sprache),
      code: Value(code),
      tags: Value(tags),
      notiz: Value(notiz),
      favorit: Value(favorit),
      erstellt: Value(erstellt),
      geaendert: Value(geaendert),
    );
  }

  factory Snippet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Snippet(
      id: serializer.fromJson<int>(json['id']),
      titel: serializer.fromJson<String>(json['titel']),
      sprache: serializer.fromJson<String>(json['sprache']),
      code: serializer.fromJson<String>(json['code']),
      tags: serializer.fromJson<String>(json['tags']),
      notiz: serializer.fromJson<String>(json['notiz']),
      favorit: serializer.fromJson<bool>(json['favorit']),
      erstellt: serializer.fromJson<DateTime>(json['erstellt']),
      geaendert: serializer.fromJson<DateTime>(json['geaendert']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'titel': serializer.toJson<String>(titel),
      'sprache': serializer.toJson<String>(sprache),
      'code': serializer.toJson<String>(code),
      'tags': serializer.toJson<String>(tags),
      'notiz': serializer.toJson<String>(notiz),
      'favorit': serializer.toJson<bool>(favorit),
      'erstellt': serializer.toJson<DateTime>(erstellt),
      'geaendert': serializer.toJson<DateTime>(geaendert),
    };
  }

  Snippet copyWith({
    int? id,
    String? titel,
    String? sprache,
    String? code,
    String? tags,
    String? notiz,
    bool? favorit,
    DateTime? erstellt,
    DateTime? geaendert,
  }) => Snippet(
    id: id ?? this.id,
    titel: titel ?? this.titel,
    sprache: sprache ?? this.sprache,
    code: code ?? this.code,
    tags: tags ?? this.tags,
    notiz: notiz ?? this.notiz,
    favorit: favorit ?? this.favorit,
    erstellt: erstellt ?? this.erstellt,
    geaendert: geaendert ?? this.geaendert,
  );
  Snippet copyWithCompanion(SnippetTabelleCompanion data) {
    return Snippet(
      id: data.id.present ? data.id.value : this.id,
      titel: data.titel.present ? data.titel.value : this.titel,
      sprache: data.sprache.present ? data.sprache.value : this.sprache,
      code: data.code.present ? data.code.value : this.code,
      tags: data.tags.present ? data.tags.value : this.tags,
      notiz: data.notiz.present ? data.notiz.value : this.notiz,
      favorit: data.favorit.present ? data.favorit.value : this.favorit,
      erstellt: data.erstellt.present ? data.erstellt.value : this.erstellt,
      geaendert: data.geaendert.present ? data.geaendert.value : this.geaendert,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Snippet(')
          ..write('id: $id, ')
          ..write('titel: $titel, ')
          ..write('sprache: $sprache, ')
          ..write('code: $code, ')
          ..write('tags: $tags, ')
          ..write('notiz: $notiz, ')
          ..write('favorit: $favorit, ')
          ..write('erstellt: $erstellt, ')
          ..write('geaendert: $geaendert')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    titel,
    sprache,
    code,
    tags,
    notiz,
    favorit,
    erstellt,
    geaendert,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Snippet &&
          other.id == this.id &&
          other.titel == this.titel &&
          other.sprache == this.sprache &&
          other.code == this.code &&
          other.tags == this.tags &&
          other.notiz == this.notiz &&
          other.favorit == this.favorit &&
          other.erstellt == this.erstellt &&
          other.geaendert == this.geaendert);
}

class SnippetTabelleCompanion extends UpdateCompanion<Snippet> {
  final Value<int> id;
  final Value<String> titel;
  final Value<String> sprache;
  final Value<String> code;
  final Value<String> tags;
  final Value<String> notiz;
  final Value<bool> favorit;
  final Value<DateTime> erstellt;
  final Value<DateTime> geaendert;
  const SnippetTabelleCompanion({
    this.id = const Value.absent(),
    this.titel = const Value.absent(),
    this.sprache = const Value.absent(),
    this.code = const Value.absent(),
    this.tags = const Value.absent(),
    this.notiz = const Value.absent(),
    this.favorit = const Value.absent(),
    this.erstellt = const Value.absent(),
    this.geaendert = const Value.absent(),
  });
  SnippetTabelleCompanion.insert({
    this.id = const Value.absent(),
    required String titel,
    required String sprache,
    required String code,
    this.tags = const Value.absent(),
    this.notiz = const Value.absent(),
    this.favorit = const Value.absent(),
    required DateTime erstellt,
    required DateTime geaendert,
  }) : titel = Value(titel),
       sprache = Value(sprache),
       code = Value(code),
       erstellt = Value(erstellt),
       geaendert = Value(geaendert);
  static Insertable<Snippet> custom({
    Expression<int>? id,
    Expression<String>? titel,
    Expression<String>? sprache,
    Expression<String>? code,
    Expression<String>? tags,
    Expression<String>? notiz,
    Expression<bool>? favorit,
    Expression<DateTime>? erstellt,
    Expression<DateTime>? geaendert,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (titel != null) 'titel': titel,
      if (sprache != null) 'sprache': sprache,
      if (code != null) 'code': code,
      if (tags != null) 'tags': tags,
      if (notiz != null) 'notiz': notiz,
      if (favorit != null) 'favorit': favorit,
      if (erstellt != null) 'erstellt': erstellt,
      if (geaendert != null) 'geaendert': geaendert,
    });
  }

  SnippetTabelleCompanion copyWith({
    Value<int>? id,
    Value<String>? titel,
    Value<String>? sprache,
    Value<String>? code,
    Value<String>? tags,
    Value<String>? notiz,
    Value<bool>? favorit,
    Value<DateTime>? erstellt,
    Value<DateTime>? geaendert,
  }) {
    return SnippetTabelleCompanion(
      id: id ?? this.id,
      titel: titel ?? this.titel,
      sprache: sprache ?? this.sprache,
      code: code ?? this.code,
      tags: tags ?? this.tags,
      notiz: notiz ?? this.notiz,
      favorit: favorit ?? this.favorit,
      erstellt: erstellt ?? this.erstellt,
      geaendert: geaendert ?? this.geaendert,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (titel.present) {
      map['titel'] = Variable<String>(titel.value);
    }
    if (sprache.present) {
      map['sprache'] = Variable<String>(sprache.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (notiz.present) {
      map['notiz'] = Variable<String>(notiz.value);
    }
    if (favorit.present) {
      map['favorit'] = Variable<bool>(favorit.value);
    }
    if (erstellt.present) {
      map['erstellt'] = Variable<DateTime>(erstellt.value);
    }
    if (geaendert.present) {
      map['geaendert'] = Variable<DateTime>(geaendert.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SnippetTabelleCompanion(')
          ..write('id: $id, ')
          ..write('titel: $titel, ')
          ..write('sprache: $sprache, ')
          ..write('code: $code, ')
          ..write('tags: $tags, ')
          ..write('notiz: $notiz, ')
          ..write('favorit: $favorit, ')
          ..write('erstellt: $erstellt, ')
          ..write('geaendert: $geaendert')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatenbank extends GeneratedDatabase {
  _$AppDatenbank(QueryExecutor e) : super(e);
  $AppDatenbankManager get managers => $AppDatenbankManager(this);
  late final $StapelTabelleTable stapelTabelle = $StapelTabelleTable(this);
  late final $KarteTabelleTable karteTabelle = $KarteTabelleTable(this);
  late final $LernstandTabelleTable lernstandTabelle = $LernstandTabelleTable(
    this,
  );
  late final $LerntagTabelleTable lerntagTabelle = $LerntagTabelleTable(this);
  late final $SnippetTabelleTable snippetTabelle = $SnippetTabelleTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    stapelTabelle,
    karteTabelle,
    lernstandTabelle,
    lerntagTabelle,
    snippetTabelle,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'stapel',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('karten', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'karten',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('lernstand', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$StapelTabelleTableCreateCompanionBuilder =
    StapelTabelleCompanion Function({
      Value<int> id,
      Value<String?> schluessel,
      required String name,
      required String sprache,
      Value<String> stufe,
      Value<String> beschreibung,
      Value<String?> produkt,
      Value<bool> eigen,
      Value<bool> aktiv,
      Value<int> sortierung,
    });
typedef $$StapelTabelleTableUpdateCompanionBuilder =
    StapelTabelleCompanion Function({
      Value<int> id,
      Value<String?> schluessel,
      Value<String> name,
      Value<String> sprache,
      Value<String> stufe,
      Value<String> beschreibung,
      Value<String?> produkt,
      Value<bool> eigen,
      Value<bool> aktiv,
      Value<int> sortierung,
    });

final class $$StapelTabelleTableReferences
    extends BaseReferences<_$AppDatenbank, $StapelTabelleTable, Stapel> {
  $$StapelTabelleTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$KarteTabelleTable, List<Karte>>
  _karteTabelleRefsTable(_$AppDatenbank db) => MultiTypedResultKey.fromTable(
    db.karteTabelle,
    aliasName: 'stapel__id__karten__stapel_id',
  );

  $$KarteTabelleTableProcessedTableManager get karteTabelleRefs {
    final manager = $$KarteTabelleTableTableManager(
      $_db,
      $_db.karteTabelle,
    ).filter((f) => f.stapelId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_karteTabelleRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StapelTabelleTableFilterComposer
    extends Composer<_$AppDatenbank, $StapelTabelleTable> {
  $$StapelTabelleTableFilterComposer({
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

  ColumnFilters<String> get schluessel => $composableBuilder(
    column: $table.schluessel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sprache => $composableBuilder(
    column: $table.sprache,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stufe => $composableBuilder(
    column: $table.stufe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get beschreibung => $composableBuilder(
    column: $table.beschreibung,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get produkt => $composableBuilder(
    column: $table.produkt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get eigen => $composableBuilder(
    column: $table.eigen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get aktiv => $composableBuilder(
    column: $table.aktiv,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortierung => $composableBuilder(
    column: $table.sortierung,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> karteTabelleRefs(
    Expression<bool> Function($$KarteTabelleTableFilterComposer f) f,
  ) {
    final $$KarteTabelleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.karteTabelle,
      getReferencedColumn: (t) => t.stapelId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$KarteTabelleTableFilterComposer(
            $db: $db,
            $table: $db.karteTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StapelTabelleTableOrderingComposer
    extends Composer<_$AppDatenbank, $StapelTabelleTable> {
  $$StapelTabelleTableOrderingComposer({
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

  ColumnOrderings<String> get schluessel => $composableBuilder(
    column: $table.schluessel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sprache => $composableBuilder(
    column: $table.sprache,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stufe => $composableBuilder(
    column: $table.stufe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get beschreibung => $composableBuilder(
    column: $table.beschreibung,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get produkt => $composableBuilder(
    column: $table.produkt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get eigen => $composableBuilder(
    column: $table.eigen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get aktiv => $composableBuilder(
    column: $table.aktiv,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortierung => $composableBuilder(
    column: $table.sortierung,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StapelTabelleTableAnnotationComposer
    extends Composer<_$AppDatenbank, $StapelTabelleTable> {
  $$StapelTabelleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get schluessel => $composableBuilder(
    column: $table.schluessel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get sprache =>
      $composableBuilder(column: $table.sprache, builder: (column) => column);

  GeneratedColumn<String> get stufe =>
      $composableBuilder(column: $table.stufe, builder: (column) => column);

  GeneratedColumn<String> get beschreibung => $composableBuilder(
    column: $table.beschreibung,
    builder: (column) => column,
  );

  GeneratedColumn<String> get produkt =>
      $composableBuilder(column: $table.produkt, builder: (column) => column);

  GeneratedColumn<bool> get eigen =>
      $composableBuilder(column: $table.eigen, builder: (column) => column);

  GeneratedColumn<bool> get aktiv =>
      $composableBuilder(column: $table.aktiv, builder: (column) => column);

  GeneratedColumn<int> get sortierung => $composableBuilder(
    column: $table.sortierung,
    builder: (column) => column,
  );

  Expression<T> karteTabelleRefs<T extends Object>(
    Expression<T> Function($$KarteTabelleTableAnnotationComposer a) f,
  ) {
    final $$KarteTabelleTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.karteTabelle,
      getReferencedColumn: (t) => t.stapelId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$KarteTabelleTableAnnotationComposer(
            $db: $db,
            $table: $db.karteTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StapelTabelleTableTableManager
    extends
        RootTableManager<
          _$AppDatenbank,
          $StapelTabelleTable,
          Stapel,
          $$StapelTabelleTableFilterComposer,
          $$StapelTabelleTableOrderingComposer,
          $$StapelTabelleTableAnnotationComposer,
          $$StapelTabelleTableCreateCompanionBuilder,
          $$StapelTabelleTableUpdateCompanionBuilder,
          (Stapel, $$StapelTabelleTableReferences),
          Stapel,
          PrefetchHooks Function({bool karteTabelleRefs})
        > {
  $$StapelTabelleTableTableManager(_$AppDatenbank db, $StapelTabelleTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StapelTabelleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StapelTabelleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StapelTabelleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> schluessel = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> sprache = const Value.absent(),
                Value<String> stufe = const Value.absent(),
                Value<String> beschreibung = const Value.absent(),
                Value<String?> produkt = const Value.absent(),
                Value<bool> eigen = const Value.absent(),
                Value<bool> aktiv = const Value.absent(),
                Value<int> sortierung = const Value.absent(),
              }) => StapelTabelleCompanion(
                id: id,
                schluessel: schluessel,
                name: name,
                sprache: sprache,
                stufe: stufe,
                beschreibung: beschreibung,
                produkt: produkt,
                eigen: eigen,
                aktiv: aktiv,
                sortierung: sortierung,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> schluessel = const Value.absent(),
                required String name,
                required String sprache,
                Value<String> stufe = const Value.absent(),
                Value<String> beschreibung = const Value.absent(),
                Value<String?> produkt = const Value.absent(),
                Value<bool> eigen = const Value.absent(),
                Value<bool> aktiv = const Value.absent(),
                Value<int> sortierung = const Value.absent(),
              }) => StapelTabelleCompanion.insert(
                id: id,
                schluessel: schluessel,
                name: name,
                sprache: sprache,
                stufe: stufe,
                beschreibung: beschreibung,
                produkt: produkt,
                eigen: eigen,
                aktiv: aktiv,
                sortierung: sortierung,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StapelTabelleTable, Stapel>(table),
                  $$StapelTabelleTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({karteTabelleRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (karteTabelleRefs) db.karteTabelle],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (karteTabelleRefs)
                    await $_getPrefetchedData<
                      Stapel,
                      $StapelTabelleTable,
                      Karte
                    >(
                      currentTable: table,
                      referencedTable: $$StapelTabelleTableReferences
                          ._karteTabelleRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$StapelTabelleTableReferences(
                            db,
                            table,
                            p0,
                          ).karteTabelleRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.stapelId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$StapelTabelleTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatenbank,
      $StapelTabelleTable,
      Stapel,
      $$StapelTabelleTableFilterComposer,
      $$StapelTabelleTableOrderingComposer,
      $$StapelTabelleTableAnnotationComposer,
      $$StapelTabelleTableCreateCompanionBuilder,
      $$StapelTabelleTableUpdateCompanionBuilder,
      (Stapel, $$StapelTabelleTableReferences),
      Stapel,
      PrefetchHooks Function({bool karteTabelleRefs})
    >;
typedef $$KarteTabelleTableCreateCompanionBuilder =
    KarteTabelleCompanion Function({
      Value<int> id,
      required int stapelId,
      Value<String?> schluessel,
      required String typ,
      required String frage,
      required String antwort,
      Value<String?> code,
      Value<String> optionen,
      Value<String> erklaerung,
      Value<int> reihenfolge,
    });
typedef $$KarteTabelleTableUpdateCompanionBuilder =
    KarteTabelleCompanion Function({
      Value<int> id,
      Value<int> stapelId,
      Value<String?> schluessel,
      Value<String> typ,
      Value<String> frage,
      Value<String> antwort,
      Value<String?> code,
      Value<String> optionen,
      Value<String> erklaerung,
      Value<int> reihenfolge,
    });

final class $$KarteTabelleTableReferences
    extends BaseReferences<_$AppDatenbank, $KarteTabelleTable, Karte> {
  $$KarteTabelleTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $StapelTabelleTable _stapelIdTable(_$AppDatenbank db) =>
      db.stapelTabelle.createAlias('karten__stapel_id__stapel__id');

  $$StapelTabelleTableProcessedTableManager get stapelId {
    final $_column = $_itemColumn<int>('stapel_id')!;

    final manager = $$StapelTabelleTableTableManager(
      $_db,
      $_db.stapelTabelle,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_stapelIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$LernstandTabelleTable, List<LernstandZeile>>
  _lernstandTabelleRefsTable(_$AppDatenbank db) =>
      MultiTypedResultKey.fromTable(
        db.lernstandTabelle,
        aliasName: 'karten__id__lernstand__karte_id',
      );

  $$LernstandTabelleTableProcessedTableManager get lernstandTabelleRefs {
    final manager = $$LernstandTabelleTableTableManager(
      $_db,
      $_db.lernstandTabelle,
    ).filter((f) => f.karteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _lernstandTabelleRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$KarteTabelleTableFilterComposer
    extends Composer<_$AppDatenbank, $KarteTabelleTable> {
  $$KarteTabelleTableFilterComposer({
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

  ColumnFilters<String> get schluessel => $composableBuilder(
    column: $table.schluessel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get typ => $composableBuilder(
    column: $table.typ,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frage => $composableBuilder(
    column: $table.frage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get antwort => $composableBuilder(
    column: $table.antwort,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get optionen => $composableBuilder(
    column: $table.optionen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get erklaerung => $composableBuilder(
    column: $table.erklaerung,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reihenfolge => $composableBuilder(
    column: $table.reihenfolge,
    builder: (column) => ColumnFilters(column),
  );

  $$StapelTabelleTableFilterComposer get stapelId {
    final $$StapelTabelleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stapelId,
      referencedTable: $db.stapelTabelle,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StapelTabelleTableFilterComposer(
            $db: $db,
            $table: $db.stapelTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> lernstandTabelleRefs(
    Expression<bool> Function($$LernstandTabelleTableFilterComposer f) f,
  ) {
    final $$LernstandTabelleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lernstandTabelle,
      getReferencedColumn: (t) => t.karteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LernstandTabelleTableFilterComposer(
            $db: $db,
            $table: $db.lernstandTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$KarteTabelleTableOrderingComposer
    extends Composer<_$AppDatenbank, $KarteTabelleTable> {
  $$KarteTabelleTableOrderingComposer({
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

  ColumnOrderings<String> get schluessel => $composableBuilder(
    column: $table.schluessel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get typ => $composableBuilder(
    column: $table.typ,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frage => $composableBuilder(
    column: $table.frage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get antwort => $composableBuilder(
    column: $table.antwort,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get optionen => $composableBuilder(
    column: $table.optionen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get erklaerung => $composableBuilder(
    column: $table.erklaerung,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reihenfolge => $composableBuilder(
    column: $table.reihenfolge,
    builder: (column) => ColumnOrderings(column),
  );

  $$StapelTabelleTableOrderingComposer get stapelId {
    final $$StapelTabelleTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stapelId,
      referencedTable: $db.stapelTabelle,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StapelTabelleTableOrderingComposer(
            $db: $db,
            $table: $db.stapelTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$KarteTabelleTableAnnotationComposer
    extends Composer<_$AppDatenbank, $KarteTabelleTable> {
  $$KarteTabelleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get schluessel => $composableBuilder(
    column: $table.schluessel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get typ =>
      $composableBuilder(column: $table.typ, builder: (column) => column);

  GeneratedColumn<String> get frage =>
      $composableBuilder(column: $table.frage, builder: (column) => column);

  GeneratedColumn<String> get antwort =>
      $composableBuilder(column: $table.antwort, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get optionen =>
      $composableBuilder(column: $table.optionen, builder: (column) => column);

  GeneratedColumn<String> get erklaerung => $composableBuilder(
    column: $table.erklaerung,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reihenfolge => $composableBuilder(
    column: $table.reihenfolge,
    builder: (column) => column,
  );

  $$StapelTabelleTableAnnotationComposer get stapelId {
    final $$StapelTabelleTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stapelId,
      referencedTable: $db.stapelTabelle,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StapelTabelleTableAnnotationComposer(
            $db: $db,
            $table: $db.stapelTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> lernstandTabelleRefs<T extends Object>(
    Expression<T> Function($$LernstandTabelleTableAnnotationComposer a) f,
  ) {
    final $$LernstandTabelleTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lernstandTabelle,
      getReferencedColumn: (t) => t.karteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LernstandTabelleTableAnnotationComposer(
            $db: $db,
            $table: $db.lernstandTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$KarteTabelleTableTableManager
    extends
        RootTableManager<
          _$AppDatenbank,
          $KarteTabelleTable,
          Karte,
          $$KarteTabelleTableFilterComposer,
          $$KarteTabelleTableOrderingComposer,
          $$KarteTabelleTableAnnotationComposer,
          $$KarteTabelleTableCreateCompanionBuilder,
          $$KarteTabelleTableUpdateCompanionBuilder,
          (Karte, $$KarteTabelleTableReferences),
          Karte,
          PrefetchHooks Function({bool stapelId, bool lernstandTabelleRefs})
        > {
  $$KarteTabelleTableTableManager(_$AppDatenbank db, $KarteTabelleTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KarteTabelleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KarteTabelleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KarteTabelleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> stapelId = const Value.absent(),
                Value<String?> schluessel = const Value.absent(),
                Value<String> typ = const Value.absent(),
                Value<String> frage = const Value.absent(),
                Value<String> antwort = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<String> optionen = const Value.absent(),
                Value<String> erklaerung = const Value.absent(),
                Value<int> reihenfolge = const Value.absent(),
              }) => KarteTabelleCompanion(
                id: id,
                stapelId: stapelId,
                schluessel: schluessel,
                typ: typ,
                frage: frage,
                antwort: antwort,
                code: code,
                optionen: optionen,
                erklaerung: erklaerung,
                reihenfolge: reihenfolge,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int stapelId,
                Value<String?> schluessel = const Value.absent(),
                required String typ,
                required String frage,
                required String antwort,
                Value<String?> code = const Value.absent(),
                Value<String> optionen = const Value.absent(),
                Value<String> erklaerung = const Value.absent(),
                Value<int> reihenfolge = const Value.absent(),
              }) => KarteTabelleCompanion.insert(
                id: id,
                stapelId: stapelId,
                schluessel: schluessel,
                typ: typ,
                frage: frage,
                antwort: antwort,
                code: code,
                optionen: optionen,
                erklaerung: erklaerung,
                reihenfolge: reihenfolge,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$KarteTabelleTable, Karte>(table),
                  $$KarteTabelleTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({stapelId = false, lernstandTabelleRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (lernstandTabelleRefs) db.lernstandTabelle,
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
                        if (stapelId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.stapelId,
                            referencedTable: $$KarteTabelleTableReferences
                                ._stapelIdTable(db),
                            referencedColumn: $$KarteTabelleTableReferences
                                ._stapelIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (lernstandTabelleRefs)
                        await $_getPrefetchedData<
                          Karte,
                          $KarteTabelleTable,
                          LernstandZeile
                        >(
                          currentTable: table,
                          referencedTable: $$KarteTabelleTableReferences
                              ._lernstandTabelleRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$KarteTabelleTableReferences(
                                db,
                                table,
                                p0,
                              ).lernstandTabelleRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.karteId == item.id,
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

typedef $$KarteTabelleTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatenbank,
      $KarteTabelleTable,
      Karte,
      $$KarteTabelleTableFilterComposer,
      $$KarteTabelleTableOrderingComposer,
      $$KarteTabelleTableAnnotationComposer,
      $$KarteTabelleTableCreateCompanionBuilder,
      $$KarteTabelleTableUpdateCompanionBuilder,
      (Karte, $$KarteTabelleTableReferences),
      Karte,
      PrefetchHooks Function({bool stapelId, bool lernstandTabelleRefs})
    >;
typedef $$LernstandTabelleTableCreateCompanionBuilder =
    LernstandTabelleCompanion Function({
      Value<int> karteId,
      required int wiederholungen,
      required double leichtigkeit,
      required int intervallTage,
      required DateTime faellig,
      Value<int> fehler,
      required DateTime zuletzt,
    });
typedef $$LernstandTabelleTableUpdateCompanionBuilder =
    LernstandTabelleCompanion Function({
      Value<int> karteId,
      Value<int> wiederholungen,
      Value<double> leichtigkeit,
      Value<int> intervallTage,
      Value<DateTime> faellig,
      Value<int> fehler,
      Value<DateTime> zuletzt,
    });

final class $$LernstandTabelleTableReferences
    extends
        BaseReferences<_$AppDatenbank, $LernstandTabelleTable, LernstandZeile> {
  $$LernstandTabelleTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $KarteTabelleTable _karteIdTable(_$AppDatenbank db) =>
      db.karteTabelle.createAlias('lernstand__karte_id__karten__id');

  $$KarteTabelleTableProcessedTableManager get karteId {
    final $_column = $_itemColumn<int>('karte_id')!;

    final manager = $$KarteTabelleTableTableManager(
      $_db,
      $_db.karteTabelle,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_karteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LernstandTabelleTableFilterComposer
    extends Composer<_$AppDatenbank, $LernstandTabelleTable> {
  $$LernstandTabelleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get wiederholungen => $composableBuilder(
    column: $table.wiederholungen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get leichtigkeit => $composableBuilder(
    column: $table.leichtigkeit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervallTage => $composableBuilder(
    column: $table.intervallTage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get faellig => $composableBuilder(
    column: $table.faellig,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fehler => $composableBuilder(
    column: $table.fehler,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get zuletzt => $composableBuilder(
    column: $table.zuletzt,
    builder: (column) => ColumnFilters(column),
  );

  $$KarteTabelleTableFilterComposer get karteId {
    final $$KarteTabelleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.karteId,
      referencedTable: $db.karteTabelle,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$KarteTabelleTableFilterComposer(
            $db: $db,
            $table: $db.karteTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LernstandTabelleTableOrderingComposer
    extends Composer<_$AppDatenbank, $LernstandTabelleTable> {
  $$LernstandTabelleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get wiederholungen => $composableBuilder(
    column: $table.wiederholungen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get leichtigkeit => $composableBuilder(
    column: $table.leichtigkeit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervallTage => $composableBuilder(
    column: $table.intervallTage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get faellig => $composableBuilder(
    column: $table.faellig,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fehler => $composableBuilder(
    column: $table.fehler,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get zuletzt => $composableBuilder(
    column: $table.zuletzt,
    builder: (column) => ColumnOrderings(column),
  );

  $$KarteTabelleTableOrderingComposer get karteId {
    final $$KarteTabelleTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.karteId,
      referencedTable: $db.karteTabelle,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$KarteTabelleTableOrderingComposer(
            $db: $db,
            $table: $db.karteTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LernstandTabelleTableAnnotationComposer
    extends Composer<_$AppDatenbank, $LernstandTabelleTable> {
  $$LernstandTabelleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get wiederholungen => $composableBuilder(
    column: $table.wiederholungen,
    builder: (column) => column,
  );

  GeneratedColumn<double> get leichtigkeit => $composableBuilder(
    column: $table.leichtigkeit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intervallTage => $composableBuilder(
    column: $table.intervallTage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get faellig =>
      $composableBuilder(column: $table.faellig, builder: (column) => column);

  GeneratedColumn<int> get fehler =>
      $composableBuilder(column: $table.fehler, builder: (column) => column);

  GeneratedColumn<DateTime> get zuletzt =>
      $composableBuilder(column: $table.zuletzt, builder: (column) => column);

  $$KarteTabelleTableAnnotationComposer get karteId {
    final $$KarteTabelleTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.karteId,
      referencedTable: $db.karteTabelle,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$KarteTabelleTableAnnotationComposer(
            $db: $db,
            $table: $db.karteTabelle,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LernstandTabelleTableTableManager
    extends
        RootTableManager<
          _$AppDatenbank,
          $LernstandTabelleTable,
          LernstandZeile,
          $$LernstandTabelleTableFilterComposer,
          $$LernstandTabelleTableOrderingComposer,
          $$LernstandTabelleTableAnnotationComposer,
          $$LernstandTabelleTableCreateCompanionBuilder,
          $$LernstandTabelleTableUpdateCompanionBuilder,
          (LernstandZeile, $$LernstandTabelleTableReferences),
          LernstandZeile,
          PrefetchHooks Function({bool karteId})
        > {
  $$LernstandTabelleTableTableManager(
    _$AppDatenbank db,
    $LernstandTabelleTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LernstandTabelleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LernstandTabelleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LernstandTabelleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> karteId = const Value.absent(),
                Value<int> wiederholungen = const Value.absent(),
                Value<double> leichtigkeit = const Value.absent(),
                Value<int> intervallTage = const Value.absent(),
                Value<DateTime> faellig = const Value.absent(),
                Value<int> fehler = const Value.absent(),
                Value<DateTime> zuletzt = const Value.absent(),
              }) => LernstandTabelleCompanion(
                karteId: karteId,
                wiederholungen: wiederholungen,
                leichtigkeit: leichtigkeit,
                intervallTage: intervallTage,
                faellig: faellig,
                fehler: fehler,
                zuletzt: zuletzt,
              ),
          createCompanionCallback:
              ({
                Value<int> karteId = const Value.absent(),
                required int wiederholungen,
                required double leichtigkeit,
                required int intervallTage,
                required DateTime faellig,
                Value<int> fehler = const Value.absent(),
                required DateTime zuletzt,
              }) => LernstandTabelleCompanion.insert(
                karteId: karteId,
                wiederholungen: wiederholungen,
                leichtigkeit: leichtigkeit,
                intervallTage: intervallTage,
                faellig: faellig,
                fehler: fehler,
                zuletzt: zuletzt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LernstandTabelleTable, LernstandZeile>(table),
                  $$LernstandTabelleTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({karteId = false}) {
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
                    if (karteId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.karteId,
                        referencedTable: $$LernstandTabelleTableReferences
                            ._karteIdTable(db),
                        referencedColumn: $$LernstandTabelleTableReferences
                            ._karteIdTable(db)
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

typedef $$LernstandTabelleTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatenbank,
      $LernstandTabelleTable,
      LernstandZeile,
      $$LernstandTabelleTableFilterComposer,
      $$LernstandTabelleTableOrderingComposer,
      $$LernstandTabelleTableAnnotationComposer,
      $$LernstandTabelleTableCreateCompanionBuilder,
      $$LernstandTabelleTableUpdateCompanionBuilder,
      (LernstandZeile, $$LernstandTabelleTableReferences),
      LernstandZeile,
      PrefetchHooks Function({bool karteId})
    >;
typedef $$LerntagTabelleTableCreateCompanionBuilder =
    LerntagTabelleCompanion Function({
      required DateTime datum,
      Value<int> karten,
      Value<int> richtig,
      Value<int> neu,
      Value<int> rowid,
    });
typedef $$LerntagTabelleTableUpdateCompanionBuilder =
    LerntagTabelleCompanion Function({
      Value<DateTime> datum,
      Value<int> karten,
      Value<int> richtig,
      Value<int> neu,
      Value<int> rowid,
    });

class $$LerntagTabelleTableFilterComposer
    extends Composer<_$AppDatenbank, $LerntagTabelleTable> {
  $$LerntagTabelleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get datum => $composableBuilder(
    column: $table.datum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get karten => $composableBuilder(
    column: $table.karten,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get richtig => $composableBuilder(
    column: $table.richtig,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get neu => $composableBuilder(
    column: $table.neu,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LerntagTabelleTableOrderingComposer
    extends Composer<_$AppDatenbank, $LerntagTabelleTable> {
  $$LerntagTabelleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get datum => $composableBuilder(
    column: $table.datum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get karten => $composableBuilder(
    column: $table.karten,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get richtig => $composableBuilder(
    column: $table.richtig,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get neu => $composableBuilder(
    column: $table.neu,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LerntagTabelleTableAnnotationComposer
    extends Composer<_$AppDatenbank, $LerntagTabelleTable> {
  $$LerntagTabelleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get datum =>
      $composableBuilder(column: $table.datum, builder: (column) => column);

  GeneratedColumn<int> get karten =>
      $composableBuilder(column: $table.karten, builder: (column) => column);

  GeneratedColumn<int> get richtig =>
      $composableBuilder(column: $table.richtig, builder: (column) => column);

  GeneratedColumn<int> get neu =>
      $composableBuilder(column: $table.neu, builder: (column) => column);
}

class $$LerntagTabelleTableTableManager
    extends
        RootTableManager<
          _$AppDatenbank,
          $LerntagTabelleTable,
          Lerntag,
          $$LerntagTabelleTableFilterComposer,
          $$LerntagTabelleTableOrderingComposer,
          $$LerntagTabelleTableAnnotationComposer,
          $$LerntagTabelleTableCreateCompanionBuilder,
          $$LerntagTabelleTableUpdateCompanionBuilder,
          (
            Lerntag,
            BaseReferences<_$AppDatenbank, $LerntagTabelleTable, Lerntag>,
          ),
          Lerntag,
          PrefetchHooks Function()
        > {
  $$LerntagTabelleTableTableManager(
    _$AppDatenbank db,
    $LerntagTabelleTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LerntagTabelleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LerntagTabelleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LerntagTabelleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> datum = const Value.absent(),
                Value<int> karten = const Value.absent(),
                Value<int> richtig = const Value.absent(),
                Value<int> neu = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LerntagTabelleCompanion(
                datum: datum,
                karten: karten,
                richtig: richtig,
                neu: neu,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime datum,
                Value<int> karten = const Value.absent(),
                Value<int> richtig = const Value.absent(),
                Value<int> neu = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LerntagTabelleCompanion.insert(
                datum: datum,
                karten: karten,
                richtig: richtig,
                neu: neu,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LerntagTabelleTable, Lerntag>(table),
                  BaseReferences<_$AppDatenbank, $LerntagTabelleTable, Lerntag>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LerntagTabelleTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatenbank,
      $LerntagTabelleTable,
      Lerntag,
      $$LerntagTabelleTableFilterComposer,
      $$LerntagTabelleTableOrderingComposer,
      $$LerntagTabelleTableAnnotationComposer,
      $$LerntagTabelleTableCreateCompanionBuilder,
      $$LerntagTabelleTableUpdateCompanionBuilder,
      (Lerntag, BaseReferences<_$AppDatenbank, $LerntagTabelleTable, Lerntag>),
      Lerntag,
      PrefetchHooks Function()
    >;
typedef $$SnippetTabelleTableCreateCompanionBuilder =
    SnippetTabelleCompanion Function({
      Value<int> id,
      required String titel,
      required String sprache,
      required String code,
      Value<String> tags,
      Value<String> notiz,
      Value<bool> favorit,
      required DateTime erstellt,
      required DateTime geaendert,
    });
typedef $$SnippetTabelleTableUpdateCompanionBuilder =
    SnippetTabelleCompanion Function({
      Value<int> id,
      Value<String> titel,
      Value<String> sprache,
      Value<String> code,
      Value<String> tags,
      Value<String> notiz,
      Value<bool> favorit,
      Value<DateTime> erstellt,
      Value<DateTime> geaendert,
    });

class $$SnippetTabelleTableFilterComposer
    extends Composer<_$AppDatenbank, $SnippetTabelleTable> {
  $$SnippetTabelleTableFilterComposer({
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

  ColumnFilters<String> get titel => $composableBuilder(
    column: $table.titel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sprache => $composableBuilder(
    column: $table.sprache,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notiz => $composableBuilder(
    column: $table.notiz,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get favorit => $composableBuilder(
    column: $table.favorit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get erstellt => $composableBuilder(
    column: $table.erstellt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get geaendert => $composableBuilder(
    column: $table.geaendert,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SnippetTabelleTableOrderingComposer
    extends Composer<_$AppDatenbank, $SnippetTabelleTable> {
  $$SnippetTabelleTableOrderingComposer({
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

  ColumnOrderings<String> get titel => $composableBuilder(
    column: $table.titel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sprache => $composableBuilder(
    column: $table.sprache,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notiz => $composableBuilder(
    column: $table.notiz,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get favorit => $composableBuilder(
    column: $table.favorit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get erstellt => $composableBuilder(
    column: $table.erstellt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get geaendert => $composableBuilder(
    column: $table.geaendert,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SnippetTabelleTableAnnotationComposer
    extends Composer<_$AppDatenbank, $SnippetTabelleTable> {
  $$SnippetTabelleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get titel =>
      $composableBuilder(column: $table.titel, builder: (column) => column);

  GeneratedColumn<String> get sprache =>
      $composableBuilder(column: $table.sprache, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get notiz =>
      $composableBuilder(column: $table.notiz, builder: (column) => column);

  GeneratedColumn<bool> get favorit =>
      $composableBuilder(column: $table.favorit, builder: (column) => column);

  GeneratedColumn<DateTime> get erstellt =>
      $composableBuilder(column: $table.erstellt, builder: (column) => column);

  GeneratedColumn<DateTime> get geaendert =>
      $composableBuilder(column: $table.geaendert, builder: (column) => column);
}

class $$SnippetTabelleTableTableManager
    extends
        RootTableManager<
          _$AppDatenbank,
          $SnippetTabelleTable,
          Snippet,
          $$SnippetTabelleTableFilterComposer,
          $$SnippetTabelleTableOrderingComposer,
          $$SnippetTabelleTableAnnotationComposer,
          $$SnippetTabelleTableCreateCompanionBuilder,
          $$SnippetTabelleTableUpdateCompanionBuilder,
          (
            Snippet,
            BaseReferences<_$AppDatenbank, $SnippetTabelleTable, Snippet>,
          ),
          Snippet,
          PrefetchHooks Function()
        > {
  $$SnippetTabelleTableTableManager(
    _$AppDatenbank db,
    $SnippetTabelleTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SnippetTabelleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SnippetTabelleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SnippetTabelleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> titel = const Value.absent(),
                Value<String> sprache = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<String> notiz = const Value.absent(),
                Value<bool> favorit = const Value.absent(),
                Value<DateTime> erstellt = const Value.absent(),
                Value<DateTime> geaendert = const Value.absent(),
              }) => SnippetTabelleCompanion(
                id: id,
                titel: titel,
                sprache: sprache,
                code: code,
                tags: tags,
                notiz: notiz,
                favorit: favorit,
                erstellt: erstellt,
                geaendert: geaendert,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String titel,
                required String sprache,
                required String code,
                Value<String> tags = const Value.absent(),
                Value<String> notiz = const Value.absent(),
                Value<bool> favorit = const Value.absent(),
                required DateTime erstellt,
                required DateTime geaendert,
              }) => SnippetTabelleCompanion.insert(
                id: id,
                titel: titel,
                sprache: sprache,
                code: code,
                tags: tags,
                notiz: notiz,
                favorit: favorit,
                erstellt: erstellt,
                geaendert: geaendert,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SnippetTabelleTable, Snippet>(table),
                  BaseReferences<_$AppDatenbank, $SnippetTabelleTable, Snippet>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SnippetTabelleTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatenbank,
      $SnippetTabelleTable,
      Snippet,
      $$SnippetTabelleTableFilterComposer,
      $$SnippetTabelleTableOrderingComposer,
      $$SnippetTabelleTableAnnotationComposer,
      $$SnippetTabelleTableCreateCompanionBuilder,
      $$SnippetTabelleTableUpdateCompanionBuilder,
      (Snippet, BaseReferences<_$AppDatenbank, $SnippetTabelleTable, Snippet>),
      Snippet,
      PrefetchHooks Function()
    >;

class $AppDatenbankManager {
  final _$AppDatenbank _db;
  $AppDatenbankManager(this._db);
  $$StapelTabelleTableTableManager get stapelTabelle =>
      $$StapelTabelleTableTableManager(_db, _db.stapelTabelle);
  $$KarteTabelleTableTableManager get karteTabelle =>
      $$KarteTabelleTableTableManager(_db, _db.karteTabelle);
  $$LernstandTabelleTableTableManager get lernstandTabelle =>
      $$LernstandTabelleTableTableManager(_db, _db.lernstandTabelle);
  $$LerntagTabelleTableTableManager get lerntagTabelle =>
      $$LerntagTabelleTableTableManager(_db, _db.lerntagTabelle);
  $$SnippetTabelleTableTableManager get snippetTabelle =>
      $$SnippetTabelleTableTableManager(_db, _db.snippetTabelle);
}
