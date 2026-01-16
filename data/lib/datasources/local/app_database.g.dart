// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  MemoDao? _memoDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `MemoEntity` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `memo_text` TEXT NOT NULL, `date` INTEGER NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  MemoDao get memoDao {
    return _memoDaoInstance ??= _$MemoDao(database, changeListener);
  }
}

class _$MemoDao extends MemoDao {
  _$MemoDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _memoEntityInsertionAdapter = InsertionAdapter(
            database,
            'MemoEntity',
            (MemoEntity item) => <String, Object?>{
                  'id': item.id,
                  'memo_text': item.memoText,
                  'date': _dateTimeConverter.encode(item.date)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<MemoEntity> _memoEntityInsertionAdapter;

  @override
  Future<List<MemoEntity>> findMemosByDate(DateTime date) async {
    return _queryAdapter.queryList('SELECT * FROM MemoEntity WHERE date = ?1',
        mapper: (Map<String, Object?> row) => MemoEntity(
            id: row['id'] as int?,
            memoText: row['memo_text'] as String,
            date: _dateTimeConverter.decode(row['date'] as int)),
        arguments: [_dateTimeConverter.encode(date)]);
  }

  @override
  Future<List<MemoEntity>> findAllMemos() async {
    return _queryAdapter.queryList('SELECT * FROM MemoEntity',
        mapper: (Map<String, Object?> row) => MemoEntity(
            id: row['id'] as int?,
            memoText: row['memo_text'] as String,
            date: _dateTimeConverter.decode(row['date'] as int)));
  }

  @override
  Future<void> insertMemo(MemoEntity memo) async {
    await _memoEntityInsertionAdapter.insert(memo, OnConflictStrategy.abort);
  }
}

// ignore_for_file: unused_element
final _dateTimeConverter = DateTimeConverter();
