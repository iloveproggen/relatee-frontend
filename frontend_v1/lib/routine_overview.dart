import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend_v1/create_new_task_v1.dart';
import 'package:frontend_v1/detailed_task_view.dart' as detailed_task_view;
import 'package:frontend_v1/main.dart';
import 'package:frontend_v1/profileV2.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';

Future<void> updateRoutine(
    DateTime? startDate, DateTime? refreshDate, int routineId) async {
  final Map<String, dynamic> input = {
    'routineId': routineId,
    'startDate': startDate,
    'refreshDate': refreshDate,
  };

  final Map<String, dynamic> variables = {
    'input': input,
  };

  final client = await getGraphQLClient();
  final QueryOptions options = QueryOptions(
    document: gql(r'''mutation UpdateTask($input: UpdateTaskInput!) {
  updateRoutine(input: $input) {
    id
    startDate
    refreshDate
  }
}
'''),
    variables: variables,
  );
  try {
    final QueryResult result = await client.query(options);
    if (result.hasException) {
      print(result.exception.toString());
    } else if (result.isLoading) {
      print('Loading');
    } else {
      // Handle the result
      print(result.data);
    }
  } catch (e) {
    print(e);
  }
}

class RoutineOverview extends StatefulWidget {
  const RoutineOverview(
      {super.key,
      required this.routine,
      required this.users,
      required this.tasks,
      required this.userData});

  final Map<String, dynamic> routine;
  final List<Map<String, dynamic>> users;
  final List<Map<String, dynamic>> tasks;
  final Map<String, dynamic> userData;

  @override
  State<RoutineOverview> createState() => _RoutineOverviewState();
}

class _RoutineOverviewState extends State<RoutineOverview> {
  bool isPausePickerShown = false;
  DateTime? newStartDate;
  DateTime? newRefreshDate;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isPausePickerShown = false;
  }

  void togglePausePicker() {
    setState(() {
      isPausePickerShown = !isPausePickerShown;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Padding(
          padding: const EdgeInsets.only(top: 80, left: 40, right: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BackIconRow(),
              Row(
                children: [
                  Expanded(
                    child: Text("${widget.routine['name']}",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge),
                  ),
                  IconButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(
                          const EdgeInsets.all(0)),
                    ),
                    icon: Icon(
                        isPausePickerShown
                            ? CupertinoIcons.pause_circle_fill
                            : CupertinoIcons.pause_circle,
                        color: Theme.of(context).colorScheme.tertiary,
                        size: 30),
                    onPressed: () {
                      togglePausePicker();
                    },
                  ),
                ],
              ),
              Text(
                  "start on ${widget.routine['startDate'] != null ? DateFormat("dd-MM-yyy").format(widget.routine['startDate']) : 'unknown'}",
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: userColor,
                      )),
              Text(
                  "next refresh on ${widget.routine['refreshDate'] != null ? DateFormat("dd-MM-yyy").format(widget.routine['refreshDate']) : 'unknown'}",
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: userColor,
                      )),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            right: paddingRight, top: 10, bottom: 10),
                        child: Icon(CupertinoIcons.person_2,
                            color: userColor, size: iconSize),
                      ),
                      Text("icon:",
                          style: Theme.of(context).textTheme.bodySmall),
                      Spacer(),
                      TextButton(
                          onPressed: () {},
                          child: Text(widget.routine['emoji'] ?? "🎉",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontSize: 30,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                      fontWeight: FontWeight.bold)))
                    ],
                  ),
                  isPausePickerShown
                      ? Column(
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 10, bottom: 10, right: paddingRight),
                                  child: Icon(CupertinoIcons.pause_circle,
                                      color: userColor, size: iconSize),
                                ),
                                Text("start date:",
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                                Spacer(),
                                TextButton(
                                    style: ButtonStyle(
                                      padding:
                                          MaterialStateProperty.all<EdgeInsets>(
                                              const EdgeInsets.all(0)),
                                    ),
                                    onPressed: () {
                                      showCupertinoModalPopup(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Container(
                                            height: 300,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            child: CupertinoDatePicker(
                                              initialDateTime: DateTime.now()
                                                  .add(const Duration(days: 2)),
                                              minimumDate: DateTime.now()
                                                  .add(const Duration(days: 1)),
                                              maximumYear:
                                                  DateTime.now().year + 2,
                                              mode:
                                                  CupertinoDatePickerMode.date,
                                              onDateTimeChanged:
                                                  (DateTime value) {
                                                print(value);
                                                setState(() {
                                                  newStartDate = value;
                                                });
                                              },
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Text(
                                        newStartDate == null
                                            ? "pick date"
                                            : DateFormat('dd-MM-yyyy')
                                                .format(newStartDate!)
                                                .toString(),
                                        style: newStartDate == null
                                            ? Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .tertiary,
                                                    fontWeight: FontWeight.bold)
                                            : Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                    fontWeight:
                                                        FontWeight.bold))),
                                IconButton(
                                  icon: Icon(CupertinoIcons.info_circle,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                      size: 20),
                                  onPressed: () {
                                    showCupertinoDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return CupertinoAlertDialog(
                                          title:
                                              const Text('Pausing a Routine'),
                                          content: const Text(
                                              "Pausing a routine will stop it from creating new tasks. You can pick a new start date for the routine to start automatically or leave it blank to pause it for an undefined time."),
                                          actions: <Widget>[
                                            CupertinoDialogAction(
                                              child: const Text('OK',
                                                  style: TextStyle(
                                                      color: Colors.blue)),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(
                                    onPressed: () {
                                      togglePausePicker();
                                      newStartDate = null;
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: 120,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          border: Border.all(color: userColor)),
                                      child: Text("Cancel",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                  color: userColor,
                                                  fontWeight: FontWeight.bold)),
                                    )),
                                TextButton(
                                    onPressed: () {
                                      int? pauseDuration = newStartDate
                                          ?.difference(DateTime.now())
                                          .inDays;
                                      showCupertinoDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CupertinoAlertDialog(
                                            title: Text(
                                                "Pause Routine ${widget.routine['name']}?"),
                                            content: pauseDuration != null
                                                ? Text(
                                                    "This routine will be paused for $pauseDuration days. It will start on ${DateFormat('EEEE, dd-MM-yyyy').format(newStartDate!)}")
                                                : const Text(
                                                    "This routine will be paused indefinitely. To start it again, return to this view."),
                                            actions: [
                                              CupertinoDialogAction(
                                                child: Text('Cancel', style: TextStyle(color: Colors.red)),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              CupertinoDialogAction(
                                                child: Text('OK', style: TextStyle(color: Colors.blue)),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  togglePausePicker();
                                                  if (newStartDate != null) {
                                                    widget.routine[
                                                            'startDate'] =
                                                        newStartDate;
                                                    widget.routine[
                                                            'refreshDate'] =
                                                        newStartDate?.add(Duration(
                                                            days: widget.routine[
                                                                    'interval'] ??
                                                                0));
                                                  } else {
                                                    widget.routine[
                                                        'startDate'] = null;
                                                    widget.routine[
                                                        'refreshDate'] = null;
                                                  }
                                                  if (newStartDate != null) {
                                                    updateRoutine(
                                                        widget.routine[
                                                            'startDate'],
                                                        widget.routine[
                                                            'refreshDate'],
                                                        widget.routine['id']);
                                                  }
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: 120,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      decoration: BoxDecoration(
                                          color: userColor,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          border: Border.all(color: userColor)),
                                      child: Text("Confirm",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  fontWeight: FontWeight.bold)),
                                    )),
                              ],
                            )
                          ],
                        )
                      : Container(),
                  const SizedBox(height: 50),
                  Text(
                    "All Tasks",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
              widget.tasks.isEmpty
                  ? Text("No tasks found.",
                      style: Theme.of(context).textTheme.bodySmall)
                  : Column(
                      children: widget.tasks.map((task) {
                        return RoutineTask(
                            task: task,
                            users: widget.users,
                            userData: widget.userData);
                      }).toList(),
                    ),
              const SizedBox(height: 30),
            ],
          )),
    ));
  }
}

class RoutineTask extends StatelessWidget {
  const RoutineTask(
      {super.key,
      required this.task,
      required this.users,
      required this.userData});

  final Map<String, dynamic> task;
  final Map<String, dynamic> userData;
  final List<Map<String, dynamic>> users;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextButton(
        style: ButtonStyle(
            animationDuration: Duration.zero,
            padding: MaterialStateProperty.all<EdgeInsets>(
              const EdgeInsets.all(0),
            )),
        onPressed: () => Get.to(() => detailed_task_view.DetailedTaskView(
              task: task,
              userData: userData,
              assigned: users.firstWhere((user) => user['id'] == task['userId'],
                  orElse: () => {'forename': null})['forename'],
            )),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(25)),
            color: Theme.of(context).colorScheme.primary,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.secondary,
                offset: const Offset(5.0, 5.0),
                blurRadius: 10.0,
                spreadRadius: 2.0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 240),
                  child: Text(task['name'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          )),
                ),
                Container(
                  constraints: const BoxConstraints(maxWidth: 180),
                  child: (users.firstWhere(
                              (user) => user['id'] == task['userId'],
                              orElse: () => {'forename': null})['forename']) ==
                          null
                      ? Text('anyone',
                          style: Theme.of(context).textTheme.bodySmall)
                      : Text(
                          "${users.firstWhere((user) => user['id'] == task['userId'], orElse: () => {
                                'forename': null
                              })['forename']}",
                          style: Theme.of(context).textTheme.bodySmall),
                ),
                const SizedBox(height: 10),
                Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      border: Border.all(
                          color: Theme.of(context).colorScheme.tertiary),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: Container(
                        child: Text(task['reward'].toString() + " pts",
                            style: Theme.of(context).textTheme.bodySmall),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
