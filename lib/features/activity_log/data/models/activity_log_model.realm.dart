// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_log_model.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class ActivityLog extends _ActivityLog
    with RealmEntity, RealmObjectBase, RealmObject {
  ActivityLog(
    ObjectId id,
    DateTime timestamp,
    String action,
    String category,
    String description,
    String userId, {
    String? referenceId,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'timestamp', timestamp);
    RealmObjectBase.set(this, 'action', action);
    RealmObjectBase.set(this, 'category', category);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'userId', userId);
    RealmObjectBase.set(this, 'referenceId', referenceId);
  }

  ActivityLog._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  DateTime get timestamp =>
      RealmObjectBase.get<DateTime>(this, 'timestamp') as DateTime;
  @override
  set timestamp(DateTime value) =>
      RealmObjectBase.set(this, 'timestamp', value);

  @override
  String get action => RealmObjectBase.get<String>(this, 'action') as String;
  @override
  set action(String value) => RealmObjectBase.set(this, 'action', value);

  @override
  String get category =>
      RealmObjectBase.get<String>(this, 'category') as String;
  @override
  set category(String value) => RealmObjectBase.set(this, 'category', value);

  @override
  String get description =>
      RealmObjectBase.get<String>(this, 'description') as String;
  @override
  set description(String value) =>
      RealmObjectBase.set(this, 'description', value);

  @override
  String get userId => RealmObjectBase.get<String>(this, 'userId') as String;
  @override
  set userId(String value) => RealmObjectBase.set(this, 'userId', value);

  @override
  String? get referenceId =>
      RealmObjectBase.get<String>(this, 'referenceId') as String?;
  @override
  set referenceId(String? value) =>
      RealmObjectBase.set(this, 'referenceId', value);

  @override
  Stream<RealmObjectChanges<ActivityLog>> get changes =>
      RealmObjectBase.getChanges<ActivityLog>(this);

  @override
  Stream<RealmObjectChanges<ActivityLog>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<ActivityLog>(this, keyPaths);

  @override
  ActivityLog freeze() => RealmObjectBase.freezeObject<ActivityLog>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'timestamp': timestamp.toEJson(),
      'action': action.toEJson(),
      'category': category.toEJson(),
      'description': description.toEJson(),
      'userId': userId.toEJson(),
      'referenceId': referenceId.toEJson(),
    };
  }

  static EJsonValue _toEJson(ActivityLog value) => value.toEJson();
  static ActivityLog _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'timestamp': EJsonValue timestamp,
        'action': EJsonValue action,
        'category': EJsonValue category,
        'description': EJsonValue description,
        'userId': EJsonValue userId,
      } =>
        ActivityLog(
          fromEJson(id),
          fromEJson(timestamp),
          fromEJson(action),
          fromEJson(category),
          fromEJson(description),
          fromEJson(userId),
          referenceId: fromEJson(ejson['referenceId']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(ActivityLog._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      ActivityLog,
      'ActivityLog',
      [
        SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
        SchemaProperty('timestamp', RealmPropertyType.timestamp),
        SchemaProperty('action', RealmPropertyType.string),
        SchemaProperty('category', RealmPropertyType.string),
        SchemaProperty('description', RealmPropertyType.string),
        SchemaProperty('userId', RealmPropertyType.string),
        SchemaProperty('referenceId', RealmPropertyType.string, optional: true),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
