import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:neural_graph/root_store.dart';
import 'package:neural_graph/tasks/task_model.dart';

part 'tasks_store.g.dart';

class TasksStore extends _TasksStore with _$TasksStore {
  static TasksStore get instance => GetIt.instance.get<RootStore>().tasksStore;
}

abstract class _TasksStore with Store {
  final tasks = ObservableList<Task>();
  final tasksReferences = ObservableMap<String, ObservableList<Task>>();

  @action
  void addTask() {
    tasks.add(Task());
  }

  @action
  bool removeTask(
    Task task, {
    bool removeChildren = true,
  }) {
    final children = tasksReferences[task.id];
    if (children != null) {
      for (final child in children) {
        if (removeChildren) {
          removeTask(child, removeChildren: true);
        }
        child.parentTaskId = null;
      }
    }

    if (task.parentTaskId != null) {
      final children = tasksReferences.update(
        task.parentTaskId!,
        (value) {
          value.remove(task);
          return value;
        },
      );
      if (children.isEmpty) {
        tasksReferences.remove(task.parentTaskId);
      }
    }
    return tasks.remove(task);
  }

  @action
  Task addChildTask(Task parentTask) {
    final childTask = Task();
    childTask.parentTaskId = parentTask.id;

    tasksReferences.update(
      parentTask.id,
      (value) {
        value.add(childTask);
        return value;
      },
      ifAbsent: () => ObservableList.of([childTask]),
    );
    // tasks.add(childTask);

    return childTask;
  }

  List<Task> childTasks(Task parentTask) =>
      tasksReferences[parentTask.id] ?? [];
}

class TaskController {
  final TasksStore store;
  final Task task;
  final childTasks = ObservableList<Task>();

  TaskController(
    this.store,
    this.task,
  );
}
