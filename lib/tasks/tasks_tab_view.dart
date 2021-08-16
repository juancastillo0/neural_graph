import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:neural_graph/tasks/task_model.dart';
import 'package:neural_graph/tasks/tasks_store.dart';
import 'package:stack_portal/stack_portal.dart';

class TasksTabView extends StatelessObserverWidget {
  const TasksTabView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final store = TasksStore.instance;
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
  }
}

class TaskItem extends StatelessObserverWidget {
  const TaskItem({Key? key, required this.task}) : super(key: key);
  final Task task;

  @override
  Widget build(BuildContext context) {
    final validation = task.validation.value;
    return Column(
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.center,
          children: [
            SizedBox(
              width: 200,
              child: TextFormField(
                initialValue: task.name,
                decoration: InputDecoration(
                  errorText: (() {
                    final err = validation.errorsMap[TaskField.global]!
                        .map((e) => e.message)
                        .join();
                    return err.isEmpty ? null : err;
                  })(),
                  errorMaxLines: 2,
                  labelText: 'name',
                ),
                onChanged: (name) {
                  task.name = name;
                },
              ),
            ),
            SizedBox(
              width: 80,
              child: TextFormField(
                initialValue: task.minWeight.toString(),
                decoration: InputDecoration(
                  errorText: (() {
                    final err = validation.fields.minWeight
                        .map((e) => e.message)
                        .join();
                    return err.isEmpty ? null : err;
                  })(),
                  errorMaxLines: 2,
                  labelText: 'minWeight',
                ),
                onChanged: (minWeight) {
                  final v = int.tryParse(minWeight);
                  if (v != null) {
                    task.minWeight = v;
                  }
                },
              ),
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
                    return DurationInput(
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
                    return DurationInput(
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
                  onChanged: (result) {
                    task.deliveryDate = result;
                  },
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
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 100),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              validation.errorsMap.entries
                  .where((e) => e.value.isNotEmpty)
                  .map((e) => e.value)
                  .join(','),
            ),
          ),
        ),
      ],
    );
  }
}

class DateInput extends StatelessWidget {
  const DateInput({
    Key? key,
    required this.title,
    required this.date,
    required this.onChanged,
  }) : super(key: key);

  final String title;
  final DateTime? date;
  final void Function(DateTime) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title),
        Builder(
          builder: (context) {
            final String dateStr;
            final _date = date;
            if (_date == null) {
              dateStr = 'Not configured';
            } else {
              final now = DateTime.now();
              final sameYear = now.year != _date.year;
              final sameMonth = now.month != _date.month;
              final sameDay = now.day != _date.day;
              dateStr = '${sameYear ? '' : '${_date.year}-'}'
                  '${sameYear && sameMonth ? '' : '${_date.month}-'}'
                  '${sameYear && sameMonth && sameDay ? '' : '${_date.day}'}';
            }
            return InkWell(
              onTap: () async {
                final result = await showDatePicker(
                  context: context,
                  initialDate:
                      date ?? DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now().add(const Duration(days: -1)),
                  lastDate: DateTime.now().add(const Duration(days: 366)),
                );
                if (result != null) {
                  onChanged(result);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 10.0,
                ),
                child: Text(
                  dateStr,
                ),
              ),
            );
          },
        )
      ],
    );
  }
}

class DurationInput extends StatelessWidget {
  const DurationInput({
    Key? key,
    required this.duration,
    required this.onChanged,
    required this.title,
  }) : super(key: key);

  final Duration duration;
  final void Function(Duration) onChanged;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title),
        Builder(
          builder: (context) {
            final mins = duration.inMinutes;
            final String str;
            if (mins > Duration.minutesPerDay * 30) {
              final months = (mins / (Duration.minutesPerDay * 30)).floor();
              final days =
                  (mins - (months * Duration.minutesPerDay * 30)).round();
              str = '${months}m ${days}d';
            } else if (mins > Duration.minutesPerDay) {
              final days = (mins / (Duration.minutesPerDay)).floor();
              final hours = (mins - (days * Duration.minutesPerDay)).round();
              str = '${days}d ${hours}h';
            } else {
              final hours = (mins / (Duration.minutesPerHour)).floor();
              final _mins = (mins - (hours * Duration.minutesPerHour)).round();
              str = '${hours}h ${_mins}m';
            }
            return CustomOverlayButton.stack(
              portalBuilder: (notifier) {
                return SizedBox(
                  width: 200,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 80,
                            child: TextFormField(),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 10.0,
                ),
                child: Text(
                  str,
                ),
              ),
            );
          },
        )
      ],
    );
  }
}
