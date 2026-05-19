// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ChatMessagesTableTable extends ChatMessagesTable
    with TableInfo<$ChatMessagesTableTable, ChatMessageEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessagesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isLoadingMeta = const VerificationMeta(
    'isLoading',
  );
  @override
  late final GeneratedColumn<bool> isLoading = GeneratedColumn<bool>(
    'is_loading',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_loading" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    content,
    role,
    timestamp,
    isLoading,
    sessionId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_messages_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatMessageEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('is_loading')) {
      context.handle(
        _isLoadingMeta,
        isLoading.isAcceptableOrUnknown(data['is_loading']!, _isLoadingMeta),
      );
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessageEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessageEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      isLoading: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_loading'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      ),
    );
  }

  @override
  $ChatMessagesTableTable createAlias(String alias) {
    return $ChatMessagesTableTable(attachedDatabase, alias);
  }
}

class ChatMessageEntry extends DataClass
    implements Insertable<ChatMessageEntry> {
  final String id;
  final String content;
  final String role;
  final DateTime timestamp;
  final bool isLoading;
  final String? sessionId;
  const ChatMessageEntry({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    required this.isLoading,
    this.sessionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['content'] = Variable<String>(content);
    map['role'] = Variable<String>(role);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['is_loading'] = Variable<bool>(isLoading);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<String>(sessionId);
    }
    return map;
  }

  ChatMessagesTableCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesTableCompanion(
      id: Value(id),
      content: Value(content),
      role: Value(role),
      timestamp: Value(timestamp),
      isLoading: Value(isLoading),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
    );
  }

  factory ChatMessageEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessageEntry(
      id: serializer.fromJson<String>(json['id']),
      content: serializer.fromJson<String>(json['content']),
      role: serializer.fromJson<String>(json['role']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      isLoading: serializer.fromJson<bool>(json['isLoading']),
      sessionId: serializer.fromJson<String?>(json['sessionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'content': serializer.toJson<String>(content),
      'role': serializer.toJson<String>(role),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'isLoading': serializer.toJson<bool>(isLoading),
      'sessionId': serializer.toJson<String?>(sessionId),
    };
  }

  ChatMessageEntry copyWith({
    String? id,
    String? content,
    String? role,
    DateTime? timestamp,
    bool? isLoading,
    Value<String?> sessionId = const Value.absent(),
  }) => ChatMessageEntry(
    id: id ?? this.id,
    content: content ?? this.content,
    role: role ?? this.role,
    timestamp: timestamp ?? this.timestamp,
    isLoading: isLoading ?? this.isLoading,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
  );
  ChatMessageEntry copyWithCompanion(ChatMessagesTableCompanion data) {
    return ChatMessageEntry(
      id: data.id.present ? data.id.value : this.id,
      content: data.content.present ? data.content.value : this.content,
      role: data.role.present ? data.role.value : this.role,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      isLoading: data.isLoading.present ? data.isLoading.value : this.isLoading,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessageEntry(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('role: $role, ')
          ..write('timestamp: $timestamp, ')
          ..write('isLoading: $isLoading, ')
          ..write('sessionId: $sessionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, content, role, timestamp, isLoading, sessionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessageEntry &&
          other.id == this.id &&
          other.content == this.content &&
          other.role == this.role &&
          other.timestamp == this.timestamp &&
          other.isLoading == this.isLoading &&
          other.sessionId == this.sessionId);
}

class ChatMessagesTableCompanion extends UpdateCompanion<ChatMessageEntry> {
  final Value<String> id;
  final Value<String> content;
  final Value<String> role;
  final Value<DateTime> timestamp;
  final Value<bool> isLoading;
  final Value<String?> sessionId;
  final Value<int> rowid;
  const ChatMessagesTableCompanion({
    this.id = const Value.absent(),
    this.content = const Value.absent(),
    this.role = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.isLoading = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatMessagesTableCompanion.insert({
    required String id,
    required String content,
    required String role,
    required DateTime timestamp,
    this.isLoading = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       content = Value(content),
       role = Value(role),
       timestamp = Value(timestamp);
  static Insertable<ChatMessageEntry> custom({
    Expression<String>? id,
    Expression<String>? content,
    Expression<String>? role,
    Expression<DateTime>? timestamp,
    Expression<bool>? isLoading,
    Expression<String>? sessionId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (content != null) 'content': content,
      if (role != null) 'role': role,
      if (timestamp != null) 'timestamp': timestamp,
      if (isLoading != null) 'is_loading': isLoading,
      if (sessionId != null) 'session_id': sessionId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatMessagesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? content,
    Value<String>? role,
    Value<DateTime>? timestamp,
    Value<bool>? isLoading,
    Value<String?>? sessionId,
    Value<int>? rowid,
  }) {
    return ChatMessagesTableCompanion(
      id: id ?? this.id,
      content: content ?? this.content,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      isLoading: isLoading ?? this.isLoading,
      sessionId: sessionId ?? this.sessionId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (isLoading.present) {
      map['is_loading'] = Variable<bool>(isLoading.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesTableCompanion(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('role: $role, ')
          ..write('timestamp: $timestamp, ')
          ..write('isLoading: $isLoading, ')
          ..write('sessionId: $sessionId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookingsTableTable extends BookingsTable
    with TableInfo<$BookingsTableTable, BookingEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serviceTypeMeta = const VerificationMeta(
    'serviceType',
  );
  @override
  late final GeneratedColumn<String> serviceType = GeneratedColumn<String>(
    'service_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerNameMeta = const VerificationMeta(
    'customerName',
  );
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
    'customer_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estimatedCostMeta = const VerificationMeta(
    'estimatedCost',
  );
  @override
  late final GeneratedColumn<double> estimatedCost = GeneratedColumn<double>(
    'estimated_cost',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
    'scheduled_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawJsonMeta = const VerificationMeta(
    'rawJson',
  );
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
    'raw_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    serviceType,
    description,
    customerName,
    location,
    status,
    estimatedCost,
    scheduledAt,
    createdAt,
    rawJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookings_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookingEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('service_type')) {
      context.handle(
        _serviceTypeMeta,
        serviceType.isAcceptableOrUnknown(
          data['service_type']!,
          _serviceTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serviceTypeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('customer_name')) {
      context.handle(
        _customerNameMeta,
        customerName.isAcceptableOrUnknown(
          data['customer_name']!,
          _customerNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_customerNameMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('estimated_cost')) {
      context.handle(
        _estimatedCostMeta,
        estimatedCost.isAcceptableOrUnknown(
          data['estimated_cost']!,
          _estimatedCostMeta,
        ),
      );
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('raw_json')) {
      context.handle(
        _rawJsonMeta,
        rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_rawJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookingEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookingEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      serviceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service_type'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      customerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_name'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      estimatedCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}estimated_cost'],
      ),
      scheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      rawJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_json'],
      )!,
    );
  }

  @override
  $BookingsTableTable createAlias(String alias) {
    return $BookingsTableTable(attachedDatabase, alias);
  }
}

class BookingEntry extends DataClass implements Insertable<BookingEntry> {
  final String id;
  final String serviceType;
  final String description;
  final String customerName;
  final String location;
  final String status;
  final double? estimatedCost;
  final DateTime scheduledAt;
  final DateTime createdAt;
  final String rawJson;
  const BookingEntry({
    required this.id,
    required this.serviceType,
    required this.description,
    required this.customerName,
    required this.location,
    required this.status,
    this.estimatedCost,
    required this.scheduledAt,
    required this.createdAt,
    required this.rawJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['service_type'] = Variable<String>(serviceType);
    map['description'] = Variable<String>(description);
    map['customer_name'] = Variable<String>(customerName);
    map['location'] = Variable<String>(location);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || estimatedCost != null) {
      map['estimated_cost'] = Variable<double>(estimatedCost);
    }
    map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['raw_json'] = Variable<String>(rawJson);
    return map;
  }

  BookingsTableCompanion toCompanion(bool nullToAbsent) {
    return BookingsTableCompanion(
      id: Value(id),
      serviceType: Value(serviceType),
      description: Value(description),
      customerName: Value(customerName),
      location: Value(location),
      status: Value(status),
      estimatedCost: estimatedCost == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedCost),
      scheduledAt: Value(scheduledAt),
      createdAt: Value(createdAt),
      rawJson: Value(rawJson),
    );
  }

  factory BookingEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookingEntry(
      id: serializer.fromJson<String>(json['id']),
      serviceType: serializer.fromJson<String>(json['serviceType']),
      description: serializer.fromJson<String>(json['description']),
      customerName: serializer.fromJson<String>(json['customerName']),
      location: serializer.fromJson<String>(json['location']),
      status: serializer.fromJson<String>(json['status']),
      estimatedCost: serializer.fromJson<double?>(json['estimatedCost']),
      scheduledAt: serializer.fromJson<DateTime>(json['scheduledAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      rawJson: serializer.fromJson<String>(json['rawJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'serviceType': serializer.toJson<String>(serviceType),
      'description': serializer.toJson<String>(description),
      'customerName': serializer.toJson<String>(customerName),
      'location': serializer.toJson<String>(location),
      'status': serializer.toJson<String>(status),
      'estimatedCost': serializer.toJson<double?>(estimatedCost),
      'scheduledAt': serializer.toJson<DateTime>(scheduledAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'rawJson': serializer.toJson<String>(rawJson),
    };
  }

  BookingEntry copyWith({
    String? id,
    String? serviceType,
    String? description,
    String? customerName,
    String? location,
    String? status,
    Value<double?> estimatedCost = const Value.absent(),
    DateTime? scheduledAt,
    DateTime? createdAt,
    String? rawJson,
  }) => BookingEntry(
    id: id ?? this.id,
    serviceType: serviceType ?? this.serviceType,
    description: description ?? this.description,
    customerName: customerName ?? this.customerName,
    location: location ?? this.location,
    status: status ?? this.status,
    estimatedCost: estimatedCost.present
        ? estimatedCost.value
        : this.estimatedCost,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    createdAt: createdAt ?? this.createdAt,
    rawJson: rawJson ?? this.rawJson,
  );
  BookingEntry copyWithCompanion(BookingsTableCompanion data) {
    return BookingEntry(
      id: data.id.present ? data.id.value : this.id,
      serviceType: data.serviceType.present
          ? data.serviceType.value
          : this.serviceType,
      description: data.description.present
          ? data.description.value
          : this.description,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      location: data.location.present ? data.location.value : this.location,
      status: data.status.present ? data.status.value : this.status,
      estimatedCost: data.estimatedCost.present
          ? data.estimatedCost.value
          : this.estimatedCost,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      rawJson: data.rawJson.present ? data.rawJson.value : this.rawJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookingEntry(')
          ..write('id: $id, ')
          ..write('serviceType: $serviceType, ')
          ..write('description: $description, ')
          ..write('customerName: $customerName, ')
          ..write('location: $location, ')
          ..write('status: $status, ')
          ..write('estimatedCost: $estimatedCost, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rawJson: $rawJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serviceType,
    description,
    customerName,
    location,
    status,
    estimatedCost,
    scheduledAt,
    createdAt,
    rawJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookingEntry &&
          other.id == this.id &&
          other.serviceType == this.serviceType &&
          other.description == this.description &&
          other.customerName == this.customerName &&
          other.location == this.location &&
          other.status == this.status &&
          other.estimatedCost == this.estimatedCost &&
          other.scheduledAt == this.scheduledAt &&
          other.createdAt == this.createdAt &&
          other.rawJson == this.rawJson);
}

class BookingsTableCompanion extends UpdateCompanion<BookingEntry> {
  final Value<String> id;
  final Value<String> serviceType;
  final Value<String> description;
  final Value<String> customerName;
  final Value<String> location;
  final Value<String> status;
  final Value<double?> estimatedCost;
  final Value<DateTime> scheduledAt;
  final Value<DateTime> createdAt;
  final Value<String> rawJson;
  final Value<int> rowid;
  const BookingsTableCompanion({
    this.id = const Value.absent(),
    this.serviceType = const Value.absent(),
    this.description = const Value.absent(),
    this.customerName = const Value.absent(),
    this.location = const Value.absent(),
    this.status = const Value.absent(),
    this.estimatedCost = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rawJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookingsTableCompanion.insert({
    required String id,
    required String serviceType,
    required String description,
    required String customerName,
    required String location,
    required String status,
    this.estimatedCost = const Value.absent(),
    required DateTime scheduledAt,
    required DateTime createdAt,
    required String rawJson,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       serviceType = Value(serviceType),
       description = Value(description),
       customerName = Value(customerName),
       location = Value(location),
       status = Value(status),
       scheduledAt = Value(scheduledAt),
       createdAt = Value(createdAt),
       rawJson = Value(rawJson);
  static Insertable<BookingEntry> custom({
    Expression<String>? id,
    Expression<String>? serviceType,
    Expression<String>? description,
    Expression<String>? customerName,
    Expression<String>? location,
    Expression<String>? status,
    Expression<double>? estimatedCost,
    Expression<DateTime>? scheduledAt,
    Expression<DateTime>? createdAt,
    Expression<String>? rawJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serviceType != null) 'service_type': serviceType,
      if (description != null) 'description': description,
      if (customerName != null) 'customer_name': customerName,
      if (location != null) 'location': location,
      if (status != null) 'status': status,
      if (estimatedCost != null) 'estimated_cost': estimatedCost,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rawJson != null) 'raw_json': rawJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookingsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? serviceType,
    Value<String>? description,
    Value<String>? customerName,
    Value<String>? location,
    Value<String>? status,
    Value<double?>? estimatedCost,
    Value<DateTime>? scheduledAt,
    Value<DateTime>? createdAt,
    Value<String>? rawJson,
    Value<int>? rowid,
  }) {
    return BookingsTableCompanion(
      id: id ?? this.id,
      serviceType: serviceType ?? this.serviceType,
      description: description ?? this.description,
      customerName: customerName ?? this.customerName,
      location: location ?? this.location,
      status: status ?? this.status,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      createdAt: createdAt ?? this.createdAt,
      rawJson: rawJson ?? this.rawJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (serviceType.present) {
      map['service_type'] = Variable<String>(serviceType.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (estimatedCost.present) {
      map['estimated_cost'] = Variable<double>(estimatedCost.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rawJson.present) {
      map['raw_json'] = Variable<String>(rawJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookingsTableCompanion(')
          ..write('id: $id, ')
          ..write('serviceType: $serviceType, ')
          ..write('description: $description, ')
          ..write('customerName: $customerName, ')
          ..write('location: $location, ')
          ..write('status: $status, ')
          ..write('estimatedCost: $estimatedCost, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rawJson: $rawJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTableTable extends SettingsTable
    with TableInfo<$SettingsTableTable, SettingEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingEntry(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTableTable createAlias(String alias) {
    return $SettingsTableTable(attachedDatabase, alias);
  }
}

class SettingEntry extends DataClass implements Insertable<SettingEntry> {
  final String key;
  final String value;
  const SettingEntry({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsTableCompanion toCompanion(bool nullToAbsent) {
    return SettingsTableCompanion(key: Value(key), value: Value(value));
  }

  factory SettingEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingEntry(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingEntry copyWith({String? key, String? value}) =>
      SettingEntry(key: key ?? this.key, value: value ?? this.value);
  SettingEntry copyWithCompanion(SettingsTableCompanion data) {
    return SettingEntry(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingEntry(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingEntry &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsTableCompanion extends UpdateCompanion<SettingEntry> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsTableCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsTableCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingEntry> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsTableCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsTableCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsTableCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UsersTableTable extends UsersTable
    with TableInfo<$UsersTableTable, UserEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _passwordHashMeta = const VerificationMeta(
    'passwordHash',
  );
  @override
  late final GeneratedColumn<String> passwordHash = GeneratedColumn<String>(
    'password_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _otpMeta = const VerificationMeta('otp');
  @override
  late final GeneratedColumn<String> otp = GeneratedColumn<String>(
    'otp',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isVerifiedMeta = const VerificationMeta(
    'isVerified',
  );
  @override
  late final GeneratedColumn<bool> isVerified = GeneratedColumn<bool>(
    'is_verified',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_verified" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _tokenMeta = const VerificationMeta('token');
  @override
  late final GeneratedColumn<String> token = GeneratedColumn<String>(
    'token',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    phone,
    passwordHash,
    address,
    role,
    otp,
    isVerified,
    token,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserEntry> instance, {
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
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('password_hash')) {
      context.handle(
        _passwordHashMeta,
        passwordHash.isAcceptableOrUnknown(
          data['password_hash']!,
          _passwordHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_passwordHashMeta);
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('otp')) {
      context.handle(
        _otpMeta,
        otp.isAcceptableOrUnknown(data['otp']!, _otpMeta),
      );
    }
    if (data.containsKey('is_verified')) {
      context.handle(
        _isVerifiedMeta,
        isVerified.isAcceptableOrUnknown(data['is_verified']!, _isVerifiedMeta),
      );
    }
    if (data.containsKey('token')) {
      context.handle(
        _tokenMeta,
        token.isAcceptableOrUnknown(data['token']!, _tokenMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      passwordHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password_hash'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      otp: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}otp'],
      ),
      isVerified: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_verified'],
      )!,
      token: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}token'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UsersTableTable createAlias(String alias) {
    return $UsersTableTable(attachedDatabase, alias);
  }
}

class UserEntry extends DataClass implements Insertable<UserEntry> {
  final String id;
  final String name;
  final String phone;
  final String passwordHash;
  final String? address;
  final String role;
  final String? otp;
  final bool isVerified;
  final String? token;
  final DateTime createdAt;
  const UserEntry({
    required this.id,
    required this.name,
    required this.phone,
    required this.passwordHash,
    this.address,
    required this.role,
    this.otp,
    required this.isVerified,
    this.token,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['phone'] = Variable<String>(phone);
    map['password_hash'] = Variable<String>(passwordHash);
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || otp != null) {
      map['otp'] = Variable<String>(otp);
    }
    map['is_verified'] = Variable<bool>(isVerified);
    if (!nullToAbsent || token != null) {
      map['token'] = Variable<String>(token);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UsersTableCompanion toCompanion(bool nullToAbsent) {
    return UsersTableCompanion(
      id: Value(id),
      name: Value(name),
      phone: Value(phone),
      passwordHash: Value(passwordHash),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      role: Value(role),
      otp: otp == null && nullToAbsent ? const Value.absent() : Value(otp),
      isVerified: Value(isVerified),
      token: token == null && nullToAbsent
          ? const Value.absent()
          : Value(token),
      createdAt: Value(createdAt),
    );
  }

  factory UserEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserEntry(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String>(json['phone']),
      passwordHash: serializer.fromJson<String>(json['passwordHash']),
      address: serializer.fromJson<String?>(json['address']),
      role: serializer.fromJson<String>(json['role']),
      otp: serializer.fromJson<String?>(json['otp']),
      isVerified: serializer.fromJson<bool>(json['isVerified']),
      token: serializer.fromJson<String?>(json['token']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String>(phone),
      'passwordHash': serializer.toJson<String>(passwordHash),
      'address': serializer.toJson<String?>(address),
      'role': serializer.toJson<String>(role),
      'otp': serializer.toJson<String?>(otp),
      'isVerified': serializer.toJson<bool>(isVerified),
      'token': serializer.toJson<String?>(token),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UserEntry copyWith({
    String? id,
    String? name,
    String? phone,
    String? passwordHash,
    Value<String?> address = const Value.absent(),
    String? role,
    Value<String?> otp = const Value.absent(),
    bool? isVerified,
    Value<String?> token = const Value.absent(),
    DateTime? createdAt,
  }) => UserEntry(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    passwordHash: passwordHash ?? this.passwordHash,
    address: address.present ? address.value : this.address,
    role: role ?? this.role,
    otp: otp.present ? otp.value : this.otp,
    isVerified: isVerified ?? this.isVerified,
    token: token.present ? token.value : this.token,
    createdAt: createdAt ?? this.createdAt,
  );
  UserEntry copyWithCompanion(UsersTableCompanion data) {
    return UserEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      passwordHash: data.passwordHash.present
          ? data.passwordHash.value
          : this.passwordHash,
      address: data.address.present ? data.address.value : this.address,
      role: data.role.present ? data.role.value : this.role,
      otp: data.otp.present ? data.otp.value : this.otp,
      isVerified: data.isVerified.present
          ? data.isVerified.value
          : this.isVerified,
      token: data.token.present ? data.token.value : this.token,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('address: $address, ')
          ..write('role: $role, ')
          ..write('otp: $otp, ')
          ..write('isVerified: $isVerified, ')
          ..write('token: $token, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    phone,
    passwordHash,
    address,
    role,
    otp,
    isVerified,
    token,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.passwordHash == this.passwordHash &&
          other.address == this.address &&
          other.role == this.role &&
          other.otp == this.otp &&
          other.isVerified == this.isVerified &&
          other.token == this.token &&
          other.createdAt == this.createdAt);
}

class UsersTableCompanion extends UpdateCompanion<UserEntry> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> phone;
  final Value<String> passwordHash;
  final Value<String?> address;
  final Value<String> role;
  final Value<String?> otp;
  final Value<bool> isVerified;
  final Value<String?> token;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const UsersTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.address = const Value.absent(),
    this.role = const Value.absent(),
    this.otp = const Value.absent(),
    this.isVerified = const Value.absent(),
    this.token = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersTableCompanion.insert({
    required String id,
    required String name,
    required String phone,
    required String passwordHash,
    this.address = const Value.absent(),
    required String role,
    this.otp = const Value.absent(),
    this.isVerified = const Value.absent(),
    this.token = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       phone = Value(phone),
       passwordHash = Value(passwordHash),
       role = Value(role),
       createdAt = Value(createdAt);
  static Insertable<UserEntry> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? passwordHash,
    Expression<String>? address,
    Expression<String>? role,
    Expression<String>? otp,
    Expression<bool>? isVerified,
    Expression<String>? token,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (address != null) 'address': address,
      if (role != null) 'role': role,
      if (otp != null) 'otp': otp,
      if (isVerified != null) 'is_verified': isVerified,
      if (token != null) 'token': token,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? phone,
    Value<String>? passwordHash,
    Value<String?>? address,
    Value<String>? role,
    Value<String?>? otp,
    Value<bool>? isVerified,
    Value<String?>? token,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return UsersTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      passwordHash: passwordHash ?? this.passwordHash,
      address: address ?? this.address,
      role: role ?? this.role,
      otp: otp ?? this.otp,
      isVerified: isVerified ?? this.isVerified,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
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
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (passwordHash.present) {
      map['password_hash'] = Variable<String>(passwordHash.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (otp.present) {
      map['otp'] = Variable<String>(otp.value);
    }
    if (isVerified.present) {
      map['is_verified'] = Variable<bool>(isVerified.value);
    }
    if (token.present) {
      map['token'] = Variable<String>(token.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('address: $address, ')
          ..write('role: $role, ')
          ..write('otp: $otp, ')
          ..write('isVerified: $isVerified, ')
          ..write('token: $token, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ChatMessagesTableTable chatMessagesTable =
      $ChatMessagesTableTable(this);
  late final $BookingsTableTable bookingsTable = $BookingsTableTable(this);
  late final $SettingsTableTable settingsTable = $SettingsTableTable(this);
  late final $UsersTableTable usersTable = $UsersTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    chatMessagesTable,
    bookingsTable,
    settingsTable,
    usersTable,
  ];
}

typedef $$ChatMessagesTableTableCreateCompanionBuilder =
    ChatMessagesTableCompanion Function({
      required String id,
      required String content,
      required String role,
      required DateTime timestamp,
      Value<bool> isLoading,
      Value<String?> sessionId,
      Value<int> rowid,
    });
typedef $$ChatMessagesTableTableUpdateCompanionBuilder =
    ChatMessagesTableCompanion Function({
      Value<String> id,
      Value<String> content,
      Value<String> role,
      Value<DateTime> timestamp,
      Value<bool> isLoading,
      Value<String?> sessionId,
      Value<int> rowid,
    });

class $$ChatMessagesTableTableFilterComposer
    extends Composer<_$AppDatabase, $ChatMessagesTableTable> {
  $$ChatMessagesTableTableFilterComposer({
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

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLoading => $composableBuilder(
    column: $table.isLoading,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChatMessagesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatMessagesTableTable> {
  $$ChatMessagesTableTableOrderingComposer({
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

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLoading => $composableBuilder(
    column: $table.isLoading,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChatMessagesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatMessagesTableTable> {
  $$ChatMessagesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<bool> get isLoading =>
      $composableBuilder(column: $table.isLoading, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);
}

class $$ChatMessagesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChatMessagesTableTable,
          ChatMessageEntry,
          $$ChatMessagesTableTableFilterComposer,
          $$ChatMessagesTableTableOrderingComposer,
          $$ChatMessagesTableTableAnnotationComposer,
          $$ChatMessagesTableTableCreateCompanionBuilder,
          $$ChatMessagesTableTableUpdateCompanionBuilder,
          (
            ChatMessageEntry,
            BaseReferences<
              _$AppDatabase,
              $ChatMessagesTableTable,
              ChatMessageEntry
            >,
          ),
          ChatMessageEntry,
          PrefetchHooks Function()
        > {
  $$ChatMessagesTableTableTableManager(
    _$AppDatabase db,
    $ChatMessagesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatMessagesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatMessagesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatMessagesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<bool> isLoading = const Value.absent(),
                Value<String?> sessionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatMessagesTableCompanion(
                id: id,
                content: content,
                role: role,
                timestamp: timestamp,
                isLoading: isLoading,
                sessionId: sessionId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String content,
                required String role,
                required DateTime timestamp,
                Value<bool> isLoading = const Value.absent(),
                Value<String?> sessionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatMessagesTableCompanion.insert(
                id: id,
                content: content,
                role: role,
                timestamp: timestamp,
                isLoading: isLoading,
                sessionId: sessionId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChatMessagesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChatMessagesTableTable,
      ChatMessageEntry,
      $$ChatMessagesTableTableFilterComposer,
      $$ChatMessagesTableTableOrderingComposer,
      $$ChatMessagesTableTableAnnotationComposer,
      $$ChatMessagesTableTableCreateCompanionBuilder,
      $$ChatMessagesTableTableUpdateCompanionBuilder,
      (
        ChatMessageEntry,
        BaseReferences<
          _$AppDatabase,
          $ChatMessagesTableTable,
          ChatMessageEntry
        >,
      ),
      ChatMessageEntry,
      PrefetchHooks Function()
    >;
typedef $$BookingsTableTableCreateCompanionBuilder =
    BookingsTableCompanion Function({
      required String id,
      required String serviceType,
      required String description,
      required String customerName,
      required String location,
      required String status,
      Value<double?> estimatedCost,
      required DateTime scheduledAt,
      required DateTime createdAt,
      required String rawJson,
      Value<int> rowid,
    });
typedef $$BookingsTableTableUpdateCompanionBuilder =
    BookingsTableCompanion Function({
      Value<String> id,
      Value<String> serviceType,
      Value<String> description,
      Value<String> customerName,
      Value<String> location,
      Value<String> status,
      Value<double?> estimatedCost,
      Value<DateTime> scheduledAt,
      Value<DateTime> createdAt,
      Value<String> rawJson,
      Value<int> rowid,
    });

class $$BookingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $BookingsTableTable> {
  $$BookingsTableTableFilterComposer({
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

  ColumnFilters<String> get serviceType => $composableBuilder(
    column: $table.serviceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get estimatedCost => $composableBuilder(
    column: $table.estimatedCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BookingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $BookingsTableTable> {
  $$BookingsTableTableOrderingComposer({
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

  ColumnOrderings<String> get serviceType => $composableBuilder(
    column: $table.serviceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get estimatedCost => $composableBuilder(
    column: $table.estimatedCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawJson => $composableBuilder(
    column: $table.rawJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BookingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookingsTableTable> {
  $$BookingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serviceType => $composableBuilder(
    column: $table.serviceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get estimatedCost => $composableBuilder(
    column: $table.estimatedCost,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get rawJson =>
      $composableBuilder(column: $table.rawJson, builder: (column) => column);
}

class $$BookingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookingsTableTable,
          BookingEntry,
          $$BookingsTableTableFilterComposer,
          $$BookingsTableTableOrderingComposer,
          $$BookingsTableTableAnnotationComposer,
          $$BookingsTableTableCreateCompanionBuilder,
          $$BookingsTableTableUpdateCompanionBuilder,
          (
            BookingEntry,
            BaseReferences<_$AppDatabase, $BookingsTableTable, BookingEntry>,
          ),
          BookingEntry,
          PrefetchHooks Function()
        > {
  $$BookingsTableTableTableManager(_$AppDatabase db, $BookingsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> serviceType = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> customerName = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double?> estimatedCost = const Value.absent(),
                Value<DateTime> scheduledAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> rawJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookingsTableCompanion(
                id: id,
                serviceType: serviceType,
                description: description,
                customerName: customerName,
                location: location,
                status: status,
                estimatedCost: estimatedCost,
                scheduledAt: scheduledAt,
                createdAt: createdAt,
                rawJson: rawJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String serviceType,
                required String description,
                required String customerName,
                required String location,
                required String status,
                Value<double?> estimatedCost = const Value.absent(),
                required DateTime scheduledAt,
                required DateTime createdAt,
                required String rawJson,
                Value<int> rowid = const Value.absent(),
              }) => BookingsTableCompanion.insert(
                id: id,
                serviceType: serviceType,
                description: description,
                customerName: customerName,
                location: location,
                status: status,
                estimatedCost: estimatedCost,
                scheduledAt: scheduledAt,
                createdAt: createdAt,
                rawJson: rawJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BookingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookingsTableTable,
      BookingEntry,
      $$BookingsTableTableFilterComposer,
      $$BookingsTableTableOrderingComposer,
      $$BookingsTableTableAnnotationComposer,
      $$BookingsTableTableCreateCompanionBuilder,
      $$BookingsTableTableUpdateCompanionBuilder,
      (
        BookingEntry,
        BaseReferences<_$AppDatabase, $BookingsTableTable, BookingEntry>,
      ),
      BookingEntry,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableTableCreateCompanionBuilder =
    SettingsTableCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingsTableTableUpdateCompanionBuilder =
    SettingsTableCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTableTable,
          SettingEntry,
          $$SettingsTableTableFilterComposer,
          $$SettingsTableTableOrderingComposer,
          $$SettingsTableTableAnnotationComposer,
          $$SettingsTableTableCreateCompanionBuilder,
          $$SettingsTableTableUpdateCompanionBuilder,
          (
            SettingEntry,
            BaseReferences<_$AppDatabase, $SettingsTableTable, SettingEntry>,
          ),
          SettingEntry,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableTableManager(_$AppDatabase db, $SettingsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  SettingsTableCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingsTableCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTableTable,
      SettingEntry,
      $$SettingsTableTableFilterComposer,
      $$SettingsTableTableOrderingComposer,
      $$SettingsTableTableAnnotationComposer,
      $$SettingsTableTableCreateCompanionBuilder,
      $$SettingsTableTableUpdateCompanionBuilder,
      (
        SettingEntry,
        BaseReferences<_$AppDatabase, $SettingsTableTable, SettingEntry>,
      ),
      SettingEntry,
      PrefetchHooks Function()
    >;
typedef $$UsersTableTableCreateCompanionBuilder =
    UsersTableCompanion Function({
      required String id,
      required String name,
      required String phone,
      required String passwordHash,
      Value<String?> address,
      required String role,
      Value<String?> otp,
      Value<bool> isVerified,
      Value<String?> token,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$UsersTableTableUpdateCompanionBuilder =
    UsersTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> phone,
      Value<String> passwordHash,
      Value<String?> address,
      Value<String> role,
      Value<String?> otp,
      Value<bool> isVerified,
      Value<String?> token,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$UsersTableTableFilterComposer
    extends Composer<_$AppDatabase, $UsersTableTable> {
  $$UsersTableTableFilterComposer({
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

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get otp => $composableBuilder(
    column: $table.otp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isVerified => $composableBuilder(
    column: $table.isVerified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get token => $composableBuilder(
    column: $table.token,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTableTable> {
  $$UsersTableTableOrderingComposer({
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

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get otp => $composableBuilder(
    column: $table.otp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isVerified => $composableBuilder(
    column: $table.isVerified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get token => $composableBuilder(
    column: $table.token,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTableTable> {
  $$UsersTableTableAnnotationComposer({
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

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get otp =>
      $composableBuilder(column: $table.otp, builder: (column) => column);

  GeneratedColumn<bool> get isVerified => $composableBuilder(
    column: $table.isVerified,
    builder: (column) => column,
  );

  GeneratedColumn<String> get token =>
      $composableBuilder(column: $table.token, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UsersTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTableTable,
          UserEntry,
          $$UsersTableTableFilterComposer,
          $$UsersTableTableOrderingComposer,
          $$UsersTableTableAnnotationComposer,
          $$UsersTableTableCreateCompanionBuilder,
          $$UsersTableTableUpdateCompanionBuilder,
          (
            UserEntry,
            BaseReferences<_$AppDatabase, $UsersTableTable, UserEntry>,
          ),
          UserEntry,
          PrefetchHooks Function()
        > {
  $$UsersTableTableTableManager(_$AppDatabase db, $UsersTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> passwordHash = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String?> otp = const Value.absent(),
                Value<bool> isVerified = const Value.absent(),
                Value<String?> token = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersTableCompanion(
                id: id,
                name: name,
                phone: phone,
                passwordHash: passwordHash,
                address: address,
                role: role,
                otp: otp,
                isVerified: isVerified,
                token: token,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String phone,
                required String passwordHash,
                Value<String?> address = const Value.absent(),
                required String role,
                Value<String?> otp = const Value.absent(),
                Value<bool> isVerified = const Value.absent(),
                Value<String?> token = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => UsersTableCompanion.insert(
                id: id,
                name: name,
                phone: phone,
                passwordHash: passwordHash,
                address: address,
                role: role,
                otp: otp,
                isVerified: isVerified,
                token: token,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTableTable,
      UserEntry,
      $$UsersTableTableFilterComposer,
      $$UsersTableTableOrderingComposer,
      $$UsersTableTableAnnotationComposer,
      $$UsersTableTableCreateCompanionBuilder,
      $$UsersTableTableUpdateCompanionBuilder,
      (UserEntry, BaseReferences<_$AppDatabase, $UsersTableTable, UserEntry>),
      UserEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ChatMessagesTableTableTableManager get chatMessagesTable =>
      $$ChatMessagesTableTableTableManager(_db, _db.chatMessagesTable);
  $$BookingsTableTableTableManager get bookingsTable =>
      $$BookingsTableTableTableManager(_db, _db.bookingsTable);
  $$SettingsTableTableTableManager get settingsTable =>
      $$SettingsTableTableTableManager(_db, _db.settingsTable);
  $$UsersTableTableTableManager get usersTable =>
      $$UsersTableTableTableManager(_db, _db.usersTable);
}
