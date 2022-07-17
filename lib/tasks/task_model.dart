import 'package:formgen/formgen.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobx/mobx.dart';
import 'package:neural_graph/tasks/tasks_store.dart';
import 'package:uuid/uuid.dart';

part 'task_model.g.dart';

@Validate()
@JsonSerializable()
class Task extends _Task with _$Task {
  Task({String? id}) : this.id = id ?? const Uuid().v4();

  @override
  final String id;

  factory Task.fromJson(Map<String, Object?> json) => _$TaskFromJson(json);
  Map<String, Object?> toJson() => _$TaskToJson(this);
}

abstract class _Task with Store {
  String get id;

  @observable
  String? parentTaskId;

  @observable
  String name = '';

  @observable
  String description = '';

  @ValidateDuration(
    comp: ValidateComparison(
      moreEq: CompVal(Duration(minutes: 5)),
      lessEq: CompVal.list([
        CompVal(Duration(days: 4)),
        CompVal.ref('maxDuration'),
      ]),
    ),
  )
  @observable
  Duration minDuration = const Duration(hours: 2);

  @ValidateDuration(
    comp: ValidateComparison(
      moreEq: CompVal(Duration(minutes: 5)),
      lessEq: CompVal(Duration(days: 4)),
    ),
  )
  @observable
  Duration maxDuration = const Duration(hours: 6);

  @observable
  DateTime? deliveryDate;

  @ValidationFunction()
  static List<ValidationError> _validateTask(Task value) {
    final tasksSameName = TasksStore.instance.tasks.where(
      (t) => t.name == value.name,
    );
    return [
      if (tasksSameName.length > 1)
        ValidationError(
          errorCode: 'Task.duplicateName',
          message: 'Can\'t have tasks with duplicate names: "${value.name}"',
          property: 'name',
          value: value.name,
        )
    ];
  }

  late final validation = Computed<TaskValidation>(() {
    return validateTask(this as Task);
  }, name: 'validation');

  @ValidateNum(
    comp: ValidateComparison(
      moreEq: CompVal(0),
      lessEq: CompVal.list([CompVal(100), CompVal.ref('maxWeight')]),
    ),
  )
  @observable
  int minWeight = 21;

  @ValidateNum(
    comp: ValidateComparison(
      moreEq: CompVal(0),
      lessEq: CompVal(100),
    ),
  )
  @observable
  int maxWeight = 34;
}
