import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// ── Tables ───────────────────────────────────────────────────────────────────

@DataClassName('ChatMessageEntry')
class ChatMessagesTable extends Table {
  TextColumn get id => text()();
  TextColumn get content => text()();
  TextColumn get role => text()(); // 'user' | 'ai'
  DateTimeColumn get timestamp => dateTime()();
  BoolColumn get isLoading => boolean().withDefault(const Constant(false))();
  TextColumn get sessionId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('BookingEntry')
class BookingsTable extends Table {
  TextColumn get id => text()();
  TextColumn get serviceType => text()();
  TextColumn get description => text()();
  TextColumn get customerName => text()();
  TextColumn get location => text()();
  TextColumn get status => text()();
  RealColumn get estimatedCost => real().nullable()();
  DateTimeColumn get scheduledAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get rawJson => text()(); // full JSON backup

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SettingEntry')
class SettingsTable extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DataClassName('UserEntry')
class UsersTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text()();
  TextColumn get passwordHash => text()();
  TextColumn get address => text().nullable()();
  TextColumn get role => text()(); // 'customer' | 'provider'
  TextColumn get otp => text().nullable()();
  BoolColumn get isVerified => boolean().withDefault(const Constant(false))();
  TextColumn get token => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ── Database ─────────────────────────────────────────────────────────────────

@DriftDatabase(tables: [ChatMessagesTable, BookingsTable, SettingsTable, UsersTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'ustaadnow_db');
  }

  // ── Chat Methods ────────────────────────────────────────────────────────────

  Future<List<ChatMessageEntry>> getAllMessages({String? sessionId}) {
    if (sessionId != null) {
      return (select(chatMessagesTable)
            ..where((t) => t.sessionId.equals(sessionId))
            ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
          .get();
    }
    return (select(chatMessagesTable)
          ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
        .get();
  }

  Future<int> insertMessage(ChatMessageEntry message) {
    return into(chatMessagesTable).insertOnConflictUpdate(message);
  }

  Future<void> clearMessages({String? sessionId}) {
    if (sessionId != null) {
      return (delete(chatMessagesTable)
            ..where((t) => t.sessionId.equals(sessionId)))
          .go();
    }
    return delete(chatMessagesTable).go();
  }

  // ── Booking Methods ─────────────────────────────────────────────────────────

  Future<List<BookingEntry>> getAllBookings() {
    return (select(bookingsTable)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<int> upsertBooking(BookingEntry booking) {
    return into(bookingsTable).insertOnConflictUpdate(booking);
  }

  Future<BookingEntry?> getBookingById(String id) {
    return (select(bookingsTable)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> deleteBooking(String id) {
    return (delete(bookingsTable)..where((t) => t.id.equals(id))).go();
  }

  // ── Settings Methods ────────────────────────────────────────────────────────

  Future<String?> getSetting(String key) async {
    final row = await (select(settingsTable)..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> setSetting(String key, String value) {
    return into(settingsTable).insertOnConflictUpdate(
      SettingEntry(key: key, value: value),
    );
  }

  // ── User Methods ────────────────────────────────────────────────────────────

  Future<UserEntry?> getUserById(String id) {
    return (select(usersTable)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<UserEntry?> getUserByPhone(String phone) {
    return (select(usersTable)..where((t) => t.phone.equals(phone))).getSingleOrNull();
  }

  Future<UserEntry?> getUserByToken(String token) {
    return (select(usersTable)..where((t) => t.token.equals(token))).getSingleOrNull();
  }

  Future<int> insertUser(UserEntry user) {
    return into(usersTable).insertOnConflictUpdate(user);
  }

  Future<void> updateUser(UserEntry user) {
    return update(usersTable).replace(user);
  }

  Future<void> deleteUser(String id) {
    return (delete(usersTable)..where((t) => t.id.equals(id))).go();
  }
}
