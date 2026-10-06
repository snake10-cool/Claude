// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'datenbank.dart';

// ignore_for_file: type=lint
class $GruppeTabelleTable extends GruppeTabelle
    with TableInfo<$GruppeTabelleTable, Gruppe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GruppeTabelleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gruppeIdMeta = const VerificationMeta(
    'gruppeId',
  );
  @override
  late final GeneratedColumn<String> gruppeId = GeneratedColumn<String>(
    'gruppe_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _geloeschtMeta = const VerificationMeta(
    'geloescht',
  );
  @override
  late final GeneratedColumn<bool> geloescht = GeneratedColumn<bool>(
    'geloescht',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("geloescht" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hochgeladenMeta = const VerificationMeta(
    'hochgeladen',
  );
  @override
  late final GeneratedColumn<bool> hochgeladen = GeneratedColumn<bool>(
    'hochgeladen',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hochgeladen" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _artMeta = const VerificationMeta('art');
  @override
  late final GeneratedColumn<String> art = GeneratedColumn<String>(
    'art',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('wg'),
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
  static const VerificationMeta _onlineMeta = const VerificationMeta('online');
  @override
  late final GeneratedColumn<bool> online = GeneratedColumn<bool>(
    'online',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("online" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _ichPersonIdMeta = const VerificationMeta(
    'ichPersonId',
  );
  @override
  late final GeneratedColumn<String> ichPersonId = GeneratedColumn<String>(
    'ich_person_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gruppeId,
    geaendert,
    geloescht,
    hochgeladen,
    name,
    art,
    code,
    online,
    ichPersonId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gruppen';
  @override
  VerificationContext validateIntegrity(
    Insertable<Gruppe> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('gruppe_id')) {
      context.handle(
        _gruppeIdMeta,
        gruppeId.isAcceptableOrUnknown(data['gruppe_id']!, _gruppeIdMeta),
      );
    }
    if (data.containsKey('geaendert')) {
      context.handle(
        _geaendertMeta,
        geaendert.isAcceptableOrUnknown(data['geaendert']!, _geaendertMeta),
      );
    } else if (isInserting) {
      context.missing(_geaendertMeta);
    }
    if (data.containsKey('geloescht')) {
      context.handle(
        _geloeschtMeta,
        geloescht.isAcceptableOrUnknown(data['geloescht']!, _geloeschtMeta),
      );
    }
    if (data.containsKey('hochgeladen')) {
      context.handle(
        _hochgeladenMeta,
        hochgeladen.isAcceptableOrUnknown(
          data['hochgeladen']!,
          _hochgeladenMeta,
        ),
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
    if (data.containsKey('art')) {
      context.handle(
        _artMeta,
        art.isAcceptableOrUnknown(data['art']!, _artMeta),
      );
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    if (data.containsKey('online')) {
      context.handle(
        _onlineMeta,
        online.isAcceptableOrUnknown(data['online']!, _onlineMeta),
      );
    }
    if (data.containsKey('ich_person_id')) {
      context.handle(
        _ichPersonIdMeta,
        ichPersonId.isAcceptableOrUnknown(
          data['ich_person_id']!,
          _ichPersonIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Gruppe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Gruppe(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      gruppeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gruppe_id'],
      ),
      geaendert: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}geaendert'],
      )!,
      geloescht: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}geloescht'],
      )!,
      hochgeladen: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hochgeladen'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      art: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}art'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      ),
      online: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}online'],
      )!,
      ichPersonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ich_person_id'],
      ),
    );
  }

  @override
  $GruppeTabelleTable createAlias(String alias) {
    return $GruppeTabelleTable(attachedDatabase, alias);
  }
}

class Gruppe extends DataClass implements Insertable<Gruppe> {
  final String id;
  final String? gruppeId;
  final DateTime geaendert;
  final bool geloescht;
  final bool hochgeladen;
  final String name;

  /// wg, familie, urlaub, essen, sonst
  final String art;

  /// Einladungscode, sobald die Gruppe in der Cloud ist.
  final String? code;

  /// Wird mit anderen Geräten synchronisiert.
  final bool online;

  /// Welche Person in der Gruppe bin ich (nur lokal, nicht geteilt).
  final String? ichPersonId;
  const Gruppe({
    required this.id,
    this.gruppeId,
    required this.geaendert,
    required this.geloescht,
    required this.hochgeladen,
    required this.name,
    required this.art,
    this.code,
    required this.online,
    this.ichPersonId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || gruppeId != null) {
      map['gruppe_id'] = Variable<String>(gruppeId);
    }
    map['geaendert'] = Variable<DateTime>(geaendert);
    map['geloescht'] = Variable<bool>(geloescht);
    map['hochgeladen'] = Variable<bool>(hochgeladen);
    map['name'] = Variable<String>(name);
    map['art'] = Variable<String>(art);
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    map['online'] = Variable<bool>(online);
    if (!nullToAbsent || ichPersonId != null) {
      map['ich_person_id'] = Variable<String>(ichPersonId);
    }
    return map;
  }

  GruppeTabelleCompanion toCompanion(bool nullToAbsent) {
    return GruppeTabelleCompanion(
      id: Value(id),
      gruppeId: gruppeId == null && nullToAbsent
          ? const Value.absent()
          : Value(gruppeId),
      geaendert: Value(geaendert),
      geloescht: Value(geloescht),
      hochgeladen: Value(hochgeladen),
      name: Value(name),
      art: Value(art),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
      online: Value(online),
      ichPersonId: ichPersonId == null && nullToAbsent
          ? const Value.absent()
          : Value(ichPersonId),
    );
  }

  factory Gruppe.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Gruppe(
      id: serializer.fromJson<String>(json['id']),
      gruppeId: serializer.fromJson<String?>(json['gruppeId']),
      geaendert: serializer.fromJson<DateTime>(json['geaendert']),
      geloescht: serializer.fromJson<bool>(json['geloescht']),
      hochgeladen: serializer.fromJson<bool>(json['hochgeladen']),
      name: serializer.fromJson<String>(json['name']),
      art: serializer.fromJson<String>(json['art']),
      code: serializer.fromJson<String?>(json['code']),
      online: serializer.fromJson<bool>(json['online']),
      ichPersonId: serializer.fromJson<String?>(json['ichPersonId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'gruppeId': serializer.toJson<String?>(gruppeId),
      'geaendert': serializer.toJson<DateTime>(geaendert),
      'geloescht': serializer.toJson<bool>(geloescht),
      'hochgeladen': serializer.toJson<bool>(hochgeladen),
      'name': serializer.toJson<String>(name),
      'art': serializer.toJson<String>(art),
      'code': serializer.toJson<String?>(code),
      'online': serializer.toJson<bool>(online),
      'ichPersonId': serializer.toJson<String?>(ichPersonId),
    };
  }

  Gruppe copyWith({
    String? id,
    Value<String?> gruppeId = const Value.absent(),
    DateTime? geaendert,
    bool? geloescht,
    bool? hochgeladen,
    String? name,
    String? art,
    Value<String?> code = const Value.absent(),
    bool? online,
    Value<String?> ichPersonId = const Value.absent(),
  }) => Gruppe(
    id: id ?? this.id,
    gruppeId: gruppeId.present ? gruppeId.value : this.gruppeId,
    geaendert: geaendert ?? this.geaendert,
    geloescht: geloescht ?? this.geloescht,
    hochgeladen: hochgeladen ?? this.hochgeladen,
    name: name ?? this.name,
    art: art ?? this.art,
    code: code.present ? code.value : this.code,
    online: online ?? this.online,
    ichPersonId: ichPersonId.present ? ichPersonId.value : this.ichPersonId,
  );
  Gruppe copyWithCompanion(GruppeTabelleCompanion data) {
    return Gruppe(
      id: data.id.present ? data.id.value : this.id,
      gruppeId: data.gruppeId.present ? data.gruppeId.value : this.gruppeId,
      geaendert: data.geaendert.present ? data.geaendert.value : this.geaendert,
      geloescht: data.geloescht.present ? data.geloescht.value : this.geloescht,
      hochgeladen: data.hochgeladen.present
          ? data.hochgeladen.value
          : this.hochgeladen,
      name: data.name.present ? data.name.value : this.name,
      art: data.art.present ? data.art.value : this.art,
      code: data.code.present ? data.code.value : this.code,
      online: data.online.present ? data.online.value : this.online,
      ichPersonId: data.ichPersonId.present
          ? data.ichPersonId.value
          : this.ichPersonId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Gruppe(')
          ..write('id: $id, ')
          ..write('gruppeId: $gruppeId, ')
          ..write('geaendert: $geaendert, ')
          ..write('geloescht: $geloescht, ')
          ..write('hochgeladen: $hochgeladen, ')
          ..write('name: $name, ')
          ..write('art: $art, ')
          ..write('code: $code, ')
          ..write('online: $online, ')
          ..write('ichPersonId: $ichPersonId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    gruppeId,
    geaendert,
    geloescht,
    hochgeladen,
    name,
    art,
    code,
    online,
    ichPersonId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Gruppe &&
          other.id == this.id &&
          other.gruppeId == this.gruppeId &&
          other.geaendert == this.geaendert &&
          other.geloescht == this.geloescht &&
          other.hochgeladen == this.hochgeladen &&
          other.name == this.name &&
          other.art == this.art &&
          other.code == this.code &&
          other.online == this.online &&
          other.ichPersonId == this.ichPersonId);
}

class GruppeTabelleCompanion extends UpdateCompanion<Gruppe> {
  final Value<String> id;
  final Value<String?> gruppeId;
  final Value<DateTime> geaendert;
  final Value<bool> geloescht;
  final Value<bool> hochgeladen;
  final Value<String> name;
  final Value<String> art;
  final Value<String?> code;
  final Value<bool> online;
  final Value<String?> ichPersonId;
  final Value<int> rowid;
  const GruppeTabelleCompanion({
    this.id = const Value.absent(),
    this.gruppeId = const Value.absent(),
    this.geaendert = const Value.absent(),
    this.geloescht = const Value.absent(),
    this.hochgeladen = const Value.absent(),
    this.name = const Value.absent(),
    this.art = const Value.absent(),
    this.code = const Value.absent(),
    this.online = const Value.absent(),
    this.ichPersonId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GruppeTabelleCompanion.insert({
    required String id,
    this.gruppeId = const Value.absent(),
    required DateTime geaendert,
    this.geloescht = const Value.absent(),
    this.hochgeladen = const Value.absent(),
    required String name,
    this.art = const Value.absent(),
    this.code = const Value.absent(),
    this.online = const Value.absent(),
    this.ichPersonId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       geaendert = Value(geaendert),
       name = Value(name);
  static Insertable<Gruppe> custom({
    Expression<String>? id,
    Expression<String>? gruppeId,
    Expression<DateTime>? geaendert,
    Expression<bool>? geloescht,
    Expression<bool>? hochgeladen,
    Expression<String>? name,
    Expression<String>? art,
    Expression<String>? code,
    Expression<bool>? online,
    Expression<String>? ichPersonId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gruppeId != null) 'gruppe_id': gruppeId,
      if (geaendert != null) 'geaendert': geaendert,
      if (geloescht != null) 'geloescht': geloescht,
      if (hochgeladen != null) 'hochgeladen': hochgeladen,
      if (name != null) 'name': name,
      if (art != null) 'art': art,
      if (code != null) 'code': code,
      if (online != null) 'online': online,
      if (ichPersonId != null) 'ich_person_id': ichPersonId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GruppeTabelleCompanion copyWith({
    Value<String>? id,
    Value<String?>? gruppeId,
    Value<DateTime>? geaendert,
    Value<bool>? geloescht,
    Value<bool>? hochgeladen,
    Value<String>? name,
    Value<String>? art,
    Value<String?>? code,
    Value<bool>? online,
    Value<String?>? ichPersonId,
    Value<int>? rowid,
  }) {
    return GruppeTabelleCompanion(
      id: id ?? this.id,
      gruppeId: gruppeId ?? this.gruppeId,
      geaendert: geaendert ?? this.geaendert,
      geloescht: geloescht ?? this.geloescht,
      hochgeladen: hochgeladen ?? this.hochgeladen,
      name: name ?? this.name,
      art: art ?? this.art,
      code: code ?? this.code,
      online: online ?? this.online,
      ichPersonId: ichPersonId ?? this.ichPersonId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (gruppeId.present) {
      map['gruppe_id'] = Variable<String>(gruppeId.value);
    }
    if (geaendert.present) {
      map['geaendert'] = Variable<DateTime>(geaendert.value);
    }
    if (geloescht.present) {
      map['geloescht'] = Variable<bool>(geloescht.value);
    }
    if (hochgeladen.present) {
      map['hochgeladen'] = Variable<bool>(hochgeladen.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (art.present) {
      map['art'] = Variable<String>(art.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (online.present) {
      map['online'] = Variable<bool>(online.value);
    }
    if (ichPersonId.present) {
      map['ich_person_id'] = Variable<String>(ichPersonId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GruppeTabelleCompanion(')
          ..write('id: $id, ')
          ..write('gruppeId: $gruppeId, ')
          ..write('geaendert: $geaendert, ')
          ..write('geloescht: $geloescht, ')
          ..write('hochgeladen: $hochgeladen, ')
          ..write('name: $name, ')
          ..write('art: $art, ')
          ..write('code: $code, ')
          ..write('online: $online, ')
          ..write('ichPersonId: $ichPersonId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PersonTabelleTable extends PersonTabelle
    with TableInfo<$PersonTabelleTable, Person> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonTabelleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gruppeIdMeta = const VerificationMeta(
    'gruppeId',
  );
  @override
  late final GeneratedColumn<String> gruppeId = GeneratedColumn<String>(
    'gruppe_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _geloeschtMeta = const VerificationMeta(
    'geloescht',
  );
  @override
  late final GeneratedColumn<bool> geloescht = GeneratedColumn<bool>(
    'geloescht',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("geloescht" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hochgeladenMeta = const VerificationMeta(
    'hochgeladen',
  );
  @override
  late final GeneratedColumn<bool> hochgeladen = GeneratedColumn<bool>(
    'hochgeladen',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hochgeladen" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _farbeMeta = const VerificationMeta('farbe');
  @override
  late final GeneratedColumn<int> farbe = GeneratedColumn<int>(
    'farbe',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gruppeId,
    geaendert,
    geloescht,
    hochgeladen,
    name,
    farbe,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'personen';
  @override
  VerificationContext validateIntegrity(
    Insertable<Person> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('gruppe_id')) {
      context.handle(
        _gruppeIdMeta,
        gruppeId.isAcceptableOrUnknown(data['gruppe_id']!, _gruppeIdMeta),
      );
    }
    if (data.containsKey('geaendert')) {
      context.handle(
        _geaendertMeta,
        geaendert.isAcceptableOrUnknown(data['geaendert']!, _geaendertMeta),
      );
    } else if (isInserting) {
      context.missing(_geaendertMeta);
    }
    if (data.containsKey('geloescht')) {
      context.handle(
        _geloeschtMeta,
        geloescht.isAcceptableOrUnknown(data['geloescht']!, _geloeschtMeta),
      );
    }
    if (data.containsKey('hochgeladen')) {
      context.handle(
        _hochgeladenMeta,
        hochgeladen.isAcceptableOrUnknown(
          data['hochgeladen']!,
          _hochgeladenMeta,
        ),
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
    if (data.containsKey('farbe')) {
      context.handle(
        _farbeMeta,
        farbe.isAcceptableOrUnknown(data['farbe']!, _farbeMeta),
      );
    } else if (isInserting) {
      context.missing(_farbeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Person map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Person(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      gruppeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gruppe_id'],
      ),
      geaendert: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}geaendert'],
      )!,
      geloescht: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}geloescht'],
      )!,
      hochgeladen: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hochgeladen'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      farbe: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}farbe'],
      )!,
    );
  }

  @override
  $PersonTabelleTable createAlias(String alias) {
    return $PersonTabelleTable(attachedDatabase, alias);
  }
}

class Person extends DataClass implements Insertable<Person> {
  final String id;
  final String? gruppeId;
  final DateTime geaendert;
  final bool geloescht;
  final bool hochgeladen;
  final String name;
  final int farbe;
  const Person({
    required this.id,
    this.gruppeId,
    required this.geaendert,
    required this.geloescht,
    required this.hochgeladen,
    required this.name,
    required this.farbe,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || gruppeId != null) {
      map['gruppe_id'] = Variable<String>(gruppeId);
    }
    map['geaendert'] = Variable<DateTime>(geaendert);
    map['geloescht'] = Variable<bool>(geloescht);
    map['hochgeladen'] = Variable<bool>(hochgeladen);
    map['name'] = Variable<String>(name);
    map['farbe'] = Variable<int>(farbe);
    return map;
  }

  PersonTabelleCompanion toCompanion(bool nullToAbsent) {
    return PersonTabelleCompanion(
      id: Value(id),
      gruppeId: gruppeId == null && nullToAbsent
          ? const Value.absent()
          : Value(gruppeId),
      geaendert: Value(geaendert),
      geloescht: Value(geloescht),
      hochgeladen: Value(hochgeladen),
      name: Value(name),
      farbe: Value(farbe),
    );
  }

  factory Person.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Person(
      id: serializer.fromJson<String>(json['id']),
      gruppeId: serializer.fromJson<String?>(json['gruppeId']),
      geaendert: serializer.fromJson<DateTime>(json['geaendert']),
      geloescht: serializer.fromJson<bool>(json['geloescht']),
      hochgeladen: serializer.fromJson<bool>(json['hochgeladen']),
      name: serializer.fromJson<String>(json['name']),
      farbe: serializer.fromJson<int>(json['farbe']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'gruppeId': serializer.toJson<String?>(gruppeId),
      'geaendert': serializer.toJson<DateTime>(geaendert),
      'geloescht': serializer.toJson<bool>(geloescht),
      'hochgeladen': serializer.toJson<bool>(hochgeladen),
      'name': serializer.toJson<String>(name),
      'farbe': serializer.toJson<int>(farbe),
    };
  }

  Person copyWith({
    String? id,
    Value<String?> gruppeId = const Value.absent(),
    DateTime? geaendert,
    bool? geloescht,
    bool? hochgeladen,
    String? name,
    int? farbe,
  }) => Person(
    id: id ?? this.id,
    gruppeId: gruppeId.present ? gruppeId.value : this.gruppeId,
    geaendert: geaendert ?? this.geaendert,
    geloescht: geloescht ?? this.geloescht,
    hochgeladen: hochgeladen ?? this.hochgeladen,
    name: name ?? this.name,
    farbe: farbe ?? this.farbe,
  );
  Person copyWithCompanion(PersonTabelleCompanion data) {
    return Person(
      id: data.id.present ? data.id.value : this.id,
      gruppeId: data.gruppeId.present ? data.gruppeId.value : this.gruppeId,
      geaendert: data.geaendert.present ? data.geaendert.value : this.geaendert,
      geloescht: data.geloescht.present ? data.geloescht.value : this.geloescht,
      hochgeladen: data.hochgeladen.present
          ? data.hochgeladen.value
          : this.hochgeladen,
      name: data.name.present ? data.name.value : this.name,
      farbe: data.farbe.present ? data.farbe.value : this.farbe,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Person(')
          ..write('id: $id, ')
          ..write('gruppeId: $gruppeId, ')
          ..write('geaendert: $geaendert, ')
          ..write('geloescht: $geloescht, ')
          ..write('hochgeladen: $hochgeladen, ')
          ..write('name: $name, ')
          ..write('farbe: $farbe')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, gruppeId, geaendert, geloescht, hochgeladen, name, farbe);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Person &&
          other.id == this.id &&
          other.gruppeId == this.gruppeId &&
          other.geaendert == this.geaendert &&
          other.geloescht == this.geloescht &&
          other.hochgeladen == this.hochgeladen &&
          other.name == this.name &&
          other.farbe == this.farbe);
}

class PersonTabelleCompanion extends UpdateCompanion<Person> {
  final Value<String> id;
  final Value<String?> gruppeId;
  final Value<DateTime> geaendert;
  final Value<bool> geloescht;
  final Value<bool> hochgeladen;
  final Value<String> name;
  final Value<int> farbe;
  final Value<int> rowid;
  const PersonTabelleCompanion({
    this.id = const Value.absent(),
    this.gruppeId = const Value.absent(),
    this.geaendert = const Value.absent(),
    this.geloescht = const Value.absent(),
    this.hochgeladen = const Value.absent(),
    this.name = const Value.absent(),
    this.farbe = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonTabelleCompanion.insert({
    required String id,
    this.gruppeId = const Value.absent(),
    required DateTime geaendert,
    this.geloescht = const Value.absent(),
    this.hochgeladen = const Value.absent(),
    required String name,
    required int farbe,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       geaendert = Value(geaendert),
       name = Value(name),
       farbe = Value(farbe);
  static Insertable<Person> custom({
    Expression<String>? id,
    Expression<String>? gruppeId,
    Expression<DateTime>? geaendert,
    Expression<bool>? geloescht,
    Expression<bool>? hochgeladen,
    Expression<String>? name,
    Expression<int>? farbe,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gruppeId != null) 'gruppe_id': gruppeId,
      if (geaendert != null) 'geaendert': geaendert,
      if (geloescht != null) 'geloescht': geloescht,
      if (hochgeladen != null) 'hochgeladen': hochgeladen,
      if (name != null) 'name': name,
      if (farbe != null) 'farbe': farbe,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonTabelleCompanion copyWith({
    Value<String>? id,
    Value<String?>? gruppeId,
    Value<DateTime>? geaendert,
    Value<bool>? geloescht,
    Value<bool>? hochgeladen,
    Value<String>? name,
    Value<int>? farbe,
    Value<int>? rowid,
  }) {
    return PersonTabelleCompanion(
      id: id ?? this.id,
      gruppeId: gruppeId ?? this.gruppeId,
      geaendert: geaendert ?? this.geaendert,
      geloescht: geloescht ?? this.geloescht,
      hochgeladen: hochgeladen ?? this.hochgeladen,
      name: name ?? this.name,
      farbe: farbe ?? this.farbe,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (gruppeId.present) {
      map['gruppe_id'] = Variable<String>(gruppeId.value);
    }
    if (geaendert.present) {
      map['geaendert'] = Variable<DateTime>(geaendert.value);
    }
    if (geloescht.present) {
      map['geloescht'] = Variable<bool>(geloescht.value);
    }
    if (hochgeladen.present) {
      map['hochgeladen'] = Variable<bool>(hochgeladen.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (farbe.present) {
      map['farbe'] = Variable<int>(farbe.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonTabelleCompanion(')
          ..write('id: $id, ')
          ..write('gruppeId: $gruppeId, ')
          ..write('geaendert: $geaendert, ')
          ..write('geloescht: $geloescht, ')
          ..write('hochgeladen: $hochgeladen, ')
          ..write('name: $name, ')
          ..write('farbe: $farbe, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ListeTabelleTable extends ListeTabelle
    with TableInfo<$ListeTabelleTable, Liste> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ListeTabelleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gruppeIdMeta = const VerificationMeta(
    'gruppeId',
  );
  @override
  late final GeneratedColumn<String> gruppeId = GeneratedColumn<String>(
    'gruppe_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _geloeschtMeta = const VerificationMeta(
    'geloescht',
  );
  @override
  late final GeneratedColumn<bool> geloescht = GeneratedColumn<bool>(
    'geloescht',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("geloescht" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hochgeladenMeta = const VerificationMeta(
    'hochgeladen',
  );
  @override
  late final GeneratedColumn<bool> hochgeladen = GeneratedColumn<bool>(
    'hochgeladen',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hochgeladen" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _artMeta = const VerificationMeta('art');
  @override
  late final GeneratedColumn<String> art = GeneratedColumn<String>(
    'art',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('einkauf'),
  );
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
    'symbol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('🛒'),
  );
  static const VerificationMeta _fuerPersonIdMeta = const VerificationMeta(
    'fuerPersonId',
  );
  @override
  late final GeneratedColumn<String> fuerPersonId = GeneratedColumn<String>(
    'fuer_person_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gruppeId,
    geaendert,
    geloescht,
    hochgeladen,
    name,
    art,
    symbol,
    fuerPersonId,
    sortierung,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'listen';
  @override
  VerificationContext validateIntegrity(
    Insertable<Liste> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('gruppe_id')) {
      context.handle(
        _gruppeIdMeta,
        gruppeId.isAcceptableOrUnknown(data['gruppe_id']!, _gruppeIdMeta),
      );
    }
    if (data.containsKey('geaendert')) {
      context.handle(
        _geaendertMeta,
        geaendert.isAcceptableOrUnknown(data['geaendert']!, _geaendertMeta),
      );
    } else if (isInserting) {
      context.missing(_geaendertMeta);
    }
    if (data.containsKey('geloescht')) {
      context.handle(
        _geloeschtMeta,
        geloescht.isAcceptableOrUnknown(data['geloescht']!, _geloeschtMeta),
      );
    }
    if (data.containsKey('hochgeladen')) {
      context.handle(
        _hochgeladenMeta,
        hochgeladen.isAcceptableOrUnknown(
          data['hochgeladen']!,
          _hochgeladenMeta,
        ),
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
    if (data.containsKey('art')) {
      context.handle(
        _artMeta,
        art.isAcceptableOrUnknown(data['art']!, _artMeta),
      );
    }
    if (data.containsKey('symbol')) {
      context.handle(
        _symbolMeta,
        symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta),
      );
    }
    if (data.containsKey('fuer_person_id')) {
      context.handle(
        _fuerPersonIdMeta,
        fuerPersonId.isAcceptableOrUnknown(
          data['fuer_person_id']!,
          _fuerPersonIdMeta,
        ),
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
  Liste map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Liste(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      gruppeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gruppe_id'],
      ),
      geaendert: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}geaendert'],
      )!,
      geloescht: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}geloescht'],
      )!,
      hochgeladen: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hochgeladen'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      art: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}art'],
      )!,
      symbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symbol'],
      )!,
      fuerPersonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fuer_person_id'],
      ),
      sortierung: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sortierung'],
      )!,
    );
  }

  @override
  $ListeTabelleTable createAlias(String alias) {
    return $ListeTabelleTable(attachedDatabase, alias);
  }
}

class Liste extends DataClass implements Insertable<Liste> {
  final String id;
  final String? gruppeId;
  final DateTime geaendert;
  final bool geloescht;
  final bool hochgeladen;
  final String name;

  /// einkauf, packliste, mitnehmen
  final String art;
  final String symbol;

  /// Bei „Ich nehm was mit“: für wen eingekauft wird.
  final String? fuerPersonId;
  final int sortierung;
  const Liste({
    required this.id,
    this.gruppeId,
    required this.geaendert,
    required this.geloescht,
    required this.hochgeladen,
    required this.name,
    required this.art,
    required this.symbol,
    this.fuerPersonId,
    required this.sortierung,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || gruppeId != null) {
      map['gruppe_id'] = Variable<String>(gruppeId);
    }
    map['geaendert'] = Variable<DateTime>(geaendert);
    map['geloescht'] = Variable<bool>(geloescht);
    map['hochgeladen'] = Variable<bool>(hochgeladen);
    map['name'] = Variable<String>(name);
    map['art'] = Variable<String>(art);
    map['symbol'] = Variable<String>(symbol);
    if (!nullToAbsent || fuerPersonId != null) {
      map['fuer_person_id'] = Variable<String>(fuerPersonId);
    }
    map['sortierung'] = Variable<int>(sortierung);
    return map;
  }

  ListeTabelleCompanion toCompanion(bool nullToAbsent) {
    return ListeTabelleCompanion(
      id: Value(id),
      gruppeId: gruppeId == null && nullToAbsent
          ? const Value.absent()
          : Value(gruppeId),
      geaendert: Value(geaendert),
      geloescht: Value(geloescht),
      hochgeladen: Value(hochgeladen),
      name: Value(name),
      art: Value(art),
      symbol: Value(symbol),
      fuerPersonId: fuerPersonId == null && nullToAbsent
          ? const Value.absent()
          : Value(fuerPersonId),
      sortierung: Value(sortierung),
    );
  }

  factory Liste.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Liste(
      id: serializer.fromJson<String>(json['id']),
      gruppeId: serializer.fromJson<String?>(json['gruppeId']),
      geaendert: serializer.fromJson<DateTime>(json['geaendert']),
      geloescht: serializer.fromJson<bool>(json['geloescht']),
      hochgeladen: serializer.fromJson<bool>(json['hochgeladen']),
      name: serializer.fromJson<String>(json['name']),
      art: serializer.fromJson<String>(json['art']),
      symbol: serializer.fromJson<String>(json['symbol']),
      fuerPersonId: serializer.fromJson<String?>(json['fuerPersonId']),
      sortierung: serializer.fromJson<int>(json['sortierung']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'gruppeId': serializer.toJson<String?>(gruppeId),
      'geaendert': serializer.toJson<DateTime>(geaendert),
      'geloescht': serializer.toJson<bool>(geloescht),
      'hochgeladen': serializer.toJson<bool>(hochgeladen),
      'name': serializer.toJson<String>(name),
      'art': serializer.toJson<String>(art),
      'symbol': serializer.toJson<String>(symbol),
      'fuerPersonId': serializer.toJson<String?>(fuerPersonId),
      'sortierung': serializer.toJson<int>(sortierung),
    };
  }

  Liste copyWith({
    String? id,
    Value<String?> gruppeId = const Value.absent(),
    DateTime? geaendert,
    bool? geloescht,
    bool? hochgeladen,
    String? name,
    String? art,
    String? symbol,
    Value<String?> fuerPersonId = const Value.absent(),
    int? sortierung,
  }) => Liste(
    id: id ?? this.id,
    gruppeId: gruppeId.present ? gruppeId.value : this.gruppeId,
    geaendert: geaendert ?? this.geaendert,
    geloescht: geloescht ?? this.geloescht,
    hochgeladen: hochgeladen ?? this.hochgeladen,
    name: name ?? this.name,
    art: art ?? this.art,
    symbol: symbol ?? this.symbol,
    fuerPersonId: fuerPersonId.present ? fuerPersonId.value : this.fuerPersonId,
    sortierung: sortierung ?? this.sortierung,
  );
  Liste copyWithCompanion(ListeTabelleCompanion data) {
    return Liste(
      id: data.id.present ? data.id.value : this.id,
      gruppeId: data.gruppeId.present ? data.gruppeId.value : this.gruppeId,
      geaendert: data.geaendert.present ? data.geaendert.value : this.geaendert,
      geloescht: data.geloescht.present ? data.geloescht.value : this.geloescht,
      hochgeladen: data.hochgeladen.present
          ? data.hochgeladen.value
          : this.hochgeladen,
      name: data.name.present ? data.name.value : this.name,
      art: data.art.present ? data.art.value : this.art,
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      fuerPersonId: data.fuerPersonId.present
          ? data.fuerPersonId.value
          : this.fuerPersonId,
      sortierung: data.sortierung.present
          ? data.sortierung.value
          : this.sortierung,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Liste(')
          ..write('id: $id, ')
          ..write('gruppeId: $gruppeId, ')
          ..write('geaendert: $geaendert, ')
          ..write('geloescht: $geloescht, ')
          ..write('hochgeladen: $hochgeladen, ')
          ..write('name: $name, ')
          ..write('art: $art, ')
          ..write('symbol: $symbol, ')
          ..write('fuerPersonId: $fuerPersonId, ')
          ..write('sortierung: $sortierung')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    gruppeId,
    geaendert,
    geloescht,
    hochgeladen,
    name,
    art,
    symbol,
    fuerPersonId,
    sortierung,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Liste &&
          other.id == this.id &&
          other.gruppeId == this.gruppeId &&
          other.geaendert == this.geaendert &&
          other.geloescht == this.geloescht &&
          other.hochgeladen == this.hochgeladen &&
          other.name == this.name &&
          other.art == this.art &&
          other.symbol == this.symbol &&
          other.fuerPersonId == this.fuerPersonId &&
          other.sortierung == this.sortierung);
}

class ListeTabelleCompanion extends UpdateCompanion<Liste> {
  final Value<String> id;
  final Value<String?> gruppeId;
  final Value<DateTime> geaendert;
  final Value<bool> geloescht;
  final Value<bool> hochgeladen;
  final Value<String> name;
  final Value<String> art;
  final Value<String> symbol;
  final Value<String?> fuerPersonId;
  final Value<int> sortierung;
  final Value<int> rowid;
  const ListeTabelleCompanion({
    this.id = const Value.absent(),
    this.gruppeId = const Value.absent(),
    this.geaendert = const Value.absent(),
    this.geloescht = const Value.absent(),
    this.hochgeladen = const Value.absent(),
    this.name = const Value.absent(),
    this.art = const Value.absent(),
    this.symbol = const Value.absent(),
    this.fuerPersonId = const Value.absent(),
    this.sortierung = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ListeTabelleCompanion.insert({
    required String id,
    this.gruppeId = const Value.absent(),
    required DateTime geaendert,
    this.geloescht = const Value.absent(),
    this.hochgeladen = const Value.absent(),
    required String name,
    this.art = const Value.absent(),
    this.symbol = const Value.absent(),
    this.fuerPersonId = const Value.absent(),
    this.sortierung = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       geaendert = Value(geaendert),
       name = Value(name);
  static Insertable<Liste> custom({
    Expression<String>? id,
    Expression<String>? gruppeId,
    Expression<DateTime>? geaendert,
    Expression<bool>? geloescht,
    Expression<bool>? hochgeladen,
    Expression<String>? name,
    Expression<String>? art,
    Expression<String>? symbol,
    Expression<String>? fuerPersonId,
    Expression<int>? sortierung,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gruppeId != null) 'gruppe_id': gruppeId,
      if (geaendert != null) 'geaendert': geaendert,
      if (geloescht != null) 'geloescht': geloescht,
      if (hochgeladen != null) 'hochgeladen': hochgeladen,
      if (name != null) 'name': name,
      if (art != null) 'art': art,
      if (symbol != null) 'symbol': symbol,
      if (fuerPersonId != null) 'fuer_person_id': fuerPersonId,
      if (sortierung != null) 'sortierung': sortierung,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ListeTabelleCompanion copyWith({
    Value<String>? id,
    Value<String?>? gruppeId,
    Value<DateTime>? geaendert,
    Value<bool>? geloescht,
    Value<bool>? hochgeladen,
    Value<String>? name,
    Value<String>? art,
    Value<String>? symbol,
    Value<String?>? fuerPersonId,
    Value<int>? sortierung,
    Value<int>? rowid,
  }) {
    return ListeTabelleCompanion(
      id: id ?? this.id,
      gruppeId: gruppeId ?? this.gruppeId,
      geaendert: geaendert ?? this.geaendert,
      geloescht: geloescht ?? this.geloescht,
      hochgeladen: hochgeladen ?? this.hochgeladen,
      name: name ?? this.name,
      art: art ?? this.art,
      symbol: symbol ?? this.symbol,
      fuerPersonId: fuerPersonId ?? this.fuerPersonId,
      sortierung: sortierung ?? this.sortierung,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (gruppeId.present) {
      map['gruppe_id'] = Variable<String>(gruppeId.value);
    }
    if (geaendert.present) {
      map['geaendert'] = Variable<DateTime>(geaendert.value);
    }
    if (geloescht.present) {
      map['geloescht'] = Variable<bool>(geloescht.value);
    }
    if (hochgeladen.present) {
      map['hochgeladen'] = Variable<bool>(hochgeladen.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (art.present) {
      map['art'] = Variable<String>(art.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (fuerPersonId.present) {
      map['fuer_person_id'] = Variable<String>(fuerPersonId.value);
    }
    if (sortierung.present) {
      map['sortierung'] = Variable<int>(sortierung.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ListeTabelleCompanion(')
          ..write('id: $id, ')
          ..write('gruppeId: $gruppeId, ')
          ..write('geaendert: $geaendert, ')
          ..write('geloescht: $geloescht, ')
          ..write('hochgeladen: $hochgeladen, ')
          ..write('name: $name, ')
          ..write('art: $art, ')
          ..write('symbol: $symbol, ')
          ..write('fuerPersonId: $fuerPersonId, ')
          ..write('sortierung: $sortierung, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ArtikelTabelleTable extends ArtikelTabelle
    with TableInfo<$ArtikelTabelleTable, Artikel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArtikelTabelleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gruppeIdMeta = const VerificationMeta(
    'gruppeId',
  );
  @override
  late final GeneratedColumn<String> gruppeId = GeneratedColumn<String>(
    'gruppe_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _geloeschtMeta = const VerificationMeta(
    'geloescht',
  );
  @override
  late final GeneratedColumn<bool> geloescht = GeneratedColumn<bool>(
    'geloescht',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("geloescht" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hochgeladenMeta = const VerificationMeta(
    'hochgeladen',
  );
  @override
  late final GeneratedColumn<bool> hochgeladen = GeneratedColumn<bool>(
    'hochgeladen',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hochgeladen" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _listeIdMeta = const VerificationMeta(
    'listeId',
  );
  @override
  late final GeneratedColumn<String> listeId = GeneratedColumn<String>(
    'liste_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _mengeMeta = const VerificationMeta('menge');
  @override
  late final GeneratedColumn<String> menge = GeneratedColumn<String>(
    'menge',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _kategorieMeta = const VerificationMeta(
    'kategorie',
  );
  @override
  late final GeneratedColumn<String> kategorie = GeneratedColumn<String>(
    'kategorie',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _erledigtMeta = const VerificationMeta(
    'erledigt',
  );
  @override
  late final GeneratedColumn<bool> erledigt = GeneratedColumn<bool>(
    'erledigt',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("erledigt" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _erledigtVonMeta = const VerificationMeta(
    'erledigtVon',
  );
  @override
  late final GeneratedColumn<String> erledigtVon = GeneratedColumn<String>(
    'erledigt_von',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ausgabeIdMeta = const VerificationMeta(
    'ausgabeId',
  );
  @override
  late final GeneratedColumn<String> ausgabeId = GeneratedColumn<String>(
    'ausgabe_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gruppeId,
    geaendert,
    geloescht,
    hochgeladen,
    listeId,
    name,
    menge,
    kategorie,
    erledigt,
    erledigtVon,
    ausgabeId,
    sortierung,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'artikel';
  @override
  VerificationContext validateIntegrity(
    Insertable<Artikel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('gruppe_id')) {
      context.handle(
        _gruppeIdMeta,
        gruppeId.isAcceptableOrUnknown(data['gruppe_id']!, _gruppeIdMeta),
      );
    }
    if (data.containsKey('geaendert')) {
      context.handle(
        _geaendertMeta,
        geaendert.isAcceptableOrUnknown(data['geaendert']!, _geaendertMeta),
      );
    } else if (isInserting) {
      context.missing(_geaendertMeta);
    }
    if (data.containsKey('geloescht')) {
      context.handle(
        _geloeschtMeta,
        geloescht.isAcceptableOrUnknown(data['geloescht']!, _geloeschtMeta),
      );
    }
    if (data.containsKey('hochgeladen')) {
      context.handle(
        _hochgeladenMeta,
        hochgeladen.isAcceptableOrUnknown(
          data['hochgeladen']!,
          _hochgeladenMeta,
        ),
      );
    }
    if (data.containsKey('liste_id')) {
      context.handle(
        _listeIdMeta,
        listeId.isAcceptableOrUnknown(data['liste_id']!, _listeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_listeIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('menge')) {
      context.handle(
        _mengeMeta,
        menge.isAcceptableOrUnknown(data['menge']!, _mengeMeta),
      );
    }
    if (data.containsKey('kategorie')) {
      context.handle(
        _kategorieMeta,
        kategorie.isAcceptableOrUnknown(data['kategorie']!, _kategorieMeta),
      );
    }
    if (data.containsKey('erledigt')) {
      context.handle(
        _erledigtMeta,
        erledigt.isAcceptableOrUnknown(data['erledigt']!, _erledigtMeta),
      );
    }
    if (data.containsKey('erledigt_von')) {
      context.handle(
        _erledigtVonMeta,
        erledigtVon.isAcceptableOrUnknown(
          data['erledigt_von']!,
          _erledigtVonMeta,
        ),
      );
    }
    if (data.containsKey('ausgabe_id')) {
      context.handle(
        _ausgabeIdMeta,
        ausgabeId.isAcceptableOrUnknown(data['ausgabe_id']!, _ausgabeIdMeta),
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
  Artikel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Artikel(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      gruppeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gruppe_id'],
      ),
      geaendert: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}geaendert'],
      )!,
      geloescht: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}geloescht'],
      )!,
      hochgeladen: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hochgeladen'],
      )!,
      listeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}liste_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      menge: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}menge'],
      )!,
      kategorie: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kategorie'],
      )!,
      erledigt: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}erledigt'],
      )!,
      erledigtVon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}erledigt_von'],
      ),
      ausgabeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ausgabe_id'],
      ),
      sortierung: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sortierung'],
      )!,
    );
  }

  @override
  $ArtikelTabelleTable createAlias(String alias) {
    return $ArtikelTabelleTable(attachedDatabase, alias);
  }
}

class Artikel extends DataClass implements Insertable<Artikel> {
  final String id;
  final String? gruppeId;
  final DateTime geaendert;
  final bool geloescht;
  final bool hochgeladen;
  final String listeId;
  final String name;
  final String menge;

  /// Bei Packlisten die Kategorie (Kleidung, Technik …).
  final String kategorie;
  final bool erledigt;
  final String? erledigtVon;

  /// Ausgabe, die beim Abhaken entstanden ist.
  final String? ausgabeId;
  final int sortierung;
  const Artikel({
    required this.id,
    this.gruppeId,
    required this.geaendert,
    required this.geloescht,
    required this.hochgeladen,
    required this.listeId,
    required this.name,
    required this.menge,
    required this.kategorie,
    required this.erledigt,
    this.erledigtVon,
    this.ausgabeId,
    required this.sortierung,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || gruppeId != null) {
      map['gruppe_id'] = Variable<String>(gruppeId);
    }
    map['geaendert'] = Variable<DateTime>(geaendert);
    map['geloescht'] = Variable<bool>(geloescht);
    map['hochgeladen'] = Variable<bool>(hochgeladen);
    map['liste_id'] = Variable<String>(listeId);
    map['name'] = Variable<String>(name);
    map['menge'] = Variable<String>(menge);
    map['kategorie'] = Variable<String>(kategorie);
    map['erledigt'] = Variable<bool>(erledigt);
    if (!nullToAbsent || erledigtVon != null) {
      map['erledigt_von'] = Variable<String>(erledigtVon);
    }
    if (!nullToAbsent || ausgabeId != null) {
      map['ausgabe_id'] = Variable<String>(ausgabeId);
    }
    map['sortierung'] = Variable<int>(sortierung);
    return map;
  }

  ArtikelTabelleCompanion toCompanion(bool nullToAbsent) {
    return ArtikelTabelleCompanion(
      id: Value(id),
      gruppeId: gruppeId == null && nullToAbsent
          ? const Value.absent()
          : Value(gruppeId),
      geaendert: Value(geaendert),
      geloescht: Value(geloescht),
      hochgeladen: Value(hochgeladen),
      listeId: Value(listeId),
      name: Value(name),
      menge: Value(menge),
      kategorie: Value(kategorie),
      erledigt: Value(erledigt),
      erledigtVon: erledigtVon == null && nullToAbsent
          ? const Value.absent()
          : Value(erledigtVon),
      ausgabeId: ausgabeId == null && nullToAbsent
          ? const Value.absent()
          : Value(ausgabeId),
      sortierung: Value(sortierung),
    );
  }

  factory Artikel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Artikel(
      id: serializer.fromJson<String>(json['id']),
      gruppeId: serializer.fromJson<String?>(json['gruppeId']),
      geaendert: serializer.fromJson<DateTime>(json['geaendert']),
      geloescht: serializer.fromJson<bool>(json['geloescht']),
      hochgeladen: serializer.fromJson<bool>(json['hochgeladen']),
      listeId: serializer.fromJson<String>(json['listeId']),
      name: serializer.fromJson<String>(json['name']),
      menge: serializer.fromJson<String>(json['menge']),
      kategorie: serializer.fromJson<String>(json['kategorie']),
      erledigt: serializer.fromJson<bool>(json['erledigt']),
      erledigtVon: serializer.fromJson<String?>(json['erledigtVon']),
      ausgabeId: serializer.fromJson<String?>(json['ausgabeId']),
      sortierung: serializer.fromJson<int>(json['sortierung']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'gruppeId': serializer.toJson<String?>(gruppeId),
      'geaendert': serializer.toJson<DateTime>(geaendert),
      'geloescht': serializer.toJson<bool>(geloescht),
      'hochgeladen': serializer.toJson<bool>(hochgeladen),
      'listeId': serializer.toJson<String>(listeId),
      'name': serializer.toJson<String>(name),
      'menge': serializer.toJson<String>(menge),
      'kategorie': serializer.toJson<String>(kategorie),
      'erledigt': serializer.toJson<bool>(erledigt),
      'erledigtVon': serializer.toJson<String?>(erledigtVon),
      'ausgabeId': serializer.toJson<String?>(ausgabeId),
      'sortierung': serializer.toJson<int>(sortierung),
    };
  }

  Artikel copyWith({
    String? id,
    Value<String?> gruppeId = const Value.absent(),
    DateTime? geaendert,
    bool? geloescht,
    bool? hochgeladen,
    String? listeId,
    String? name,
    String? menge,
    String? kategorie,
    bool? erledigt,
    Value<String?> erledigtVon = const Value.absent(),
    Value<String?> ausgabeId = const Value.absent(),
    int? sortierung,
  }) => Artikel(
    id: id ?? this.id,
    gruppeId: gruppeId.present ? gruppeId.value : this.gruppeId,
    geaendert: geaendert ?? this.geaendert,
    geloescht: geloescht ?? this.geloescht,
    hochgeladen: hochgeladen ?? this.hochgeladen,
    listeId: listeId ?? this.listeId,
    name: name ?? this.name,
    menge: menge ?? this.menge,
    kategorie: kategorie ?? this.kategorie,
    erledigt: erledigt ?? this.erledigt,
    erledigtVon: erledigtVon.present ? erledigtVon.value : this.erledigtVon,
    ausgabeId: ausgabeId.present ? ausgabeId.value : this.ausgabeId,
    sortierung: sortierung ?? this.sortierung,
  );
  Artikel copyWithCompanion(ArtikelTabelleCompanion data) {
    return Artikel(
      id: data.id.present ? data.id.value : this.id,
      gruppeId: data.gruppeId.present ? data.gruppeId.value : this.gruppeId,
      geaendert: data.geaendert.present ? data.geaendert.value : this.geaendert,
      geloescht: data.geloescht.present ? data.geloescht.value : this.geloescht,
      hochgeladen: data.hochgeladen.present
          ? data.hochgeladen.value
          : this.hochgeladen,
      listeId: data.listeId.present ? data.listeId.value : this.listeId,
      name: data.name.present ? data.name.value : this.name,
      menge: data.menge.present ? data.menge.value : this.menge,
      kategorie: data.kategorie.present ? data.kategorie.value : this.kategorie,
      erledigt: data.erledigt.present ? data.erledigt.value : this.erledigt,
      erledigtVon: data.erledigtVon.present
          ? data.erledigtVon.value
          : this.erledigtVon,
      ausgabeId: data.ausgabeId.present ? data.ausgabeId.value : this.ausgabeId,
      sortierung: data.sortierung.present
          ? data.sortierung.value
          : this.sortierung,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Artikel(')
          ..write('id: $id, ')
          ..write('gruppeId: $gruppeId, ')
          ..write('geaendert: $geaendert, ')
          ..write('geloescht: $geloescht, ')
          ..write('hochgeladen: $hochgeladen, ')
          ..write('listeId: $listeId, ')
          ..write('name: $name, ')
          ..write('menge: $menge, ')
          ..write('kategorie: $kategorie, ')
          ..write('erledigt: $erledigt, ')
          ..write('erledigtVon: $erledigtVon, ')
          ..write('ausgabeId: $ausgabeId, ')
          ..write('sortierung: $sortierung')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    gruppeId,
    geaendert,
    geloescht,
    hochgeladen,
    listeId,
    name,
    menge,
    kategorie,
    erledigt,
    erledigtVon,
    ausgabeId,
    sortierung,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Artikel &&
          other.id == this.id &&
          other.gruppeId == this.gruppeId &&
          other.geaendert == this.geaendert &&
          other.geloescht == this.geloescht &&
          other.hochgeladen == this.hochgeladen &&
          other.listeId == this.listeId &&
          other.name == this.name &&
          other.menge == this.menge &&
          other.kategorie == this.kategorie &&
          other.erledigt == this.erledigt &&
          other.erledigtVon == this.erledigtVon &&
          other.ausgabeId == this.ausgabeId &&
          other.sortierung == this.sortierung);
}

class ArtikelTabelleCompanion extends UpdateCompanion<Artikel> {
  final Value<String> id;
  final Value<String?> gruppeId;
  final Value<DateTime> geaendert;
  final Value<bool> geloescht;
  final Value<bool> hochgeladen;
  final Value<String> listeId;
  final Value<String> name;
  final Value<String> menge;
  final Value<String> kategorie;
  final Value<bool> erledigt;
  final Value<String?> erledigtVon;
  final Value<String?> ausgabeId;
  final Value<int> sortierung;
  final Value<int> rowid;
  const ArtikelTabelleCompanion({
    this.id = const Value.absent(),
    this.gruppeId = const Value.absent(),
    this.geaendert = const Value.absent(),
    this.geloescht = const Value.absent(),
    this.hochgeladen = const Value.absent(),
    this.listeId = const Value.absent(),
    this.name = const Value.absent(),
    this.menge = const Value.absent(),
    this.kategorie = const Value.absent(),
    this.erledigt = const Value.absent(),
    this.erledigtVon = const Value.absent(),
    this.ausgabeId = const Value.absent(),
    this.sortierung = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ArtikelTabelleCompanion.insert({
    required String id,
    this.gruppeId = const Value.absent(),
    required DateTime geaendert,
    this.geloescht = const Value.absent(),
    this.hochgeladen = const Value.absent(),
    required String listeId,
    required String name,
    this.menge = const Value.absent(),
    this.kategorie = const Value.absent(),
    this.erledigt = const Value.absent(),
    this.erledigtVon = const Value.absent(),
    this.ausgabeId = const Value.absent(),
    this.sortierung = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       geaendert = Value(geaendert),
       listeId = Value(listeId),
       name = Value(name);
  static Insertable<Artikel> custom({
    Expression<String>? id,
    Expression<String>? gruppeId,
    Expression<DateTime>? geaendert,
    Expression<bool>? geloescht,
    Expression<bool>? hochgeladen,
    Expression<String>? listeId,
    Expression<String>? name,
    Expression<String>? menge,
    Expression<String>? kategorie,
    Expression<bool>? erledigt,
    Expression<String>? erledigtVon,
    Expression<String>? ausgabeId,
    Expression<int>? sortierung,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gruppeId != null) 'gruppe_id': gruppeId,
      if (geaendert != null) 'geaendert': geaendert,
      if (geloescht != null) 'geloescht': geloescht,
      if (hochgeladen != null) 'hochgeladen': hochgeladen,
      if (listeId != null) 'liste_id': listeId,
      if (name != null) 'name': name,
      if (menge != null) 'menge': menge,
      if (kategorie != null) 'kategorie': kategorie,
      if (erledigt != null) 'erledigt': erledigt,
      if (erledigtVon != null) 'erledigt_von': erledigtVon,
      if (ausgabeId != null) 'ausgabe_id': ausgabeId,
      if (sortierung != null) 'sortierung': sortierung,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ArtikelTabelleCompanion copyWith({
    Value<String>? id,
    Value<String?>? gruppeId,
    Value<DateTime>? geaendert,
    Value<bool>? geloescht,
    Value<bool>? hochgeladen,
    Value<String>? listeId,
    Value<String>? name,
    Value<String>? menge,
    Value<String>? kategorie,
    Value<bool>? erledigt,
    Value<String?>? erledigtVon,
    Value<String?>? ausgabeId,
    Value<int>? sortierung,
    Value<int>? rowid,
  }) {
    return ArtikelTabelleCompanion(
      id: id ?? this.id,
      gruppeId: gruppeId ?? this.gruppeId,
      geaendert: geaendert ?? this.geaendert,
      geloescht: geloescht ?? this.geloescht,
      hochgeladen: hochgeladen ?? this.hochgeladen,
      listeId: listeId ?? this.listeId,
      name: name ?? this.name,
      menge: menge ?? this.menge,
      kategorie: kategorie ?? this.kategorie,
      erledigt: erledigt ?? this.erledigt,
      erledigtVon: erledigtVon ?? this.erledigtVon,
      ausgabeId: ausgabeId ?? this.ausgabeId,
      sortierung: sortierung ?? this.sortierung,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (gruppeId.present) {
      map['gruppe_id'] = Variable<String>(gruppeId.value);
    }
    if (geaendert.present) {
      map['geaendert'] = Variable<DateTime>(geaendert.value);
    }
    if (geloescht.present) {
      map['geloescht'] = Variable<bool>(geloescht.value);
    }
    if (hochgeladen.present) {
      map['hochgeladen'] = Variable<bool>(hochgeladen.value);
    }
    if (listeId.present) {
      map['liste_id'] = Variable<String>(listeId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (menge.present) {
      map['menge'] = Variable<String>(menge.value);
    }
    if (kategorie.present) {
      map['kategorie'] = Variable<String>(kategorie.value);
    }
    if (erledigt.present) {
      map['erledigt'] = Variable<bool>(erledigt.value);
    }
    if (erledigtVon.present) {
      map['erledigt_von'] = Variable<String>(erledigtVon.value);
    }
    if (ausgabeId.present) {
      map['ausgabe_id'] = Variable<String>(ausgabeId.value);
    }
    if (sortierung.present) {
      map['sortierung'] = Variable<int>(sortierung.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArtikelTabelleCompanion(')
          ..write('id: $id, ')
          ..write('gruppeId: $gruppeId, ')
          ..write('geaendert: $geaendert, ')
          ..write('geloescht: $geloescht, ')
          ..write('hochgeladen: $hochgeladen, ')
          ..write('listeId: $listeId, ')
          ..write('name: $name, ')
          ..write('menge: $menge, ')
          ..write('kategorie: $kategorie, ')
          ..write('erledigt: $erledigt, ')
          ..write('erledigtVon: $erledigtVon, ')
          ..write('ausgabeId: $ausgabeId, ')
          ..write('sortierung: $sortierung, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AusgabeTabelleTable extends AusgabeTabelle
    with TableInfo<$AusgabeTabelleTable, Ausgabe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AusgabeTabelleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gruppeIdMeta = const VerificationMeta(
    'gruppeId',
  );
  @override
  late final GeneratedColumn<String> gruppeId = GeneratedColumn<String>(
    'gruppe_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _geloeschtMeta = const VerificationMeta(
    'geloescht',
  );
  @override
  late final GeneratedColumn<bool> geloescht = GeneratedColumn<bool>(
    'geloescht',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("geloescht" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hochgeladenMeta = const VerificationMeta(
    'hochgeladen',
  );
  @override
  late final GeneratedColumn<bool> hochgeladen = GeneratedColumn<bool>(
    'hochgeladen',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hochgeladen" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _betragCentMeta = const VerificationMeta(
    'betragCent',
  );
  @override
  late final GeneratedColumn<int> betragCent = GeneratedColumn<int>(
    'betrag_cent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _zahlerIdMeta = const VerificationMeta(
    'zahlerId',
  );
  @override
  late final GeneratedColumn<String> zahlerId = GeneratedColumn<String>(
    'zahler_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _anteileMeta = const VerificationMeta(
    'anteile',
  );
  @override
  late final GeneratedColumn<String> anteile = GeneratedColumn<String>(
    'anteile',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _datumMeta = const VerificationMeta('datum');
  @override
  late final GeneratedColumn<DateTime> datum = GeneratedColumn<DateTime>(
    'datum',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artMeta = const VerificationMeta('art');
  @override
  late final GeneratedColumn<String> art = GeneratedColumn<String>(
    'art',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ausgabe'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gruppeId,
    geaendert,
    geloescht,
    hochgeladen,
    titel,
    betragCent,
    zahlerId,
    anteile,
    datum,
    art,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ausgaben';
  @override
  VerificationContext validateIntegrity(
    Insertable<Ausgabe> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('gruppe_id')) {
      context.handle(
        _gruppeIdMeta,
        gruppeId.isAcceptableOrUnknown(data['gruppe_id']!, _gruppeIdMeta),
      );
    }
    if (data.containsKey('geaendert')) {
      context.handle(
        _geaendertMeta,
        geaendert.isAcceptableOrUnknown(data['geaendert']!, _geaendertMeta),
      );
    } else if (isInserting) {
      context.missing(_geaendertMeta);
    }
    if (data.containsKey('geloescht')) {
      context.handle(
        _geloeschtMeta,
        geloescht.isAcceptableOrUnknown(data['geloescht']!, _geloeschtMeta),
      );
    }
    if (data.containsKey('hochgeladen')) {
      context.handle(
        _hochgeladenMeta,
        hochgeladen.isAcceptableOrUnknown(
          data['hochgeladen']!,
          _hochgeladenMeta,
        ),
      );
    }
    if (data.containsKey('titel')) {
      context.handle(
        _titelMeta,
        titel.isAcceptableOrUnknown(data['titel']!, _titelMeta),
      );
    } else if (isInserting) {
      context.missing(_titelMeta);
    }
    if (data.containsKey('betrag_cent')) {
      context.handle(
        _betragCentMeta,
        betragCent.isAcceptableOrUnknown(data['betrag_cent']!, _betragCentMeta),
      );
    } else if (isInserting) {
      context.missing(_betragCentMeta);
    }
    if (data.containsKey('zahler_id')) {
      context.handle(
        _zahlerIdMeta,
        zahlerId.isAcceptableOrUnknown(data['zahler_id']!, _zahlerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_zahlerIdMeta);
    }
    if (data.containsKey('anteile')) {
      context.handle(
        _anteileMeta,
        anteile.isAcceptableOrUnknown(data['anteile']!, _anteileMeta),
      );
    } else if (isInserting) {
      context.missing(_anteileMeta);
    }
    if (data.containsKey('datum')) {
      context.handle(
        _datumMeta,
        datum.isAcceptableOrUnknown(data['datum']!, _datumMeta),
      );
    } else if (isInserting) {
      context.missing(_datumMeta);
    }
    if (data.containsKey('art')) {
      context.handle(
        _artMeta,
        art.isAcceptableOrUnknown(data['art']!, _artMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Ausgabe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Ausgabe(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      gruppeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gruppe_id'],
      ),
      geaendert: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}geaendert'],
      )!,
      geloescht: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}geloescht'],
      )!,
      hochgeladen: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hochgeladen'],
      )!,
      titel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}titel'],
      )!,
      betragCent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}betrag_cent'],
      )!,
      zahlerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}zahler_id'],
      )!,
      anteile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}anteile'],
      )!,
      datum: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}datum'],
      )!,
      art: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}art'],
      )!,
    );
  }

  @override
  $AusgabeTabelleTable createAlias(String alias) {
    return $AusgabeTabelleTable(attachedDatabase, alias);
  }
}

class Ausgabe extends DataClass implements Insertable<Ausgabe> {
  final String id;
  final String? gruppeId;
  final DateTime geaendert;
  final bool geloescht;
  final bool hochgeladen;
  final String titel;
  final int betragCent;
  final String zahlerId;

  /// JSON: {personId: gewicht}
  final String anteile;
  final DateTime datum;

  /// ausgabe oder zahlung (Rückzahlung zwischen zwei Personen)
  final String art;
  const Ausgabe({
    required this.id,
    this.gruppeId,
    required this.geaendert,
    required this.geloescht,
    required this.hochgeladen,
    required this.titel,
    required this.betragCent,
    required this.zahlerId,
    required this.anteile,
    required this.datum,
    required this.art,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || gruppeId != null) {
      map['gruppe_id'] = Variable<String>(gruppeId);
    }
    map['geaendert'] = Variable<DateTime>(geaendert);
    map['geloescht'] = Variable<bool>(geloescht);
    map['hochgeladen'] = Variable<bool>(hochgeladen);
    map['titel'] = Variable<String>(titel);
    map['betrag_cent'] = Variable<int>(betragCent);
    map['zahler_id'] = Variable<String>(zahlerId);
    map['anteile'] = Variable<String>(anteile);
    map['datum'] = Variable<DateTime>(datum);
    map['art'] = Variable<String>(art);
    return map;
  }

  AusgabeTabelleCompanion toCompanion(bool nullToAbsent) {
    return AusgabeTabelleCompanion(
      id: Value(id),
      gruppeId: gruppeId == null && nullToAbsent
          ? const Value.absent()
          : Value(gruppeId),
      geaendert: Value(geaendert),
      geloescht: Value(geloescht),
      hochgeladen: Value(hochgeladen),
      titel: Value(titel),
      betragCent: Value(betragCent),
      zahlerId: Value(zahlerId),
      anteile: Value(anteile),
      datum: Value(datum),
      art: Value(art),
    );
  }

  factory Ausgabe.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Ausgabe(
      id: serializer.fromJson<String>(json['id']),
      gruppeId: serializer.fromJson<String?>(json['gruppeId']),
      geaendert: serializer.fromJson<DateTime>(json['geaendert']),
      geloescht: serializer.fromJson<bool>(json['geloescht']),
      hochgeladen: serializer.fromJson<bool>(json['hochgeladen']),
      titel: serializer.fromJson<String>(json['titel']),
      betragCent: serializer.fromJson<int>(json['betragCent']),
      zahlerId: serializer.fromJson<String>(json['zahlerId']),
      anteile: serializer.fromJson<String>(json['anteile']),
      datum: serializer.fromJson<DateTime>(json['datum']),
      art: serializer.fromJson<String>(json['art']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'gruppeId': serializer.toJson<String?>(gruppeId),
      'geaendert': serializer.toJson<DateTime>(geaendert),
      'geloescht': serializer.toJson<bool>(geloescht),
      'hochgeladen': serializer.toJson<bool>(hochgeladen),
      'titel': serializer.toJson<String>(titel),
      'betragCent': serializer.toJson<int>(betragCent),
      'zahlerId': serializer.toJson<String>(zahlerId),
      'anteile': serializer.toJson<String>(anteile),
      'datum': serializer.toJson<DateTime>(datum),
      'art': serializer.toJson<String>(art),
    };
  }

  Ausgabe copyWith({
    String? id,
    Value<String?> gruppeId = const Value.absent(),
    DateTime? geaendert,
    bool? geloescht,
    bool? hochgeladen,
    String? titel,
    int? betragCent,
    String? zahlerId,
    String? anteile,
    DateTime? datum,
    String? art,
  }) => Ausgabe(
    id: id ?? this.id,
    gruppeId: gruppeId.present ? gruppeId.value : this.gruppeId,
    geaendert: geaendert ?? this.geaendert,
    geloescht: geloescht ?? this.geloescht,
    hochgeladen: hochgeladen ?? this.hochgeladen,
    titel: titel ?? this.titel,
    betragCent: betragCent ?? this.betragCent,
    zahlerId: zahlerId ?? this.zahlerId,
    anteile: anteile ?? this.anteile,
    datum: datum ?? this.datum,
    art: art ?? this.art,
  );
  Ausgabe copyWithCompanion(AusgabeTabelleCompanion data) {
    return Ausgabe(
      id: data.id.present ? data.id.value : this.id,
      gruppeId: data.gruppeId.present ? data.gruppeId.value : this.gruppeId,
      geaendert: data.geaendert.present ? data.geaendert.value : this.geaendert,
      geloescht: data.geloescht.present ? data.geloescht.value : this.geloescht,
      hochgeladen: data.hochgeladen.present
          ? data.hochgeladen.value
          : this.hochgeladen,
      titel: data.titel.present ? data.titel.value : this.titel,
      betragCent: data.betragCent.present
          ? data.betragCent.value
          : this.betragCent,
      zahlerId: data.zahlerId.present ? data.zahlerId.value : this.zahlerId,
      anteile: data.anteile.present ? data.anteile.value : this.anteile,
      datum: data.datum.present ? data.datum.value : this.datum,
      art: data.art.present ? data.art.value : this.art,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Ausgabe(')
          ..write('id: $id, ')
          ..write('gruppeId: $gruppeId, ')
          ..write('geaendert: $geaendert, ')
          ..write('geloescht: $geloescht, ')
          ..write('hochgeladen: $hochgeladen, ')
          ..write('titel: $titel, ')
          ..write('betragCent: $betragCent, ')
          ..write('zahlerId: $zahlerId, ')
          ..write('anteile: $anteile, ')
          ..write('datum: $datum, ')
          ..write('art: $art')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    gruppeId,
    geaendert,
    geloescht,
    hochgeladen,
    titel,
    betragCent,
    zahlerId,
    anteile,
    datum,
    art,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Ausgabe &&
          other.id == this.id &&
          other.gruppeId == this.gruppeId &&
          other.geaendert == this.geaendert &&
          other.geloescht == this.geloescht &&
          other.hochgeladen == this.hochgeladen &&
          other.titel == this.titel &&
          other.betragCent == this.betragCent &&
          other.zahlerId == this.zahlerId &&
          other.anteile == this.anteile &&
          other.datum == this.datum &&
          other.art == this.art);
}

class AusgabeTabelleCompanion extends UpdateCompanion<Ausgabe> {
  final Value<String> id;
  final Value<String?> gruppeId;
  final Value<DateTime> geaendert;
  final Value<bool> geloescht;
  final Value<bool> hochgeladen;
  final Value<String> titel;
  final Value<int> betragCent;
  final Value<String> zahlerId;
  final Value<String> anteile;
  final Value<DateTime> datum;
  final Value<String> art;
  final Value<int> rowid;
  const AusgabeTabelleCompanion({
    this.id = const Value.absent(),
    this.gruppeId = const Value.absent(),
    this.geaendert = const Value.absent(),
    this.geloescht = const Value.absent(),
    this.hochgeladen = const Value.absent(),
    this.titel = const Value.absent(),
    this.betragCent = const Value.absent(),
    this.zahlerId = const Value.absent(),
    this.anteile = const Value.absent(),
    this.datum = const Value.absent(),
    this.art = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AusgabeTabelleCompanion.insert({
    required String id,
    this.gruppeId = const Value.absent(),
    required DateTime geaendert,
    this.geloescht = const Value.absent(),
    this.hochgeladen = const Value.absent(),
    required String titel,
    required int betragCent,
    required String zahlerId,
    required String anteile,
    required DateTime datum,
    this.art = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       geaendert = Value(geaendert),
       titel = Value(titel),
       betragCent = Value(betragCent),
       zahlerId = Value(zahlerId),
       anteile = Value(anteile),
       datum = Value(datum);
  static Insertable<Ausgabe> custom({
    Expression<String>? id,
    Expression<String>? gruppeId,
    Expression<DateTime>? geaendert,
    Expression<bool>? geloescht,
    Expression<bool>? hochgeladen,
    Expression<String>? titel,
    Expression<int>? betragCent,
    Expression<String>? zahlerId,
    Expression<String>? anteile,
    Expression<DateTime>? datum,
    Expression<String>? art,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gruppeId != null) 'gruppe_id': gruppeId,
      if (geaendert != null) 'geaendert': geaendert,
      if (geloescht != null) 'geloescht': geloescht,
      if (hochgeladen != null) 'hochgeladen': hochgeladen,
      if (titel != null) 'titel': titel,
      if (betragCent != null) 'betrag_cent': betragCent,
      if (zahlerId != null) 'zahler_id': zahlerId,
      if (anteile != null) 'anteile': anteile,
      if (datum != null) 'datum': datum,
      if (art != null) 'art': art,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AusgabeTabelleCompanion copyWith({
    Value<String>? id,
    Value<String?>? gruppeId,
    Value<DateTime>? geaendert,
    Value<bool>? geloescht,
    Value<bool>? hochgeladen,
    Value<String>? titel,
    Value<int>? betragCent,
    Value<String>? zahlerId,
    Value<String>? anteile,
    Value<DateTime>? datum,
    Value<String>? art,
    Value<int>? rowid,
  }) {
    return AusgabeTabelleCompanion(
      id: id ?? this.id,
      gruppeId: gruppeId ?? this.gruppeId,
      geaendert: geaendert ?? this.geaendert,
      geloescht: geloescht ?? this.geloescht,
      hochgeladen: hochgeladen ?? this.hochgeladen,
      titel: titel ?? this.titel,
      betragCent: betragCent ?? this.betragCent,
      zahlerId: zahlerId ?? this.zahlerId,
      anteile: anteile ?? this.anteile,
      datum: datum ?? this.datum,
      art: art ?? this.art,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (gruppeId.present) {
      map['gruppe_id'] = Variable<String>(gruppeId.value);
    }
    if (geaendert.present) {
      map['geaendert'] = Variable<DateTime>(geaendert.value);
    }
    if (geloescht.present) {
      map['geloescht'] = Variable<bool>(geloescht.value);
    }
    if (hochgeladen.present) {
      map['hochgeladen'] = Variable<bool>(hochgeladen.value);
    }
    if (titel.present) {
      map['titel'] = Variable<String>(titel.value);
    }
    if (betragCent.present) {
      map['betrag_cent'] = Variable<int>(betragCent.value);
    }
    if (zahlerId.present) {
      map['zahler_id'] = Variable<String>(zahlerId.value);
    }
    if (anteile.present) {
      map['anteile'] = Variable<String>(anteile.value);
    }
    if (datum.present) {
      map['datum'] = Variable<DateTime>(datum.value);
    }
    if (art.present) {
      map['art'] = Variable<String>(art.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AusgabeTabelleCompanion(')
          ..write('id: $id, ')
          ..write('gruppeId: $gruppeId, ')
          ..write('geaendert: $geaendert, ')
          ..write('geloescht: $geloescht, ')
          ..write('hochgeladen: $hochgeladen, ')
          ..write('titel: $titel, ')
          ..write('betragCent: $betragCent, ')
          ..write('zahlerId: $zahlerId, ')
          ..write('anteile: $anteile, ')
          ..write('datum: $datum, ')
          ..write('art: $art, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VorlageTabelleTable extends VorlageTabelle
    with TableInfo<$VorlageTabelleTable, Vorlage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VorlageTabelleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    defaultValue: const Constant('🧳'),
  );
  static const VerificationMeta _artikelMeta = const VerificationMeta(
    'artikel',
  );
  @override
  late final GeneratedColumn<String> artikel = GeneratedColumn<String>(
    'artikel',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, symbol, artikel];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vorlagen';
  @override
  VerificationContext validateIntegrity(
    Insertable<Vorlage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    if (data.containsKey('artikel')) {
      context.handle(
        _artikelMeta,
        artikel.isAcceptableOrUnknown(data['artikel']!, _artikelMeta),
      );
    } else if (isInserting) {
      context.missing(_artikelMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Vorlage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Vorlage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
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
      artikel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artikel'],
      )!,
    );
  }

  @override
  $VorlageTabelleTable createAlias(String alias) {
    return $VorlageTabelleTable(attachedDatabase, alias);
  }
}

class Vorlage extends DataClass implements Insertable<Vorlage> {
  final String id;
  final String name;
  final String symbol;

  /// JSON: {kategorie: [artikel, …]}
  final String artikel;
  const Vorlage({
    required this.id,
    required this.name,
    required this.symbol,
    required this.artikel,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['symbol'] = Variable<String>(symbol);
    map['artikel'] = Variable<String>(artikel);
    return map;
  }

  VorlageTabelleCompanion toCompanion(bool nullToAbsent) {
    return VorlageTabelleCompanion(
      id: Value(id),
      name: Value(name),
      symbol: Value(symbol),
      artikel: Value(artikel),
    );
  }

  factory Vorlage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Vorlage(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      symbol: serializer.fromJson<String>(json['symbol']),
      artikel: serializer.fromJson<String>(json['artikel']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'symbol': serializer.toJson<String>(symbol),
      'artikel': serializer.toJson<String>(artikel),
    };
  }

  Vorlage copyWith({
    String? id,
    String? name,
    String? symbol,
    String? artikel,
  }) => Vorlage(
    id: id ?? this.id,
    name: name ?? this.name,
    symbol: symbol ?? this.symbol,
    artikel: artikel ?? this.artikel,
  );
  Vorlage copyWithCompanion(VorlageTabelleCompanion data) {
    return Vorlage(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      artikel: data.artikel.present ? data.artikel.value : this.artikel,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Vorlage(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('symbol: $symbol, ')
          ..write('artikel: $artikel')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, symbol, artikel);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vorlage &&
          other.id == this.id &&
          other.name == this.name &&
          other.symbol == this.symbol &&
          other.artikel == this.artikel);
}

class VorlageTabelleCompanion extends UpdateCompanion<Vorlage> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> symbol;
  final Value<String> artikel;
  final Value<int> rowid;
  const VorlageTabelleCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.symbol = const Value.absent(),
    this.artikel = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VorlageTabelleCompanion.insert({
    required String id,
    required String name,
    this.symbol = const Value.absent(),
    required String artikel,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       artikel = Value(artikel);
  static Insertable<Vorlage> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? symbol,
    Expression<String>? artikel,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (symbol != null) 'symbol': symbol,
      if (artikel != null) 'artikel': artikel,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VorlageTabelleCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? symbol,
    Value<String>? artikel,
    Value<int>? rowid,
  }) {
    return VorlageTabelleCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      artikel: artikel ?? this.artikel,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (artikel.present) {
      map['artikel'] = Variable<String>(artikel.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VorlageTabelleCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('symbol: $symbol, ')
          ..write('artikel: $artikel, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatenbank extends GeneratedDatabase {
  _$AppDatenbank(QueryExecutor e) : super(e);
  $AppDatenbankManager get managers => $AppDatenbankManager(this);
  late final $GruppeTabelleTable gruppeTabelle = $GruppeTabelleTable(this);
  late final $PersonTabelleTable personTabelle = $PersonTabelleTable(this);
  late final $ListeTabelleTable listeTabelle = $ListeTabelleTable(this);
  late final $ArtikelTabelleTable artikelTabelle = $ArtikelTabelleTable(this);
  late final $AusgabeTabelleTable ausgabeTabelle = $AusgabeTabelleTable(this);
  late final $VorlageTabelleTable vorlageTabelle = $VorlageTabelleTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    gruppeTabelle,
    personTabelle,
    listeTabelle,
    artikelTabelle,
    ausgabeTabelle,
    vorlageTabelle,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$GruppeTabelleTableCreateCompanionBuilder =
    GruppeTabelleCompanion Function({
      required String id,
      Value<String?> gruppeId,
      required DateTime geaendert,
      Value<bool> geloescht,
      Value<bool> hochgeladen,
      required String name,
      Value<String> art,
      Value<String?> code,
      Value<bool> online,
      Value<String?> ichPersonId,
      Value<int> rowid,
    });
typedef $$GruppeTabelleTableUpdateCompanionBuilder =
    GruppeTabelleCompanion Function({
      Value<String> id,
      Value<String?> gruppeId,
      Value<DateTime> geaendert,
      Value<bool> geloescht,
      Value<bool> hochgeladen,
      Value<String> name,
      Value<String> art,
      Value<String?> code,
      Value<bool> online,
      Value<String?> ichPersonId,
      Value<int> rowid,
    });

class $$GruppeTabelleTableFilterComposer
    extends Composer<_$AppDatenbank, $GruppeTabelleTable> {
  $$GruppeTabelleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gruppeId => $composableBuilder(
    column: $table.gruppeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get geaendert => $composableBuilder(
    column: $table.geaendert,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get geloescht => $composableBuilder(
    column: $table.geloescht,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hochgeladen => $composableBuilder(
    column: $table.hochgeladen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get art => $composableBuilder(
    column: $table.art,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get online => $composableBuilder(
    column: $table.online,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ichPersonId => $composableBuilder(
    column: $table.ichPersonId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GruppeTabelleTableOrderingComposer
    extends Composer<_$AppDatenbank, $GruppeTabelleTable> {
  $$GruppeTabelleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gruppeId => $composableBuilder(
    column: $table.gruppeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get geaendert => $composableBuilder(
    column: $table.geaendert,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get geloescht => $composableBuilder(
    column: $table.geloescht,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hochgeladen => $composableBuilder(
    column: $table.hochgeladen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get art => $composableBuilder(
    column: $table.art,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get online => $composableBuilder(
    column: $table.online,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ichPersonId => $composableBuilder(
    column: $table.ichPersonId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GruppeTabelleTableAnnotationComposer
    extends Composer<_$AppDatenbank, $GruppeTabelleTable> {
  $$GruppeTabelleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get gruppeId =>
      $composableBuilder(column: $table.gruppeId, builder: (column) => column);

  GeneratedColumn<DateTime> get geaendert =>
      $composableBuilder(column: $table.geaendert, builder: (column) => column);

  GeneratedColumn<bool> get geloescht =>
      $composableBuilder(column: $table.geloescht, builder: (column) => column);

  GeneratedColumn<bool> get hochgeladen => $composableBuilder(
    column: $table.hochgeladen,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get art =>
      $composableBuilder(column: $table.art, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<bool> get online =>
      $composableBuilder(column: $table.online, builder: (column) => column);

  GeneratedColumn<String> get ichPersonId => $composableBuilder(
    column: $table.ichPersonId,
    builder: (column) => column,
  );
}

class $$GruppeTabelleTableTableManager
    extends
        RootTableManager<
          _$AppDatenbank,
          $GruppeTabelleTable,
          Gruppe,
          $$GruppeTabelleTableFilterComposer,
          $$GruppeTabelleTableOrderingComposer,
          $$GruppeTabelleTableAnnotationComposer,
          $$GruppeTabelleTableCreateCompanionBuilder,
          $$GruppeTabelleTableUpdateCompanionBuilder,
          (Gruppe, BaseReferences<_$AppDatenbank, $GruppeTabelleTable, Gruppe>),
          Gruppe,
          PrefetchHooks Function()
        > {
  $$GruppeTabelleTableTableManager(_$AppDatenbank db, $GruppeTabelleTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GruppeTabelleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GruppeTabelleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GruppeTabelleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> gruppeId = const Value.absent(),
                Value<DateTime> geaendert = const Value.absent(),
                Value<bool> geloescht = const Value.absent(),
                Value<bool> hochgeladen = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> art = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<bool> online = const Value.absent(),
                Value<String?> ichPersonId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GruppeTabelleCompanion(
                id: id,
                gruppeId: gruppeId,
                geaendert: geaendert,
                geloescht: geloescht,
                hochgeladen: hochgeladen,
                name: name,
                art: art,
                code: code,
                online: online,
                ichPersonId: ichPersonId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> gruppeId = const Value.absent(),
                required DateTime geaendert,
                Value<bool> geloescht = const Value.absent(),
                Value<bool> hochgeladen = const Value.absent(),
                required String name,
                Value<String> art = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<bool> online = const Value.absent(),
                Value<String?> ichPersonId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GruppeTabelleCompanion.insert(
                id: id,
                gruppeId: gruppeId,
                geaendert: geaendert,
                geloescht: geloescht,
                hochgeladen: hochgeladen,
                name: name,
                art: art,
                code: code,
                online: online,
                ichPersonId: ichPersonId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GruppeTabelleTable, Gruppe>(table),
                  BaseReferences<_$AppDatenbank, $GruppeTabelleTable, Gruppe>(
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

typedef $$GruppeTabelleTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatenbank,
      $GruppeTabelleTable,
      Gruppe,
      $$GruppeTabelleTableFilterComposer,
      $$GruppeTabelleTableOrderingComposer,
      $$GruppeTabelleTableAnnotationComposer,
      $$GruppeTabelleTableCreateCompanionBuilder,
      $$GruppeTabelleTableUpdateCompanionBuilder,
      (Gruppe, BaseReferences<_$AppDatenbank, $GruppeTabelleTable, Gruppe>),
      Gruppe,
      PrefetchHooks Function()
    >;
typedef $$PersonTabelleTableCreateCompanionBuilder =
    PersonTabelleCompanion Function({
      required String id,
      Value<String?> gruppeId,
      required DateTime geaendert,
      Value<bool> geloescht,
      Value<bool> hochgeladen,
      required String name,
      required int farbe,
      Value<int> rowid,
    });
typedef $$PersonTabelleTableUpdateCompanionBuilder =
    PersonTabelleCompanion Function({
      Value<String> id,
      Value<String?> gruppeId,
      Value<DateTime> geaendert,
      Value<bool> geloescht,
      Value<bool> hochgeladen,
      Value<String> name,
      Value<int> farbe,
      Value<int> rowid,
    });

class $$PersonTabelleTableFilterComposer
    extends Composer<_$AppDatenbank, $PersonTabelleTable> {
  $$PersonTabelleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gruppeId => $composableBuilder(
    column: $table.gruppeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get geaendert => $composableBuilder(
    column: $table.geaendert,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get geloescht => $composableBuilder(
    column: $table.geloescht,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hochgeladen => $composableBuilder(
    column: $table.hochgeladen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get farbe => $composableBuilder(
    column: $table.farbe,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PersonTabelleTableOrderingComposer
    extends Composer<_$AppDatenbank, $PersonTabelleTable> {
  $$PersonTabelleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gruppeId => $composableBuilder(
    column: $table.gruppeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get geaendert => $composableBuilder(
    column: $table.geaendert,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get geloescht => $composableBuilder(
    column: $table.geloescht,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hochgeladen => $composableBuilder(
    column: $table.hochgeladen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get farbe => $composableBuilder(
    column: $table.farbe,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PersonTabelleTableAnnotationComposer
    extends Composer<_$AppDatenbank, $PersonTabelleTable> {
  $$PersonTabelleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get gruppeId =>
      $composableBuilder(column: $table.gruppeId, builder: (column) => column);

  GeneratedColumn<DateTime> get geaendert =>
      $composableBuilder(column: $table.geaendert, builder: (column) => column);

  GeneratedColumn<bool> get geloescht =>
      $composableBuilder(column: $table.geloescht, builder: (column) => column);

  GeneratedColumn<bool> get hochgeladen => $composableBuilder(
    column: $table.hochgeladen,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get farbe =>
      $composableBuilder(column: $table.farbe, builder: (column) => column);
}

class $$PersonTabelleTableTableManager
    extends
        RootTableManager<
          _$AppDatenbank,
          $PersonTabelleTable,
          Person,
          $$PersonTabelleTableFilterComposer,
          $$PersonTabelleTableOrderingComposer,
          $$PersonTabelleTableAnnotationComposer,
          $$PersonTabelleTableCreateCompanionBuilder,
          $$PersonTabelleTableUpdateCompanionBuilder,
          (Person, BaseReferences<_$AppDatenbank, $PersonTabelleTable, Person>),
          Person,
          PrefetchHooks Function()
        > {
  $$PersonTabelleTableTableManager(_$AppDatenbank db, $PersonTabelleTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonTabelleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonTabelleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonTabelleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> gruppeId = const Value.absent(),
                Value<DateTime> geaendert = const Value.absent(),
                Value<bool> geloescht = const Value.absent(),
                Value<bool> hochgeladen = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> farbe = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonTabelleCompanion(
                id: id,
                gruppeId: gruppeId,
                geaendert: geaendert,
                geloescht: geloescht,
                hochgeladen: hochgeladen,
                name: name,
                farbe: farbe,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> gruppeId = const Value.absent(),
                required DateTime geaendert,
                Value<bool> geloescht = const Value.absent(),
                Value<bool> hochgeladen = const Value.absent(),
                required String name,
                required int farbe,
                Value<int> rowid = const Value.absent(),
              }) => PersonTabelleCompanion.insert(
                id: id,
                gruppeId: gruppeId,
                geaendert: geaendert,
                geloescht: geloescht,
                hochgeladen: hochgeladen,
                name: name,
                farbe: farbe,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PersonTabelleTable, Person>(table),
                  BaseReferences<_$AppDatenbank, $PersonTabelleTable, Person>(
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

typedef $$PersonTabelleTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatenbank,
      $PersonTabelleTable,
      Person,
      $$PersonTabelleTableFilterComposer,
      $$PersonTabelleTableOrderingComposer,
      $$PersonTabelleTableAnnotationComposer,
      $$PersonTabelleTableCreateCompanionBuilder,
      $$PersonTabelleTableUpdateCompanionBuilder,
      (Person, BaseReferences<_$AppDatenbank, $PersonTabelleTable, Person>),
      Person,
      PrefetchHooks Function()
    >;
typedef $$ListeTabelleTableCreateCompanionBuilder =
    ListeTabelleCompanion Function({
      required String id,
      Value<String?> gruppeId,
      required DateTime geaendert,
      Value<bool> geloescht,
      Value<bool> hochgeladen,
      required String name,
      Value<String> art,
      Value<String> symbol,
      Value<String?> fuerPersonId,
      Value<int> sortierung,
      Value<int> rowid,
    });
typedef $$ListeTabelleTableUpdateCompanionBuilder =
    ListeTabelleCompanion Function({
      Value<String> id,
      Value<String?> gruppeId,
      Value<DateTime> geaendert,
      Value<bool> geloescht,
      Value<bool> hochgeladen,
      Value<String> name,
      Value<String> art,
      Value<String> symbol,
      Value<String?> fuerPersonId,
      Value<int> sortierung,
      Value<int> rowid,
    });

class $$ListeTabelleTableFilterComposer
    extends Composer<_$AppDatenbank, $ListeTabelleTable> {
  $$ListeTabelleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gruppeId => $composableBuilder(
    column: $table.gruppeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get geaendert => $composableBuilder(
    column: $table.geaendert,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get geloescht => $composableBuilder(
    column: $table.geloescht,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hochgeladen => $composableBuilder(
    column: $table.hochgeladen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get art => $composableBuilder(
    column: $table.art,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fuerPersonId => $composableBuilder(
    column: $table.fuerPersonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortierung => $composableBuilder(
    column: $table.sortierung,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ListeTabelleTableOrderingComposer
    extends Composer<_$AppDatenbank, $ListeTabelleTable> {
  $$ListeTabelleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gruppeId => $composableBuilder(
    column: $table.gruppeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get geaendert => $composableBuilder(
    column: $table.geaendert,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get geloescht => $composableBuilder(
    column: $table.geloescht,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hochgeladen => $composableBuilder(
    column: $table.hochgeladen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get art => $composableBuilder(
    column: $table.art,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fuerPersonId => $composableBuilder(
    column: $table.fuerPersonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortierung => $composableBuilder(
    column: $table.sortierung,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ListeTabelleTableAnnotationComposer
    extends Composer<_$AppDatenbank, $ListeTabelleTable> {
  $$ListeTabelleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get gruppeId =>
      $composableBuilder(column: $table.gruppeId, builder: (column) => column);

  GeneratedColumn<DateTime> get geaendert =>
      $composableBuilder(column: $table.geaendert, builder: (column) => column);

  GeneratedColumn<bool> get geloescht =>
      $composableBuilder(column: $table.geloescht, builder: (column) => column);

  GeneratedColumn<bool> get hochgeladen => $composableBuilder(
    column: $table.hochgeladen,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get art =>
      $composableBuilder(column: $table.art, builder: (column) => column);

  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<String> get fuerPersonId => $composableBuilder(
    column: $table.fuerPersonId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortierung => $composableBuilder(
    column: $table.sortierung,
    builder: (column) => column,
  );
}

class $$ListeTabelleTableTableManager
    extends
        RootTableManager<
          _$AppDatenbank,
          $ListeTabelleTable,
          Liste,
          $$ListeTabelleTableFilterComposer,
          $$ListeTabelleTableOrderingComposer,
          $$ListeTabelleTableAnnotationComposer,
          $$ListeTabelleTableCreateCompanionBuilder,
          $$ListeTabelleTableUpdateCompanionBuilder,
          (Liste, BaseReferences<_$AppDatenbank, $ListeTabelleTable, Liste>),
          Liste,
          PrefetchHooks Function()
        > {
  $$ListeTabelleTableTableManager(_$AppDatenbank db, $ListeTabelleTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ListeTabelleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ListeTabelleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ListeTabelleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> gruppeId = const Value.absent(),
                Value<DateTime> geaendert = const Value.absent(),
                Value<bool> geloescht = const Value.absent(),
                Value<bool> hochgeladen = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> art = const Value.absent(),
                Value<String> symbol = const Value.absent(),
                Value<String?> fuerPersonId = const Value.absent(),
                Value<int> sortierung = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ListeTabelleCompanion(
                id: id,
                gruppeId: gruppeId,
                geaendert: geaendert,
                geloescht: geloescht,
                hochgeladen: hochgeladen,
                name: name,
                art: art,
                symbol: symbol,
                fuerPersonId: fuerPersonId,
                sortierung: sortierung,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> gruppeId = const Value.absent(),
                required DateTime geaendert,
                Value<bool> geloescht = const Value.absent(),
                Value<bool> hochgeladen = const Value.absent(),
                required String name,
                Value<String> art = const Value.absent(),
                Value<String> symbol = const Value.absent(),
                Value<String?> fuerPersonId = const Value.absent(),
                Value<int> sortierung = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ListeTabelleCompanion.insert(
                id: id,
                gruppeId: gruppeId,
                geaendert: geaendert,
                geloescht: geloescht,
                hochgeladen: hochgeladen,
                name: name,
                art: art,
                symbol: symbol,
                fuerPersonId: fuerPersonId,
                sortierung: sortierung,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ListeTabelleTable, Liste>(table),
                  BaseReferences<_$AppDatenbank, $ListeTabelleTable, Liste>(
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

typedef $$ListeTabelleTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatenbank,
      $ListeTabelleTable,
      Liste,
      $$ListeTabelleTableFilterComposer,
      $$ListeTabelleTableOrderingComposer,
      $$ListeTabelleTableAnnotationComposer,
      $$ListeTabelleTableCreateCompanionBuilder,
      $$ListeTabelleTableUpdateCompanionBuilder,
      (Liste, BaseReferences<_$AppDatenbank, $ListeTabelleTable, Liste>),
      Liste,
      PrefetchHooks Function()
    >;
typedef $$ArtikelTabelleTableCreateCompanionBuilder =
    ArtikelTabelleCompanion Function({
      required String id,
      Value<String?> gruppeId,
      required DateTime geaendert,
      Value<bool> geloescht,
      Value<bool> hochgeladen,
      required String listeId,
      required String name,
      Value<String> menge,
      Value<String> kategorie,
      Value<bool> erledigt,
      Value<String?> erledigtVon,
      Value<String?> ausgabeId,
      Value<int> sortierung,
      Value<int> rowid,
    });
typedef $$ArtikelTabelleTableUpdateCompanionBuilder =
    ArtikelTabelleCompanion Function({
      Value<String> id,
      Value<String?> gruppeId,
      Value<DateTime> geaendert,
      Value<bool> geloescht,
      Value<bool> hochgeladen,
      Value<String> listeId,
      Value<String> name,
      Value<String> menge,
      Value<String> kategorie,
      Value<bool> erledigt,
      Value<String?> erledigtVon,
      Value<String?> ausgabeId,
      Value<int> sortierung,
      Value<int> rowid,
    });

class $$ArtikelTabelleTableFilterComposer
    extends Composer<_$AppDatenbank, $ArtikelTabelleTable> {
  $$ArtikelTabelleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gruppeId => $composableBuilder(
    column: $table.gruppeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get geaendert => $composableBuilder(
    column: $table.geaendert,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get geloescht => $composableBuilder(
    column: $table.geloescht,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hochgeladen => $composableBuilder(
    column: $table.hochgeladen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get listeId => $composableBuilder(
    column: $table.listeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get menge => $composableBuilder(
    column: $table.menge,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kategorie => $composableBuilder(
    column: $table.kategorie,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get erledigt => $composableBuilder(
    column: $table.erledigt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get erledigtVon => $composableBuilder(
    column: $table.erledigtVon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ausgabeId => $composableBuilder(
    column: $table.ausgabeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortierung => $composableBuilder(
    column: $table.sortierung,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ArtikelTabelleTableOrderingComposer
    extends Composer<_$AppDatenbank, $ArtikelTabelleTable> {
  $$ArtikelTabelleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gruppeId => $composableBuilder(
    column: $table.gruppeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get geaendert => $composableBuilder(
    column: $table.geaendert,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get geloescht => $composableBuilder(
    column: $table.geloescht,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hochgeladen => $composableBuilder(
    column: $table.hochgeladen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get listeId => $composableBuilder(
    column: $table.listeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get menge => $composableBuilder(
    column: $table.menge,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kategorie => $composableBuilder(
    column: $table.kategorie,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get erledigt => $composableBuilder(
    column: $table.erledigt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get erledigtVon => $composableBuilder(
    column: $table.erledigtVon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ausgabeId => $composableBuilder(
    column: $table.ausgabeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortierung => $composableBuilder(
    column: $table.sortierung,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ArtikelTabelleTableAnnotationComposer
    extends Composer<_$AppDatenbank, $ArtikelTabelleTable> {
  $$ArtikelTabelleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get gruppeId =>
      $composableBuilder(column: $table.gruppeId, builder: (column) => column);

  GeneratedColumn<DateTime> get geaendert =>
      $composableBuilder(column: $table.geaendert, builder: (column) => column);

  GeneratedColumn<bool> get geloescht =>
      $composableBuilder(column: $table.geloescht, builder: (column) => column);

  GeneratedColumn<bool> get hochgeladen => $composableBuilder(
    column: $table.hochgeladen,
    builder: (column) => column,
  );

  GeneratedColumn<String> get listeId =>
      $composableBuilder(column: $table.listeId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get menge =>
      $composableBuilder(column: $table.menge, builder: (column) => column);

  GeneratedColumn<String> get kategorie =>
      $composableBuilder(column: $table.kategorie, builder: (column) => column);

  GeneratedColumn<bool> get erledigt =>
      $composableBuilder(column: $table.erledigt, builder: (column) => column);

  GeneratedColumn<String> get erledigtVon => $composableBuilder(
    column: $table.erledigtVon,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ausgabeId =>
      $composableBuilder(column: $table.ausgabeId, builder: (column) => column);

  GeneratedColumn<int> get sortierung => $composableBuilder(
    column: $table.sortierung,
    builder: (column) => column,
  );
}

class $$ArtikelTabelleTableTableManager
    extends
        RootTableManager<
          _$AppDatenbank,
          $ArtikelTabelleTable,
          Artikel,
          $$ArtikelTabelleTableFilterComposer,
          $$ArtikelTabelleTableOrderingComposer,
          $$ArtikelTabelleTableAnnotationComposer,
          $$ArtikelTabelleTableCreateCompanionBuilder,
          $$ArtikelTabelleTableUpdateCompanionBuilder,
          (
            Artikel,
            BaseReferences<_$AppDatenbank, $ArtikelTabelleTable, Artikel>,
          ),
          Artikel,
          PrefetchHooks Function()
        > {
  $$ArtikelTabelleTableTableManager(
    _$AppDatenbank db,
    $ArtikelTabelleTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArtikelTabelleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArtikelTabelleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArtikelTabelleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> gruppeId = const Value.absent(),
                Value<DateTime> geaendert = const Value.absent(),
                Value<bool> geloescht = const Value.absent(),
                Value<bool> hochgeladen = const Value.absent(),
                Value<String> listeId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> menge = const Value.absent(),
                Value<String> kategorie = const Value.absent(),
                Value<bool> erledigt = const Value.absent(),
                Value<String?> erledigtVon = const Value.absent(),
                Value<String?> ausgabeId = const Value.absent(),
                Value<int> sortierung = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ArtikelTabelleCompanion(
                id: id,
                gruppeId: gruppeId,
                geaendert: geaendert,
                geloescht: geloescht,
                hochgeladen: hochgeladen,
                listeId: listeId,
                name: name,
                menge: menge,
                kategorie: kategorie,
                erledigt: erledigt,
                erledigtVon: erledigtVon,
                ausgabeId: ausgabeId,
                sortierung: sortierung,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> gruppeId = const Value.absent(),
                required DateTime geaendert,
                Value<bool> geloescht = const Value.absent(),
                Value<bool> hochgeladen = const Value.absent(),
                required String listeId,
                required String name,
                Value<String> menge = const Value.absent(),
                Value<String> kategorie = const Value.absent(),
                Value<bool> erledigt = const Value.absent(),
                Value<String?> erledigtVon = const Value.absent(),
                Value<String?> ausgabeId = const Value.absent(),
                Value<int> sortierung = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ArtikelTabelleCompanion.insert(
                id: id,
                gruppeId: gruppeId,
                geaendert: geaendert,
                geloescht: geloescht,
                hochgeladen: hochgeladen,
                listeId: listeId,
                name: name,
                menge: menge,
                kategorie: kategorie,
                erledigt: erledigt,
                erledigtVon: erledigtVon,
                ausgabeId: ausgabeId,
                sortierung: sortierung,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ArtikelTabelleTable, Artikel>(table),
                  BaseReferences<_$AppDatenbank, $ArtikelTabelleTable, Artikel>(
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

typedef $$ArtikelTabelleTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatenbank,
      $ArtikelTabelleTable,
      Artikel,
      $$ArtikelTabelleTableFilterComposer,
      $$ArtikelTabelleTableOrderingComposer,
      $$ArtikelTabelleTableAnnotationComposer,
      $$ArtikelTabelleTableCreateCompanionBuilder,
      $$ArtikelTabelleTableUpdateCompanionBuilder,
      (Artikel, BaseReferences<_$AppDatenbank, $ArtikelTabelleTable, Artikel>),
      Artikel,
      PrefetchHooks Function()
    >;
typedef $$AusgabeTabelleTableCreateCompanionBuilder =
    AusgabeTabelleCompanion Function({
      required String id,
      Value<String?> gruppeId,
      required DateTime geaendert,
      Value<bool> geloescht,
      Value<bool> hochgeladen,
      required String titel,
      required int betragCent,
      required String zahlerId,
      required String anteile,
      required DateTime datum,
      Value<String> art,
      Value<int> rowid,
    });
typedef $$AusgabeTabelleTableUpdateCompanionBuilder =
    AusgabeTabelleCompanion Function({
      Value<String> id,
      Value<String?> gruppeId,
      Value<DateTime> geaendert,
      Value<bool> geloescht,
      Value<bool> hochgeladen,
      Value<String> titel,
      Value<int> betragCent,
      Value<String> zahlerId,
      Value<String> anteile,
      Value<DateTime> datum,
      Value<String> art,
      Value<int> rowid,
    });

class $$AusgabeTabelleTableFilterComposer
    extends Composer<_$AppDatenbank, $AusgabeTabelleTable> {
  $$AusgabeTabelleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gruppeId => $composableBuilder(
    column: $table.gruppeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get geaendert => $composableBuilder(
    column: $table.geaendert,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get geloescht => $composableBuilder(
    column: $table.geloescht,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hochgeladen => $composableBuilder(
    column: $table.hochgeladen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titel => $composableBuilder(
    column: $table.titel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get betragCent => $composableBuilder(
    column: $table.betragCent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get zahlerId => $composableBuilder(
    column: $table.zahlerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get anteile => $composableBuilder(
    column: $table.anteile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get datum => $composableBuilder(
    column: $table.datum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get art => $composableBuilder(
    column: $table.art,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AusgabeTabelleTableOrderingComposer
    extends Composer<_$AppDatenbank, $AusgabeTabelleTable> {
  $$AusgabeTabelleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gruppeId => $composableBuilder(
    column: $table.gruppeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get geaendert => $composableBuilder(
    column: $table.geaendert,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get geloescht => $composableBuilder(
    column: $table.geloescht,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hochgeladen => $composableBuilder(
    column: $table.hochgeladen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titel => $composableBuilder(
    column: $table.titel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get betragCent => $composableBuilder(
    column: $table.betragCent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get zahlerId => $composableBuilder(
    column: $table.zahlerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get anteile => $composableBuilder(
    column: $table.anteile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get datum => $composableBuilder(
    column: $table.datum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get art => $composableBuilder(
    column: $table.art,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AusgabeTabelleTableAnnotationComposer
    extends Composer<_$AppDatenbank, $AusgabeTabelleTable> {
  $$AusgabeTabelleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get gruppeId =>
      $composableBuilder(column: $table.gruppeId, builder: (column) => column);

  GeneratedColumn<DateTime> get geaendert =>
      $composableBuilder(column: $table.geaendert, builder: (column) => column);

  GeneratedColumn<bool> get geloescht =>
      $composableBuilder(column: $table.geloescht, builder: (column) => column);

  GeneratedColumn<bool> get hochgeladen => $composableBuilder(
    column: $table.hochgeladen,
    builder: (column) => column,
  );

  GeneratedColumn<String> get titel =>
      $composableBuilder(column: $table.titel, builder: (column) => column);

  GeneratedColumn<int> get betragCent => $composableBuilder(
    column: $table.betragCent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get zahlerId =>
      $composableBuilder(column: $table.zahlerId, builder: (column) => column);

  GeneratedColumn<String> get anteile =>
      $composableBuilder(column: $table.anteile, builder: (column) => column);

  GeneratedColumn<DateTime> get datum =>
      $composableBuilder(column: $table.datum, builder: (column) => column);

  GeneratedColumn<String> get art =>
      $composableBuilder(column: $table.art, builder: (column) => column);
}

class $$AusgabeTabelleTableTableManager
    extends
        RootTableManager<
          _$AppDatenbank,
          $AusgabeTabelleTable,
          Ausgabe,
          $$AusgabeTabelleTableFilterComposer,
          $$AusgabeTabelleTableOrderingComposer,
          $$AusgabeTabelleTableAnnotationComposer,
          $$AusgabeTabelleTableCreateCompanionBuilder,
          $$AusgabeTabelleTableUpdateCompanionBuilder,
          (
            Ausgabe,
            BaseReferences<_$AppDatenbank, $AusgabeTabelleTable, Ausgabe>,
          ),
          Ausgabe,
          PrefetchHooks Function()
        > {
  $$AusgabeTabelleTableTableManager(
    _$AppDatenbank db,
    $AusgabeTabelleTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AusgabeTabelleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AusgabeTabelleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AusgabeTabelleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> gruppeId = const Value.absent(),
                Value<DateTime> geaendert = const Value.absent(),
                Value<bool> geloescht = const Value.absent(),
                Value<bool> hochgeladen = const Value.absent(),
                Value<String> titel = const Value.absent(),
                Value<int> betragCent = const Value.absent(),
                Value<String> zahlerId = const Value.absent(),
                Value<String> anteile = const Value.absent(),
                Value<DateTime> datum = const Value.absent(),
                Value<String> art = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AusgabeTabelleCompanion(
                id: id,
                gruppeId: gruppeId,
                geaendert: geaendert,
                geloescht: geloescht,
                hochgeladen: hochgeladen,
                titel: titel,
                betragCent: betragCent,
                zahlerId: zahlerId,
                anteile: anteile,
                datum: datum,
                art: art,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> gruppeId = const Value.absent(),
                required DateTime geaendert,
                Value<bool> geloescht = const Value.absent(),
                Value<bool> hochgeladen = const Value.absent(),
                required String titel,
                required int betragCent,
                required String zahlerId,
                required String anteile,
                required DateTime datum,
                Value<String> art = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AusgabeTabelleCompanion.insert(
                id: id,
                gruppeId: gruppeId,
                geaendert: geaendert,
                geloescht: geloescht,
                hochgeladen: hochgeladen,
                titel: titel,
                betragCent: betragCent,
                zahlerId: zahlerId,
                anteile: anteile,
                datum: datum,
                art: art,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AusgabeTabelleTable, Ausgabe>(table),
                  BaseReferences<_$AppDatenbank, $AusgabeTabelleTable, Ausgabe>(
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

typedef $$AusgabeTabelleTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatenbank,
      $AusgabeTabelleTable,
      Ausgabe,
      $$AusgabeTabelleTableFilterComposer,
      $$AusgabeTabelleTableOrderingComposer,
      $$AusgabeTabelleTableAnnotationComposer,
      $$AusgabeTabelleTableCreateCompanionBuilder,
      $$AusgabeTabelleTableUpdateCompanionBuilder,
      (Ausgabe, BaseReferences<_$AppDatenbank, $AusgabeTabelleTable, Ausgabe>),
      Ausgabe,
      PrefetchHooks Function()
    >;
typedef $$VorlageTabelleTableCreateCompanionBuilder =
    VorlageTabelleCompanion Function({
      required String id,
      required String name,
      Value<String> symbol,
      required String artikel,
      Value<int> rowid,
    });
typedef $$VorlageTabelleTableUpdateCompanionBuilder =
    VorlageTabelleCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> symbol,
      Value<String> artikel,
      Value<int> rowid,
    });

class $$VorlageTabelleTableFilterComposer
    extends Composer<_$AppDatenbank, $VorlageTabelleTable> {
  $$VorlageTabelleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
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

  ColumnFilters<String> get artikel => $composableBuilder(
    column: $table.artikel,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VorlageTabelleTableOrderingComposer
    extends Composer<_$AppDatenbank, $VorlageTabelleTable> {
  $$VorlageTabelleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
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

  ColumnOrderings<String> get artikel => $composableBuilder(
    column: $table.artikel,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VorlageTabelleTableAnnotationComposer
    extends Composer<_$AppDatenbank, $VorlageTabelleTable> {
  $$VorlageTabelleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<String> get artikel =>
      $composableBuilder(column: $table.artikel, builder: (column) => column);
}

class $$VorlageTabelleTableTableManager
    extends
        RootTableManager<
          _$AppDatenbank,
          $VorlageTabelleTable,
          Vorlage,
          $$VorlageTabelleTableFilterComposer,
          $$VorlageTabelleTableOrderingComposer,
          $$VorlageTabelleTableAnnotationComposer,
          $$VorlageTabelleTableCreateCompanionBuilder,
          $$VorlageTabelleTableUpdateCompanionBuilder,
          (
            Vorlage,
            BaseReferences<_$AppDatenbank, $VorlageTabelleTable, Vorlage>,
          ),
          Vorlage,
          PrefetchHooks Function()
        > {
  $$VorlageTabelleTableTableManager(
    _$AppDatenbank db,
    $VorlageTabelleTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VorlageTabelleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VorlageTabelleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VorlageTabelleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> symbol = const Value.absent(),
                Value<String> artikel = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VorlageTabelleCompanion(
                id: id,
                name: name,
                symbol: symbol,
                artikel: artikel,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> symbol = const Value.absent(),
                required String artikel,
                Value<int> rowid = const Value.absent(),
              }) => VorlageTabelleCompanion.insert(
                id: id,
                name: name,
                symbol: symbol,
                artikel: artikel,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VorlageTabelleTable, Vorlage>(table),
                  BaseReferences<_$AppDatenbank, $VorlageTabelleTable, Vorlage>(
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

typedef $$VorlageTabelleTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatenbank,
      $VorlageTabelleTable,
      Vorlage,
      $$VorlageTabelleTableFilterComposer,
      $$VorlageTabelleTableOrderingComposer,
      $$VorlageTabelleTableAnnotationComposer,
      $$VorlageTabelleTableCreateCompanionBuilder,
      $$VorlageTabelleTableUpdateCompanionBuilder,
      (Vorlage, BaseReferences<_$AppDatenbank, $VorlageTabelleTable, Vorlage>),
      Vorlage,
      PrefetchHooks Function()
    >;

class $AppDatenbankManager {
  final _$AppDatenbank _db;
  $AppDatenbankManager(this._db);
  $$GruppeTabelleTableTableManager get gruppeTabelle =>
      $$GruppeTabelleTableTableManager(_db, _db.gruppeTabelle);
  $$PersonTabelleTableTableManager get personTabelle =>
      $$PersonTabelleTableTableManager(_db, _db.personTabelle);
  $$ListeTabelleTableTableManager get listeTabelle =>
      $$ListeTabelleTableTableManager(_db, _db.listeTabelle);
  $$ArtikelTabelleTableTableManager get artikelTabelle =>
      $$ArtikelTabelleTableTableManager(_db, _db.artikelTabelle);
  $$AusgabeTabelleTableTableManager get ausgabeTabelle =>
      $$AusgabeTabelleTableTableManager(_db, _db.ausgabeTabelle);
  $$VorlageTabelleTableTableManager get vorlageTabelle =>
      $$VorlageTabelleTableTableManager(_db, _db.vorlageTabelle);
}
