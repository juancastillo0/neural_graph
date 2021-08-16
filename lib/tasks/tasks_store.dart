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

  @action
  void addTask() {
    tasks.add(Task());
  }

  @action
  bool removeTask(Task task) {
    return tasks.remove(task);
  }
}
