// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ClientesTable extends Clientes with TableInfo<$ClientesTable, Cliente> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _telefoneMeta = const VerificationMeta(
    'telefone',
  );
  @override
  late final GeneratedColumn<String> telefone = GeneratedColumn<String>(
    'telefone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, nome, telefone, email];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clientes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Cliente> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('telefone')) {
      context.handle(
        _telefoneMeta,
        telefone.isAcceptableOrUnknown(data['telefone']!, _telefoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Cliente map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Cliente(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      telefone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}telefone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
    );
  }

  @override
  $ClientesTable createAlias(String alias) {
    return $ClientesTable(attachedDatabase, alias);
  }
}

class Cliente extends DataClass implements Insertable<Cliente> {
  final int id;
  final String nome;
  final String? telefone;
  final String? email;
  const Cliente({
    required this.id,
    required this.nome,
    this.telefone,
    this.email,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nome'] = Variable<String>(nome);
    if (!nullToAbsent || telefone != null) {
      map['telefone'] = Variable<String>(telefone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    return map;
  }

  ClientesCompanion toCompanion(bool nullToAbsent) {
    return ClientesCompanion(
      id: Value(id),
      nome: Value(nome),
      telefone: telefone == null && nullToAbsent
          ? const Value.absent()
          : Value(telefone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
    );
  }

  factory Cliente.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Cliente(
      id: serializer.fromJson<int>(json['id']),
      nome: serializer.fromJson<String>(json['nome']),
      telefone: serializer.fromJson<String?>(json['telefone']),
      email: serializer.fromJson<String?>(json['email']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nome': serializer.toJson<String>(nome),
      'telefone': serializer.toJson<String?>(telefone),
      'email': serializer.toJson<String?>(email),
    };
  }

  Cliente copyWith({
    int? id,
    String? nome,
    Value<String?> telefone = const Value.absent(),
    Value<String?> email = const Value.absent(),
  }) => Cliente(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    telefone: telefone.present ? telefone.value : this.telefone,
    email: email.present ? email.value : this.email,
  );
  Cliente copyWithCompanion(ClientesCompanion data) {
    return Cliente(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
      telefone: data.telefone.present ? data.telefone.value : this.telefone,
      email: data.email.present ? data.email.value : this.email,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Cliente(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('telefone: $telefone, ')
          ..write('email: $email')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nome, telefone, email);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cliente &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.telefone == this.telefone &&
          other.email == this.email);
}

class ClientesCompanion extends UpdateCompanion<Cliente> {
  final Value<int> id;
  final Value<String> nome;
  final Value<String?> telefone;
  final Value<String?> email;
  const ClientesCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.telefone = const Value.absent(),
    this.email = const Value.absent(),
  });
  ClientesCompanion.insert({
    this.id = const Value.absent(),
    required String nome,
    this.telefone = const Value.absent(),
    this.email = const Value.absent(),
  }) : nome = Value(nome);
  static Insertable<Cliente> custom({
    Expression<int>? id,
    Expression<String>? nome,
    Expression<String>? telefone,
    Expression<String>? email,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
      if (telefone != null) 'telefone': telefone,
      if (email != null) 'email': email,
    });
  }

  ClientesCompanion copyWith({
    Value<int>? id,
    Value<String>? nome,
    Value<String?>? telefone,
    Value<String?>? email,
  }) {
    return ClientesCompanion(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      telefone: telefone ?? this.telefone,
      email: email ?? this.email,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (telefone.present) {
      map['telefone'] = Variable<String>(telefone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClientesCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('telefone: $telefone, ')
          ..write('email: $email')
          ..write(')'))
        .toString();
  }
}

class $OrcamentosTable extends Orcamentos
    with TableInfo<$OrcamentosTable, Orcamento> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrcamentosTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _clienteIdMeta = const VerificationMeta(
    'clienteId',
  );
  @override
  late final GeneratedColumn<int> clienteId = GeneratedColumn<int>(
    'cliente_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES clientes (id)',
    ),
  );
  static const VerificationMeta _tituloMeta = const VerificationMeta('titulo');
  @override
  late final GeneratedColumn<String> titulo = GeneratedColumn<String>(
    'titulo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataEventoMeta = const VerificationMeta(
    'dataEvento',
  );
  @override
  late final GeneratedColumn<DateTime> dataEvento = GeneratedColumn<DateTime>(
    'data_evento',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localMeta = const VerificationMeta('local');
  @override
  late final GeneratedColumn<String> local = GeneratedColumn<String>(
    'local',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _convidadosMeta = const VerificationMeta(
    'convidados',
  );
  @override
  late final GeneratedColumn<int> convidados = GeneratedColumn<int>(
    'convidados',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _descontoCentavosMeta = const VerificationMeta(
    'descontoCentavos',
  );
  @override
  late final GeneratedColumn<int> descontoCentavos = GeneratedColumn<int>(
    'desconto_centavos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _ingredientesCompradosPeloBufeMeta =
      const VerificationMeta('ingredientesCompradosPeloBufe');
  @override
  late final GeneratedColumn<bool> ingredientesCompradosPeloBufe =
      GeneratedColumn<bool>(
        'ingredientes_comprados_pelo_bufe',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("ingredientes_comprados_pelo_bufe" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pendente'),
  );
  static const VerificationMeta _observacoesMeta = const VerificationMeta(
    'observacoes',
  );
  @override
  late final GeneratedColumn<String> observacoes = GeneratedColumn<String>(
    'observacoes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clienteId,
    titulo,
    dataEvento,
    local,
    convidados,
    descontoCentavos,
    ingredientesCompradosPeloBufe,
    status,
    observacoes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'orcamentos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Orcamento> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cliente_id')) {
      context.handle(
        _clienteIdMeta,
        clienteId.isAcceptableOrUnknown(data['cliente_id']!, _clienteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clienteIdMeta);
    }
    if (data.containsKey('titulo')) {
      context.handle(
        _tituloMeta,
        titulo.isAcceptableOrUnknown(data['titulo']!, _tituloMeta),
      );
    } else if (isInserting) {
      context.missing(_tituloMeta);
    }
    if (data.containsKey('data_evento')) {
      context.handle(
        _dataEventoMeta,
        dataEvento.isAcceptableOrUnknown(data['data_evento']!, _dataEventoMeta),
      );
    } else if (isInserting) {
      context.missing(_dataEventoMeta);
    }
    if (data.containsKey('local')) {
      context.handle(
        _localMeta,
        local.isAcceptableOrUnknown(data['local']!, _localMeta),
      );
    }
    if (data.containsKey('convidados')) {
      context.handle(
        _convidadosMeta,
        convidados.isAcceptableOrUnknown(data['convidados']!, _convidadosMeta),
      );
    }
    if (data.containsKey('desconto_centavos')) {
      context.handle(
        _descontoCentavosMeta,
        descontoCentavos.isAcceptableOrUnknown(
          data['desconto_centavos']!,
          _descontoCentavosMeta,
        ),
      );
    }
    if (data.containsKey('ingredientes_comprados_pelo_bufe')) {
      context.handle(
        _ingredientesCompradosPeloBufeMeta,
        ingredientesCompradosPeloBufe.isAcceptableOrUnknown(
          data['ingredientes_comprados_pelo_bufe']!,
          _ingredientesCompradosPeloBufeMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('observacoes')) {
      context.handle(
        _observacoesMeta,
        observacoes.isAcceptableOrUnknown(
          data['observacoes']!,
          _observacoesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Orcamento map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Orcamento(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      clienteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cliente_id'],
      )!,
      titulo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}titulo'],
      )!,
      dataEvento: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_evento'],
      )!,
      local: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local'],
      ),
      convidados: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}convidados'],
      )!,
      descontoCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}desconto_centavos'],
      )!,
      ingredientesCompradosPeloBufe: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}ingredientes_comprados_pelo_bufe'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      observacoes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observacoes'],
      ),
    );
  }

  @override
  $OrcamentosTable createAlias(String alias) {
    return $OrcamentosTable(attachedDatabase, alias);
  }
}

class Orcamento extends DataClass implements Insertable<Orcamento> {
  final int id;
  final int clienteId;
  final String titulo;
  final DateTime dataEvento;
  final String? local;
  final int convidados;
  final int descontoCentavos;
  final bool ingredientesCompradosPeloBufe;
  final String status;
  final String? observacoes;
  const Orcamento({
    required this.id,
    required this.clienteId,
    required this.titulo,
    required this.dataEvento,
    this.local,
    required this.convidados,
    required this.descontoCentavos,
    required this.ingredientesCompradosPeloBufe,
    required this.status,
    this.observacoes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cliente_id'] = Variable<int>(clienteId);
    map['titulo'] = Variable<String>(titulo);
    map['data_evento'] = Variable<DateTime>(dataEvento);
    if (!nullToAbsent || local != null) {
      map['local'] = Variable<String>(local);
    }
    map['convidados'] = Variable<int>(convidados);
    map['desconto_centavos'] = Variable<int>(descontoCentavos);
    map['ingredientes_comprados_pelo_bufe'] = Variable<bool>(
      ingredientesCompradosPeloBufe,
    );
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || observacoes != null) {
      map['observacoes'] = Variable<String>(observacoes);
    }
    return map;
  }

  OrcamentosCompanion toCompanion(bool nullToAbsent) {
    return OrcamentosCompanion(
      id: Value(id),
      clienteId: Value(clienteId),
      titulo: Value(titulo),
      dataEvento: Value(dataEvento),
      local: local == null && nullToAbsent
          ? const Value.absent()
          : Value(local),
      convidados: Value(convidados),
      descontoCentavos: Value(descontoCentavos),
      ingredientesCompradosPeloBufe: Value(ingredientesCompradosPeloBufe),
      status: Value(status),
      observacoes: observacoes == null && nullToAbsent
          ? const Value.absent()
          : Value(observacoes),
    );
  }

  factory Orcamento.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Orcamento(
      id: serializer.fromJson<int>(json['id']),
      clienteId: serializer.fromJson<int>(json['clienteId']),
      titulo: serializer.fromJson<String>(json['titulo']),
      dataEvento: serializer.fromJson<DateTime>(json['dataEvento']),
      local: serializer.fromJson<String?>(json['local']),
      convidados: serializer.fromJson<int>(json['convidados']),
      descontoCentavos: serializer.fromJson<int>(json['descontoCentavos']),
      ingredientesCompradosPeloBufe: serializer.fromJson<bool>(
        json['ingredientesCompradosPeloBufe'],
      ),
      status: serializer.fromJson<String>(json['status']),
      observacoes: serializer.fromJson<String?>(json['observacoes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'clienteId': serializer.toJson<int>(clienteId),
      'titulo': serializer.toJson<String>(titulo),
      'dataEvento': serializer.toJson<DateTime>(dataEvento),
      'local': serializer.toJson<String?>(local),
      'convidados': serializer.toJson<int>(convidados),
      'descontoCentavos': serializer.toJson<int>(descontoCentavos),
      'ingredientesCompradosPeloBufe': serializer.toJson<bool>(
        ingredientesCompradosPeloBufe,
      ),
      'status': serializer.toJson<String>(status),
      'observacoes': serializer.toJson<String?>(observacoes),
    };
  }

  Orcamento copyWith({
    int? id,
    int? clienteId,
    String? titulo,
    DateTime? dataEvento,
    Value<String?> local = const Value.absent(),
    int? convidados,
    int? descontoCentavos,
    bool? ingredientesCompradosPeloBufe,
    String? status,
    Value<String?> observacoes = const Value.absent(),
  }) => Orcamento(
    id: id ?? this.id,
    clienteId: clienteId ?? this.clienteId,
    titulo: titulo ?? this.titulo,
    dataEvento: dataEvento ?? this.dataEvento,
    local: local.present ? local.value : this.local,
    convidados: convidados ?? this.convidados,
    descontoCentavos: descontoCentavos ?? this.descontoCentavos,
    ingredientesCompradosPeloBufe:
        ingredientesCompradosPeloBufe ?? this.ingredientesCompradosPeloBufe,
    status: status ?? this.status,
    observacoes: observacoes.present ? observacoes.value : this.observacoes,
  );
  Orcamento copyWithCompanion(OrcamentosCompanion data) {
    return Orcamento(
      id: data.id.present ? data.id.value : this.id,
      clienteId: data.clienteId.present ? data.clienteId.value : this.clienteId,
      titulo: data.titulo.present ? data.titulo.value : this.titulo,
      dataEvento: data.dataEvento.present
          ? data.dataEvento.value
          : this.dataEvento,
      local: data.local.present ? data.local.value : this.local,
      convidados: data.convidados.present
          ? data.convidados.value
          : this.convidados,
      descontoCentavos: data.descontoCentavos.present
          ? data.descontoCentavos.value
          : this.descontoCentavos,
      ingredientesCompradosPeloBufe: data.ingredientesCompradosPeloBufe.present
          ? data.ingredientesCompradosPeloBufe.value
          : this.ingredientesCompradosPeloBufe,
      status: data.status.present ? data.status.value : this.status,
      observacoes: data.observacoes.present
          ? data.observacoes.value
          : this.observacoes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Orcamento(')
          ..write('id: $id, ')
          ..write('clienteId: $clienteId, ')
          ..write('titulo: $titulo, ')
          ..write('dataEvento: $dataEvento, ')
          ..write('local: $local, ')
          ..write('convidados: $convidados, ')
          ..write('descontoCentavos: $descontoCentavos, ')
          ..write(
            'ingredientesCompradosPeloBufe: $ingredientesCompradosPeloBufe, ',
          )
          ..write('status: $status, ')
          ..write('observacoes: $observacoes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    clienteId,
    titulo,
    dataEvento,
    local,
    convidados,
    descontoCentavos,
    ingredientesCompradosPeloBufe,
    status,
    observacoes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Orcamento &&
          other.id == this.id &&
          other.clienteId == this.clienteId &&
          other.titulo == this.titulo &&
          other.dataEvento == this.dataEvento &&
          other.local == this.local &&
          other.convidados == this.convidados &&
          other.descontoCentavos == this.descontoCentavos &&
          other.ingredientesCompradosPeloBufe ==
              this.ingredientesCompradosPeloBufe &&
          other.status == this.status &&
          other.observacoes == this.observacoes);
}

class OrcamentosCompanion extends UpdateCompanion<Orcamento> {
  final Value<int> id;
  final Value<int> clienteId;
  final Value<String> titulo;
  final Value<DateTime> dataEvento;
  final Value<String?> local;
  final Value<int> convidados;
  final Value<int> descontoCentavos;
  final Value<bool> ingredientesCompradosPeloBufe;
  final Value<String> status;
  final Value<String?> observacoes;
  const OrcamentosCompanion({
    this.id = const Value.absent(),
    this.clienteId = const Value.absent(),
    this.titulo = const Value.absent(),
    this.dataEvento = const Value.absent(),
    this.local = const Value.absent(),
    this.convidados = const Value.absent(),
    this.descontoCentavos = const Value.absent(),
    this.ingredientesCompradosPeloBufe = const Value.absent(),
    this.status = const Value.absent(),
    this.observacoes = const Value.absent(),
  });
  OrcamentosCompanion.insert({
    this.id = const Value.absent(),
    required int clienteId,
    required String titulo,
    required DateTime dataEvento,
    this.local = const Value.absent(),
    this.convidados = const Value.absent(),
    this.descontoCentavos = const Value.absent(),
    this.ingredientesCompradosPeloBufe = const Value.absent(),
    this.status = const Value.absent(),
    this.observacoes = const Value.absent(),
  }) : clienteId = Value(clienteId),
       titulo = Value(titulo),
       dataEvento = Value(dataEvento);
  static Insertable<Orcamento> custom({
    Expression<int>? id,
    Expression<int>? clienteId,
    Expression<String>? titulo,
    Expression<DateTime>? dataEvento,
    Expression<String>? local,
    Expression<int>? convidados,
    Expression<int>? descontoCentavos,
    Expression<bool>? ingredientesCompradosPeloBufe,
    Expression<String>? status,
    Expression<String>? observacoes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clienteId != null) 'cliente_id': clienteId,
      if (titulo != null) 'titulo': titulo,
      if (dataEvento != null) 'data_evento': dataEvento,
      if (local != null) 'local': local,
      if (convidados != null) 'convidados': convidados,
      if (descontoCentavos != null) 'desconto_centavos': descontoCentavos,
      if (ingredientesCompradosPeloBufe != null)
        'ingredientes_comprados_pelo_bufe': ingredientesCompradosPeloBufe,
      if (status != null) 'status': status,
      if (observacoes != null) 'observacoes': observacoes,
    });
  }

  OrcamentosCompanion copyWith({
    Value<int>? id,
    Value<int>? clienteId,
    Value<String>? titulo,
    Value<DateTime>? dataEvento,
    Value<String?>? local,
    Value<int>? convidados,
    Value<int>? descontoCentavos,
    Value<bool>? ingredientesCompradosPeloBufe,
    Value<String>? status,
    Value<String?>? observacoes,
  }) {
    return OrcamentosCompanion(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      titulo: titulo ?? this.titulo,
      dataEvento: dataEvento ?? this.dataEvento,
      local: local ?? this.local,
      convidados: convidados ?? this.convidados,
      descontoCentavos: descontoCentavos ?? this.descontoCentavos,
      ingredientesCompradosPeloBufe:
          ingredientesCompradosPeloBufe ?? this.ingredientesCompradosPeloBufe,
      status: status ?? this.status,
      observacoes: observacoes ?? this.observacoes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (clienteId.present) {
      map['cliente_id'] = Variable<int>(clienteId.value);
    }
    if (titulo.present) {
      map['titulo'] = Variable<String>(titulo.value);
    }
    if (dataEvento.present) {
      map['data_evento'] = Variable<DateTime>(dataEvento.value);
    }
    if (local.present) {
      map['local'] = Variable<String>(local.value);
    }
    if (convidados.present) {
      map['convidados'] = Variable<int>(convidados.value);
    }
    if (descontoCentavos.present) {
      map['desconto_centavos'] = Variable<int>(descontoCentavos.value);
    }
    if (ingredientesCompradosPeloBufe.present) {
      map['ingredientes_comprados_pelo_bufe'] = Variable<bool>(
        ingredientesCompradosPeloBufe.value,
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (observacoes.present) {
      map['observacoes'] = Variable<String>(observacoes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrcamentosCompanion(')
          ..write('id: $id, ')
          ..write('clienteId: $clienteId, ')
          ..write('titulo: $titulo, ')
          ..write('dataEvento: $dataEvento, ')
          ..write('local: $local, ')
          ..write('convidados: $convidados, ')
          ..write('descontoCentavos: $descontoCentavos, ')
          ..write(
            'ingredientesCompradosPeloBufe: $ingredientesCompradosPeloBufe, ',
          )
          ..write('status: $status, ')
          ..write('observacoes: $observacoes')
          ..write(')'))
        .toString();
  }
}

class $ServicosTable extends Servicos with TableInfo<$ServicosTable, Servico> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServicosTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 150,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _precoCentavosMeta = const VerificationMeta(
    'precoCentavos',
  );
  @override
  late final GeneratedColumn<int> precoCentavos = GeneratedColumn<int>(
    'preco_centavos',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tipoCobrancaMeta = const VerificationMeta(
    'tipoCobranca',
  );
  @override
  late final GeneratedColumn<String> tipoCobranca = GeneratedColumn<String>(
    'tipo_cobranca',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('geral'),
  );
  static const VerificationMeta _ativoMeta = const VerificationMeta('ativo');
  @override
  late final GeneratedColumn<bool> ativo = GeneratedColumn<bool>(
    'ativo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("ativo" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _criadoEmMeta = const VerificationMeta(
    'criadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> criadoEm = GeneratedColumn<DateTime>(
    'criado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nome,
    precoCentavos,
    tipoCobranca,
    ativo,
    criadoEm,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'servicos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Servico> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('preco_centavos')) {
      context.handle(
        _precoCentavosMeta,
        precoCentavos.isAcceptableOrUnknown(
          data['preco_centavos']!,
          _precoCentavosMeta,
        ),
      );
    }
    if (data.containsKey('tipo_cobranca')) {
      context.handle(
        _tipoCobrancaMeta,
        tipoCobranca.isAcceptableOrUnknown(
          data['tipo_cobranca']!,
          _tipoCobrancaMeta,
        ),
      );
    }
    if (data.containsKey('ativo')) {
      context.handle(
        _ativoMeta,
        ativo.isAcceptableOrUnknown(data['ativo']!, _ativoMeta),
      );
    }
    if (data.containsKey('criado_em')) {
      context.handle(
        _criadoEmMeta,
        criadoEm.isAcceptableOrUnknown(data['criado_em']!, _criadoEmMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Servico map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Servico(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      precoCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}preco_centavos'],
      ),
      tipoCobranca: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo_cobranca'],
      )!,
      ativo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}ativo'],
      )!,
      criadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}criado_em'],
      )!,
    );
  }

  @override
  $ServicosTable createAlias(String alias) {
    return $ServicosTable(attachedDatabase, alias);
  }
}

class Servico extends DataClass implements Insertable<Servico> {
  final int id;
  final String nome;

  /// Preço sugerido em centavos. Pode não ser informado.
  final int? precoCentavos;
  final String tipoCobranca;
  final bool ativo;
  final DateTime criadoEm;
  const Servico({
    required this.id,
    required this.nome,
    this.precoCentavos,
    required this.tipoCobranca,
    required this.ativo,
    required this.criadoEm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nome'] = Variable<String>(nome);
    if (!nullToAbsent || precoCentavos != null) {
      map['preco_centavos'] = Variable<int>(precoCentavos);
    }
    map['tipo_cobranca'] = Variable<String>(tipoCobranca);
    map['ativo'] = Variable<bool>(ativo);
    map['criado_em'] = Variable<DateTime>(criadoEm);
    return map;
  }

  ServicosCompanion toCompanion(bool nullToAbsent) {
    return ServicosCompanion(
      id: Value(id),
      nome: Value(nome),
      precoCentavos: precoCentavos == null && nullToAbsent
          ? const Value.absent()
          : Value(precoCentavos),
      tipoCobranca: Value(tipoCobranca),
      ativo: Value(ativo),
      criadoEm: Value(criadoEm),
    );
  }

  factory Servico.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Servico(
      id: serializer.fromJson<int>(json['id']),
      nome: serializer.fromJson<String>(json['nome']),
      precoCentavos: serializer.fromJson<int?>(json['precoCentavos']),
      tipoCobranca: serializer.fromJson<String>(json['tipoCobranca']),
      ativo: serializer.fromJson<bool>(json['ativo']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nome': serializer.toJson<String>(nome),
      'precoCentavos': serializer.toJson<int?>(precoCentavos),
      'tipoCobranca': serializer.toJson<String>(tipoCobranca),
      'ativo': serializer.toJson<bool>(ativo),
      'criadoEm': serializer.toJson<DateTime>(criadoEm),
    };
  }

  Servico copyWith({
    int? id,
    String? nome,
    Value<int?> precoCentavos = const Value.absent(),
    String? tipoCobranca,
    bool? ativo,
    DateTime? criadoEm,
  }) => Servico(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    precoCentavos: precoCentavos.present
        ? precoCentavos.value
        : this.precoCentavos,
    tipoCobranca: tipoCobranca ?? this.tipoCobranca,
    ativo: ativo ?? this.ativo,
    criadoEm: criadoEm ?? this.criadoEm,
  );
  Servico copyWithCompanion(ServicosCompanion data) {
    return Servico(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
      precoCentavos: data.precoCentavos.present
          ? data.precoCentavos.value
          : this.precoCentavos,
      tipoCobranca: data.tipoCobranca.present
          ? data.tipoCobranca.value
          : this.tipoCobranca,
      ativo: data.ativo.present ? data.ativo.value : this.ativo,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Servico(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('precoCentavos: $precoCentavos, ')
          ..write('tipoCobranca: $tipoCobranca, ')
          ..write('ativo: $ativo, ')
          ..write('criadoEm: $criadoEm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, nome, precoCentavos, tipoCobranca, ativo, criadoEm);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Servico &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.precoCentavos == this.precoCentavos &&
          other.tipoCobranca == this.tipoCobranca &&
          other.ativo == this.ativo &&
          other.criadoEm == this.criadoEm);
}

class ServicosCompanion extends UpdateCompanion<Servico> {
  final Value<int> id;
  final Value<String> nome;
  final Value<int?> precoCentavos;
  final Value<String> tipoCobranca;
  final Value<bool> ativo;
  final Value<DateTime> criadoEm;
  const ServicosCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.precoCentavos = const Value.absent(),
    this.tipoCobranca = const Value.absent(),
    this.ativo = const Value.absent(),
    this.criadoEm = const Value.absent(),
  });
  ServicosCompanion.insert({
    this.id = const Value.absent(),
    required String nome,
    this.precoCentavos = const Value.absent(),
    this.tipoCobranca = const Value.absent(),
    this.ativo = const Value.absent(),
    this.criadoEm = const Value.absent(),
  }) : nome = Value(nome);
  static Insertable<Servico> custom({
    Expression<int>? id,
    Expression<String>? nome,
    Expression<int>? precoCentavos,
    Expression<String>? tipoCobranca,
    Expression<bool>? ativo,
    Expression<DateTime>? criadoEm,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
      if (precoCentavos != null) 'preco_centavos': precoCentavos,
      if (tipoCobranca != null) 'tipo_cobranca': tipoCobranca,
      if (ativo != null) 'ativo': ativo,
      if (criadoEm != null) 'criado_em': criadoEm,
    });
  }

  ServicosCompanion copyWith({
    Value<int>? id,
    Value<String>? nome,
    Value<int?>? precoCentavos,
    Value<String>? tipoCobranca,
    Value<bool>? ativo,
    Value<DateTime>? criadoEm,
  }) {
    return ServicosCompanion(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      precoCentavos: precoCentavos ?? this.precoCentavos,
      tipoCobranca: tipoCobranca ?? this.tipoCobranca,
      ativo: ativo ?? this.ativo,
      criadoEm: criadoEm ?? this.criadoEm,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (precoCentavos.present) {
      map['preco_centavos'] = Variable<int>(precoCentavos.value);
    }
    if (tipoCobranca.present) {
      map['tipo_cobranca'] = Variable<String>(tipoCobranca.value);
    }
    if (ativo.present) {
      map['ativo'] = Variable<bool>(ativo.value);
    }
    if (criadoEm.present) {
      map['criado_em'] = Variable<DateTime>(criadoEm.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServicosCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('precoCentavos: $precoCentavos, ')
          ..write('tipoCobranca: $tipoCobranca, ')
          ..write('ativo: $ativo, ')
          ..write('criadoEm: $criadoEm')
          ..write(')'))
        .toString();
  }
}

class $OrcamentoItensTable extends OrcamentoItens
    with TableInfo<$OrcamentoItensTable, OrcamentoIten> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrcamentoItensTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _orcamentoIdMeta = const VerificationMeta(
    'orcamentoId',
  );
  @override
  late final GeneratedColumn<int> orcamentoId = GeneratedColumn<int>(
    'orcamento_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES orcamentos (id)',
    ),
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantidadeMeta = const VerificationMeta(
    'quantidade',
  );
  @override
  late final GeneratedColumn<int> quantidade = GeneratedColumn<int>(
    'quantidade',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _precoCentavosMeta = const VerificationMeta(
    'precoCentavos',
  );
  @override
  late final GeneratedColumn<int> precoCentavos = GeneratedColumn<int>(
    'preco_centavos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _tipoCobrancaMeta = const VerificationMeta(
    'tipoCobranca',
  );
  @override
  late final GeneratedColumn<String> tipoCobranca = GeneratedColumn<String>(
    'tipo_cobranca',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('geral'),
  );
  static const VerificationMeta _categoriaMeta = const VerificationMeta(
    'categoria',
  );
  @override
  late final GeneratedColumn<String> categoria = GeneratedColumn<String>(
    'categoria',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('servico'),
  );
  static const VerificationMeta _receitaIdMeta = const VerificationMeta(
    'receitaId',
  );
  @override
  late final GeneratedColumn<int> receitaId = GeneratedColumn<int>(
    'receita_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receitaIngredienteIdMeta =
      const VerificationMeta('receitaIngredienteId');
  @override
  late final GeneratedColumn<int> receitaIngredienteId = GeneratedColumn<int>(
    'receita_ingrediente_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receitaNomeMeta = const VerificationMeta(
    'receitaNome',
  );
  @override
  late final GeneratedColumn<String> receitaNome = GeneratedColumn<String>(
    'receita_nome',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unidadeMeta = const VerificationMeta(
    'unidade',
  );
  @override
  late final GeneratedColumn<String> unidade = GeneratedColumn<String>(
    'unidade',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quantidadeMilesimosMeta =
      const VerificationMeta('quantidadeMilesimos');
  @override
  late final GeneratedColumn<int> quantidadeMilesimos = GeneratedColumn<int>(
    'quantidade_milesimos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1000),
  );
  static const VerificationMeta _servicoIdMeta = const VerificationMeta(
    'servicoId',
  );
  @override
  late final GeneratedColumn<int> servicoId = GeneratedColumn<int>(
    'servico_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES servicos (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    orcamentoId,
    nome,
    quantidade,
    precoCentavos,
    tipoCobranca,
    categoria,
    receitaId,
    receitaIngredienteId,
    receitaNome,
    unidade,
    quantidadeMilesimos,
    servicoId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'orcamento_itens';
  @override
  VerificationContext validateIntegrity(
    Insertable<OrcamentoIten> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('orcamento_id')) {
      context.handle(
        _orcamentoIdMeta,
        orcamentoId.isAcceptableOrUnknown(
          data['orcamento_id']!,
          _orcamentoIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_orcamentoIdMeta);
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('quantidade')) {
      context.handle(
        _quantidadeMeta,
        quantidade.isAcceptableOrUnknown(data['quantidade']!, _quantidadeMeta),
      );
    }
    if (data.containsKey('preco_centavos')) {
      context.handle(
        _precoCentavosMeta,
        precoCentavos.isAcceptableOrUnknown(
          data['preco_centavos']!,
          _precoCentavosMeta,
        ),
      );
    }
    if (data.containsKey('tipo_cobranca')) {
      context.handle(
        _tipoCobrancaMeta,
        tipoCobranca.isAcceptableOrUnknown(
          data['tipo_cobranca']!,
          _tipoCobrancaMeta,
        ),
      );
    }
    if (data.containsKey('categoria')) {
      context.handle(
        _categoriaMeta,
        categoria.isAcceptableOrUnknown(data['categoria']!, _categoriaMeta),
      );
    }
    if (data.containsKey('receita_id')) {
      context.handle(
        _receitaIdMeta,
        receitaId.isAcceptableOrUnknown(data['receita_id']!, _receitaIdMeta),
      );
    }
    if (data.containsKey('receita_ingrediente_id')) {
      context.handle(
        _receitaIngredienteIdMeta,
        receitaIngredienteId.isAcceptableOrUnknown(
          data['receita_ingrediente_id']!,
          _receitaIngredienteIdMeta,
        ),
      );
    }
    if (data.containsKey('receita_nome')) {
      context.handle(
        _receitaNomeMeta,
        receitaNome.isAcceptableOrUnknown(
          data['receita_nome']!,
          _receitaNomeMeta,
        ),
      );
    }
    if (data.containsKey('unidade')) {
      context.handle(
        _unidadeMeta,
        unidade.isAcceptableOrUnknown(data['unidade']!, _unidadeMeta),
      );
    }
    if (data.containsKey('quantidade_milesimos')) {
      context.handle(
        _quantidadeMilesimosMeta,
        quantidadeMilesimos.isAcceptableOrUnknown(
          data['quantidade_milesimos']!,
          _quantidadeMilesimosMeta,
        ),
      );
    }
    if (data.containsKey('servico_id')) {
      context.handle(
        _servicoIdMeta,
        servicoId.isAcceptableOrUnknown(data['servico_id']!, _servicoIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrcamentoIten map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrcamentoIten(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      orcamentoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}orcamento_id'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      quantidade: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantidade'],
      )!,
      precoCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}preco_centavos'],
      )!,
      tipoCobranca: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo_cobranca'],
      )!,
      categoria: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categoria'],
      )!,
      receitaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}receita_id'],
      ),
      receitaIngredienteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}receita_ingrediente_id'],
      ),
      receitaNome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receita_nome'],
      ),
      unidade: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unidade'],
      ),
      quantidadeMilesimos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantidade_milesimos'],
      )!,
      servicoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}servico_id'],
      ),
    );
  }

  @override
  $OrcamentoItensTable createAlias(String alias) {
    return $OrcamentoItensTable(attachedDatabase, alias);
  }
}

class OrcamentoIten extends DataClass implements Insertable<OrcamentoIten> {
  final int id;
  final int orcamentoId;
  final String nome;
  final int quantidade;
  final int precoCentavos;
  final String tipoCobranca;
  final String categoria;
  final int? receitaId;
  final int? receitaIngredienteId;
  final String? receitaNome;
  final String? unidade;
  final int quantidadeMilesimos;
  final int? servicoId;
  const OrcamentoIten({
    required this.id,
    required this.orcamentoId,
    required this.nome,
    required this.quantidade,
    required this.precoCentavos,
    required this.tipoCobranca,
    required this.categoria,
    this.receitaId,
    this.receitaIngredienteId,
    this.receitaNome,
    this.unidade,
    required this.quantidadeMilesimos,
    this.servicoId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['orcamento_id'] = Variable<int>(orcamentoId);
    map['nome'] = Variable<String>(nome);
    map['quantidade'] = Variable<int>(quantidade);
    map['preco_centavos'] = Variable<int>(precoCentavos);
    map['tipo_cobranca'] = Variable<String>(tipoCobranca);
    map['categoria'] = Variable<String>(categoria);
    if (!nullToAbsent || receitaId != null) {
      map['receita_id'] = Variable<int>(receitaId);
    }
    if (!nullToAbsent || receitaIngredienteId != null) {
      map['receita_ingrediente_id'] = Variable<int>(receitaIngredienteId);
    }
    if (!nullToAbsent || receitaNome != null) {
      map['receita_nome'] = Variable<String>(receitaNome);
    }
    if (!nullToAbsent || unidade != null) {
      map['unidade'] = Variable<String>(unidade);
    }
    map['quantidade_milesimos'] = Variable<int>(quantidadeMilesimos);
    if (!nullToAbsent || servicoId != null) {
      map['servico_id'] = Variable<int>(servicoId);
    }
    return map;
  }

  OrcamentoItensCompanion toCompanion(bool nullToAbsent) {
    return OrcamentoItensCompanion(
      id: Value(id),
      orcamentoId: Value(orcamentoId),
      nome: Value(nome),
      quantidade: Value(quantidade),
      precoCentavos: Value(precoCentavos),
      tipoCobranca: Value(tipoCobranca),
      categoria: Value(categoria),
      receitaId: receitaId == null && nullToAbsent
          ? const Value.absent()
          : Value(receitaId),
      receitaIngredienteId: receitaIngredienteId == null && nullToAbsent
          ? const Value.absent()
          : Value(receitaIngredienteId),
      receitaNome: receitaNome == null && nullToAbsent
          ? const Value.absent()
          : Value(receitaNome),
      unidade: unidade == null && nullToAbsent
          ? const Value.absent()
          : Value(unidade),
      quantidadeMilesimos: Value(quantidadeMilesimos),
      servicoId: servicoId == null && nullToAbsent
          ? const Value.absent()
          : Value(servicoId),
    );
  }

  factory OrcamentoIten.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrcamentoIten(
      id: serializer.fromJson<int>(json['id']),
      orcamentoId: serializer.fromJson<int>(json['orcamentoId']),
      nome: serializer.fromJson<String>(json['nome']),
      quantidade: serializer.fromJson<int>(json['quantidade']),
      precoCentavos: serializer.fromJson<int>(json['precoCentavos']),
      tipoCobranca: serializer.fromJson<String>(json['tipoCobranca']),
      categoria: serializer.fromJson<String>(json['categoria']),
      receitaId: serializer.fromJson<int?>(json['receitaId']),
      receitaIngredienteId: serializer.fromJson<int?>(
        json['receitaIngredienteId'],
      ),
      receitaNome: serializer.fromJson<String?>(json['receitaNome']),
      unidade: serializer.fromJson<String?>(json['unidade']),
      quantidadeMilesimos: serializer.fromJson<int>(
        json['quantidadeMilesimos'],
      ),
      servicoId: serializer.fromJson<int?>(json['servicoId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'orcamentoId': serializer.toJson<int>(orcamentoId),
      'nome': serializer.toJson<String>(nome),
      'quantidade': serializer.toJson<int>(quantidade),
      'precoCentavos': serializer.toJson<int>(precoCentavos),
      'tipoCobranca': serializer.toJson<String>(tipoCobranca),
      'categoria': serializer.toJson<String>(categoria),
      'receitaId': serializer.toJson<int?>(receitaId),
      'receitaIngredienteId': serializer.toJson<int?>(receitaIngredienteId),
      'receitaNome': serializer.toJson<String?>(receitaNome),
      'unidade': serializer.toJson<String?>(unidade),
      'quantidadeMilesimos': serializer.toJson<int>(quantidadeMilesimos),
      'servicoId': serializer.toJson<int?>(servicoId),
    };
  }

  OrcamentoIten copyWith({
    int? id,
    int? orcamentoId,
    String? nome,
    int? quantidade,
    int? precoCentavos,
    String? tipoCobranca,
    String? categoria,
    Value<int?> receitaId = const Value.absent(),
    Value<int?> receitaIngredienteId = const Value.absent(),
    Value<String?> receitaNome = const Value.absent(),
    Value<String?> unidade = const Value.absent(),
    int? quantidadeMilesimos,
    Value<int?> servicoId = const Value.absent(),
  }) => OrcamentoIten(
    id: id ?? this.id,
    orcamentoId: orcamentoId ?? this.orcamentoId,
    nome: nome ?? this.nome,
    quantidade: quantidade ?? this.quantidade,
    precoCentavos: precoCentavos ?? this.precoCentavos,
    tipoCobranca: tipoCobranca ?? this.tipoCobranca,
    categoria: categoria ?? this.categoria,
    receitaId: receitaId.present ? receitaId.value : this.receitaId,
    receitaIngredienteId: receitaIngredienteId.present
        ? receitaIngredienteId.value
        : this.receitaIngredienteId,
    receitaNome: receitaNome.present ? receitaNome.value : this.receitaNome,
    unidade: unidade.present ? unidade.value : this.unidade,
    quantidadeMilesimos: quantidadeMilesimos ?? this.quantidadeMilesimos,
    servicoId: servicoId.present ? servicoId.value : this.servicoId,
  );
  OrcamentoIten copyWithCompanion(OrcamentoItensCompanion data) {
    return OrcamentoIten(
      id: data.id.present ? data.id.value : this.id,
      orcamentoId: data.orcamentoId.present
          ? data.orcamentoId.value
          : this.orcamentoId,
      nome: data.nome.present ? data.nome.value : this.nome,
      quantidade: data.quantidade.present
          ? data.quantidade.value
          : this.quantidade,
      precoCentavos: data.precoCentavos.present
          ? data.precoCentavos.value
          : this.precoCentavos,
      tipoCobranca: data.tipoCobranca.present
          ? data.tipoCobranca.value
          : this.tipoCobranca,
      categoria: data.categoria.present ? data.categoria.value : this.categoria,
      receitaId: data.receitaId.present ? data.receitaId.value : this.receitaId,
      receitaIngredienteId: data.receitaIngredienteId.present
          ? data.receitaIngredienteId.value
          : this.receitaIngredienteId,
      receitaNome: data.receitaNome.present
          ? data.receitaNome.value
          : this.receitaNome,
      unidade: data.unidade.present ? data.unidade.value : this.unidade,
      quantidadeMilesimos: data.quantidadeMilesimos.present
          ? data.quantidadeMilesimos.value
          : this.quantidadeMilesimos,
      servicoId: data.servicoId.present ? data.servicoId.value : this.servicoId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrcamentoIten(')
          ..write('id: $id, ')
          ..write('orcamentoId: $orcamentoId, ')
          ..write('nome: $nome, ')
          ..write('quantidade: $quantidade, ')
          ..write('precoCentavos: $precoCentavos, ')
          ..write('tipoCobranca: $tipoCobranca, ')
          ..write('categoria: $categoria, ')
          ..write('receitaId: $receitaId, ')
          ..write('receitaIngredienteId: $receitaIngredienteId, ')
          ..write('receitaNome: $receitaNome, ')
          ..write('unidade: $unidade, ')
          ..write('quantidadeMilesimos: $quantidadeMilesimos, ')
          ..write('servicoId: $servicoId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    orcamentoId,
    nome,
    quantidade,
    precoCentavos,
    tipoCobranca,
    categoria,
    receitaId,
    receitaIngredienteId,
    receitaNome,
    unidade,
    quantidadeMilesimos,
    servicoId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrcamentoIten &&
          other.id == this.id &&
          other.orcamentoId == this.orcamentoId &&
          other.nome == this.nome &&
          other.quantidade == this.quantidade &&
          other.precoCentavos == this.precoCentavos &&
          other.tipoCobranca == this.tipoCobranca &&
          other.categoria == this.categoria &&
          other.receitaId == this.receitaId &&
          other.receitaIngredienteId == this.receitaIngredienteId &&
          other.receitaNome == this.receitaNome &&
          other.unidade == this.unidade &&
          other.quantidadeMilesimos == this.quantidadeMilesimos &&
          other.servicoId == this.servicoId);
}

class OrcamentoItensCompanion extends UpdateCompanion<OrcamentoIten> {
  final Value<int> id;
  final Value<int> orcamentoId;
  final Value<String> nome;
  final Value<int> quantidade;
  final Value<int> precoCentavos;
  final Value<String> tipoCobranca;
  final Value<String> categoria;
  final Value<int?> receitaId;
  final Value<int?> receitaIngredienteId;
  final Value<String?> receitaNome;
  final Value<String?> unidade;
  final Value<int> quantidadeMilesimos;
  final Value<int?> servicoId;
  const OrcamentoItensCompanion({
    this.id = const Value.absent(),
    this.orcamentoId = const Value.absent(),
    this.nome = const Value.absent(),
    this.quantidade = const Value.absent(),
    this.precoCentavos = const Value.absent(),
    this.tipoCobranca = const Value.absent(),
    this.categoria = const Value.absent(),
    this.receitaId = const Value.absent(),
    this.receitaIngredienteId = const Value.absent(),
    this.receitaNome = const Value.absent(),
    this.unidade = const Value.absent(),
    this.quantidadeMilesimos = const Value.absent(),
    this.servicoId = const Value.absent(),
  });
  OrcamentoItensCompanion.insert({
    this.id = const Value.absent(),
    required int orcamentoId,
    required String nome,
    this.quantidade = const Value.absent(),
    this.precoCentavos = const Value.absent(),
    this.tipoCobranca = const Value.absent(),
    this.categoria = const Value.absent(),
    this.receitaId = const Value.absent(),
    this.receitaIngredienteId = const Value.absent(),
    this.receitaNome = const Value.absent(),
    this.unidade = const Value.absent(),
    this.quantidadeMilesimos = const Value.absent(),
    this.servicoId = const Value.absent(),
  }) : orcamentoId = Value(orcamentoId),
       nome = Value(nome);
  static Insertable<OrcamentoIten> custom({
    Expression<int>? id,
    Expression<int>? orcamentoId,
    Expression<String>? nome,
    Expression<int>? quantidade,
    Expression<int>? precoCentavos,
    Expression<String>? tipoCobranca,
    Expression<String>? categoria,
    Expression<int>? receitaId,
    Expression<int>? receitaIngredienteId,
    Expression<String>? receitaNome,
    Expression<String>? unidade,
    Expression<int>? quantidadeMilesimos,
    Expression<int>? servicoId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orcamentoId != null) 'orcamento_id': orcamentoId,
      if (nome != null) 'nome': nome,
      if (quantidade != null) 'quantidade': quantidade,
      if (precoCentavos != null) 'preco_centavos': precoCentavos,
      if (tipoCobranca != null) 'tipo_cobranca': tipoCobranca,
      if (categoria != null) 'categoria': categoria,
      if (receitaId != null) 'receita_id': receitaId,
      if (receitaIngredienteId != null)
        'receita_ingrediente_id': receitaIngredienteId,
      if (receitaNome != null) 'receita_nome': receitaNome,
      if (unidade != null) 'unidade': unidade,
      if (quantidadeMilesimos != null)
        'quantidade_milesimos': quantidadeMilesimos,
      if (servicoId != null) 'servico_id': servicoId,
    });
  }

  OrcamentoItensCompanion copyWith({
    Value<int>? id,
    Value<int>? orcamentoId,
    Value<String>? nome,
    Value<int>? quantidade,
    Value<int>? precoCentavos,
    Value<String>? tipoCobranca,
    Value<String>? categoria,
    Value<int?>? receitaId,
    Value<int?>? receitaIngredienteId,
    Value<String?>? receitaNome,
    Value<String?>? unidade,
    Value<int>? quantidadeMilesimos,
    Value<int?>? servicoId,
  }) {
    return OrcamentoItensCompanion(
      id: id ?? this.id,
      orcamentoId: orcamentoId ?? this.orcamentoId,
      nome: nome ?? this.nome,
      quantidade: quantidade ?? this.quantidade,
      precoCentavos: precoCentavos ?? this.precoCentavos,
      tipoCobranca: tipoCobranca ?? this.tipoCobranca,
      categoria: categoria ?? this.categoria,
      receitaId: receitaId ?? this.receitaId,
      receitaIngredienteId: receitaIngredienteId ?? this.receitaIngredienteId,
      receitaNome: receitaNome ?? this.receitaNome,
      unidade: unidade ?? this.unidade,
      quantidadeMilesimos: quantidadeMilesimos ?? this.quantidadeMilesimos,
      servicoId: servicoId ?? this.servicoId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (orcamentoId.present) {
      map['orcamento_id'] = Variable<int>(orcamentoId.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (quantidade.present) {
      map['quantidade'] = Variable<int>(quantidade.value);
    }
    if (precoCentavos.present) {
      map['preco_centavos'] = Variable<int>(precoCentavos.value);
    }
    if (tipoCobranca.present) {
      map['tipo_cobranca'] = Variable<String>(tipoCobranca.value);
    }
    if (categoria.present) {
      map['categoria'] = Variable<String>(categoria.value);
    }
    if (receitaId.present) {
      map['receita_id'] = Variable<int>(receitaId.value);
    }
    if (receitaIngredienteId.present) {
      map['receita_ingrediente_id'] = Variable<int>(receitaIngredienteId.value);
    }
    if (receitaNome.present) {
      map['receita_nome'] = Variable<String>(receitaNome.value);
    }
    if (unidade.present) {
      map['unidade'] = Variable<String>(unidade.value);
    }
    if (quantidadeMilesimos.present) {
      map['quantidade_milesimos'] = Variable<int>(quantidadeMilesimos.value);
    }
    if (servicoId.present) {
      map['servico_id'] = Variable<int>(servicoId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrcamentoItensCompanion(')
          ..write('id: $id, ')
          ..write('orcamentoId: $orcamentoId, ')
          ..write('nome: $nome, ')
          ..write('quantidade: $quantidade, ')
          ..write('precoCentavos: $precoCentavos, ')
          ..write('tipoCobranca: $tipoCobranca, ')
          ..write('categoria: $categoria, ')
          ..write('receitaId: $receitaId, ')
          ..write('receitaIngredienteId: $receitaIngredienteId, ')
          ..write('receitaNome: $receitaNome, ')
          ..write('unidade: $unidade, ')
          ..write('quantidadeMilesimos: $quantidadeMilesimos, ')
          ..write('servicoId: $servicoId')
          ..write(')'))
        .toString();
  }
}

class $EventosTable extends Eventos with TableInfo<$EventosTable, Evento> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventosTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _orcamentoIdMeta = const VerificationMeta(
    'orcamentoId',
  );
  @override
  late final GeneratedColumn<int> orcamentoId = GeneratedColumn<int>(
    'orcamento_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES orcamentos (id)',
    ),
  );
  static const VerificationMeta _tituloMeta = const VerificationMeta('titulo');
  @override
  late final GeneratedColumn<String> titulo = GeneratedColumn<String>(
    'titulo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localMeta = const VerificationMeta('local');
  @override
  late final GeneratedColumn<String> local = GeneratedColumn<String>(
    'local',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _inicioMeta = const VerificationMeta('inicio');
  @override
  late final GeneratedColumn<DateTime> inicio = GeneratedColumn<DateTime>(
    'inicio',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fimMeta = const VerificationMeta('fim');
  @override
  late final GeneratedColumn<DateTime> fim = GeneratedColumn<DateTime>(
    'fim',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    orcamentoId,
    titulo,
    local,
    inicio,
    fim,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'eventos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Evento> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('orcamento_id')) {
      context.handle(
        _orcamentoIdMeta,
        orcamentoId.isAcceptableOrUnknown(
          data['orcamento_id']!,
          _orcamentoIdMeta,
        ),
      );
    }
    if (data.containsKey('titulo')) {
      context.handle(
        _tituloMeta,
        titulo.isAcceptableOrUnknown(data['titulo']!, _tituloMeta),
      );
    } else if (isInserting) {
      context.missing(_tituloMeta);
    }
    if (data.containsKey('local')) {
      context.handle(
        _localMeta,
        local.isAcceptableOrUnknown(data['local']!, _localMeta),
      );
    }
    if (data.containsKey('inicio')) {
      context.handle(
        _inicioMeta,
        inicio.isAcceptableOrUnknown(data['inicio']!, _inicioMeta),
      );
    } else if (isInserting) {
      context.missing(_inicioMeta);
    }
    if (data.containsKey('fim')) {
      context.handle(
        _fimMeta,
        fim.isAcceptableOrUnknown(data['fim']!, _fimMeta),
      );
    } else if (isInserting) {
      context.missing(_fimMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Evento map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Evento(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      orcamentoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}orcamento_id'],
      ),
      titulo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}titulo'],
      )!,
      local: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local'],
      ),
      inicio: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}inicio'],
      )!,
      fim: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fim'],
      )!,
    );
  }

  @override
  $EventosTable createAlias(String alias) {
    return $EventosTable(attachedDatabase, alias);
  }
}

class Evento extends DataClass implements Insertable<Evento> {
  final int id;
  final int? orcamentoId;
  final String titulo;
  final String? local;
  final DateTime inicio;
  final DateTime fim;
  const Evento({
    required this.id,
    this.orcamentoId,
    required this.titulo,
    this.local,
    required this.inicio,
    required this.fim,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || orcamentoId != null) {
      map['orcamento_id'] = Variable<int>(orcamentoId);
    }
    map['titulo'] = Variable<String>(titulo);
    if (!nullToAbsent || local != null) {
      map['local'] = Variable<String>(local);
    }
    map['inicio'] = Variable<DateTime>(inicio);
    map['fim'] = Variable<DateTime>(fim);
    return map;
  }

  EventosCompanion toCompanion(bool nullToAbsent) {
    return EventosCompanion(
      id: Value(id),
      orcamentoId: orcamentoId == null && nullToAbsent
          ? const Value.absent()
          : Value(orcamentoId),
      titulo: Value(titulo),
      local: local == null && nullToAbsent
          ? const Value.absent()
          : Value(local),
      inicio: Value(inicio),
      fim: Value(fim),
    );
  }

  factory Evento.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Evento(
      id: serializer.fromJson<int>(json['id']),
      orcamentoId: serializer.fromJson<int?>(json['orcamentoId']),
      titulo: serializer.fromJson<String>(json['titulo']),
      local: serializer.fromJson<String?>(json['local']),
      inicio: serializer.fromJson<DateTime>(json['inicio']),
      fim: serializer.fromJson<DateTime>(json['fim']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'orcamentoId': serializer.toJson<int?>(orcamentoId),
      'titulo': serializer.toJson<String>(titulo),
      'local': serializer.toJson<String?>(local),
      'inicio': serializer.toJson<DateTime>(inicio),
      'fim': serializer.toJson<DateTime>(fim),
    };
  }

  Evento copyWith({
    int? id,
    Value<int?> orcamentoId = const Value.absent(),
    String? titulo,
    Value<String?> local = const Value.absent(),
    DateTime? inicio,
    DateTime? fim,
  }) => Evento(
    id: id ?? this.id,
    orcamentoId: orcamentoId.present ? orcamentoId.value : this.orcamentoId,
    titulo: titulo ?? this.titulo,
    local: local.present ? local.value : this.local,
    inicio: inicio ?? this.inicio,
    fim: fim ?? this.fim,
  );
  Evento copyWithCompanion(EventosCompanion data) {
    return Evento(
      id: data.id.present ? data.id.value : this.id,
      orcamentoId: data.orcamentoId.present
          ? data.orcamentoId.value
          : this.orcamentoId,
      titulo: data.titulo.present ? data.titulo.value : this.titulo,
      local: data.local.present ? data.local.value : this.local,
      inicio: data.inicio.present ? data.inicio.value : this.inicio,
      fim: data.fim.present ? data.fim.value : this.fim,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Evento(')
          ..write('id: $id, ')
          ..write('orcamentoId: $orcamentoId, ')
          ..write('titulo: $titulo, ')
          ..write('local: $local, ')
          ..write('inicio: $inicio, ')
          ..write('fim: $fim')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, orcamentoId, titulo, local, inicio, fim);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Evento &&
          other.id == this.id &&
          other.orcamentoId == this.orcamentoId &&
          other.titulo == this.titulo &&
          other.local == this.local &&
          other.inicio == this.inicio &&
          other.fim == this.fim);
}

class EventosCompanion extends UpdateCompanion<Evento> {
  final Value<int> id;
  final Value<int?> orcamentoId;
  final Value<String> titulo;
  final Value<String?> local;
  final Value<DateTime> inicio;
  final Value<DateTime> fim;
  const EventosCompanion({
    this.id = const Value.absent(),
    this.orcamentoId = const Value.absent(),
    this.titulo = const Value.absent(),
    this.local = const Value.absent(),
    this.inicio = const Value.absent(),
    this.fim = const Value.absent(),
  });
  EventosCompanion.insert({
    this.id = const Value.absent(),
    this.orcamentoId = const Value.absent(),
    required String titulo,
    this.local = const Value.absent(),
    required DateTime inicio,
    required DateTime fim,
  }) : titulo = Value(titulo),
       inicio = Value(inicio),
       fim = Value(fim);
  static Insertable<Evento> custom({
    Expression<int>? id,
    Expression<int>? orcamentoId,
    Expression<String>? titulo,
    Expression<String>? local,
    Expression<DateTime>? inicio,
    Expression<DateTime>? fim,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orcamentoId != null) 'orcamento_id': orcamentoId,
      if (titulo != null) 'titulo': titulo,
      if (local != null) 'local': local,
      if (inicio != null) 'inicio': inicio,
      if (fim != null) 'fim': fim,
    });
  }

  EventosCompanion copyWith({
    Value<int>? id,
    Value<int?>? orcamentoId,
    Value<String>? titulo,
    Value<String?>? local,
    Value<DateTime>? inicio,
    Value<DateTime>? fim,
  }) {
    return EventosCompanion(
      id: id ?? this.id,
      orcamentoId: orcamentoId ?? this.orcamentoId,
      titulo: titulo ?? this.titulo,
      local: local ?? this.local,
      inicio: inicio ?? this.inicio,
      fim: fim ?? this.fim,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (orcamentoId.present) {
      map['orcamento_id'] = Variable<int>(orcamentoId.value);
    }
    if (titulo.present) {
      map['titulo'] = Variable<String>(titulo.value);
    }
    if (local.present) {
      map['local'] = Variable<String>(local.value);
    }
    if (inicio.present) {
      map['inicio'] = Variable<DateTime>(inicio.value);
    }
    if (fim.present) {
      map['fim'] = Variable<DateTime>(fim.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventosCompanion(')
          ..write('id: $id, ')
          ..write('orcamentoId: $orcamentoId, ')
          ..write('titulo: $titulo, ')
          ..write('local: $local, ')
          ..write('inicio: $inicio, ')
          ..write('fim: $fim')
          ..write(')'))
        .toString();
  }
}

class $EmpresasTable extends Empresas with TableInfo<$EmpresasTable, Empresa> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmpresasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Seu Bufê'),
  );
  static const VerificationMeta _telefoneMeta = const VerificationMeta(
    'telefone',
  );
  @override
  late final GeneratedColumn<String> telefone = GeneratedColumn<String>(
    'telefone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _validadeDiasMeta = const VerificationMeta(
    'validadeDias',
  );
  @override
  late final GeneratedColumn<int> validadeDias = GeneratedColumn<int>(
    'validade_dias',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(15),
  );
  static const VerificationMeta _logoMeta = const VerificationMeta('logo');
  @override
  late final GeneratedColumn<Uint8List> logo = GeneratedColumn<Uint8List>(
    'logo',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nome,
    telefone,
    email,
    validadeDias,
    logo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'empresas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Empresa> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    }
    if (data.containsKey('telefone')) {
      context.handle(
        _telefoneMeta,
        telefone.isAcceptableOrUnknown(data['telefone']!, _telefoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('validade_dias')) {
      context.handle(
        _validadeDiasMeta,
        validadeDias.isAcceptableOrUnknown(
          data['validade_dias']!,
          _validadeDiasMeta,
        ),
      );
    }
    if (data.containsKey('logo')) {
      context.handle(
        _logoMeta,
        logo.isAcceptableOrUnknown(data['logo']!, _logoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Empresa map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Empresa(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      telefone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}telefone'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      validadeDias: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}validade_dias'],
      )!,
      logo: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}logo'],
      ),
    );
  }

  @override
  $EmpresasTable createAlias(String alias) {
    return $EmpresasTable(attachedDatabase, alias);
  }
}

class Empresa extends DataClass implements Insertable<Empresa> {
  final int id;
  final String nome;
  final String telefone;
  final String email;
  final int validadeDias;
  final Uint8List? logo;
  const Empresa({
    required this.id,
    required this.nome,
    required this.telefone,
    required this.email,
    required this.validadeDias,
    this.logo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nome'] = Variable<String>(nome);
    map['telefone'] = Variable<String>(telefone);
    map['email'] = Variable<String>(email);
    map['validade_dias'] = Variable<int>(validadeDias);
    if (!nullToAbsent || logo != null) {
      map['logo'] = Variable<Uint8List>(logo);
    }
    return map;
  }

  EmpresasCompanion toCompanion(bool nullToAbsent) {
    return EmpresasCompanion(
      id: Value(id),
      nome: Value(nome),
      telefone: Value(telefone),
      email: Value(email),
      validadeDias: Value(validadeDias),
      logo: logo == null && nullToAbsent ? const Value.absent() : Value(logo),
    );
  }

  factory Empresa.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Empresa(
      id: serializer.fromJson<int>(json['id']),
      nome: serializer.fromJson<String>(json['nome']),
      telefone: serializer.fromJson<String>(json['telefone']),
      email: serializer.fromJson<String>(json['email']),
      validadeDias: serializer.fromJson<int>(json['validadeDias']),
      logo: serializer.fromJson<Uint8List?>(json['logo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nome': serializer.toJson<String>(nome),
      'telefone': serializer.toJson<String>(telefone),
      'email': serializer.toJson<String>(email),
      'validadeDias': serializer.toJson<int>(validadeDias),
      'logo': serializer.toJson<Uint8List?>(logo),
    };
  }

  Empresa copyWith({
    int? id,
    String? nome,
    String? telefone,
    String? email,
    int? validadeDias,
    Value<Uint8List?> logo = const Value.absent(),
  }) => Empresa(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    telefone: telefone ?? this.telefone,
    email: email ?? this.email,
    validadeDias: validadeDias ?? this.validadeDias,
    logo: logo.present ? logo.value : this.logo,
  );
  Empresa copyWithCompanion(EmpresasCompanion data) {
    return Empresa(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
      telefone: data.telefone.present ? data.telefone.value : this.telefone,
      email: data.email.present ? data.email.value : this.email,
      validadeDias: data.validadeDias.present
          ? data.validadeDias.value
          : this.validadeDias,
      logo: data.logo.present ? data.logo.value : this.logo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Empresa(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('telefone: $telefone, ')
          ..write('email: $email, ')
          ..write('validadeDias: $validadeDias, ')
          ..write('logo: $logo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nome,
    telefone,
    email,
    validadeDias,
    $driftBlobEquality.hash(logo),
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Empresa &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.telefone == this.telefone &&
          other.email == this.email &&
          other.validadeDias == this.validadeDias &&
          $driftBlobEquality.equals(other.logo, this.logo));
}

class EmpresasCompanion extends UpdateCompanion<Empresa> {
  final Value<int> id;
  final Value<String> nome;
  final Value<String> telefone;
  final Value<String> email;
  final Value<int> validadeDias;
  final Value<Uint8List?> logo;
  const EmpresasCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.telefone = const Value.absent(),
    this.email = const Value.absent(),
    this.validadeDias = const Value.absent(),
    this.logo = const Value.absent(),
  });
  EmpresasCompanion.insert({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.telefone = const Value.absent(),
    this.email = const Value.absent(),
    this.validadeDias = const Value.absent(),
    this.logo = const Value.absent(),
  });
  static Insertable<Empresa> custom({
    Expression<int>? id,
    Expression<String>? nome,
    Expression<String>? telefone,
    Expression<String>? email,
    Expression<int>? validadeDias,
    Expression<Uint8List>? logo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
      if (telefone != null) 'telefone': telefone,
      if (email != null) 'email': email,
      if (validadeDias != null) 'validade_dias': validadeDias,
      if (logo != null) 'logo': logo,
    });
  }

  EmpresasCompanion copyWith({
    Value<int>? id,
    Value<String>? nome,
    Value<String>? telefone,
    Value<String>? email,
    Value<int>? validadeDias,
    Value<Uint8List?>? logo,
  }) {
    return EmpresasCompanion(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      telefone: telefone ?? this.telefone,
      email: email ?? this.email,
      validadeDias: validadeDias ?? this.validadeDias,
      logo: logo ?? this.logo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (telefone.present) {
      map['telefone'] = Variable<String>(telefone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (validadeDias.present) {
      map['validade_dias'] = Variable<int>(validadeDias.value);
    }
    if (logo.present) {
      map['logo'] = Variable<Uint8List>(logo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmpresasCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('telefone: $telefone, ')
          ..write('email: $email, ')
          ..write('validadeDias: $validadeDias, ')
          ..write('logo: $logo')
          ..write(')'))
        .toString();
  }
}

class $ReceitasTable extends Receitas with TableInfo<$ReceitasTable, Receita> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReceitasTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 150,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rendimentoPessoasMeta = const VerificationMeta(
    'rendimentoPessoas',
  );
  @override
  late final GeneratedColumn<int> rendimentoPessoas = GeneratedColumn<int>(
    'rendimento_pessoas',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _criadoEmMeta = const VerificationMeta(
    'criadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> criadoEm = GeneratedColumn<DateTime>(
    'criado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nome,
    rendimentoPessoas,
    criadoEm,
    atualizadoEm,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'receitas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Receita> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('rendimento_pessoas')) {
      context.handle(
        _rendimentoPessoasMeta,
        rendimentoPessoas.isAcceptableOrUnknown(
          data['rendimento_pessoas']!,
          _rendimentoPessoasMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rendimentoPessoasMeta);
    }
    if (data.containsKey('criado_em')) {
      context.handle(
        _criadoEmMeta,
        criadoEm.isAcceptableOrUnknown(data['criado_em']!, _criadoEmMeta),
      );
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Receita map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Receita(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      rendimentoPessoas: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rendimento_pessoas'],
      )!,
      criadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}criado_em'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
    );
  }

  @override
  $ReceitasTable createAlias(String alias) {
    return $ReceitasTable(attachedDatabase, alias);
  }
}

class Receita extends DataClass implements Insertable<Receita> {
  final int id;
  final String nome;
  final int rendimentoPessoas;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  const Receita({
    required this.id,
    required this.nome,
    required this.rendimentoPessoas,
    required this.criadoEm,
    required this.atualizadoEm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nome'] = Variable<String>(nome);
    map['rendimento_pessoas'] = Variable<int>(rendimentoPessoas);
    map['criado_em'] = Variable<DateTime>(criadoEm);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    return map;
  }

  ReceitasCompanion toCompanion(bool nullToAbsent) {
    return ReceitasCompanion(
      id: Value(id),
      nome: Value(nome),
      rendimentoPessoas: Value(rendimentoPessoas),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
    );
  }

  factory Receita.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Receita(
      id: serializer.fromJson<int>(json['id']),
      nome: serializer.fromJson<String>(json['nome']),
      rendimentoPessoas: serializer.fromJson<int>(json['rendimentoPessoas']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nome': serializer.toJson<String>(nome),
      'rendimentoPessoas': serializer.toJson<int>(rendimentoPessoas),
      'criadoEm': serializer.toJson<DateTime>(criadoEm),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
    };
  }

  Receita copyWith({
    int? id,
    String? nome,
    int? rendimentoPessoas,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) => Receita(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    rendimentoPessoas: rendimentoPessoas ?? this.rendimentoPessoas,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
  );
  Receita copyWithCompanion(ReceitasCompanion data) {
    return Receita(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
      rendimentoPessoas: data.rendimentoPessoas.present
          ? data.rendimentoPessoas.value
          : this.rendimentoPessoas,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Receita(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('rendimentoPessoas: $rendimentoPessoas, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, nome, rendimentoPessoas, criadoEm, atualizadoEm);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Receita &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.rendimentoPessoas == this.rendimentoPessoas &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm);
}

class ReceitasCompanion extends UpdateCompanion<Receita> {
  final Value<int> id;
  final Value<String> nome;
  final Value<int> rendimentoPessoas;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  const ReceitasCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.rendimentoPessoas = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
  });
  ReceitasCompanion.insert({
    this.id = const Value.absent(),
    required String nome,
    required int rendimentoPessoas,
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
  }) : nome = Value(nome),
       rendimentoPessoas = Value(rendimentoPessoas);
  static Insertable<Receita> custom({
    Expression<int>? id,
    Expression<String>? nome,
    Expression<int>? rendimentoPessoas,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
      if (rendimentoPessoas != null) 'rendimento_pessoas': rendimentoPessoas,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
    });
  }

  ReceitasCompanion copyWith({
    Value<int>? id,
    Value<String>? nome,
    Value<int>? rendimentoPessoas,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
  }) {
    return ReceitasCompanion(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      rendimentoPessoas: rendimentoPessoas ?? this.rendimentoPessoas,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (rendimentoPessoas.present) {
      map['rendimento_pessoas'] = Variable<int>(rendimentoPessoas.value);
    }
    if (criadoEm.present) {
      map['criado_em'] = Variable<DateTime>(criadoEm.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReceitasCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('rendimentoPessoas: $rendimentoPessoas, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm')
          ..write(')'))
        .toString();
  }
}

class $ReceitaIngredientesTable extends ReceitaIngredientes
    with TableInfo<$ReceitaIngredientesTable, ReceitaIngrediente> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReceitaIngredientesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _receitaIdMeta = const VerificationMeta(
    'receitaId',
  );
  @override
  late final GeneratedColumn<int> receitaId = GeneratedColumn<int>(
    'receita_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES receitas (id)',
    ),
  );
  static const VerificationMeta _produtoMeta = const VerificationMeta(
    'produto',
  );
  @override
  late final GeneratedColumn<String> produto = GeneratedColumn<String>(
    'produto',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 150,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantidadeMilesimosMeta =
      const VerificationMeta('quantidadeMilesimos');
  @override
  late final GeneratedColumn<int> quantidadeMilesimos = GeneratedColumn<int>(
    'quantidade_milesimos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unidadeMeta = const VerificationMeta(
    'unidade',
  );
  @override
  late final GeneratedColumn<String> unidade = GeneratedColumn<String>(
    'unidade',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 30,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _precoCentavosMeta = const VerificationMeta(
    'precoCentavos',
  );
  @override
  late final GeneratedColumn<int> precoCentavos = GeneratedColumn<int>(
    'preco_centavos',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _criadoEmMeta = const VerificationMeta(
    'criadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> criadoEm = GeneratedColumn<DateTime>(
    'criado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    receitaId,
    produto,
    quantidadeMilesimos,
    unidade,
    precoCentavos,
    criadoEm,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'receita_ingredientes';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReceitaIngrediente> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('receita_id')) {
      context.handle(
        _receitaIdMeta,
        receitaId.isAcceptableOrUnknown(data['receita_id']!, _receitaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_receitaIdMeta);
    }
    if (data.containsKey('produto')) {
      context.handle(
        _produtoMeta,
        produto.isAcceptableOrUnknown(data['produto']!, _produtoMeta),
      );
    } else if (isInserting) {
      context.missing(_produtoMeta);
    }
    if (data.containsKey('quantidade_milesimos')) {
      context.handle(
        _quantidadeMilesimosMeta,
        quantidadeMilesimos.isAcceptableOrUnknown(
          data['quantidade_milesimos']!,
          _quantidadeMilesimosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantidadeMilesimosMeta);
    }
    if (data.containsKey('unidade')) {
      context.handle(
        _unidadeMeta,
        unidade.isAcceptableOrUnknown(data['unidade']!, _unidadeMeta),
      );
    } else if (isInserting) {
      context.missing(_unidadeMeta);
    }
    if (data.containsKey('preco_centavos')) {
      context.handle(
        _precoCentavosMeta,
        precoCentavos.isAcceptableOrUnknown(
          data['preco_centavos']!,
          _precoCentavosMeta,
        ),
      );
    }
    if (data.containsKey('criado_em')) {
      context.handle(
        _criadoEmMeta,
        criadoEm.isAcceptableOrUnknown(data['criado_em']!, _criadoEmMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReceitaIngrediente map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReceitaIngrediente(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      receitaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}receita_id'],
      )!,
      produto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}produto'],
      )!,
      quantidadeMilesimos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantidade_milesimos'],
      )!,
      unidade: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unidade'],
      )!,
      precoCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}preco_centavos'],
      ),
      criadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}criado_em'],
      )!,
    );
  }

  @override
  $ReceitaIngredientesTable createAlias(String alias) {
    return $ReceitaIngredientesTable(attachedDatabase, alias);
  }
}

class ReceitaIngrediente extends DataClass
    implements Insertable<ReceitaIngrediente> {
  final int id;
  final int receitaId;
  final String produto;

  /// Quantidade armazenada em milésimos da unidade.
  final int quantidadeMilesimos;

  /// Exemplos: g, kg, ml, l, un, cabeça, pacote.
  final String unidade;

  /// Preço estimado do ingrediente, em centavos. Pode ser nulo.
  final int? precoCentavos;
  final DateTime criadoEm;
  const ReceitaIngrediente({
    required this.id,
    required this.receitaId,
    required this.produto,
    required this.quantidadeMilesimos,
    required this.unidade,
    this.precoCentavos,
    required this.criadoEm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['receita_id'] = Variable<int>(receitaId);
    map['produto'] = Variable<String>(produto);
    map['quantidade_milesimos'] = Variable<int>(quantidadeMilesimos);
    map['unidade'] = Variable<String>(unidade);
    if (!nullToAbsent || precoCentavos != null) {
      map['preco_centavos'] = Variable<int>(precoCentavos);
    }
    map['criado_em'] = Variable<DateTime>(criadoEm);
    return map;
  }

  ReceitaIngredientesCompanion toCompanion(bool nullToAbsent) {
    return ReceitaIngredientesCompanion(
      id: Value(id),
      receitaId: Value(receitaId),
      produto: Value(produto),
      quantidadeMilesimos: Value(quantidadeMilesimos),
      unidade: Value(unidade),
      precoCentavos: precoCentavos == null && nullToAbsent
          ? const Value.absent()
          : Value(precoCentavos),
      criadoEm: Value(criadoEm),
    );
  }

  factory ReceitaIngrediente.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReceitaIngrediente(
      id: serializer.fromJson<int>(json['id']),
      receitaId: serializer.fromJson<int>(json['receitaId']),
      produto: serializer.fromJson<String>(json['produto']),
      quantidadeMilesimos: serializer.fromJson<int>(
        json['quantidadeMilesimos'],
      ),
      unidade: serializer.fromJson<String>(json['unidade']),
      precoCentavos: serializer.fromJson<int?>(json['precoCentavos']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'receitaId': serializer.toJson<int>(receitaId),
      'produto': serializer.toJson<String>(produto),
      'quantidadeMilesimos': serializer.toJson<int>(quantidadeMilesimos),
      'unidade': serializer.toJson<String>(unidade),
      'precoCentavos': serializer.toJson<int?>(precoCentavos),
      'criadoEm': serializer.toJson<DateTime>(criadoEm),
    };
  }

  ReceitaIngrediente copyWith({
    int? id,
    int? receitaId,
    String? produto,
    int? quantidadeMilesimos,
    String? unidade,
    Value<int?> precoCentavos = const Value.absent(),
    DateTime? criadoEm,
  }) => ReceitaIngrediente(
    id: id ?? this.id,
    receitaId: receitaId ?? this.receitaId,
    produto: produto ?? this.produto,
    quantidadeMilesimos: quantidadeMilesimos ?? this.quantidadeMilesimos,
    unidade: unidade ?? this.unidade,
    precoCentavos: precoCentavos.present
        ? precoCentavos.value
        : this.precoCentavos,
    criadoEm: criadoEm ?? this.criadoEm,
  );
  ReceitaIngrediente copyWithCompanion(ReceitaIngredientesCompanion data) {
    return ReceitaIngrediente(
      id: data.id.present ? data.id.value : this.id,
      receitaId: data.receitaId.present ? data.receitaId.value : this.receitaId,
      produto: data.produto.present ? data.produto.value : this.produto,
      quantidadeMilesimos: data.quantidadeMilesimos.present
          ? data.quantidadeMilesimos.value
          : this.quantidadeMilesimos,
      unidade: data.unidade.present ? data.unidade.value : this.unidade,
      precoCentavos: data.precoCentavos.present
          ? data.precoCentavos.value
          : this.precoCentavos,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReceitaIngrediente(')
          ..write('id: $id, ')
          ..write('receitaId: $receitaId, ')
          ..write('produto: $produto, ')
          ..write('quantidadeMilesimos: $quantidadeMilesimos, ')
          ..write('unidade: $unidade, ')
          ..write('precoCentavos: $precoCentavos, ')
          ..write('criadoEm: $criadoEm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    receitaId,
    produto,
    quantidadeMilesimos,
    unidade,
    precoCentavos,
    criadoEm,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReceitaIngrediente &&
          other.id == this.id &&
          other.receitaId == this.receitaId &&
          other.produto == this.produto &&
          other.quantidadeMilesimos == this.quantidadeMilesimos &&
          other.unidade == this.unidade &&
          other.precoCentavos == this.precoCentavos &&
          other.criadoEm == this.criadoEm);
}

class ReceitaIngredientesCompanion extends UpdateCompanion<ReceitaIngrediente> {
  final Value<int> id;
  final Value<int> receitaId;
  final Value<String> produto;
  final Value<int> quantidadeMilesimos;
  final Value<String> unidade;
  final Value<int?> precoCentavos;
  final Value<DateTime> criadoEm;
  const ReceitaIngredientesCompanion({
    this.id = const Value.absent(),
    this.receitaId = const Value.absent(),
    this.produto = const Value.absent(),
    this.quantidadeMilesimos = const Value.absent(),
    this.unidade = const Value.absent(),
    this.precoCentavos = const Value.absent(),
    this.criadoEm = const Value.absent(),
  });
  ReceitaIngredientesCompanion.insert({
    this.id = const Value.absent(),
    required int receitaId,
    required String produto,
    required int quantidadeMilesimos,
    required String unidade,
    this.precoCentavos = const Value.absent(),
    this.criadoEm = const Value.absent(),
  }) : receitaId = Value(receitaId),
       produto = Value(produto),
       quantidadeMilesimos = Value(quantidadeMilesimos),
       unidade = Value(unidade);
  static Insertable<ReceitaIngrediente> custom({
    Expression<int>? id,
    Expression<int>? receitaId,
    Expression<String>? produto,
    Expression<int>? quantidadeMilesimos,
    Expression<String>? unidade,
    Expression<int>? precoCentavos,
    Expression<DateTime>? criadoEm,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (receitaId != null) 'receita_id': receitaId,
      if (produto != null) 'produto': produto,
      if (quantidadeMilesimos != null)
        'quantidade_milesimos': quantidadeMilesimos,
      if (unidade != null) 'unidade': unidade,
      if (precoCentavos != null) 'preco_centavos': precoCentavos,
      if (criadoEm != null) 'criado_em': criadoEm,
    });
  }

  ReceitaIngredientesCompanion copyWith({
    Value<int>? id,
    Value<int>? receitaId,
    Value<String>? produto,
    Value<int>? quantidadeMilesimos,
    Value<String>? unidade,
    Value<int?>? precoCentavos,
    Value<DateTime>? criadoEm,
  }) {
    return ReceitaIngredientesCompanion(
      id: id ?? this.id,
      receitaId: receitaId ?? this.receitaId,
      produto: produto ?? this.produto,
      quantidadeMilesimos: quantidadeMilesimos ?? this.quantidadeMilesimos,
      unidade: unidade ?? this.unidade,
      precoCentavos: precoCentavos ?? this.precoCentavos,
      criadoEm: criadoEm ?? this.criadoEm,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (receitaId.present) {
      map['receita_id'] = Variable<int>(receitaId.value);
    }
    if (produto.present) {
      map['produto'] = Variable<String>(produto.value);
    }
    if (quantidadeMilesimos.present) {
      map['quantidade_milesimos'] = Variable<int>(quantidadeMilesimos.value);
    }
    if (unidade.present) {
      map['unidade'] = Variable<String>(unidade.value);
    }
    if (precoCentavos.present) {
      map['preco_centavos'] = Variable<int>(precoCentavos.value);
    }
    if (criadoEm.present) {
      map['criado_em'] = Variable<DateTime>(criadoEm.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReceitaIngredientesCompanion(')
          ..write('id: $id, ')
          ..write('receitaId: $receitaId, ')
          ..write('produto: $produto, ')
          ..write('quantidadeMilesimos: $quantidadeMilesimos, ')
          ..write('unidade: $unidade, ')
          ..write('precoCentavos: $precoCentavos, ')
          ..write('criadoEm: $criadoEm')
          ..write(')'))
        .toString();
  }
}

class $OrcamentoReceitasTable extends OrcamentoReceitas
    with TableInfo<$OrcamentoReceitasTable, OrcamentoReceita> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrcamentoReceitasTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _orcamentoIdMeta = const VerificationMeta(
    'orcamentoId',
  );
  @override
  late final GeneratedColumn<int> orcamentoId = GeneratedColumn<int>(
    'orcamento_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES orcamentos (id)',
    ),
  );
  static const VerificationMeta _receitaIdMeta = const VerificationMeta(
    'receitaId',
  );
  @override
  late final GeneratedColumn<int> receitaId = GeneratedColumn<int>(
    'receita_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES receitas (id)',
    ),
  );
  static const VerificationMeta _fatorMilesimosMeta = const VerificationMeta(
    'fatorMilesimos',
  );
  @override
  late final GeneratedColumn<int> fatorMilesimos = GeneratedColumn<int>(
    'fator_milesimos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _convidadosNoMomentoMeta =
      const VerificationMeta('convidadosNoMomento');
  @override
  late final GeneratedColumn<int> convidadosNoMomento = GeneratedColumn<int>(
    'convidados_no_momento',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _adicionadaEmMeta = const VerificationMeta(
    'adicionadaEm',
  );
  @override
  late final GeneratedColumn<DateTime> adicionadaEm = GeneratedColumn<DateTime>(
    'adicionada_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    orcamentoId,
    receitaId,
    fatorMilesimos,
    convidadosNoMomento,
    adicionadaEm,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'orcamento_receitas';
  @override
  VerificationContext validateIntegrity(
    Insertable<OrcamentoReceita> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('orcamento_id')) {
      context.handle(
        _orcamentoIdMeta,
        orcamentoId.isAcceptableOrUnknown(
          data['orcamento_id']!,
          _orcamentoIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_orcamentoIdMeta);
    }
    if (data.containsKey('receita_id')) {
      context.handle(
        _receitaIdMeta,
        receitaId.isAcceptableOrUnknown(data['receita_id']!, _receitaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_receitaIdMeta);
    }
    if (data.containsKey('fator_milesimos')) {
      context.handle(
        _fatorMilesimosMeta,
        fatorMilesimos.isAcceptableOrUnknown(
          data['fator_milesimos']!,
          _fatorMilesimosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fatorMilesimosMeta);
    }
    if (data.containsKey('convidados_no_momento')) {
      context.handle(
        _convidadosNoMomentoMeta,
        convidadosNoMomento.isAcceptableOrUnknown(
          data['convidados_no_momento']!,
          _convidadosNoMomentoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_convidadosNoMomentoMeta);
    }
    if (data.containsKey('adicionada_em')) {
      context.handle(
        _adicionadaEmMeta,
        adicionadaEm.isAcceptableOrUnknown(
          data['adicionada_em']!,
          _adicionadaEmMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrcamentoReceita map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrcamentoReceita(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      orcamentoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}orcamento_id'],
      )!,
      receitaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}receita_id'],
      )!,
      fatorMilesimos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fator_milesimos'],
      )!,
      convidadosNoMomento: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}convidados_no_momento'],
      )!,
      adicionadaEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}adicionada_em'],
      )!,
    );
  }

  @override
  $OrcamentoReceitasTable createAlias(String alias) {
    return $OrcamentoReceitasTable(attachedDatabase, alias);
  }
}

class OrcamentoReceita extends DataClass
    implements Insertable<OrcamentoReceita> {
  final int id;
  final int orcamentoId;
  final int receitaId;

  /// Fator calculado no momento da inclusão.
  final int fatorMilesimos;

  /// Quantidade de convidados usada ao incluir a receita.
  final int convidadosNoMomento;
  final DateTime adicionadaEm;
  const OrcamentoReceita({
    required this.id,
    required this.orcamentoId,
    required this.receitaId,
    required this.fatorMilesimos,
    required this.convidadosNoMomento,
    required this.adicionadaEm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['orcamento_id'] = Variable<int>(orcamentoId);
    map['receita_id'] = Variable<int>(receitaId);
    map['fator_milesimos'] = Variable<int>(fatorMilesimos);
    map['convidados_no_momento'] = Variable<int>(convidadosNoMomento);
    map['adicionada_em'] = Variable<DateTime>(adicionadaEm);
    return map;
  }

  OrcamentoReceitasCompanion toCompanion(bool nullToAbsent) {
    return OrcamentoReceitasCompanion(
      id: Value(id),
      orcamentoId: Value(orcamentoId),
      receitaId: Value(receitaId),
      fatorMilesimos: Value(fatorMilesimos),
      convidadosNoMomento: Value(convidadosNoMomento),
      adicionadaEm: Value(adicionadaEm),
    );
  }

  factory OrcamentoReceita.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrcamentoReceita(
      id: serializer.fromJson<int>(json['id']),
      orcamentoId: serializer.fromJson<int>(json['orcamentoId']),
      receitaId: serializer.fromJson<int>(json['receitaId']),
      fatorMilesimos: serializer.fromJson<int>(json['fatorMilesimos']),
      convidadosNoMomento: serializer.fromJson<int>(
        json['convidadosNoMomento'],
      ),
      adicionadaEm: serializer.fromJson<DateTime>(json['adicionadaEm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'orcamentoId': serializer.toJson<int>(orcamentoId),
      'receitaId': serializer.toJson<int>(receitaId),
      'fatorMilesimos': serializer.toJson<int>(fatorMilesimos),
      'convidadosNoMomento': serializer.toJson<int>(convidadosNoMomento),
      'adicionadaEm': serializer.toJson<DateTime>(adicionadaEm),
    };
  }

  OrcamentoReceita copyWith({
    int? id,
    int? orcamentoId,
    int? receitaId,
    int? fatorMilesimos,
    int? convidadosNoMomento,
    DateTime? adicionadaEm,
  }) => OrcamentoReceita(
    id: id ?? this.id,
    orcamentoId: orcamentoId ?? this.orcamentoId,
    receitaId: receitaId ?? this.receitaId,
    fatorMilesimos: fatorMilesimos ?? this.fatorMilesimos,
    convidadosNoMomento: convidadosNoMomento ?? this.convidadosNoMomento,
    adicionadaEm: adicionadaEm ?? this.adicionadaEm,
  );
  OrcamentoReceita copyWithCompanion(OrcamentoReceitasCompanion data) {
    return OrcamentoReceita(
      id: data.id.present ? data.id.value : this.id,
      orcamentoId: data.orcamentoId.present
          ? data.orcamentoId.value
          : this.orcamentoId,
      receitaId: data.receitaId.present ? data.receitaId.value : this.receitaId,
      fatorMilesimos: data.fatorMilesimos.present
          ? data.fatorMilesimos.value
          : this.fatorMilesimos,
      convidadosNoMomento: data.convidadosNoMomento.present
          ? data.convidadosNoMomento.value
          : this.convidadosNoMomento,
      adicionadaEm: data.adicionadaEm.present
          ? data.adicionadaEm.value
          : this.adicionadaEm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrcamentoReceita(')
          ..write('id: $id, ')
          ..write('orcamentoId: $orcamentoId, ')
          ..write('receitaId: $receitaId, ')
          ..write('fatorMilesimos: $fatorMilesimos, ')
          ..write('convidadosNoMomento: $convidadosNoMomento, ')
          ..write('adicionadaEm: $adicionadaEm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    orcamentoId,
    receitaId,
    fatorMilesimos,
    convidadosNoMomento,
    adicionadaEm,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrcamentoReceita &&
          other.id == this.id &&
          other.orcamentoId == this.orcamentoId &&
          other.receitaId == this.receitaId &&
          other.fatorMilesimos == this.fatorMilesimos &&
          other.convidadosNoMomento == this.convidadosNoMomento &&
          other.adicionadaEm == this.adicionadaEm);
}

class OrcamentoReceitasCompanion extends UpdateCompanion<OrcamentoReceita> {
  final Value<int> id;
  final Value<int> orcamentoId;
  final Value<int> receitaId;
  final Value<int> fatorMilesimos;
  final Value<int> convidadosNoMomento;
  final Value<DateTime> adicionadaEm;
  const OrcamentoReceitasCompanion({
    this.id = const Value.absent(),
    this.orcamentoId = const Value.absent(),
    this.receitaId = const Value.absent(),
    this.fatorMilesimos = const Value.absent(),
    this.convidadosNoMomento = const Value.absent(),
    this.adicionadaEm = const Value.absent(),
  });
  OrcamentoReceitasCompanion.insert({
    this.id = const Value.absent(),
    required int orcamentoId,
    required int receitaId,
    required int fatorMilesimos,
    required int convidadosNoMomento,
    this.adicionadaEm = const Value.absent(),
  }) : orcamentoId = Value(orcamentoId),
       receitaId = Value(receitaId),
       fatorMilesimos = Value(fatorMilesimos),
       convidadosNoMomento = Value(convidadosNoMomento);
  static Insertable<OrcamentoReceita> custom({
    Expression<int>? id,
    Expression<int>? orcamentoId,
    Expression<int>? receitaId,
    Expression<int>? fatorMilesimos,
    Expression<int>? convidadosNoMomento,
    Expression<DateTime>? adicionadaEm,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orcamentoId != null) 'orcamento_id': orcamentoId,
      if (receitaId != null) 'receita_id': receitaId,
      if (fatorMilesimos != null) 'fator_milesimos': fatorMilesimos,
      if (convidadosNoMomento != null)
        'convidados_no_momento': convidadosNoMomento,
      if (adicionadaEm != null) 'adicionada_em': adicionadaEm,
    });
  }

  OrcamentoReceitasCompanion copyWith({
    Value<int>? id,
    Value<int>? orcamentoId,
    Value<int>? receitaId,
    Value<int>? fatorMilesimos,
    Value<int>? convidadosNoMomento,
    Value<DateTime>? adicionadaEm,
  }) {
    return OrcamentoReceitasCompanion(
      id: id ?? this.id,
      orcamentoId: orcamentoId ?? this.orcamentoId,
      receitaId: receitaId ?? this.receitaId,
      fatorMilesimos: fatorMilesimos ?? this.fatorMilesimos,
      convidadosNoMomento: convidadosNoMomento ?? this.convidadosNoMomento,
      adicionadaEm: adicionadaEm ?? this.adicionadaEm,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (orcamentoId.present) {
      map['orcamento_id'] = Variable<int>(orcamentoId.value);
    }
    if (receitaId.present) {
      map['receita_id'] = Variable<int>(receitaId.value);
    }
    if (fatorMilesimos.present) {
      map['fator_milesimos'] = Variable<int>(fatorMilesimos.value);
    }
    if (convidadosNoMomento.present) {
      map['convidados_no_momento'] = Variable<int>(convidadosNoMomento.value);
    }
    if (adicionadaEm.present) {
      map['adicionada_em'] = Variable<DateTime>(adicionadaEm.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrcamentoReceitasCompanion(')
          ..write('id: $id, ')
          ..write('orcamentoId: $orcamentoId, ')
          ..write('receitaId: $receitaId, ')
          ..write('fatorMilesimos: $fatorMilesimos, ')
          ..write('convidadosNoMomento: $convidadosNoMomento, ')
          ..write('adicionadaEm: $adicionadaEm')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ClientesTable clientes = $ClientesTable(this);
  late final $OrcamentosTable orcamentos = $OrcamentosTable(this);
  late final $ServicosTable servicos = $ServicosTable(this);
  late final $OrcamentoItensTable orcamentoItens = $OrcamentoItensTable(this);
  late final $EventosTable eventos = $EventosTable(this);
  late final $EmpresasTable empresas = $EmpresasTable(this);
  late final $ReceitasTable receitas = $ReceitasTable(this);
  late final $ReceitaIngredientesTable receitaIngredientes =
      $ReceitaIngredientesTable(this);
  late final $OrcamentoReceitasTable orcamentoReceitas =
      $OrcamentoReceitasTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    clientes,
    orcamentos,
    servicos,
    orcamentoItens,
    eventos,
    empresas,
    receitas,
    receitaIngredientes,
    orcamentoReceitas,
  ];
}

typedef $$ClientesTableCreateCompanionBuilder = ClientesCompanion Function({
  Value<int> id,
  required String nome,
  Value<String?> telefone,
  Value<String?> email,
});
typedef $$ClientesTableUpdateCompanionBuilder = ClientesCompanion Function({
  Value<int> id,
  Value<String> nome,
  Value<String?> telefone,
  Value<String?> email,
});

final class $$ClientesTableReferences
    extends BaseReferences<_$AppDatabase, $ClientesTable, Cliente> {
  $$ClientesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$OrcamentosTable, List<Orcamento>>
  _orcamentosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.orcamentos,
    aliasName: 'clientes__id__orcamentos__cliente_id',
  );

  $$OrcamentosTableProcessedTableManager get orcamentosRefs {
    final manager = $$OrcamentosTableTableManager(
      $_db,
      $_db.orcamentos,
    ).filter((f) => f.clienteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_orcamentosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ClientesTableFilterComposer
    extends Composer<_$AppDatabase, $ClientesTable> {
  $$ClientesTableFilterComposer({
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

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get telefone => $composableBuilder(
    column: $table.telefone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> orcamentosRefs(
    Expression<bool> Function($$OrcamentosTableFilterComposer f) f,
  ) {
    final $$OrcamentosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orcamentos,
      getReferencedColumn: (t) => t.clienteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrcamentosTableFilterComposer(
            $db: $db,
            $table: $db.orcamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClientesTableOrderingComposer
    extends Composer<_$AppDatabase, $ClientesTable> {
  $$ClientesTableOrderingComposer({
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

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get telefone => $composableBuilder(
    column: $table.telefone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClientesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClientesTable> {
  $$ClientesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<String> get telefone =>
      $composableBuilder(column: $table.telefone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  Expression<T> orcamentosRefs<T extends Object>(
    Expression<T> Function($$OrcamentosTableAnnotationComposer a) f,
  ) {
    final $$OrcamentosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orcamentos,
      getReferencedColumn: (t) => t.clienteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrcamentosTableAnnotationComposer(
            $db: $db,
            $table: $db.orcamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClientesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClientesTable,
          Cliente,
          $$ClientesTableFilterComposer,
          $$ClientesTableOrderingComposer,
          $$ClientesTableAnnotationComposer,
          $$ClientesTableCreateCompanionBuilder,
          $$ClientesTableUpdateCompanionBuilder,
          (Cliente, $$ClientesTableReferences),
          Cliente,
          PrefetchHooks Function({bool orcamentosRefs})
        > {
  $$ClientesTableTableManager(_$AppDatabase db, $ClientesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClientesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClientesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClientesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<String?> telefone = const Value.absent(),
                Value<String?> email = const Value.absent(),
              }) => ClientesCompanion(
                id: id,
                nome: nome,
                telefone: telefone,
                email: email,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nome,
                Value<String?> telefone = const Value.absent(),
                Value<String?> email = const Value.absent(),
              }) => ClientesCompanion.insert(
                id: id,
                nome: nome,
                telefone: telefone,
                email: email,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ClientesTable, Cliente>(table),
                  $$ClientesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({orcamentosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (orcamentosRefs) db.orcamentos],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (orcamentosRefs)
                    await $_getPrefetchedDataByColumns<
                      Cliente,
                      $ClientesTable,
                      Orcamento,
                      $OrcamentosTable
                    >(
                      currentTable: table,
                      referencedTable: $$ClientesTableReferences
                          ._orcamentosRefsTable(db),
                      managerFromTypedResult: (p0) => $$ClientesTableReferences(
                        db,
                        table,
                        p0,
                      ).orcamentosRefs,
                      currentColumn: 'id',
                      referencedColumn: 'cliente_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ClientesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClientesTable,
      Cliente,
      $$ClientesTableFilterComposer,
      $$ClientesTableOrderingComposer,
      $$ClientesTableAnnotationComposer,
      $$ClientesTableCreateCompanionBuilder,
      $$ClientesTableUpdateCompanionBuilder,
      (Cliente, $$ClientesTableReferences),
      Cliente,
      PrefetchHooks Function({bool orcamentosRefs})
    >;
typedef $$OrcamentosTableCreateCompanionBuilder = OrcamentosCompanion Function({
  Value<int> id,
  required int clienteId,
  required String titulo,
  required DateTime dataEvento,
  Value<String?> local,
  Value<int> convidados,
  Value<int> descontoCentavos,
  Value<bool> ingredientesCompradosPeloBufe,
  Value<String> status,
  Value<String?> observacoes,
});
typedef $$OrcamentosTableUpdateCompanionBuilder = OrcamentosCompanion Function({
  Value<int> id,
  Value<int> clienteId,
  Value<String> titulo,
  Value<DateTime> dataEvento,
  Value<String?> local,
  Value<int> convidados,
  Value<int> descontoCentavos,
  Value<bool> ingredientesCompradosPeloBufe,
  Value<String> status,
  Value<String?> observacoes,
});

final class $$OrcamentosTableReferences
    extends BaseReferences<_$AppDatabase, $OrcamentosTable, Orcamento> {
  $$OrcamentosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClientesTable _clienteIdTable(_$AppDatabase db) =>
      db.clientes.createAlias('orcamentos__cliente_id__clientes__id');

  $$ClientesTableProcessedTableManager get clienteId {
    final $_column = $_itemColumn<int>('cliente_id')!;

    final manager = $$ClientesTableTableManager(
      $_db,
      $_db.clientes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clienteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$OrcamentoItensTable, List<OrcamentoIten>>
  _orcamentoItensRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.orcamentoItens,
    aliasName: 'orcamentos__id__orcamento_itens__orcamento_id',
  );

  $$OrcamentoItensTableProcessedTableManager get orcamentoItensRefs {
    final manager = $$OrcamentoItensTableTableManager(
      $_db,
      $_db.orcamentoItens,
    ).filter((f) => f.orcamentoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_orcamentoItensRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EventosTable, List<Evento>> _eventosRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.eventos,
    aliasName: 'orcamentos__id__eventos__orcamento_id',
  );

  $$EventosTableProcessedTableManager get eventosRefs {
    final manager = $$EventosTableTableManager(
      $_db,
      $_db.eventos,
    ).filter((f) => f.orcamentoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_eventosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OrcamentoReceitasTable, List<OrcamentoReceita>>
  _orcamentoReceitasRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.orcamentoReceitas,
        aliasName: 'orcamentos__id__orcamento_receitas__orcamento_id',
      );

  $$OrcamentoReceitasTableProcessedTableManager get orcamentoReceitasRefs {
    final manager = $$OrcamentoReceitasTableTableManager(
      $_db,
      $_db.orcamentoReceitas,
    ).filter((f) => f.orcamentoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _orcamentoReceitasRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$OrcamentosTableFilterComposer
    extends Composer<_$AppDatabase, $OrcamentosTable> {
  $$OrcamentosTableFilterComposer({
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

  ColumnFilters<String> get titulo => $composableBuilder(
    column: $table.titulo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataEvento => $composableBuilder(
    column: $table.dataEvento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get local => $composableBuilder(
    column: $table.local,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get convidados => $composableBuilder(
    column: $table.convidados,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get descontoCentavos => $composableBuilder(
    column: $table.descontoCentavos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get ingredientesCompradosPeloBufe => $composableBuilder(
    column: $table.ingredientesCompradosPeloBufe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observacoes => $composableBuilder(
    column: $table.observacoes,
    builder: (column) => ColumnFilters(column),
  );

  $$ClientesTableFilterComposer get clienteId {
    final $$ClientesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clienteId,
      referencedTable: $db.clientes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientesTableFilterComposer(
            $db: $db,
            $table: $db.clientes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> orcamentoItensRefs(
    Expression<bool> Function($$OrcamentoItensTableFilterComposer f) f,
  ) {
    final $$OrcamentoItensTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orcamentoItens,
      getReferencedColumn: (t) => t.orcamentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrcamentoItensTableFilterComposer(
            $db: $db,
            $table: $db.orcamentoItens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> eventosRefs(
    Expression<bool> Function($$EventosTableFilterComposer f) f,
  ) {
    final $$EventosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventos,
      getReferencedColumn: (t) => t.orcamentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventosTableFilterComposer(
            $db: $db,
            $table: $db.eventos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> orcamentoReceitasRefs(
    Expression<bool> Function($$OrcamentoReceitasTableFilterComposer f) f,
  ) {
    final $$OrcamentoReceitasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orcamentoReceitas,
      getReferencedColumn: (t) => t.orcamentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrcamentoReceitasTableFilterComposer(
            $db: $db,
            $table: $db.orcamentoReceitas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OrcamentosTableOrderingComposer
    extends Composer<_$AppDatabase, $OrcamentosTable> {
  $$OrcamentosTableOrderingComposer({
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

  ColumnOrderings<String> get titulo => $composableBuilder(
    column: $table.titulo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataEvento => $composableBuilder(
    column: $table.dataEvento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get local => $composableBuilder(
    column: $table.local,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get convidados => $composableBuilder(
    column: $table.convidados,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get descontoCentavos => $composableBuilder(
    column: $table.descontoCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get ingredientesCompradosPeloBufe => $composableBuilder(
    column: $table.ingredientesCompradosPeloBufe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observacoes => $composableBuilder(
    column: $table.observacoes,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClientesTableOrderingComposer get clienteId {
    final $$ClientesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clienteId,
      referencedTable: $db.clientes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientesTableOrderingComposer(
            $db: $db,
            $table: $db.clientes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OrcamentosTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrcamentosTable> {
  $$OrcamentosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get titulo =>
      $composableBuilder(column: $table.titulo, builder: (column) => column);

  GeneratedColumn<DateTime> get dataEvento => $composableBuilder(
    column: $table.dataEvento,
    builder: (column) => column,
  );

  GeneratedColumn<String> get local =>
      $composableBuilder(column: $table.local, builder: (column) => column);

  GeneratedColumn<int> get convidados => $composableBuilder(
    column: $table.convidados,
    builder: (column) => column,
  );

  GeneratedColumn<int> get descontoCentavos => $composableBuilder(
    column: $table.descontoCentavos,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get ingredientesCompradosPeloBufe => $composableBuilder(
    column: $table.ingredientesCompradosPeloBufe,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get observacoes => $composableBuilder(
    column: $table.observacoes,
    builder: (column) => column,
  );

  $$ClientesTableAnnotationComposer get clienteId {
    final $$ClientesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clienteId,
      referencedTable: $db.clientes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientesTableAnnotationComposer(
            $db: $db,
            $table: $db.clientes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> orcamentoItensRefs<T extends Object>(
    Expression<T> Function($$OrcamentoItensTableAnnotationComposer a) f,
  ) {
    final $$OrcamentoItensTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orcamentoItens,
      getReferencedColumn: (t) => t.orcamentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrcamentoItensTableAnnotationComposer(
            $db: $db,
            $table: $db.orcamentoItens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> eventosRefs<T extends Object>(
    Expression<T> Function($$EventosTableAnnotationComposer a) f,
  ) {
    final $$EventosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.eventos,
      getReferencedColumn: (t) => t.orcamentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EventosTableAnnotationComposer(
            $db: $db,
            $table: $db.eventos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> orcamentoReceitasRefs<T extends Object>(
    Expression<T> Function($$OrcamentoReceitasTableAnnotationComposer a) f,
  ) {
    final $$OrcamentoReceitasTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.orcamentoReceitas,
          getReferencedColumn: (t) => t.orcamentoId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$OrcamentoReceitasTableAnnotationComposer(
                $db: $db,
                $table: $db.orcamentoReceitas,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$OrcamentosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OrcamentosTable,
          Orcamento,
          $$OrcamentosTableFilterComposer,
          $$OrcamentosTableOrderingComposer,
          $$OrcamentosTableAnnotationComposer,
          $$OrcamentosTableCreateCompanionBuilder,
          $$OrcamentosTableUpdateCompanionBuilder,
          (Orcamento, $$OrcamentosTableReferences),
          Orcamento,
          PrefetchHooks Function({
            bool clienteId,
            bool orcamentoItensRefs,
            bool eventosRefs,
            bool orcamentoReceitasRefs,
          })
        > {
  $$OrcamentosTableTableManager(_$AppDatabase db, $OrcamentosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrcamentosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrcamentosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrcamentosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> clienteId = const Value.absent(),
                Value<String> titulo = const Value.absent(),
                Value<DateTime> dataEvento = const Value.absent(),
                Value<String?> local = const Value.absent(),
                Value<int> convidados = const Value.absent(),
                Value<int> descontoCentavos = const Value.absent(),
                Value<bool> ingredientesCompradosPeloBufe =
                    const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> observacoes = const Value.absent(),
              }) => OrcamentosCompanion(
                id: id,
                clienteId: clienteId,
                titulo: titulo,
                dataEvento: dataEvento,
                local: local,
                convidados: convidados,
                descontoCentavos: descontoCentavos,
                ingredientesCompradosPeloBufe: ingredientesCompradosPeloBufe,
                status: status,
                observacoes: observacoes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int clienteId,
                required String titulo,
                required DateTime dataEvento,
                Value<String?> local = const Value.absent(),
                Value<int> convidados = const Value.absent(),
                Value<int> descontoCentavos = const Value.absent(),
                Value<bool> ingredientesCompradosPeloBufe =
                    const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> observacoes = const Value.absent(),
              }) => OrcamentosCompanion.insert(
                id: id,
                clienteId: clienteId,
                titulo: titulo,
                dataEvento: dataEvento,
                local: local,
                convidados: convidados,
                descontoCentavos: descontoCentavos,
                ingredientesCompradosPeloBufe: ingredientesCompradosPeloBufe,
                status: status,
                observacoes: observacoes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OrcamentosTable, Orcamento>(table),
                  $$OrcamentosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                clienteId = false,
                orcamentoItensRefs = false,
                eventosRefs = false,
                orcamentoReceitasRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (orcamentoItensRefs) db.orcamentoItens,
                    if (eventosRefs) db.eventos,
                    if (orcamentoReceitasRefs) db.orcamentoReceitas,
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
                        if (clienteId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.clienteId,
                            referencedTable: $$OrcamentosTableReferences
                                ._clienteIdTable(db),
                            referencedColumn: $$OrcamentosTableReferences
                                ._clienteIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (orcamentoItensRefs)
                        await $_getPrefetchedDataByColumns<
                          Orcamento,
                          $OrcamentosTable,
                          OrcamentoIten,
                          $OrcamentoItensTable
                        >(
                          currentTable: table,
                          referencedTable: $$OrcamentosTableReferences
                              ._orcamentoItensRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OrcamentosTableReferences(
                                db,
                                table,
                                p0,
                              ).orcamentoItensRefs,
                          currentColumn: 'id',
                          referencedColumn: 'orcamento_id',
                          typedResults: items,
                        ),
                      if (eventosRefs)
                        await $_getPrefetchedDataByColumns<
                          Orcamento,
                          $OrcamentosTable,
                          Evento,
                          $EventosTable
                        >(
                          currentTable: table,
                          referencedTable: $$OrcamentosTableReferences
                              ._eventosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OrcamentosTableReferences(
                                db,
                                table,
                                p0,
                              ).eventosRefs,
                          currentColumn: 'id',
                          referencedColumn: 'orcamento_id',
                          typedResults: items,
                        ),
                      if (orcamentoReceitasRefs)
                        await $_getPrefetchedDataByColumns<
                          Orcamento,
                          $OrcamentosTable,
                          OrcamentoReceita,
                          $OrcamentoReceitasTable
                        >(
                          currentTable: table,
                          referencedTable: $$OrcamentosTableReferences
                              ._orcamentoReceitasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OrcamentosTableReferences(
                                db,
                                table,
                                p0,
                              ).orcamentoReceitasRefs,
                          currentColumn: 'id',
                          referencedColumn: 'orcamento_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$OrcamentosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OrcamentosTable,
      Orcamento,
      $$OrcamentosTableFilterComposer,
      $$OrcamentosTableOrderingComposer,
      $$OrcamentosTableAnnotationComposer,
      $$OrcamentosTableCreateCompanionBuilder,
      $$OrcamentosTableUpdateCompanionBuilder,
      (Orcamento, $$OrcamentosTableReferences),
      Orcamento,
      PrefetchHooks Function({
        bool clienteId,
        bool orcamentoItensRefs,
        bool eventosRefs,
        bool orcamentoReceitasRefs,
      })
    >;
typedef $$ServicosTableCreateCompanionBuilder = ServicosCompanion Function({
  Value<int> id,
  required String nome,
  Value<int?> precoCentavos,
  Value<String> tipoCobranca,
  Value<bool> ativo,
  Value<DateTime> criadoEm,
});
typedef $$ServicosTableUpdateCompanionBuilder = ServicosCompanion Function({
  Value<int> id,
  Value<String> nome,
  Value<int?> precoCentavos,
  Value<String> tipoCobranca,
  Value<bool> ativo,
  Value<DateTime> criadoEm,
});

final class $$ServicosTableReferences
    extends BaseReferences<_$AppDatabase, $ServicosTable, Servico> {
  $$ServicosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$OrcamentoItensTable, List<OrcamentoIten>>
  _orcamentoItensRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.orcamentoItens,
    aliasName: 'servicos__id__orcamento_itens__servico_id',
  );

  $$OrcamentoItensTableProcessedTableManager get orcamentoItensRefs {
    final manager = $$OrcamentoItensTableTableManager(
      $_db,
      $_db.orcamentoItens,
    ).filter((f) => f.servicoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_orcamentoItensRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ServicosTableFilterComposer
    extends Composer<_$AppDatabase, $ServicosTable> {
  $$ServicosTableFilterComposer({
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

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get precoCentavos => $composableBuilder(
    column: $table.precoCentavos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipoCobranca => $composableBuilder(
    column: $table.tipoCobranca,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get ativo => $composableBuilder(
    column: $table.ativo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> orcamentoItensRefs(
    Expression<bool> Function($$OrcamentoItensTableFilterComposer f) f,
  ) {
    final $$OrcamentoItensTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orcamentoItens,
      getReferencedColumn: (t) => t.servicoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrcamentoItensTableFilterComposer(
            $db: $db,
            $table: $db.orcamentoItens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ServicosTableOrderingComposer
    extends Composer<_$AppDatabase, $ServicosTable> {
  $$ServicosTableOrderingComposer({
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

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get precoCentavos => $composableBuilder(
    column: $table.precoCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipoCobranca => $composableBuilder(
    column: $table.tipoCobranca,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get ativo => $composableBuilder(
    column: $table.ativo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ServicosTableAnnotationComposer
    extends Composer<_$AppDatabase, $ServicosTable> {
  $$ServicosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<int> get precoCentavos => $composableBuilder(
    column: $table.precoCentavos,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tipoCobranca => $composableBuilder(
    column: $table.tipoCobranca,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get ativo =>
      $composableBuilder(column: $table.ativo, builder: (column) => column);

  GeneratedColumn<DateTime> get criadoEm =>
      $composableBuilder(column: $table.criadoEm, builder: (column) => column);

  Expression<T> orcamentoItensRefs<T extends Object>(
    Expression<T> Function($$OrcamentoItensTableAnnotationComposer a) f,
  ) {
    final $$OrcamentoItensTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orcamentoItens,
      getReferencedColumn: (t) => t.servicoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrcamentoItensTableAnnotationComposer(
            $db: $db,
            $table: $db.orcamentoItens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ServicosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ServicosTable,
          Servico,
          $$ServicosTableFilterComposer,
          $$ServicosTableOrderingComposer,
          $$ServicosTableAnnotationComposer,
          $$ServicosTableCreateCompanionBuilder,
          $$ServicosTableUpdateCompanionBuilder,
          (Servico, $$ServicosTableReferences),
          Servico,
          PrefetchHooks Function({bool orcamentoItensRefs})
        > {
  $$ServicosTableTableManager(_$AppDatabase db, $ServicosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServicosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServicosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServicosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<int?> precoCentavos = const Value.absent(),
                Value<String> tipoCobranca = const Value.absent(),
                Value<bool> ativo = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
              }) => ServicosCompanion(
                id: id,
                nome: nome,
                precoCentavos: precoCentavos,
                tipoCobranca: tipoCobranca,
                ativo: ativo,
                criadoEm: criadoEm,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nome,
                Value<int?> precoCentavos = const Value.absent(),
                Value<String> tipoCobranca = const Value.absent(),
                Value<bool> ativo = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
              }) => ServicosCompanion.insert(
                id: id,
                nome: nome,
                precoCentavos: precoCentavos,
                tipoCobranca: tipoCobranca,
                ativo: ativo,
                criadoEm: criadoEm,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ServicosTable, Servico>(table),
                  $$ServicosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({orcamentoItensRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (orcamentoItensRefs) db.orcamentoItens,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (orcamentoItensRefs)
                    await $_getPrefetchedDataByColumns<
                      Servico,
                      $ServicosTable,
                      OrcamentoIten,
                      $OrcamentoItensTable
                    >(
                      currentTable: table,
                      referencedTable: $$ServicosTableReferences
                          ._orcamentoItensRefsTable(db),
                      managerFromTypedResult: (p0) => $$ServicosTableReferences(
                        db,
                        table,
                        p0,
                      ).orcamentoItensRefs,
                      currentColumn: 'id',
                      referencedColumn: 'servico_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ServicosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ServicosTable,
      Servico,
      $$ServicosTableFilterComposer,
      $$ServicosTableOrderingComposer,
      $$ServicosTableAnnotationComposer,
      $$ServicosTableCreateCompanionBuilder,
      $$ServicosTableUpdateCompanionBuilder,
      (Servico, $$ServicosTableReferences),
      Servico,
      PrefetchHooks Function({bool orcamentoItensRefs})
    >;
typedef $$OrcamentoItensTableCreateCompanionBuilder =
    OrcamentoItensCompanion Function({
      Value<int> id,
      required int orcamentoId,
      required String nome,
      Value<int> quantidade,
      Value<int> precoCentavos,
      Value<String> tipoCobranca,
      Value<String> categoria,
      Value<int?> receitaId,
      Value<int?> receitaIngredienteId,
      Value<String?> receitaNome,
      Value<String?> unidade,
      Value<int> quantidadeMilesimos,
      Value<int?> servicoId,
    });
typedef $$OrcamentoItensTableUpdateCompanionBuilder =
    OrcamentoItensCompanion Function({
      Value<int> id,
      Value<int> orcamentoId,
      Value<String> nome,
      Value<int> quantidade,
      Value<int> precoCentavos,
      Value<String> tipoCobranca,
      Value<String> categoria,
      Value<int?> receitaId,
      Value<int?> receitaIngredienteId,
      Value<String?> receitaNome,
      Value<String?> unidade,
      Value<int> quantidadeMilesimos,
      Value<int?> servicoId,
    });

final class $$OrcamentoItensTableReferences
    extends BaseReferences<_$AppDatabase, $OrcamentoItensTable, OrcamentoIten> {
  $$OrcamentoItensTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $OrcamentosTable _orcamentoIdTable(_$AppDatabase db) => db.orcamentos
      .createAlias('orcamento_itens__orcamento_id__orcamentos__id');

  $$OrcamentosTableProcessedTableManager get orcamentoId {
    final $_column = $_itemColumn<int>('orcamento_id')!;

    final manager = $$OrcamentosTableTableManager(
      $_db,
      $_db.orcamentos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_orcamentoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ServicosTable _servicoIdTable(_$AppDatabase db) =>
      db.servicos.createAlias('orcamento_itens__servico_id__servicos__id');

  $$ServicosTableProcessedTableManager? get servicoId {
    final $_column = $_itemColumn<int>('servico_id');
    if ($_column == null) return null;
    final manager = $$ServicosTableTableManager(
      $_db,
      $_db.servicos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_servicoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$OrcamentoItensTableFilterComposer
    extends Composer<_$AppDatabase, $OrcamentoItensTable> {
  $$OrcamentoItensTableFilterComposer({
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

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantidade => $composableBuilder(
    column: $table.quantidade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get precoCentavos => $composableBuilder(
    column: $table.precoCentavos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipoCobranca => $composableBuilder(
    column: $table.tipoCobranca,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get receitaId => $composableBuilder(
    column: $table.receitaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get receitaIngredienteId => $composableBuilder(
    column: $table.receitaIngredienteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receitaNome => $composableBuilder(
    column: $table.receitaNome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unidade => $composableBuilder(
    column: $table.unidade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantidadeMilesimos => $composableBuilder(
    column: $table.quantidadeMilesimos,
    builder: (column) => ColumnFilters(column),
  );

  $$OrcamentosTableFilterComposer get orcamentoId {
    final $$OrcamentosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orcamentoId,
      referencedTable: $db.orcamentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrcamentosTableFilterComposer(
            $db: $db,
            $table: $db.orcamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ServicosTableFilterComposer get servicoId {
    final $$ServicosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.servicoId,
      referencedTable: $db.servicos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServicosTableFilterComposer(
            $db: $db,
            $table: $db.servicos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OrcamentoItensTableOrderingComposer
    extends Composer<_$AppDatabase, $OrcamentoItensTable> {
  $$OrcamentoItensTableOrderingComposer({
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

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantidade => $composableBuilder(
    column: $table.quantidade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get precoCentavos => $composableBuilder(
    column: $table.precoCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipoCobranca => $composableBuilder(
    column: $table.tipoCobranca,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoria => $composableBuilder(
    column: $table.categoria,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get receitaId => $composableBuilder(
    column: $table.receitaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get receitaIngredienteId => $composableBuilder(
    column: $table.receitaIngredienteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receitaNome => $composableBuilder(
    column: $table.receitaNome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unidade => $composableBuilder(
    column: $table.unidade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantidadeMilesimos => $composableBuilder(
    column: $table.quantidadeMilesimos,
    builder: (column) => ColumnOrderings(column),
  );

  $$OrcamentosTableOrderingComposer get orcamentoId {
    final $$OrcamentosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orcamentoId,
      referencedTable: $db.orcamentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrcamentosTableOrderingComposer(
            $db: $db,
            $table: $db.orcamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ServicosTableOrderingComposer get servicoId {
    final $$ServicosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.servicoId,
      referencedTable: $db.servicos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServicosTableOrderingComposer(
            $db: $db,
            $table: $db.servicos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OrcamentoItensTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrcamentoItensTable> {
  $$OrcamentoItensTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<int> get quantidade => $composableBuilder(
    column: $table.quantidade,
    builder: (column) => column,
  );

  GeneratedColumn<int> get precoCentavos => $composableBuilder(
    column: $table.precoCentavos,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tipoCobranca => $composableBuilder(
    column: $table.tipoCobranca,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoria =>
      $composableBuilder(column: $table.categoria, builder: (column) => column);

  GeneratedColumn<int> get receitaId =>
      $composableBuilder(column: $table.receitaId, builder: (column) => column);

  GeneratedColumn<int> get receitaIngredienteId => $composableBuilder(
    column: $table.receitaIngredienteId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get receitaNome => $composableBuilder(
    column: $table.receitaNome,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unidade =>
      $composableBuilder(column: $table.unidade, builder: (column) => column);

  GeneratedColumn<int> get quantidadeMilesimos => $composableBuilder(
    column: $table.quantidadeMilesimos,
    builder: (column) => column,
  );

  $$OrcamentosTableAnnotationComposer get orcamentoId {
    final $$OrcamentosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orcamentoId,
      referencedTable: $db.orcamentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrcamentosTableAnnotationComposer(
            $db: $db,
            $table: $db.orcamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ServicosTableAnnotationComposer get servicoId {
    final $$ServicosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.servicoId,
      referencedTable: $db.servicos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServicosTableAnnotationComposer(
            $db: $db,
            $table: $db.servicos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OrcamentoItensTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OrcamentoItensTable,
          OrcamentoIten,
          $$OrcamentoItensTableFilterComposer,
          $$OrcamentoItensTableOrderingComposer,
          $$OrcamentoItensTableAnnotationComposer,
          $$OrcamentoItensTableCreateCompanionBuilder,
          $$OrcamentoItensTableUpdateCompanionBuilder,
          (OrcamentoIten, $$OrcamentoItensTableReferences),
          OrcamentoIten,
          PrefetchHooks Function({bool orcamentoId, bool servicoId})
        > {
  $$OrcamentoItensTableTableManager(
    _$AppDatabase db,
    $OrcamentoItensTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrcamentoItensTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrcamentoItensTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrcamentoItensTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> orcamentoId = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<int> quantidade = const Value.absent(),
                Value<int> precoCentavos = const Value.absent(),
                Value<String> tipoCobranca = const Value.absent(),
                Value<String> categoria = const Value.absent(),
                Value<int?> receitaId = const Value.absent(),
                Value<int?> receitaIngredienteId = const Value.absent(),
                Value<String?> receitaNome = const Value.absent(),
                Value<String?> unidade = const Value.absent(),
                Value<int> quantidadeMilesimos = const Value.absent(),
                Value<int?> servicoId = const Value.absent(),
              }) => OrcamentoItensCompanion(
                id: id,
                orcamentoId: orcamentoId,
                nome: nome,
                quantidade: quantidade,
                precoCentavos: precoCentavos,
                tipoCobranca: tipoCobranca,
                categoria: categoria,
                receitaId: receitaId,
                receitaIngredienteId: receitaIngredienteId,
                receitaNome: receitaNome,
                unidade: unidade,
                quantidadeMilesimos: quantidadeMilesimos,
                servicoId: servicoId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int orcamentoId,
                required String nome,
                Value<int> quantidade = const Value.absent(),
                Value<int> precoCentavos = const Value.absent(),
                Value<String> tipoCobranca = const Value.absent(),
                Value<String> categoria = const Value.absent(),
                Value<int?> receitaId = const Value.absent(),
                Value<int?> receitaIngredienteId = const Value.absent(),
                Value<String?> receitaNome = const Value.absent(),
                Value<String?> unidade = const Value.absent(),
                Value<int> quantidadeMilesimos = const Value.absent(),
                Value<int?> servicoId = const Value.absent(),
              }) => OrcamentoItensCompanion.insert(
                id: id,
                orcamentoId: orcamentoId,
                nome: nome,
                quantidade: quantidade,
                precoCentavos: precoCentavos,
                tipoCobranca: tipoCobranca,
                categoria: categoria,
                receitaId: receitaId,
                receitaIngredienteId: receitaIngredienteId,
                receitaNome: receitaNome,
                unidade: unidade,
                quantidadeMilesimos: quantidadeMilesimos,
                servicoId: servicoId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OrcamentoItensTable, OrcamentoIten>(table),
                  $$OrcamentoItensTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({orcamentoId = false, servicoId = false}) {
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
                    if (orcamentoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.orcamentoId,
                        referencedTable: $$OrcamentoItensTableReferences
                            ._orcamentoIdTable(db),
                        referencedColumn: $$OrcamentoItensTableReferences
                            ._orcamentoIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (servicoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.servicoId,
                        referencedTable: $$OrcamentoItensTableReferences
                            ._servicoIdTable(db),
                        referencedColumn: $$OrcamentoItensTableReferences
                            ._servicoIdTable(db)
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

typedef $$OrcamentoItensTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OrcamentoItensTable,
      OrcamentoIten,
      $$OrcamentoItensTableFilterComposer,
      $$OrcamentoItensTableOrderingComposer,
      $$OrcamentoItensTableAnnotationComposer,
      $$OrcamentoItensTableCreateCompanionBuilder,
      $$OrcamentoItensTableUpdateCompanionBuilder,
      (OrcamentoIten, $$OrcamentoItensTableReferences),
      OrcamentoIten,
      PrefetchHooks Function({bool orcamentoId, bool servicoId})
    >;
typedef $$EventosTableCreateCompanionBuilder = EventosCompanion Function({
  Value<int> id,
  Value<int?> orcamentoId,
  required String titulo,
  Value<String?> local,
  required DateTime inicio,
  required DateTime fim,
});
typedef $$EventosTableUpdateCompanionBuilder = EventosCompanion Function({
  Value<int> id,
  Value<int?> orcamentoId,
  Value<String> titulo,
  Value<String?> local,
  Value<DateTime> inicio,
  Value<DateTime> fim,
});

final class $$EventosTableReferences
    extends BaseReferences<_$AppDatabase, $EventosTable, Evento> {
  $$EventosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $OrcamentosTable _orcamentoIdTable(_$AppDatabase db) =>
      db.orcamentos.createAlias('eventos__orcamento_id__orcamentos__id');

  $$OrcamentosTableProcessedTableManager? get orcamentoId {
    final $_column = $_itemColumn<int>('orcamento_id');
    if ($_column == null) return null;
    final manager = $$OrcamentosTableTableManager(
      $_db,
      $_db.orcamentos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_orcamentoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EventosTableFilterComposer
    extends Composer<_$AppDatabase, $EventosTable> {
  $$EventosTableFilterComposer({
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

  ColumnFilters<String> get titulo => $composableBuilder(
    column: $table.titulo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get local => $composableBuilder(
    column: $table.local,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get inicio => $composableBuilder(
    column: $table.inicio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fim => $composableBuilder(
    column: $table.fim,
    builder: (column) => ColumnFilters(column),
  );

  $$OrcamentosTableFilterComposer get orcamentoId {
    final $$OrcamentosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orcamentoId,
      referencedTable: $db.orcamentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrcamentosTableFilterComposer(
            $db: $db,
            $table: $db.orcamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventosTableOrderingComposer
    extends Composer<_$AppDatabase, $EventosTable> {
  $$EventosTableOrderingComposer({
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

  ColumnOrderings<String> get titulo => $composableBuilder(
    column: $table.titulo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get local => $composableBuilder(
    column: $table.local,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get inicio => $composableBuilder(
    column: $table.inicio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fim => $composableBuilder(
    column: $table.fim,
    builder: (column) => ColumnOrderings(column),
  );

  $$OrcamentosTableOrderingComposer get orcamentoId {
    final $$OrcamentosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orcamentoId,
      referencedTable: $db.orcamentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrcamentosTableOrderingComposer(
            $db: $db,
            $table: $db.orcamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventosTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventosTable> {
  $$EventosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get titulo =>
      $composableBuilder(column: $table.titulo, builder: (column) => column);

  GeneratedColumn<String> get local =>
      $composableBuilder(column: $table.local, builder: (column) => column);

  GeneratedColumn<DateTime> get inicio =>
      $composableBuilder(column: $table.inicio, builder: (column) => column);

  GeneratedColumn<DateTime> get fim =>
      $composableBuilder(column: $table.fim, builder: (column) => column);

  $$OrcamentosTableAnnotationComposer get orcamentoId {
    final $$OrcamentosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orcamentoId,
      referencedTable: $db.orcamentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrcamentosTableAnnotationComposer(
            $db: $db,
            $table: $db.orcamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EventosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EventosTable,
          Evento,
          $$EventosTableFilterComposer,
          $$EventosTableOrderingComposer,
          $$EventosTableAnnotationComposer,
          $$EventosTableCreateCompanionBuilder,
          $$EventosTableUpdateCompanionBuilder,
          (Evento, $$EventosTableReferences),
          Evento,
          PrefetchHooks Function({bool orcamentoId})
        > {
  $$EventosTableTableManager(_$AppDatabase db, $EventosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> orcamentoId = const Value.absent(),
                Value<String> titulo = const Value.absent(),
                Value<String?> local = const Value.absent(),
                Value<DateTime> inicio = const Value.absent(),
                Value<DateTime> fim = const Value.absent(),
              }) => EventosCompanion(
                id: id,
                orcamentoId: orcamentoId,
                titulo: titulo,
                local: local,
                inicio: inicio,
                fim: fim,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> orcamentoId = const Value.absent(),
                required String titulo,
                Value<String?> local = const Value.absent(),
                required DateTime inicio,
                required DateTime fim,
              }) => EventosCompanion.insert(
                id: id,
                orcamentoId: orcamentoId,
                titulo: titulo,
                local: local,
                inicio: inicio,
                fim: fim,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EventosTable, Evento>(table),
                  $$EventosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({orcamentoId = false}) {
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
                    if (orcamentoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.orcamentoId,
                        referencedTable: $$EventosTableReferences
                            ._orcamentoIdTable(db),
                        referencedColumn: $$EventosTableReferences
                            ._orcamentoIdTable(db)
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

typedef $$EventosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EventosTable,
      Evento,
      $$EventosTableFilterComposer,
      $$EventosTableOrderingComposer,
      $$EventosTableAnnotationComposer,
      $$EventosTableCreateCompanionBuilder,
      $$EventosTableUpdateCompanionBuilder,
      (Evento, $$EventosTableReferences),
      Evento,
      PrefetchHooks Function({bool orcamentoId})
    >;
typedef $$EmpresasTableCreateCompanionBuilder = EmpresasCompanion Function({
  Value<int> id,
  Value<String> nome,
  Value<String> telefone,
  Value<String> email,
  Value<int> validadeDias,
  Value<Uint8List?> logo,
});
typedef $$EmpresasTableUpdateCompanionBuilder = EmpresasCompanion Function({
  Value<int> id,
  Value<String> nome,
  Value<String> telefone,
  Value<String> email,
  Value<int> validadeDias,
  Value<Uint8List?> logo,
});

class $$EmpresasTableFilterComposer
    extends Composer<_$AppDatabase, $EmpresasTable> {
  $$EmpresasTableFilterComposer({
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

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get telefone => $composableBuilder(
    column: $table.telefone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get validadeDias => $composableBuilder(
    column: $table.validadeDias,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get logo => $composableBuilder(
    column: $table.logo,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EmpresasTableOrderingComposer
    extends Composer<_$AppDatabase, $EmpresasTable> {
  $$EmpresasTableOrderingComposer({
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

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get telefone => $composableBuilder(
    column: $table.telefone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get validadeDias => $composableBuilder(
    column: $table.validadeDias,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get logo => $composableBuilder(
    column: $table.logo,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EmpresasTableAnnotationComposer
    extends Composer<_$AppDatabase, $EmpresasTable> {
  $$EmpresasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<String> get telefone =>
      $composableBuilder(column: $table.telefone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<int> get validadeDias => $composableBuilder(
    column: $table.validadeDias,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get logo =>
      $composableBuilder(column: $table.logo, builder: (column) => column);
}

class $$EmpresasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EmpresasTable,
          Empresa,
          $$EmpresasTableFilterComposer,
          $$EmpresasTableOrderingComposer,
          $$EmpresasTableAnnotationComposer,
          $$EmpresasTableCreateCompanionBuilder,
          $$EmpresasTableUpdateCompanionBuilder,
          (Empresa, BaseReferences<_$AppDatabase, $EmpresasTable, Empresa>),
          Empresa,
          PrefetchHooks Function()
        > {
  $$EmpresasTableTableManager(_$AppDatabase db, $EmpresasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmpresasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EmpresasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmpresasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<String> telefone = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<int> validadeDias = const Value.absent(),
                Value<Uint8List?> logo = const Value.absent(),
              }) => EmpresasCompanion(
                id: id,
                nome: nome,
                telefone: telefone,
                email: email,
                validadeDias: validadeDias,
                logo: logo,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<String> telefone = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<int> validadeDias = const Value.absent(),
                Value<Uint8List?> logo = const Value.absent(),
              }) => EmpresasCompanion.insert(
                id: id,
                nome: nome,
                telefone: telefone,
                email: email,
                validadeDias: validadeDias,
                logo: logo,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EmpresasTable, Empresa>(table),
                  BaseReferences<_$AppDatabase, $EmpresasTable, Empresa>(
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

typedef $$EmpresasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EmpresasTable,
      Empresa,
      $$EmpresasTableFilterComposer,
      $$EmpresasTableOrderingComposer,
      $$EmpresasTableAnnotationComposer,
      $$EmpresasTableCreateCompanionBuilder,
      $$EmpresasTableUpdateCompanionBuilder,
      (Empresa, BaseReferences<_$AppDatabase, $EmpresasTable, Empresa>),
      Empresa,
      PrefetchHooks Function()
    >;
typedef $$ReceitasTableCreateCompanionBuilder = ReceitasCompanion Function({
  Value<int> id,
  required String nome,
  required int rendimentoPessoas,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
});
typedef $$ReceitasTableUpdateCompanionBuilder = ReceitasCompanion Function({
  Value<int> id,
  Value<String> nome,
  Value<int> rendimentoPessoas,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
});

final class $$ReceitasTableReferences
    extends BaseReferences<_$AppDatabase, $ReceitasTable, Receita> {
  $$ReceitasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $ReceitaIngredientesTable,
    List<ReceitaIngrediente>
  >
  _receitaIngredientesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.receitaIngredientes,
        aliasName: 'receitas__id__receita_ingredientes__receita_id',
      );

  $$ReceitaIngredientesTableProcessedTableManager get receitaIngredientesRefs {
    final manager = $$ReceitaIngredientesTableTableManager(
      $_db,
      $_db.receitaIngredientes,
    ).filter((f) => f.receitaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _receitaIngredientesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OrcamentoReceitasTable, List<OrcamentoReceita>>
  _orcamentoReceitasRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.orcamentoReceitas,
        aliasName: 'receitas__id__orcamento_receitas__receita_id',
      );

  $$OrcamentoReceitasTableProcessedTableManager get orcamentoReceitasRefs {
    final manager = $$OrcamentoReceitasTableTableManager(
      $_db,
      $_db.orcamentoReceitas,
    ).filter((f) => f.receitaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _orcamentoReceitasRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ReceitasTableFilterComposer
    extends Composer<_$AppDatabase, $ReceitasTable> {
  $$ReceitasTableFilterComposer({
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

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rendimentoPessoas => $composableBuilder(
    column: $table.rendimentoPessoas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> receitaIngredientesRefs(
    Expression<bool> Function($$ReceitaIngredientesTableFilterComposer f) f,
  ) {
    final $$ReceitaIngredientesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.receitaIngredientes,
      getReferencedColumn: (t) => t.receitaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReceitaIngredientesTableFilterComposer(
            $db: $db,
            $table: $db.receitaIngredientes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> orcamentoReceitasRefs(
    Expression<bool> Function($$OrcamentoReceitasTableFilterComposer f) f,
  ) {
    final $$OrcamentoReceitasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.orcamentoReceitas,
      getReferencedColumn: (t) => t.receitaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrcamentoReceitasTableFilterComposer(
            $db: $db,
            $table: $db.orcamentoReceitas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ReceitasTableOrderingComposer
    extends Composer<_$AppDatabase, $ReceitasTable> {
  $$ReceitasTableOrderingComposer({
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

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rendimentoPessoas => $composableBuilder(
    column: $table.rendimentoPessoas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReceitasTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReceitasTable> {
  $$ReceitasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<int> get rendimentoPessoas => $composableBuilder(
    column: $table.rendimentoPessoas,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get criadoEm =>
      $composableBuilder(column: $table.criadoEm, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  Expression<T> receitaIngredientesRefs<T extends Object>(
    Expression<T> Function($$ReceitaIngredientesTableAnnotationComposer a) f,
  ) {
    final $$ReceitaIngredientesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.receitaIngredientes,
          getReferencedColumn: (t) => t.receitaId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ReceitaIngredientesTableAnnotationComposer(
                $db: $db,
                $table: $db.receitaIngredientes,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> orcamentoReceitasRefs<T extends Object>(
    Expression<T> Function($$OrcamentoReceitasTableAnnotationComposer a) f,
  ) {
    final $$OrcamentoReceitasTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.orcamentoReceitas,
          getReferencedColumn: (t) => t.receitaId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$OrcamentoReceitasTableAnnotationComposer(
                $db: $db,
                $table: $db.orcamentoReceitas,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ReceitasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReceitasTable,
          Receita,
          $$ReceitasTableFilterComposer,
          $$ReceitasTableOrderingComposer,
          $$ReceitasTableAnnotationComposer,
          $$ReceitasTableCreateCompanionBuilder,
          $$ReceitasTableUpdateCompanionBuilder,
          (Receita, $$ReceitasTableReferences),
          Receita,
          PrefetchHooks Function({
            bool receitaIngredientesRefs,
            bool orcamentoReceitasRefs,
          })
        > {
  $$ReceitasTableTableManager(_$AppDatabase db, $ReceitasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReceitasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReceitasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReceitasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<int> rendimentoPessoas = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
              }) => ReceitasCompanion(
                id: id,
                nome: nome,
                rendimentoPessoas: rendimentoPessoas,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nome,
                required int rendimentoPessoas,
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
              }) => ReceitasCompanion.insert(
                id: id,
                nome: nome,
                rendimentoPessoas: rendimentoPessoas,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReceitasTable, Receita>(table),
                  $$ReceitasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                receitaIngredientesRefs = false,
                orcamentoReceitasRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (receitaIngredientesRefs) db.receitaIngredientes,
                    if (orcamentoReceitasRefs) db.orcamentoReceitas,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (receitaIngredientesRefs)
                        await $_getPrefetchedDataByColumns<
                          Receita,
                          $ReceitasTable,
                          ReceitaIngrediente,
                          $ReceitaIngredientesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ReceitasTableReferences
                              ._receitaIngredientesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ReceitasTableReferences(
                                db,
                                table,
                                p0,
                              ).receitaIngredientesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'receita_id',
                          typedResults: items,
                        ),
                      if (orcamentoReceitasRefs)
                        await $_getPrefetchedDataByColumns<
                          Receita,
                          $ReceitasTable,
                          OrcamentoReceita,
                          $OrcamentoReceitasTable
                        >(
                          currentTable: table,
                          referencedTable: $$ReceitasTableReferences
                              ._orcamentoReceitasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ReceitasTableReferences(
                                db,
                                table,
                                p0,
                              ).orcamentoReceitasRefs,
                          currentColumn: 'id',
                          referencedColumn: 'receita_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ReceitasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReceitasTable,
      Receita,
      $$ReceitasTableFilterComposer,
      $$ReceitasTableOrderingComposer,
      $$ReceitasTableAnnotationComposer,
      $$ReceitasTableCreateCompanionBuilder,
      $$ReceitasTableUpdateCompanionBuilder,
      (Receita, $$ReceitasTableReferences),
      Receita,
      PrefetchHooks Function({
        bool receitaIngredientesRefs,
        bool orcamentoReceitasRefs,
      })
    >;
typedef $$ReceitaIngredientesTableCreateCompanionBuilder =
    ReceitaIngredientesCompanion Function({
      Value<int> id,
      required int receitaId,
      required String produto,
      required int quantidadeMilesimos,
      required String unidade,
      Value<int?> precoCentavos,
      Value<DateTime> criadoEm,
    });
typedef $$ReceitaIngredientesTableUpdateCompanionBuilder =
    ReceitaIngredientesCompanion Function({
      Value<int> id,
      Value<int> receitaId,
      Value<String> produto,
      Value<int> quantidadeMilesimos,
      Value<String> unidade,
      Value<int?> precoCentavos,
      Value<DateTime> criadoEm,
    });

final class $$ReceitaIngredientesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ReceitaIngredientesTable,
          ReceitaIngrediente
        > {
  $$ReceitaIngredientesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ReceitasTable _receitaIdTable(_$AppDatabase db) =>
      db.receitas.createAlias('receita_ingredientes__receita_id__receitas__id');

  $$ReceitasTableProcessedTableManager get receitaId {
    final $_column = $_itemColumn<int>('receita_id')!;

    final manager = $$ReceitasTableTableManager(
      $_db,
      $_db.receitas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_receitaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReceitaIngredientesTableFilterComposer
    extends Composer<_$AppDatabase, $ReceitaIngredientesTable> {
  $$ReceitaIngredientesTableFilterComposer({
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

  ColumnFilters<String> get produto => $composableBuilder(
    column: $table.produto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantidadeMilesimos => $composableBuilder(
    column: $table.quantidadeMilesimos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unidade => $composableBuilder(
    column: $table.unidade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get precoCentavos => $composableBuilder(
    column: $table.precoCentavos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnFilters(column),
  );

  $$ReceitasTableFilterComposer get receitaId {
    final $$ReceitasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.receitaId,
      referencedTable: $db.receitas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReceitasTableFilterComposer(
            $db: $db,
            $table: $db.receitas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReceitaIngredientesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReceitaIngredientesTable> {
  $$ReceitaIngredientesTableOrderingComposer({
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

  ColumnOrderings<String> get produto => $composableBuilder(
    column: $table.produto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantidadeMilesimos => $composableBuilder(
    column: $table.quantidadeMilesimos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unidade => $composableBuilder(
    column: $table.unidade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get precoCentavos => $composableBuilder(
    column: $table.precoCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  $$ReceitasTableOrderingComposer get receitaId {
    final $$ReceitasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.receitaId,
      referencedTable: $db.receitas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReceitasTableOrderingComposer(
            $db: $db,
            $table: $db.receitas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReceitaIngredientesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReceitaIngredientesTable> {
  $$ReceitaIngredientesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get produto =>
      $composableBuilder(column: $table.produto, builder: (column) => column);

  GeneratedColumn<int> get quantidadeMilesimos => $composableBuilder(
    column: $table.quantidadeMilesimos,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unidade =>
      $composableBuilder(column: $table.unidade, builder: (column) => column);

  GeneratedColumn<int> get precoCentavos => $composableBuilder(
    column: $table.precoCentavos,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get criadoEm =>
      $composableBuilder(column: $table.criadoEm, builder: (column) => column);

  $$ReceitasTableAnnotationComposer get receitaId {
    final $$ReceitasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.receitaId,
      referencedTable: $db.receitas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReceitasTableAnnotationComposer(
            $db: $db,
            $table: $db.receitas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReceitaIngredientesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReceitaIngredientesTable,
          ReceitaIngrediente,
          $$ReceitaIngredientesTableFilterComposer,
          $$ReceitaIngredientesTableOrderingComposer,
          $$ReceitaIngredientesTableAnnotationComposer,
          $$ReceitaIngredientesTableCreateCompanionBuilder,
          $$ReceitaIngredientesTableUpdateCompanionBuilder,
          (ReceitaIngrediente, $$ReceitaIngredientesTableReferences),
          ReceitaIngrediente,
          PrefetchHooks Function({bool receitaId})
        > {
  $$ReceitaIngredientesTableTableManager(
    _$AppDatabase db,
    $ReceitaIngredientesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReceitaIngredientesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReceitaIngredientesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ReceitaIngredientesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> receitaId = const Value.absent(),
                Value<String> produto = const Value.absent(),
                Value<int> quantidadeMilesimos = const Value.absent(),
                Value<String> unidade = const Value.absent(),
                Value<int?> precoCentavos = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
              }) => ReceitaIngredientesCompanion(
                id: id,
                receitaId: receitaId,
                produto: produto,
                quantidadeMilesimos: quantidadeMilesimos,
                unidade: unidade,
                precoCentavos: precoCentavos,
                criadoEm: criadoEm,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int receitaId,
                required String produto,
                required int quantidadeMilesimos,
                required String unidade,
                Value<int?> precoCentavos = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
              }) => ReceitaIngredientesCompanion.insert(
                id: id,
                receitaId: receitaId,
                produto: produto,
                quantidadeMilesimos: quantidadeMilesimos,
                unidade: unidade,
                precoCentavos: precoCentavos,
                criadoEm: criadoEm,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReceitaIngredientesTable, ReceitaIngrediente>(
                    table,
                  ),
                  $$ReceitaIngredientesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({receitaId = false}) {
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
                    if (receitaId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.receitaId,
                        referencedTable: $$ReceitaIngredientesTableReferences
                            ._receitaIdTable(db),
                        referencedColumn: $$ReceitaIngredientesTableReferences
                            ._receitaIdTable(db)
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

typedef $$ReceitaIngredientesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReceitaIngredientesTable,
      ReceitaIngrediente,
      $$ReceitaIngredientesTableFilterComposer,
      $$ReceitaIngredientesTableOrderingComposer,
      $$ReceitaIngredientesTableAnnotationComposer,
      $$ReceitaIngredientesTableCreateCompanionBuilder,
      $$ReceitaIngredientesTableUpdateCompanionBuilder,
      (ReceitaIngrediente, $$ReceitaIngredientesTableReferences),
      ReceitaIngrediente,
      PrefetchHooks Function({bool receitaId})
    >;
typedef $$OrcamentoReceitasTableCreateCompanionBuilder =
    OrcamentoReceitasCompanion Function({
      Value<int> id,
      required int orcamentoId,
      required int receitaId,
      required int fatorMilesimos,
      required int convidadosNoMomento,
      Value<DateTime> adicionadaEm,
    });
typedef $$OrcamentoReceitasTableUpdateCompanionBuilder =
    OrcamentoReceitasCompanion Function({
      Value<int> id,
      Value<int> orcamentoId,
      Value<int> receitaId,
      Value<int> fatorMilesimos,
      Value<int> convidadosNoMomento,
      Value<DateTime> adicionadaEm,
    });

final class $$OrcamentoReceitasTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $OrcamentoReceitasTable,
          OrcamentoReceita
        > {
  $$OrcamentoReceitasTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $OrcamentosTable _orcamentoIdTable(_$AppDatabase db) => db.orcamentos
      .createAlias('orcamento_receitas__orcamento_id__orcamentos__id');

  $$OrcamentosTableProcessedTableManager get orcamentoId {
    final $_column = $_itemColumn<int>('orcamento_id')!;

    final manager = $$OrcamentosTableTableManager(
      $_db,
      $_db.orcamentos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_orcamentoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ReceitasTable _receitaIdTable(_$AppDatabase db) =>
      db.receitas.createAlias('orcamento_receitas__receita_id__receitas__id');

  $$ReceitasTableProcessedTableManager get receitaId {
    final $_column = $_itemColumn<int>('receita_id')!;

    final manager = $$ReceitasTableTableManager(
      $_db,
      $_db.receitas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_receitaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$OrcamentoReceitasTableFilterComposer
    extends Composer<_$AppDatabase, $OrcamentoReceitasTable> {
  $$OrcamentoReceitasTableFilterComposer({
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

  ColumnFilters<int> get fatorMilesimos => $composableBuilder(
    column: $table.fatorMilesimos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get convidadosNoMomento => $composableBuilder(
    column: $table.convidadosNoMomento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get adicionadaEm => $composableBuilder(
    column: $table.adicionadaEm,
    builder: (column) => ColumnFilters(column),
  );

  $$OrcamentosTableFilterComposer get orcamentoId {
    final $$OrcamentosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orcamentoId,
      referencedTable: $db.orcamentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrcamentosTableFilterComposer(
            $db: $db,
            $table: $db.orcamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ReceitasTableFilterComposer get receitaId {
    final $$ReceitasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.receitaId,
      referencedTable: $db.receitas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReceitasTableFilterComposer(
            $db: $db,
            $table: $db.receitas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OrcamentoReceitasTableOrderingComposer
    extends Composer<_$AppDatabase, $OrcamentoReceitasTable> {
  $$OrcamentoReceitasTableOrderingComposer({
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

  ColumnOrderings<int> get fatorMilesimos => $composableBuilder(
    column: $table.fatorMilesimos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get convidadosNoMomento => $composableBuilder(
    column: $table.convidadosNoMomento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get adicionadaEm => $composableBuilder(
    column: $table.adicionadaEm,
    builder: (column) => ColumnOrderings(column),
  );

  $$OrcamentosTableOrderingComposer get orcamentoId {
    final $$OrcamentosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orcamentoId,
      referencedTable: $db.orcamentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrcamentosTableOrderingComposer(
            $db: $db,
            $table: $db.orcamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ReceitasTableOrderingComposer get receitaId {
    final $$ReceitasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.receitaId,
      referencedTable: $db.receitas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReceitasTableOrderingComposer(
            $db: $db,
            $table: $db.receitas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OrcamentoReceitasTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrcamentoReceitasTable> {
  $$OrcamentoReceitasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get fatorMilesimos => $composableBuilder(
    column: $table.fatorMilesimos,
    builder: (column) => column,
  );

  GeneratedColumn<int> get convidadosNoMomento => $composableBuilder(
    column: $table.convidadosNoMomento,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get adicionadaEm => $composableBuilder(
    column: $table.adicionadaEm,
    builder: (column) => column,
  );

  $$OrcamentosTableAnnotationComposer get orcamentoId {
    final $$OrcamentosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.orcamentoId,
      referencedTable: $db.orcamentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OrcamentosTableAnnotationComposer(
            $db: $db,
            $table: $db.orcamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ReceitasTableAnnotationComposer get receitaId {
    final $$ReceitasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.receitaId,
      referencedTable: $db.receitas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReceitasTableAnnotationComposer(
            $db: $db,
            $table: $db.receitas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OrcamentoReceitasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OrcamentoReceitasTable,
          OrcamentoReceita,
          $$OrcamentoReceitasTableFilterComposer,
          $$OrcamentoReceitasTableOrderingComposer,
          $$OrcamentoReceitasTableAnnotationComposer,
          $$OrcamentoReceitasTableCreateCompanionBuilder,
          $$OrcamentoReceitasTableUpdateCompanionBuilder,
          (OrcamentoReceita, $$OrcamentoReceitasTableReferences),
          OrcamentoReceita,
          PrefetchHooks Function({bool orcamentoId, bool receitaId})
        > {
  $$OrcamentoReceitasTableTableManager(
    _$AppDatabase db,
    $OrcamentoReceitasTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrcamentoReceitasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrcamentoReceitasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrcamentoReceitasTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> orcamentoId = const Value.absent(),
                Value<int> receitaId = const Value.absent(),
                Value<int> fatorMilesimos = const Value.absent(),
                Value<int> convidadosNoMomento = const Value.absent(),
                Value<DateTime> adicionadaEm = const Value.absent(),
              }) => OrcamentoReceitasCompanion(
                id: id,
                orcamentoId: orcamentoId,
                receitaId: receitaId,
                fatorMilesimos: fatorMilesimos,
                convidadosNoMomento: convidadosNoMomento,
                adicionadaEm: adicionadaEm,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int orcamentoId,
                required int receitaId,
                required int fatorMilesimos,
                required int convidadosNoMomento,
                Value<DateTime> adicionadaEm = const Value.absent(),
              }) => OrcamentoReceitasCompanion.insert(
                id: id,
                orcamentoId: orcamentoId,
                receitaId: receitaId,
                fatorMilesimos: fatorMilesimos,
                convidadosNoMomento: convidadosNoMomento,
                adicionadaEm: adicionadaEm,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OrcamentoReceitasTable, OrcamentoReceita>(table),
                  $$OrcamentoReceitasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({orcamentoId = false, receitaId = false}) {
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
                    if (orcamentoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.orcamentoId,
                        referencedTable: $$OrcamentoReceitasTableReferences
                            ._orcamentoIdTable(db),
                        referencedColumn: $$OrcamentoReceitasTableReferences
                            ._orcamentoIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (receitaId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.receitaId,
                        referencedTable: $$OrcamentoReceitasTableReferences
                            ._receitaIdTable(db),
                        referencedColumn: $$OrcamentoReceitasTableReferences
                            ._receitaIdTable(db)
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

typedef $$OrcamentoReceitasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OrcamentoReceitasTable,
      OrcamentoReceita,
      $$OrcamentoReceitasTableFilterComposer,
      $$OrcamentoReceitasTableOrderingComposer,
      $$OrcamentoReceitasTableAnnotationComposer,
      $$OrcamentoReceitasTableCreateCompanionBuilder,
      $$OrcamentoReceitasTableUpdateCompanionBuilder,
      (OrcamentoReceita, $$OrcamentoReceitasTableReferences),
      OrcamentoReceita,
      PrefetchHooks Function({bool orcamentoId, bool receitaId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ClientesTableTableManager get clientes =>
      $$ClientesTableTableManager(_db, _db.clientes);
  $$OrcamentosTableTableManager get orcamentos =>
      $$OrcamentosTableTableManager(_db, _db.orcamentos);
  $$ServicosTableTableManager get servicos =>
      $$ServicosTableTableManager(_db, _db.servicos);
  $$OrcamentoItensTableTableManager get orcamentoItens =>
      $$OrcamentoItensTableTableManager(_db, _db.orcamentoItens);
  $$EventosTableTableManager get eventos =>
      $$EventosTableTableManager(_db, _db.eventos);
  $$EmpresasTableTableManager get empresas =>
      $$EmpresasTableTableManager(_db, _db.empresas);
  $$ReceitasTableTableManager get receitas =>
      $$ReceitasTableTableManager(_db, _db.receitas);
  $$ReceitaIngredientesTableTableManager get receitaIngredientes =>
      $$ReceitaIngredientesTableTableManager(_db, _db.receitaIngredientes);
  $$OrcamentoReceitasTableTableManager get orcamentoReceitas =>
      $$OrcamentoReceitasTableTableManager(_db, _db.orcamentoReceitas);
}
