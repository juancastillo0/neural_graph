// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Task _$TaskFromJson(Map<String, dynamic> json) => Task(
      id: json['id'] as String?,
    )
      ..parentTaskId = json['parentTaskId'] as String?
      ..name = json['name'] as String
      ..description = json['description'] as String
      ..minDuration = Duration(microseconds: json['minDuration'] as int)
      ..maxDuration = Duration(microseconds: json['maxDuration'] as int)
      ..deliveryDate = json['deliveryDate'] == null
          ? null
          : DateTime.parse(json['deliveryDate'] as String)
      ..minWeight = json['minWeight'] as int
      ..maxWeight = json['maxWeight'] as int;

Map<String, dynamic> _$TaskToJson(Task instance) => <String, dynamic>{
      'parentTaskId': instance.parentTaskId,
      'name': instance.name,
      'description': instance.description,
      'minDuration': instance.minDuration.inMicroseconds,
      'maxDuration': instance.maxDuration.inMicroseconds,
      'deliveryDate': instance.deliveryDate?.toIso8601String(),
      'minWeight': instance.minWeight,
      'maxWeight': instance.maxWeight,
      'id': instance.id,
    };

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$Task on _Task, Store {
  late final _$parentTaskIdAtom =
      Atom(name: '_Task.parentTaskId', context: context);

  @override
  String? get parentTaskId {
    _$parentTaskIdAtom.reportRead();
    return super.parentTaskId;
  }

  @override
  set parentTaskId(String? value) {
    _$parentTaskIdAtom.reportWrite(value, super.parentTaskId, () {
      super.parentTaskId = value;
    });
  }

  late final _$nameAtom = Atom(name: '_Task.name', context: context);

  @override
  String get name {
    _$nameAtom.reportRead();
    return super.name;
  }

  @override
  set name(String value) {
    _$nameAtom.reportWrite(value, super.name, () {
      super.name = value;
    });
  }

  late final _$descriptionAtom =
      Atom(name: '_Task.description', context: context);

  @override
  String get description {
    _$descriptionAtom.reportRead();
    return super.description;
  }

  @override
  set description(String value) {
    _$descriptionAtom.reportWrite(value, super.description, () {
      super.description = value;
    });
  }

  late final _$minDurationAtom =
      Atom(name: '_Task.minDuration', context: context);

  @override
  Duration get minDuration {
    _$minDurationAtom.reportRead();
    return super.minDuration;
  }

  @override
  set minDuration(Duration value) {
    _$minDurationAtom.reportWrite(value, super.minDuration, () {
      super.minDuration = value;
    });
  }

  late final _$maxDurationAtom =
      Atom(name: '_Task.maxDuration', context: context);

  @override
  Duration get maxDuration {
    _$maxDurationAtom.reportRead();
    return super.maxDuration;
  }

  @override
  set maxDuration(Duration value) {
    _$maxDurationAtom.reportWrite(value, super.maxDuration, () {
      super.maxDuration = value;
    });
  }

  late final _$deliveryDateAtom =
      Atom(name: '_Task.deliveryDate', context: context);

  @override
  DateTime? get deliveryDate {
    _$deliveryDateAtom.reportRead();
    return super.deliveryDate;
  }

  @override
  set deliveryDate(DateTime? value) {
    _$deliveryDateAtom.reportWrite(value, super.deliveryDate, () {
      super.deliveryDate = value;
    });
  }

  late final _$minWeightAtom = Atom(name: '_Task.minWeight', context: context);

  @override
  int get minWeight {
    _$minWeightAtom.reportRead();
    return super.minWeight;
  }

  @override
  set minWeight(int value) {
    _$minWeightAtom.reportWrite(value, super.minWeight, () {
      super.minWeight = value;
    });
  }

  late final _$maxWeightAtom = Atom(name: '_Task.maxWeight', context: context);

  @override
  int get maxWeight {
    _$maxWeightAtom.reportRead();
    return super.maxWeight;
  }

  @override
  set maxWeight(int value) {
    _$maxWeightAtom.reportWrite(value, super.maxWeight, () {
      super.maxWeight = value;
    });
  }

  @override
  String toString() {
    return '''
parentTaskId: ${parentTaskId},
name: ${name},
description: ${description},
minDuration: ${minDuration},
maxDuration: ${maxDuration},
deliveryDate: ${deliveryDate},
minWeight: ${minWeight},
maxWeight: ${maxWeight}
    ''';
  }
}

// **************************************************************************
// ValidatorGenerator
// **************************************************************************

enum TaskField {
  minDuration,
  maxDuration,
  minWeight,
  maxWeight,

  global,
}

class TaskValidationFields {
  const TaskValidationFields(this.errorsMap);
  final Map<TaskField, List<ValidationError>> errorsMap;

  List<ValidationError> get minDuration => errorsMap[TaskField.minDuration]!;
  List<ValidationError> get maxDuration => errorsMap[TaskField.maxDuration]!;
  List<ValidationError> get minWeight => errorsMap[TaskField.minWeight]!;
  List<ValidationError> get maxWeight => errorsMap[TaskField.maxWeight]!;
}

class TaskValidation extends Validation<Task, TaskField> {
  TaskValidation(this.errorsMap, this.value, this.fields) : super(errorsMap);

  final Map<TaskField, List<ValidationError>> errorsMap;

  final Task value;

  final TaskValidationFields fields;
}

TaskValidation validateTask(Task value) {
  final errors = <TaskField, List<ValidationError>>{};

  errors[TaskField.global] = [..._Task._validateTask(value)];
  errors[TaskField.minDuration] = [
    if (value.minDuration.compareTo(Duration(microseconds: 345600000000)) > 0 ||
        value.minDuration.compareTo(value.maxDuration) > 0)
      ValidationError(
        message:
            r'Should be at a less than or equal to [96:00:00.000000 , maxDuration]',
        errorCode: 'ValidateComparable.lessEq',
        property: 'minDuration',
        validationParam: "[96:00:00.000000 , maxDuration]",
        value: value.minDuration,
      ),
    if (value.minDuration.compareTo(Duration(microseconds: 300000000)) < 0)
      ValidationError(
        message: r'Should be at a more than or equal to 0:05:00.000000',
        errorCode: 'ValidateComparable.moreEq',
        property: 'minDuration',
        validationParam: "0:05:00.000000",
        value: value.minDuration,
      )
  ];
  errors[TaskField.maxDuration] = [
    if (value.maxDuration.compareTo(Duration(microseconds: 345600000000)) > 0)
      ValidationError(
        message: r'Should be at a less than or equal to 96:00:00.000000',
        errorCode: 'ValidateComparable.lessEq',
        property: 'maxDuration',
        validationParam: "96:00:00.000000",
        value: value.maxDuration,
      ),
    if (value.maxDuration.compareTo(Duration(microseconds: 300000000)) < 0)
      ValidationError(
        message: r'Should be at a more than or equal to 0:05:00.000000',
        errorCode: 'ValidateComparable.moreEq',
        property: 'maxDuration',
        validationParam: "0:05:00.000000",
        value: value.maxDuration,
      )
  ];
  errors[TaskField.minWeight] = [
    if (value.minWeight.compareTo(100) > 0 ||
        value.minWeight.compareTo(value.maxWeight) > 0)
      ValidationError(
        message: r'Should be at a less than or equal to [100 , maxWeight]',
        errorCode: 'ValidateComparable.lessEq',
        property: 'minWeight',
        validationParam: "[100 , maxWeight]",
        value: value.minWeight,
      ),
    if (value.minWeight.compareTo(0) < 0)
      ValidationError(
        message: r'Should be at a more than or equal to 0',
        errorCode: 'ValidateComparable.moreEq',
        property: 'minWeight',
        validationParam: "0",
        value: value.minWeight,
      )
  ];
  errors[TaskField.maxWeight] = [
    if (value.maxWeight.compareTo(100) > 0)
      ValidationError(
        message: r'Should be at a less than or equal to 100',
        errorCode: 'ValidateComparable.lessEq',
        property: 'maxWeight',
        validationParam: "100",
        value: value.maxWeight,
      ),
    if (value.maxWeight.compareTo(0) < 0)
      ValidationError(
        message: r'Should be at a more than or equal to 0',
        errorCode: 'ValidateComparable.moreEq',
        property: 'maxWeight',
        validationParam: "0",
        value: value.maxWeight,
      )
  ];

  return TaskValidation(
    errors,
    value,
    TaskValidationFields(errors),
  );
}
