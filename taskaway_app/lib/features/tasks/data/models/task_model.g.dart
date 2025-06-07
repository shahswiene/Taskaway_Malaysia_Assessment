// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Task _$TaskFromJson(Map<String, dynamic> json) => $checkedCreate(
  '_Task',
  json,
  ($checkedConvert) {
    final val = _Task(
      id: $checkedConvert('id', (v) => v as String),
      title: $checkedConvert('title', (v) => v as String),
      isCompleted: $checkedConvert('is_completed', (v) => v as bool? ?? false),
      createdAt: $checkedConvert(
        'created_at',
        (v) => DateTime.parse(v as String),
      ),
      updatedAt: $checkedConvert(
        'updated_at',
        (v) => DateTime.parse(v as String),
      ),
      isDeleted: $checkedConvert('is_deleted', (v) => v as bool? ?? false),
    );
    return val;
  },
  fieldKeyMap: const {
    'isCompleted': 'is_completed',
    'createdAt': 'created_at',
    'updatedAt': 'updated_at',
    'isDeleted': 'is_deleted',
  },
);


Map<String, dynamic> _$TaskToJson(_Task instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'is_completed': instance.isCompleted,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'is_deleted': instance.isDeleted,
};
