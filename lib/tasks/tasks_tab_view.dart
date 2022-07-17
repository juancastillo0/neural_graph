import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:neural_graph/root_store.dart';
import 'package:neural_graph/tasks/task_model.dart';
import 'package:neural_graph/tasks/tasks_store.dart';
import 'package:stack_portal/fields.dart';

class TasksTabView extends HookWidget {
  const TasksTabView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final store = TasksStore.instance;
    final scrollController = useScrollController();

    return Observer(builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: FocusTraversalGroup(
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Tasks (${store.tasks.length})',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        store.addTask();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Create Task'),
                    ),
                  )
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: store.tasks.length,
                  controller: scrollController,
                  itemBuilder: (context, index) {
                    final task = store.tasks[index];
                    return FocusTraversalGroup(
                      key: ValueKey(task),
                      child: Center(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TaskItem(task: task),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class TaskItem extends HookWidget {
  const TaskItem({
    Key? key,
    required this.task,
    this.showFields,
  }) : super(key: key);

  final Task task;
  final bool? showFields;

  @override
  Widget build(BuildContext context) {
    final store = useRoot().tasksStore;
    final theme = Theme.of(context);
    final showFieldsOwn = useState(false);
    final _showFields =
        showFieldsOwn.value && showFields == null || showFields == true;

    return Observer(builder: (context) {
      final validation = task.validation.value;
      return Theme(
        data: theme.copyWith(
          inputDecorationTheme: theme.inputDecorationTheme.copyWith(
            errorStyle: const TextStyle(height: 0),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.drag_indicator),
                    IconButton(
                      onPressed: () {
                        showFieldsOwn.value = !showFieldsOwn.value;
                      },
                      icon: AnimatedRotation(
                        turns: _showFields ? 0.5 : 0.75,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInCubic,
                        child: const Icon(Icons.arrow_back_ios_new_rounded),
                      ),
                    )
                  ],
                ),
                IconButton(
                  onPressed: () {
                    store.removeTask(task);
                  },
                  icon: const Icon(Icons.delete),
                )
              ],
            ),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              children: [
                SizedBox(
                  width: 200,
                  child: ErrorOverlay(
                    error: (() {
                      final err = validation.errorsMap[TaskField.global]!
                          .map((e) => e.message)
                          .join();
                      return err.isEmpty ? null : err;
                    })(),
                    child: TextFormField(
                      initialValue: task.name,
                      decoration: InputDecoration(
                        errorText: (() {
                          return validation.errorsMap[TaskField.global]!.isEmpty
                              ? null
                              : '';
                        })(),
                        errorMaxLines: 2,
                        labelText: 'name',
                      ),
                      onChanged: (name) {
                        task.name = name;
                      },
                    ),
                  ),
                ),
                SizedBox(
                    width: 100,
                    child: IntInput(
                      label: 'minWeight',
                      value: task.minWeight,
                      error: (() {
                        final err = validation.fields.minWeight
                            .map((e) => e.message)
                            .join(', ');
                        return err.isEmpty ? null : err;
                      })(),
                      onChanged: (v) {
                        if (v != null) {
                          task.minWeight = v;
                        }
                      },
                    )
                    // TextFormField(
                    //   initialValue: task.minWeight.toString(),
                    //   decoration: InputDecoration(
                    //     errorText: (() {
                    //       final err = validation.fields.minWeight
                    //           .map((e) => e.message)
                    //           .join();
                    //       return err.isEmpty ? null : err;
                    //     })(),
                    //     errorMaxLines: 2,
                    //     labelText: 'minWeight',
                    //   ),
                    //   onChanged: (minWeight) {
                    //     final v = int.tryParse(minWeight);
                    //     if (v != null) {
                    //       task.minWeight = v;
                    //     }
                    //   },
                    // ),
                    ),
                SizedBox(
                  width: 80,
                  child: TextFormField(
                    initialValue: task.maxWeight.toString(),
                    decoration: InputDecoration(
                      errorText: (() {
                        final err = validation.fields.maxWeight
                            .map((e) => e.message)
                            .join();
                        return err.isEmpty ? null : err;
                      })(),
                      errorMaxLines: 2,
                      labelText: 'maxWeight',
                    ),
                    validator: (v) {
                      if (v != null) {
                        final p = int.tryParse(v);
                        return p == null ? 'invalid integer' : null;
                      }
                    },
                    onChanged: (maxWeight) {
                      final v = int.tryParse(maxWeight);
                      if (v != null) {
                        task.maxWeight = v;
                      }
                    },
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Observer(
                      builder: (context) {
                        return DurationInputButton(
                          title: 'Min Duration',
                          duration: task.minDuration,
                          onChanged: (dur) {
                            task.minDuration = dur;
                          },
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    Observer(
                      builder: (context) {
                        return DurationInputButton(
                          title: 'Max Duration',
                          duration: task.maxDuration,
                          onChanged: (dur) {
                            task.maxDuration = dur;
                          },
                        );
                      },
                    ),
                  ],
                ),
                Observer(
                  builder: (context) {
                    return DateInput(
                      title: 'Due Date',
                      date: task.deliveryDate,
                      firstDate: DateTime.now().add(const Duration(days: -1)),
                      lastDate: DateTime.now().add(const Duration(days: 366)),
                      onChanged: OnChange.opt((result) {
                        task.deliveryDate = result;
                      }),
                    );
                  },
                ),
                SizedBox(
                  width: 400,
                  height: 80,
                  child: TextFormField(
                    initialValue: task.description,
                    expands: true,
                    maxLines: null,
                    decoration: const InputDecoration(
                      errorMaxLines: 2,
                      labelText: 'description',
                    ),
                    onChanged: (description) {
                      task.description = description;
                    },
                  ),
                ),
              ],
            ),
            Builder(builder: (context) {
              final error = validation.errorsMap.entries
                  .where((e) => e.value.isNotEmpty)
                  .map((e) => e.value)
                  .join(',');
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeInQuad,
                switchOutCurve: Curves.easeOutQuad,
                transitionBuilder: (child, animation) => SizeTransition(
                  sizeFactor: animation,
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                ),
                child: error.isEmpty
                    ? const SizedBox()
                    : Center(
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 100),
                          color: Theme.of(context)
                              .colorScheme
                              .error
                              .withOpacity(0.1),
                          padding: const EdgeInsets.all(18.0),
                          margin: const EdgeInsets.all(8.0),
                          child: Text(
                            error,
                          ),
                        ),
                      ),
              );
            }),
            if (task.parentTaskId == null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Subtasks',
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          const SizedBox(width: 10),
                          TextButton(
                            onPressed: () {
                              store.addChildTask(task);
                            },
                            child: const Text('Add'),
                          )
                        ],
                      ),
                      Observer(
                        builder: (context) {
                          final childTasks = store.childTasks(task);
                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                ...childTasks.map(
                                  (e) => TaskItem(
                                    task: e,
                                    showFields: false,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
